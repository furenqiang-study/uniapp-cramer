<template>
  <view class="game-container">
    <view class="header">
      <text class="back-btn" @tap="goBack">‹</text>
      <text class="title">数字拼图</text>
      <view class="info">
        <text class="info-text">步数: {{ moves }}</text>
        <text class="info-text">⭐ {{ stars }}</text>
      </view>
    </view>
    <view class="board">
      <view class="row" v-for="(row, r) in grid" :key="r">
        <view
          :class="['cell', cell === 0 ? 'empty' : (cell === r * 3 + c + 1 ? 'correct' : 'tile')]"
          v-for="(cell, c) in row"
          :key="c"
          @tap="tapCell(r, c)"
        >
          <text class="cell-text" v-if="cell !== 0">{{ cell }}</text>
        </view>
      </view>
    </view>
    <view class="controls">
      <view class="btn" @tap="shuffle"><text class="btn-text">🔀 重新打乱</text></view>
    </view>
    <view class="overlay" v-if="won">
      <view class="overlay-content">
        <text class="overlay-msg">🎉 恭喜通关！</text>
        <text class="overlay-score">步数：{{ moves }}</text>
        <text class="overlay-stars">{{ stars }}</text>
        <view class="btn" @tap="shuffle"><text class="btn-text">再来一局</text></view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

const grid = ref<number[][]>([])
const moves = ref(0)
const won = ref(false)

const stars = computed(() => {
  if (moves.value <= 30) return '⭐⭐⭐'
  if (moves.value <= 60) return '⭐⭐'
  return '⭐'
})

function initGrid() {
  const flat = [1, 2, 3, 4, 5, 6, 7, 8, 0]
  grid.value = [flat.slice(0, 3), flat.slice(3, 6), flat.slice(6, 9)]
}

function shuffle() {
  moves.value = 0; won.value = false
  let flat = [1, 2, 3, 4, 5, 6, 7, 8, 0]
  // do random valid moves to ensure solvability
  for (let i = 0; i < 200; i++) {
    const emptyIdx = flat.indexOf(0)
    const r = Math.floor(emptyIdx / 3), c = emptyIdx % 3
    const neighbors: [number, number][] = []
    if (r > 0) neighbors.push([r - 1, c])
    if (r < 2) neighbors.push([r + 1, c])
    if (c > 0) neighbors.push([r, c - 1])
    if (c < 2) neighbors.push([r, c + 1])
    const [nr, nc] = neighbors[Math.floor(Math.random() * neighbors.length)]
    const nIdx = nr * 3 + nc
    flat[emptyIdx] = flat[nIdx]
    flat[nIdx] = 0
  }
  grid.value = [flat.slice(0, 3), flat.slice(3, 6), flat.slice(6, 9)]
}

function tapCell(r: number, c: number) {
  if (won.value || grid.value[r][c] === 0) return
  const emptyPos = findEmpty()
  const [er, ec] = emptyPos
  if (Math.abs(er - r) + Math.abs(ec - c) !== 1) return
  grid.value[er][ec] = grid.value[r][c]
  grid.value[r][c] = 0
  moves.value++
  checkWin()
}

function findEmpty(): [number, number] {
  for (let r = 0; r < 3; r++)
    for (let c = 0; c < 3; c++)
      if (grid.value[r][c] === 0) return [r, c]
  return [2, 2]
}

function checkWin() {
  const flat = grid.value.flat()
  for (let i = 0; i < 8; i++) {
    if (flat[i] !== i + 1) return
  }
  won.value = true
}

function goBack() { uni.navigateBack() }

onMounted(() => { shuffle() })
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: linear-gradient(135deg, #2d3561, #1e215d); display: flex; flex-direction: column; align-items: center; padding: 20rpx; position: relative; }
.header { width: 100%; max-width: 520rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 30rpx; }
.back-btn { font-size: 48rpx; color: #fff; font-weight: 700; padding: 0 16rpx; }
.title { font-size: 44rpx; font-weight: bold; color: #f8d90f; }
.info { display: flex; gap: 12rpx; }
.info-text { font-size: 24rpx; color: #dfe6e9; background: rgba(255,255,255,0.1); padding: 6rpx 14rpx; border-radius: 16rpx; }
.board { width: 420rpx; background: rgba(255,255,255,0.1); border-radius: 20rpx; padding: 16rpx; display: flex; flex-direction: column; gap: 10rpx; }
.row { display: flex; gap: 10rpx; }
.cell { width: 120rpx; height: 120rpx; border-radius: 16rpx; display: flex; align-items: center; justify-content: center; }
.cell-empty { background: rgba(255,255,255,0.05); }
.cell-tile { background: linear-gradient(135deg, #667eea, #764ba2); }
.cell-correct { background: linear-gradient(135deg, #50e3c2, #3ba89f); }
.cell-text { font-size: 44rpx; font-weight: bold; color: #fff; }
.controls { margin-top: 30rpx; }
.btn { background: linear-gradient(135deg, #667eea, #764ba2); padding: 16rpx 40rpx; border-radius: 30rpx; display: inline-block; text-align: center; }
.btn-text { font-size: 28rpx; color: #fff; }
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; }
.overlay-msg { font-size: 56rpx; color: #fff; font-weight: bold; margin-bottom: 16rpx; display: block; }
.overlay-score { font-size: 32rpx; color: #dfe6e9; margin-bottom: 10rpx; display: block; }
.overlay-stars { font-size: 48rpx; margin-bottom: 24rpx; display: block; }
</style>