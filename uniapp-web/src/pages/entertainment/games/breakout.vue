<template>
  <view class="game-container">
    <view class="header">
      <text class="title">打砖块</text>
      <view class="info">
        <text class="info-text">分数: {{ score }}</text>
        <text class="info-text">生命: {{ lives }}</text>
        <text class="info-text">关卡: {{ level }}</text>
      </view>
    </view>
    <view class="controls">
      <view class="btn" @tap="newGame"><text class="btn-text">新游戏</text></view>
      <view class="btn" @tap="togglePause"><text class="btn-text">{{ paused ? '继续' : '暂停' }}</text></view>
    </view>
    <view class="game-area" @touchstart="onTouch" @touchmove="onMove" @tap="startGame">
      <!-- 砖块区域 -->
      <view class="bricks-area">
        <view class="brick-row" v-for="(row, ri) in bricks" :key="ri">
          <view
            :class="['brick', 'brick-color-' + (bi % 5)]"
            v-for="(brick, bi) in row"
            :key="bi"
            v-show="brick.alive"
            :style="{ opacity: brick.hits > 1 ? '0.8' : '1' }"
          ></view>
        </view>
      </view>
      <!-- 球 -->
      <view class="ball" :style="{ left: ball.x + 'rpx', top: ball.y + 'rpx' }"></view>
      <!-- 挡板 -->
      <view class="paddle" :style="{ left: paddle.x + 'rpx', width: paddle.w + 'rpx' }"></view>
    </view>
    <view class="hint" v-if="!started && !gameOver">
      <text class="hint-text">点击屏幕开始游戏</text>
    </view>
    <view class="overlay" v-if="gameOver">
      <view class="overlay-content">
        <text class="overlay-msg">{{ resultMsg }}</text>
        <text class="overlay-sub">得分：{{ score }}</text>
        <view class="btn" @tap="newGame"><text class="btn-text">再来一局</text></view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const AREA_W = 690, AREA_H = 900
const BRICK_COLS = 10, BRICK_W = 60, BRICK_H = 28, BRICK_GAP = 6, BRICK_TOP = 40
const PADDLE_H = 16, BALL_R = 12

interface Brick { alive: boolean; hits: number }
interface BallType { x: number; y: number; dx: number; dy: number }
interface PaddleType { x: number; w: number }

const score = ref(0)
const lives = ref(3)
const level = ref(1)
const paused = ref(false)
const started = ref(false)
const gameOver = ref(false)
const resultMsg = ref('')

const ball = ref<BallType>({ x: AREA_W / 2, y: AREA_H - 80, dx: 0, dy: 0 })
const paddle = ref<PaddleType>({ x: AREA_W / 2 - 60, w: 120 })
const bricks = ref<Brick[][]>([])

let animId: any = null

function newGame() {
  score.value = 0; lives.value = 3; level.value = 1
  paused.value = false; started.value = false; gameOver.value = false
  resultMsg.value = ''
  cancelAnimationFrame(animId)
  initLevel()
}

function initLevel() {
  paddle.value = { x: AREA_W / 2 - 60, w: 120 }
  const spd = 5 + level.value
  ball.value = { x: AREA_W / 2, y: AREA_H - 80, dx: spd * (Math.random() > 0.5 ? 1 : -1), dy: -spd }
  started.value = false
  const rows = Math.min(3 + Math.floor(level.value / 2), 6)
  bricks.value = []
  for (let r = 0; r < rows; r++) {
    const row: Brick[] = []
    for (let c = 0; c < BRICK_COLS; c++) {
      row.push({ alive: true, hits: level.value > 2 && r < 2 ? 2 : 1 })
    }
    bricks.value.push(row)
  }
}

function startGame() {
  if (started.value || gameOver.value) return
  started.value = true
  gameLoop()
}

function gameLoop() {
  if (!paused.value && started.value) update()
  animId = requestAnimationFrame(gameLoop)
}

function update() {
  const b = ball.value
  b.x += b.dx; b.y += b.dy
  if (b.x - BALL_R < 0 || b.x + BALL_R > AREA_W) b.dx = -b.dx
  if (b.y - BALL_R < 0) b.dy = -b.dy
  const p = paddle.value
  if (b.y + BALL_R >= AREA_H - 40 && b.y + BALL_R <= AREA_H - 40 + PADDLE_H && b.x >= p.x && b.x <= p.x + p.w) {
    b.dy = -Math.abs(b.dy)
    b.dx = 8 * ((b.x - p.x) / p.w - 0.5)
  }
  bricks.value.forEach((row, ri) => {
    row.forEach((brick, ci) => {
      if (!brick.alive) return
      const bx = ci * (BRICK_W + BRICK_GAP) + 15
      const by = ri * (BRICK_H + BRICK_GAP) + BRICK_TOP
      if (b.x + BALL_R > bx && b.x - BALL_R < bx + BRICK_W && b.y + BALL_R > by && b.y - BALL_R < by + BRICK_H) {
        b.dy = -b.dy
        brick.hits--
        if (brick.hits <= 0) { brick.alive = false; score.value += 10 * level.value }
      }
    })
  })
  if (b.y + BALL_R > AREA_H) {
    lives.value--
    if (lives.value <= 0) {
      cancelAnimationFrame(animId); gameOver.value = true; resultMsg.value = '游戏结束！'; return
    }
    ball.value = { x: AREA_W / 2, y: AREA_H - 80, dx: 5, dy: -5 }
    started.value = false
  }
  if (bricks.value.every(row => row.every(b => !b.alive))) {
    level.value++; initLevel()
  }
}

function onTouch(e: any) {
  const x = e.touches[0].clientX - 30
  paddle.value.x = Math.max(0, Math.min(AREA_W - paddle.value.w, x / 2 * 3))
}
function onMove(e: any) {
  const x = e.touches[0].clientX - 30
  paddle.value.x = Math.max(0, Math.min(AREA_W - paddle.value.w, x / 2 * 3))
}

function togglePause() { paused.value = !paused.value }

onMounted(() => { newGame() })
onUnmounted(() => { cancelAnimationFrame(animId) })
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: #1a1a2e; display: flex; flex-direction: column; align-items: center; padding: 20rpx; position: relative; }
.header { width: 100%; max-width: 700rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.title { font-size: 52rpx; font-weight: bold; color: #e94560; }
.info { display: flex; gap: 16rpx; }
.info-text { font-size: 24rpx; color: #dfe6e9; background: rgba(255,255,255,0.1); padding: 8rpx 16rpx; border-radius: 16rpx; }
.controls { display: flex; gap: 16rpx; margin-bottom: 16rpx; }
.btn { background: #e94560; color: #fff; padding: 12rpx 28rpx; border-radius: 10rpx; text-align: center; }
.btn-text { font-size: 26rpx; color: #fff; }
.game-area { width: 690rpx; height: 900rpx; background: #16213e; border-radius: 16rpx; position: relative; overflow: hidden; }
.bricks-area { padding: 15rpx; }
.brick-row { display: flex; gap: 6rpx; margin-bottom: 6rpx; justify-content: center; }
.brick { width: 60rpx; height: 28rpx; border-radius: 4rpx; }
.brick-color-0 { background: #e94560; } .brick-color-1 { background: #f5a623; }
.brick-color-2 { background: #50e3c2; } .brick-color-3 { background: #4a90d9; }
.brick-color-4 { background: #bd10e0; }
.ball { width: 24rpx; height: 24rpx; border-radius: 50%; background: #fff; position: absolute; box-shadow: 0 0 12rpx #50e3c2; }
.paddle { height: 16rpx; border-radius: 8rpx; background: #50e3c2; position: absolute; bottom: 30rpx; }
.hint { position: absolute; bottom: 100rpx; left: 50%; transform: translateX(-50%); }
.hint-text { font-size: 28rpx; color: rgba(255,255,255,0.6); }
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; }
.overlay-msg { font-size: 56rpx; color: #fff; font-weight: bold; margin-bottom: 16rpx; display: block; }
.overlay-sub { font-size: 32rpx; color: #eee; margin-bottom: 30rpx; display: block; }
</style>