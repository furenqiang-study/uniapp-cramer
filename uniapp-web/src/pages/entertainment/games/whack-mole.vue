<template>
  <view class="game-container">
    <view class="header">
      <text class="back-btn" @tap="goBack">‹</text>
      <text class="title">打地鼠</text>
      <view class="info">
        <text class="info-text">⏱ {{ timeLeft }}s</text>
        <text class="info-text">🔨 {{ score }}</text>
      </view>
    </view>
    <view class="grid">
      <view class="hole" v-for="(hole, i) in holes" :key="i" @tap="whack(i)">
        <view :class="['mole', hole.active ? (hole.isBad ? 'bad' : 'show') : '']">
          <text class="mole-emoji">{{ hole.isBad ? '🐀' : '🐹' }}</text>
        </view>
        <view class="hole-bg">🕳️</view>
      </view>
    </view>
    <view class="overlay" v-if="gameOver">
      <view class="overlay-content">
        <text class="overlay-msg">⏰ 时间到！</text>
        <text class="overlay-score">得分：{{ score }}</text>
        <text class="overlay-best" v-if="score >= best && score > 0">🎉 新纪录！</text>
        <view class="btn" @tap="newGame"><text class="btn-text">再来一局</text></view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

interface Hole { active: boolean; isBad: boolean }

const GAME_TIME = 60
const score = ref(0)
const best = ref(0)
const timeLeft = ref(GAME_TIME)
const gameOver = ref(false)
const holes = ref<Hole[]>([])

let timerId: any = null
let moleId: any = null

function newGame() {
  score.value = 0; timeLeft.value = GAME_TIME; gameOver.value = false
  holes.value = Array(9).fill(null).map(() => ({ active: false, isBad: false }))
  clearInterval(timerId); clearInterval(moleId)
  timerId = setInterval(() => { timeLeft.value--; if (timeLeft.value <= 0) endGame() }, 1000)
  scheduleMole()
}

function scheduleMole() {
  clearInterval(moleId)
  const interval = Math.max(400, 1000 - (GAME_TIME - timeLeft.value) * 10)
  moleId = setInterval(() => {
    // hide all first
    holes.value.forEach(h => { h.active = false })
    // show 1-2 random moles
    const count = Math.random() < 0.3 ? 2 : 1
    for (let i = 0; i < count; i++) {
      const idx = Math.floor(Math.random() * 9)
      holes.value[idx].active = true
      holes.value[idx].isBad = Math.random() < 0.2
    }
    // auto hide after a short time
    const hideTime = Math.max(500, 1200 - (GAME_TIME - timeLeft.value) * 8)
    setTimeout(() => { holes.value.forEach(h => { h.active = false }) }, hideTime)
  }, interval)
}

function whack(i: number) {
  const hole = holes.value[i]
  if (!hole.active || gameOver.value) return
  if (hole.isBad) { score.value = Math.max(0, score.value - 10) }
  else { score.value += 15 }
  hole.active = false
}

function endGame() {
  gameOver.value = true
  clearInterval(timerId); clearInterval(moleId)
  holes.value.forEach(h => { h.active = false })
  if (score.value > best.value) { best.value = score.value; uni.setStorageSync('best_whack', best.value) }
}

function goBack() { uni.navigateBack() }

onMounted(() => { best.value = uni.getStorageSync('best_whack') || 0; newGame() })
onUnmounted(() => { clearInterval(timerId); clearInterval(moleId) })
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: linear-gradient(180deg, #2d5016, #1a3a0a); display: flex; flex-direction: column; align-items: center; padding: 20rpx; position: relative; }
.header { width: 100%; max-width: 600rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 30rpx; }
.back-btn { font-size: 48rpx; color: #fff; font-weight: 700; padding: 0 16rpx; }
.title { font-size: 44rpx; font-weight: bold; color: #f5a623; }
.info { display: flex; gap: 12rpx; }
.info-text { font-size: 24rpx; color: #fff; background: rgba(255,255,255,0.15); padding: 6rpx 14rpx; border-radius: 16rpx; }
.grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24rpx; width: 100%; max-width: 540rpx; padding: 20rpx; }
.hole { position: relative; height: 150rpx; display: flex; align-items: flex-end; justify-content: center; }
.hole-bg { font-size: 80rpx; opacity: 0.5; }
.mole { position: absolute; bottom: 20rpx; transform: translateY(100%); transition: transform 0.15s ease; z-index: 2; }
.mole.show { transform: translateY(0); }
.mole.bad { transform: translateY(0); }
.mole-emoji { font-size: 72rpx; }
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; }
.overlay-msg { font-size: 56rpx; color: #fff; font-weight: bold; margin-bottom: 16rpx; display: block; }
.overlay-score { font-size: 36rpx; color: #f5a623; margin-bottom: 10rpx; display: block; }
.overlay-best { font-size: 32rpx; color: #50e3c2; margin-bottom: 24rpx; display: block; }
.btn { background: #f5a623; padding: 16rpx 48rpx; border-radius: 30rpx; display: inline-block; }
.btn-text { font-size: 28rpx; color: #fff; }
</style>