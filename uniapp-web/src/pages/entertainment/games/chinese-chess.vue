<template>
  <view class="game-container">
    <view class="header">
      <text class="back-btn" @tap="goBack">‹</text>
      <text class="title">中国象棋</text>
      <view class="info">
        <text :class="['turn-badge', turn === 'red' ? 'red' : 'black']">{{ turn === 'red' ? '红方走棋' : '黑方走棋' }}</text>
      </view>
    </view>
    <view class="controls">
      <view class="ctrl-btn" @tap="undo"><text>悔棋</text></view>
      <view class="ctrl-btn" @tap="newGame"><text>新局</text></view>
    </view>
    <!-- 难度选择 -->
    <view class="difficulty-bar">
      <text class="diff-label">AI难度：</text>
      <view
        v-for="d in difficulties" :key="d.level"
        :class="['diff-btn', difficulty === d.level ? 'diff-active' : '']"
        @tap="setDifficulty(d.level)"
      >
        <text class="diff-text">{{ d.icon }}{{ d.label }}</text>
      </view>
    </view>
    <!-- 棋盘 -->
    <view class="board-wrap">
      <view class="board-grid">
        <!-- 楚河汉界文字 -->
        <view class="river-text left">楚 河</view>
        <view class="river-text right">汉 界</view>
        <view v-for="(row, r) in ROWS" :key="r" class="board-row">
          <view
            v-for="(col, c) in COLS" :key="c"
            :class="[
              'pos',
              isHighlight(r,c) ? 'hl' : '',
              isSelected(r,c) ? 'sel' : '',
              (c >= 1 && c <= 7 && (r === 4 || r === 5)) ? 'no-vline' : ''
            ]"
            @tap="tapPos(r, c)"
          >
            <!-- 兵/炮十字标记 -->
            <view v-if="isCrossMark(r,c)" class="cross-mark">
              <view class="cross-h"></view>
              <view class="cross-v"></view>
            </view>
            <!-- 九宫斜线 -->
            <view v-if="isPalaceDiag(r,c,'tl')" class="palace-line palace-tl"></view>
            <view v-if="isPalaceDiag(r,c,'tr')" class="palace-line palace-tr"></view>
            <view v-if="isPalaceDiag(r,c,'bl')" class="palace-line palace-bl"></view>
            <view v-if="isPalaceDiag(r,c,'br')" class="palace-line palace-br"></view>
            <view v-if="getPiece(r,c)" :class="['piece', getPiece(r,c)!.side]">
              <text class="piece-text">{{ getPiece(r,c)!.name }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>
    <view class="overlay" v-if="gameOver">
      <view class="overlay-content">
        <text class="overlay-msg">{{ winMsg }}</text>
        <view class="btn" @tap="newGame"><text class="btn-text">再来一局</text></view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

interface Piece { type: string; side: 'red' | 'black'; name: string }
type Board = (Piece | null)[][]

const ROWS = 10, COLS = 9
const board = ref<Board>([])
const turn = ref<'red' | 'black'>('red')
const selected = ref<[number, number] | null>(null)
const validMoves = ref<[number, number][]>([])
const gameOver = ref(false)
const winMsg = ref('')
const undoStack = ref<{ board: Board; turn: string }[]>([])

// 难度系统
const difficulties = [
  { level: 1, label: '简单', icon: '🟢' },
  { level: 2, label: '中等', icon: '🟡' },
  { level: 3, label: '困难', icon: '🔴' },
  { level: 4, label: '大师', icon: '⚫' }
]
const difficulty = ref(2)
function setDifficulty(d: number) { difficulty.value = d }

// 兵/炮十字标记位置
const crossPositions = new Set(['1-1','1-7','2-0','2-2','2-4','2-6','2-8','7-0','7-2','7-4','7-6','7-8','8-1','8-7'])
function isCrossMark(r:number,c:number) { return crossPositions.has(`${r}-${c}`) && !getPiece(r,c) }

// 九宫斜线判断（每个格子中心画斜线段）
function isPalaceDiag(r:number,c:number,d:string):boolean {
  if(d==='tl') return (r===0&&c===3)||(r===1&&c===4)
  if(d==='tr') return (r===0&&c===5)||(r===1&&c===4)
  if(d==='bl') return (r===8&&c===4)||(r===9&&c===3)
  if(d==='br') return (r===8&&c===4)||(r===9&&c===5)
  return false
}

function getPiece(r: number, c: number): Piece | null { return board.value[r]?.[c] ?? null }
function isSelected(r: number, c: number): boolean { return selected.value !== null && selected.value[0]===r && selected.value[1]===c }
function isHighlight(r: number, c: number): boolean { return validMoves.value.some(([vr,vc]) => vr===r && vc===c) }

function initBoard(): Board {
  const b: Board = Array(ROWS).fill(null).map(() => Array(COLS).fill(null))
  const bRow = (r:number, pieces:[number,string,string][]) => pieces.forEach(([c,t,n]) => { b[r][c] = {type:t,side:'black',name:n} })
  const rRow = (r:number, pieces:[number,string,string][]) => pieces.forEach(([c,t,n]) => { b[r][c] = {type:t,side:'red',name:n} })
  bRow(0, [[0,'r','车'],[1,'n','马'],[2,'b','象'],[3,'a','士'],[4,'k','将'],[5,'a','士'],[6,'b','象'],[7,'n','马'],[8,'r','车']])
  bRow(2, [[1,'c','炮'],[7,'c','炮']])
  bRow(3, [[0,'p','卒'],[2,'p','卒'],[4,'p','卒'],[6,'p','卒'],[8,'p','卒']])
  rRow(9, [[0,'r','车'],[1,'n','马'],[2,'b','相'],[3,'a','仕'],[4,'k','帅'],[5,'a','仕'],[6,'b','相'],[7,'n','马'],[8,'r','车']])
  rRow(7, [[1,'c','炮'],[7,'c','炮']])
  rRow(6, [[0,'p','兵'],[2,'p','兵'],[4,'p','兵'],[6,'p','兵'],[8,'p','兵']])
  return b
}

function newGame() {
  board.value = initBoard(); turn.value = 'red'
  selected.value = null; validMoves.value = []
  gameOver.value = false; winMsg.value = ''; undoStack.value = []
}

// ==================== 走法生成（支持传入自定义棋盘） ====================
function genMoves(side: 'red'|'black', b: Board): {sr:number,sc:number,er:number,ec:number}[] {
  const moves: {sr:number,sc:number,er:number,ec:number}[] = []
  for(let r=0;r<ROWS;r++) for(let c=0;c<COLS;c++) {
    const p = b[r][c]
    if(p && p.side===side) {
      for(const [er,ec] of getValidMovesB(r,c,p,b)) moves.push({sr:r,sc:c,er,ec})
    }
  }
  return moves
}

function getValidMoves(r: number, c: number, piece: Piece): [number, number][] {
  return getValidMovesB(r, c, piece, board.value)
}

function getValidMovesB(r: number, c: number, piece: Piece, b: Board): [number, number][] {
  const moves: [number, number][] = []
  const s = piece.side
  const canGo = (nr:number,nc:number) => nr>=0&&nr<ROWS&&nc>=0&&nc<COLS&&(!b[nr][nc]||b[nr][nc]!.side!==s)
  switch(piece.type) {
    case 'k':
      for(const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1]]) {
        const nr=r+dr,nc=c+dc
        if(nr>=0&&nr<ROWS&&nc>=0&&nc<COLS) {
          const pal = s==='red'?(nr>=7&&nr<=9&&nc>=3&&nc<=5):(nr>=0&&nr<=2&&nc>=3&&nc<=5)
          if(pal&&canGo(nr,nc)) moves.push([nr,nc])
        }
      }
      // 飞将
      const kd = s==='red'?-1:1
      let kr=r+kd
      while(kr>=0&&kr<ROWS) {
        if(b[kr][c]) { if(b[kr][c]!.type==='k'&&b[kr][c]!.side!==s) moves.push([kr,c]); break }
        kr+=kd
      }
      break
    case 'a':
      for(const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) {
        const nr=r+dr,nc=c+dc
        if(nr>=0&&nr<ROWS&&nc>=0&&nc<COLS) {
          const pal = s==='red'?(nr>=7&&nr<=9&&nc>=3&&nc<=5):(nr>=0&&nr<=2&&nc>=3&&nc<=5)
          if(pal&&canGo(nr,nc)) moves.push([nr,nc])
        }
      }
      break
    case 'b':
      for(const [dr,dc] of [[-2,-2],[-2,2],[2,-2],[2,2]]) {
        const nr=r+dr,nc=c+dc,mr=r+dr/2,mc=c+dc/2
        if(nr>=0&&nr<ROWS&&nc>=0&&nc<COLS) {
          const nc2 = s==='red'?nr>=5:nr<=4
          if(nc2&&!b[mr][mc]&&canGo(nr,nc)) moves.push([nr,nc])
        }
      }
      break
    case 'n':
      for(const [dr,dc,lr,lc] of [[-2,-1,-1,0],[-2,1,-1,0],[-1,-2,0,-1],[-1,2,0,1],[1,-2,0,-1],[1,2,0,1],[2,-1,1,0],[2,1,1,0]]) {
        const nr=r+dr,nc=c+dc
        const br=r+lr,bc=c+lc
        if(nr>=0&&nr<ROWS&&nc>=0&&nc<COLS&&br>=0&&br<ROWS&&bc>=0&&bc<COLS&&!b[br][bc]&&canGo(nr,nc)) moves.push([nr,nc])
      }
      break
    case 'r':
      for(const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1]]) {
        let nr=r+dr,nc=c+dc
        while(nr>=0&&nr<ROWS&&nc>=0&&nc<COLS) {
          if(!b[nr][nc]) moves.push([nr,nc])
          else { if(b[nr][nc]!.side!==s) moves.push([nr,nc]); break }
          nr+=dr;nc+=dc
        }
      }
      break
    case 'c':
      for(const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1]]) {
        let nr=r+dr,nc=c+dc,jumped=false
        while(nr>=0&&nr<ROWS&&nc>=0&&nc<COLS) {
          if(!jumped) { if(!b[nr][nc]) moves.push([nr,nc]); else jumped=true }
          else { if(b[nr][nc]) { if(b[nr][nc]!.side!==s) moves.push([nr,nc]); break } }
          nr+=dr;nc+=dc
        }
      }
      break
    case 'p': {
      const fwd = s==='red'?-1:1
      const crossed = s==='red'?r<=4:r>=5
      if(r+fwd>=0&&r+fwd<ROWS&&canGo(r+fwd,c)) moves.push([r+fwd,c])
      if(crossed) {
        if(c-1>=0&&canGo(r,c-1)) moves.push([r,c-1])
        if(c+1<COLS&&canGo(r,c+1)) moves.push([r,c+1])
      }
      break
    }
  }
  return moves
}

// ==================== 评估函数 ====================
const PIECE_VAL: Record<string, number> = { k: 10000, r: 600, c: 300, n: 300, b: 120, a: 120, p: 80 }

// 位置加分表（黑方视角，红方镜像）
const POS_BONUS: Record<string, number[][]> = {
  p: [
    [0,0,0,0,0,0,0,0,0],
    [90,90,110,120,120,120,110,90,90],
    [90,90,110,120,120,120,110,90,90],
    [70,90,110,110,110,110,110,90,70],
    [70,70,70,70,70,70,70,70,70],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0]
  ],
  r: [
    [200,210,210,220,220,220,210,210,200],
    [200,220,230,240,250,240,230,220,200],
    [190,210,220,230,230,230,220,210,190],
    [180,200,210,220,220,220,210,200,180],
    [180,200,210,220,220,220,210,200,180],
    [180,200,210,220,220,220,210,200,180],
    [180,200,210,220,220,220,210,200,180],
    [190,210,220,230,230,230,220,210,190],
    [200,220,230,240,250,240,230,220,200],
    [200,210,210,220,220,220,210,210,200]
  ],
  n: [
    [90,90,90,96,90,96,90,90,90],
    [90,96,103,97,94,97,103,96,90],
    [92,98,99,103,99,103,99,98,92],
    [93,108,100,107,100,107,100,108,93],
    [90,100,99,103,104,103,99,100,90],
    [90,100,99,103,104,103,99,100,90],
    [93,108,100,107,100,107,100,108,93],
    [92,98,99,103,99,103,99,98,92],
    [90,96,103,97,94,97,103,96,90],
    [90,90,90,96,90,96,90,90,90]
  ],
  c: [
    [100,100,96,91,90,91,96,100,100],
    [98,98,96,92,89,92,96,98,98],
    [97,97,96,91,92,91,96,97,97],
    [96,99,99,98,100,98,99,99,96],
    [96,96,96,96,100,96,96,96,96],
    [96,96,96,96,100,96,96,96,96],
    [96,99,99,98,100,98,99,99,96],
    [97,97,96,91,92,91,96,97,97],
    [98,98,96,92,89,92,96,98,98],
    [100,100,96,91,90,91,96,100,100]
  ],
  k: [
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,1,1,1,0,0,0],
    [0,0,0,2,2,2,0,0,0],
    [0,0,0,11,15,11,0,0,0]
  ],
  a: [
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,20,0,20,0,0,0],
    [0,0,0,0,23,0,0,0,0],
    [0,0,0,20,0,20,0,0,0]
  ],
  b: [
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0],
    [0,0,20,0,0,0,20,0,0],
    [0,0,0,0,0,0,0,0,0],
    [18,0,0,0,23,0,0,0,18],
    [0,0,0,0,0,0,0,0,0],
    [0,0,20,0,0,0,20,0,0]
  ]
}

function evaluate(b: Board): number {
  let score = 0
  for(let r=0;r<ROWS;r++) for(let c=0;c<COLS;c++) {
    const p = b[r][c]
    if(!p) continue
    const sign = p.side==='red'?1:-1
    const val = PIECE_VAL[p.type]||0
    // 位置加分：红方用(9-r)镜像
    const posR = p.side==='red'?(9-r):r
    const posC = p.side==='red'?(8-c):c
    const posBonus = (POS_BONUS[p.type]?.[posR]?.[posC])||0
    score += sign * (val + posBonus)
    // 过河兵额外加分
    if(p.type==='p') {
      const crossed = p.side==='red'?r<=4:r>=5
      if(crossed) score += sign * 30
    }
  }
  return score
}

// ==================== Minimax + Alpha-Beta 搜索 ====================
function alphaBeta(b: Board, depth: number, alpha: number, beta: number, isMax: boolean): number {
  if(depth <= 0) return evaluate(b)
  const side = isMax?'black':'red'
  const moves = genMoves(side, b)
  if(moves.length===0) return isMax?-99999:99999
  // 走法排序：吃子优先
  moves.sort((a,bm) => {
    const capA = b[a.er][a.ec]?PIECE_VAL[b[a.er][a.ec]!.type]||0:0
    const capB = b[bm.er][bm.ec]?PIECE_VAL[b[bm.er][bm.ec]!.type]||0:0
    return capB-capA
  })
  if(isMax) {
    let val = -Infinity
    for(const mv of moves) {
      const captured = b[mv.er][mv.ec]
      b[mv.er][mv.ec] = b[mv.sr][mv.sc]
      b[mv.sr][mv.sc] = null
      const score = alphaBeta(b, depth-1, alpha, beta, false)
      b[mv.sr][mv.sc] = b[mv.er][mv.ec]
      b[mv.er][mv.ec] = captured
      val = Math.max(val, score)
      alpha = Math.max(alpha, val)
      if(beta <= alpha) break
    }
    return val
  } else {
    let val = Infinity
    for(const mv of moves) {
      const captured = b[mv.er][mv.ec]
      b[mv.er][mv.ec] = b[mv.sr][mv.sc]
      b[mv.sr][mv.sc] = null
      const score = alphaBeta(b, depth-1, alpha, beta, true)
      b[mv.sr][mv.sc] = b[mv.er][mv.ec]
      b[mv.er][mv.ec] = captured
      val = Math.min(val, score)
      beta = Math.min(beta, val)
      if(beta <= alpha) break
    }
    return val
  }
}

// ==================== AI主函数 ====================
function aiMove() {
  if(gameOver.value) return
  const depth = difficulty.value // 1-4层搜索
  const b = board.value
  const moves = genMoves('black', b)
  if(!moves.length) { gameOver.value=true; winMsg.value='🎉 红方获胜！'; return }

  // 简单难度加随机性
  const randomRange = [0, 0, 5, 15, 40][difficulty.value] || 0
  let bestScore = -Infinity
  let bestMoves: typeof moves = []

  for(const mv of moves) {
    const captured = b[mv.er][mv.ec]
    b[mv.er][mv.ec] = b[mv.sr][mv.sc]
    b[mv.sr][mv.sc] = null
    let score = alphaBeta(b, depth-1, -Infinity, Infinity, false)
    // 简单难度加随机扰动
    if(randomRange > 0) score += (Math.random()-0.5)*randomRange*2
    b[mv.sr][mv.sc] = b[mv.er][mv.ec]
    b[mv.er][mv.ec] = captured

    if(score > bestScore) { bestScore = score; bestMoves = [mv] }
    else if(score === bestScore) bestMoves.push(mv)
  }
  const mv = bestMoves[Math.floor(Math.random()*bestMoves.length)]
  doMoveDirect(mv.sr, mv.sc, mv.er, mv.ec)
}

// ==================== 玩家操作 ====================
function tapPos(r: number, c: number) {
  if(gameOver.value||turn.value!=='red') return
  if(selected.value&&isHighlight(r,c)) {
    doMove(selected.value[0],selected.value[1],r,c)
    return
  }
  const piece = board.value[r][c]
  if(piece&&piece.side==='red') {
    selected.value=[r,c]
    validMoves.value=getValidMoves(r,c,piece)
  }
}

function doMove(sr:number,sc:number,er:number,ec:number) {
  undoStack.value.push({board:board.value.map(row=>row.map(p=>p?{...p}:null)),turn:turn.value})
  const captured = board.value[er][ec]
  board.value[er][ec]=board.value[sr][sc]
  board.value[sr][sc]=null
  selected.value=null; validMoves.value=[]
  if(captured&&captured.type==='k') {
    gameOver.value=true; winMsg.value='🎉 红方获胜！'
    return
  }
  turn.value = 'black'
  if(!gameOver.value) setTimeout(aiMove, 300)
}

function doMoveDirect(sr:number,sc:number,er:number,ec:number) {
  undoStack.value.push({board:board.value.map(row=>row.map(p=>p?{...p}:null)),turn:turn.value})
  const captured = board.value[er][ec]
  board.value[er][ec]=board.value[sr][sc]
  board.value[sr][sc]=null
  if(captured&&captured.type==='k') {
    gameOver.value=true; winMsg.value='⚫ 黑方获胜！'
    return
  }
  turn.value='red'
}

function undo() {
  if(!undoStack.value.length) return
  undoStack.value.pop() // 撤销AI的走步
  if(undoStack.value.length) {
    const s = undoStack.value.pop()! // 撤销玩家的走步
    board.value=s.board; turn.value=s.turn as any
  } else {
    newGame()
  }
  selected.value=null; validMoves.value=[]
}

function goBack() { uni.navigateBack() }
onMounted(() => { newGame() })
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: linear-gradient(135deg, #2d1b00, #1a0f00); display: flex; flex-direction: column; align-items: center; padding: 20rpx; }
.header { width: 100%; max-width: 660rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 8rpx; }
.back-btn { font-size: 48rpx; color: #fff; font-weight: 700; padding: 0 16rpx; }
.title { font-size: 44rpx; font-weight: bold; color: #f5a623; }
.info { display: flex; gap: 12rpx; }
.turn-badge { font-size: 24rpx; padding: 8rpx 20rpx; border-radius: 20rpx; }
.turn-badge.red { background: #c0392b; color: #fff; }
.turn-badge.black { background: #2c3e50; color: #fff; }
.controls { display: flex; gap: 16rpx; margin-bottom: 8rpx; }
.ctrl-btn { background: rgba(255,255,255,0.15); padding: 10rpx 28rpx; border-radius: 20rpx; color: #f5a623; font-size: 24rpx; }

/* 难度选择 */
.difficulty-bar { display: flex; align-items: center; gap: 10rpx; margin-bottom: 12rpx; flex-wrap: wrap; justify-content: center; }
.diff-label { color: #ccc; font-size: 24rpx; }
.diff-btn { padding: 8rpx 18rpx; border-radius: 16rpx; background: rgba(255,255,255,0.1); border: 2rpx solid transparent; }
.diff-btn.diff-active { background: rgba(245,166,35,0.25); border-color: #f5a623; }
.diff-text { color: #fff; font-size: 22rpx; }

/* 棋盘 */
.board-wrap { padding: 10rpx; }
.board-grid {
  position: relative;
  background: #E4B97F;
  border-radius: 8rpx;
  border: 3rpx solid #912020;
  overflow: hidden;
}
.board-row { display: flex; }
.pos {
  width: 70rpx;
  height: 68rpx;
  box-sizing: border-box;
  border-top: 1.5rpx solid #912020;
  border-left: 1.5rpx solid #912020;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}
.pos:last-child { border-right: 1.5rpx solid #912020; }
.board-row:last-child .pos { border-bottom: 1.5rpx solid #912020; }
.no-vline { border-left: 0; }

/* 九宫斜线 */
.palace-line {
  position: absolute;
  width: 70rpx;
  height: 68rpx;
  top: 0; left: 0;
  pointer-events: none;
  z-index: 1;
}
.palace-tl { background: linear-gradient(to bottom right, transparent 49%, #912020 49%, #912020 51%, transparent 51%); }
.palace-tr { background: linear-gradient(to bottom left, transparent 49%, #912020 49%, #912020 51%, transparent 51%); }
.palace-bl { background: linear-gradient(to top right, transparent 49%, #912020 49%, #912020 51%, transparent 51%); }
.palace-br { background: linear-gradient(to top left, transparent 49%, #912020 49%, #912020 51%, transparent 51%); }

/* 兵/炮十字标记 */
.cross-mark { position: absolute; width: 20rpx; height: 20rpx; pointer-events: none; z-index: 1; }
.cross-h { position: absolute; top: 50%; left: 0; width: 100%; height: 1.5rpx; background: #912020; transform: translateY(-50%); }
.cross-v { position: absolute; left: 50%; top: 0; width: 1.5rpx; height: 100%; background: #912020; transform: translateX(-50%); }

/* 高亮和选中 */
.pos.hl { background: rgba(80,227,194,0.4); }
.pos.sel { background: rgba(248,217,15,0.45); }

/* 楚河汉界 */
.river-text {
  position: absolute;
  z-index: 2;
  font-size: 26rpx;
  font-weight: bold;
  color: #912020;
  letter-spacing: 6rpx;
  pointer-events: none;
  font-family: SimSun, serif;
}
.river-text.left { top: calc(4 * 68rpx + 18rpx); left: calc(1 * 70rpx + 12rpx); }
.river-text.right { top: calc(4 * 68rpx + 18rpx); left: calc(6 * 70rpx + 12rpx); }

/* 棋子 */
.piece {
  width: 56rpx;
  height: 56rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 3rpx solid #912020;
  box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.4);
  position: relative;
  z-index: 3;
  background: radial-gradient(circle at 35% 35%, #f5e6cc, #E4B97F);
}
.piece.red { border-color: #c0392b; .piece-text { color: #c0392b; } }
.piece.black { border-color: #2c3e50; .piece-text { color: #2c3e50; } }
.piece-text { font-size: 24rpx; font-weight: bold; font-family: SimSun, serif; }

/* 弹窗 */
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; }
.overlay-msg { font-size: 52rpx; color: #fff; font-weight: bold; margin-bottom: 24rpx; display: block; }
.btn { background: #f5a623; padding: 16rpx 48rpx; border-radius: 30rpx; display: inline-block; }
.btn-text { font-size: 28rpx; color: #fff; }
</style>