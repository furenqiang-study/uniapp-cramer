<template>
  <view class="game-container">
    <view class="header">
      <text class="back-btn" @tap="goBack">‹</text>
      <text class="title">飞鸟穿越</text>
      <view class="info">
        <text class="info-text">分数: {{ score }}</text>
        <text class="info-text">🏆 {{ best }}</text>
      </view>
    </view>
    <view class="game-area" @tap="flap">
      <view class="bird" :style="{ top: birdY + 'rpx', transform: 'rotate(' + rotation + 'deg)' }">
        <text class="bird-emoji">🐦</text>
      </view>
      <view v-for="(pipe, i) in pipes" :key="i">
        <view class="pipe pipe-top" :style="{ left: pipe.x + 'rpx', height: pipe.topH + 'rpx' }"></view>
        <view class="pipe pipe-bottom" :style="{ left: pipe.x + 'rpx', top: (pipe.topH + GAP) + 'rpx' }"></view>
      </view>
      <view class="score-display" v-if="!started && !gameOver">
        <text class="tap-hint">点击屏幕开始</text>
      </view>
    </view>
    <view class="overlay" v-if="gameOver">
      <view class="overlay-content">
        <text class="overlay-msg">💥 游戏结束</text>
        <text class="overlay-score">得分：{{ score }}</text>
        <text class="overlay-best" v-if="score >= best && score > 0">🎉 新纪录！</text>
        <view class="btn" @tap="newGame"><text class="btn-text">再来一局</text></view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

interface Pipe { x: number; topH: number; scored: boolean }

const AREA_W = 690, AREA_H = 900
const BIRD_X = 120, BIRD_R = 20
const PIPE_W = 70, GAP = 200
const GRAVITY = 0.6, FLAP_POWER = -9

const score = ref(0)
const best = ref(0)
const gameOver = ref(false)
const started = ref(false)
const birdY = ref(400)
const rotation = ref(0)
const pipes = ref<Pipe[]>([])

let vy = 0
let animId: any = null
let pipeTimer: any = null

function newGame() {
  score.value = 0; gameOver.value = false; started.value = false
  birdY.value = 400; vy = 0; rotation.value = 0
  pipes.value = []
  cancelAnimationFrame(animId); clearInterval(pipeTimer)
}

function flap() {
  if (gameOver.value) return
  if (!started.value) {
    started.value = true
    vy = FLAP_POWER
    pipeTimer = setInterval(spawnPipe, 1800)
    gameLoop()
    return
  }
  vy = FLAP_POWER
}

function spawnPipe() {
  const topH = 80 + Math.random() * (AREA_H - GAP - 200)
  pipes.value.push({ x: AREA_W, topH, scored: false })
}

function gameLoop() {
  if (gameOver.value) return
  update()
  animId = requestAnimationFrame(gameLoop)
}

function update() {
  vy += GRAVITY
  birdY.value += vy
  rotation.value = Math.min(70, Math.max(-30, vy * 4))

  pipes.value.forEach(pipe => { pipe.x -= 4 })

  // check collision
  const by = birdY.value
  if (by < 0 || by + 40 > AREA_H) { endGame(); return }
  for (const pipe of pipes.value) {
    if (BIRD_X + BIRD_R > pipe.x && BIRD_X - BIRD_R < pipe.x + PIPE_W) {
      if (by < pipe.topH || by + 40 > pipe.topH + GAP) { endGame(); return }
    }
    if (!pipe.scored && pipe.x + PIPE_W < BIRD_X) { pipe.scored = true; score.value++ }
  }
  pipes.value = pipes.value.filter(p => p.x + PIPE_W > -20)
}

function endGame() {
  gameOver.value = true; started.value = false
  cancelAnimationFrame(animId); clearInterval(pipeTimer)
  if (score.value > best.value) { best.value = score.value; uni.setStorageSync('best_flappy', best.value) }
}

function goBack() { uni.navigateBack() }

onMounted(() => { best.value = uni.getStorageSync('best_flappy') || 0; newGame() })
onUnmounted(() => { cancelAnimationFrame(animId); clearInterval(pipeTimer) })
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: linear-gradient(180deg, #70c5ce, #4ec0ca); display: flex; flex-direction: column; align-items: center; padding: 20rpx; position: relative; }
.header { width: 100%; max-width: 700rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 10rpx; }
.back-btn { font-size: 48rpx; color: #fff; font-weight: 700; padding: 0 16rpx; }
.title { font-size: 44rpx; font-weight: bold; color: #fff; text-shadow: 0 2rpx 4rpx rgba(0,0,0,0.3); }
.info { display: flex; gap: 12rpx; }
.info-text { font-size: 24rpx; color: #fff; background: rgba(0,0,0,0.2); padding: 6rpx 14rpx; border-radius: 16rpx; }
.game-area { width: 690rpx; height: 900rpx; background: linear-gradient(180deg, #70c5ce 0%, #87ceeb 60%, #deb887 60%, #deb887 100%); border-radius: 20rpx; position: relative; overflow: hidden; }
.bird { position: absolute; left: 120rpx; z-index: 5; transition: transform 0.05s; }
.bird-emoji { font-size: 56rpx; }
.pipe { position: absolute; width: 70rpx; background: linear-gradient(90deg, #5cb85c, #4cae4c); border: 4rpx solid #3d8b3d; border-radius: 8rpx; z-index: 3; }
.pipe-top { top: 0; }
.pipe-bottom { bottom: 0; }
.score-display { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 10; }
.tap-hint { font-size: 36rpx; color: #fff; font-weight: bold; text-shadow: 0 2rpx 4rpx rgba(0,0,0,0.3); }
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; }
.overlay-msg { font-size: 56rpx; color: #fff; font-weight: bold; margin-bottom: 16rpx; display: block; }
.overlay-score { font-size: 36rpx; color: #f5a623; margin-bottom: 10rpx; display: block; }
.overlay-best { font-size: 32rpx; color: #50e3c2; margin-bottom: 24rpx; display: block; }
.btn { background: #50e3c2; padding: 16rpx 48rpx; border-radius: 30rpx; display: inline-block; }
.btn-text { font-size: 28rpx; color: #fff; }
</style>