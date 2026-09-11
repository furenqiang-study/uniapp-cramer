<template>
  <view class="page">
    <view class="hero card">
      <view class="avatar">{{ user?.nickname?.slice(0, 1) || 'U' }}</view>
      <view>
        <text class="name">{{ user?.nickname || '未登录' }}</text>
        <text class="role">CoolCap 用户</text>
      </view>
    </view>

    <view class="card">
      <text class="sec-t">模拟环境</text>
      <view class="row">
        <text class="k">环境温度 {{ env.temp }}°C</text>
        <slider :value="env.temp" :min="18" :max="32" :step="1" activeColor="#0EA5E9" @change="(e:any)=>onTemp(e.detail.value)" />
      </view>
      <view class="row">
        <text class="k">湿度 {{ env.humidity }}%</text>
        <slider :value="env.humidity" :min="20" :max="95" :step="1" activeColor="#0EA5E9" @change="(e:any)=>onHum(e.detail.value)" />
      </view>
    </view>

    <view class="card">
      <text class="sec-t">安全包络（只读默认）</text>
      <view class="kv" v-for="(v, k) in safety" :key="k">
        <text class="k">{{ safetyLabel[k] }}</text>
        <text class="v">{{ v }}{{ unitOf(k) }}</text>
      </view>
    </view>

    <view class="card">
      <text class="sec-t">数据同步</text>
      <text class="tip">后端表前缀 YL_，接口 /api/coolcap/*。未启动服务时使用本地模拟。</text>
      <button class="btn ghost" @tap="goAlarm">报警中心</button>
    </view>

    <button class="btn danger" @tap="onLogout">退出登录</button>
  </view>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getUser, logout, getEnvSettings, setEnvSettings } from '@/services/store/therapyStore'
import { useTherapy } from '@/services/store/useTherapy'
import { getSafety } from '@/api/coolcap'
import { clearToken } from '@/api/request'

const user = ref(getUser())
const env = reactive(getEnvSettings())
const { setEnv } = useTherapy()

const safety = ref<Record<string, number>>({
  scalp_lower_limit: 12,
  scalp_hard_stop: 10,
  hot_side_warn: 60,
  hot_side_stop: 65,
  current_max: 2,
  dew_point_margin: 2,
  delta_target: 1.5
})

const safetyLabel: Record<string, string> = {
  scalp_lower_limit: '头皮温度下限',
  scalp_hard_stop: '紧急停机温度',
  hot_side_warn: '热端过温警告',
  hot_side_stop: '热端过温停机',
  current_max: 'TEC 最大电流',
  dew_point_margin: '露点安全余量',
  delta_target: '全头温差目标'
}

function unitOf(k: string) {
  if (k === 'current_max') return 'A'
  if (k === 'dew_point_margin' || k === 'delta_target' || k.startsWith('scalp') || k.startsWith('hot')) return '°C'
  return ''
}

function onTemp(v: number) {
  env.temp = v
  setEnv(env.temp, env.humidity)
  setEnvSettings(env.temp, env.humidity)
}

function onHum(v: number) {
  env.humidity = v
  setEnv(env.temp, env.humidity)
  setEnvSettings(env.temp, env.humidity)
}

function goAlarm() {
  uni.navigateTo({ url: '/pages/alarm/alarm' })
}

function onLogout() {
  logout()
  clearToken()
  uni.reLaunch({ url: '/pages/login/login' })
}

onShow(async () => {
  user.value = getUser()
  try {
    const res = await getSafety()
    if (res.code === 200 && res.data) safety.value = res.data
  } catch (e) {}
})
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  padding: 24rpx 28rpx 48rpx;
  background: #f4f7fb;
}
.card {
  background: #fff;
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 8rpx rgba(15, 23, 42, 0.04);
}
.hero {
  display: flex;
  align-items: center;
  gap: 20rpx;
}
.avatar {
  width: 96rpx;
  height: 96rpx;
  line-height: 96rpx;
  text-align: center;
  border-radius: 28rpx;
  background: linear-gradient(135deg, #0ea5e9, #0284c7);
  color: #fff;
  font-size: 40rpx;
  font-weight: 700;
}
.name { display: block; font-size: 32rpx; font-weight: 700; color: #0f172a; }
.role { font-size: 22rpx; color: #64748b; }
.sec-t { display: block; font-size: 28rpx; font-weight: 600; color: #0f172a; margin-bottom: 16rpx; }
.row { margin-bottom: 8rpx; }
.k { font-size: 24rpx; color: #64748b; }
.v { font-size: 24rpx; color: #0f172a; font-variant-numeric: tabular-nums; }
.kv {
  display: flex;
  justify-content: space-between;
  padding: 12rpx 0;
  border-bottom: 1rpx solid #f1f5f9;
}
.tip {
  display: block;
  font-size: 22rpx;
  color: #64748b;
  margin-bottom: 16rpx;
  line-height: 1.5;
}
.btn {
  width: 100%;
  height: 80rpx;
  line-height: 80rpx;
  border-radius: 20rpx;
  font-size: 28rpx;
  border: none;
  margin-top: 8rpx;
  &.ghost { background: #f1f5f9; color: #0f172a; }
  &.danger { background: #fee2e2; color: #b91c1c; }
}
</style>
