<template>
  <view class="entertainment-container">
    <!-- 顶部导航 -->
    <view class="nav-bar">
      <view class="nav-back" @tap="goBack">
        <text class="back-icon">‹</text>
      </view>
      <text class="nav-title">娱乐中心</text>
      <view class="nav-placeholder"></view>
    </view>

    <!-- 轮播图 -->
    <view class="banner-section">
      <swiper class="banner-swiper" autoplay circular indicator-dots indicator-color="rgba(255,255,255,0.4)" indicator-active-color="#fff">
        <swiper-item v-for="(item, index) in bannerList" :key="index">
          <view class="banner-item" :style="{ background: item.bgColor }">
            <view class="banner-content">
              <text class="banner-tag">{{ item.tag }}</text>
              <text class="banner-title">{{ item.title }}</text>
              <text class="banner-desc">{{ item.desc }}</text>
            </view>
            <text class="banner-emoji">{{ item.emoji }}</text>
          </view>
        </swiper-item>
      </swiper>
    </view>

    <!-- 四大模块入口 -->
    <view class="modules-section">
      <view class="section-header">
        <text class="section-title">全部模块</text>
      </view>
      <view class="modules-grid">
        <view
          class="module-card"
          v-for="item in moduleList"
          :key="item.id"
          @tap="goToModule(item)"
        >
          <view class="module-icon-wrapper" :style="{ background: item.bgColor }">
            <text class="module-icon">{{ item.icon }}</text>
          </view>
          <text class="module-name">{{ item.name }}</text>
          <text class="module-desc">{{ item.desc }}</text>
        </view>
      </view>
    </view>

    <!-- 热门推荐 -->
    <view class="recommend-section">
      <view class="section-header">
        <text class="section-title">热门推荐</text>
        <text class="section-more">更多 ›</text>
      </view>
      <scroll-view scroll-x class="recommend-scroll">
        <view class="recommend-list">
          <view
            class="recommend-card"
            v-for="(item, index) in recommendList"
            :key="index"
          >
            <view class="recommend-cover" :style="{ background: item.color }">
              <text class="recommend-emoji">{{ item.emoji }}</text>
            </view>
            <text class="recommend-name">{{ item.name }}</text>
            <text class="recommend-tag">{{ item.tag }}</text>
          </view>
        </view>
      </scroll-view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getGameHome, getMusicHome, getVideoHome, getNovelHome, globalSearch } from '@/api/entertainment'

// 轮播图数据
const bannerList = ref([
  {
    tag: '热门游戏',
    title: '经典小游戏合集',
    desc: '休闲益智，即点即玩',
    emoji: '🎮',
    bgColor: 'linear-gradient(135deg, #667eea, #764ba2)'
  },
  {
    tag: '音乐推荐',
    title: '今日热门歌单',
    desc: '精选好歌，悦享生活',
    emoji: '🎵',
    bgColor: 'linear-gradient(135deg, #f093fb, #f5576c)'
  },
  {
    tag: '影视热播',
    title: '最新院线大片',
    desc: '高清画质，畅享视听',
    emoji: '🎬',
    bgColor: 'linear-gradient(135deg, #4facfe, #00f2fe)'
  },
  {
    tag: '小说强推',
    title: '爆款网络小说',
    desc: '沉浸阅读，精彩不断',
    emoji: '📖',
    bgColor: 'linear-gradient(135deg, #43e97b, #38f9d7)'
  }
])

// 四大模块
const moduleList = ref([
  {
    id: 'game',
    name: '游戏中心',
    desc: '免下载即点即玩',
    icon: '🎮',
    bgColor: 'linear-gradient(135deg, #667eea, #764ba2)'
  },
  {
    id: 'music',
    name: '音乐播放',
    desc: '海量曲库在线听',
    icon: '🎵',
    bgColor: 'linear-gradient(135deg, #f093fb, #f5576c)'
  },
  {
    id: 'video',
    name: '视频影音',
    desc: '高清影视随时看',
    icon: '🎬',
    bgColor: 'linear-gradient(135deg, #4facfe, #00f2fe)'
  },
  {
    id: 'novel',
    name: '网络小说',
    desc: '精品网文沉浸读',
    icon: '📖',
    bgColor: 'linear-gradient(135deg, #43e97b, #38f9d7)'
  }
])

// 热门推荐（从各模块首页聚合）
const recommendList = ref<any[]>([])

const moduleStats = ref({
  game: { count: 0, label: '游戏' },
  music: { count: 0, label: '歌曲' },
  video: { count: 0, label: '影视' },
  novel: { count: 0, label: '小说' },
})

async function loadRecommendData() {
  const items: any[] = []
  try {
    const [gameRes, musicRes, videoRes, novelRes] = await Promise.allSettled([
      getGameHome(),
      getMusicHome(),
      getVideoHome(),
      getNovelHome(),
    ])

    if (gameRes.status === 'fulfilled' && gameRes.value.code === 200) {
      const games = gameRes.value.data?.recommend || []
      if (games.length > 0) {
        items.push({ name: games[0].title, tag: '游戏', emoji: '🎮', color: '#667eea' })
      }
      moduleStats.value.game.count = (gameRes.value.data?.hot || []).length
    }
    if (musicRes.status === 'fulfilled' && musicRes.value.code === 200) {
      const songs = musicRes.value.data?.hot_songs || []
      if (songs.length > 0) {
        items.push({ name: songs[0].title, tag: '音乐', emoji: '🎵', color: '#f5576c' })
      }
      moduleStats.value.music.count = songs.length
    }
    if (videoRes.status === 'fulfilled' && videoRes.value.code === 200) {
      const videos = videoRes.value.data?.hot || []
      if (videos.length > 0) {
        items.push({ name: videos[0].title, tag: '影视', emoji: '🎬', color: '#4facfe' })
      }
      moduleStats.value.video.count = videos.length
    }
    if (novelRes.status === 'fulfilled' && novelRes.value.code === 200) {
      const novels = novelRes.value.data?.recommend || []
      if (novels.length > 0) {
        items.push({ name: novels[0].title, tag: '小说', emoji: '📖', color: '#43e97b' })
      }
      moduleStats.value.novel.count = novels.length
    }
  } catch (e) {
    console.error('加载推荐数据失败', e)
  }

  // 如果接口失败，使用默认数据
  if (items.length === 0) {
    recommendList.value = [
      { name: '2048', tag: '益智', emoji: '🧩', color: '#667eea' },
      { name: '华语热歌榜', tag: '音乐', emoji: '🎸', color: '#f5576c' },
      { name: '科幻电影', tag: '影视', emoji: '🚀', color: '#4facfe' },
      { name: '玄幻小说', tag: '小说', emoji: '⚔️', color: '#43e97b' },
      { name: '斗地主', tag: '棋牌', emoji: '🃏', color: '#fa709a' },
      { name: '民谣合集', tag: '音乐', emoji: '🎹', color: '#a18cd1' },
    ]
  } else {
    recommendList.value = items
  }
}

function goBack() {
  uni.navigateBack()
}

function goToModule(item: any) {
  const routeMap: Record<string, string> = {
    game: '/pages/entertainment/game',
    music: '/pages/entertainment/music',
    video: '/pages/entertainment/video',
    novel: '/pages/entertainment/novel'
  }
  uni.navigateTo({ url: routeMap[item.id] || '' })
}

onMounted(() => {
  loadRecommendData()
})
</script>

<style lang="scss" scoped>
.entertainment-container {
  min-height: 100vh;
  background: #f5f6fa;
  padding-bottom: 40rpx;
}

// ========== 顶部导航 ==========
.nav-bar {
  background: linear-gradient(135deg, #667eea, #764ba2);
  padding: 60rpx 30rpx 30rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.nav-back {
  width: 60rpx;
  height: 60rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.back-icon {
  font-size: 48rpx;
  color: #fff;
  font-weight: 700;
}

.nav-title {
  font-size: 36rpx;
  font-weight: 700;
  color: #fff;
}

.nav-placeholder {
  width: 60rpx;
}

// ========== 轮播图 ==========
.banner-section {
  padding: 30rpx;
  margin-top: -10rpx;
}

.banner-swiper {
  height: 300rpx;
  border-radius: 24rpx;
  overflow: hidden;
}

.banner-item {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 40rpx;
  box-sizing: border-box;
  border-radius: 24rpx;
}

.banner-content {
  display: flex;
  flex-direction: column;
  flex: 1;
}

.banner-tag {
  font-size: 22rpx;
  color: rgba(255, 255, 255, 0.8);
  background: rgba(255, 255, 255, 0.2);
  padding: 4rpx 16rpx;
  border-radius: 20rpx;
  align-self: flex-start;
  margin-bottom: 16rpx;
}

.banner-title {
  font-size: 36rpx;
  font-weight: 700;
  color: #fff;
  margin-bottom: 10rpx;
}

.banner-desc {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.8);
}

.banner-emoji {
  font-size: 100rpx;
  margin-left: 30rpx;
}

// ========== 模块入口 ==========
.modules-section {
  padding: 0 30rpx;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #333;
}

.section-more {
  font-size: 24rpx;
  color: #999;
}

.modules-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20rpx;
}

.module-card {
  background: #fff;
  border-radius: 24rpx;
  padding: 36rpx 30rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.06);

  &:active {
    transform: scale(0.96);
  }
}

.module-icon-wrapper {
  width: 120rpx;
  height: 120rpx;
  border-radius: 36rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20rpx;
}

.module-icon {
  font-size: 56rpx;
}

.module-name {
  font-size: 30rpx;
  font-weight: 700;
  color: #333;
  margin-bottom: 8rpx;
}

.module-desc {
  font-size: 22rpx;
  color: #999;
}

// ========== 热门推荐 ==========
.recommend-section {
  padding: 30rpx 30px 0;
}

.recommend-scroll {
  white-space: nowrap;
}

.recommend-list {
  display: inline-flex;
  gap: 20rpx;
  padding-bottom: 10rpx;
}

.recommend-card {
  width: 240rpx;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
}

.recommend-cover {
  width: 240rpx;
  height: 240rpx;
  border-radius: 20rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16rpx;
}

.recommend-emoji {
  font-size: 72rpx;
}

.recommend-name {
  font-size: 26rpx;
  font-weight: 600;
  color: #333;
  margin-bottom: 6rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.recommend-tag {
  font-size: 22rpx;
  color: #999;
}
</style>