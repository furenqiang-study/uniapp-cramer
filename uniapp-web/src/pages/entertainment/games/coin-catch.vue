<template>
  <view class="game-container">
    <view class="header">
      <text class="back-btn" @tap="goBack">‹</text>
      <text class="title">接金币</text>
      <view class="info">
        <text class="info-text">⏱ {{ timeLeft }}s</text>
        <text class="info-text">💰 {{ score }}</text>
        <text class="info-text">🏆 {{ best }}</text>
      </view>
    </view>
    <view class="game-area" @touchstart="onTouch" @touchmove="onTouch">
      <view v-for="(item, i) in items" :key="i"
        class="falling-item"
        :style="{ left: item.x + 'rpx', top: item.y + 'rpx', fontSize: item.type === 'bomb' ? '48rpx' : '44rpx' }"
      >
        {{ item.type === 'coin' ? '🪙' : item.type === 'diamond' ? '💎' : '💣' }}
      </view>
      <view class="tray" :style="{ left: trayX + 'rpx' }">
        <text class="tray-emoji">🧺</text>
      </view>
      <view v-for="(eff, i) in effects" :key="'e' + i" class="effect"
        :style="{ left: eff.x + 'rpx', top: eff.y + 'rpx', color: eff.color }">
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

interface FallingItem { x: number; y: number; type: 'coin' | 'diamond' | 'bomb'; speed: number }
interface Effect { x: number; y: number; text: string; color: string }

const AREA_W = 690
const TRAY_W = 120
const GAME_TIME = 60

const score = ref(0)
const best = ref(0)
const timeLeft = ref(GAME_TIME)
const gameOver = ref(false)
const items = ref<FallingItem[]>([])
const effects = ref<Effect[]>([])
const trayX = ref(AREA_W / 2 - TRAY_W / 2)

let timerId: any = null
let animId: any = null
let spawnId: any = null

function newGame() {
  score.value = 0
  timeLeft.value = GAME_TIME
  gameOver.value = false
  items.value = []
  effects.value = []
  trayX.value = AREA_W / 2 - TRAY_W / 2
  clearInterval(timerId)
  cancelAnimationFrame(animId)
  clearInterval(spawnId)

  timerId = setInterval(() => {
    timeLeft.value--
    if (timeLeft.value <= 0) {
      endGame()
    }
  }, 1000)

  spawnId = setInterval(spawnItem, 600)
  gameLoop()
}

function spawnItem() {
  const r = Math.random()
  const type = r < 0.6 ? 'coin' : r < 0.85 ? 'diamond' : 'bomb'
  const baseSpeed = 3 + Math.floor((GAME_TIME - timeLeft.value) / 10)
  items.value.push({
    x: Math.random() * (AREA_W - 60) + 10,
    y: -50,
    type,
    speed: baseSpeed + Math.random() * 2,
  })
}

function gameLoop() {
  if (gameOver.value) return
  update()
  animId = requestAnimationFrame(gameLoop)
}

function update() {
  const TRAY_Y = 800
  items.value = items.value.filter(item => {
    item.y += item.speed
    if (item.y + 50 >= TRAY_Y && item.y <= TRAY_Y + 40 &&
        item.x + 40 >= trayX.value && item.x <= trayX.value + TRAY_W) {
      if (item.type === 'coin') {
        score.value += 10
        addEffect(item.x, TRAY_Y, '+10', '#f5a623')
      } else if (item.type === 'diamond') {
        score.value += 30
        addEffect(item.x, TRAY_Y, '+30', '#50e3c2')
      } else {
        score.value = Math.max(0, score.value - 20)
        addEffect(item.x, TRAY_Y, '-20', '#e94560')
      }
      return false
    }
    return item.y < 950
  })
  effects.value = effects.value.filter(e => {
    e.y -= 1
    return e.y > 0
  })
}

function addEffect(x: number, y: number, text: string, color: string) {
  effects.value.push({ x, y, text, color })
  setTimeout(() => { effects.value.shift() }, 800)
}

function onTouch(e: any) {
  const touch = e.touches[0]
  const containerLeft = (touch.clientX - 30) * (AREA_W / 330)
  trayX.value = Math.max(0, Math.min(AREA_W - TRAY_W, containerLeft - TRAY_W / 2))
}

function endGame() {
  gameOver.value = true
  clearInterval(timerId)
  cancelAnimationFrame(animId)
  clearInterval(spawnId)
  if (score.value > best.value) {
    best.value = score.value
    uni.setStorageSync('best_coin_catch', best.value)
  }
}

function goBack() { uni.navigateBack() }

onMounted(() => { best.value = uni.getStorageSync('best_coin_catch') || 0; newGame() })
onUnmounted(() => { clearInterval(timerId); cancelAnimationFrame(animId); clearInterval(spawnId) })
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: linear-gradient(180deg, #1a1a2e, #16213e); display: flex; flex-direction: column; align-items: center; padding: 20rpx; position: relative; }
.header { width: 100%; max-width: 700rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 10rpx; }
.back-btn { font-size: 48rpx; color: #fff; font-weight: 700; padding: 0 16rpx; }
.title { font-size: 44rpx; font-weight: bold; color: #f5a623; }
.info { display: flex; gap: 12rpx; }
.info-text { font-size: 24rpx; color: #dfe6e9; background: rgba(255,255,255,0.1); padding: 6rpx 14rpx; border-radius: 16rpx; }
.game-area { width: 690rpx; height: 900rpx; background: rgba(255,255,255,0.05); border-radius: 20rpx; position: relative; overflow: hidden; }
.falling-item { position: absolute; z-index: 2; }
.tray { position: absolute; bottom: 60rpx; z-index: 3; }
.tray-emoji { font-size: 64rpx; }
.effect { position: absolute; font-size: 28rpx; font-weight: bold; z-index: 5; pointer-events: none; }
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; }
.overlay-msg { font-size: 56rpx; color: #fff; font-weight: bold; margin-bottom: 16rpx; display: block; }
.overlay-score { font-size: 36rpx; color: #f5a623; margin-bottom: 10rpx; display: block; }
.overlay-best { font-size: 32rpx; color: #50e3c2; margin-bottom: 24rpx; display: block; }
.btn { background: #f5a623; padding: 16rpx 48rpx; border-radius: 30rpx; display: inline-block; }
.btn-text { font-size: 28rpx; color: #fff; }
</style>