<template>
  <view class="user-container">
    <!-- 顶部导航栏 -->
    <view class="nav-bar">
      <view class="nav-back" @tap="goBack">
        <text class="nav-back-icon">‹</text>
      </view>
      <text class="nav-title">用户管理</text>
      <view class="nav-add" @tap="showAddModal">
        <text class="nav-add-icon">+</text>
      </view>
    </view>

    <!-- 搜索栏 -->
    <view class="search-bar">
      <view class="search-input-wrapper">
        <text class="search-icon">🔍</text>
        <input
          class="search-input"
          v-model="searchKeyword"
          placeholder="搜索用户名/昵称/手机号"
          placeholder-class="search-placeholder"
          @confirm="handleSearch"
        />
        <view v-if="searchKeyword" class="search-clear" @tap="clearSearch">
          <text class="search-clear-icon">✕</text>
        </view>
      </view>
    </view>

    <!-- 筛选栏 -->
    <view class="filter-bar">
      <scroll-view scroll-x class="filter-scroll">
        <view class="filter-tags">
          <view class="filter-tag" :class="{ active: filterRole === '' }" @tap="setRoleFilter('')">
            <text class="filter-tag-text">全部</text>
          </view>
          <view class="filter-tag" :class="{ active: filterRole === 'admin' }" @tap="setRoleFilter('admin')">
            <text class="filter-tag-text">管理员</text>
          </view>
          <view class="filter-tag" :class="{ active: filterRole === 'user' }" @tap="setRoleFilter('user')">
            <text class="filter-tag-text">普通用户</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- 用户列表 -->
    <scroll-view class="user-list-wrapper" scroll-y @scrolltolower="loadMore">
      <view v-if="loading && userList.length === 0" class="loading-wrapper">
        <text class="loading-text">加载中...</text>
      </view>

      <view v-else-if="userList.length === 0" class="empty-wrapper">
        <text class="empty-icon">📭</text>
        <text class="empty-text">暂无用户数据</text>
      </view>

      <view v-else class="user-list">
        <view v-for="item in userList" :key="item.id" class="user-card">
          <view class="user-card-main">
            <view class="user-card-left">
              <view class="user-avatar">
                <text class="user-avatar-text">{{ (item.nickname || item.username).charAt(0) }}</text>
              </view>
              <view class="user-info">
                <view class="user-name-row">
                  <text class="user-name">{{ item.nickname || item.username }}</text>
                  <view class="user-role-badge" :class="'role-' + item.role">
                    <text class="user-role-text">{{ item.role === 'admin' ? '管理员' : '用户' }}</text>
                  </view>
                </view>
                <text class="user-username">@{{ item.username }}</text>
                <view class="user-meta">
                  <text v-if="item.phone" class="user-phone">📱 {{ item.phone }}</text>
                  <text class="user-time">{{ formatTime(item.created_at) }}</text>
                </view>
              </view>
            </view>
            <view class="user-card-right">
              <view class="user-status-badge" :class="item.status === 1 ? 'status-on' : 'status-off'">
                <text class="user-status-text">{{ item.status === 1 ? '启用' : '禁用' }}</text>
              </view>
            </view>
          </view>
          <view class="user-card-actions">
            <view class="action-btn edit-btn" @tap="showEditModal(item)">
              <text class="action-icon">✏️</text>
              <text class="action-text">编辑</text>
            </view>
            <view class="action-btn toggle-btn" @tap="handleToggleStatus(item)">
              <text class="action-icon">{{ item.status === 1 ? '🔴' : '🟢' }}</text>
              <text class="action-text">{{ item.status === 1 ? '禁用' : '启用' }}</text>
            </view>
            <view class="action-btn delete-btn" @tap="handleDelete(item)">
              <text class="action-icon">🗑️</text>
              <text class="action-text">删除</text>
            </view>
          </view>
        </view>
      </view>

      <view v-if="userList.length > 0" class="load-more">
        <text class="load-more-text">{{ hasMore ? '上拉加载更多' : '没有更多了' }}</text>
      </view>
    </scroll-view>

    <!-- 新增/编辑弹窗 -->
    <view v-if="modalVisible" class="modal-overlay" @tap="closeModal">
      <view class="modal-content" @tap.stop>
        <view class="modal-header">
          <text class="modal-title">{{ isEdit ? '编辑用户' : '新增用户' }}</text>
          <view class="modal-close" @tap="closeModal">
            <text class="modal-close-icon">✕</text>
          </view>
        </view>

        <scroll-view class="modal-body" scroll-y>
          <view class="form-item">
            <text class="form-label">用户名 <text class="required">*</text></text>
            <input class="form-input" v-model="formData.username" placeholder="请输入用户名" placeholder-class="form-placeholder" :disabled="isEdit" />
          </view>

          <view class="form-item">
            <text class="form-label">{{ isEdit ? '新密码（留空不修改）' : '密码' }} <text v-if="!isEdit" class="required">*</text></text>
            <input class="form-input" v-model="formData.password" type="text" :placeholder="isEdit ? '留空则不修改密码' : '请输入密码'" placeholder-class="form-placeholder" />
          </view>

          <view class="form-item">
            <text class="form-label">昵称</text>
            <input class="form-input" v-model="formData.nickname" placeholder="请输入昵称" placeholder-class="form-placeholder" />
          </view>

          <view class="form-item">
            <text class="form-label">手机号</text>
            <input class="form-input" v-model="formData.phone" placeholder="请输入手机号" placeholder-class="form-placeholder" type="number" />
          </view>

          <view class="form-item">
            <text class="form-label">角色</text>
            <view class="status-picker">
              <view class="status-option" :class="{ active: formData.role === 'user' }" @tap="formData.role = 'user'">
                <text class="status-option-text">普通用户</text>
              </view>
              <view class="status-option" :class="{ active: formData.role === 'admin' }" @tap="formData.role = 'admin'">
                <text class="status-option-text">管理员</text>
              </view>
            </view>
          </view>
        </scroll-view>

        <view class="modal-footer">
          <button class="modal-btn cancel-btn" @tap="closeModal">取消</button>
          <button class="modal-btn confirm-btn" @tap="handleSubmit">确定</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import {
  getUserList,
  addUser,
  updateUser,
  deleteUser,
  toggleUserStatus,
  type UserItem,
  type UserListParams
} from '@/api/user'

const loading = ref(false)
const userList = ref<UserItem[]>([])
const searchKeyword = ref('')
const filterRole = ref('')
const page = ref(1)
const pageSize = 20
const total = ref(0)
const hasMore = ref(true)

const modalVisible = ref(false)
const isEdit = ref(false)
const editingId = ref(0)

const formData = reactive({
  username: '',
  password: '',
  nickname: '',
  phone: '',
  role: 'user' as 'user' | 'admin'
})

onMounted(() => {
  loadUserData()
})

async function loadUserData(append = false) {
  if (loading.value) return
  loading.value = true
  try {
    const params: UserListParams = {
      page: append ? page.value : 1,
      page_size: pageSize
    }
    if (searchKeyword.value.trim()) params.keyword = searchKeyword.value.trim()
    if (filterRole.value) params.role = filterRole.value
    const res = await getUserList(params)
    if (res.code === 200 && res.data) {
      const data = res.data
      total.value = data.total
      if (append) {
        userList.value = [...userList.value, ...data.list]
      } else {
        userList.value = data.list
      }
      hasMore.value = userList.value.length < data.total
    }
  } catch (e) {
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

function loadMore() {
  if (!hasMore.value || loading.value) return
  page.value++
  loadUserData(true)
}

function goBack() {
  uni.navigateBack()
}

function handleSearch() {
  page.value = 1
  loadUserData()
}

function clearSearch() {
  searchKeyword.value = ''
  page.value = 1
  loadUserData()
}

function setRoleFilter(role: string) {
  filterRole.value = role
  page.value = 1
  loadUserData()
}

function formatTime(time?: string) {
  if (!time) return ''
  return time.replace('T', ' ').substring(0, 16)
}

function resetForm() {
  formData.username = ''
  formData.password = ''
  formData.nickname = ''
  formData.phone = ''
  formData.role = 'user'
}

function showAddModal() {
  resetForm()
  isEdit.value = false
  editingId.value = 0
  modalVisible.value = true
}

function showEditModal(item: UserItem) {
  isEdit.value = true
  editingId.value = item.id
  formData.username = item.username
  formData.password = ''
  formData.nickname = item.nickname
  formData.phone = item.phone
  formData.role = item.role as 'user' | 'admin'
  modalVisible.value = true
}

function closeModal() {
  modalVisible.value = false
}

async function handleSubmit() {
  if (!formData.username.trim()) {
    uni.showToast({ title: '请输入用户名', icon: 'none' })
    return
  }
  if (!isEdit.value && !formData.password.trim()) {
    uni.showToast({ title: '请输入密码', icon: 'none' })
    return
  }
  try {
    if (isEdit.value) {
      const data: any = {
        nickname: formData.nickname,
        phone: formData.phone,
        role: formData.role
      }
      if (formData.password.trim()) {
        data.password = formData.password
      }
      const res = await updateUser(editingId.value, data)
      if (res.code === 200) {
        uni.showToast({ title: '编辑成功', icon: 'success' })
        closeModal()
        page.value = 1
        loadUserData()
      } else {
        uni.showToast({ title: res.message || '编辑失败', icon: 'none' })
      }
    } else {
      const res = await addUser({
        username: formData.username,
        password: formData.password,
        nickname: formData.nickname,
        phone: formData.phone,
        role: formData.role
      })
      if (res.code === 200) {
        uni.showToast({ title: '创建成功', icon: 'success' })
        closeModal()
        page.value = 1
        loadUserData()
      } else {
        uni.showToast({ title: res.message || '创建失败', icon: 'none' })
      }
    }
  } catch (e) {
    uni.showToast({ title: '操作失败', icon: 'none' })
  }
}

async function handleToggleStatus(item: UserItem) {
  uni.showModal({
    title: '确认操作',
    content: `确定要${item.status === 1 ? '禁用' : '启用'}用户 ${item.nickname || item.username} 吗？`,
    success: async (res) => {
      if (res.confirm) {
        try {
          const result = await toggleUserStatus(item.id)
          if (result.code === 200) {
            uni.showToast({ title: '操作成功', icon: 'success' })
            page.value = 1
            loadUserData()
          } else {
            uni.showToast({ title: result.message || '操作失败', icon: 'none' })
          }
        } catch (e) {
          uni.showToast({ title: '操作失败', icon: 'none' })
        }
      }
    }
  })
}

async function handleDelete(item: UserItem) {
  uni.showModal({
    title: '确认删除',
    content: `确定要删除用户 ${item.nickname || item.username} 吗？此操作不可恢复！`,
    confirmColor: '#ff4d4f',
    success: async (res) => {
      if (res.confirm) {
        try {
          const result = await deleteUser(item.id)
          if (result.code === 200) {
            uni.showToast({ title: '删除成功', icon: 'success' })
            page.value = 1
            loadUserData()
          } else {
            uni.showToast({ title: result.message || '删除失败', icon: 'none' })
          }
        } catch (e) {
          uni.showToast({ title: '删除失败', icon: 'none' })
        }
      }
    }
  })
}
</script>

<style lang="scss" scoped>
.user-container {
  min-height: 100vh;
  background: #f5f6fa;
  display: flex;
  flex-direction: column;
}
.nav-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16rpx;
  height: 88rpx;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding-top: var(--status-bar-height, 0);
}
.nav-back, .nav-add {
  width: 60rpx; height: 60rpx;
  display: flex; align-items: center; justify-content: center;
}
.nav-back-icon { font-size: 40rpx; color: #fff; font-weight: bold; }
.nav-title { font-size: 34rpx; color: #fff; font-weight: 600; }
.nav-add-icon { font-size: 44rpx; color: #fff; font-weight: bold; }

.search-bar { padding: 16rpx 24rpx; background: #fff; }
.search-input-wrapper {
  display: flex; align-items: center; background: #f5f6fa;
  border-radius: 16rpx; padding: 0 20rpx; height: 72rpx;
}
.search-icon { font-size: 28rpx; margin-right: 12rpx; }
.search-input { flex: 1; font-size: 28rpx; height: 72rpx; }
.search-placeholder { color: #999; font-size: 28rpx; }
.search-clear { width: 40rpx; height: 40rpx; display: flex; align-items: center; justify-content: center; }
.search-clear-icon { font-size: 24rpx; color: #999; }

.filter-bar { background: #fff; padding: 0 24rpx 16rpx; border-bottom: 1rpx solid #eee; }
.filter-scroll { white-space: nowrap; }
.filter-tags { display: flex; gap: 16rpx; }
.filter-tag {
  display: inline-flex; align-items: center; padding: 8rpx 24rpx;
  border-radius: 24rpx; background: #f5f6fa; border: 1rpx solid #eee;
}
.filter-tag.active { background: rgba(102,126,234,0.1); border-color: #667eea; }
.filter-tag-text { font-size: 24rpx; color: #666; }
.filter-tag.active .filter-tag-text { color: #667eea; font-weight: 600; }

.user-list-wrapper { flex: 1; }
.loading-wrapper, .empty-wrapper {
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  padding: 120rpx 0;
}
.loading-text { font-size: 28rpx; color: #999; }
.empty-icon { font-size: 80rpx; margin-bottom: 20rpx; }
.empty-text { font-size: 28rpx; color: #999; }

.user-list { padding: 20rpx 24rpx; }
.user-card {
  background: #fff; border-radius: 20rpx; margin-bottom: 20rpx;
  box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.05); overflow: hidden;
}
.user-card-main {
  display: flex; align-items: flex-start; justify-content: space-between;
  padding: 24rpx 24rpx 16rpx;
}
.user-card-left { display: flex; flex: 1; }
.user-avatar {
  width: 80rpx; height: 80rpx; border-radius: 50%;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex; align-items: center; justify-content: center;
  margin-right: 20rpx; flex-shrink: 0;
}
.user-avatar-text { font-size: 32rpx; color: #fff; font-weight: 600; }
.user-info { flex: 1; }
.user-name-row { display: flex; align-items: center; margin-bottom: 6rpx; }
.user-name { font-size: 30rpx; font-weight: 600; color: #333; margin-right: 12rpx; }
.user-role-badge {
  padding: 2rpx 12rpx; border-radius: 8rpx;
}
.role-admin { background: rgba(255,107,107,0.1); }
.role-user { background: rgba(102,126,234,0.1); }
.user-role-text { font-size: 20rpx; }
.role-admin .user-role-text { color: #ff6b6b; }
.role-user .user-role-text { color: #667eea; }
.user-username { font-size: 24rpx; color: #999; margin-bottom: 6rpx; }
.user-meta { display: flex; align-items: center; gap: 16rpx; }
.user-phone { font-size: 22rpx; color: #666; }
.user-time { font-size: 22rpx; color: #bbb; }
.user-card-right { margin-left: 12rpx; }
.user-status-badge { padding: 4rpx 16rpx; border-radius: 12rpx; }
.status-on { background: rgba(82,196,26,0.1); }
.status-off { background: rgba(255,77,79,0.1); }
.user-status-text { font-size: 22rpx; }
.status-on .user-status-text { color: #52c41a; }
.status-off .user-status-text { color: #ff4d4f; }

.user-card-actions {
  display: flex; border-top: 1rpx solid #f0f0f0;
}
.action-btn {
  flex: 1; display: flex; align-items: center; justify-content: center;
  padding: 16rpx 0; gap: 6rpx;
}
.action-btn + .action-btn { border-left: 1rpx solid #f0f0f0; }
.action-icon { font-size: 24rpx; }
.action-text { font-size: 24rpx; color: #666; }
.edit-btn:active { background: #f9f9f9; }
.toggle-btn:active { background: #f9f9f9; }
.delete-btn:active { background: #fff1f0; }
.delete-btn .action-text { color: #ff4d4f; }

.load-more { padding: 30rpx 0; text-align: center; }
.load-more-text { font-size: 24rpx; color: #999; }

/* 弹窗样式 */
.modal-overlay {
  position: fixed; top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.5); z-index: 1000;
  display: flex; align-items: center; justify-content: center;
}
.modal-content {
  width: 640rpx; max-height: 80vh; background: #fff; border-radius: 20rpx;
  display: flex; flex-direction: column; overflow: hidden;
}
.modal-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 24rpx 30rpx; border-bottom: 1rpx solid #eee;
}
.modal-title { font-size: 32rpx; font-weight: 600; color: #333; }
.modal-close {
  width: 48rpx; height: 48rpx; display: flex;
  align-items: center; justify-content: center;
}
.modal-close-icon { font-size: 32rpx; color: #999; }
.modal-body { flex: 1; padding: 24rpx 30rpx; max-height: 60vh; }
.form-item { margin-bottom: 24rpx; }
.form-label { font-size: 26rpx; color: #333; font-weight: 500; margin-bottom: 12rpx; }
.required { color: #ff4d4f; }
.form-input {
  width: 100%; height: 72rpx; padding: 0 20rpx;
  background: #f5f6fa; border-radius: 12rpx; font-size: 28rpx;
  border: 1rpx solid #eee; box-sizing: border-box;
}
.form-placeholder { color: #ccc; }
.status-picker { display: flex; gap: 20rpx; }
.status-option {
  flex: 1; height: 72rpx; display: flex; align-items: center;
  justify-content: center; border-radius: 12rpx;
  background: #f5f6fa; border: 2rpx solid #eee;
}
.status-option.active {
  background: rgba(102,126,234,0.1); border-color: #667eea;
}
.status-option-text { font-size: 26rpx; color: #666; }
.status-option.active .status-option-text { color: #667eea; font-weight: 600; }
.modal-footer {
  display: flex; padding: 16rpx 30rpx 24rpx; gap: 20rpx;
  border-top: 1rpx solid #eee;
}
.modal-btn {
  flex: 1; height: 76rpx; border-radius: 12rpx;
  font-size: 28rpx; display: flex; align-items: center;
  justify-content: center; border: none;
}
.cancel-btn { background: #f5f6fa; color: #666; }
.confirm-btn { background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; }
</style>