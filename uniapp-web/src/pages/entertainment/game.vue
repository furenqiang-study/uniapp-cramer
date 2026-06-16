<template>
  <view class="game-container">
    <!-- 顶部导航 -->
    <view class="nav-bar">
      <view class="nav-back" @tap="goBack">
        <text class="back-icon">‹</text>
      </view>
      <text class="nav-title">游戏中心</text>
      <view class="nav-placeholder"></view>
    </view>

    <!-- 分类筛选 -->
    <view class="filter-section">
      <scroll-view scroll-x class="filter-scroll">
        <view class="filter-list">
          <view
            class="filter-item"
            :class="{ active: activeCategory === item.id }"
            v-for="item in categories"
            :key="item.id"
            @tap="onCategoryChange(item.id)"
          >
            <text>{{ item.name }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- 热门推荐 -->
    <view class="hot-section">
      <view class="section-header">
        <text class="section-title">🔥 热门推荐</text>
      </view>
      <view class="hot-grid">
        <view class="hot-card" v-for="(item, index) in hotGames" :key="index">
          <view class="hot-cover">
            <image v-if="item.cover_url" :src="item.cover_url" class="hot-cover-img" mode="aspectFill" />
            <text v-else class="hot-emoji">🎮</text>
          </view>
          <view class="hot-info">
            <text class="hot-name">{{ item.title }}</text>
            <text class="hot-players">{{ formatCount(item.play_count) }}人在玩</text>
          </view>
          <view class="hot-play-btn" @tap="playGame(item)">
            <text class="play-text">开始</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 游戏列表 -->
    <view class="list-section">
      <view class="section-header">
        <text class="section-title">全部游戏</text>
        <text class="section-sort" @tap="toggleSort">{{ sortLabel }}</text>
      </view>
      <view class="game-list">
        <view class="game-card" v-for="(item, index) in gameList" :key="index" @tap="playGame(item)">
          <view class="game-cover">
            <image v-if="item.cover_url" :src="item.cover_url" class="game-cover-img" mode="aspectFill" />
            <text v-else class="game-emoji">🎮</text>
            <view class="game-tag" v-if="item.score >= 4.5">
              <text class="tag-text">HOT</text>
            </view>
          </view>
          <view class="game-info">
            <text class="game-name">{{ item.title }}</text>
            <view class="game-meta">
              <text class="game-category">{{ getCategoryName(item.category_id) }}</text>
              <text class="game-rating">⭐ {{ item.score }}</text>
            </view>
            <text class="game-desc">{{ item.description }}</text>
          </view>
        </view>
      </view>
      <view class="load-more" v-if="gameList.length > 0 && gameList.length < total">
        <text class="load-more-text" @tap="loadMore">{{ loading ? '加载中...' : '加载更多' }}</text>
      </view>
      <view class="empty-state" v-if="!loading && gameList.length === 0">
        <text class="empty-text">暂无游戏数据</text>
      </view>
    </view>

  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { getGameHome, getGameList } from '@/api/entertainment'

const activeCategory = ref(0)
const sortType = ref('created_at')
const loading = ref(false)
const page = ref(1)
const pageSize = ref(20)
const total = ref(0)
const GAME_ROUTE_MAP: Record<string, string> = {
  '2048数字合并': '/pages/entertainment/games/game2048',
  '五子棋': '/pages/entertainment/games/gomoku',
  '消消乐': '/pages/entertainment/games/match3',
  '打砖块': '/pages/entertainment/games/breakout',
  '扫雷经典版': '/pages/entertainment/games/minesweeper',
  '接金币': '/pages/entertainment/games/coin-catch',
  '贪吃蛇': '/pages/entertainment/games/snake',
  '打地鼠': '/pages/entertainment/games/whack-mole',
  '飞鸟穿越': '/pages/entertainment/games/flappy-bird',
  '数字拼图': '/pages/entertainment/games/sliding-puzzle',
  '射击气球': '/pages/entertainment/games/balloon-shoot',
  '国旗配对': '/pages/entertainment/games/flag-match',
  '跳棋': '/pages/entertainment/games/checkers',
  '中国象棋': '/pages/entertainment/games/chinese-chess',
  '炸金花': '/pages/entertainment/games/zjh-poker',
}

const sortLabel = computed(() => {
  return sortType.value === 'play_count' ? '最热' : sortType.value === 'created_at' ? '最新' : '好评'
})

const categories = ref([{ id: 0, name: '全部' }])
const hotGames = ref<any[]>([])
const gameList = ref<any[]>([])

function formatCount(count: number): string {
  if (!count) return '0'
  if (count >= 10000) return (count / 10000).toFixed(1) + 'w'
  if (count >= 1000) return (count / 1000).toFixed(1) + 'k'
  return String(count)
}

function getCategoryName(categoryId: number): string {
  const cat = categories.value.find(c => c.id === categoryId)
  return cat ? cat.name : '其他'
}

function toggleSort() {
  const types = ['play_count', 'created_at', 'score']
  const idx = types.indexOf(sortType.value)
  sortType.value = types[(idx + 1) % types.length]
  page.value = 1
  loadGameList()
}

function onCategoryChange(id: number) {
  activeCategory.value = id
  page.value = 1
  loadGameList()
}

async function loadHomeData() {
  try {
    const res = await getGameHome()
    if (res.code === 200 && res.data) {
      // 按title去重，防止数据库重复记录导致显示多个
      const seen = new Set<string>()
      hotGames.value = (res.data.recommend || []).filter((g: any) => {
        if (seen.has(g.title)) return false
        seen.add(g.title)
        return true
      })
      if (res.data.categories && res.data.categories.length > 0) {
        categories.value = [{ id: 0, name: '全部' }, ...res.data.categories.map((c: any) => ({ id: c.id, name: c.name }))]
      }
    }
  } catch (e) {
    console.error('加载首页数据失败', e)
  }
}

async function loadGameList() {
  loading.value = true
  try {
    const params: any = { page: page.value, page_size: pageSize.value, sort_by: sortType.value }
    if (activeCategory.value > 0) params.category_id = activeCategory.value
    const res = await getGameList(params)
    if (res.code === 200 && res.data) {
      const hotIds = new Set(hotGames.value.map((g: any) => g.id))
      const seenTitles = new Set<string>()
      const filtered = (res.data.list || []).filter((g: any) => {
        if (hotIds.has(g.id)) return false
        if (seenTitles.has(g.title)) return false
        seenTitles.add(g.title)
        return true
      })
      gameList.value = page.value === 1 ? filtered : [...gameList.value, ...filtered]
      total.value = (res.data.total || 0) - (page.value === 1 ? (res.data.list || []).length - filtered.length : 0)
    }
  } catch (e) {
    console.error('加载游戏列表失败', e)
  } finally {
    loading.value = false
  }
}

function loadMore() {
  if (loading.value || gameList.value.length >= total.value) return
  page.value++
  loadGameList()
}

async function playGame(item: any) {
  const route = GAME_ROUTE_MAP[item.title]
  if (route) {
    uni.navigateTo({ url: route })
    return
  }
  uni.showToast({ title: '游戏开发中...', icon: 'none' })
}

function goBack() { uni.navigateBack() }

onMounted(() => {
  loadHomeData()
  loadGameList()
})
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: #f5f6fa; padding-bottom: 40rpx; }
.nav-bar { background: linear-gradient(135deg, #667eea, #764ba2); padding: 60rpx 30rpx 30rpx; display: flex; align-items: center; justify-content: space-between; }
.nav-back { width: 60rpx; height: 60rpx; display: flex; align-items: center; justify-content: center; }
.back-icon { font-size: 48rpx; color: #fff; font-weight: 700; }
.nav-title { font-size: 36rpx; font-weight: 700; color: #fff; }
.nav-placeholder { width: 60rpx; }
.filter-section { padding: 24rpx 30rpx; }
.filter-scroll { white-space: nowrap; }
.filter-list { display: inline-flex; gap: 16rpx; }
.filter-item { padding: 12rpx 32rpx; border-radius: 32rpx; background: #fff; font-size: 26rpx; color: #666; box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.04); &.active { background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; } }
.hot-section { padding: 0 30rpx; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24rpx; }
.section-title { font-size: 32rpx; font-weight: 700; color: #333; }
.section-sort { font-size: 24rpx; color: #667eea; }
.hot-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20rpx; margin-bottom: 30rpx; }
.hot-card { background: #fff; border-radius: 20rpx; padding: 24rpx; display: flex; align-items: center; gap: 20rpx; box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.05); }
.hot-cover { width: 80rpx; height: 80rpx; border-radius: 20rpx; display: flex; align-items: center; justify-content: center; flex-shrink: 0; overflow: hidden; background: #f0f0f0; }
.hot-cover-img { width: 100%; height: 100%; }
.hot-emoji { font-size: 40rpx; }
.hot-info { flex: 1; display: flex; flex-direction: column; gap: 6rpx; }
.hot-name { font-size: 28rpx; font-weight: 600; color: #333; }
.hot-players { font-size: 22rpx; color: #999; }
.hot-play-btn { background: linear-gradient(135deg, #667eea, #764ba2); padding: 10rpx 24rpx; border-radius: 20rpx; }
.play-text { font-size: 22rpx; color: #fff; }
.list-section { padding: 0 30rpx; }
.game-list { display: flex; flex-direction: column; gap: 20rpx; }
.game-card { background: #fff; border-radius: 20rpx; overflow: hidden; display: flex; box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.05); }
.game-cover { width: 200rpx; height: 200rpx; display: flex; align-items: center; justify-content: center; position: relative; flex-shrink: 0; background: #f0f0f0; }
.game-cover-img { width: 100%; height: 100%; }
.game-emoji { font-size: 72rpx; }
.game-tag { position: absolute; top: 12rpx; right: 12rpx; background: rgba(255,255,255,0.9); padding: 4rpx 12rpx; border-radius: 12rpx; }
.tag-text { font-size: 20rpx; color: #ff6b35; font-weight: 600; }
.game-info { flex: 1; padding: 24rpx; display: flex; flex-direction: column; justify-content: center; gap: 8rpx; }
.game-name { font-size: 30rpx; font-weight: 600; color: #333; }
.game-meta { display: flex; gap: 20rpx; align-items: center; }
.game-category { font-size: 22rpx; color: #667eea; background: rgba(102,126,234,0.1); padding: 4rpx 12rpx; border-radius: 12rpx; }
.game-rating { font-size: 22rpx; color: #f5a623; }
.game-desc { font-size: 24rpx; color: #999; overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; }
.load-more { text-align: center; padding: 30rpx 0; }
.load-more-text { font-size: 26rpx; color: #667eea; }
.empty-state { text-align: center; padding: 100rpx 0; }
.empty-text { font-size: 28rpx; color: #999; }
</style>