<template>
  <view class="page">
    <view class="head">
      <text class="h1">实时监控</text>
      <StatusChip
        :label="connected ? '已连接' : '未连接'"
        :tone="connected ? 'ok' : 'idle'"
      />
    </view>

    <view v-if="!connected" class="empty card">
      <text class="empty-t">设备未连接</text>
      <text class="empty-s">请在「治疗」页连接 CoolCap 设备后查看实时数据</text>
      <button class="btn" @tap="goHome">去连接</button>
    </view>

    <template v-else>
      <view class="stats">
        <view class="stat card">
          <text class="sv">{{ snap.meanT.toFixed(1) }}</text>
          <text class="sl">全头均温 °C</text>
        </view>
        <view class="stat card">
          <text class="sv">{{ snap.deltaT.toFixed(1) }}</text>
          <text class="sl">温差 °C</text>
        </view>
        <view class="stat card">
          <text class="sv" :class="uniformClass">{{ uniformLabel }}</text>
          <text class="sl">均匀度</text>
        </view>
      </view>

      <ZoneHeatmap :zones="zones" class="mb" />

      <EnvDewpointCard :env="snap.env" :clamp-hint="snap.clampedByDewpoint" :min-setpoint="minSetpoint" class="mb" />

      <view class="grid">
        <ZoneCard v-for="z in zones" :key="z.id" :zone="z" />
      </view>

      <TempTrendChart :zones="zones" :points="points" class="mb" />

      <view class="sim card">
        <text class="sim-t">模拟调试</text>
        <view class="sim-row" v-for="z in zones" :key="z.id">
          <text class="sim-n">{{ z.name }} 接触</text>
          <switch :checked="z.contact" @change="onContact(z.id, $event)" color="#0EA5E9" />
        </view>
        <view class="sim-row">
          <text class="sim-n">顶区传感器故障</text>
          <switch :checked="!!faultP" @change="onFault" color="#EF4444" />
        </view>
      </view>
    </template>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import StatusChip from '@/components/StatusChip.vue'
import ZoneCard from '@/components/ZoneCard.vue'
import ZoneHeatmap from '@/components/ZoneHeatmap.vue'
import EnvDewpointCard from '@/components/EnvDewpointCard.vue'
import TempTrendChart from '@/components/TempTrendChart.vue'
import { useTherapy } from '@/services/store/useTherapy'
import { bleDevice } from '@/services/ble/device'
import type { ZoneId } from '@/services/types'

const { snapshot: snap, zones, connected, points } = useTherapy()
const faultP = ref(false)

const minSetpoint = computed(() => Math.min(...zones.value.map((z) => z.setpoint)))
const uniformLabel = computed(() => {
  const m: Record<string, string> = { excellent: '优', good: '良', poor: '差' }
  return m[snap.value.uniformity]
})
const uniformClass = computed(() => {
  if (snap.value.uniformity === 'excellent') return 'ok'
  if (snap.value.uniformity === 'good') return 'warn'
  return 'bad'
})

function goHome() {
  uni.switchTab({ url: '/pages/home/home' })
}

function onContact(id: ZoneId, e: any) {
  bleDevice.toggleContact(id, !!e.detail.value)
}

function onFault(e: any) {
  faultP.value = !!e.detail.value
  bleDevice.injectFault('P', faultP.value ? 'OPEN_CIRCUIT' : null)
}
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  padding: 24rpx 28rpx 48rpx;
  background: #f4f7fb;
}
.head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}
.h1 { font-size: 40rpx; font-weight: 700; color: #0f172a; }
.card {
  background: #fff;
  border-radius: 24rpx;
  box-shadow: 0 2rpx 8rpx rgba(15, 23, 42, 0.04);
}
.mb { margin-bottom: 20rpx; }
.empty {
  padding: 80rpx 40rpx;
  text-align: center;
}
.empty-t { display: block; font-size: 30rpx; font-weight: 600; color: #0f172a; margin-bottom: 12rpx; }
.empty-s { display: block; font-size: 24rpx; color: #64748b; margin-bottom: 32rpx; }
.btn {
  width: 320rpx;
  height: 80rpx;
  line-height: 80rpx;
  border-radius: 20rpx;
  background: #0ea5e9;
  color: #fff;
  font-size: 28rpx;
  border: none;
}
.stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16rpx;
  margin-bottom: 20rpx;
}
.stat { padding: 20rpx 12rpx; text-align: center; }
.sv { display: block; font-size: 36rpx; font-weight: 700; color: #0f172a; &.ok { color: #059669; } &.warn { color: #d97706; } &.bad { color: #dc2626; } }
.sl { font-size: 20rpx; color: #94a3b8; }
.grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16rpx;
  margin-bottom: 20rpx;
}
.sim {
  padding: 24rpx;
}
.sim-t { font-size: 28rpx; font-weight: 600; color: #0f172a; margin-bottom: 12rpx; display: block; }
.sim-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12rpx 0;
  border-bottom: 1rpx solid #f1f5f9;
}
.sim-n { font-size: 24rpx; color: #64748b; }
</style>
