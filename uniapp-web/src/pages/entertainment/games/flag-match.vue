<template>
  <view class="game-container">
    <view class="header">
      <text class="back-btn" @tap="goBack">‹</text>
      <text class="title">国旗配对</text>
      <view class="info">
        <text class="info-text">⏱ {{ seconds }}s</text>
        <text class="info-text">翻牌: {{ flips }}</text>
        <text class="info-text">配对: {{ matched }}/{{ totalPairs }}</text>
      </view>
    </view>
    <view class="controls">
      <view :class="['diff-btn', mode === 'easy' ? 'active' : '']" @tap="setMode('easy')"><text>简单 4×4</text></view>
      <view :class="['diff-btn', mode === 'hard' ? 'active' : '']" @tap="setMode('hard')"><text>困难 5×5</text></view>
    </view>
    <view class="board" :class="mode">
      <view class="row" v-for="(row, r) in grid" :key="r">
        <view
          :class="['card', card.flipped ? 'flipped' : '', card.matched ? 'matched' : '']"
          v-for="(card, c) in row"
          :key="c"
          @tap="flipCard(r, c)"
        >
          <view class="card-front">
            <text class="flag">{{ card.flag }}</text>
          </view>
          <view class="card-back">
            <text class="back-text">?</text>
          </view>
        </view>
      </view>
    </view>
    <view class="overlay" v-if="won">
      <view class="overlay-content">
        <text class="overlay-msg">🎉 恭喜通关！</text>
        <text class="overlay-stars">{{ stars }}</text>
        <text class="overlay-detail">用时：{{ seconds }}秒 | 翻牌：{{ flips }}次</text>
        <view class="btn" @tap="newGame"><text class="btn-text">再来一局</text></view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'

interface Card { flag: string; id: number; flipped: boolean; matched: boolean }

const FLAGS = ['🇨🇳','🇺🇸','🇯🇵','🇬🇧','🇫🇷','🇩🇪','🇰🇷','🇧🇷','🇮🇳','🇦🇺','🇨🇦','🇮🇹','🇷🇺','🇪🇸','🇲🇽','🇹🇷']
const mode = ref<'easy' | 'hard'>('easy')
const grid = ref<Card[][]>([])
const flips = ref(0)
const matched = ref(0)
const seconds = ref(0)
const won = ref(false)
const totalPairs = computed(() => mode.value === 'easy' ? 8 : 12)

const stars = computed(() => {
  const minFlips = totalPairs.value * 2
  if (flips.value <= minFlips + 4) return '⭐⭐⭐'
  if (flips.value <= minFlips + 12) return '⭐⭐'
  return '⭐'
})

let firstCard: [number, number] | null = null
let lockBoard = false
let timerId: any = null

function newGame() {
  flips.value = 0; matched.value = 0; seconds.value = 0; won.value = false
  firstCard = null; lockBoard = false
  clearInterval(timerId); timerId = null

  const isEasy = mode.value === 'easy'
  const rows = isEasy ? 4 : 5
  const cols = isEasy ? 4 : 5
  const pairCount = isEasy ? 8 : 12

  const flags = FLAGS.slice(0, pairCount)
  let cards: Card[] = []
  let id = 0
  flags.forEach(flag => {
    cards.push({ flag, id: id++, flipped: false, matched: false })
    cards.push({ flag, id: id++, flipped: false, matched: false })
  })
  // for hard mode (25 cards), add one dummy
  if (!isEasy) {
    cards.push({ flag: '⭐', id: id++, flipped: true, matched: true })
  }
  // shuffle
  for (let i = cards.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [cards[i], cards[j]] = [cards[j], cards[i]]
  }
  const newGrid: Card[][] = []
  for (let r = 0; r < rows; r++) {
    newGrid.push(cards.slice(r * cols, (r + 1) * cols))
  }
  grid.value = newGrid
}

function setMode(m: 'easy' | 'hard') { mode.value = m; newGame() }

function flipCard(r: number, c: number) {
  if (lockBoard) return
  const card = grid.value[r][c]
  if (card.flipped || card.matched) return
  if (!timerId) timerId = setInterval(() => seconds.value++, 1000)

  card.flipped = true
  flips.value++

  if (!firstCard) {
    firstCard = [r, c]
    return
  }

  const [fr, fc] = firstCard
  firstCard = null
  const first = grid.value[fr][fc]

  if (first.flag === card.flag) {
    first.matched = true
    card.matched = true
    matched.value++
    if (matched.value >= totalPairs.value) {
      won.value = true
      clearInterval(timerId)
    }
  } else {
    lockBoard = true
    setTimeout(() => {
      first.flipped = false
      card.flipped = false
      lockBoard = false
    }, 800)
  }
}

function goBack() { uni.navigateBack() }

onMounted(() => { newGame() })
onUnmounted(() => { clearInterval(timerId) })
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: linear-gradient(135deg, #1a1a2e, #16213e); display: flex; flex-direction: column; align-items: center; padding: 20rpx; position: relative; }
.header { width: 100%; max-width: 620rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.back-btn { font-size: 48rpx; color: #fff; font-weight: 700; padding: 0 16rpx; }
.title { font-size: 44rpx; font-weight: bold; color: #f8d90f; }
.info { display: flex; gap: 10rpx; }
.info-text { font-size: 22rpx; color: #dfe6e9; background: rgba(255,255,255,0.1); padding: 6rpx 12rpx; border-radius: 14rpx; }
.controls { display: flex; gap: 16rpx; margin-bottom: 20rpx; }
.diff-btn { background: rgba(255,255,255,0.1); padding: 10rpx 28rpx; border-radius: 24rpx; color: #aaa; font-size: 24rpx; &.active { background: #f8d90f; color: #1a1a2e; font-weight: bold; } }
.board { display: flex; flex-direction: column; gap: 10rpx; }
.board.easy { width: 500rpx; }
.board.hard { width: 600rpx; }
.row { display: flex; gap: 10rpx; justify-content: center; }
.card { width: 110rpx; height: 140rpx; border-radius: 12rpx; position: relative; perspective: 600rpx; }
.card-front, .card-back { position: absolute; inset: 0; border-radius: 12rpx; display: flex; align-items: center; justify-content: center; backface-visibility: hidden; transition: transform 0.3s; }
.card-front { background: linear-gradient(135deg, #667eea, #764ba2); transform: rotateY(180deg); }
.card-back { background: linear-gradient(135deg, #2d3561, #1e215d); transform: rotateY(0deg); }
.card.flipped .card-front { transform: rotateY(0deg); }
.card.flipped .card-back { transform: rotateY(180deg); }
.card.matched .card-front { background: linear-gradient(135deg, #50e3c2, #3ba89f); }
.flag { font-size: 56rpx; }
.back-text { font-size: 40rpx; color: #aaa; font-weight: bold; }
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; }
.overlay-msg { font-size: 56rpx; color: #fff; font-weight: bold; margin-bottom: 12rpx; display: block; }
.overlay-stars { font-size: 48rpx; margin-bottom: 12rpx; display: block; }
.overlay-detail { font-size: 28rpx; color: #dfe6e9; margin-bottom: 24rpx; display: block; }
.btn { background: #f8d90f; padding: 16rpx 48rpx; border-radius: 30rpx; display: inline-block; }
.btn-text { font-size: 28rpx; color: #1a1a2e; font-weight: bold; }
</style>