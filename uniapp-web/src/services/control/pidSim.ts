import { SAFETY, ZONES, type ZoneId, type ZoneTelemetry } from '../types'

export interface PidZoneState {
  integral: number
  lastError: number
}

export function createPidStates(): Record<ZoneId, PidZoneState> {
  const m = {} as Record<ZoneId, PidZoneState>
  for (const z of ZONES) m[z.id] = { integral: 0, lastError: 0 }
  return m
}

/** Simple PID → power 0..100 */
export function pidStep(
  setpoint: number,
  measured: number,
  st: PidZoneState,
  dt = 1
): number {
  const error = measured - setpoint
  st.integral = clamp(st.integral + error * dt, -50, 50)
  const derivative = error - st.lastError
  st.lastError = error
  const kp = 8
  const ki = 0.4
  const kd = 1.2
  const out = kp * error + ki * st.integral + kd * derivative
  return clamp(out, 0, 100)
}

/** Plant simulation: scalp approaches setpoint under cooling power */
export function simulateScalp(
  current: number,
  setpoint: number,
  power: number,
  ambient = 25,
  dt = 1
): number {
  // cooling strength proportional to power; floor toward setpoint
  const targetFloor = setpoint
  const cooling = (power / 100) * 0.35 * dt
  const drift = (ambient - current) * 0.008 * dt
  let next = current - cooling + drift
  // prevent infinite dive
  if (next < targetFloor - 0.8) next = targetFloor - 0.8 + (next - (targetFloor - 0.8)) * 0.5
  return round1(next)
}

export function simulateColdSide(scalp: number, power: number): number {
  return round1(scalp - (power / 100) * 6 - 1.5)
}

export function simulateHotSide(scalp: number, power: number, base = 28): number {
  return round1(base + (power / 100) * 28 + (25 - scalp) * 0.15)
}

export function simulateCurrent(power: number, fault = false): number {
  if (fault) return 0
  return round2((power / 100) * 1.8 + 0.05)
}

export interface CoordinationResult {
  effectivePower: number
  compensated: boolean
  deltaT: number
  meanT: number
  uniformity: 'excellent' | 'good' | 'poor'
}

export function coordinate(
  zones: ZoneTelemetry[],
  powers: Record<ZoneId, number>
): { powers: Record<ZoneId, number>; meta: Omit<CoordinationResult, 'effectivePower'> & { byZone: Record<ZoneId, CoordinationResult> } } {
  const temps = zones.map((z) => z.scalpTemp)
  const meanT = temps.reduce((a, b) => a + b, 0) / temps.length
  const maxT = Math.max(...temps)
  const minT = Math.min(...temps)
  const deltaT = maxT - minT
  const uniformity = deltaT <= SAFETY.uniformExcellent ? 'excellent' : deltaT <= SAFETY.uniformGood ? 'good' : 'poor'

  const next = { ...powers }
  const byZone = {} as Record<ZoneId, CoordinationResult>

  for (const z of zones) {
    let p = next[z.id]
    let compensated = false
    if (deltaT > SAFETY.uniformExcellent && z.scalpTemp > meanT + 0.2) {
      const comp = Math.min(12, (z.scalpTemp - meanT) * 6)
      p = clamp(p + comp, 0, 100)
      compensated = comp > 0.5
    }
    next[z.id] = p
    byZone[z.id] = { effectivePower: p, compensated, deltaT, meanT, uniformity }
  }

  return { powers: next, meta: { deltaT, meanT, uniformity, byZone } }
}

export function clampDewPointSetpoints(
  setpoints: Record<ZoneId, number>,
  dewPoint: number,
  margin: number
): { setpoints: Record<ZoneId, number>; clamped: boolean } {
  let clamped = false
  const next = { ...setpoints }
  const floor = dewPoint + margin
  for (const k of Object.keys(next) as ZoneId[]) {
    if (next[k] < floor) {
      next[k] = round1(floor)
      clamped = true
    }
  }
  return { setpoints: next, clamped }
}

export function zoneStateOf(
  power: number,
  setpoint: number,
  measured: number,
  fault: string | null,
  protect: boolean
): ZoneTelemetry['state'] {
  if (fault) return 'fault'
  if (protect) return 'protect'
  if (power <= 0.5 && Math.abs(measured - setpoint) < 0.6) return 'idle'
  if (Math.abs(measured - setpoint) <= 0.5) return 'hold'
  return 'ramp'
}

function clamp(v: number, a: number, b: number) {
  return Math.max(a, Math.min(b, v))
}

function round1(v: number) {
  return Math.round(v * 10) / 10
}

function round2(v: number) {
  return Math.round(v * 100) / 100
}
