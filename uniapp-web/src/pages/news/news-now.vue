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
          <text class="refresh-icon">⟳</text>
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
        <view class="loading-spinner"></view>
        <text class="loading-text">加载中...</text>
      </view>

      <view v-else-if="newsList.length === 0" class="empty-wrap">
        <text class="empty-icon">📰</text>
        <text class="empty-text">暂无新闻数据</text>
        <view class="empty-btn" @click="refreshAll">
          <text class="empty-btn-text">点击重试</text>
        </view>
      </view>

      <view v-else class="news-list">
        <view
          v-for="(item, idx) in displayList"
          :key="item.id || idx"
          class="news-card"
          @click="openNews(item)"
        >
          <!-- 卡片头部：来源标签 -->
          <view class="card-source" :style="{ background: item.sourceBgColor || '#f0f0f0' }">
            <view class="card-source-left">
              <view class="source-dot" :style="{ background: item.sourceColor || '#999' }"></view>
              <text class="source-label" :style="{ color: item.sourceColor || '#666' }">{{ item.sourceName }}</text>
              <text class="source-type">{{ item.sourceLabel || '热点' }}</text>
            </view>
            <text class="card-rank" :class="{ 'rank-hot': idx < 3 }">{{ idx + 1 }}</text>
          </view>

          <!-- 卡片内容 -->
          <view class="card-body">
            <view class="card-text">
              <text class="card-title">{{ item.title }}</text>
              <text v-if="item.description" class="card-desc">{{ item.description }}</text>
              <text v-if="item.hotValue" class="card-hot">
                <text class="hot-icon">🔥</text> {{ item.hotValue }}
              </text>
            </view>
            <image
              v-if="item.image"
              class="card-image"
              :src="item.image"
              mode="aspectFill"
              @error="onImageError(idx)"
            />
          </view>
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
  if (url) {
    uni.navigateTo({
      url: `/pages/news/webview?url=${encodeURIComponent(url)}&title=${encodeURIComponent(item.title)}`
    })
  }
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
.news-page {
  min-height: 100vh;
  background: #f5f6fa;
}

.nav-bar {
  background: linear-gradient(135deg, #1a1a2e, #16213e);
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
  font-size: 18px;
  font-weight: 700;
  color: #fff;
  letter-spacing: 1px;
}

.refresh-icon {
  font-size: 22px;
  color: #fff;
}

/* 新闻源切换栏 */
.source-bar {
  background: #fff;
  padding: 10px 0;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
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
  background: #f0f0f0;
  color: #666;
  font-size: 13px;
  font-weight: 500;
  transition: all 0.3s;
}

.source-tab.active {
  box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}

.source-tab-name {
  font-size: 13px;
}

.source-tab-count {
  font-size: 10px;
  background: rgba(255,255,255,0.3);
  padding: 1px 6px;
  border-radius: 10px;
  min-width: 18px;
  text-align: center;
}

/* 新闻滚动区域 */
.news-scroll {
  padding: 12px;
}

.loading-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 120px;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #f0f0f0;
  border-top-color: #1a1a2e;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.loading-text {
  margin-top: 12px;
  color: #999;
  font-size: 14px;
}

.empty-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 100px;
}

.empty-icon {
  font-size: 48px;
}

.empty-text {
  margin-top: 12px;
  color: #999;
  font-size: 15px;
}

.empty-btn {
  margin-top: 20px;
  padding: 10px 30px;
  background: linear-gradient(135deg, #1a1a2e, #16213e);
  border-radius: 20px;
}

.empty-btn-text {
  color: #fff;
  font-size: 14px;
}

/* 新闻卡片列表 */
.news-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.news-card {
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0,0,0,0.06);
  transition: transform 0.2s;
}

.news-card:active {
  transform: scale(0.98);
}

.card-source {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 14px;
}

.card-source-left {
  display: flex;
  align-items: center;
  gap: 8px;
}

.source-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.source-label {
  font-size: 12px;
  font-weight: 600;
}

.source-type {
  font-size: 10px;
  color: #999;
  background: rgba(0,0,0,0.05);
  padding: 1px 6px;
  border-radius: 8px;
}

.card-rank {
  font-size: 14px;
  font-weight: 700;
  color: #ccc;
  min-width: 24px;
  text-align: center;
}

.card-rank.rank-hot {
  color: #ff4757;
  font-size: 16px;
}

.card-body {
  display: flex;
  align-items: flex-start;
  padding: 12px 14px;
  gap: 12px;
}

.card-text {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 6px;
  min-width: 0;
}

.card-title {
  font-size: 15px;
  color: #1a1a2e;
  font-weight: 600;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-desc {
  font-size: 12px;
  color: #999;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-hot {
  font-size: 11px;
  color: #ff6b35;
  display: flex;
  align-items: center;
  gap: 2px;
}

.hot-icon {
  font-size: 11px;
}

.card-image {
  width: 80px;
  height: 60px;
  border-radius: 8px;
  flex-shrink: 0;
  background: #f0f0f0;
}
</style>