import { SAFETY, type AlarmItem, type AlarmLevel, type ZoneId, type ZoneTelemetry } from '../types'
import { uid } from '../types'

export interface SafetyCheckContext {
  zones: ZoneTelemetry[]
  dewPoint: number
  margin: number
}

export function evaluateSafety(ctx: SafetyCheckContext): AlarmItem[] {
  const alarms: AlarmItem[] = []
  const now = Date.now()

  for (const z of ctx.zones) {
    if (z.fault) {
      alarms.push(make(now, 'critical', 'SENSOR_FAULT', `${z.name}传感器故障：${z.fault}`, z.id))
    }
    if (z.scalpTemp < SAFETY.scalpHardStop) {
      alarms.push(make(now, 'critical', 'FROST_HARD', `${z.name}头皮温度过低（${z.scalpTemp.toFixed(1)}°C），已紧急停机`, z.id))
    } else if (z.scalpTemp < SAFETY.scalpLowerLimit) {
      alarms.push(make(now, 'critical', 'FROST_RISK', `${z.name}接近冻伤下限（${z.scalpTemp.toFixed(1)}°C）`, z.id))
    }
    if (z.hotSideTemp > SAFETY.hotSideStop) {
      alarms.push(make(now, 'critical', 'HOT_STOP', `${z.name}热端过温停机（${z.hotSideTemp.toFixed(1)}°C）`, z.id))
    } else if (z.hotSideTemp > SAFETY.hotSideWarn) {
      alarms.push(make(now, 'warning', 'HOT_WARN', `${z.name}热端偏高（${z.hotSideTemp.toFixed(1)}°C）`, z.id))
    }
    if (z.current > SAFETY.currentMax) {
      alarms.push(make(now, 'critical', 'OVERCURRENT', `${z.name}TEC过流（${z.current.toFixed(2)}A）`, z.id))
    }
    if (!z.contact && z.state !== 'idle') {
      alarms.push(make(now, 'warning', 'CONTACT_LOST', `${z.name}疑似脱离头皮，请检查佩戴`, z.id))
    }
  }

  const minSet = Math.min(...ctx.zones.map((z) => z.setpoint))
  if (minSet < ctx.dewPoint + ctx.margin) {
    alarms.push(make(now, 'info', 'DEWPOINT_CLAMP', '露点安全余量不足，已自动上调目标温度', undefined))
  }

  return alarms
}

function make(ts: number, level: AlarmLevel, code: string, message: string, zoneId?: ZoneId): AlarmItem {
  return { id: uid('alm'), ts, level, code, message, zoneId }
}
