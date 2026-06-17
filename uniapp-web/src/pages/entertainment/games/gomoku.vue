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
    <!-- 模式选择 -->
    <view class="mode-bar">
      <view
        :class="['mode-btn', mode === 'pvp' ? 'mode-active' : '']"
        @tap="switchMode('pvp')"
      >
        <text class="mode-text">👥 双人对战</text>
      </view>
      <view
        :class="['mode-btn', mode === 'pve' ? 'mode-active' : '']"
        @tap="switchMode('pve')"
      >
        <text class="mode-text">🤖 人机对战</text>
      </view>
    </view>
    <!-- AI难度（仅人机模式显示） -->
    <view class="mode-bar" v-if="mode === 'pve'">
      <text class="diff-label">AI难度：</text>
      <view
        :class="['mode-btn', aiLevel === 1 ? 'mode-active' : '']"
        @tap="aiLevel = 1; newGame()"
      >
        <text class="mode-text">简单</text>
      </view>
      <view
        :class="['mode-btn', aiLevel === 2 ? 'mode-active' : '']"
        @tap="aiLevel = 2; newGame()"
      >
        <text class="mode-text">中等</text>
      </view>
      <view
        :class="['mode-btn', aiLevel === 3 ? 'mode-active' : '']"
        @tap="aiLevel = 3; newGame()"
      >
        <text class="mode-text">困难</text>
      </view>
    </view>
    <!-- 棋盘 -->
    <view class="board" id="board-area">
      <view class="row" v-for="(row, r) in board" :key="r">
        <view
          class="cell"
          v-for="(cell, c) in row"
          :key="c"
          :style="{ height: cellSize + 'px' }"
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
import { ref, onMounted, nextTick } from 'vue'

const N = 15
const board = ref<number[][]>([])
const turn = ref(1)
const history = ref<[number, number][]>([])
const gameOver = ref(false)
const resultMsg = ref('')
const lastMove = ref<[number, number] | null>(null)
const undoCount = ref(0)

// 模式：pvp 双人，pve 人机
const mode = ref<'pvp' | 'pve'>('pve')
const aiLevel = ref(2)
const cellSize = ref(0)
let aiThinking = false

function newGame() {
  board.value = Array(N).fill(null).map(() => Array(N).fill(0))
  turn.value = 1
  history.value = []
  gameOver.value = false
  resultMsg.value = ''
  lastMove.value = null
  undoCount.value = 0
  aiThinking = false
}

function switchMode(m: 'pvp' | 'pve') {
  mode.value = m
  newGame()
}

// 计算棋盘格子尺寸（兼容 iOS Safari 不支持 aspect-ratio）
function calcCellSize() {
  try {
    const sys = uni.getSystemInfoSync()
    const screenWidth = sys.screenWidth || 375
    // 棋盘宽度 = 屏幕宽度 - 左右 padding (20rpx * 2 = 40rpx) - 棋盘 padding (10rpx * 2 = 20rpx)
    const rpxPerPx = screenWidth / 750
    const boardPaddingPx = 20 * rpxPerPx  // 10rpx * 2
    const containerPaddingPx = 40 * rpxPerPx // 20rpx * 2
    const maxBoardPx = Math.min(screenWidth - containerPaddingPx, 700 * rpxPerPx)
    const cellPx = (maxBoardPx - boardPaddingPx * 2) / N
    cellSize.value = Math.floor(cellPx)
  } catch {
    cellSize.value = 0 // fallback: CSS will handle
  }
}

function placeStone(r: number, c: number) {
  if (gameOver.value || board.value[r][c] || aiThinking) return

  // 人机模式下，只允许黑方（玩家）下棋
  if (mode.value === 'pve' && turn.value !== 1) return

  board.value[r][c] = turn.value
  history.value.push([r, c])
  lastMove.value = [r, c]

  if (checkWin(r, c)) {
    gameOver.value = true
    if (mode.value === 'pve') {
      resultMsg.value = (turn.value === 1 ? '🎉 你赢了！' : '💻 电脑获胜！')
    } else {
      resultMsg.value = (turn.value === 1 ? '黑方' : '白方') + '获胜！🎉'
    }
    return
  }
  if (history.value.length === N * N) {
    gameOver.value = true
    resultMsg.value = '平局！'
    return
  }
  turn.value = turn.value === 1 ? 2 : 1

  // 人机模式：AI 回应
  if (mode.value === 'pve' && turn.value === 2 && !gameOver.value) {
    aiThinking = true
    setTimeout(() => {
      aiMakeMove()
      aiThinking = false
    }, 200)
  }
}

// ==================== AI 人机对战 ====================
function aiMakeMove() {
  const move = findBestMove()
  if (!move) return
  placeStoneAI(move[0], move[1])
}

function placeStoneAI(r: number, c: number) {
  board.value[r][c] = turn.value
  history.value.push([r, c])
  lastMove.value = [r, c]

  if (checkWin(r, c)) {
    gameOver.value = true
    resultMsg.value = '💻 电脑获胜！'
    return
  }
  if (history.value.length === N * N) {
    gameOver.value = true
    resultMsg.value = '平局！'
    return
  }
  turn.value = 1
}

function findBestMove(): [number, number] | null {
  const empty = getEmptyCells()
  if (empty.length === 0) return null

  // 第一步下中心附近
  if (history.value.length <= 1) {
    const center = Math.floor(N / 2)
    const offsets = [[0,0],[0,1],[1,0],[-1,0],[0,-1],[1,1],[-1,-1],[1,-1],[-1,1]]
    for (const [dr, dc] of offsets) {
      const nr = center + dr, nc = center + dc
      if (nr >= 0 && nr < N && nc >= 0 && nc < N && board.value[nr][nc] === 0) {
        return [nr, nc]
      }
    }
  }

  // 评估每个空位的分数
  const searchRadius = aiLevel.value === 1 ? 1 : (aiLevel.value === 2 ? 2 : 3)
  const candidates: { r: number; c: number; score: number }[] = []

  for (const [r, c] of empty) {
    if (!hasNeighbor(r, c, searchRadius)) continue
    const score = evaluatePosition(r, c)
    candidates.push({ r, c, score })
  }

  if (candidates.length === 0) {
    // 如果没有邻居，随便选一个离已有棋子最近的
    const allWithDist = empty.map(([r, c]) => {
      let minDist = Infinity
      for (const [hr, hc] of history.value) {
        const d = Math.abs(r - hr) + Math.abs(c - hc)
        if (d < minDist) minDist = d
      }
      return { r, c, score: -minDist }
    })
    allWithDist.sort((a, b) => b.score - a.score)
    return [allWithDist[0].r, allWithDist[0].c]
  }

  candidates.sort((a, b) => b.score - a.score)

  // 简单难度加随机性
  if (aiLevel.value === 1) {
    const top = candidates.slice(0, Math.max(3, Math.floor(candidates.length * 0.3)))
    const pick = top[Math.floor(Math.random() * top.length)]
    return [pick.r, pick.c]
  }

  return [candidates[0].r, candidates[0].c]
}

function hasNeighbor(r: number, c: number, radius: number): boolean {
  for (let dr = -radius; dr <= radius; dr++) {
    for (let dc = -radius; dc <= radius; dc++) {
      if (dr === 0 && dc === 0) continue
      const nr = r + dr, nc = c + dc
      if (nr >= 0 && nr < N && nc >= 0 && nc < N && board.value[nr][nc] !== 0) {
        return true
      }
    }
  }
  return false
}

// 评估某位置的综合得分
function evaluatePosition(r: number, c: number): number {
  const AI = 2, HUMAN = 1
  let score = 0

  // 放置 AI 棋子后的进攻得分
  const aiScore = evaluatePoint(r, c, AI)
  // 放置玩家棋子后的防守得分
  const humanScore = evaluatePoint(r, c, HUMAN)

  // 进攻权重略高
  score = aiScore * 1.1 + humanScore
  return score
}

// 评估在 (r,c) 放置 player 棋子后的连线价值
function evaluatePoint(r: number, c: number, player: number): number {
  const dirs = [[0, 1], [1, 0], [1, 1], [1, -1]]
  let totalScore = 0

  for (const [dr, dc] of dirs) {
    const result = analyzeLine(r, c, dr, dc, player)
    totalScore += result
  }
  return totalScore
}

// 分析一条线上的棋型
function analyzeLine(r: number, c: number, dr: number, dc: number, player: number): number {
  let count = 1  // 包含当前位置
  let openEnds = 0
  let gaps = 0

  // 正方向
  let blocked1 = false
  for (let i = 1; i <= 4; i++) {
    const nr = r + dr * i, nc = c + dc * i
    if (nr < 0 || nr >= N || nc < 0 || nc >= N) { blocked1 = true; break }
    if (board.value[nr][nc] === player) count++
    else if (board.value[nr][nc] === 0) { openEnds++; break }
    else { blocked1 = true; break }
  }

  // 反方向
  let blocked2 = false
  for (let i = 1; i <= 4; i++) {
    const nr = r - dr * i, nc = c - dc * i
    if (nr < 0 || nr >= N || nc < 0 || nc >= N) { blocked2 = true; break }
    if (board.value[nr][nc] === player) count++
    else if (board.value[nr][nc] === 0) { openEnds++; break }
    else { blocked2 = true; break }
  }

  // 棋型评分
  if (count >= 5) return 1000000  // 连五

  if (count === 4) {
    if (openEnds === 2) return 100000   // 活四
    if (openEnds === 1) return 10000    // 冲四
    return 0
  }

  if (count === 3) {
    if (openEnds === 2) return 5000     // 活三
    if (openEnds === 1) return 500      // 眠三
    return 0
  }

  if (count === 2) {
    if (openEnds === 2) return 500      // 活二
    if (openEnds === 1) return 50       // 眠二
    return 0
  }

  if (count === 1) {
    if (openEnds === 2) return 50
    if (openEnds === 1) return 10
  }

  return 0
}

// ==================== 胜负判断 ====================
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

// ==================== 悔棋 ====================
function undo() {
  if (!history.value.length || gameOver.value || aiThinking) return
  if (undoCount.value >= 3) {
    uni.showToast({ title: '最多悔棋3次', icon: 'none' })
    return
  }

  if (mode.value === 'pve') {
    // 人机模式：撤销 AI 的一步 + 玩家的一步
    if (history.value.length >= 2) {
      const [ar, ac] = history.value.pop()!   // AI 的棋
      board.value[ar][ac] = 0
      const [pr, pc] = history.value.pop()!   // 玩家的棋
      board.value[pr][pc] = 0
      turn.value = 1
      undoCount.value++
    } else if (history.value.length === 1) {
      const [r, c] = history.value.pop()!
      board.value[r][c] = 0
      turn.value = 1
      undoCount.value++
    }
  } else {
    const [r, c] = history.value.pop()!
    board.value[r][c] = 0
    undoCount.value++
    turn.value = turn.value === 1 ? 2 : 1
  }

  lastMove.value = history.value.length ? history.value[history.value.length - 1] : null
}

function getEmptyCells(): [number, number][] {
  const cells: [number, number][] = []
  for (let r = 0; r < N; r++) {
    for (let c = 0; c < N; c++) {
      if (board.value[r][c] === 0) cells.push([r, c])
    }
  }
  return cells
}

onMounted(() => {
  newGame()
  calcCellSize()
})
</script>

<style lang="scss" scoped>
.game-container {
  min-height: 100vh;
  background: #f5e6c8;
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
  margin-bottom: 12rpx;
}
.title { font-size: 56rpx; font-weight: bold; color: #5d4e37; }
.turn { padding: 8rpx 24rpx; border-radius: 30rpx; }
.turn.black { background: #333; .turn-text { color: #fff; } }
.turn.white { background: #999; .turn-text { color: #fff; } }
.turn-text { font-size: 24rpx; }

.controls { display: flex; gap: 16rpx; margin-bottom: 12rpx; width: 100%; max-width: 700rpx; }
.btn { background: #8f7a66; color: #fff; padding: 12rpx 28rpx; border-radius: 10rpx; text-align: center; }
.btn-text { font-size: 26rpx; color: #fff; }

/* 模式选择 */
.mode-bar {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 12rpx;
  width: 100%;
  max-width: 700rpx;
  justify-content: center;
}
.mode-btn {
  padding: 8rpx 20rpx;
  border-radius: 16rpx;
  background: rgba(93, 78, 55, 0.15);
  border: 2rpx solid transparent;
}
.mode-btn.mode-active {
  background: rgba(93, 78, 55, 0.35);
  border-color: #5d4e37;
}
.mode-text { font-size: 24rpx; color: #5d4e37; }
.diff-label { font-size: 24rpx; color: #5d4e37; }

/* 棋盘 - 使用 flex 而非 aspect-ratio 兼容 iOS Safari */
.board {
  width: 100%;
  max-width: 700rpx;
  background: #d4a843;
  border-radius: 12rpx;
  padding: 10rpx;
  display: flex;
  flex-direction: column;
}
.row { display: flex; }
.cell {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  border: 1rpx solid rgba(93, 78, 55, 0.3);
  /* aspect-ratio removed for iOS Safari compatibility */
  /* height is set dynamically via :style binding */
}
.stone { width: 80%; height: 80%; border-radius: 50%; }
.black-stone { background: radial-gradient(circle at 35% 35%, #555, #111); }
.white-stone { background: radial-gradient(circle at 35% 35%, #fff, #ccc); border: 1rpx solid #ddd; }
.last-dot { width: 16rpx; height: 16rpx; border-radius: 50%; background: red; position: absolute; z-index: 2; }

.overlay {
  position: fixed; top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex; align-items: center; justify-content: center; z-index: 99;
}
.overlay-content { text-align: center; }
.overlay-msg {
  font-size: 56rpx; color: #fff; font-weight: bold; margin-bottom: 30rpx;
  display: block; text-shadow: 0 2rpx 4rpx rgba(0, 0, 0, 0.5);
}
</style>