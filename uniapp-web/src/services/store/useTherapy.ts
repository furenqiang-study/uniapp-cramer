import { computed, ref, onUnmounted } from 'vue'
import { bleDevice, type DeviceSnapshot } from '../ble/device'
import type { AlarmItem, Protocol, SessionPoint, ZoneId } from '../types'
import { ZONES, uid } from '../types'
import {
  collectSession,
  defaultProtocols,
  getEnvSettings,
  loadProtocols,
  newSessionId,
  saveSession,
  setEnvSettings
} from '../store/therapyStore'
import { evaluateSafety } from '../control/safety'

const snapshot = ref<DeviceSnapshot>(bleDevice.snapshot())
const alarms = ref<AlarmItem[]>([])
const points = ref<SessionPoint[]>([])
const currentProtocol = ref<Protocol>(defaultProtocols()[0])
const sessionId = ref<string | null>(null)
const sessionStart = ref<number | null>(null)
const remoteSessionId = ref<number | null>(null)
let unsub: (() => void) | null = null
let sampleTimer: ReturnType<typeof setInterval> | null = null

function ensureSubscribed() {
  if (unsub) return
  unsub = bleDevice.subscribe((snap) => {
    snapshot.value = snap
    if (snap.running) {
      const pts = {} as Record<ZoneId, number>
      for (const z of snap.zones) pts[z.id] = z.scalpTemp
      const power = snap.zones.reduce((a, b) => a + b.power, 0) / snap.zones.length
      points.value.push({ t: Date.now(), zones: pts, power, deltaT: snap.deltaT })
      if (points.value.length > 720) points.value.shift()
      const found = evaluateSafety({
        zones: snap.zones,
        dewPoint: snap.env.dewPoint,
        margin: snap.env.margin
      })
      // keep latest unique-ish codes per zone
      const map = new Map(alarms.value.map((a) => [a.id, a]))
      for (const a of found) {
        const key = `${a.code}_${a.zoneId || 'global'}`
        const exists = [...map.values()].find((x) => `${x.code}_${x.zoneId || 'global'}` === key)
        if (exists) {
          exists.ts = a.ts
          exists.message = a.message
          exists.level = a.level
        } else {
          map.set(a.id, a)
        }
      }
      alarms.value = [...map.values()].sort((a, b) => b.ts - a.ts).slice(0, 50)
    }
  })
}

export function useTherapy() {
  ensureSubscribed()
  const env = getEnvSettings()
  if (bleDevice.snapshot().env.temp !== env.temp) {
    bleDevice.setEnvironment(env.temp, env.humidity)
  }

  const zones = computed(() => snapshot.value.zones)
  const connected = computed(() => snapshot.value.status === 'connected')
  const connecting = computed(() => snapshot.value.status === 'connecting')
  const running = computed(() => snapshot.value.running)
  const alarmCount = computed(() => alarms.value.filter((a) => a.level !== 'info').length)
  const protocols = ref<Protocol[]>(loadProtocols())

  const elapsedMin = computed(() => {
    if (!sessionStart.value) return 0
    return Math.floor((Date.now() - sessionStart.value) / 60000)
  })

  async function connect() {
    await bleDevice.connect()
  }

  async function disconnect() {
    await bleDevice.disconnect()
  }

  function start(protocol?: Protocol) {
    if (protocol) {
      currentProtocol.value = protocol
      const map = {} as Record<ZoneId, number>
      const stage = protocol.stages[0]
      for (const z of ZONES) map[z.id] = stage?.targetTemp ?? z.defaultSetpoint
      bleDevice.setAllSetpoints(map)
    }
    points.value = []
    sessionId.value = newSessionId()
    sessionStart.value = Date.now()
    remoteSessionId.value = null
    bleDevice.startTreatment()
    if (!sampleTimer) {
      sampleTimer = setInterval(() => {
        snapshot.value = { ...snapshot.value }
      }, 1000)
    }
  }

  function setRemoteSessionId(id: number | null) {
    remoteSessionId.value = id
  }

  function stop(reason = '用户结束') {
    const snap = snapshot.value
    const started = sessionStart.value || snap.startTime || Date.now()
    const protocol = currentProtocol.value
    const ses = collectSession({
      id: sessionId.value || newSessionId(),
      startedAt: started,
      protocol,
      env: snap.env,
      alarms: [...alarms.value],
      points: [...points.value],
      endReason: reason
    })
    saveSession(ses)
    bleDevice.stopTreatment(true)
    sessionStart.value = null
    sessionId.value = null
    remoteSessionId.value = null
    alarms.value = []
    points.value = []
    return ses
  }

  function setEnv(temp: number, humidity: number) {
    bleDevice.setEnvironment(temp, humidity)
    setEnvSettings(temp, humidity)
  }

  function applySetpoints(map: Partial<Record<ZoneId, number>>) {
    bleDevice.setAllSetpoints(map)
  }

  function refreshProtocols() {
    protocols.value = loadProtocols()
  }

  function clearAlarms() {
    alarms.value = []
  }

  function dispose() {
    unsub?.()
    unsub = null
    if (sampleTimer) {
      clearInterval(sampleTimer)
      sampleTimer = null
    }
  }

  return {
    snapshot,
    zones,
    connected,
    connecting,
    running,
    alarms,
    alarmCount,
    points,
    currentProtocol,
    protocols,
    elapsedMin,
    remoteSessionId,
    connect,
    disconnect,
    start,
    stop,
    setRemoteSessionId,
    setEnv,
    applySetpoints,
    refreshProtocols,
    clearAlarms,
    dispose
  }
}

export function shortId() {
  return uid('x')
}
