/**
 * 首页相关接口
 */
import { get } from './request'

/** 获取首页统计数据 */
export function getHomeStats() {
  return get('/api/home/stats')
}