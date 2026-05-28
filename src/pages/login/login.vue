<template>
  <view class="login-container">
    <!-- 顶部装饰区域 -->
    <view class="header">
      <view class="logo-wrapper">
        <text class="logo-icon">🛡️</text>
      </view>
      <text class="app-title">管理系统</text>
      <text class="app-subtitle">企业级后台管理平台</text>
    </view>

    <!-- 登录表单 -->
    <view class="form-wrapper">
      <view class="form-card">
        <text class="form-title">账号登录</text>

        <!-- 用户名输入 -->
        <view class="input-group">
          <view class="input-wrapper" :class="{ focused: usernameFocused }">
            <text class="input-icon">👤</text>
            <input
              class="input-field"
              type="text"
              v-model="loginForm.username"
              placeholder="请输入用户名"
              placeholder-class="placeholder-text"
              @focus="usernameFocused = true"
              @blur="usernameFocused = false"
            />
            <view
              class="clear-btn"
              v-if="loginForm.username"
              @tap="loginForm.username = ''"
            >
              <text class="clear-icon">✕</text>
            </view>
          </view>
        </view>

        <!-- 密码输入 -->
        <view class="input-group">
          <view class="input-wrapper" :class="{ focused: passwordFocused }">
            <text class="input-icon">🔒</text>
            <input
              class="input-field"
              :type="showPassword ? 'text' : 'password'"
              v-model="loginForm.password"
              placeholder="请输入密码"
              placeholder-class="placeholder-text"
              @focus="passwordFocused = true"
              @blur="passwordFocused = false"
            />
            <view class="eye-btn" @tap="showPassword = !showPassword">
              <text class="eye-icon">{{ showPassword ? '👁️' : '👁️‍🗨️' }}</text>
            </view>
          </view>
        </view>

        <!-- 记住密码 & 忘记密码 -->
        <view class="options-row">
          <view class="remember-wrapper" @tap="rememberPassword = !rememberPassword">
            <view class="checkbox" :class="{ checked: rememberPassword }">
              <text v-if="rememberPassword" class="check-icon">✓</text>
            </view>
            <text class="remember-text">记住密码</text>
          </view>
          <text class="forgot-link" @tap="handleForgotPassword">忘记密码？</text>
        </view>

        <!-- 登录按钮 -->
        <button
          class="login-btn"
          :class="{ disabled: !canLogin }"
          :loading="loginLoading"
          @tap="handleLogin"
        >
          <text class="login-btn-text">{{ loginLoading ? '登录中...' : '登 录' }}</text>
        </button>

        <!-- 其他登录方式 -->
        <view class="divider">
          <view class="divider-line"></view>
          <text class="divider-text">其他登录方式</text>
          <view class="divider-line"></view>
        </view>

        <view class="social-login">
          <view class="social-btn" @tap="handleSocialLogin('wechat')">
            <text class="social-icon">💬</text>
          </view>
          <view class="social-btn" @tap="handleSocialLogin('phone')">
            <text class="social-icon">📱</text>
          </view>
          <view class="social-btn" @tap="handleSocialLogin('dingtalk')">
            <text class="social-icon">🔗</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 底部协议 -->
    <view class="footer">
      <view class="agreement-wrapper" @tap="agreeTerms = !agreeTerms">
        <view class="checkbox small" :class="{ checked: agreeTerms }">
          <text v-if="agreeTerms" class="check-icon">✓</text>
        </view>
        <text class="agreement-text">
          登录即同意
          <text class="agreement-link" @tap.stop="openAgreement('user')">《用户协议》</text>
          和
          <text class="agreement-link" @tap.stop="openAgreement('privacy')">《隐私政策》</text>
        </text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'

// ============ 响应式数据 ============
const loginForm = reactive({
  username: '',
  password: ''
})

const showPassword = ref(false)
const rememberPassword = ref(false)
const agreeTerms = ref(false)
const loginLoading = ref(false)
const usernameFocused = ref(false)
const passwordFocused = ref(false)

// ============ 计算属性 ============
const canLogin = computed(() => {
  return loginForm.username.trim() !== '' && loginForm.password.trim() !== '' && !loginLoading.value
})

// ============ 方法 ============
function handleLogin() {
  if (!canLogin.value) return

  if (!agreeTerms.value) {
    uni.showToast({ title: '请先同意用户协议', icon: 'none' })
    return
  }

  loginLoading.value = true

  // 模拟登录（后续对接真实接口）
  setTimeout(() => {
    loginLoading.value = false
    if (loginForm.username === 'admin' && loginForm.password === 'admin') {
      uni.showToast({ title: '登录成功', icon: 'success' })
      // 存储登录状态
      uni.setStorageSync('token', 'mock-token-xxx')
      uni.setStorageSync('userInfo', JSON.stringify({
        username: loginForm.username,
        nickname: '管理员'
      }))
      // 跳转首页
      setTimeout(() => {
        uni.switchTab({ url: '/pages/home/home' })
      }, 500)
    } else {
      uni.showToast({ title: '用户名或密码错误', icon: 'none' })
    }
  }, 1500)
}

function handleForgotPassword() {
  uni.showToast({ title: '请联系管理员重置密码', icon: 'none' })
}

function handleSocialLogin(type: string) {
  uni.showToast({ title: `${type} 登录开发中`, icon: 'none' })
}

function openAgreement(type: string) {
  const titles: Record<string, string> = {
    user: '用户协议',
    privacy: '隐私政策'
  }
  uni.showToast({ title: titles[type] + '页面开发中', icon: 'none' })
}
</script>

<style lang="scss" scoped>
.login-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #ff6b35 0%, #f7931e 50%, #ffab40 100%);
  display: flex;
  flex-direction: column;
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    top: -50%;
    right: -30%;
    width: 600rpx;
    height: 600rpx;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.08);
  }

  &::after {
    content: '';
    position: absolute;
    bottom: -20%;
    left: -20%;
    width: 400rpx;
    height: 400rpx;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.05);
  }
}

// ========== 顶部区域 ==========
.header {
  padding-top: 140rpx;
  padding-bottom: 60rpx;
  text-align: center;
  position: relative;
  z-index: 1;
}

.logo-wrapper {
  width: 140rpx;
  height: 140rpx;
  border-radius: 36rpx;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(20px);
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 30rpx;
  box-shadow: 0 16rpx 40rpx rgba(0, 0, 0, 0.15);
}

.logo-icon {
  font-size: 64rpx;
}

.app-title {
  display: block;
  font-size: 44rpx;
  font-weight: 700;
  color: #fff;
  margin-bottom: 12rpx;
  letter-spacing: 4rpx;
}

.app-subtitle {
  display: block;
  font-size: 26rpx;
  color: rgba(255, 255, 255, 0.8);
}

// ========== 表单区域 ==========
.form-wrapper {
  flex: 1;
  padding: 0 40rpx;
  position: relative;
  z-index: 1;
}

.form-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(30px);
  border-radius: 28rpx;
  padding: 50rpx 40rpx;
  box-shadow: 0 20rpx 60rpx rgba(0, 0, 0, 0.1);
}

.form-title {
  display: block;
  font-size: 38rpx;
  font-weight: 700;
  color: #1a1a2e;
  text-align: center;
  margin-bottom: 50rpx;
}

// ========== 输入框 ==========
.input-group {
  margin-bottom: 30rpx;
}

.input-wrapper {
  display: flex;
  align-items: center;
  height: 100rpx;
  background: #f5f7fa;
  border-radius: 16rpx;
  padding: 0 28rpx;
  border: 2rpx solid transparent;
  transition: all 0.3s ease;

  &.focused {
    border-color: #ff6b35;
    background: #fff8f5;
    box-shadow: 0 0 0 4rpx rgba(255, 107, 53, 0.1);
  }
}

.input-icon {
  font-size: 36rpx;
  margin-right: 20rpx;
  opacity: 0.6;
}

.input-field {
  flex: 1;
  height: 100%;
  font-size: 30rpx;
  color: #333;
}

.placeholder-text {
  color: #bbb;
  font-size: 28rpx;
}

.clear-btn,
.eye-btn {
  width: 50rpx;
  height: 50rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.clear-icon {
  font-size: 28rpx;
  color: #ccc;
}

.eye-icon {
  font-size: 32rpx;
}

// ========== 选项行 ==========
.options-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 40rpx;
  padding: 0 8rpx;
}

.remember-wrapper {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.checkbox {
  width: 36rpx;
  height: 36rpx;
  border: 2rpx solid #ddd;
  border-radius: 8rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;

  &.checked {
    background: linear-gradient(135deg, #ff6b35, #f7931e);
    border-color: #ff6b35;
  }

  &.small {
    width: 30rpx;
    height: 30rpx;
    border-radius: 6rpx;
  }
}

.check-icon {
  font-size: 22rpx;
  color: #fff;
  font-weight: 700;
}

.remember-text {
  font-size: 26rpx;
  color: #666;
}

.forgot-link {
  font-size: 26rpx;
  color: #ff6b35;
}

// ========== 登录按钮 ==========
.login-btn {
  width: 100%;
  height: 96rpx;
  border-radius: 48rpx;
  background: linear-gradient(135deg, #ff6b35, #f7931e);
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  box-shadow: 0 12rpx 30rpx rgba(255, 107, 53, 0.4);
  transition: all 0.3s ease;
  margin-bottom: 40rpx;

  &::after {
    border: none;
  }

  &:active {
    transform: scale(0.98);
    box-shadow: 0 6rpx 15rpx rgba(255, 107, 53, 0.3);
  }

  &.disabled {
    opacity: 0.5;
    box-shadow: none;
  }
}

.login-btn-text {
  font-size: 32rpx;
  font-weight: 600;
  color: #fff;
  letter-spacing: 6rpx;
}

// ========== 分隔线 ==========
.divider {
  display: flex;
  align-items: center;
  margin-bottom: 30rpx;
}

.divider-line {
  flex: 1;
  height: 1rpx;
  background: #e8e8e8;
}

.divider-text {
  font-size: 24rpx;
  color: #bbb;
  padding: 0 20rpx;
}

// ========== 社交登录 ==========
.social-login {
  display: flex;
  justify-content: center;
  gap: 60rpx;
}

.social-btn {
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  background: #f5f7fa;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;

  &:active {
    transform: scale(0.9);
    background: #eee;
  }
}

.social-icon {
  font-size: 40rpx;
}

// ========== 底部协议 ==========
.footer {
  padding: 30rpx 40rpx 60rpx;
  position: relative;
  z-index: 1;
}

.agreement-wrapper {
  display: flex;
  align-items: flex-start;
  justify-content: center;
  gap: 10rpx;
}

.agreement-text {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.8);
  line-height: 1.6;
}

.agreement-link {
  color: #fff;
  font-weight: 600;
}
</style>