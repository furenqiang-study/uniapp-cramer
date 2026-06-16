<template>
  <view class="game-container">
    <view class="header">
      <text class="title">扫雷</text>
      <view class="info">
        <text class="info-text">💣 {{ flagCount }}/{{ mineCount }}</text>
        <text class="info-text">⏱ {{ seconds }}s</text>
      </view>
    </view>
    <view class="controls">
      <view class="btn" @tap="newGame"><text class="btn-text">新游戏</text></view>
    </view>
    <view class="board">
      <view class="row" v-for="(row, r) in cells" :key="r">
        <view
          :class="['cell', cell.revealed ? (cell.mine ? 'mine' : 'revealed') : (cell.flagged ? 'flagged' : 'hidden')]"
          v-for="(cell, c) in row"
          :key="c"
          @tap="revealCell(r, c)"
          @longpress.prevent="toggleFlag(r, c)"
        >
          <text v-if="cell.revealed && cell.mine" class="cell-emoji">💣</text>
          <text v-else-if="cell.revealed && cell.adjacent > 0" :class="['cell-num', 'num-' + cell.adjacent]">{{ cell.adjacent }}</text>
          <text v-else-if="cell.flagged" class="cell-emoji">🚩</text>
        </view>
      </view>
    </view>
    <view class="overlay" v-if="gameOver">
      <view class="overlay-content">
        <text class="overlay-msg">{{ resultMsg }}</text>
        <text class="overlay-sub">用时：{{ seconds }}秒</text>
        <view class="btn" @tap="newGame"><text class="btn-text">再来一局</text></view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'

interface Cell { mine: boolean; revealed: boolean; flagged: boolean; adjacent: number }

const ROWS = 9, COLS = 9, MINE_COUNT = 10
const mineCount = ref(MINE_COUNT)
const cells = ref<Cell[][]>([])
const gameOver = ref(false)
const resultMsg = ref('')
const seconds = ref(0)
let timerId: any = null
let firstClick = true

const flagCount = computed(() => {
  let cnt = 0
  cells.value.forEach(row => row.forEach(c => { if (c.flagged) cnt++ }))
  return cnt
})

function newGame() {
  cells.value = Array(ROWS).fill(null).map(() =>
    Array(COLS).fill(null).map(() => ({ mine: false, revealed: false, flagged: false, adjacent: 0 }))
  )
  gameOver.value = false
  resultMsg.value = ''
  seconds.value = 0
  firstClick = true
  clearInterval(timerId)
  timerId = null
}

function placeMines(sr: number, sc: number) {
  let placed = 0
  while (placed < MINE_COUNT) {
    const r = Math.floor(Math.random() * ROWS)
    const c = Math.floor(Math.random() * COLS)
    if (cells.value[r][c].mine || (Math.abs(r - sr) <= 1 && Math.abs(c - sc) <= 1)) continue
    cells.value[r][c].mine = true
    placed++
  }
  for (let r = 0; r < ROWS; r++)
    for (let c = 0; c < COLS; c++) {
      if (cells.value[r][c].mine) continue
      let cnt = 0
      for (let dr = -1; dr <= 1; dr++)
        for (let dc = -1; dc <= 1; dc++) {
          const nr = r + dr, nc = c + dc
          if (nr >= 0 && nr < ROWS && nc >= 0 && nc < COLS && cells.value[nr][nc].mine) cnt++
        }
      cells.value[r][c].adjacent = cnt
    }
}

function revealCell(r: number, c: number) {
  if (gameOver.value || cells.value[r][c].revealed || cells.value[r][c].flagged) return
  if (firstClick) {
    firstClick = false
    placeMines(r, c)
    timerId = setInterval(() => seconds.value++, 1000)
  }
  if (cells.value[r][c].mine) {
    gameOver.value = true
    clearInterval(timerId)
    revealAll()
    resultMsg.value = '💥 游戏结束！'
    return
  }
  reveal(r, c)
  checkWin()
}

function reveal(r: number, c: number) {
  if (r < 0 || r >= ROWS || c < 0 || c >= COLS) return
  const cell = cells.value[r][c]
  if (cell.revealed || cell.flagged) return
  cell.revealed = true
  if (cell.adjacent === 0 && !cell.mine) {
    for (let dr = -1; dr <= 1; dr++)
      for (let dc = -1; dc <= 1; dc++) reveal(r + dr, c + dc)
  }
}

function revealAll() {
  cells.value.forEach(row => row.forEach(c => { c.revealed = true }))
}

function toggleFlag(r: number, c: number) {
  if (gameOver.value || cells.value[r][c].revealed) return
  cells.value[r][c].flagged = !cells.value[r][c].flagged
}

function checkWin() {
  let unrevealed = 0
  cells.value.forEach(row => row.forEach(c => { if (!c.revealed) unrevealed++ }))
  if (unrevealed === MINE_COUNT) {
    gameOver.value = true
    clearInterval(timerId)
    resultMsg.value = '🎉 恭喜通关！'
  }
}

onMounted(() => { newGame() })
onUnmounted(() => { clearInterval(timerId) })
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: #2d3436; display: flex; flex-direction: column; align-items: center; padding: 20rpx; position: relative; }
.header { width: 100%; max-width: 600rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.title { font-size: 52rpx; font-weight: bold; color: #dfe6e9; }
.info { display: flex; gap: 20rpx; }
.info-text { font-size: 28rpx; color: #dfe6e9; background: rgba(255,255,255,0.1); padding: 8rpx 20rpx; border-radius: 20rpx; }
.controls { display: flex; gap: 16rpx; margin-bottom: 16rpx; }
.btn { background: #636e72; color: #fff; padding: 12rpx 28rpx; border-radius: 10rpx; text-align: center; }
.btn-text { font-size: 26rpx; color: #fff; }
.board { background: #636e72; border-radius: 8rpx; padding: 6rpx; display: flex; flex-direction: column; gap: 3rpx; }
.row { display: flex; gap: 3rpx; }
.cell { width: 60rpx; height: 60rpx; display: flex; align-items: center; justify-content: center; border-radius: 4rpx; }
.cell.hidden { background: #b2bec3; }
.cell.revealed { background: #dfe6e9; }
.cell.mine { background: #d63031; }
.cell.flagged { background: #fdcb6e; }
.cell-emoji { font-size: 28rpx; }
.cell-num { font-size: 26rpx; font-weight: bold; }
.num-1 { color: #0984e3; } .num-2 { color: #00b894; } .num-3 { color: #d63031; }
.num-4 { color: #6c5ce7; } .num-5 { color: #e17055; } .num-6 { color: #00cec9; }
.num-7 { color: #fdcb6e; } .num-8 { color: #636e72; }
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; }
.overlay-msg { font-size: 56rpx; color: #fff; font-weight: bold; margin-bottom: 16rpx; display: block; }
.overlay-sub { font-size: 32rpx; color: #eee; margin-bottom: 30rpx; display: block; }
</style>