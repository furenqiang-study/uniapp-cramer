export type ZoneId = 'F' | 'TL' | 'TR' | 'P' | 'OL' | 'OR'

export type ZoneState = 'idle' | 'ramp' | 'hold' | 'protect' | 'fault'

export type AlarmLevel = 'info' | 'warning' | 'critical'

export interface ZoneTelemetry {
  id: ZoneId
  name: string
  scalpTemp: number
  coldSideTemp: number
  hotSideTemp: number
  current: number
  power: number
  contact: boolean
  fault: string | null
  setpoint: number
  state: ZoneState
  compensated: boolean
}

export interface EnvironmentInfo {
  temp: number
  humidity: number
  dewPoint: number
  margin: number
  safe: boolean
}

export interface AlarmItem {
  id: string
  ts: number
  level: AlarmLevel
  code: string
  message: string
  zoneId?: ZoneId
}

export interface ProtocolStage {
  name: string
  durationMin: number
  targetTemp: number
  maxDuty: number
}

export interface Protocol {
  id: string
  name: string
  builtin: boolean
  stages: ProtocolStage[]
  note?: string
  updatedAt: number
}

export interface SessionPoint {
  t: number
  zones: Record<ZoneId, number>
  power: number
  deltaT: number
}

export interface TherapySession {
  id: string
  startedAt: number
  endedAt: number | null
  durationMin: number
  protocolId: string
  protocolName: string
  protocolSnapshot: Protocol
  env: EnvironmentInfo
  alarms: AlarmItem[]
  points: SessionPoint[]
  endReason: string
  stats: {
    minTemp: number
    maxTemp: number
    avgTemp: number
  }
}

export interface UserSession {
  username: string
  nickname: string
  token: string
}

export const ZONES: { id: ZoneId; name: string; defaultSetpoint: number }[] = [
  { id: 'F', name: '额区', defaultSetpoint: 18 },
  { id: 'TL', name: '左颞区', defaultSetpoint: 16 },
  { id: 'TR', name: '右颞区', defaultSetpoint: 16 },
  { id: 'P', name: '顶区', defaultSetpoint: 16 },
  { id: 'OL', name: '左枕区', defaultSetpoint: 16 },
  { id: 'OR', name: '右枕区', defaultSetpoint: 16 }
]

export const SAFETY = {
  scalpLowerLimit: 12,
  scalpHardStop: 10,
  hotSideWarn: 60,
  hotSideStop: 65,
  currentMax: 2.0,
  dewPointMargin: 2.0,
  deltaTarget: 1.5,
  uniformExcellent: 0.8,
  uniformGood: 1.5
}

export function zoneColor(temp: number): string {
  // colder -> more blue, warmer -> more amber
  if (temp <= 14) return '#0369A1'
  if (temp <= 16) return '#0284C7'
  if (temp <= 18) return '#0EA5E9'
  if (temp <= 20) return '#38BDF8'
  if (temp <= 22) return '#7DD3FC'
  if (temp <= 24) return '#BAE6FD'
  return '#FDE68A'
}

export function uid(prefix = 'id'): string {
  return `${prefix}_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`
}
