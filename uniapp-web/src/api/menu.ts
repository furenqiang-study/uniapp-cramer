/**
 * 菜单管理接口
 */
import { get, post, put, del } from './request'

export interface MenuItem {
  id: number
  name: string
  icon: string
  path: string
  parent_id: number
  sort_order: number
  status: number
  created_at?: string
  updated_at?: string
  children?: MenuItem[]
}

/** 获取菜单列表（树形结构） */
export function getMenuTree() {
  return get<MenuItem[]>('/api/menus?tree=true')
}

/** 获取菜单平铺列表 */
export function getMenuList() {
  return get<MenuItem[]>('/api/menus?tree=false')
}

/** 获取单个菜单详情 */
export function getMenuDetail(id: number) {
  return get<MenuItem>(`/api/menus/${id}`)
}

/** 新增菜单 */
export function addMenu(data: Partial<MenuItem>) {
  return post<MenuItem>('/api/menus', data)
}

/** 修改菜单 */
export function updateMenu(id: number, data: Partial<MenuItem>) {
  return put<MenuItem>(`/api/menus/${id}`, data)
}

/** 删除菜单 */
export function deleteMenu(id: number) {
  return del(`/api/menus/${id}`)
}