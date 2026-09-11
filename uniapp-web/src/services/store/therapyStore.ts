import type { AlarmItem, Protocol, TherapySession, UserSession, SessionPoint } from '../types'
import { SAFETY, ZONES, uid } from '../types'

const K = {
  user: 'cc_user',
  token: 'cc_token',
  remember: 'cc_remember',
  protocols: 'cc_protocols',
  sessions: 'cc_sessions',
  env: 'cc_env',
  settings: 'cc_settings'
}

export function getUser(): UserSession | null {
  return uni.getStorageSync(K.user) || null
}

export function setRemember(v: boolean) {
  uni.setStorageSync(K.remember, v ? '1' : '0')
}

export function isRemember() {
  return uni.getStorageSync(K.remember) === '1'
}

export function mockLogin(username: string, password: string): Promise<UserSession> {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (!username || !password) {
        reject(new Error('请输入账号和密码'))
        return
      }
      if (password.length < 4) {
        reject(new Error('密码错误'))
        return
      }
      const user: UserSession = {
        username,
        nickname: username === 'admin' ? '管理员' : username,
        token: uid('tok')
      }
      uni.setStorageSync(K.user, user)
      uni.setStorageSync(K.token, user.token)
      resolve(user)
    }, 400)
  })
}

export function logout() {
  uni.removeStorageSync(K.user)
  uni.removeStorageSync(K.token)
}

export function defaultProtocols(): Protocol[] {
  const now = Date.now()
  return [
    {
      id: 'proto_standard',
      name: '标准化疗冷却（预冷30+维持90+回温30）',
      builtin: true,
      updatedAt: now,
      stages: [
        { name: '预冷', durationMin: 30, targetTemp: 18, maxDuty: 70 },
        { name: '维持', durationMin: 90, targetTemp: 16, maxDuty: 100 },
        { name: '回温', durationMin: 30, targetTemp: 22, maxDuty: 40 }
      ],
      note: '适用于紫杉烷类等常规方案，目标头皮温度约16°C'
    },
    {
      id: 'proto_fast',
      name: '快速预冷（15+60）',
      builtin: true,
      updatedAt: now,
      stages: [
        { name: '快速预冷', durationMin: 15, targetTemp: 17, maxDuty: 90 },
        { name: '维持', durationMin: 60, targetTemp: 16, maxDuty: 100 }
      ]
    },
    {
      id: 'proto_gentle',
      name: '温和方案（高耐受）',
      builtin: true,
      updatedAt: now,
      stages: [
        { name: '预冷', durationMin: 30, targetTemp: 19, maxDuty: 60 },
        { name: '维持', durationMin: 90, targetTemp: 18, maxDuty: 80 },
        { name: '回温', durationMin: 20, targetTemp: 23, maxDuty: 35 }
      ]
    }
  ]
}

export function loadProtocols(): Protocol[] {
  const raw = uni.getStorageSync(K.protocols)
  if (raw && Array.isArray(raw) && raw.length) return raw
  const list = defaultProtocols()
  saveProtocols(list)
  return list
}

export function saveProtocols(list: Protocol[]) {
  uni.setStorageSync(K.protocols, list)
}

export function upsertProtocol(p: Protocol) {
  const list = loadProtocols()
  const i = list.findIndex((x) => x.id === p.id)
  p.updatedAt = Date.now()
  if (i >= 0) list[i] = p
  else list.push(p)
  saveProtocols(list)
  return list
}

export function removeProtocol(id: string) {
  const list = loadProtocols().filter((p) => p.id !== id || p.builtin)
  saveProtocols(list)
  return list
}

export function loadSessions(): TherapySession[] {
  const raw = uni.getStorageSync(K.sessions)
  return raw && Array.isArray(raw) ? raw : []
}

export function saveSession(s: TherapySession) {
  const list = loadSessions()
  list.unshift(s)
  uni.setStorageSync(K.sessions, list.slice(0, 100))
  return list
}

export function getEnvSettings(): { temp: number; humidity: number } {
  const raw = uni.getStorageSync(K.env)
  if (raw && typeof raw === 'object') return raw
  return { temp: 26, humidity: 55 }
}

export function setEnvSettings(temp: number, humidity: number) {
  uni.setStorageSync(K.env, { temp, humidity })
}

export function getSettings() {
  const raw = uni.getStorageSync(K.settings)
  return {
    sound: true,
    mock: true,
    margin: SAFETY.dewPointMargin,
    ...(raw || {})
  }
}

export function setSettings(s: Record<string, unknown>) {
  uni.setStorageSync(K.settings, { ...getSettings(), ...s })
}

export function buildEmptyPointsFrom(zonesTemp: Record<string, number>): SessionPoint[] {
  return []
}

export function summarizePoints(points: SessionPoint[]) {
  let min = 99
  let max = -99
  let sum = 0
  let n = 0
  for (const p of points) {
    for (const id of ZONES.map((z) => z.id)) {
      const t = p.zones[id]
      if (t == null) continue
      min = Math.min(min, t)
      max = Math.max(max, t)
      sum += t
      n++
    }
  }
  if (!n) return { minTemp: 0, maxTemp: 0, avgTemp: 0 }
  return {
    minTemp: Math.round(min * 10) / 10,
    maxTemp: Math.round(max * 10) / 10,
    avgTemp: Math.round((sum / n) * 10) / 10
  }
}

export function exportSessionJson(s: TherapySession) {
  downloadText(`coolcap-${s.id}.json`, JSON.stringify(s, null, 2), 'application/json')
}

export function exportSessionCsv(s: TherapySession) {
  const header = ['t', ...ZONES.map((z) => z.id), 'deltaT', 'power']
  const lines = [header.join(',')]
  for (const p of s.points) {
    lines.push(
      [p.t, ...ZONES.map((z) => p.zones[z.id] ?? ''), p.deltaT, p.power].join(',')
    )
  }
  downloadText(`coolcap-${s.id}.csv`, lines.join('\n'), 'text/csv')
}

function downloadText(filename: string, content: string, mime: string) {
  // #ifdef H5
  const blob = new Blob([content], { type: mime })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  a.click()
  URL.revokeObjectURL(url)
  return
  // #endif
  // #ifndef H5
  uni.setClipboardData({
    data: content,
    success: () => uni.showToast({ title: '已复制到剪贴板', icon: 'none' })
  })
  // #endif
}

export function newSessionId() {
  return uid('ses')
}

export function collectSession(input: {
  id: string
  startedAt: number
  protocol: Protocol
  env: TherapySession['env']
  alarms: AlarmItem[]
  points: SessionPoint[]
  endReason: string
}): TherapySession {
  const endedAt = Date.now()
  const durationMin = Math.max(1, Math.round((endedAt - input.startedAt) / 60000))
  return {
    id: input.id,
    startedAt: input.startedAt,
    endedAt,
    durationMin,
    protocolId: input.protocol.id,
    protocolName: input.protocol.name,
    protocolSnapshot: input.protocol,
    env: input.env,
    alarms: input.alarms,
    points: input.points,
    endReason: input.endReason,
    stats: summarizePoints(input.points)
  }
}
