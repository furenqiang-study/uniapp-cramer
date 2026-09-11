<template>
  <view class="login-page">
    <view class="header">
      <view class="logo">❄</view>
      <text class="title">CoolCap</text>
      <text class="subtitle">化疗头皮冷却治疗系统</text>
    </view>

    <view class="card">
      <text class="form-title">账号登录</text>

      <view class="field">
        <input
          class="input"
          v-model="username"
          placeholder="请输入用户名"
          placeholder-class="ph"
        />
      </view>
      <view class="field">
        <input
          class="input"
          :type="showPwd ? 'text' : 'password'"
          v-model="password"
          placeholder="请输入密码"
          placeholder-class="ph"
        />
        <text class="eye" @tap="showPwd = !showPwd">{{ showPwd ? '👁' : '👁‍🗨' }}</text>
      </view>

      <view class="options">
        <view class="remember" @tap="remember = !remember">
          <view class="cb" :class="{ on: remember }">{{ remember ? '✓' : '' }}</view>
          <text>记住密码</text>
        </view>
        <text class="forgot" @tap="onForgot">忘记密码？</text>
      </view>

      <button class="btn" :disabled="loading" @tap="onLogin">
        {{ loading ? '登录中…' : '登 录' }}
      </button>
      <text class="hint">演示账号：admin / 任意密码（≥4位）</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { mockLogin, setRemember, isRemember } from '@/services/store/therapyStore'
import { setToken, setMockToken, clearToken } from '@/api/request'
import { login as apiLogin } from '@/api/auth'

const username = ref(uni.getStorageSync('cc_login_user') || '')
const password = ref(uni.getStorageSync('cc_login_pwd') || '')
const remember = ref(isRemember())
const showPwd = ref(false)
const loading = ref(false)

async function onLogin() {
  if (!username.value || !password.value) {
    uni.showToast({ title: '请输入账号密码', icon: 'none' })
    return
  }
  loading.value = true
  try {
    const uname = username.value.trim()
    let token = ''
    // 优先真实后端登录，失败则回退本地 mock（演示可离线）
    try {
      clearToken()
      const res = await apiLogin(uname, password.value)
      if (res?.code === 200 && res.data?.access_token) {
        token = res.data.access_token
        setToken(token)
        if (res.data.user?.nickname) {
          uni.setStorageSync('cc_user', {
            username: uname,
            nickname: res.data.user.nickname,
            token
          })
        }
      }
    } catch (_e) {
      token = ''
    }
    if (!token) {
      const user = await mockLogin(uname, password.value)
      token = user.token
      setMockToken(token)
      uni.setStorageSync('cc_user', user)
    }
    setRemember(remember.value)
    if (remember.value) {
      uni.setStorageSync('cc_login_user', uname)
      uni.setStorageSync('cc_login_pwd', password.value)
    } else {
      uni.removeStorageSync('cc_login_user')
      uni.removeStorageSync('cc_login_pwd')
    }
    uni.switchTab({ url: '/pages/home/home' })
  } catch (e: any) {
    uni.showToast({ title: e?.message || '登录失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

function onForgot() {
  uni.showToast({ title: '请联系管理员重置密码', icon: 'none' })
}
</script>

<style lang="scss" scoped>
.login-page {
  min-height: 100vh;
  background: linear-gradient(165deg, #0f172a 0%, #0c4a6e 48%, #e0f2fe 100%);
  padding: 120rpx 40rpx 80rpx;
  box-sizing: border-box;
}
.header {
  text-align: center;
  margin-bottom: 64rpx;
}
.logo {
  width: 120rpx;
  height: 120rpx;
  line-height: 120rpx;
  margin: 0 auto 20rpx;
  border-radius: 36rpx;
  background: rgba(255, 255, 255, 0.12);
  color: #e0f2fe;
  font-size: 56rpx;
}
.title {
  display: block;
  font-size: 48rpx;
  font-weight: 700;
  color: #fff;
}
.subtitle {
  display: block;
  margin-top: 8rpx;
  font-size: 24rpx;
  color: #bae6fd;
}
.card {
  background: #fff;
  border-radius: 32rpx;
  padding: 48rpx 36rpx;
  box-shadow: 0 12rpx 40rpx rgba(15, 23, 42, 0.12);
}
.form-title {
  display: block;
  font-size: 34rpx;
  font-weight: 600;
  color: #0f172a;
  margin-bottom: 36rpx;
}
.field {
  position: relative;
  margin-bottom: 24rpx;
}
.input {
  height: 96rpx;
  background: #f8fafc;
  border-radius: 20rpx;
  padding: 0 28rpx;
  font-size: 30rpx;
  color: #0f172a;
}
.ph {
  color: #94a3b8;
}
.eye {
  position: absolute;
  right: 24rpx;
  top: 28rpx;
  font-size: 28rpx;
}
.options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 8rpx 0 36rpx;
  font-size: 24rpx;
  color: #64748b;
}
.remember {
  display: flex;
  align-items: center;
  gap: 10rpx;
}
.cb {
  width: 32rpx;
  height: 32rpx;
  border-radius: 8rpx;
  border: 2rpx solid #cbd5e1;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20rpx;
  color: #fff;
  &.on {
    background: #0ea5e9;
    border-color: #0ea5e9;
  }
}
.forgot {
  color: #0ea5e9;
}
.btn {
  height: 96rpx;
  line-height: 96rpx;
  border-radius: 24rpx;
  background: linear-gradient(135deg, #0ea5e9, #0284c7);
  color: #fff;
  font-size: 32rpx;
  font-weight: 600;
  border: none;
  &[disabled] {
    opacity: 0.6;
  }
}
.hint {
  display: block;
  text-align: center;
  margin-top: 24rpx;
  font-size: 22rpx;
  color: #94a3b8;
}
</style>
