<template>
  <view class="page-back" @tap="onBack">
    <text class="icon">‹</text>
  </view>
</template>

<script setup lang="ts">
function onBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) {
    uni.navigateBack()
  } else {
    uni.switchTab({ url: '/pages/home/home' })
  }
}
</script>

<style lang="scss" scoped>
.page-back {
  position: fixed;
  top: calc(16rpx + env(safe-area-inset-top, 0px));
  left: 20rpx;
  z-index: 999;
  width: 56rpx;
  height: 56rpx;
  border-radius: 18rpx;
  background: rgba(255, 255, 255, 0.92);
  box-shadow: 0 2rpx 8rpx rgba(15, 23, 42, 0.08);
  display: flex;
  align-items: center;
  justify-content: center;
}
.icon {
  font-size: 36rpx;
  line-height: 1;
  color: #0f172a;
  font-weight: 700;
  margin-top: -4rpx;
}
</style>
