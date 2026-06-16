<template>
  <view class="game-container">
    <view class="header">
      <text class="back-btn" @tap="goBack">‹</text>
      <text class="title">跳棋</text>
      <view class="info">
        <text :class="['turn-badge', turn === 1 ? 'red' : 'blue']">{{ turn === 1 ? '红方回合' : '蓝方回合' }}</text>
      </view>
    </view>
    <view class="controls">
      <view :class="['ctrl-btn', mode === 'pvp' ? 'active' : '']" @tap="setMode('pvp')"><text>双人</text></view>
      <view :class="['ctrl-btn', mode === 'pve' ? 'active' : '']" @tap="setMode('pve')"><text>人机</text></view>
      <view class="ctrl-btn" @tap="undo"><text>悔棋</text></view>
      <view class="ctrl-btn" @tap="newGame"><text>新局</text></view>
    </view>
    <view class="board-area">
      <view v-for="(row, ri) in board" :key="ri" class="board-row">
        <view
          v-for="(cell, ci) in row"
          :key="ci"
          :class="['cell', cell === 0 ? 'empty' : '', cell === 1 ? 'red-piece' : '', cell === 2 ? 'blue-piece' : '', isHighlight(ri, ci) ? 'highlight' : '', isSelected(ri, ci) ? 'selected' : '']"
          @tap="tapCell(ri, ci)"
        >
          <view v-if="cell > 0" class="piece"></view>
        </view>
      </view>
    </view>
    <view class="overlay" v-if="gameOver">
      <view class="overlay-content">
        <text class="overlay-msg">{{ winner === 1 ? '红方获胜！' : '蓝方获胜！' }}🎉</text>
        <view class="btn" @tap="newGame"><text class="btn-text">再来一局</text></view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

// 简化版跳棋：使用较小的六角星形棋盘近似为十字形棋盘
// 2人对战，每方10颗棋子
const ROWS = 13, COLS = 17
const board = ref<number[][]>([])
const turn = ref(1)
const selected = ref<[number, number] | null>(null)
const highlights = ref<[number, number][]>([])
const gameOver = ref(false)
const winner = ref(0)
const mode = ref<'pvp' | 'pve'>('pve')
const undoStack = ref<{ board: number[][]; turn: number }[]>([])
const undoCount = ref(0)

function setMode(m: 'pvp' | 'pve') { mode.value = m; newGame() }

function newGame() {
  turn.value = 1; selected.value = null; highlights.value = []
  gameOver.value = false; winner.value = 0; undoStack.value = []; undoCount.value = 0
  // 初始化棋盘 - 简化为三角形营地对战
  board.value = Array(ROWS).fill(null).map(() => Array(COLS).fill(0))
  // 红方（上方营地）
  const redPositions: [number, number][] = [
    [0,8],[1,7],[1,9],[2,6],[2,8],[2,10],[3,5],[3,7],[3,9],[3,11]
  ]
  // 蓝方（下方营地）
  const bluePositions: [number, number][] = [
    [12,8],[11,7],[11,9],[10,6],[10,8],[10,10],[9,5],[9,7],[9,9],[9,11]
  ]
  redPositions.forEach(([r,c]) => { board.value[r][c] = 1 })
  bluePositions.forEach(([r,c]) => { board.value[r][c] = 2 })
}

function isValidCell(r: number, c: number): boolean {
  return r >= 0 && r < ROWS && c >= 0 && c < COLS && board.value[r][c] !== -1
}

function getNeighbors(r: number, c: number): [number, number][] {
  const dirs: [number, number][] = [[-1,-1],[-1,1],[0,-2],[0,2],[1,-1],[1,1]]
  return dirs.map(([dr,dc]) => [r+dr, c+dc] as [number, number]).filter(([nr,nc]) => isValidCell(nr,nc))
}

function getJumps(r: number, c: number): [number, number][] {
  const dirs: [number, number][] = [[-2,-2],[-2,2],[0,-4],[0,4],[2,-2],[2,2]]
  const jumps: [number, number][] = []
  dirs.forEach(([dr,dc]) => {
    const nr = r+dr, nc = c+dc, mr = r+dr/2, mc = c+dc/2
    if (isValidCell(nr,nc) && board.value[nr][nc] === 0 && board.value[mr][mc] > 0) {
      jumps.push([nr,nc])
    }
  })
  return jumps
}

function computeHighlights(r: number, c: number): [number, number][] {
  const result: [number, number][] = []
  // 相邻空位
  getNeighbors(r,c).forEach(([nr,nc]) => {
    if (board.value[nr][nc] === 0) result.push([nr,nc])
  })
  // 跳跃
  const visited = new Set<string>()
  const queue: [number, number][] = [[r,c]]
  visited.add(`${r},${c}`)
  while (queue.length) {
    const [cr, cc] = queue.shift()!
    getJumps(cr, cc).forEach(([nr,nc]) => {
      const key = `${nr},${nc}`
      if (!visited.has(key)) {
        visited.add(key)
        result.push([nr,nc])
        queue.push([nr,nc])
      }
    })
  }
  return result
}

function isHighlight(r: number, c: number): boolean {
  return highlights.value.some(([hr,hc]) => hr===r && hc===c)
}
function isSelected(r: number, c: number): boolean {
  return selected.value !== null && selected.value[0]===r && selected.value[1]===c
}

function tapCell(r: number, c: number) {
  if (gameOver.value) return
  if (isHighlight(r, c) && selected.value) {
    // 移动
    undoStack.value.push({ board: board.value.map(row => [...row]), turn: turn.value })
    const [sr, sc] = selected.value
    board.value[r][c] = board.value[sr][sc]
    board.value[sr][sc] = 0
    selected.value = null; highlights.value = []
    // 检查胜负
    checkWin()
    if (!gameOver.value) {
      turn.value = turn.value === 1 ? 2 : 1
      if (mode.value === 'pve' && turn.value === 2) {
        setTimeout(aiMove, 400)
      }
    }
    return
  }
  if (board.value[r][c] === turn.value) {
    selected.value = [r, c]
    highlights.value = computeHighlights(r, c)
  }
}

function checkWin() {
  // 红方棋子在蓝方营地 = 红方赢
  const blueCamp: [number, number][] = [[12,8],[11,7],[11,9],[10,6],[10,8],[10,10],[9,5],[9,7],[9,9],[9,11]]
  const redCamp: [number, number][] = [[0,8],[1,7],[1,9],[2,6],[2,8],[2,10],[3,5],[3,7],[3,9],[3,11]]
  
  let redInBlue = 0, blueInRed = 0
  blueCamp.forEach(([r,c]) => { if (board.value[r][c] === 1) redInBlue++ })
  redCamp.forEach(([r,c]) => { if (board.value[r][c] === 2) blueInRed++ })
  
  if (redInBlue >= 10) { gameOver.value = true; winner.value = 1 }
  if (blueInRed >= 10) { gameOver.value = true; winner.value = 2 }
}

function aiMove() {
  if (gameOver.value || turn.value !== 2) return
  const camp: [number, number][] = [[12,8],[11,7],[11,9],[10,6],[10,8],[10,10],[9,5],[9,7],[9,9],[9,11]]
  const allMoves: {sr:number;sc:number;er:number;ec:number;score:number}[] = []
  for (let r = 0; r < ROWS; r++) for (let c = 0; c < COLS; c++) {
    if (board.value[r][c] !== 2) continue
    const moves = computeHighlights(r, c)
    for (const [er, ec] of moves) {
      // Score: prefer moves toward red camp (row 0-3)
      let score = (12 - er) * 2 + Math.random() * 3
      // Bonus if landing in red camp
      if (camp.some(([cr,cc]) => cr===er && cc===ec)) score += 50
      allMoves.push({sr:r,sc:c,er,ec,score})
    }
  }
  if (!allMoves.length) return
  allMoves.sort((a,b) => b.score - a.score)
  const mv = allMoves[0]
  undoStack.value.push({board:board.value.map(row=>[...row]), turn:turn.value})
  board.value[mv.er][mv.ec] = board.value[mv.sr][mv.sc]
  board.value[mv.sr][mv.sc] = 0
  selected.value = null; highlights.value = []
  checkWin()
  if (!gameOver.value) turn.value = 1
}

function undo() {
  if (!undoStack.value.length || undoCount.value >= 3) {
    if (undoCount.value >= 3) uni.showToast({ title: '最多悔棋3次', icon: 'none' })
    return
  }
  const state = undoStack.value.pop()!
  board.value = state.board; turn.value = state.turn
  undoCount.value++; selected.value = null; highlights.value = []
}

function goBack() { uni.navigateBack() }

onMounted(() => { newGame() })
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: linear-gradient(135deg, #1a1a2e, #16213e); display: flex; flex-direction: column; align-items: center; padding: 20rpx; position: relative; }
.header { width: 100%; max-width: 700rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 12rpx; }
.back-btn { font-size: 48rpx; color: #fff; font-weight: 700; padding: 0 16rpx; }
.title { font-size: 44rpx; font-weight: bold; color: #50e3c2; }
.info { display: flex; gap: 12rpx; }
.turn-badge { font-size: 24rpx; padding: 8rpx 20rpx; border-radius: 20rpx; }
.turn-badge.red { background: #e94560; color: #fff; }
.turn-badge.blue { background: #4a90d9; color: #fff; }
.controls { display: flex; gap: 16rpx; margin-bottom: 16rpx; }
.ctrl-btn { background: rgba(255,255,255,0.1); padding: 10rpx 28rpx; border-radius: 20rpx; color: #aaa; font-size: 24rpx; &.active { background: #50e3c2; color: #1a1a2e; font-weight: bold; } }
.board-area { display: flex; flex-direction: column; gap: 2rpx; background: rgba(255,255,255,0.05); border-radius: 16rpx; padding: 16rpx; }
.board-row { display: flex; gap: 2rpx; justify-content: center; }
.cell { width: 36rpx; height: 36rpx; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
.cell.empty { background: rgba(255,255,255,0.08); }
.cell.highlight { background: rgba(80,227,194,0.4); box-shadow: 0 0 8rpx #50e3c2; }
.cell.selected { background: rgba(248,217,15,0.5); box-shadow: 0 0 10rpx #f8d90f; }
.piece { width: 28rpx; height: 28rpx; border-radius: 50%; }
.cell.red-piece { background: rgba(233,69,96,0.3); .piece { background: radial-gradient(circle at 35% 35%, #ff6b6b, #e94560); } }
.cell.blue-piece { background: rgba(74,144,217,0.3); .piece { background: radial-gradient(circle at 35% 35%, #74b9ff, #4a90d9); } }
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; }
.overlay-msg { font-size: 56rpx; color: #fff; font-weight: bold; margin-bottom: 24rpx; display: block; }
.btn { background: #50e3c2; padding: 16rpx 48rpx; border-radius: 30rpx; display: inline-block; }
.btn-text { font-size: 28rpx; color: #1a1a2e; font-weight: bold; }
</style>