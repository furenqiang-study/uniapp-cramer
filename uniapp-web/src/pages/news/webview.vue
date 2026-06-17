<template>
  <view class="webview-page">
    <!-- 自定义导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-content">
        <view class="nav-left" @click="goBack">
          <text class="back-icon">‹</text>
        </view>
        <text class="nav-title">{{ title || '新闻详情' }}</text>
        <view class="nav-right" @click="openInBrowser">
          <text class="browser-icon">↗</text>
        </view>
      </view>
    </view>
    <!-- webview -->
    <web-view :src="url" :style="{ height: webviewHeight + 'px' }"></web-view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

const url = ref('')
const title = ref('')
const statusBarHeight = ref(20)
const webviewHeight = ref(600)

function goBack() {
  uni.navigateBack()
}

function openInBrowser() {
  if (url.value) {
    uni.setClipboardData({
      data: url.value,
      success: () => {
        uni.showToast({ title: '链接已复制', icon: 'none' })
      }
    })
  }
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage.$page?.options || currentPage.options || {}
  url.value = decodeURIComponent(options.url || '')
  title.value = decodeURIComponent(options.title || '')

  const sysInfo = uni.getSystemInfoSync()
  statusBarHeight.value = sysInfo.statusBarHeight || 20
  webviewHeight.value = sysInfo.windowHeight - statusBarHeight.value - 44
})
</script>

<style scoped>
.webview-page {
  min-height: 100vh;
  background: #fff;
}

.nav-bar {
  background: linear-gradient(135deg, #ff6b35, #ff8c42);
  position: sticky;
  top: 0;
  z-index: 100;
}

.nav-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 44px;
  padding: 0 16px;
}

.nav-left, .nav-right {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.back-icon {
  font-size: 28px;
  color: #fff;
  font-weight: bold;
}

.nav-title {
  font-size: 16px;
  font-weight: 600;
  color: #fff;
  flex: 1;
  text-align: center;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  padding: 0 8px;
}

.browser-icon {
  font-size: 18px;
  color: #fff;
}
</style>