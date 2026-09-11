<template>
  <view class="zone-card" :class="{ warn: zone.state === 'protect' || zone.state === 'fault', pulse: zone.compensated }">
    <view class="top">
      <text class="name">{{ zone.name }}</text>
      <text class="state">{{ stateLabel }}</text>
    </view>
    <view class="temp-row">
      <text class="temp">{{ zone.scalpTemp.toFixed(1) }}</text>
      <text class="unit">°C</text>
      <text class="target">目标 {{ zone.setpoint.toFixed(0) }}°</text>
    </view>
    <view class="meta">
      <text>功率 {{ Math.round(zone.power) }}%</text>
      <text>{{ zone.current.toFixed(2) }}A</text>
    </view>
    <view v-if="!zone.contact" class="badge bad">接触异常</view>
    <view v-else-if="zone.fault" class="badge bad">传感器故障</view>
    <view v-else-if="zone.compensated" class="badge ok">已加大制冷</view>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { ZoneTelemetry } from '@/services/types'

const props = defineProps<{ zone: ZoneTelemetry }>()

const stateLabel = computed(() => {
  const map: Record<string, string> = {
    idle: '待机',
    ramp: '降温中',
    hold: '稳定',
    protect: '保护',
    fault: '故障'
  }
  return map[props.zone.state] || props.zone.state
})
</script>

<style lang="scss" scoped>
.zone-card {
  position: relative;
  background: #fff;
  border-radius: 20rpx;
  padding: 20rpx;
  box-shadow: 0 2rpx 8rpx rgba(15, 23, 42, 0.04);
  border: 1rpx solid transparent;

  &.warn {
    border-color: #fecaca;
    background: #fef2f2;
  }
  &.pulse {
    animation: pulse 1.2s ease;
  }
}
@keyframes pulse {
  0% { box-shadow: 0 0 0 0 rgba(14, 165, 233, 0.35); }
  100% { box-shadow: 0 0 0 12rpx rgba(14, 165, 233, 0); }
}
.top {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8rpx;
}
.name { font-size: 24rpx; color: #64748b; }
.state { font-size: 20rpx; color: #0ea5e9; }
.temp-row { display: flex; align-items: baseline; gap: 4rpx; }
.temp {
  font-size: 48rpx;
  font-weight: 700;
  color: #0f172a;
  font-variant-numeric: tabular-nums;
}
.unit { font-size: 22rpx; color: #64748b; }
.target { margin-left: auto; font-size: 22rpx; color: #64748b; }
.meta {
  margin-top: 8rpx;
  display: flex;
  justify-content: space-between;
  font-size: 20rpx;
  color: #94a3b8;
}
.badge {
  position: absolute;
  top: 16rpx;
  right: 16rpx;
  font-size: 18rpx;
  padding: 4rpx 10rpx;
  border-radius: 999rpx;
  &.bad { background: #fee2e2; color: #b91c1c; }
  &.ok { background: #e0f2fe; color: #0369a1; }
}
</style>
