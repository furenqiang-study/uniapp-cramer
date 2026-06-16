/**
 * 笔记本电脑智能推荐 API
 */
import { get, post } from './request'

// 获取推荐问卷选项（预算、场景、偏好）
export function getLaptopOptions() {
  return get('/api/laptops/options')
}

// 提交推荐请求
export function recommendLaptop(data: {
  budget: string
  scenes: string[]
  preferences: string[]
  extra_demand?: string
}) {
  return post('/api/laptops/recommend', data)
}

// 获取推荐历史
export function getLaptopHistory() {
  return get('/api/laptops/history')
}