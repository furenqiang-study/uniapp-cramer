<template>
  <view class="game-container">
    <view class="header">
      <text class="back-btn" @tap="goBack">‹</text>
      <text class="title">射击气球</text>
      <view class="info">
        <text class="info-text">⏱ {{ timeLeft }}s</text>
        <text class="info-text">🎯 {{ score }}</text>
        <text class="info-text">🏆 {{ best }}</text>
      </view>
    </view>
    <view class="game-area" @tap="shoot">
      <view v-for="(b, i) in balloons" :key="i"
        class="balloon"
        :style="{ left: b.x + 'rpx', bottom: b.y + 'rpx', opacity: b.hit ? 0 : 1 }"
        @tap.stop="popBalloon(i)"
      >
        <text class="balloon-emoji">{{ b.type === 'gold' ? '🟡' : b.type === 'bomb' ? '⚫' : '🎈' }}</text>
      </view>
      <view v-for="(eff, i) in effects" :key="'e' + i" class="effect"
        :style="{ left: eff.x + 'rpx', bottom: eff.y + 'rpx', color: eff.color }">
        {{ eff.text }}
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

interface Balloon { x: number; y: number; speed: number; type: 'normal' | 'gold' | 'bomb'; hit: boolean }
interface Effect { x: number; y: number; text: string; color: string }

const AREA_W = 690, AREA_H = 900, GAME_TIME = 90

const score = ref(0)
const best = ref(0)
const timeLeft = ref(GAME_TIME)
const gameOver = ref(false)
const balloons = ref<Balloon[]>([])
const effects = ref<Effect[]>([])

let timerId: any = null
let animId: any = null
let spawnId: any = null

function newGame() {
  score.value = 0; timeLeft.value = GAME_TIME; gameOver.value = false
  balloons.value = []; effects.value = []
  clearInterval(timerId); cancelAnimationFrame(animId); clearInterval(spawnId)
  timerId = setInterval(() => { timeLeft.value--; if (timeLeft.value <= 0) endGame() }, 1000)
  spawnId = setInterval(spawnBalloon, 500)
  gameLoop()
}

function spawnBalloon() {
  const r = Math.random()
  const type = r < 0.15 ? 'gold' : r < 0.25 ? 'bomb' : 'normal'
  const baseSpeed = 2 + Math.floor((GAME_TIME - timeLeft.value) / 15)
  balloons.value.push({
    x: Math.random() * (AREA_W - 80) + 20,
    y: -80,
    speed: baseSpeed + Math.random() * 1.5,
    type,
    hit: false,
  })
}

function gameLoop() {
  if (gameOver.value) return
  update()
  animId = requestAnimationFrame(gameLoop)
}

function update() {
  balloons.value = balloons.value.filter(b => {
    if (b.hit) return false
    b.y += b.speed
    return b.y < AREA_H + 100
  })
  effects.value = effects.value.filter(e => { e.y += 2; return e.y < AREA_H + 50 })
}

function popBalloon(i: number) {
  const b = balloons.value[i]
  if (!b || b.hit || gameOver.value) return
  b.hit = true
  let points = 0
  if (b.type === 'normal') points = 10
  else if (b.type === 'gold') points = 25
  else points = -30
  score.value = Math.max(0, score.value + points)
  const text = points > 0 ? `+${points}` : `${points}`
  const color = points > 0 ? (b.type === 'gold' ? '#f8d90f' : '#50e3c2') : '#e94560'
  effects.value.push({ x: b.x, y: b.y, text, color })
}

function shoot() { /* tap on empty area does nothing */ }

function endGame() {
  gameOver.value = true
  clearInterval(timerId); cancelAnimationFrame(animId); clearInterval(spawnId)
  if (score.value > best.value) { best.value = score.value; uni.setStorageSync('best_balloon', best.value) }
}

function goBack() { uni.navigateBack() }

onMounted(() => { best.value = uni.getStorageSync('best_balloon') || 0; newGame() })
onUnmounted(() => { clearInterval(timerId); cancelAnimationFrame(animId); clearInterval(spawnId) })
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: linear-gradient(180deg, #0f0c29, #302b63); display: flex; flex-direction: column; align-items: center; padding: 20rpx; position: relative; }
.header { width: 100%; max-width: 700rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 10rpx; }
.back-btn { font-size: 48rpx; color: #fff; font-weight: 700; padding: 0 16rpx; }
.title { font-size: 44rpx; font-weight: bold; color: #e94560; }
.info { display: flex; gap: 12rpx; }
.info-text { font-size: 22rpx; color: #dfe6e9; background: rgba(255,255,255,0.1); padding: 6rpx 14rpx; border-radius: 16rpx; }
.game-area { width: 690rpx; height: 900rpx; background: linear-gradient(180deg, #0f0c29, #302b63, #24243e); border-radius: 20rpx; position: relative; overflow: hidden; }
.balloon { position: absolute; z-index: 3; transition: opacity 0.2s; }
.balloon-emoji { font-size: 60rpx; }
.effect { position: absolute; font-size: 30rpx; font-weight: bold; z-index: 5; pointer-events: none; }
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; }
.overlay-msg { font-size: 56rpx; color: #fff; font-weight: bold; margin-bottom: 16rpx; display: block; }
.overlay-score { font-size: 36rpx; color: #e94560; margin-bottom: 10rpx; display: block; }
.overlay-best { font-size: 32rpx; color: #50e3c2; margin-bottom: 24rpx; display: block; }
.btn { background: #e94560; padding: 16rpx 48rpx; border-radius: 30rpx; display: inline-block; }
.btn-text { font-size: 28rpx; color: #fff; }
</style>