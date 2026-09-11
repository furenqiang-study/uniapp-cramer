/**
 * HTTP 请求封装
 * 基于 uni.request 封装统一的请求方法
 */

const BASE_URL = '/uniapp-api'

interface RequestOptions {
  url: string
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  data?: any
  header?: Record<string, string>
  /** 401 时是否强制跳登录（默认：mock 会话不跳） */
  silentAuth?: boolean
}

interface ApiResponse<T = any> {
  code: number
  message: string
  data: T
}

function getToken(): string {
  return uni.getStorageSync('token') || uni.getStorageSync('cc_token') || ''
}

export function setToken(token: string) {
  uni.setStorageSync('token', token)
  uni.removeStorageSync('cc_mock_auth')
}

export function setMockToken(token: string) {
  uni.setStorageSync('token', token)
  uni.setStorageSync('cc_mock_auth', '1')
}

export function isMockAuth(): boolean {
  return uni.getStorageSync('cc_mock_auth') === '1'
}

export function clearToken() {
  uni.removeStorageSync('token')
  uni.removeStorageSync('cc_token')
  uni.removeStorageSync('cc_mock_auth')
}

function handleAuthFail(options: RequestOptions, data: any) {
  // mock 登录：后端 401 不踢人，本地业务继续可用
  if (isMockAuth() || options.silentAuth) {
    rejectQuiet(data)
    return
  }
  clearToken()
  uni.showToast({ title: '登录已过期，请重新登录', icon: 'none' })
  setTimeout(() => {
    uni.reLaunch({ url: '/pages/login/login' })
  }, 800)
}

function rejectQuiet(data: any): never {
  throw data
}

export function request<T = any>(options: RequestOptions): Promise<ApiResponse<T>> {
  return new Promise((resolve, reject) => {
    const token = getToken()
    const header: Record<string, string> = {
      'Content-Type': 'application/json',
      ...options.header,
    }
    if (token) {
      header['Authorization'] = `Bearer ${token}`
    }

    uni.request({
      url: `${BASE_URL}${options.url}`,
      method: options.method || 'GET',
      data: options.data,
      header,
      success: (res: any) => {
        const data = res.data as ApiResponse<T>
        if (res.statusCode === 200) {
          if (data.code === 200) {
            resolve(data)
            return
          }
          if (data.code === 401) {
            try {
              handleAuthFail(options, data)
            } catch (e) {
              reject(e)
            }
            return
          }
          // mock 会话下业务错误静默抛出，避免打断演示
          if (isMockAuth() || options.silentAuth) {
            reject(data)
            return
          }
          uni.showToast({ title: data.message || '请求失败', icon: 'none' })
          reject(data)
          return
        }
        if (res.statusCode === 401) {
          try {
            handleAuthFail(options, data)
          } catch (e) {
            reject(e)
          }
          return
        }
        if (isMockAuth() || options.silentAuth) {
          reject(data)
          return
        }
        uni.showToast({ title: '网络请求失败', icon: 'none' })
        reject(data)
      },
      fail: (err: any) => {
        // 后端未启动/联调时：mock 会话静默失败，不打扰主流程
        if (isMockAuth() || options.silentAuth) {
          reject(err)
          return
        }
        uni.showToast({ title: '网络连接失败', icon: 'none' })
        reject(err)
      },
    })
  })
}

export const get = <T = any>(url: string, data?: any, opts?: Partial<RequestOptions>) =>
  request<T>({ url, method: 'GET', data, ...opts })
export const post = <T = any>(url: string, data?: any, opts?: Partial<RequestOptions>) =>
  request<T>({ url, method: 'POST', data, ...opts })
export const put = <T = any>(url: string, data?: any, opts?: Partial<RequestOptions>) =>
  request<T>({ url, method: 'PUT', data, ...opts })
export const del = <T = any>(url: string, data?: any, opts?: Partial<RequestOptions>) =>
  request<T>({ url, method: 'DELETE', data, ...opts })
