<template>
  <view class="env-card card">
    <view class="head">
      <text class="title">环境与露点防护</text>
      <text class="sub">目标 ≥ 露点 + {{ margin.toFixed(1) }}°C</text>
    </view>
    <view class="metrics">
      <view class="m">
        <text class="mv">{{ env.temp.toFixed(1) }}</text>
        <text class="ml">环境温度</text>
      </view>
      <view class="m">
        <text class="mv">{{ Math.round(env.humidity) }}%</text>
        <text class="ml">湿度</text>
      </view>
      <view class="m">
        <text class="mv">{{ env.dewPoint.toFixed(1) }}</text>
        <text class="ml">露点 °C</text>
      </view>
      <view class="m">
        <text class="mv" :class="marginClass">{{ marginShow.toFixed(1) }}</text>
        <text class="ml">安全余量</text>
      </view>
    </view>
    <view class="bar-wrap">
      <view class="bar">
        <view
          class="bar-fill"
          :class="barClass"
          :style="{ width: barWidth }"
        />
      </view>
      <text class="bar-label">{{ env.safe && marginShow >= margin ? '凝露风险低' : '余量不足，已钳制制冷目标' }}</text>
    </view>
    <view v-if="clampHint" class="clamp-hint">
      <text>已根据露点自动上调目标温度，从源头抑制凝露。</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { EnvironmentInfo } from '@/services/types'

const props = defineProps<{
  env: EnvironmentInfo
  clampHint?: boolean
  minSetpoint?: number
}>()

const margin = computed(() => props.env.margin)

const marginShow = computed(() => {
  if (props.minSetpoint == null) return props.env.temp - props.env.dewPoint
  return props.minSetpoint - props.env.dewPoint
})

const marginClass = computed(() => {
  const m = marginShow.value
  if (m < 1) return 'bad'
  if (m < margin.value) return 'warn'
  return 'ok'
})

const barWidth = computed(() => {
  const m = marginShow.value
  const pct = Math.max(8, Math.min(100, (m / 5) * 100))
  return `${pct}%`
})

const barClass = computed(() => marginClass.value)
</script>

<style lang="scss" scoped>
.env-card {
  padding: 24rpx;
  border-radius: 24rpx;
  background: #fff;
  box-shadow: 0 2rpx 8rpx rgba(15, 23, 42, 0.04);
}
.head {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16rpx;
}
.title { font-size: 28rpx; font-weight: 600; color: #0f172a; }
.sub { font-size: 22rpx; color: #64748b; }
.metrics {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8rpx;
  margin-bottom: 16rpx;
}
.m { text-align: center; }
.mv { display: block; font-size: 30rpx; font-weight: 700; color: #0f172a; font-variant-numeric: tabular-nums; }
.ml { font-size: 20rpx; color: #94a3b8; }
.ok { color: #059669 !important; }
.warn { color: #d97706 !important; }
.bad { color: #dc2626 !important; }
.bar-wrap {}
.bar {
  height: 12rpx;
  border-radius: 999rpx;
  background: #e2e8f0;
  overflow: hidden;
}
.bar-fill {
  height: 100%;
  border-radius: 999rpx;
  transition: width 0.3s;
  &.ok { background: #10b981; }
  &.warn { background: #f59e0b; }
  &.bad { background: #ef4444; }
}
.bar-label {
  margin-top: 8rpx;
  font-size: 22rpx;
  color: #64748b;
}
.clamp-hint {
  margin-top: 12rpx;
  padding: 12rpx 16rpx;
  border-radius: 12rpx;
  background: #fffbeb;
  color: #b45309;
  font-size: 22rpx;
}
</style>
