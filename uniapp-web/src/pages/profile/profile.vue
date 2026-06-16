<template>
  <view class="profile-container">
    <!-- 顶部个人信息 -->
    <view class="profile-header">
      <view class="profile-bg"></view>
      <view class="profile-info">
        <view class="avatar-large">
          <text class="avatar-char">{{ userInfo.nickname.charAt(0) }}</text>
        </view>
        <text class="profile-name">{{ userInfo.nickname }}</text>
        <text class="profile-role">{{ userInfo.role }}</text>
        <view class="profile-stats">
          <view class="profile-stat-item">
            <text class="profile-stat-value">128</text>
            <text class="profile-stat-label">菜单数</text>
          </view>
          <view class="profile-stat-divider"></view>
          <view class="profile-stat-item">
            <text class="profile-stat-value">56</text>
            <text class="profile-stat-label">用户数</text>
          </view>
          <view class="profile-stat-divider"></view>
          <view class="profile-stat-item">
            <text class="profile-stat-value">99%</text>
            <text class="profile-stat-label">可用率</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 功能列表 -->
    <view class="menu-section">
      <view class="menu-group">
        <view class="menu-item" v-for="item in menuList1" :key="item.label" @tap="handleMenuTap(item)">
          <view class="menu-item-left">
            <text class="menu-icon">{{ item.icon }}</text>
            <text class="menu-label">{{ item.label }}</text>
          </view>
          <view class="menu-item-right">
            <text class="menu-arrow">›</text>
          </view>
        </view>
      </view>

      <view class="menu-group">
        <view class="menu-item" v-for="item in menuList2" :key="item.label" @tap="handleMenuTap(item)">
          <view class="menu-item-left">
            <text class="menu-icon">{{ item.icon }}</text>
            <text class="menu-label">{{ item.label }}</text>
          </view>
          <view class="menu-item-right">
            <text v-if="item.extra" class="menu-extra">{{ item.extra }}</text>
            <text class="menu-arrow">›</text>
          </view>
        </view>
      </view>

      <view class="menu-group">
        <view class="menu-item" @tap="handleMenuTap({ action: 'about' })">
          <view class="menu-item-left">
            <text class="menu-icon">ℹ️</text>
            <text class="menu-label">关于我们</text>
          </view>
          <view class="menu-item-right">
            <text class="menu-extra">v1.0.0</text>
            <text class="menu-arrow">›</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 退出登录 -->
    <view class="logout-section">
      <button class="logout-btn" @tap="handleLogout">退出登录</button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { reactive, onMounted } from 'vue'

const userInfo = reactive({
  nickname: '管理员',
  role: '超级管理员',
  username: 'admin'
})

const menuList1 = [
  { icon: '👤', label: '个人信息', action: 'profile' },
  { icon: '🔐', label: '修改密码', action: 'password' },
  { icon: '🌍', label: '漫游地球', action: 'roam-earth' }
]

const menuList2 = [
  { icon: '🎨', label: '主题设置', action: 'theme' },
  { icon: '🌐', label: '语言设置', action: 'language', extra: '简体中文' },
  { icon: '🗑️', label: '清除缓存', action: 'cache', extra: '12.5MB' },
  { icon: '💬', label: '意见反馈', action: 'feedback' }
]

onMounted(() => {
  const storedInfo = uni.getStorageSync('userInfo')
  if (storedInfo) {
    try {
      const info = JSON.parse(storedInfo)
      userInfo.nickname = info.nickname || '管理员'
      userInfo.username = info.username || 'admin'
    } catch (e) {}
  }
})

function handleMenuTap(item: any) {
  if (item.action === 'cache') {
    uni.showModal({
      title: '提示',
      content: '确定清除缓存吗？',
      success: (res) => {
        if (res.confirm) {
          uni.showToast({ title: '缓存已清除', icon: 'success' })
        }
      }
    })
  } else if (item.action === 'roam-earth') {
    uni.navigateTo({ url: '/pages/earth/roam-earth' })
  } else {
    uni.showToast({ title: `${item.label} 功能开发中`, icon: 'none' })
  }
}

function handleLogout() {
  uni.showModal({
    title: '提示',
    content: '确定退出登录吗？',
    success: (res) => {
      if (res.confirm) {
        uni.removeStorageSync('token')
        uni.removeStorageSync('userInfo')
        uni.reLaunch({ url: '/pages/login/login' })
      }
    }
  })
}
</script>

<style lang="scss" scoped>
.profile-container {
  min-height: 100vh;
  background: #f5f6fa;
}

// ========== 顶部个人信息 ==========
.profile-header {
  position: relative;
  padding-bottom: 40rpx;
}

.profile-bg {
  height: 300rpx;
  background: linear-gradient(135deg, #ff6b35, #f7931e);
  border-radius: 0 0 50rpx 50rpx;
}

.profile-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: -120rpx;
  position: relative;
  z-index: 1;
}

.avatar-large {
  width: 160rpx;
  height: 160rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, #ff8a50, #ff6b35);
  display: flex;
  align-items: center;
  justify-content: center;
  border: 6rpx solid #fff;
  box-shadow: 0 8rpx 30rpx rgba(255, 107, 53, 0.3);
  margin-bottom: 20rpx;
}

.avatar-char {
  font-size: 64rpx;
  font-weight: 700;
  color: #fff;
}

.profile-name {
  font-size: 36rpx;
  font-weight: 700;
  color: #333;
  margin-bottom: 8rpx;
}

.profile-role {
  font-size: 24rpx;
  color: #999;
  margin-bottom: 30rpx;
}

.profile-stats {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 20rpx;
  padding: 24rpx 40rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05);
  width: 80%;
}

.profile-stat-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.profile-stat-value {
  font-size: 36rpx;
  font-weight: 700;
  color: #ff6b35;
  margin-bottom: 4rpx;
}

.profile-stat-label {
  font-size: 22rpx;
  color: #999;
}

.profile-stat-divider {
  width: 1rpx;
  height: 50rpx;
  background: #eee;
}

// ========== 功能列表 ==========
.menu-section {
  padding: 20rpx 30rpx;
}

.menu-group {
  background: #fff;
  border-radius: 20rpx;
  margin-bottom: 20rpx;
  overflow: hidden;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.03);
}

.menu-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 30rpx;
  border-bottom: 1rpx solid #f5f5f5;

  &:last-child {
    border-bottom: none;
  }

  &:active {
    background: #fafafa;
  }
}

.menu-item-left {
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.menu-icon {
  font-size: 36rpx;
}

.menu-label {
  font-size: 30rpx;
  color: #333;
}

.menu-item-right {
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.menu-extra {
  font-size: 24rpx;
  color: #bbb;
}

.menu-arrow {
  font-size: 32rpx;
  color: #ccc;
}

// ========== 退出登录 ==========
.logout-section {
  padding: 20rpx 30rpx 80rpx;
}

.logout-btn {
  width: 100%;
  height: 96rpx;
  line-height: 96rpx;
  text-align: center;
  background: #fff;
  color: #ff4757;
  font-size: 32rpx;
  font-weight: 600;
  border-radius: 20rpx;
  border: none;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.03);

  &::after {
    border: none;
  }

  &:active {
    background: #fff5f5;
  }
}
</style>