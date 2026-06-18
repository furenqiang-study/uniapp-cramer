<template>
  <view class="news-page">
    <!-- 自定义导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-content">
        <view class="nav-left" @click="goBack">
          <text class="back-icon">‹</text>
        </view>
        <text class="nav-title">新闻现在</text>
        <view class="nav-right" @click="refreshAll">
          <text class="refresh-icon" :class="{ 'refresh-spinning': isRefreshing }">⟳</text>
        </view>
      </view>
    </view>

    <!-- 新闻源切换 -->
    <view class="source-bar">
      <scroll-view scroll-x class="source-bar-scroll">
        <view
          v-for="source in sourceTabs"
          :key="source.key"
          :class="['source-tab', { active: currentSource === source.key }]"
          :style="currentSource === source.key ? { background: source.color, color: '#fff' } : {}"
          @click="switchSource(source.key)"
        >
          <text class="source-tab-name">{{ source.name }}</text>
          <text class="source-tab-count" v-if="source.count">{{ source.count }}</text>
          <view v-if="currentSource === source.key" class="source-tab-indicator" :style="{ background: source.color }"></view>
        </view>
      </scroll-view>
    </view>

    <!-- 新闻列表 -->
    <scroll-view
      class="news-scroll"
      scroll-y
      :style="{ height: scrollHeight + 'px' }"
      refresher-enabled
      :refresher-triggered="isRefreshing"
      @refresherrefresh="onRefresh"
    >
      <view v-if="loading && newsList.length === 0" class="loading-wrap">
        <view class="loading-spinner-wrap">
          <view class="loading-spinner"></view>
          <view class="loading-spinner-inner"></view>
        </view>
        <text class="loading-text">正在获取最新热点...</text>
      </view>

      <view v-else-if="newsList.length === 0" class="empty-wrap">
        <text class="empty-icon floating-anim">📰</text>
        <text class="empty-text">暂无新闻数据</text>
        <view class="empty-btn" @click="refreshAll">
          <text class="empty-btn-text">点击重试</text>
        </view>
      </view>

      <view v-else class="news-list">
        <view
          v-for="(item, idx) in displayList"
          :key="item.id || idx"
          class="news-card card-enter-anim"
          :class="{ 'card-top1': idx === 0, 'card-top2': idx === 1, 'card-top3': idx === 2 }"
          :style="{ animationDelay: Math.min(idx * 0.06, 0.6) + 's' }"
          @click="openNews(item)"
        >
          <!-- 左侧彩色装饰条 -->
          <view class="card-accent-bar" :style="{ background: item.sourceColor || '#999' }"></view>

          <!-- 卡片头部：来源标签 -->
          <view class="card-source" :style="{ background: item.sourceBgColor || '#f0f0f0' }">
            <view class="card-source-left">
              <view class="source-dot pulse-dot" :style="{ background: item.sourceColor || '#999' }"></view>
              <text class="source-label" :style="{ color: item.sourceColor || '#666' }">{{ item.sourceName }}</text>
              <text class="source-type">{{ item.sourceLabel || '热点' }}</text>
            </view>
            <view class="rank-badge" :class="{ 'rank-top1': idx === 0, 'rank-top2': idx === 1, 'rank-top3': idx === 2, 'rank-normal': idx > 2 }">
              <text class="rank-num">{{ idx + 1 }}</text>
            </view>
          </view>

          <!-- 卡片内容 -->
          <view class="card-body">
            <view class="card-text">
              <text class="card-title">{{ item.title }}</text>
              <text v-if="item.description" class="card-desc">{{ item.description }}</text>
              <text v-if="item.hotValue" class="card-hot">
                <text class="hot-icon wiggle-anim">🔥</text>
                <text class="hot-value">{{ item.hotValue }}</text>
              </text>
            </view>
            <view v-if="item.image" class="card-image-wrap">
              <image
                class="card-image"
                :src="item.image"
                mode="aspectFill"
                @error="onImageError(idx)"
              />
              <view class="card-image-shine"></view>
            </view>
          </view>

          <!-- 卡片底部光效 -->
          <view v-if="idx < 3" class="card-glow-bar" :style="{ background: `linear-gradient(90deg, ${item.sourceColor || '#999'}, transparent)` }"></view>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { getNewsList, getNewsSources } from '@/api/news'

interface NewsItem {
  id: string
  title: string
  url: string
  description: string
  hotValue: string
  image: string
  sourceKey: string
  sourceName: string
  sourceIcon: string
  sourceColor: string
  sourceBgColor: string
  sourceLabel: string
  tag?: string
  icon?: string
}

interface SourceTab {
  key: string
  name: string
  color: string
  bgColor: string
  label: string
  count: number
}

const statusBarHeight = ref(20)
const currentSource = ref('')
const loading = ref(false)
const isRefreshing = ref(false)
const newsList = ref<NewsItem[]>([])
const sourceTabs = ref<SourceTab[]>([])
const scrollHeight = ref(500)

const displayList = computed(() => {
  return newsList.value
})

async function fetchSources() {
  try {
    const res: any = await getNewsSources()
    if (res && res.code === 200 && res.data) {
      sourceTabs.value = res.data.map((s: any) => ({
        key: s.key,
        name: s.name,
        color: s.color || '#999',
        bgColor: s.bgColor || '#f0f0f0',
        label: s.label || '',
        count: 0,
      }))
      if (sourceTabs.value.length > 0 && !currentSource.value) {
        currentSource.value = ''
      }
    }
  } catch (e) {
    console.error('获取新闻源失败:', e)
  }
}

async function fetchNews(sources: string = '') {
  loading.value = true
  try {
    const params: any = { category: 'hottest' }
    if (sources) params.sources = sources
    const res: any = await getNewsList(params)
    if (res && res.code === 200) {
      newsList.value = res.data || []
      // 更新源的 count
      if (res.sources) {
        for (const s of res.sources) {
          const tab = sourceTabs.value.find(t => t.key === s.key)
          if (tab) tab.count = s.count
        }
      }
    } else {
      uni.showToast({ title: res?.message || '加载失败', icon: 'none' })
    }
  } catch (e: any) {
    uni.showToast({ title: '网络错误', icon: 'none' })
  } finally {
    loading.value = false
    isRefreshing.value = false
  }
}

function switchSource(key: string) {
  if (currentSource.value === key) {
    // 取消选择，显示全部
    currentSource.value = ''
    fetchNews()
  } else {
    currentSource.value = key
    newsList.value = []
    fetchNews(key)
  }
}

async function onRefresh() {
  isRefreshing.value = true
  await fetchNews(currentSource.value || undefined)
}

function refreshAll() {
  currentSource.value = ''
  newsList.value = []
  fetchNews()
}

function openNews(item: NewsItem) {
  const url = item.url
  if (!url) return

  // #ifdef APP-PLUS
  // @ts-ignore
  plus.runtime.openURL(url)
  // #endif

  // #ifdef H5
  window.open(url, '_blank')
  // #endif

  // #ifdef MP
  uni.setClipboardData({
    data: url,
    success: () => {
      uni.showToast({ title: '链接已复制到剪贴板', icon: 'none' })
    }
  })
  // #endif
}

function goBack() {
  uni.navigateBack()
}

function onImageError(idx: number) {
  // 图片加载失败时隐藏
  if (newsList.value[idx]) {
    newsList.value[idx].image = ''
  }
}

onMounted(() => {
  const sysInfo = uni.getSystemInfoSync()
  statusBarHeight.value = sysInfo.statusBarHeight || 20
  const navHeight = statusBarHeight.value + 44
  const sourceBarHeight = 52
  scrollHeight.value = sysInfo.windowHeight - navHeight - sourceBarHeight
  fetchSources()
  fetchNews()
})
</script>

<style scoped>
/* ========== 页面基础 ========== */
.news-page {
  min-height: 100vh;
  background: linear-gradient(180deg, #f0f2f8 0%, #f5f6fa 30%, #fafbfe 100%);
}

/* ========== 导航栏 ========== */
.nav-bar {
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 2px 20px rgba(26, 26, 46, 0.3);
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
  border-radius: 12px;
  transition: background 0.2s;
}

.nav-left:active, .nav-right:active {
  background: rgba(255, 255, 255, 0.15);
}

.back-icon {
  font-size: 28px;
  color: #fff;
  font-weight: bold;
}

.nav-title {
  font-size: 18px;
  font-weight: 700;
  color: #fff;
  letter-spacing: 2px;
  text-shadow: 0 1px 4px rgba(0, 0, 0, 0.2);
}

.refresh-icon {
  font-size: 22px;
  color: #fff;
  display: inline-block;
  transition: transform 0.3s;
}

.refresh-spinning {
  animation: refreshSpin 0.8s linear infinite;
}

@keyframes refreshSpin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* ========== 新闻源切换栏 ========== */
.source-bar {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  padding: 10px 0;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
  position: sticky;
  top: calc(var(--status-bar-height, 20px) + 44px);
  z-index: 99;
}

.source-bar-scroll {
  white-space: nowrap;
  padding: 0 12px;
}

.source-tab {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 6px 16px;
  margin-right: 10px;
  border-radius: 20px;
  background: #f0f0f5;
  color: #666;
  font-size: 13px;
  font-weight: 500;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.source-tab:active {
  transform: scale(0.95);
}

.source-tab.active {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  transform: translateY(-1px);
}

.source-tab-indicator {
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 20px;
  height: 3px;
  border-radius: 2px;
  opacity: 0.6;
}

.source-tab-name {
  font-size: 13px;
}

.source-tab-count {
  font-size: 10px;
  background: rgba(255, 255, 255, 0.3);
  padding: 1px 6px;
  border-radius: 10px;
  min-width: 18px;
  text-align: center;
}

/* ========== 新闻滚动区域 ========== */
.news-scroll {
  padding: 12px;
}

/* ========== 加载状态 ========== */
.loading-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 120px;
}

.loading-spinner-wrap {
  position: relative;
  width: 48px;
  height: 48px;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 3px solid transparent;
  border-top-color: #1a1a2e;
  border-right-color: #1a1a2e;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

.loading-spinner-inner {
  position: absolute;
  top: 8px;
  left: 8px;
  width: 32px;
  height: 32px;
  border: 3px solid transparent;
  border-bottom-color: #e94560;
  border-left-color: #e94560;
  border-radius: 50%;
  animation: spin 0.6s linear infinite reverse;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.loading-text {
  margin-top: 16px;
  color: #888;
  font-size: 14px;
  letter-spacing: 1px;
  animation: textPulse 1.5s ease-in-out infinite;
}

@keyframes textPulse {
  0%, 100% { opacity: 0.5; }
  50% { opacity: 1; }
}

/* ========== 空状态 ========== */
.empty-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 100px;
}

.empty-icon {
  font-size: 56px;
}

.floating-anim {
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-12px); }
}

.empty-text {
  margin-top: 16px;
  color: #999;
  font-size: 15px;
  letter-spacing: 1px;
}

.empty-btn {
  margin-top: 24px;
  padding: 12px 36px;
  background: linear-gradient(135deg, #1a1a2e, #0f3460);
  border-radius: 24px;
  box-shadow: 0 4px 16px rgba(26, 26, 46, 0.3);
  transition: transform 0.2s, box-shadow 0.2s;
}

.empty-btn:active {
  transform: scale(0.95);
  box-shadow: 0 2px 8px rgba(26, 26, 46, 0.2);
}

.empty-btn-text {
  color: #fff;
  font-size: 14px;
  font-weight: 500;
  letter-spacing: 1px;
}

/* ========== 新闻卡片列表 ========== */
.news-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

/* ========== 卡片入场动画 ========== */
.card-enter-anim {
  opacity: 0;
  animation: cardSlideIn 0.5s cubic-bezier(0.23, 1, 0.32, 1) forwards;
}

@keyframes cardSlideIn {
  from {
    opacity: 0;
    transform: translateY(30px) scale(0.97);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

/* ========== 新闻卡片 ========== */
.news-card {
  background: #fff;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 2px 16px rgba(0, 0, 0, 0.06);
  transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
}

.news-card:active {
  transform: scale(0.97) translateY(2px);
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.08);
}

/* 左侧彩色装饰条 */
.card-accent-bar {
  position: absolute;
  top: 0;
  left: 0;
  width: 4px;
  height: 100%;
  border-radius: 0 4px 4px 0;
  z-index: 1;
}

/* ========== 卡片头部 ========== */
.card-source {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 14px 10px 18px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.04);
}

.card-source-left {
  display: flex;
  align-items: center;
  gap: 8px;
}

/* 来源圆点脉冲动画 */
.source-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  position: relative;
}

.pulse-dot {
  animation: dotPulse 2s ease-in-out infinite;
}

.pulse-dot::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: inherit;
  animation: dotRipple 2s ease-in-out infinite;
}

@keyframes dotPulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.6; }
}

@keyframes dotRipple {
  0% {
    width: 8px;
    height: 8px;
    opacity: 0.6;
  }
  100% {
    width: 22px;
    height: 22px;
    opacity: 0;
  }
}

.source-label {
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.5px;
}

.source-type {
  font-size: 10px;
  color: #888;
  background: rgba(0, 0, 0, 0.05);
  padding: 2px 8px;
  border-radius: 8px;
  font-weight: 500;
}

/* ========== 排名徽章 ========== */
.rank-badge {
  min-width: 26px;
  height: 26px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.3s;
}

.rank-badge.rank-top1 {
  background: linear-gradient(135deg, #ff9a00, #ff6a00);
  box-shadow: 0 2px 10px rgba(255, 154, 0, 0.4);
  animation: rankGlow 2s ease-in-out infinite;
}

.rank-badge.rank-top2 {
  background: linear-gradient(135deg, #c0c0c0, #a0a0a0);
  box-shadow: 0 2px 8px rgba(192, 192, 192, 0.4);
}

.rank-badge.rank-top3 {
  background: linear-gradient(135deg, #cd7f32, #b8691e);
  box-shadow: 0 2px 8px rgba(205, 127, 50, 0.4);
}

.rank-badge.rank-normal {
  background: rgba(0, 0, 0, 0.06);
}

@keyframes rankGlow {
  0%, 100% {
    box-shadow: 0 2px 10px rgba(255, 154, 0, 0.4);
  }
  50% {
    box-shadow: 0 2px 18px rgba(255, 154, 0, 0.7);
  }
}

.rank-num {
  font-size: 12px;
  font-weight: 700;
  color: #fff;
  line-height: 1;
}

.rank-normal .rank-num {
  color: #aaa;
  font-weight: 600;
}

/* ========== 卡片内容 ========== */
.card-body {
  display: flex;
  align-items: flex-start;
  padding: 14px 14px 14px 18px;
  gap: 12px;
}

.card-text {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-width: 0;
}

.card-title {
  font-size: 15px;
  color: #1a1a2e;
  font-weight: 600;
  line-height: 1.6;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  letter-spacing: 0.3px;
}

.card-desc {
  font-size: 12px;
  color: #999;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* ========== 热度值 ========== */
.card-hot {
  font-size: 11px;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: linear-gradient(90deg, rgba(255, 107, 53, 0.08), rgba(255, 71, 87, 0.08));
  padding: 3px 10px;
  border-radius: 12px;
  align-self: flex-start;
}

.hot-icon {
  font-size: 12px;
  display: inline-block;
}

.wiggle-anim {
  animation: wiggle 2s ease-in-out infinite;
}

@keyframes wiggle {
  0%, 100% { transform: rotate(0deg); }
  25% { transform: rotate(-8deg); }
  75% { transform: rotate(8deg); }
}

.hot-value {
  color: #e94560;
  font-weight: 600;
  font-size: 11px;
  letter-spacing: 0.3px;
}

/* ========== 图片 ========== */
.card-image-wrap {
  flex-shrink: 0;
  border-radius: 10px;
  overflow: hidden;
  position: relative;
}

.card-image {
  width: 88px;
  height: 66px;
  border-radius: 10px;
  background: linear-gradient(135deg, #f0f0f5, #e8e8ee);
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.news-card:active .card-image {
  transform: scale(1.05);
}

/* ========== Top3 卡片特殊样式 ========== */
.card-top1 {
  border: 1.5px solid rgba(255, 154, 0, 0.2);
  box-shadow: 0 4px 24px rgba(255, 154, 0, 0.12), 0 2px 16px rgba(0, 0, 0, 0.06);
  animation-delay: 0s !important;
}

.card-top2 {
  border: 1.5px solid rgba(192, 192, 192, 0.25);
  box-shadow: 0 4px 20px rgba(192, 192, 192, 0.15), 0 2px 16px rgba(0, 0, 0, 0.06);
}

.card-top3 {
  border: 1.5px solid rgba(205, 127, 50, 0.2);
  box-shadow: 0 4px 20px rgba(205, 127, 50, 0.12), 0 2px 16px rgba(0, 0, 0, 0.06);
}

.card-top1:active {
  transform: scale(0.98) translateY(2px);
  box-shadow: 0 2px 12px rgba(255, 154, 0, 0.2), 0 1px 6px rgba(0, 0, 0, 0.08);
}

/* ========== 图片光泽滑过效果 ========== */
.card-image-shine {
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(
    90deg,
    transparent 0%,
    rgba(255, 255, 255, 0.15) 50%,
    transparent 100%
  );
  animation: imageShine 3s ease-in-out infinite;
  pointer-events: none;
}

@keyframes imageShine {
  0% { left: -100%; }
  50%, 100% { left: 100%; }
}

/* ========== 卡片底部光效条 ========== */
.card-glow-bar {
  height: 3px;
  opacity: 0.6;
  animation: glowPulse 2s ease-in-out infinite;
}

@keyframes glowPulse {
  0%, 100% { opacity: 0.4; }
  50% { opacity: 0.8; }
}

/* ========== 装饰条渐变动画 ========== */
.card-accent-bar {
  transition: width 0.3s ease;
}

.news-card:active .card-accent-bar {
  width: 6px;
}

/* ========== 标题文字悬浮高亮 ========== */
.card-title {
  transition: color 0.2s ease;
}

.news-card:active .card-title {
  color: #0f3460;
}

/* ========== 热度标签渐变流光 ========== */
.card-hot {
  position: relative;
  overflow: hidden;
}

.card-hot::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(255, 107, 53, 0.1),
    transparent
  );
  animation: hotShimmer 2.5s ease-in-out infinite;
}

@keyframes hotShimmer {
  0% { left: -100%; }
  100% { left: 100%; }
}

/* ========== 来源标签悬浮效果 ========== */
.source-type {
  transition: background 0.2s, transform 0.2s;
}

.news-card:active .source-type {
  background: rgba(0, 0, 0, 0.08);
  transform: scale(1.05);
}

/* ========== 卡片列表错落动画增强 ========== */
.news-list .news-card:nth-child(even) {
  animation-name: cardSlideInRight;
}

@keyframes cardSlideInRight {
  from {
    opacity: 0;
    transform: translateX(20px) scale(0.97);
  }
  to {
    opacity: 1;
    transform: translateX(0) scale(1);
  }
}

/* ========== 导航栏标题呼吸光效 ========== */
.nav-title {
  position: relative;
  overflow: hidden;
}

.nav-title::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 60%;
  height: 100%;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(255, 255, 255, 0.15),
    transparent
  );
  animation: titleShine 4s ease-in-out infinite;
}

@keyframes titleShine {
  0%, 100% { left: -100%; }
  50% { left: 100%; }
}

/* ========== 源切换栏选中态微弹 ========== */
.source-tab.active {
  animation: tabBounce 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes tabBounce {
  0% { transform: scale(0.9); }
  50% { transform: scale(1.05); }
  100% { transform: translateY(-1px) scale(1); }
}
</style>
