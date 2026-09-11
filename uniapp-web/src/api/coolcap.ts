/** CoolCap 冰帽业务接口（YL_ 后端） */
import { get, post, put, del } from './request'

export function listPatients() {
  return get('/api/coolcap/patients')
}

export function createPatient(data: any) {
  return post('/api/coolcap/patients', data)
}

export function listDevices() {
  return get('/api/coolcap/devices')
}

export function bindDevice(data: any) {
  return post('/api/coolcap/devices', data)
}

export function listProtocols() {
  return get('/api/coolcap/protocols')
}

export function createProtocol(data: any) {
  return post('/api/coolcap/protocols', data)
}

export function updateProtocol(id: number, data: any) {
  return put(`/api/coolcap/protocols/${id}`, data)
}

export function deleteProtocol(id: number) {
  return del(`/api/coolcap/protocols/${id}`)
}

export function listSessions(params: { page?: number; page_size?: number; keyword?: string } = {}) {
  return get('/api/coolcap/sessions', params as any)
}

export function startSession(data: any) {
  return post('/api/coolcap/sessions/start', data)
}

export function getSession(id: number) {
  return get(`/api/coolcap/sessions/${id}`)
}

export function finishSession(id: number, data: any) {
  return post(`/api/coolcap/sessions/${id}/finish`, data)
}

export function exportSession(id: number) {
  return get(`/api/coolcap/sessions/${id}/export`)
}

export function reproduceSession(id: number) {
  return post(`/api/coolcap/sessions/${id}/reproduce`, {})
}

export function listAlarms(params: any = {}) {
  return get('/api/coolcap/alarms', params)
}

export function createAlarm(data: any) {
  return post('/api/coolcap/alarms', data)
}

export function ackAlarm(id: number) {
  return post(`/api/coolcap/alarms/${id}/ack`, {})
}

export function getSafety() {
  return get('/api/coolcap/safety')
}

export function pushEnvSample(data: any) {
  return post('/api/coolcap/env/samples', data)
}

export function getLatestEnv() {
  return get('/api/coolcap/env/latest')
}

export function pushCommand(data: any) {
  return post('/api/coolcap/commands', data)
}
