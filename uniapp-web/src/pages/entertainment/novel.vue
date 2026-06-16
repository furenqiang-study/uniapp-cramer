<template>
  <view class="novel-container">
    <!-- 顶部导航 -->
    <view class="nav-bar">
      <view class="nav-back" @tap="goBack">
        <text class="back-icon">‹</text>
      </view>
      <text class="nav-title">网络小说</text>
      <view class="nav-placeholder"></view>
    </view>

    <!-- 分类筛选 -->
    <view class="filter-section">
      <scroll-view scroll-x class="filter-scroll">
        <view class="filter-list">
          <view
            class="filter-item"
            :class="{ active: activeGenre === item }"
            v-for="item in genres"
            :key="item"
            @tap="onGenreChange(item)"
          >
            <text>{{ item }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- 推荐小说 -->
    <view class="recommend-section">
      <view class="section-header">
        <text class="section-title">📖 编辑推荐</text>
      </view>
      <scroll-view scroll-x class="recommend-scroll">
        <view class="recommend-list">
          <view class="recommend-card" v-for="(item, index) in recommendNovels" :key="index" @tap="viewDetail(item)">
            <view class="recommend-cover">
              <image v-if="item.cover_url" :src="item.cover_url" class="recommend-cover-img" mode="aspectFill" />
              <text v-else class="recommend-emoji">📖</text>
            </view>
            <text class="recommend-name">{{ item.title }}</text>
            <text class="recommend-author">{{ item.author }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- 小说列表 -->
    <view class="list-section">
      <view class="section-header">
        <text class="section-title">全部小说</text>
        <text class="section-sort" @tap="toggleSort">{{ sortLabel }}</text>
      </view>
      <view class="novel-list">
        <view class="novel-card" v-for="(item, index) in novelList" :key="index" @tap="viewDetail(item)">
          <view class="novel-cover">
            <image v-if="item.cover_url" :src="item.cover_url" class="novel-cover-img" mode="aspectFill" />
            <text v-else class="novel-emoji">📖</text>
            <view class="novel-status-tag" :class="{ 'status-finish': item.status_text === '完本' }">
              <text class="status-text">{{ item.status_text }}</text>
            </view>
          </view>
          <view class="novel-info">
            <text class="novel-name">{{ item.title }}</text>
            <text class="novel-author">{{ item.author }}</text>
            <view class="novel-meta">
              <text class="novel-genre">{{ item.genre }}</text>
              <text class="novel-words">{{ formatWordCount(item.word_count) }}</text>
              <text class="novel-score">⭐ {{ item.score }}</text>
            </view>
            <text class="novel-desc">{{ item.description }}</text>
            <text class="novel-latest" v-if="item.last_chapter">最新: {{ item.last_chapter }}</text>
          </view>
        </view>
      </view>
      <view class="load-more" v-if="novelList.length > 0 && novelList.length < total">
        <text class="load-more-text" @tap="loadMore">{{ loading ? '加载中...' : '加载更多' }}</text>
      </view>
      <view class="empty-state" v-if="!loading && novelList.length === 0">
        <text class="empty-text">暂无小说数据</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { getNovelHome, getNovelList } from '@/api/entertainment'

const activeGenre = ref('全部')
const sortType = ref('created_at')
const loading = ref(false)
const page = ref(1)
const pageSize = ref(20)
const total = ref(0)

const genres = ref(['全部', '玄幻', '仙侠', '都市', '言情', '悬疑', '历史', '科幻'])

const sortLabel = computed(() => {
  return sortType.value === 'read_count' ? '最热' : sortType.value === 'created_at' ? '最新' : sortType.value === 'score' ? '好评' : '更新'
})

const recommendNovels = ref<any[]>([])
const novelList = ref<any[]>([])

function formatWordCount(count: number): string {
  if (count >= 10000) return (count / 10000).toFixed(0) + '万字'
  return count + '字'
}

function onGenreChange(genre: string) {
  activeGenre.value = genre
  page.value = 1
  loadNovelList()
}

function toggleSort() {
  const types = ['read_count', 'created_at', 'score', 'update']
  const idx = types.indexOf(sortType.value)
  sortType.value = types[(idx + 1) % types.length]
  page.value = 1
  loadNovelList()
}

async function loadHomeData() {
  try {
    const res = await getNovelHome()
    if (res.code === 200 && res.data) {
      recommendNovels.value = res.data.recommend || []
    }
  } catch (e) {
    console.error('加载小说首页失败', e)
  }
}

async function loadNovelList() {
  loading.value = true
  try {
    const params: any = {
      page: page.value,
      page_size: pageSize.value,
      sort_by: sortType.value,
    }
    if (activeGenre.value !== '全部') {
      params.genre = activeGenre.value
    }
    const res = await getNovelList(params)
    if (res.code === 200 && res.data) {
      if (page.value === 1) {
        novelList.value = res.data.list || []
      } else {
        novelList.value = [...novelList.value, ...(res.data.list || [])]
      }
      total.value = res.data.total || 0
    }
  } catch (e) {
    console.error('加载小说列表失败', e)
  } finally {
    loading.value = false
  }
}

function loadMore() {
  if (loading.value || novelList.value.length >= total.value) return
  page.value++
  loadNovelList()
}

function viewDetail(item: any) {
  uni.showToast({ title: `《${item.title}》- ${item.author}`, icon: 'none' })
}

function goBack() {
  uni.navigateBack()
}

onMounted(() => {
  loadHomeData()
  loadNovelList()
})
</script>

<style lang="scss" scoped>
.novel-container {
  min-height: 100vh;
  background: #f5f6fa;
  padding-bottom: 40rpx;
}

.nav-bar {
  background: linear-gradient(135deg, #43e97b, #38f9d7);
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
    background: linear-gradient(135deg, #43e97b, #38f9d7);
    color: #fff;
  }
}

.recommend-section { padding: 0 30rpx; }
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}
.section-title { font-size: 32rpx; font-weight: 700; color: #333; }
.section-sort { font-size: 24rpx; color: #43e97b; }

.recommend-scroll { white-space: nowrap; }
.recommend-list { display: inline-flex; gap: 20rpx; padding-bottom: 10rpx; }
.recommend-card {
  width: 200rpx;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
}
.recommend-cover {
  width: 200rpx; height: 280rpx; border-radius: 16rpx;
  overflow: hidden; background: #f0f0f0;
  display: flex; align-items: center; justify-content: center;
  margin-bottom: 12rpx;
}
.recommend-cover-img { width: 100%; height: 100%; }
.recommend-emoji { font-size: 72rpx; }
.recommend-name {
  font-size: 26rpx; font-weight: 600; color: #333;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.recommend-author { font-size: 22rpx; color: #999; }

.list-section { padding: 30rpx 30rpx 0; }
.novel-list { display: flex; flex-direction: column; gap: 20rpx; }
.novel-card {
  background: #fff;
  border-radius: 20rpx;
  overflow: hidden;
  display: flex;
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.05);
}
.novel-cover {
  width: 180rpx; height: 250rpx;
  position: relative; flex-shrink: 0; background: #f0f0f0;
  display: flex; align-items: center; justify-content: center;
}
.novel-cover-img { width: 100%; height: 100%; }
.novel-emoji { font-size: 72rpx; }
.novel-status-tag {
  position: absolute; bottom: 0; left: 0; right: 0;
  background: rgba(67,233,123,0.9); padding: 6rpx 0; text-align: center;
  &.status-finish { background: rgba(102,126,234,0.9); }
}
.status-text { font-size: 20rpx; color: #fff; font-weight: 600; }
.novel-info {
  flex: 1; padding: 24rpx; display: flex; flex-direction: column;
  justify-content: flex-start; gap: 8rpx;
}
.novel-name { font-size: 30rpx; font-weight: 600; color: #333; }
.novel-author { font-size: 24rpx; color: #666; }
.novel-meta { display: flex; gap: 16rpx; align-items: center; flex-wrap: wrap; }
.novel-genre {
  font-size: 22rpx; color: #43e97b; background: rgba(67,233,123,0.1);
  padding: 4rpx 12rpx; border-radius: 12rpx;
}
.novel-words { font-size: 22rpx; color: #999; }
.novel-score { font-size: 22rpx; color: #f5a623; }
.novel-desc {
  font-size: 24rpx; color: #999;
  overflow: hidden; text-overflow: ellipsis; display: -webkit-box;
  -webkit-line-clamp: 2; -webkit-box-orient: vertical;
}
.novel-latest { font-size: 22rpx; color: #43e97b; }

.load-more { text-align: center; padding: 30rpx 0; }
.load-more-text { font-size: 26rpx; color: #43e97b; }
.empty-state { text-align: center; padding: 100rpx 0; }
.empty-text { font-size: 28rpx; color: #999; }
</style>