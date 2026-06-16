<template>
  <view class="video-container">
    <!-- 顶部导航 -->
    <view class="nav-bar">
      <view class="nav-back" @tap="goBack">
        <text class="back-icon">‹</text>
      </view>
      <text class="nav-title">视频影音</text>
      <view class="nav-placeholder"></view>
    </view>

    <!-- 分类筛选 -->
    <view class="filter-section">
      <scroll-view scroll-x class="filter-scroll">
        <view class="filter-list">
          <view
            class="filter-item"
            :class="{ active: activeType === item.value }"
            v-for="item in videoTypes"
            :key="item.value"
            @tap="onTypeChange(item.value)"
          >
            <text>{{ item.label }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- 热播推荐 -->
    <view class="hot-section">
      <view class="section-header">
        <text class="section-title">🔥 热播推荐</text>
      </view>
      <scroll-view scroll-x class="hot-scroll">
        <view class="hot-list">
          <view class="hot-card" v-for="(item, index) in hotVideos" :key="index" @tap="viewDetail(item)">
            <view class="hot-cover">
              <image v-if="item.cover_url" :src="item.cover_url" class="hot-cover-img" mode="aspectFill" />
              <text v-else class="hot-emoji">🎬</text>
              <view class="hot-score">
                <text class="score-text">{{ item.score }}</text>
              </view>
            </view>
            <text class="hot-name">{{ item.title }}</text>
            <text class="hot-tag">{{ item.status_text }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- 视频列表 -->
    <view class="list-section">
      <view class="section-header">
        <text class="section-title">全部影视</text>
        <text class="section-sort" @tap="toggleSort">{{ sortLabel }}</text>
      </view>
      <view class="video-list">
        <view class="video-card" v-for="(item, index) in videoList" :key="index" @tap="viewDetail(item)">
          <view class="video-cover">
            <image v-if="item.cover_url" :src="item.cover_url" class="video-cover-img" mode="aspectFill" />
            <text v-else class="video-emoji">🎬</text>
            <view class="video-score-badge">
              <text class="score-badge-text">{{ item.score }}</text>
            </view>
            <view class="video-type-tag">
              <text class="type-tag-text">{{ getTypeName(item.video_type) }}</text>
            </view>
          </view>
          <view class="video-info">
            <text class="video-name">{{ item.title }}</text>
            <view class="video-meta">
              <text class="video-region">{{ item.region }}</text>
              <text class="video-year">{{ item.year }}</text>
              <text class="video-status">{{ item.status_text }}</text>
            </view>
            <text class="video-actors" v-if="item.actors">主演: {{ item.actors }}</text>
            <text class="video-desc">{{ item.description }}</text>
          </view>
        </view>
      </view>
      <view class="load-more" v-if="videoList.length > 0 && videoList.length < total">
        <text class="load-more-text" @tap="loadMore">{{ loading ? '加载中...' : '加载更多' }}</text>
      </view>
      <view class="empty-state" v-if="!loading && videoList.length === 0">
        <text class="empty-text">暂无影视数据</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { getVideoHome, getVideoList } from '@/api/entertainment'

const activeType = ref('')
const sortType = ref('created_at')
const loading = ref(false)
const page = ref(1)
const pageSize = ref(20)
const total = ref(0)

const videoTypes = ref([
  { value: '', label: '全部' },
  { value: 'movie', label: '电影' },
  { value: 'series', label: '电视剧' },
  { value: 'anime', label: '动漫' },
  { value: 'variety', label: '综艺' },
  { value: 'documentary', label: '纪录片' },
])

const sortLabel = computed(() => {
  return sortType.value === 'play_count' ? '最热' : sortType.value === 'created_at' ? '最新' : '高分'
})

const hotVideos = ref<any[]>([])
const videoList = ref<any[]>([])

function getTypeName(type: string): string {
  const map: Record<string, string> = {
    movie: '电影', series: '电视剧', anime: '动漫',
    variety: '综艺', documentary: '纪录片', short: '短视频',
  }
  return map[type] || type
}

function onTypeChange(type: string) {
  activeType.value = type
  page.value = 1
  loadVideoList()
}

function toggleSort() {
  const types = ['play_count', 'created_at', 'score']
  const idx = types.indexOf(sortType.value)
  sortType.value = types[(idx + 1) % types.length]
  page.value = 1
  loadVideoList()
}

async function loadHomeData() {
  try {
    const res = await getVideoHome()
    if (res.code === 200 && res.data) {
      hotVideos.value = res.data.hot || []
    }
  } catch (e) {
    console.error('加载视频首页失败', e)
  }
}

async function loadVideoList() {
  loading.value = true
  try {
    const params: any = {
      page: page.value,
      page_size: pageSize.value,
      sort_by: sortType.value,
    }
    if (activeType.value) {
      params.video_type = activeType.value
    }
    const res = await getVideoList(params)
    if (res.code === 200 && res.data) {
      if (page.value === 1) {
        videoList.value = res.data.list || []
      } else {
        videoList.value = [...videoList.value, ...(res.data.list || [])]
      }
      total.value = res.data.total || 0
    }
  } catch (e) {
    console.error('加载视频列表失败', e)
  } finally {
    loading.value = false
  }
}

function loadMore() {
  if (loading.value || videoList.value.length >= total.value) return
  page.value++
  loadVideoList()
}

function viewDetail(item: any) {
  uni.showToast({ title: `《${item.title}》- ${item.description?.substring(0, 30) || '精彩影视'}`, icon: 'none' })
}

function goBack() {
  uni.navigateBack()
}

onMounted(() => {
  loadHomeData()
  loadVideoList()
})
</script>

<style lang="scss" scoped>
.video-container {
  min-height: 100vh;
  background: #f5f6fa;
  padding-bottom: 40rpx;
}

.nav-bar {
  background: linear-gradient(135deg, #4facfe, #00f2fe);
  padding: 60rpx 30rpx 30rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.nav-back { width: 60rpx; height: 60rpx; display: flex; align-items: center; justify-content: center; }
.back-icon { font-size: 48rpx; color: #fff; font-weight: 700; }
.nav-title { font-size: 36rpx; font-weight: 700; color: #fff; }
.nav-placeholder { width: 60rpx; }

.filter-section { padding: 24rpx 30rpx; }
.filter-scroll { white-space: nowrap; }
.filter-list { display: inline-flex; gap: 16rpx; }
.filter-item {
  padding: 12rpx 32rpx;
  border-radius: 32rpx;
  background: #fff;
  font-size: 26rpx;
  color: #666;
  box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.04);
  &.active {
    background: linear-gradient(135deg, #4facfe, #00f2fe);
    color: #fff;
  }
}

.hot-section { padding: 0 30rpx; }
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}
.section-title { font-size: 32rpx; font-weight: 700; color: #333; }
.section-sort { font-size: 24rpx; color: #4facfe; }

.hot-scroll { white-space: nowrap; }
.hot-list { display: inline-flex; gap: 20rpx; padding-bottom: 10rpx; }
.hot-card {
  width: 220rpx;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
}
.hot-cover {
  width: 220rpx; height: 300rpx; border-radius: 16rpx;
  overflow: hidden; position: relative; background: #f0f0f0;
  display: flex; align-items: center; justify-content: center;
  margin-bottom: 12rpx;
}
.hot-cover-img { width: 100%; height: 100%; }
.hot-emoji { font-size: 72rpx; }
.hot-score {
  position: absolute; top: 8rpx; right: 8rpx;
  background: rgba(255,165,0,0.9); padding: 4rpx 12rpx; border-radius: 12rpx;
}
.score-text { font-size: 22rpx; color: #fff; font-weight: 600; }
.hot-name {
  font-size: 26rpx; font-weight: 600; color: #333;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.hot-tag { font-size: 22rpx; color: #999; }

.list-section { padding: 30rpx 30rpx 0; }
.video-list { display: flex; flex-direction: column; gap: 20rpx; }
.video-card {
  background: #fff;
  border-radius: 20rpx;
  overflow: hidden;
  display: flex;
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.05);
}
.video-cover {
  width: 200rpx; height: 280rpx;
  position: relative; flex-shrink: 0; background: #f0f0f0;
  display: flex; align-items: center; justify-content: center;
}
.video-cover-img { width: 100%; height: 100%; }
.video-emoji { font-size: 72rpx; }
.video-score-badge {
  position: absolute; top: 8rpx; left: 8rpx;
  background: rgba(255,165,0,0.9); padding: 4rpx 12rpx; border-radius: 12rpx;
}
.score-badge-text { font-size: 22rpx; color: #fff; font-weight: 600; }
.video-type-tag {
  position: absolute; bottom: 8rpx; left: 8rpx;
  background: rgba(0,0,0,0.6); padding: 4rpx 12rpx; border-radius: 12rpx;
}
.type-tag-text { font-size: 20rpx; color: #fff; }
.video-info {
  flex: 1; padding: 24rpx; display: flex; flex-direction: column;
  justify-content: flex-start; gap: 8rpx;
}
.video-name { font-size: 30rpx; font-weight: 600; color: #333; }
.video-meta { display: flex; gap: 16rpx; align-items: center; flex-wrap: wrap; }
.video-region, .video-year, .video-status {
  font-size: 22rpx; color: #4facfe; background: rgba(79,172,254,0.1);
  padding: 4rpx 12rpx; border-radius: 12rpx;
}
.video-actors { font-size: 22rpx; color: #666; }
.video-desc {
  font-size: 24rpx; color: #999;
  overflow: hidden; text-overflow: ellipsis; display: -webkit-box;
  -webkit-line-clamp: 2; -webkit-box-orient: vertical;
}

.load-more { text-align: center; padding: 30rpx 0; }
.load-more-text { font-size: 26rpx; color: #4facfe; }
.empty-state { text-align: center; padding: 100rpx 0; }
.empty-text { font-size: 28rpx; color: #999; }
</style>