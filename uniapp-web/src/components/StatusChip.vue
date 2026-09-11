<template>
  <view class="status-chip" :class="`--${tone}`">
    <view class="dot" />
    <text class="text">{{ label }}</text>
  </view>
</template>

<script setup lang="ts">
defineProps<{
  label: string
  tone?: 'idle' | 'ok' | 'warn' | 'bad' | 'primary'
}>()
</script>

<style lang="scss" scoped>
.status-chip {
  display: inline-flex;
  align-items: center;
  gap: 8rpx;
  padding: 6rpx 16rpx;
  border-radius: 999rpx;
  background: #f1f5f9;
  font-size: 22rpx;
  color: #64748b;

  .dot {
    width: 12rpx;
    height: 12rpx;
    border-radius: 50%;
    background: #94a3b8;
  }

  &.--ok {
    background: #ecfdf5;
    color: #047857;
    .dot { background: #10b981; }
  }
  &.--warn {
    background: #fffbeb;
    color: #b45309;
    .dot { background: #f59e0b; }
  }
  &.--bad {
    background: #fef2f2;
    color: #b91c1c;
    .dot { background: #ef4444; }
  }
  &.--primary {
    background: #e0f2fe;
    color: #0369a1;
    .dot { background: #0ea5e9; }
  }
}
</style>
