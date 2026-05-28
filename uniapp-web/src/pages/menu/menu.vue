<template>
  <view class="menu-container">
    <!-- 顶部导航栏 -->
    <view class="nav-bar">
      <view class="nav-back" @tap="goBack">
        <text class="nav-back-icon">‹</text>
      </view>
      <text class="nav-title">菜单管理</text>
      <view class="nav-add" @tap="showAddModal()">
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
          placeholder="搜索菜单名称"
          placeholder-class="search-placeholder"
          @input="handleSearch"
        />
        <view v-if="searchKeyword" class="search-clear" @tap="searchKeyword = ''">
          <text class="search-clear-icon">✕</text>
        </view>
      </view>
    </view>

    <!-- 菜单列表 -->
    <scroll-view
      class="menu-list-wrapper"
      scroll-y
      :scroll-top="scrollTop"
      @scrolltolower="handleScrollToLower"
    >
      <view v-if="loading" class="loading-wrapper">
        <text class="loading-text">加载中...</text>
      </view>

      <view v-else-if="filteredMenuList.length === 0" class="empty-wrapper">
        <text class="empty-icon">📭</text>
        <text class="empty-text">暂无菜单数据</text>
      </view>

      <view v-else class="menu-list">
        <view
          v-for="item in filteredMenuList"
          :key="item.id"
          class="menu-card"
        >
          <view class="menu-card-main" @tap="toggleExpand(item.id)">
            <view class="menu-card-left">
              <text class="menu-card-icon">{{ item.icon }}</text>
              <view class="menu-card-info">
                <view class="menu-card-name-row">
                  <text class="menu-card-name">{{ item.name }}</text>
                </view>
                <text class="menu-card-path">{{ item.path }}</text>
              </view>
            </view>
            <view class="menu-card-right">
              <view class="menu-status-badge" :class="item.status === 1 ? 'status-on' : 'status-off'">
                <text class="menu-status-text">{{ item.status === 1 ? '启用' : '禁用' }}</text>
              </view>
              <text v-if="item.children && item.children.length" class="menu-expand-icon">
                {{ expandedIds.includes(item.id) ? '▼' : '▶' }}
              </text>
            </view>
          </view>

          <!-- 子菜单列表 -->
          <view v-if="item.children && item.children.length && expandedIds.includes(item.id)" class="sub-menu-list">
            <view
              v-for="child in item.children"
              :key="child.id"
              class="sub-menu-item"
              @tap="showEditModal(child)"
            >
              <view class="sub-menu-left">
                <text class="sub-menu-icon">{{ child.icon }}</text>
                <view class="sub-menu-info">
                  <text class="sub-menu-name">{{ child.name }}</text>
                  <text class="sub-menu-path">{{ child.path }}</text>
                </view>
              </view>
              <view class="sub-menu-right">
                <view class="menu-status-badge" :class="child.status === 1 ? 'status-on' : 'status-off'">
                  <text class="menu-status-text">{{ child.status === 1 ? '启用' : '禁用' }}</text>
                </view>
                <view class="sub-menu-actions">
                  <view class="action-btn edit-btn" @tap.stop="showEditModal(child)">
                    <text class="action-icon">✏️</text>
                  </view>
                  <view class="action-btn delete-btn" @tap.stop="handleDelete(child)">
                    <text class="action-icon">🗑️</text>
                  </view>
                </view>
              </view>
            </view>
          </view>

          <!-- 操作按钮 -->
          <view class="menu-card-actions">
            <view class="action-btn add-btn" @tap="showAddModal(item.id)">
              <text class="action-icon">➕</text>
              <text class="action-text">新增子菜单</text>
            </view>
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
    </scroll-view>

    <!-- 新增/编辑弹窗 -->
    <view v-if="modalVisible" class="modal-overlay" @tap="closeModal">
      <view class="modal-content" @tap.stop>
        <view class="modal-header">
          <text class="modal-title">{{ isEdit ? '编辑菜单' : '新增菜单' }}</text>
          <view class="modal-close" @tap="closeModal">
            <text class="modal-close-icon">✕</text>
          </view>
        </view>

        <scroll-view class="modal-body" scroll-y>
          <!-- 菜单名称 -->
          <view class="form-item">
            <text class="form-label">菜单名称 <text class="required">*</text></text>
            <input
              class="form-input"
              v-model="formData.name"
              placeholder="请输入菜单名称"
              placeholder-class="form-placeholder"
            />
          </view>

          <!-- 菜单图标 -->
          <view class="form-item">
            <text class="form-label">图标</text>
            <view class="icon-picker">
              <view
                v-for="icon in iconOptions"
                :key="icon"
                class="icon-option"
                :class="{ active: formData.icon === icon }"
                @tap="formData.icon = icon"
              >
                <text class="icon-option-text">{{ icon }}</text>
              </view>
            </view>
          </view>

          <!-- 路由路径 -->
          <view class="form-item">
            <text class="form-label">路由路径 <text class="required">*</text></text>
            <input
              class="form-input"
              v-model="formData.path"
              placeholder="如：/system/user"
              placeholder-class="form-placeholder"
            />
          </view>

          <!-- 排序 -->
          <view class="form-item">
            <text class="form-label">排序</text>
            <input
              class="form-input"
              type="number"
              v-model="formData.sort_order"
              placeholder="数字越小越靠前"
              placeholder-class="form-placeholder"
            />
          </view>

          <!-- 状态 -->
          <view class="form-item">
            <text class="form-label">状态</text>
            <view class="status-picker">
              <view
                class="status-option"
                :class="{ active: formData.status === 1 }"
                @tap="formData.status = 1"
              >
                <text class="status-option-text">启用</text>
              </view>
              <view
                class="status-option"
                :class="{ active: formData.status === 0 }"
                @tap="formData.status = 0"
              >
                <text class="status-option-text">禁用</text>
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
import { ref, reactive, computed, onMounted } from 'vue'
import {
  getMenuTree,
  addMenu,
  updateMenu,
  deleteMenu,
  type MenuItem
} from '@/api/menu'

// ============ 状态 ============
const loading = ref(false)
const menuList = ref<MenuItem[]>([])
const searchKeyword = ref('')
const expandedIds = ref<number[]>([])
const scrollTop = ref(0)
const modalVisible = ref(false)
const isEdit = ref(false)
const editingId = ref(0)

// 表单数据
const formData = reactive({
  name: '',
  icon: '📄',
  path: '',
  parent_id: 0,
  sort_order: 0,
  status: 1 as 0 | 1
})

// 常量
const iconOptions = [
  '📋', '👤', '🎭', '📊', '📈', '📑', '📝', '📄',
  '🏷️', '💰', '🛒', '💸', '🎯', '🎫', '⚙️', '🔔',
  '📂', '🏠', '📦', '🔒', '🌐', '💬', '📱', '⚡'
]

// ============ 计算属性 ============
const filteredMenuList = computed(() => {
  if (!searchKeyword.value.trim()) return menuList.value
  const keyword = searchKeyword.value.toLowerCase()
  return menuList.value.filter(item => {
    if (item.name.toLowerCase().includes(keyword)) return true
    if (item.children) {
      return item.children.some(child =>
        child.name.toLowerCase().includes(keyword)
      )
    }
    return false
  })
})

// ============ 生命周期 ============
onMounted(() => {
  loadMenuData()
})

// ============ 方法 ============
async function loadMenuData() {
  loading.value = true
  try {
    const res = await getMenuTree()
    menuList.value = res.data || []
  } catch (e) {
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

function goBack() {
  uni.navigateBack()
}

function handleSearch() {
  // 实时搜索，computed 已处理
}

function toggleExpand(id: number) {
  const index = expandedIds.value.indexOf(id)
  if (index > -1) {
    expandedIds.value.splice(index, 1)
  } else {
    expandedIds.value.push(id)
  }
}

function handleScrollToLower() {
  // 触底加载更多（当前为全量数据，暂不处理）
}

function resetForm() {
  formData.name = ''
  formData.icon = '📄'
  formData.path = ''
  formData.parent_id = 0
  formData.sort_order = 0
  formData.status = 1
}

function showAddModal(parentId?: number) {
  resetForm()
  isEdit.value = false
  editingId.value = 0
  formData.parent_id = parentId || 0
  modalVisible.value = true
}

function showEditModal(item: MenuItem) {
  resetForm()
  isEdit.value = true
  editingId.value = item.id
  formData.name = item.name
  formData.icon = item.icon
  formData.path = item.path
  formData.parent_id = item.parent_id
  formData.sort_order = item.sort_order
  formData.status = item.status
  modalVisible.value = true
}

function closeModal() {
  modalVisible.value = false
}

async function handleSubmit() {
  // 表单验证
  if (!formData.name.trim()) {
    uni.showToast({ title: '请输入菜单名称', icon: 'none' })
    return
  }
  if (!formData.path.trim()) {
    uni.showToast({ title: '请输入路由路径', icon: 'none' })
    return
  }

  try {
    if (isEdit.value) {
      await updateMenu(editingId.value, { name: formData.name, icon: formData.icon, path: formData.path, parent_id: formData.parent_id, sort_order: formData.sort_order, status: formData.status })
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      await addMenu({ name: formData.name, icon: formData.icon, path: formData.path, parent_id: formData.parent_id, sort_order: formData.sort_order, status: formData.status })
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
    closeModal()
    await loadMenuData()
  } catch (e) {
    uni.showToast({ title: '操作失败', icon: 'none' })
  }
}

function handleToggleStatus(item: MenuItem) {
  const newStatus = item.status === 1 ? 0 : 1
  const actionText = newStatus === 1 ? '启用' : '禁用'

  uni.showModal({
    title: '提示',
    content: `确定${actionText}菜单"${item.name}"吗？`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await updateMenu(item.id, { status: newStatus } as any)
          uni.showToast({ title: `${actionText}成功`, icon: 'success' })
          await loadMenuData()
        } catch (e) {
          uni.showToast({ title: '操作失败', icon: 'none' })
        }
      }
    }
  })
}

function handleDelete(item: MenuItem) {
  const hasChildren = item.children && item.children.length > 0
  const content = hasChildren
    ? `菜单"${item.name}"下有子菜单，删除后子菜单也将被删除，确定删除吗？`
    : `确定删除菜单"${item.name}"吗？`

  uni.showModal({
    title: '提示',
    content,
    confirmColor: '#ff4757',
    success: async (res) => {
      if (res.confirm) {
        try {
          await deleteMenu(item.id)
          uni.showToast({ title: '删除成功', icon: 'success' })
          await loadMenuData()
        } catch (e) {
          uni.showToast({ title: '删除失败', icon: 'none' })
        }
      }
    }
  })
}
</script>

<style lang="scss" scoped>
.menu-container {
  min-height: 100vh;
  background: #f5f6fa;
  display: flex;
  flex-direction: column;
}

// ========== 导航栏 ==========
.nav-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 88rpx;
  padding: 0 24rpx;
  background: linear-gradient(135deg, #ff6b35, #f7931e);
  padding-top: var(--status-bar-height, 0);
}

.nav-back {
  width: 60rpx;
  height: 60rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-back-icon {
  font-size: 48rpx;
  color: #fff;
  font-weight: 300;
}

.nav-title {
  font-size: 34rpx;
  font-weight: 600;
  color: #fff;
}

.nav-add {
  width: 60rpx;
  height: 60rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
}

.nav-add-icon {
  font-size: 40rpx;
  color: #fff;
  font-weight: 300;
}

// ========== 搜索栏 ==========
.search-bar {
  padding: 20rpx 30rpx;
  background: #fff;
}

.search-input-wrapper {
  display: flex;
  align-items: center;
  height: 72rpx;
  background: #f5f6fa;
  border-radius: 36rpx;
  padding: 0 24rpx;
}

.search-icon {
  font-size: 28rpx;
  margin-right: 12rpx;
}

.search-input {
  flex: 1;
  font-size: 28rpx;
  color: #333;
}

.search-placeholder {
  color: #bbb;
  font-size: 26rpx;
}

.search-clear {
  width: 40rpx;
  height: 40rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.search-clear-icon {
  font-size: 24rpx;
  color: #ccc;
}

// ========== 列表区域 ==========
.menu-list-wrapper {
  flex: 1;
  padding: 20rpx 30rpx;
  padding-bottom: 120rpx;
}

.loading-wrapper,
.empty-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 100rpx 0;
}

.loading-text {
  font-size: 28rpx;
  color: #999;
}

.empty-icon {
  font-size: 80rpx;
  margin-bottom: 20rpx;
}

.empty-text {
  font-size: 28rpx;
  color: #999;
}

// ========== 菜单卡片 ==========
.menu-card {
  background: #fff;
  border-radius: 20rpx;
  margin-bottom: 20rpx;
  overflow: hidden;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.menu-card-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx 24rpx;
}

.menu-card-left {
  display: flex;
  align-items: center;
  flex: 1;
  min-width: 0;
}

.menu-card-icon {
  font-size: 44rpx;
  margin-right: 20rpx;
  flex-shrink: 0;
}

.menu-card-info {
  flex: 1;
  min-width: 0;
}

.menu-card-name-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 6rpx;
}

.menu-card-name {
  font-size: 30rpx;
  font-weight: 600;
  color: #333;
}

.menu-type-tag {
  padding: 2rpx 12rpx;
  border-radius: 6rpx;
  flex-shrink: 0;

  &.type-1 {
    background: #e3f2fd;
  }
  &.type-2 {
    background: #e8f5e9;
  }
  &.type-3 {
    background: #fff3e0;
  }
}

.menu-type-text {
  font-size: 20rpx;
  color: #666;
}

.menu-card-path {
  font-size: 24rpx;
  color: #999;
}

.menu-card-right {
  display: flex;
  align-items: center;
  gap: 12rpx;
  flex-shrink: 0;
}

.menu-status-badge {
  padding: 4rpx 14rpx;
  border-radius: 20rpx;

  &.status-on {
    background: rgba(76, 175, 80, 0.1);
  }
  &.status-off {
    background: rgba(244, 67, 54, 0.1);
  }
}

.menu-status-text {
  font-size: 22rpx;
  color: #4caf50;

  .status-off & {
    color: #f44336;
  }
}

.menu-expand-icon {
  font-size: 20rpx;
  color: #ccc;
}

// ========== 子菜单 ==========
.sub-menu-list {
  border-top: 1rpx solid #f5f5f5;
  padding: 0 24rpx;
}

.sub-menu-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 0 20rpx 40rpx;
  border-bottom: 1rpx solid #fafafa;

  &:last-child {
    border-bottom: none;
  }

  &:active {
    background: #fafafa;
  }
}

.sub-menu-left {
  display: flex;
  align-items: center;
  flex: 1;
  min-width: 0;
}

.sub-menu-icon {
  font-size: 32rpx;
  margin-right: 16rpx;
  flex-shrink: 0;
}

.sub-menu-info {
  flex: 1;
  min-width: 0;
}

.sub-menu-name {
  font-size: 28rpx;
  color: #333;
  margin-bottom: 4rpx;
}

.sub-menu-path {
  font-size: 22rpx;
  color: #bbb;
}

.sub-menu-right {
  display: flex;
  align-items: center;
  gap: 12rpx;
  flex-shrink: 0;
}

.sub-menu-actions {
  display: flex;
  gap: 8rpx;
}

// ========== 操作按钮 ==========
.menu-card-actions {
  display: flex;
  border-top: 1rpx solid #f5f5f5;
  padding: 0;
}

.action-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6rpx;
  padding: 18rpx 0;
  position: relative;

  &::after {
    content: '';
    position: absolute;
    right: 0;
    top: 50%;
    transform: translateY(-50%);
    width: 1rpx;
    height: 30rpx;
    background: #f0f0f0;
  }

  &:last-child::after {
    display: none;
  }

  &:active {
    background: #fafafa;
  }
}

.action-icon {
  font-size: 24rpx;
}

.action-text {
  font-size: 24rpx;
  color: #666;
}

.delete-btn .action-text {
  color: #ff4757;
}

.edit-btn .action-text {
  color: #2196f3;
}

// ========== 弹窗 ==========
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: flex-end;
  z-index: 999;
}

.modal-content {
  width: 100%;
  max-height: 85vh;
  background: #fff;
  border-radius: 28rpx 28rpx 0 0;
  display: flex;
  flex-direction: column;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 30rpx;
  border-bottom: 1rpx solid #f0f0f0;
}

.modal-title {
  font-size: 34rpx;
  font-weight: 700;
  color: #333;
}

.modal-close {
  width: 50rpx;
  height: 50rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-close-icon {
  font-size: 32rpx;
  color: #999;
}

.modal-body {
  flex: 1;
  padding: 20rpx 30rpx;
  max-height: 60vh;
}

// ========== 表单 ==========
.form-item {
  margin-bottom: 28rpx;
}

.form-label {
  font-size: 28rpx;
  font-weight: 600;
  color: #333;
  margin-bottom: 14rpx;
  display: block;
}

.required {
  color: #ff4757;
}

.form-input {
  width: 100%;
  height: 80rpx;
  background: #f5f6fa;
  border-radius: 12rpx;
  padding: 0 24rpx;
  font-size: 28rpx;
  color: #333;
  border: 2rpx solid transparent;

  &:focus {
    border-color: #ff6b35;
    background: #fff8f5;
  }
}

.form-placeholder {
  color: #bbb;
  font-size: 26rpx;
}

// 图标选择器
.icon-picker {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
}

.icon-option {
  width: 72rpx;
  height: 72rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f6fa;
  border-radius: 12rpx;
  border: 2rpx solid transparent;

  &.active {
    border-color: #ff6b35;
    background: #fff3e0;
  }
}

.icon-option-text {
  font-size: 32rpx;
}

// 类型选择器
.type-picker {
  display: flex;
  gap: 16rpx;
}

.type-option {
  flex: 1;
  height: 72rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f6fa;
  border-radius: 12rpx;
  border: 2rpx solid transparent;

  &.active {
    border-color: #ff6b35;
    background: #fff3e0;
  }
}

.type-option-text {
  font-size: 28rpx;
  color: #666;

  .active & {
    color: #ff6b35;
    font-weight: 600;
  }
}

// 状态选择器
.status-picker {
  display: flex;
  gap: 16rpx;
}

.status-option {
  flex: 1;
  height: 72rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f6fa;
  border-radius: 12rpx;
  border: 2rpx solid transparent;

  &.active {
    border-color: #ff6b35;
    background: #fff3e0;
  }
}

.status-option-text {
  font-size: 28rpx;
  color: #666;

  .active & {
    color: #ff6b35;
    font-weight: 600;
  }
}

// ========== 弹窗底部 ==========
.modal-footer {
  display: flex;
  gap: 20rpx;
  padding: 20rpx 30rpx 60rpx;
  border-top: 1rpx solid #f0f0f0;
}

.modal-btn {
  flex: 1;
  height: 88rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 44rpx;
  font-size: 30rpx;
  font-weight: 600;
  border: none;

  &::after {
    border: none;
  }
}

.cancel-btn {
  background: #f5f6fa;
  color: #666;
}

.confirm-btn {
  background: linear-gradient(135deg, #ff6b35, #f7931e);
  color: #fff;
  box-shadow: 0 8rpx 20rpx rgba(255, 107, 53, 0.3);
}
</style>