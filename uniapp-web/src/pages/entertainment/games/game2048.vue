<template>
  <view class="game-container">
    <view class="header">
      <text class="title">2048</text>
      <view class="scores">
        <view class="score-box">
          <text class="label">分数</text>
          <text class="value">{{ score }}</text>
        </view>
        <view class="score-box">
          <text class="label">最高</text>
          <text class="value">{{ best }}</text>
        </view>
      </view>
    </view>
    <view class="controls">
      <view class="btn" @tap="newGame">
        <text class="btn-text">新游戏</text>
      </view>
    </view>
    <view class="board" id="board">
      <view class="row" v-for="(row, r) in grid" :key="r">
        <view
          class="cell"
          :class="'cell-' + (cell || 0)"
          v-for="(cell, c) in row"
          :key="c"
        >
          <text class="cell-text" v-if="cell">{{ cell }}</text>
        </view>
      </view>
    </view>
    <view class="overlay" v-if="gameOver">
      <view class="overlay-content">
        <text class="overlay-msg">{{ winMsg }}</text>
        <view class="btn" @tap="newGame">
          <text class="btn-text">再来一局</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

const grid = ref<number[][]>([])
const score = ref(0)
const best = ref(0)
const gameOver = ref(false)
const winMsg = ref('')
const won = ref(false)

function newGame() {
  grid.value = Array(4).fill(null).map(() => Array(4).fill(0))
  score.value = 0
  won.value = false
  gameOver.value = false
  winMsg.value = ''
  addRandom()
  addRandom()
}

function addRandom() {
  const empty: [number, number][] = []
  for (let r = 0; r < 4; r++)
    for (let c = 0; c < 4; c++)
      if (!grid.value[r][c]) empty.push([r, c])
  if (!empty.length) return
  const [r, c] = empty[Math.floor(Math.random() * empty.length)]
  grid.value[r][c] = Math.random() < 0.9 ? 2 : 4
}

function slide(row: number[]): number[] {
  const a = row.filter(v => v)
  for (let i = 0; i < a.length - 1; i++) {
    if (a[i] === a[i + 1]) {
      a[i] *= 2
      score.value += a[i]
      a.splice(i + 1, 1)
      if (a[i] === 2048 && !won.value) won.value = true
    }
  }
  while (a.length < 4) a.push(0)
  return a
}

function move(dir: string) {
  const old = JSON.stringify(grid.value)
  if (dir === 'left') {
    for (let r = 0; r < 4; r++) grid.value[r] = slide(grid.value[r])
  } else if (dir === 'right') {
    for (let r = 0; r < 4; r++) grid.value[r] = slide(grid.value[r].reverse()).reverse()
  } else if (dir === 'up') {
    for (let c = 0; c < 4; c++) {
      let col = [grid.value[0][c], grid.value[1][c], grid.value[2][c], grid.value[3][c]]
      col = slide(col)
      for (let r = 0; r < 4; r++) grid.value[r][c] = col[r]
    }
  } else if (dir === 'down') {
    for (let c = 0; c < 4; c++) {
      let col = [grid.value[3][c], grid.value[2][c], grid.value[1][c], grid.value[0][c]]
      col = slide(col)
      for (let r = 0; r < 4; r++) grid.value[r][c] = col[3 - r]
    }
  }
  if (JSON.stringify(grid.value) !== old) {
    addRandom()
    if (score.value > best.value) {
      best.value = score.value
      uni.setStorageSync('best2048', best.value)
    }
  }
  if (won.value) {
    setTimeout(() => { winMsg.value = '🎉 你赢了！'; gameOver.value = true }, 300)
    return
  }
  if (!canMove()) {
    setTimeout(() => { winMsg.value = '游戏结束！得分：' + score.value; gameOver.value = true }, 300)
  }
}

function canMove(): boolean {
  for (let r = 0; r < 4; r++)
    for (let c = 0; c < 4; c++) {
      if (!grid.value[r][c]) return true
      if (c < 3 && grid.value[r][c] === grid.value[r][c + 1]) return true
      if (r < 3 && grid.value[r][c] === grid.value[r + 1][c]) return true
    }
  return false
}

let startX = 0, startY = 0
function onTouchStart(e: any) {
  startX = e.touches[0].clientX
  startY = e.touches[0].clientY
}
function onTouchEnd(e: any) {
  const dx = e.changedTouches[0].clientX - startX
  const dy = e.changedTouches[0].clientY - startY
  if (Math.abs(dx) > Math.abs(dy)) {
    move(dx > 0 ? 'right' : 'left')
  } else {
    move(dy > 0 ? 'down' : 'up')
  }
}

onMounted(() => {
  best.value = uni.getStorageSync('best2048') || 0
  newGame()
})
</script>

<style lang="scss" scoped>
.game-container {
  min-height: 100vh;
  background: #faf8ef;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20rpx;
  position: relative;
}
.header {
  width: 100%;
  max-width: 700rpx;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}
.title { font-size: 72rpx; font-weight: bold; color: #776e65; }
.scores { display: flex; gap: 16rpx; }
.score-box { background: #bbada0; color: #fff; padding: 12rpx 24rpx; border-radius: 10rpx; text-align: center; }
.label { font-size: 20rpx; }
.value { font-size: 32rpx; font-weight: bold; }
.controls { margin-bottom: 20rpx; width: 100%; max-width: 700rpx; }
.btn { background: #8f7a66; color: #fff; padding: 16rpx 32rpx; border-radius: 10rpx; text-align: center; }
.btn-text { font-size: 28rpx; color: #fff; }
.board {
  width: 100%;
  max-width: 700rpx;
  background: #bbada0;
  border-radius: 14rpx;
  padding: 12rpx;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  touch-action: none;
}
.row { display: flex; gap: 8rpx; }
.cell {
  flex: 1;
  aspect-ratio: 1;
  border-radius: 10rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}
.cell-text { font-weight: bold; }
.cell-0 { background: #cdc1b4; }
.cell-2 { background: #eee4da; .cell-text { color: #776e65; font-size: 40rpx; } }
.cell-4 { background: #ede0c8; .cell-text { color: #776e65; font-size: 40rpx; } }
.cell-8 { background: #f2b179; .cell-text { color: #fff; font-size: 40rpx; } }
.cell-16 { background: #f59563; .cell-text { color: #fff; font-size: 38rpx; } }
.cell-32 { background: #f67c5f; .cell-text { color: #fff; font-size: 38rpx; } }
.cell-64 { background: #f65e3b; .cell-text { color: #fff; font-size: 38rpx; } }
.cell-128 { background: #edcf72; .cell-text { color: #fff; font-size: 34rpx; } }
.cell-256 { background: #edcc61; .cell-text { color: #fff; font-size: 34rpx; } }
.cell-512 { background: #edc850; .cell-text { color: #fff; font-size: 30rpx; } }
.cell-1024 { background: #edc53f; .cell-text { color: #fff; font-size: 26rpx; } }
.cell-2048 { background: #edc22e; .cell-text { color: #fff; font-size: 26rpx; } }
.overlay {
  position: fixed; top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(238,228,218,0.73);
  display: flex; align-items: center; justify-content: center;
  z-index: 99;
}
.overlay-content { text-align: center; }
.overlay-msg { font-size: 64rpx; color: #776e65; font-weight: bold; margin-bottom: 30rpx; display: block; }
</style>