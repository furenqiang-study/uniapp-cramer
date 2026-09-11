<template>
  <view class="page">
    <PageBack />
    <view class="head">
      <text class="h1">报警中心</text>
      <text class="clear" @tap="clear">清空本地</text>
    </view>

    <view v-if="alarms.length === 0" class="empty card">
      <text class="empty-t">暂无报警</text>
      <text class="empty-s">治疗中的异常将实时汇总到这里</text>
    </view>

    <view v-for="a in alarms" :key="a.id" class="item card" :class="a.level">
      <view class="row">
        <text class="lv" :class="a.level">{{ levelLabel(a.level) }}</text>
        <text class="time">{{ fmt(a.ts) }}</text>
      </view>
      <text class="msg">{{ a.message }}</text>
      <text class="code">{{ a.code }}</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import PageBack from '@/components/PageBack.vue'
import { useTherapy } from '@/services/store/useTherapy'
import type { AlarmLevel } from '@/services/types'

const { alarms, clearAlarms } = useTherapy()

function levelLabel(l: AlarmLevel) {
  return { info: '提示', warning: '警告', critical: '严重' }[l]
}

function fmt(ts: number) {
  const d = new Date(ts)
  const p = (n: number) => String(n).padStart(2, '0')
  return `${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`
}

function clear() {
  clearAlarms()
  uni.showToast({ title: '已清空', icon: 'none' })
}
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  padding: 88rpx 28rpx 48rpx;
  background: #f4f7fb;
}
.head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}
.h1 { font-size: 40rpx; font-weight: 700; color: #0f172a; }
.clear { font-size: 24rpx; color: #0ea5e9; }
.card {
  background: #fff;
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: 0 2rpx 8rpx rgba(15, 23, 42, 0.04);
  &.critical { border-left: 8rpx solid #ef4444; }
  &.warning { border-left: 8rpx solid #f59e0b; }
  &.info { border-left: 8rpx solid #0ea5e9; }
}
.empty { text-align: center; padding: 80rpx 20rpx; }
.empty-t { display: block; font-size: 30rpx; font-weight: 600; color: #0f172a; margin-bottom: 8rpx; }
.empty-s { font-size: 24rpx; color: #94a3b8; }
.row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10rpx;
}
.lv {
  font-size: 20rpx;
  padding: 4rpx 12rpx;
  border-radius: 999rpx;
  &.critical { background: #fee2e2; color: #b91c1c; }
  &.warning { background: #fffbeb; color: #b45309; }
  &.info { background: #e0f2fe; color: #0369a1; }
}
.time { font-size: 22rpx; color: #94a3b8; }
.msg { display: block; font-size: 26rpx; color: #0f172a; margin-bottom: 8rpx; }
.code { font-size: 20rpx; color: #94a3b8; font-family: monospace; }
</style>
