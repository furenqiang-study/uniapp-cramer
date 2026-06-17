import request from './request'

/** 获取新闻列表 */
export function getNewsList(category: string = 'hottest') {
  return request({
    url: `/api/news/list?category=${category}`,
    method: 'GET'
  })
}

/** 获取新闻分类 */
export function getNewsCategories() {
  return request({
    url: `/api/news/categories`,
    method: 'GET'
  })
}