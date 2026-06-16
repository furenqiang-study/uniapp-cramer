<template>
  <view class="game-container">
    <view class="header">
      <text class="back-btn" @tap="goBack">‹</text>
      <text class="title">贪吃蛇</text>
      <view class="info">
        <text class="info-text">分数: {{ score }}</text>
        <text class="info-text">🏆 {{ best }}</text>
      </view>
    </view>
    <view class="controls">
      <view :class="['diff-btn', difficulty === 1 ? 'active' : '']" @tap="setDiff(1)"><text>慢速</text></view>
      <view :class="['diff-btn', difficulty === 2 ? 'active' : '']" @tap="setDiff(2)"><text>中速</text></view>
      <view :class="['diff-btn', difficulty === 3 ? 'active' : '']" @tap="setDiff(3)"><text>快速</text></view>
      <view class="ctrl-btn" @tap="togglePause"><text>{{ paused ? '继续' : '暂停' }}</text></view>
      <view class="ctrl-btn" @tap="newGame"><text>重开</text></view>
    </view>
    <view class="board">
      <view class="row" v-for="(row, r) in display" :key="r">
        <view :class="['cell', cell]" v-for="(cell, c) in row" :key="c"></view>
      </view>
    </view>
    <view class="dpad">
      <view class="dpad-row"><view class="dpad-btn" @tap="changeDir('up')">▲</view></view>
      <view class="dpad-row">
        <view class="dpad-btn" @tap="changeDir('left')">◀</view>
        <view class="dpad-btn" @tap="changeDir('down')">▼</view>
        <view class="dpad-btn" @tap="changeDir('right')">▶</view>
      </view>
    </view>
    <view class="overlay" v-if="gameOver">
      <view class="overlay-content">
        <text class="overlay-msg">💀 游戏结束</text>
        <text class="overlay-score">得分：{{ score }}</text>
        <view class="btn" @tap="newGame"><text class="btn-text">再来一局</text></view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'

const ROWS = 20, COLS = 20
type Dir = 'up' | 'down' | 'left' | 'right'

const score = ref(0)
const best = ref(0)
const difficulty = ref(2)
const paused = ref(false)
const gameOver = ref(false)

let snake: [number, number][] = []
let food: [number, number] = [0, 0]
let dir: Dir = 'right'
let nextDir: Dir = 'right'
let timerId: any = null

const display = ref<string[][]>([])

function newGame() {
  score.value = 0
  gameOver.value = false
  paused.value = false
  snake = [[10, 10], [10, 9], [10, 8]]
  dir = 'right'; nextDir = 'right'
  placeFood()
  render()
  clearInterval(timerId)
  const speeds = [200, 120, 70]
  timerId = setInterval(tick, speeds[difficulty.value - 1])
}

function setDiff(d: number) { difficulty.value = d; newGame() }

function togglePause() { paused.value = !paused.value }

function placeFood() {
  const occupied = new Set(snake.map(([r, c]) => `${r},${c}`))
  let r, c; do { r = Math.floor(Math.random() * ROWS); c = Math.floor(Math.random() * COLS) } while (occupied.has(`${r},${c}`))
  food = [r, c]
}

function changeDir(d: Dir) {
  const opposites: Record<Dir, Dir> = { up: 'down', down: 'up', left: 'right', right: 'left' }
  if (d !== opposites[dir]) nextDir = d
}

function tick() {
  if (paused.value || gameOver.value) return
  dir = nextDir
  const [hr, hc] = snake[0]
  const moves: Record<Dir, [number, number]> = { up: [-1, 0], down: [1, 0], left: [0, -1], right: [0, 1] }
  const [dr, dc] = moves[dir]
  const nr = hr + dr, nc = hc + dc
  if (nr < 0 || nr >= ROWS || nc < 0 || nc >= COLS || snake.some(([r, c]) => r === nr && c === nc)) {
    gameOver.value = true
    clearInterval(timerId)
    if (score.value > best.value) { best.value = score.value; uni.setStorageSync('best_snake', best.value) }
    return
  }
  snake.unshift([nr, nc])
  if (nr === food[0] && nc === food[1]) { score.value += 10; placeFood() }
  else snake.pop()
  render()
}

function render() {
  const grid: string[][] = Array(ROWS).fill(null).map(() => Array(COLS).fill('cell-empty'))
  snake.forEach(([r, c], i) => { grid[r][c] = i === 0 ? 'cell-head' : 'cell-body' })
  grid[food[0]][food[1]] = 'cell-food'
  display.value = grid
}

function goBack() { uni.navigateBack() }

onMounted(() => { best.value = uni.getStorageSync('best_snake') || 0; newGame() })
onUnmounted(() => { clearInterval(timerId) })
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: #1a1a2e; display: flex; flex-direction: column; align-items: center; padding: 20rpx; position: relative; }
.header { width: 100%; max-width: 620rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 12rpx; }
.back-btn { font-size: 48rpx; color: #fff; font-weight: 700; padding: 0 16rpx; }
.title { font-size: 44rpx; font-weight: bold; color: #50e3c2; }
.info { display: flex; gap: 12rpx; }
.info-text { font-size: 24rpx; color: #dfe6e9; background: rgba(255,255,255,0.1); padding: 6rpx 14rpx; border-radius: 16rpx; }
.controls { display: flex; gap: 10rpx; margin-bottom: 12rpx; width: 100%; max-width: 620rpx; justify-content: center; }
.diff-btn { background: rgba(255,255,255,0.1); padding: 8rpx 20rpx; border-radius: 20rpx; color: #aaa; font-size: 22rpx; &.active { background: #50e3c2; color: #1a1a2e; } }
.ctrl-btn { background: rgba(255,255,255,0.1); padding: 8rpx 20rpx; border-radius: 20rpx; color: #aaa; font-size: 22rpx; }
.board { display: flex; flex-direction: column; gap: 2rpx; background: #0a0a1a; border-radius: 10rpx; padding: 6rpx; }
.row { display: flex; gap: 2rpx; }
.cell { width: 30rpx; height: 30rpx; border-radius: 4rpx; background: #16213e; }
.cell-empty { background: #16213e; }
.cell-head { background: #50e3c2; border-radius: 6rpx; }
.cell-body { background: #3ba89f; }
.cell-food { background: #e94560; border-radius: 50%; }
.dpad { margin-top: 24rpx; display: flex; flex-direction: column; align-items: center; gap: 8rpx; }
.dpad-row { display: flex; gap: 8rpx; }
.dpad-btn { width: 80rpx; height: 80rpx; background: rgba(255,255,255,0.15); border-radius: 16rpx; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 32rpx; }
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; }
.overlay-msg { font-size: 56rpx; color: #fff; font-weight: bold; margin-bottom: 16rpx; display: block; }
.overlay-score { font-size: 36rpx; color: #50e3c2; margin-bottom: 24rpx; display: block; }
.btn { background: #50e3c2; padding: 16rpx 48rpx; border-radius: 30rpx; display: inline-block; }
.btn-text { font-size: 28rpx; color: #1a1a2e; font-weight: bold; }
</style>