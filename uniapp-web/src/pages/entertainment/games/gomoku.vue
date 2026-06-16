<template>
  <view class="game-container">
    <view class="header">
      <text class="title">五子棋</text>
      <view :class="['turn', turn === 1 ? 'black' : 'white']">
        <text class="turn-text">{{ turn === 1 ? '⚫ 黑方落子' : '⚪ 白方落子' }}</text>
      </view>
    </view>
    <view class="controls">
      <view class="btn" @tap="undo"><text class="btn-text">悔棋</text></view>
      <view class="btn" @tap="newGame"><text class="btn-text">新局</text></view>
    </view>
    <view class="board">
      <view class="row" v-for="(row, r) in board" :key="r">
        <view
          class="cell"
          v-for="(cell, c) in row"
          :key="c"
          @tap="placeStone(r, c)"
        >
          <view v-if="cell === 1" class="stone black-stone"></view>
          <view v-if="cell === 2" class="stone white-stone"></view>
          <view v-if="lastMove && lastMove[0] === r && lastMove[1] === c" class="last-dot"></view>
        </view>
      </view>
    </view>
    <view class="overlay" v-if="gameOver">
      <view class="overlay-content">
        <text class="overlay-msg">{{ resultMsg }}</text>
        <view class="btn" @tap="newGame"><text class="btn-text">再来一局</text></view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

const N = 15
const board = ref<number[][]>([])
const turn = ref(1)
const history = ref<[number, number][]>([])
const gameOver = ref(false)
const resultMsg = ref('')
const lastMove = ref<[number, number] | null>(null)
const undoCount = ref(0)

function newGame() {
  board.value = Array(N).fill(null).map(() => Array(N).fill(0))
  turn.value = 1
  history.value = []
  gameOver.value = false
  resultMsg.value = ''
  lastMove.value = null
  undoCount.value = 0
}

function placeStone(r: number, c: number) {
  if (gameOver.value || board.value[r][c]) return
  board.value[r][c] = turn.value
  history.value.push([r, c])
  lastMove.value = [r, c]
  if (checkWin(r, c)) {
    gameOver.value = true
    resultMsg.value = (turn.value === 1 ? '黑方' : '白方') + '获胜！🎉'
    return
  }
  if (history.value.length === N * N) {
    gameOver.value = true
    resultMsg.value = '平局！'
    return
  }
  turn.value = turn.value === 1 ? 2 : 1
}

function checkWin(r: number, c: number): boolean {
  const dirs = [[0, 1], [1, 0], [1, 1], [1, -1]]
  const p = board.value[r][c]
  for (const [dr, dc] of dirs) {
    let cnt = 1
    for (let i = 1; i < 5; i++) {
      const nr = r + dr * i, nc = c + dc * i
      if (nr >= 0 && nr < N && nc >= 0 && nc < N && board.value[nr][nc] === p) cnt++
      else break
    }
    for (let i = 1; i < 5; i++) {
      const nr = r - dr * i, nc = c - dc * i
      if (nr >= 0 && nr < N && nc >= 0 && nc < N && board.value[nr][nc] === p) cnt++
      else break
    }
    if (cnt >= 5) return true
  }
  return false
}

function undo() {
  if (!history.value.length || gameOver.value) return
  if (undoCount.value >= 3) {
    uni.showToast({ title: '最多悔棋3次', icon: 'none' })
    return
  }
  const [r, c] = history.value.pop()!
  board.value[r][c] = 0
  undoCount.value++
  turn.value = turn.value === 1 ? 2 : 1
  lastMove.value = history.value.length ? history.value[history.value.length - 1] : null
}

onMounted(() => { newGame() })
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: #f5e6c8; display: flex; flex-direction: column; align-items: center; padding: 20rpx; position: relative; }
.header { width: 100%; max-width: 700rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.title { font-size: 56rpx; font-weight: bold; color: #5d4e37; }
.turn { padding: 8rpx 24rpx; border-radius: 30rpx; }
.turn.black { background: #333; .turn-text { color: #fff; } }
.turn.white { background: #999; .turn-text { color: #fff; } }
.turn-text { font-size: 24rpx; }
.controls { display: flex; gap: 16rpx; margin-bottom: 16rpx; width: 100%; max-width: 700rpx; }
.btn { background: #8f7a66; color: #fff; padding: 12rpx 28rpx; border-radius: 10rpx; text-align: center; }
.btn-text { font-size: 26rpx; color: #fff; }
.board {
  width: 100%; max-width: 700rpx; background: #d4a843; border-radius: 12rpx; padding: 10rpx;
  display: flex; flex-direction: column; gap: 0;
}
.row { display: flex; gap: 0; }
.cell {
  flex: 1; aspect-ratio: 1; display: flex; align-items: center; justify-content: center;
  position: relative; border: 1rpx solid rgba(93,78,55,0.3);
}
.stone { width: 80%; height: 80%; border-radius: 50%; }
.black-stone { background: radial-gradient(circle at 35% 35%, #555, #111); }
.white-stone { background: radial-gradient(circle at 35% 35%, #fff, #ccc); border: 1rpx solid #ddd; }
.last-dot { width: 16rpx; height: 16rpx; border-radius: 50%; background: red; position: absolute; z-index: 2; }
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; }
.overlay-msg { font-size: 56rpx; color: #fff; font-weight: bold; margin-bottom: 30rpx; display: block; text-shadow: 0 2rpx 4rpx rgba(0,0,0,0.5); }
</style>