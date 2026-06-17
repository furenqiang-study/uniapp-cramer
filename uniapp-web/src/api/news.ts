import { get } from './request'

/** 获取新闻列表（聚合多个平台热点） */
export function getNewsList(params?: { category?: string; sources?: string }) {
  const category = params?.category || 'hottest'
  const sources = params?.sources || ''
  let url = `/api/news/list?category=${category}`
  if (sources) url += `&sources=${sources}`
  return get(url)
}

/** 获取指定新闻源的热点 */
export function getNewsBySource(sourceKey: string) {
  return get(`/api/news/source/${sourceKey}`)
}

/** 获取所有可用的新闻源 */
export function getNewsSources() {
  return get('/api/news/sources')
}

/** 获取新闻分类 */
export function getNewsCategories() {
  return get('/api/news/categories')
}