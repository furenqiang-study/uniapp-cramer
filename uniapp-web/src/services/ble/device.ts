import {
  ZONES,
  type EnvironmentInfo,
  type ZoneId,
  type ZoneTelemetry
} from '../types'
import { calcDewPoint } from '../control/dewpoint'
import {
  clampDewPointSetpoints,
  coordinate,
  createPidStates,
  pidStep,
  simulateColdSide,
  simulateCurrent,
  simulateHotSide,
  simulateScalp,
  zoneStateOf,
  type PidZoneState
} from '../control/pidSim'
import { SAFETY } from '../types'

export type BleStatus = 'disconnected' | 'connecting' | 'connected'

export interface DeviceSnapshot {
  status: BleStatus
  deviceName: string
  running: boolean
  zones: ZoneTelemetry[]
  env: EnvironmentInfo
  deltaT: number
  meanT: number
  uniformity: 'excellent' | 'good' | 'poor'
  startTime: number | null
  clampedByDewpoint: boolean
}

type Listener = (snap: DeviceSnapshot) => void

export class MockBleDevice {
  private status: BleStatus = 'disconnected'
  private running = false
  private timer: ReturnType<typeof setInterval> | null = null
  private listeners = new Set<Listener>()
  private pid = createPidStates()
  private powers = {} as Record<ZoneId, number>
  private temps = {} as Record<ZoneId, number>
  private setpoints = {} as Record<ZoneId, number>
  private faults = {} as Record<ZoneId, string | null>
  private contact = {} as Record<ZoneId, boolean>
  private env: EnvironmentInfo = {
    temp: 26,
    humidity: 55,
    dewPoint: calcDewPoint(26, 55),
    margin: SAFETY.dewPointMargin,
    safe: true
  }
  private startTime: number | null = null
  private clampedByDewpoint = false
  private tick = 0
  deviceName = 'CoolCap-SC6'

  constructor() {
    this.resetState()
  }

  subscribe(fn: Listener) {
    this.listeners.add(fn)
    fn(this.snapshot())
    return () => this.listeners.delete(fn)
  }

  snapshot(): DeviceSnapshot {
    const zones = this.buildZones()
    const temps = zones.map((z) => z.scalpTemp)
    const meanT = temps.reduce((a, b) => a + b, 0) / temps.length
    const deltaT = Math.max(...temps) - Math.min(...temps)
    const uniformity =
      deltaT <= SAFETY.uniformExcellent ? 'excellent' : deltaT <= SAFETY.uniformGood ? 'good' : 'poor'
    return {
      status: this.status,
      deviceName: this.deviceName,
      running: this.running,
      zones,
      env: { ...this.env },
      deltaT,
      meanT,
      uniformity,
      startTime: this.startTime,
      clampedByDewpoint: this.clampedByDewpoint
    }
  }

  async connect(): Promise<void> {
    if (this.status === 'connected') return
    this.status = 'connecting'
    this.emit()
    await sleep(700)
    this.status = 'connected'
    this.emit()
  }

  async disconnect(): Promise<void> {
    this.stopTreatment(false)
    this.status = 'disconnected'
    this.emit()
  }

  setEnvironment(temp: number, humidity: number) {
    this.env.temp = temp
    this.env.humidity = humidity
    this.env.dewPoint = Math.round(calcDewPoint(temp, humidity) * 10) / 10
    this.env.margin = SAFETY.dewPointMargin
    this.emit()
  }

  setSetpoint(zoneId: ZoneId, temp: number) {
    this.setpoints[zoneId] = temp
    this.emit()
  }

  setAllSetpoints(map: Partial<Record<ZoneId, number>>) {
    for (const z of ZONES) {
      if (map[z.id] != null) this.setpoints[z.id] = map[z.id] as number
    }
    this.emit()
  }

  toggleContact(zoneId: ZoneId, on: boolean) {
    this.contact[zoneId] = on
    if (!on) this.faults[zoneId] = null
    this.emit()
  }

  injectFault(zoneId: ZoneId, code: string | null) {
    this.faults[zoneId] = code
    this.emit()
  }

  startTreatment() {
    if (this.status !== 'connected') return
    this.running = true
    this.startTime = Date.now()
    this.pid = createPidStates()
    this.ensureTimer()
    this.emit()
  }

  stopTreatment(_archive = true) {
    this.running = false
    this.startTime = null
    for (const z of ZONES) this.powers[z.id] = 0
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
    this.emit()
  }

  private ensureTimer() {
    if (this.timer) return
    this.timer = setInterval(() => this.step(), 1000)
  }

  private step() {
    this.tick += 1
    if (!this.running) return

    // dew point clamp
    const { setpoints, clamped } = clampDewPointSetpoints(
      this.setpoints,
      this.env.dewPoint,
      SAFETY.dewPointMargin
    )
    this.clampedByDewpoint = clamped
    if (clamped) {
      for (const k of Object.keys(setpoints) as ZoneId[]) this.setpoints[k] = setpoints[k]
    }

    const rawPowers = {} as Record<ZoneId, number>
    for (const z of ZONES) {
      const fault = this.faults[z.id]
      if (fault || !this.contact[z.id]) {
        rawPowers[z.id] = fault ? 0 : Math.max(0, (this.powers[z.id] || 0) - 15)
        continue
      }
      const pid = this.pid[z.id]
      let p = pidStep(this.setpoints[z.id], this.temps[z.id], pid)
      // frost / hot protect soft clamp
      if (this.temps[z.id] < SAFETY.scalpLowerLimit) p = Math.max(0, p - 25)
      if (this.temps[z.id] < SAFETY.scalpHardStop) p = 0
      const hs = simulateHotSide(this.temps[z.id], p)
      if (hs > SAFETY.hotSideStop) p = 0
      else if (hs > SAFETY.hotSideWarn) p = Math.min(p, 55)
      rawPowers[z.id] = p
    }

    const zoneObjs = this.buildZones()
    const { powers, meta } = coordinate(zoneObjs, rawPowers)

    // biome noise + slow ambient load
    for (const z of ZONES) {
      const noise = (Math.sin(this.tick / 7 + z.id.charCodeAt(0)) + Math.random() - 0.5) * 0.05
      if (this.faults[z.id]) {
        this.temps[z.id] = Math.min(28, this.temps[z.id] + 0.05)
        this.powers[z.id] = 0
        continue
      }
      this.powers[z.id] = powers[z.id]
      this.temps[z.id] = simulateScalp(this.temps[z.id], this.setpoints[z.id], powers[z.id], this.env.temp + noise)
    }

    // occasional soft contact blip for demo if very stable long run — skip auto fault
    this.emit()
  }

  private buildZones(): ZoneTelemetry[] {
    return ZONES.map((z) => {
      const power = this.powers[z.id] || 0
      const scalp = this.temps[z.id]
      const fault = this.faults[z.id]
      const protect = scalp < SAFETY.scalpHardStop
      const contact = this.contact[z.id]
      return {
        id: z.id,
        name: z.name,
        scalpTemp: scalp,
        coldSideTemp: contact ? simulateColdSide(scalp, power) : scalp,
        hotSideTemp: simulateHotSide(scalp, power),
        current: simulateCurrent(power, !!fault || !contact),
        power,
        contact,
        fault,
        setpoint: this.setpoints[z.id],
        state: zoneStateOf(power, this.setpoints[z.id], scalp, fault, protect),
        compensated: false
      }
    })
  }

  private resetState() {
    for (const z of ZONES) {
      this.powers[z.id] = 0
      this.temps[z.id] = 30.5 + Math.random() * 0.8
      this.setpoints[z.id] = z.defaultSetpoint
      this.faults[z.id] = null
      this.contact[z.id] = true
    }
  }

  private emit() {
    const snap = this.snapshot()
    for (const fn of this.listeners) fn(snap)
  }
}

function sleep(ms: number) {
  return new Promise((r) => setTimeout(r, ms))
}

export const bleDevice = new MockBleDevice()
