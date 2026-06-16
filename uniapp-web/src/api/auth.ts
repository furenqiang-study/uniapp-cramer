/**
 * 认证相关接口
 */
import { post, get } from './request'

/** 用户登录 */
export function login(username: string, password: string) {
  return post('/api/auth/login', { username, password })
}

/** 用户注册 */
export function register(username: string, password: string, nickname?: string) {
  return post('/api/auth/register', { username, password, nickname })
}

/** 获取当前用户信息 */
export function getCurrentUser() {
  return get('/api/auth/current')
}

/** 用户登出 */
export function logout() {
  return post('/api/auth/logout')
}