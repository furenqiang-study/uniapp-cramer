<template>
  <view class="home-container">
    <!-- 顶部欢迎栏 -->
    <view class="welcome-bar">
      <view class="welcome-left">
        <text class="welcome-text">欢迎回来，{{ userInfo.nickname }}</text>
        <text class="welcome-date">{{ currentDate }}</text>
      </view>
      <view class="avatar-wrapper" @tap="goToProfile">
        <text class="avatar-text">{{ userInfo.nickname.charAt(0) }}</text>
      </view>
    </view>

    <!-- 数据概览卡片 -->
    <view class="stats-section">
      <view class="stats-grid">
        <view class="stat-card" v-for="item in statsData" :key="item.label">
          <view class="stat-icon-wrapper" :style="{ background: item.bgColor }">
            <text class="stat-icon">{{ item.icon }}</text>
          </view>
          <text class="stat-value">{{ item.value }}</text>
          <text class="stat-label">{{ item.label }}</text>
        </view>
      </view>
    </view>

    <!-- 快捷操作 -->
    <view class="quick-section">
      <view class="section-header">
        <text class="section-title">快捷操作</text>
      </view>
      <view class="quick-grid">
        <view
          class="quick-item"
          v-for="item in quickActions"
          :key="item.label"
          @tap="handleQuickAction(item)"
        >
          <view class="quick-icon-wrapper" :style="{ background: item.bgColor }">
            <text class="quick-icon">{{ item.icon }}</text>
          </view>
          <text class="quick-label">{{ item.label }}</text>
        </view>
      </view>
    </view>

    <!-- 最近动态 -->
    <view class="recent-section">
      <view class="section-header">
        <text class="section-title">最近动态</text>
        <text class="section-more" @tap="handleViewMore">查看全部 ›</text>
      </view>
      <view class="recent-list">
        <view class="recent-item" v-for="(item, index) in recentList" :key="index">
          <view class="recent-dot" :style="{ background: item.color }"></view>
          <view class="recent-content">
            <text class="recent-title">{{ item.title }}</text>
            <text class="recent-time">{{ item.time }}</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { getHomeStats } from '@/api/home'

// ============ 响应式数据 ============
const userInfo = reactive({
  nickname: '管理员'
})

const currentDate = ref('')

const statsData = ref([
  { icon: '📦', label: '菜单总数', value: '128', bgColor: 'rgba(255, 107, 53, 0.1)' },
  { icon: '👥', label: '用户数量', value: '56', bgColor: 'rgba(76, 175, 80, 0.1)' },
  { icon: '📊', label: '今日访问', value: '1,024', bgColor: 'rgba(33, 150, 243, 0.1)' },
  { icon: '⚡', label: '系统消息', value: '3', bgColor: 'rgba(255, 193, 7, 0.1)' }
])

const quickActions = ref([
  { icon: '📋', label: '菜单管理', bgColor: '#fff3e0', action: 'menu' },
  { icon: '👤', label: '用户管理', bgColor: '#e8f5e9', action: 'user' },
  { icon: '💻', label: '电脑推荐', bgColor: '#e3f2fd', action: 'laptop' },
  { icon: '📰', label: '新闻现在', bgColor: '#fce4ec', action: 'news-now' },
  { icon: '🌍', label: '漫游地球', bgColor: '#e8eaf6', action: 'roam-earth' },
  { icon: '🎮', label: '娱乐中心', bgColor: '#e0f2f1', action: 'entertainment' },
  { icon: '📷', label: '相机拍照', bgColor: '#fff8e1', action: 'camera' },
  { icon: '❓', label: '帮助中心', bgColor: '#e8eaf6', action: 'help' }
])

const recentList = ref([
  { title: '新增了菜单"数据报表"', time: '10 分钟前', color: '#ff6b35' },
  { title: '用户 张三 修改了个人信息', time: '30 分钟前', color: '#4caf50' },
  { title: '系统完成了一次数据备份', time: '1 小时前', color: '#2196f3' },
  { title: '新增了菜单"权限管理"', time: '2 小时前', color: '#ff6b35' },
  { title: '用户 李四 登录了系统', time: '3 小时前', color: '#9c27b0' }
])

// ============ 生命周期 ============
onMounted(() => {
  const now = new Date()
  const weekDays = ['日', '一', '二', '三', '四', '五', '六']
  currentDate.value = `${now.getFullYear()}年${now.getMonth() + 1}月${now.getDate()}日 星期${weekDays[now.getDay()]}`
  
  // 读取用户信息
  const storedInfo = uni.getStorageSync('userInfo')
  if (storedInfo) {
    try {
      const info = JSON.parse(storedInfo)
      userInfo.nickname = info.nickname || '管理员'
    } catch (e) {}
  }

  // 加载统计数据
  loadStats()
})

async function loadStats() {
  try {
    const res = await getHomeStats()
    if (res.data) {
      statsData.value[0].value = String(res.data.menuCount || 0)
      statsData.value[1].value = String(res.data.userCount || 0)
      statsData.value[2].value = String(res.data.todayLogCount || 0)
      statsData.value[3].value = String(res.data.logCount || 0)
      if (res.data.recentLogins) {
        recentList.value = res.data.recentLogins.map((log: any) => ({
          title: log.detail || log.username + ' 登录了系统',
          time: log.created_at || '',
          color: '#ff6b35'
        }))
      }
    }
  } catch (e) {}
}

// ============ 方法 ============
function goToProfile() {
  uni.switchTab({ url: '/pages/profile/profile' })
}

function handleQuickAction(item: any) {
  if (item.action === 'menu') {
    uni.navigateTo({ url: '/pages/menu/menu' })
  } else if (item.action === 'camera') {
    uni.navigateTo({ url: '/pages/camera/camera' })
  } else if (item.action === 'laptop') {
    uni.navigateTo({ url: '/pages/laptop/laptop' })
  } else if (item.action === 'entertainment') {
    uni.navigateTo({ url: '/pages/entertainment/index' })
  } else if (item.action === 'roam-earth') {
    uni.navigateTo({ url: '/pages/earth/roam-earth' })
  } else if (item.action === 'news-now') {
    uni.navigateTo({ url: '/pages/news/news-now' })
  } else {
    uni.showToast({ title: `${item.label} 功能开发中`, icon: 'none' })
  }
}

function handleViewMore() {
  uni.showToast({ title: '功能开发中', icon: 'none' })
}
</script>

<style lang="scss" scoped>
.home-container {
  min-height: 100vh;
  background: #f5f6fa;
  padding-bottom: 40rpx;
}

// ========== 欢迎栏 ==========
.welcome-bar {
  background: linear-gradient(135deg, #ff6b35, #f7931e);
  padding: 60rpx 40rpx 80rpx;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-radius: 0 0 40rpx 40rpx;
}

.welcome-left {
  display: flex;
  flex-direction: column;
}

.welcome-text {
  font-size: 36rpx;
  font-weight: 700;
  color: #fff;
  margin-bottom: 10rpx;
}

.welcome-date {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.8);
}

.avatar-wrapper {
  width: 90rpx;
  height: 90rpx;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.25);
  display: flex;
  align-items: center;
  justify-content: center;
  border: 3rpx solid rgba(255, 255, 255, 0.5);
}

.avatar-text {
  font-size: 36rpx;
  font-weight: 700;
  color: #fff;
}

// ========== 数据概览 ==========
.stats-section {
  padding: 0 30rpx;
  margin-top: -40rpx;
  position: relative;
  z-index: 1;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16rpx;
  background: #fff;
  border-radius: 24rpx;
  padding: 30rpx 20rpx;
  box-shadow: 0 8rpx 30rpx rgba(0, 0, 0, 0.06);
}

.stat-card {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-icon-wrapper {
  width: 80rpx;
  height: 80rpx;
  border-radius: 20rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 12rpx;
}

.stat-icon {
  font-size: 36rpx;
}

.stat-value {
  font-size: 34rpx;
  font-weight: 700;
  color: #333;
  margin-bottom: 4rpx;
}

.stat-label {
  font-size: 22rpx;
  color: #999;
}

// ========== 快捷操作 ==========
.quick-section {
  padding: 30rpx 30rpx 0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #333;
}

.section-more {
  font-size: 24rpx;
  color: #999;
}

.quick-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24rpx 0;
  background: #fff;
  border-radius: 24rpx;
  padding: 30rpx 20rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.04);
}

.quick-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;

  &:active {
    opacity: 0.7;
  }
}

.quick-icon-wrapper {
  width: 90rpx;
  height: 90rpx;
  border-radius: 24rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.quick-icon {
  font-size: 40rpx;
}

.quick-label {
  font-size: 24rpx;
  color: #666;
}

// ========== 最近动态 ==========
.recent-section {
  padding: 30rpx 30rpx 0;
}

.recent-list {
  background: #fff;
  border-radius: 24rpx;
  padding: 10rpx 30rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.04);
}

.recent-item {
  display: flex;
  align-items: center;
  padding: 24rpx 0;
  border-bottom: 1rpx solid #f5f5f5;

  &:last-child {
    border-bottom: none;
  }
}

.recent-dot {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  margin-right: 20rpx;
  flex-shrink: 0;
}

.recent-content {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.recent-title {
  font-size: 28rpx;
  color: #333;
  flex: 1;
}

.recent-time {
  font-size: 24rpx;
  color: #bbb;
  flex-shrink: 0;
  margin-left: 20rpx;
}
</style>