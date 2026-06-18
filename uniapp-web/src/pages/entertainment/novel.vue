<template>
  <view class="novel-container">
    <!-- ===== 阅读器视图 ===== -->
    <template v-if="currentView === 'reader'">
      <view class="reader-container" :class="{ 'night-mode': isNightMode }">
        <!-- 阅读器顶栏 -->
        <view class="reader-topbar" v-if="showReaderControls">
          <view class="reader-topbar-back" @tap="closeReader">
            <text class="reader-topbar-icon">‹</text>
          </view>
          <text class="reader-topbar-title">{{ readerChapter.title }}</text>
          <view class="reader-topbar-placeholder"></view>
        </view>
        <!-- 阅读内容 -->
        <scroll-view scroll-y class="reader-scroll" :scroll-top="readerScrollTop" @tap="toggleReaderControls">
          <view class="reader-content">
            <text class="reader-chapter-title">{{ readerChapter.title }}</text>
            <text class="reader-text" :style="{ fontSize: fontSize + 'rpx' }">{{ readerChapter.content }}</text>
          </view>
        </scroll-view>
        <!-- 阅读器底栏 -->
        <view class="reader-bottombar" v-if="showReaderControls">
          <view class="reader-btn" @tap="goPrevChapter" :class="{ disabled: !readerChapter.prev_url }">
            <text class="reader-btn-text">‹ 上一章</text>
          </view>
          <view class="reader-btn" @tap="toggleNightMode">
            <text class="reader-btn-text">{{ isNightMode ? '☀️ 日间' : '🌙 夜间' }}</text>
          </view>
          <view class="reader-btn" @tap="changeFontSize(-1)">
            <text class="reader-btn-text">A-</text>
          </view>
          <view class="reader-btn" @tap="changeFontSize(1)">
            <text class="reader-btn-text">A+</text>
          </view>
          <view class="reader-btn" @tap="goNextChapter" :class="{ disabled: !readerChapter.next_url }">
            <text class="reader-btn-text">下一章 ›</text>
          </view>
        </view>
      </view>
    </template>

    <!-- ===== 小说详情视图 ===== -->
    <template v-else-if="currentView === 'detail'">
      <!-- 顶部导航 -->
      <view class="nav-bar">
        <view class="nav-back" @tap="closeDetail">
          <text class="back-icon">‹</text>
        </view>
        <text class="nav-title">小说详情</text>
        <view class="nav-placeholder"></view>
      </view>
      <scroll-view scroll-y class="detail-scroll">
        <!-- 书籍信息卡片 -->
        <view class="detail-book-card">
          <view class="detail-cover">
            <image v-if="novelInfo.cover" :src="novelInfo.cover" class="detail-cover-img" mode="aspectFill" />
            <text v-else class="detail-emoji">📖</text>
          </view>
          <view class="detail-book-info">
            <text class="detail-title">{{ novelInfo.title }}</text>
            <text class="detail-author">✍️ {{ novelInfo.author }}</text>
            <view class="detail-tags">
              <text class="detail-tag" v-if="novelInfo.category">{{ novelInfo.category }}</text>
              <text class="detail-tag" v-if="novelInfo.status">{{ novelInfo.status }}</text>
              <text class="detail-tag" v-if="novelInfo.word_count">{{ novelInfo.word_count }}</text>
            </view>
            <text class="detail-latest" v-if="novelInfo.last_chapter">最新: {{ novelInfo.last_chapter }}</text>
          </view>
        </view>
        <!-- 简介 -->
        <view class="detail-desc-card">
          <text class="detail-desc-title">📖 简介</text>
          <text class="detail-desc-text">{{ novelInfo.description || '暂无简介' }}</text>
        </view>
        <!-- 章节列表 -->
        <view class="detail-chapter-card">
          <view class="detail-chapter-header">
            <text class="detail-chapter-title">📑 章节列表</text>
            <text class="detail-chapter-count">共{{ novelInfo.chapters ? novelInfo.chapters.length : 0 }}章</text>
          </view>
          <view class="chapter-list">
            <view
              class="chapter-item"
              v-for="(ch, idx) in (novelInfo.chapters || []).slice(0, showAllChapters ? 9999 : 50)"
              :key="idx"
              @tap="readChapter(ch)"
            >
              <text class="chapter-item-title">{{ ch.title }}</text>
              <text class="chapter-item-arrow">›</text>
            </view>
            <view class="chapter-more" v-if="novelInfo.chapters && novelInfo.chapters.length > 50 && !showAllChapters" @tap="showAllChapters = true">
              <text class="chapter-more-text">展开全部{{ novelInfo.chapters.length }}章 ▼</text>
            </view>
          </view>
        </view>
      </scroll-view>
    </template>

    <!-- ===== 搜索结果视图 ===== -->
    <template v-else-if="currentView === 'search'">
      <!-- 顶部导航 + 搜索框 -->
      <view class="nav-bar">
        <view class="nav-back" @tap="closeSearch">
          <text class="back-icon">‹</text>
        </view>
        <view class="search-input-wrap">
          <input
            class="search-input"
            v-model="searchKeyword"
            placeholder="搜索小说名或作者"
            confirm-type="search"
            @confirm="doSearch"
            focus
          />
        </view>
        <view class="search-btn" @tap="doSearch">
          <text class="search-btn-text">搜索</text>
        </view>
      </view>
      <!-- 加载中 -->
      <view class="search-loading" v-if="searchLoading">
        <text class="search-loading-text">🔍 搜索中...</text>
      </view>
      <!-- 搜索结果列表 -->
      <scroll-view scroll-y class="search-result-scroll" v-else>
        <view class="search-result-list">
          <view class="search-result-item" v-for="(item, index) in searchResults" :key="index" @tap="viewCrawlDetail(item)">
            <view class="search-result-cover">
              <image v-if="item.cover" :src="item.cover" class="search-result-cover-img" mode="aspectFill" />
              <text v-else class="search-result-emoji">📖</text>
            </view>
            <view class="search-result-info">
              <text class="search-result-title">{{ item.title }}</text>
              <text class="search-result-author">{{ item.author }}</text>
              <view class="search-result-meta">
                <text class="search-result-genre" v-if="item.category">{{ item.category }}</text>
                <text class="search-result-status" v-if="item.status">{{ item.status }}</text>
                <text class="search-result-words" v-if="item.word_count">{{ item.word_count }}</text>
              </view>
              <text class="search-result-desc">{{ item.description }}</text>
            </view>
          </view>
        </view>
        <view class="empty-state" v-if="!searchLoading && searchResults.length === 0 && searchKeyword">
          <text class="empty-text">未找到相关小说</text>
        </view>
      </scroll-view>
    </template>

    <!-- ===== 主页视图 ===== -->
    <template v-else>
      <!-- 顶部导航 + 搜索入口 -->
      <view class="nav-bar">
        <view class="nav-back" @tap="goBack">
          <text class="back-icon">‹</text>
        </view>
        <text class="nav-title">网络小说</text>
        <view class="nav-search" @tap="openSearch">
          <text class="nav-search-icon">🔍</text>
        </view>
      </view>

      <!-- 搜索入口栏 -->
      <view class="search-entry" @tap="openSearch">
        <text class="search-entry-icon">🔍</text>
        <text class="search-entry-text">搜索你想看的小说...</text>
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
    </template>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { getNovelHome, getNovelList, crawlSearchNovels, crawlNovelInfo, crawlChapterContent } from '@/api/entertainment'

// ===== 视图控制 =====
const currentView = ref<'home' | 'search' | 'detail' | 'reader'>('home')

// ===== 主页数据 =====
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

// ===== 搜索相关 =====
const searchKeyword = ref('')
const searchResults = ref<any[]>([])
const searchLoading = ref(false)

// ===== 详情相关 =====
const novelInfo = ref<any>({})
const showAllChapters = ref(false)

// ===== 阅读器相关 =====
const readerChapter = ref<any>({})
const showReaderControls = ref(false)
const isNightMode = ref(false)
const fontSize = ref(32)
const previousView = ref<'home' | 'search'>('home')
const currentBookUrl = ref('')
const readerScrollTop = ref(0)

// ===== 主页方法 =====
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

async function viewDetail(item: any) {
  // 从数据库小说进入详情：先搜索 piquge.com 获取对应书籍URL，再加载详情
  if (!item.title) return
  uni.showLoading({ title: '加载中...' })
  try {
    // 先尝试用书名在线搜索找到对应书籍URL
    const searchRes = await crawlSearchNovels(item.title)
    if (searchRes.code === 200 && searchRes.data && searchRes.data.list && searchRes.data.list.length > 0) {
      // 找到最匹配的结果（标题相似度最高的）
      const list = Array.isArray(searchRes.data) ? searchRes.data : (searchRes.data.list || [])
      const matched = list.find((s: any) => s.title === item.title) || list[0]
      if (matched && matched.detail_url) {
        const infoRes = await crawlNovelInfo(matched.detail_url)
        if (infoRes.code === 200 && infoRes.data) {
          novelInfo.value = infoRes.data
          showAllChapters.value = false
          previousView.value = 'home'
          currentView.value = 'detail'
          uni.hideLoading()
          return
        }
      }
    }
    uni.showToast({ title: '暂无法获取该小说在线数据', icon: 'none' })
  } catch (e) {
    console.error('加载小说详情失败', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

function goBack() {
  // 如果在子视图中，返回上级视图
  if (currentView.value !== 'home') {
    currentView.value = 'home'
    return
  }
  uni.navigateBack()
}

// ===== 搜索方法 =====
function openSearch() {
  searchKeyword.value = ''
  searchResults.value = []
  currentView.value = 'search'
}

function closeSearch() {
  searchResults.value = []
  searchKeyword.value = ''
  currentView.value = 'home'
}

async function doSearch() {
  const kw = searchKeyword.value.trim()
  if (!kw) return
  searchLoading.value = true
  searchResults.value = []
  try {
    const res = await crawlSearchNovels(kw)
    if (res.code === 200 && res.data) {
      searchResults.value = Array.isArray(res.data) ? res.data : (res.data.list || [])
    } else {
      uni.showToast({ title: res.message || '搜索失败', icon: 'none' })
    }
  } catch (e) {
    console.error('搜索失败', e)
    uni.showToast({ title: '搜索失败，请重试', icon: 'none' })
  } finally {
    searchLoading.value = false
  }
}

// ===== 详情方法 =====
async function viewCrawlDetail(item: any) {
  if (!item.detail_url) {
    uni.showToast({ title: '无法获取详情', icon: 'none' })
    return
  }
  uni.showLoading({ title: '加载中...' })
  try {
    const res = await crawlNovelInfo(item.detail_url, true)
    if (res.code === 200 && res.data) {
      novelInfo.value = res.data
      currentBookUrl.value = item.detail_url
      showAllChapters.value = false
      previousView.value = 'search'
      currentView.value = 'detail'
    } else {
      uni.showToast({ title: res.message || '加载失败', icon: 'none' })
    }
  } catch (e) {
    console.error('加载详情失败', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

function closeDetail() {
  currentView.value = previousView.value
}

// ===== 阅读器方法 =====
async function readChapter(ch: any) {
  if (!ch.url) {
    uni.showToast({ title: '无法获取章节内容', icon: 'none' })
    return
  }
  uni.showLoading({ title: '加载中...' })
  try {
    const res = await crawlChapterContent(ch.url)
    if (res.code === 200 && res.data) {
      readerChapter.value = res.data
      showReaderControls.value = false
      readerScrollTop.value = readerScrollTop.value === 0 ? 0.01 : 0 // 触发滚动到顶部
      currentView.value = 'reader'
    } else {
      uni.showToast({ title: res.message || '加载失败', icon: 'none' })
    }
  } catch (e) {
    console.error('加载章节失败', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

function closeReader() {
  currentView.value = 'detail'
}

function toggleReaderControls() {
  showReaderControls.value = !showReaderControls.value
}

function toggleNightMode() {
  isNightMode.value = !isNightMode.value
}

function changeFontSize(delta: number) {
  fontSize.value = Math.max(24, Math.min(48, fontSize.value + delta))
  // 保存字体大小偏好
  try {
    uni.setStorageSync('novel_font_size', fontSize.value)
  } catch (e) {}
}

async function goPrevChapter() {
  if (!readerChapter.value.prev_url) return
  uni.showLoading({ title: '加载中...' })
  try {
    const res = await crawlChapterContent(readerChapter.value.prev_url)
    if (res.code === 200 && res.data) {
      readerChapter.value = res.data
      showReaderControls.value = false
      readerScrollTop.value = readerScrollTop.value === 0 ? 0.01 : 0
    }
  } catch (e) {
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

async function goNextChapter() {
  if (!readerChapter.value.next_url) return
  uni.showLoading({ title: '加载中...' })
  try {
    const res = await crawlChapterContent(readerChapter.value.next_url)
    if (res.code === 200 && res.data) {
      readerChapter.value = res.data
      showReaderControls.value = false
      readerScrollTop.value = readerScrollTop.value === 0 ? 0.01 : 0
    }
  } catch (e) {
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

onMounted(() => {
  // 恢复字体大小偏好
  try {
    const saved = uni.getStorageSync('novel_font_size')
    if (saved) fontSize.value = Number(saved)
  } catch (e) {}
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

/* ===== 导航栏 ===== */
.nav-bar {
  background: linear-gradient(135deg, #43e97b, #38f9d7);
  padding: 60rpx 30rpx 30rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.nav-back { width: 60rpx; height: 60rpx; display: flex; align-items: center; justify-content: center; }
.back-icon { font-size: 48rpx; color: #fff; font-weight: 700; }
.nav-title { font-size: 36rpx; font-weight: 700; color: #fff; flex: 1; text-align: center; }
.nav-placeholder { width: 60rpx; }
.nav-search { width: 60rpx; height: 60rpx; display: flex; align-items: center; justify-content: center; }
.nav-search-icon { font-size: 36rpx; }

/* ===== 搜索入口栏 ===== */
.search-entry {
  margin: 24rpx 30rpx;
  background: #fff;
  border-radius: 40rpx;
  padding: 18rpx 30rpx;
  display: flex;
  align-items: center;
  gap: 16rpx;
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.06);
}
.search-entry-icon { font-size: 32rpx; }
.search-entry-text { font-size: 28rpx; color: #bbb; }

/* ===== 搜索视图 ===== */
.search-input-wrap {
  flex: 1;
  margin: 0 20rpx;
}
.search-input {
  background: rgba(255,255,255,0.9);
  border-radius: 30rpx;
  padding: 14rpx 28rpx;
  font-size: 28rpx;
  color: #333;
}
.search-btn {
  padding: 10rpx 24rpx;
  background: rgba(255,255,255,0.3);
  border-radius: 30rpx;
}
.search-btn-text { font-size: 28rpx; color: #fff; font-weight: 600; }

.search-loading { text-align: center; padding: 100rpx 0; }
.search-loading-text { font-size: 30rpx; color: #999; }

.search-result-scroll { height: calc(100vh - 160rpx); }
.search-result-list { padding: 24rpx 30rpx; display: flex; flex-direction: column; gap: 24rpx; }
.search-result-item {
  background: #fff;
  border-radius: 20rpx;
  overflow: hidden;
  display: flex;
  box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.06);
  transition: transform 0.2s;
  &:active { transform: scale(0.98); }
}
.search-result-cover {
  width: 180rpx; height: 250rpx;
  flex-shrink: 0; background: #f0f0f0;
  display: flex; align-items: center; justify-content: center;
}
.search-result-cover-img { width: 100%; height: 100%; }
.search-result-emoji { font-size: 72rpx; }
.search-result-info {
  flex: 1; padding: 24rpx; display: flex; flex-direction: column; gap: 8rpx;
}
.search-result-title { font-size: 32rpx; font-weight: 700; color: #333; }
.search-result-author { font-size: 24rpx; color: #666; }
.search-result-meta { display: flex; gap: 12rpx; flex-wrap: wrap; }
.search-result-genre {
  font-size: 22rpx; color: #43e97b; background: rgba(67,233,123,0.1);
  padding: 4rpx 12rpx; border-radius: 12rpx;
}
.search-result-status {
  font-size: 22rpx; color: #667eea; background: rgba(102,126,234,0.1);
  padding: 4rpx 12rpx; border-radius: 12rpx;
}
.search-result-words { font-size: 22rpx; color: #999; }
.search-result-desc {
  font-size: 24rpx; color: #999;
  overflow: hidden; text-overflow: ellipsis; display: -webkit-box;
  -webkit-line-clamp: 2; -webkit-box-orient: vertical;
}

/* ===== 详情视图 ===== */
.detail-scroll { height: calc(100vh - 140rpx); }
.detail-book-card {
  margin: 24rpx 30rpx;
  background: #fff;
  border-radius: 24rpx;
  padding: 30rpx;
  display: flex;
  gap: 28rpx;
  box-shadow: 0 8rpx 30rpx rgba(0,0,0,0.08);
}
.detail-cover {
  width: 200rpx; height: 280rpx;
  border-radius: 16rpx; overflow: hidden; flex-shrink: 0;
  background: #f0f0f0;
  display: flex; align-items: center; justify-content: center;
}
.detail-cover-img { width: 100%; height: 100%; }
.detail-emoji { font-size: 80rpx; }
.detail-book-info {
  flex: 1; display: flex; flex-direction: column; gap: 12rpx;
}
.detail-title { font-size: 36rpx; font-weight: 700; color: #333; }
.detail-author { font-size: 26rpx; color: #666; }
.detail-tags { display: flex; gap: 12rpx; flex-wrap: wrap; }
.detail-tag {
  font-size: 22rpx; color: #43e97b; background: rgba(67,233,123,0.1);
  padding: 6rpx 16rpx; border-radius: 16rpx;
}
.detail-latest { font-size: 24rpx; color: #f5a623; }

.detail-desc-card {
  margin: 0 30rpx 24rpx;
  background: #fff;
  border-radius: 24rpx;
  padding: 30rpx;
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.04);
}
.detail-desc-title { font-size: 30rpx; font-weight: 700; color: #333; margin-bottom: 16rpx; }
.detail-desc-text { font-size: 26rpx; color: #666; line-height: 1.8; }

.detail-chapter-card {
  margin: 0 30rpx 40rpx;
  background: #fff;
  border-radius: 24rpx;
  padding: 30rpx;
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.04);
}
.detail-chapter-header {
  display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx;
}
.detail-chapter-title { font-size: 30rpx; font-weight: 700; color: #333; }
.detail-chapter-count { font-size: 24rpx; color: #999; }
.chapter-list { display: flex; flex-direction: column; }
.chapter-item {
  display: flex; justify-content: space-between; align-items: center;
  padding: 24rpx 0;
  border-bottom: 1rpx solid #f0f0f0;
  &:active { background: #f9f9f9; }
}
.chapter-item-title { font-size: 28rpx; color: #333; }
.chapter-item-arrow { font-size: 32rpx; color: #ccc; }
.chapter-more { text-align: center; padding: 24rpx 0; }
.chapter-more-text { font-size: 26rpx; color: #43e97b; }

/* ===== 阅读器视图 ===== */
.reader-container {
  min-height: 100vh;
  background: #f8f4e8;
  display: flex; flex-direction: column;
  &.night-mode {
    background: #1a1a2e;
    .reader-text { color: #b0b0b0; }
    .reader-chapter-title { color: #888; }
    .reader-topbar { background: #16213e; }
    .reader-bottombar { background: #16213e; }
  }
}
.reader-topbar {
  background: rgba(0,0,0,0.8);
  padding: 60rpx 30rpx 20rpx;
  display: flex; align-items: center; justify-content: space-between;
}
.reader-topbar-back { width: 60rpx; height: 60rpx; display: flex; align-items: center; justify-content: center; }
.reader-topbar-icon { font-size: 48rpx; color: #fff; font-weight: 700; }
.reader-topbar-title { font-size: 28rpx; color: #fff; flex: 1; text-align: center; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.reader-topbar-placeholder { width: 60rpx; }
.reader-scroll { flex: 1; }
.reader-content { padding: 40rpx; }
.reader-chapter-title {
  font-size: 36rpx; font-weight: 700; color: #333;
  text-align: center; margin-bottom: 40rpx;
}
.reader-text {
  font-size: 32rpx; color: #444; line-height: 2;
  white-space: pre-wrap;
}
.reader-bottombar {
  background: rgba(0,0,0,0.8);
  padding: 20rpx 20rpx 50rpx;
  display: flex; justify-content: space-around;
}
.reader-btn {
  padding: 16rpx 20rpx;
  &.disabled { opacity: 0.3; }
}
.reader-btn-text { font-size: 26rpx; color: #fff; }

/* ===== 分类筛选 ===== */
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

/* ===== 推荐区 ===== */
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

/* ===== 小说列表 ===== */
.list-section { padding: 30rpx 30rpx 0; }
.novel-list { display: flex; flex-direction: column; gap: 20rpx; }
.novel-card {
  background: #fff;
  border-radius: 20rpx;
  overflow: hidden;
  display: flex;
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.05);
  transition: transform 0.2s;
  &:active { transform: scale(0.98); }
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