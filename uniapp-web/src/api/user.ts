/**
 * 用户管理接口
 */
import { get, post, put, del } from './request'

export interface UserItem {
  id: number
  username: string
  nickname: string
  avatar: string
  phone: string
  role: string
  status: number
  created_at?: string
}

export interface UserListParams {
  keyword?: string
  role?: string
  status?: number
  page?: number
  page_size?: number
}

export interface UserListResult {
  total: number
  page: number
  page_size: number
  list: UserItem[]
}

export interface UserCreateData {
  username: string
  password: string
  nickname?: string
  phone?: string
  role?: string
}

export interface UserUpdateData {
  nickname?: string
  avatar?: string
  phone?: string
  role?: string
  password?: string
}

/** 获取用户列表 */
export function getUserList(params: UserListParams) {
  const query = new URLSearchParams()
  if (params.keyword) query.append('keyword', params.keyword)
  if (params.role) query.append('role', params.role)
  if (params.status !== undefined && params.status >= 0) query.append('status', String(params.status))
  if (params.page) query.append('page', String(params.page))
  if (params.page_size) query.append('page_size', String(params.page_size))
  return get<UserListResult>(`/api/users?${query.toString()}`)
}

/** 获取用户详情 */
export function getUserDetail(id: number) {
  return get<UserItem>(`/api/users/${id}`)
}

/** 新增用户 */
export function addUser(data: UserCreateData) {
  return post<UserItem>('/api/users', data)
}

/** 编辑用户 */
export function updateUser(id: number, data: UserUpdateData) {
  return put<UserItem>(`/api/users/${id}`, data)
}

/** 删除用户 */
export function deleteUser(id: number) {
  return del(`/api/users/${id}`)
}

/** 切换用户状态 */
export function toggleUserStatus(id: number) {
  return put(`/api/users/${id}/status`)
}