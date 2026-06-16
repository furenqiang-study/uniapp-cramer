<template>
  <view class="game-container">
    <view class="header">
      <text class="title">消消乐</text>
      <view class="scores">
        <view class="score-box"><text class="score-text">分数: {{ score }}</text></view>
        <view class="score-box"><text class="score-text">步数: {{ moves }}</text></view>
      </view>
    </view>
    <view class="controls">
      <view class="btn" @tap="newGame"><text class="btn-text">新游戏</text></view>
      <view class="btn" @tap="useHint"><text class="btn-text">💡 提示</text></view>
    </view>
    <view class="board">
      <view class="row" v-for="(row, r) in grid" :key="r">
        <view
          class="cell"
          :class="{ selected: selected && selected[0] === r && selected[1] === c }"
          v-for="(cell, c) in row"
          :key="c"
          @tap="cellClick(r, c)"
        >
          <text class="emoji">{{ cell }}</text>
        </view>
      </view>
    </view>
    <view class="overlay" v-if="gameOver">
      <view class="overlay-content">
        <text class="overlay-msg">游戏结束！</text>
        <text class="overlay-score">得分：{{ score }}</text>
        <view class="btn" @tap="newGame"><text class="btn-text">再来一局</text></view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

const ROWS = 8, COLS = 8
const TYPES = ['🍎', '🍊', '🍋', '🍇', '🍓', '🫐']
const grid = ref<string[][]>([])
const selected = ref<[number, number] | null>(null)
const score = ref(0)
const moves = ref(30)
const gameOver = ref(false)
let animating = false

function newGame() {
  score.value = 0
  moves.value = 30
  selected.value = null
  animating = false
  gameOver.value = false
  do {
    grid.value = Array(ROWS).fill(null).map(() =>
      Array(COLS).fill(null).map(() => TYPES[Math.floor(Math.random() * TYPES.length)])
    )
  } while (hasMatches())
}

function cellClick(r: number, c: number) {
  if (animating || gameOver.value) return
  if (!selected.value) {
    selected.value = [r, c]
    return
  }
  const [sr, sc] = selected.value
  if (sr === r && sc === c) { selected.value = null; return }
  if (Math.abs(sr - r) + Math.abs(sc - c) !== 1) { selected.value = [r, c]; return }
  swap(sr, sc, r, c)
  selected.value = null
  if (hasMatches()) {
    moves.value--
    processMatches()
  } else {
    swap(sr, sc, r, c)
  }
}

function swap(r1: number, c1: number, r2: number, c2: number) {
  const t = grid.value[r1][c1]
  grid.value[r1][c1] = grid.value[r2][c2]
  grid.value[r2][c2] = t
}

function hasMatches(): boolean {
  for (let r = 0; r < ROWS; r++)
    for (let c = 0; c < COLS - 2; c++)
      if (grid.value[r][c] && grid.value[r][c] === grid.value[r][c + 1] && grid.value[r][c] === grid.value[r][c + 2]) return true
  for (let c = 0; c < COLS; c++)
    for (let r = 0; r < ROWS - 2; r++)
      if (grid.value[r][c] && grid.value[r][c] === grid.value[r + 1][c] && grid.value[r][c] === grid.value[r + 2][c]) return true
  return false
}

function findMatches(): [number, number][] {
  const matched = new Set<string>()
  for (let r = 0; r < ROWS; r++)
    for (let c = 0; c < COLS - 2; c++)
      if (grid.value[r][c] && grid.value[r][c] === grid.value[r][c + 1] && grid.value[r][c] === grid.value[r][c + 2]) {
        matched.add(`${r},${c}`); matched.add(`${r},${c + 1}`); matched.add(`${r},${c + 2}`)
      }
  for (let c = 0; c < COLS; c++)
    for (let r = 0; r < ROWS - 2; r++)
      if (grid.value[r][c] && grid.value[r][c] === grid.value[r + 1][c] && grid.value[r][c] === grid.value[r + 2][c]) {
        matched.add(`${r},${c}`); matched.add(`${r + 1},${c}`); matched.add(`${r + 2},${c}`)
      }
  return [...matched].map(k => k.split(',').map(Number) as [number, number])
}

function processMatches() {
  animating = true
  const matches = findMatches()
  if (!matches.length) {
    animating = false
    if (moves.value <= 0) { gameOver.value = true }
    return
  }
  score.value += matches.length * 10
  matches.forEach(([r, c]) => { grid.value[r][c] = '' })
  setTimeout(() => {
    dropDown()
    fillEmpty()
    setTimeout(() => processMatches(), 150)
  }, 200)
}

function dropDown() {
  for (let c = 0; c < COLS; c++) {
    let write = ROWS - 1
    for (let r = ROWS - 1; r >= 0; r--) {
      if (grid.value[r][c]) {
        grid.value[write][c] = grid.value[r][c]
        if (write !== r) grid.value[r][c] = ''
        write--
      }
    }
  }
}

function fillEmpty() {
  for (let r = 0; r < ROWS; r++)
    for (let c = 0; c < COLS; c++)
      if (!grid.value[r][c]) grid.value[r][c] = TYPES[Math.floor(Math.random() * TYPES.length)]
}

function useHint() {
  if (animating) return
  for (let r = 0; r < ROWS; r++)
    for (let c = 0; c < COLS - 1; c++) {
      swap(r, c, r, c + 1)
      if (hasMatches()) { swap(r, c, r, c + 1); selected.value = [r, c]; return }
      swap(r, c, r, c + 1)
    }
  for (let r = 0; r < ROWS - 1; r++)
    for (let c = 0; c < COLS; c++) {
      swap(r, c, r + 1, c)
      if (hasMatches()) { swap(r, c, r + 1, c); selected.value = [r, c]; return }
      swap(r, c, r + 1, c)
    }
}

onMounted(() => { newGame() })
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: linear-gradient(135deg, #667eea, #764ba2); display: flex; flex-direction: column; align-items: center; padding: 20rpx; position: relative; }
.header { width: 100%; max-width: 600rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.title { font-size: 52rpx; font-weight: bold; color: #fff; }
.scores { display: flex; gap: 12rpx; }
.score-box { background: rgba(255,255,255,0.2); padding: 8rpx 20rpx; border-radius: 30rpx; }
.score-text { font-size: 24rpx; color: #fff; }
.controls { display: flex; gap: 16rpx; margin-bottom: 16rpx; width: 100%; max-width: 600rpx; }
.btn { background: rgba(255,255,255,0.3); color: #fff; padding: 12rpx 28rpx; border-radius: 30rpx; text-align: center; }
.btn-text { font-size: 26rpx; color: #fff; }
.board { width: 100%; max-width: 600rpx; background: rgba(255,255,255,0.15); border-radius: 20rpx; padding: 10rpx; display: flex; flex-direction: column; gap: 6rpx; }
.row { display: flex; gap: 6rpx; }
.cell { flex: 1; aspect-ratio: 1; border-radius: 14rpx; display: flex; align-items: center; justify-content: center; background: rgba(255,255,255,0.1); }
.cell.selected { background: rgba(255,255,255,0.4); transform: scale(1.1); }
.emoji { font-size: 36rpx; }
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; }
.overlay-msg { font-size: 56rpx; color: #fff; font-weight: bold; margin-bottom: 16rpx; display: block; }
.overlay-score { font-size: 36rpx; color: #eee; margin-bottom: 30rpx; display: block; }
</style>