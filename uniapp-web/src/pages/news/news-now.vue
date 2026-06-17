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

    <!-- Tab 切换 -->
    <view class="tab-bar">
      <view
        v-for="tab in tabs"
        :key="tab.key"
        :class="['tab-item', { active: currentTab === tab.key }]"
        @click="switchTab(tab.key)"
      >
        <text class="tab-icon">{{ tab.icon }}</text>
        <text class="tab-label">{{ tab.label }}</text>
      </view>
    </view>

    <!-- 新闻源卡片列表 -->
    <scroll-view
      class="source-scroll"
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

      <view v-else class="news-grid">
        <view
          v-for="(source, idx) in groupedSources"
          :key="source.name"
          class="source-card"
          :style="{ background: getSourceColor(idx) }"
        >
          <!-- 源头部 -->
          <view class="source-header">
            <view class="source-info">
              <image
                v-if="source.icon"
                class="source-icon"
                :src="source.icon"
                mode="aspectFit"
              />
              <view v-else class="source-icon-placeholder">
                <text class="source-icon-text">{{ source.name.charAt(0) }}</text>
              </view>
              <view class="source-meta">
                <view class="source-name-row">
                  <text class="source-name">{{ source.name }}</text>
                </view>
                <text class="source-time">{{ source.updateTime }}</text>
              </view>
            </view>
          </view>

          <!-- 新闻列表 -->
          <scroll-view class="news-list" scroll-y>
            <view
              v-for="(item, itemIdx) in source.items"
              :key="item.id || itemIdx"
              class="news-item"
              @click="openNews(item)"
            >
              <view class="news-rank">
                <text class="rank-num">{{ itemIdx + 1 }}</text>
              </view>
              <view class="news-content">
                <text class="news-title">{{ item.title }}</text>
                <text v-if="item.engagement" class="news-engagement">{{ item.engagement }}</text>
              </view>
            </view>
          </scroll-view>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { getNewsList } from '@/api/news'

interface NewsItem {
  id: string
  title: string
  url: string
  mobileUrl: string
  description: string
  source: string
  icon: string
  timestamp: string
  engagement: string
}

interface SourceGroup {
  name: string
  icon: string
  updateTime: string
  items: NewsItem[]
}

const statusBarHeight = ref(20)
const currentTab = ref('hottest')
const loading = ref(false)
const isRefreshing = ref(false)
const newsList = ref<NewsItem[]>([])
const scrollHeight = ref(500)

const tabs = [
  { key: 'hottest', label: '最热', icon: '🔥' },
  { key: 'latest', label: '最新', icon: '⚡' }
]

const sourceColors = [
  'linear-gradient(135deg, #667eea33, #764ba233)',
  'linear-gradient(135deg, #f093fb33, #f5576c33)',
  'linear-gradient(135deg, #4facfe33, #00f2fe33)',
  'linear-gradient(135deg, #43e97b33, #38f9d733)',
  'linear-gradient(135deg, #fa709a33, #fee14033)',
  'linear-gradient(135deg, #a18cd133, #fbc2eb33)',
  'linear-gradient(135deg, #ffecd233, #fcb69f33)',
  'linear-gradient(135deg, #ff9a9e33, #fecfef33)',
]

const sourceSolidColors = [
  '#eef2ff', '#fdf2f8', '#eff6ff', '#ecfdf5',
  '#fff7ed', '#faf5ff', '#fefce8', '#fef2f2'
]

function getSourceColor(idx: number) {
  return sourceSolidColors[idx % sourceSolidColors.length]
}

const groupedSources = computed<SourceGroup[]>(() => {
  const map = new Map<string, NewsItem[]>()
  for (const item of newsList.value) {
    const key = item.source || '未知来源'
    if (!map.has(key)) map.set(key, [])
    map.get(key)!.push(item)
  }
  const groups: SourceGroup[] = []
  for (const [name, items] of map) {
    const icon = items[0]?.icon || ''
    const ts = items[0]?.timestamp || ''
    groups.push({ name, icon, updateTime: ts ? formatTime(ts) : '刚刚更新', items })
  }
  return groups
})

function formatTime(ts: string): string {
  if (!ts) return '刚刚更新'
  try {
    const d = new Date(ts)
    if (isNaN(d.getTime())) return ts
    const now = Date.now()
    const diff = now - d.getTime()
    if (diff < 60000) return '刚刚更新'
    if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前更新`
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前更新`
    return `${d.getMonth() + 1}/${d.getDate()} 更新`
  } catch {
    return ts
  }
}

async function fetchNews(category: string = currentTab.value) {
  loading.value = true
  try {
    const res: any = await getNewsList(category)
    if (res && res.code === 200) {
      newsList.value = res.data || []
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

function switchTab(key: string) {
  if (currentTab.value === key) return
  currentTab.value = key
  newsList.value = []
  fetchNews(key)
}

async function onRefresh() {
  isRefreshing.value = true
  await fetchNews()
}

function refreshAll() {
  newsList.value = []
  fetchNews()
}

function openNews(item: NewsItem) {
  const url = item.mobileUrl || item.url
  if (url) {
    uni.navigateTo({
      url: `/pages/news/webview?url=${encodeURIComponent(url)}&title=${encodeURIComponent(item.title)}`
    })
  }
}

function goBack() {
  uni.navigateBack()
}

onMounted(() => {
  const sysInfo = uni.getSystemInfoSync()
  statusBarHeight.value = sysInfo.statusBarHeight || 20
  const navHeight = statusBarHeight.value + 44
  scrollHeight.value = sysInfo.windowHeight - navHeight - 50
  fetchNews()
})
</script>

<style scoped>
.news-page {
  min-height: 100vh;
  background: #f5f6fa;
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
  font-size: 18px;
  font-weight: 700;
  color: #fff;
}

.refresh-icon {
  font-size: 22px;
  color: #fff;
}

.tab-bar {
  display: flex;
  background: #fff;
  padding: 10px 16px;
  gap: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.tab-item {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 8px 20px;
  border-radius: 20px;
  background: #f0f0f0;
  transition: all 0.3s;
}

.tab-item.active {
  background: linear-gradient(135deg, #ff6b35, #ff8c42);
  box-shadow: 0 2px 8px rgba(255,107,53,0.3);
}

.tab-icon {
  font-size: 16px;
}

.tab-label {
  font-size: 14px;
  color: #666;
  font-weight: 500;
}

.tab-item.active .tab-label {
  color: #fff;
  font-weight: 700;
}

.source-scroll {
  padding: 16px 12px;
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
  border-top-color: #ff6b35;
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
  background: linear-gradient(135deg, #ff6b35, #ff8c42);
  border-radius: 20px;
}

.empty-btn-text {
  color: #fff;
  font-size: 14px;
}

.news-grid {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.source-card {
  border-radius: 16px;
  padding: 14px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.06);
  min-height: 200px;
  max-height: 420px;
  display: flex;
  flex-direction: column;
}

.source-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.source-info {
  display: flex;
  align-items: center;
  gap: 10px;
}

.source-icon {
  width: 32px;
  height: 32px;
  border-radius: 50%;
}

.source-icon-placeholder {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(135deg, #ff6b35, #ff8c42);
  display: flex;
  align-items: center;
  justify-content: center;
}

.source-icon-text {
  color: #fff;
  font-size: 14px;
  font-weight: 700;
}

.source-meta {
  display: flex;
  flex-direction: column;
}

.source-name-row {
  display: flex;
  align-items: center;
  gap: 6px;
}

.source-name {
  font-size: 16px;
  font-weight: 700;
  color: #333;
}

.source-time {
  font-size: 11px;
  color: #999;
  margin-top: 2px;
}

.news-list {
  flex: 1;
  background: rgba(255,255,255,0.7);
  border-radius: 12px;
  padding: 8px;
  overflow: hidden;
}

.news-item {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 10px 8px;
  border-radius: 8px;
  transition: background 0.2s;
}

.news-item:active {
  background: rgba(0,0,0,0.04);
}

.news-rank {
  min-width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0,0,0,0.06);
  border-radius: 6px;
  flex-shrink: 0;
}

.rank-num {
  font-size: 12px;
  color: #666;
  font-weight: 600;
}

.news-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
}

.news-title {
  font-size: 14px;
  color: #333;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.news-engagement {
  font-size: 11px;
  color: #999;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>