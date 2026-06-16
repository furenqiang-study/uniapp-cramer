<template>
  <view class="music-container">
    <!-- 顶部导航 -->
    <view class="nav-bar">
      <view class="nav-back" @tap="goBack">
        <text class="back-icon">‹</text>
      </view>
      <text class="nav-title">音乐播放</text>
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

    <!-- 推荐歌单 -->
    <view class="playlist-section">
      <view class="section-header">
        <text class="section-title">🎵 推荐歌单</text>
      </view>
      <scroll-view scroll-x class="playlist-scroll">
        <view class="playlist-list">
          <view class="playlist-card" v-for="(item, index) in playlists" :key="index" @tap="viewPlaylist(item)">
            <view class="playlist-cover">
              <image v-if="item.cover_url" :src="item.cover_url" class="playlist-cover-img" mode="aspectFill" />
              <text v-else class="playlist-emoji">🎵</text>
            </view>
            <text class="playlist-name">{{ item.title }}</text>
            <text class="playlist-count">{{ item.song_count }}首</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- 热门歌曲 -->
    <view class="songs-section">
      <view class="section-header">
        <text class="section-title">🔥 热门歌曲</text>
      </view>
      <view class="song-list">
        <view class="song-item" v-for="(item, index) in songList" :key="index" @tap="playSongItem(item)">
          <view class="song-rank" :class="{ 'rank-top': index < 3 }">
            <text class="rank-num">{{ index + 1 }}</text>
          </view>
          <view class="song-cover">
            <image v-if="item.cover_url" :src="item.cover_url" class="song-cover-img" mode="aspectFill" />
            <text v-else class="song-emoji">🎵</text>
          </view>
          <view class="song-info">
            <text class="song-name">{{ item.title }}</text>
            <text class="song-artist">{{ item.artist_name }}</text>
          </view>
          <view class="song-meta">
            <text class="song-duration">{{ formatDuration(item.duration) }}</text>
            <text class="song-plays">{{ formatCount(item.play_count) }}</text>
          </view>
        </view>
      </view>
      <view class="load-more" v-if="songList.length > 0 && songList.length < total">
        <text class="load-more-text" @tap="loadMore">{{ loading ? '加载中...' : '加载更多' }}</text>
      </view>
      <view class="empty-state" v-if="!loading && songList.length === 0">
        <text class="empty-text">暂无歌曲数据</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getMusicHome, getSongList, playSong } from '@/api/entertainment'

const activeGenre = ref('全部')
const loading = ref(false)
const page = ref(1)
const pageSize = ref(20)
const total = ref(0)

const genres = ref(['全部', '流行', '摇滚', '古风', '民谣', '电子', '经典', '纯音乐'])
const playlists = ref<any[]>([])
const songList = ref<any[]>([])

function formatDuration(sec: number): string {
  const m = Math.floor(sec / 60)
  const s = sec % 60
  return `${m}:${String(s).padStart(2, '0')}`
}

function formatCount(count: number): string {
  if (count >= 10000) return (count / 10000).toFixed(1) + 'w'
  if (count >= 1000) return (count / 1000).toFixed(1) + 'k'
  return String(count)
}

function onGenreChange(genre: string) {
  activeGenre.value = genre
  page.value = 1
  loadSongList()
}

async function loadHomeData() {
  try {
    const res = await getMusicHome()
    if (res.code === 200 && res.data) {
      playlists.value = res.data.recommend_playlists || []
    }
  } catch (e) {
    console.error('加载音乐首页失败', e)
  }
}

async function loadSongList() {
  loading.value = true
  try {
    const params: any = { page: page.value, page_size: pageSize.value }
    if (activeGenre.value !== '全部') {
      params.genre = activeGenre.value
    }
    const res = await getSongList(params)
    if (res.code === 200 && res.data) {
      if (page.value === 1) {
        songList.value = res.data.list || []
      } else {
        songList.value = [...songList.value, ...(res.data.list || [])]
      }
      total.value = res.data.total || 0
    }
  } catch (e) {
    console.error('加载歌曲列表失败', e)
  } finally {
    loading.value = false
  }
}

function loadMore() {
  if (loading.value || songList.value.length >= total.value) return
  page.value++
  loadSongList()
}

async function playSongItem(item: any) {
  try {
    await playSong(item.id)
    uni.showToast({ title: `正在播放: ${item.title}`, icon: 'none' })
  } catch (e) {}
}

function viewPlaylist(item: any) {
  uni.showToast({ title: `歌单: ${item.title}`, icon: 'none' })
}

function goBack() {
  uni.navigateBack()
}

onMounted(() => {
  loadHomeData()
  loadSongList()
})
</script>

<style lang="scss" scoped>
.music-container {
  min-height: 100vh;
  background: #f5f6fa;
  padding-bottom: 40rpx;
}

.nav-bar {
  background: linear-gradient(135deg, #f093fb, #f5576c);
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
    background: linear-gradient(135deg, #f093fb, #f5576c);
    color: #fff;
  }
}

.playlist-section { padding: 0 30rpx; }
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}
.section-title { font-size: 32rpx; font-weight: 700; color: #333; }

.playlist-scroll { white-space: nowrap; }
.playlist-list { display: inline-flex; gap: 20rpx; padding-bottom: 10rpx; }
.playlist-card {
  width: 240rpx;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
}
.playlist-cover {
  width: 240rpx; height: 240rpx; border-radius: 20rpx;
  display: flex; align-items: center; justify-content: center;
  margin-bottom: 16rpx; overflow: hidden; background: #f0f0f0;
}
.playlist-cover-img { width: 100%; height: 100%; }
.playlist-emoji { font-size: 72rpx; }
.playlist-name {
  font-size: 26rpx; font-weight: 600; color: #333;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.playlist-count { font-size: 22rpx; color: #999; }

.songs-section { padding: 30rpx 30rpx 0; }
.song-list { display: flex; flex-direction: column; gap: 16rpx; }
.song-item {
  background: #fff;
  border-radius: 16rpx;
  padding: 20rpx 24rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
}
.song-rank {
  width: 48rpx; text-align: center;
  &.rank-top .rank-num { color: #f5576c; font-weight: 700; }
}
.rank-num { font-size: 28rpx; color: #999; }
.song-cover {
  width: 80rpx; height: 80rpx; border-radius: 12rpx;
  overflow: hidden; background: #f0f0f0;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.song-cover-img { width: 100%; height: 100%; }
.song-emoji { font-size: 36rpx; }
.song-info {
  flex: 1; display: flex; flex-direction: column; gap: 6rpx;
  overflow: hidden;
}
.song-name {
  font-size: 28rpx; font-weight: 600; color: #333;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.song-artist { font-size: 22rpx; color: #999; }
.song-meta { display: flex; flex-direction: column; align-items: flex-end; gap: 4rpx; flex-shrink: 0; }
.song-duration { font-size: 22rpx; color: #999; }
.song-plays { font-size: 20rpx; color: #bbb; }

.load-more { text-align: center; padding: 30rpx 0; }
.load-more-text { font-size: 26rpx; color: #f5576c; }
.empty-state { text-align: center; padding: 100rpx 0; }
.empty-text { font-size: 28rpx; color: #999; }
</style>