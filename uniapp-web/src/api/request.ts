/**
 * HTTP 请求封装
 * 基于 uni.request 封装统一的请求方法
 */

const BASE_URL = 'http://localhost:8000'

interface RequestOptions {
  url: string
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  data?: any
  header?: Record<string, string>
}

interface ApiResponse<T = any> {
  code: number
  message: string
  data: T
}

// 获取存储的token
function getToken(): string {
  return uni.getStorageSync('token') || ''
}

// 设置token
export function setToken(token: string) {
  uni.setStorageSync('token', token)
}

// 清除token
export function clearToken() {
  uni.removeStorageSync('token')
}

// 统一请求方法
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
          } else if (data.code === 401) {
            // Token过期，跳转登录
            clearToken()
            uni.showToast({ title: '请重新登录', icon: 'none' })
            setTimeout(() => {
              uni.navigateTo({ url: '/pages/login/login' })
            }, 1500)
            reject(data)
          } else {
            uni.showToast({ title: data.message || '请求失败', icon: 'none' })
            reject(data)
          }
        } else if (res.statusCode === 401) {
          clearToken()
          uni.showToast({ title: '请重新登录', icon: 'none' })
          setTimeout(() => {
            uni.navigateTo({ url: '/pages/login/login' })
          }, 1500)
          reject(data)
        } else {
          uni.showToast({ title: '网络请求失败', icon: 'none' })
          reject(data)
        }
      },
      fail: (err: any) => {
        uni.showToast({ title: '网络连接失败', icon: 'none' })
        reject(err)
      },
    })
  })
}

// 便捷方法
export const get = <T = any>(url: string, data?: any) => request<T>({ url, method: 'GET', data })
export const post = <T = any>(url: string, data?: any) => request<T>({ url, method: 'POST', data })
export const put = <T = any>(url: string, data?: any) => request<T>({ url, method: 'PUT', data })
export const del = <T = any>(url: string, data?: any) => request<T>({ url, method: 'DELETE', data })