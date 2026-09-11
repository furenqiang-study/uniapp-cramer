<template>
  <view class="page">
    <view class="head">
      <text class="h1">治疗方案</text>
      <text class="add" @tap="onCreate">+ 新建</text>
    </view>

    <view v-for="p in protocols" :key="String(p.id)" class="proto card">
      <view class="row">
        <text class="name">{{ p.name }}</text>
        <text class="tag" :class="p.builtin ? 'in' : 'cus'">{{ p.builtin ? '内置' : '自定义' }}</text>
      </view>
      <text class="desc">{{ p.note || '含多阶段温度与时长控制' }}</text>
      <view class="stages">
        <view v-for="(s, i) in p.stages" :key="i" class="stage">
          <text class="sn">{{ s.name }}</text>
          <text class="sv">{{ s.durationMin }}min · {{ s.targetTemp }}°C · ≤{{ s.maxDuty }}%</text>
        </view>
      </view>
      <view class="actions">
        <button class="btn ghost" @tap="onEdit(p)">编辑</button>
        <button class="btn solid" @tap="onApply(p)">应用到治疗</button>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { useTherapy } from '@/services/store/useTherapy'
import type { Protocol } from '@/services/types'

const { protocols, currentProtocol, refreshProtocols } = useTherapy()

function onApply(p: Protocol) {
  currentProtocol.value = p
  uni.setStorageSync('cc_active_protocol', p)
  uni.showToast({ title: '已应用到治疗', icon: 'success' })
}

function onCreate() {
  uni.navigateTo({ url: '/pages/protocol/edit' })
}

function onEdit(p: Protocol) {
  if (p.builtin) {
    uni.showModal({
      title: '内置方案',
      content: '将基于该方案创建可编辑副本？',
      success: (r) => {
        if (!r.confirm) return
        const copy: Protocol = {
          ...JSON.parse(JSON.stringify(p)),
          id: `custom_${Date.now()}`,
          name: `${p.name}-副本`,
          builtin: false
        }
        uni.setStorageSync('cc_edit_protocol', copy)
        uni.navigateTo({ url: '/pages/protocol/edit' })
      }
    })
    return
  }
  uni.setStorageSync('cc_edit_protocol', p)
  uni.navigateTo({ url: '/pages/protocol/edit' })
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
.add { font-size: 28rpx; color: #0ea5e9; font-weight: 600; }
.card {
  background: #fff;
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: 0 2rpx 8rpx rgba(15, 23, 42, 0.04);
}
.row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8rpx;
}
.name { font-size: 28rpx; font-weight: 600; color: #0f172a; flex: 1; padding-right: 12rpx; }
.tag {
  font-size: 20rpx;
  padding: 4rpx 12rpx;
  border-radius: 999rpx;
  &.in { background: #e0f2fe; color: #0369a1; }
  &.cus { background: #ecfdf5; color: #047857; }
}
.desc { font-size: 22rpx; color: #64748b; margin-bottom: 16rpx; display: block; }
.stages { margin-bottom: 16rpx; }
.stage {
  display: flex;
  justify-content: space-between;
  padding: 10rpx 0;
  border-bottom: 1rpx solid #f1f5f9;
}
.sn { font-size: 24rpx; color: #0f172a; }
.sv { font-size: 22rpx; color: #64748b; font-variant-numeric: tabular-nums; }
.actions {
  display: flex;
  gap: 16rpx;
}
.btn {
  flex: 1;
  height: 72rpx;
  line-height: 72rpx;
  border-radius: 16rpx;
  font-size: 26rpx;
  border: none;
  &.ghost {
    background: #f1f5f9;
    color: #0f172a;
  }
  &.solid {
    background: linear-gradient(135deg, #0ea5e9, #0284c7);
    color: #fff;
  }
}
</style>
