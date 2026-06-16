<template>
  <view class="game-container">
    <view class="header">
      <text class="back-btn" @tap="goBack">‹</text>
      <text class="title">炸金花</text>
      <view class="info">
        <text class="info-text">💰 {{ playerChips }}</text>
        <text class="info-text">底池: {{ pot }}</text>
      </view>
    </view>

    <!-- AI区域 -->
    <view class="ai-area">
      <view class="player-label"><text class="label-text">🤖 AI</text></view>
      <view class="cards-row">
        <view v-for="(card, i) in aiCards" :key="i" :class="['card', card.revealed ? 'revealed' : 'hidden']">
          <text v-if="card.revealed" :class="['card-suit', card.suit === '♥' || card.suit === '♦' ? 'red' : 'black']">{{ card.suit }}{{ card.rank }}</text>
          <text v-else class="card-back">🂠</text>
        </view>
      </view>
      <text v-if="aiType" class="type-label">{{ aiType }}</text>
    </view>

    <!-- 底池区域 -->
    <view class="pot-area">
      <view class="pot-chips">
        <text class="pot-emoji">🪙</text>
        <text class="pot-text">{{ pot }}</text>
      </view>
    </view>

    <!-- 玩家区域 -->
    <view class="player-area">
      <view class="cards-row">
        <view v-for="(card, i) in playerCards" :key="i" :class="['card', card.revealed ? 'revealed' : 'hidden', card.revealed && !looked ? 'peek' : '']" @tap="peekCards">
          <text v-if="card.revealed" :class="['card-suit', card.suit === '♥' || card.suit === '♦' ? 'red' : 'black']">{{ card.suit }}{{ card.rank }}</text>
          <text v-else class="card-back">🂠</text>
        </view>
      </view>
      <text class="type-label" v-if="playerType">{{ playerType }}</text>
      <view class="player-label"><text class="label-text">👤 你</text></view>
    </view>

    <!-- 操作按钮 -->
    <view class="actions" v-if="!roundOver">
      <view v-if="!looked" class="action-btn peek-btn" @tap="peekCards"><text>👁 看牌</text></view>
      <view class="action-btn call-btn" @tap="doCall"><text>跟注 {{ callAmount }}</text></view>
      <view class="action-btn raise-btn" @tap="doRaise"><text>加注 {{ callAmount * 2 }}</text></view>
      <view class="action-btn compare-btn" @tap="doCompare"><text>⚔ 比牌</text></view>
      <view class="action-btn fold-btn" @tap="doFold"><text>🏳 弃牌</text></view>
    </view>

    <!-- 结果弹窗 -->
    <view class="overlay" v-if="roundOver">
      <view class="overlay-content">
        <text class="overlay-msg">{{ resultMsg }}</text>
        <text class="overlay-detail">{{ resultDetail }}</text>
        <text class="overlay-chips">当前积分：{{ playerChips }}</text>
        <view class="btn-row">
          <view class="btn" @tap="newRound"><text class="btn-text">再来一局</text></view>
          <view class="btn secondary" v-if="playerChips <= 0" @tap="resetChips"><text class="btn-text">免费重置</text></view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

interface Card { suit: string; rank: string; value: number; revealed: boolean }

const SUITS = ['♠','♥','♣','♦']
const RANKS = ['A','2','3','4','5','6','7','8','9','10','J','Q','K']
const RANK_VALUES: Record<string, number> = {A:14,K:13,Q:12,J:11,10:10,9:9,8:8,7:7,6:6,5:5,4:4,3:3,2:2}

const playerChips = ref(1000)
const pot = ref(0)
const currentBet = ref(10)
const playerCards = ref<Card[]>([])
const aiCards = ref<Card[]>([])
const looked = ref(false)
const roundOver = ref(false)
const resultMsg = ref('')
const resultDetail = ref('')
const playerType = ref('')
const aiType = ref('')
let deck: Card[] = []

const callAmount = computed(() => currentBet.value)

function newDeck(): Card[] {
  const d: Card[] = []
  for (const s of SUITS) for (const r of RANKS) d.push({suit:s,rank:r,value:RANK_VALUES[r],revealed:false})
  // shuffle
  for (let i = d.length-1; i > 0; i--) { const j = Math.floor(Math.random()*(i+1)); [d[i],d[j]]=[d[j],d[i]] }
  return d
}

function newRound() {
  if (playerChips.value <= 0) { resetChips(); return }
  deck = newDeck(); looked.value = false; roundOver.value = false
  resultMsg.value = ''; resultDetail.value = ''; playerType.value = ''; aiType.value = ''
  playerCards.value = [deck.pop()!, deck.pop()!, deck.pop()!]
  aiCards.value = [deck.pop()!, deck.pop()!, deck.pop()!]
  // 底注
  const ante = 10
  playerChips.value -= ante; pot.value = ante * 2; currentBet.value = ante
  aiCards.value.forEach(c => c.revealed = false)
  playerCards.value.forEach(c => c.revealed = false)
}

function peekCards() {
  if (roundOver.value) return
  looked.value = true
  playerCards.value.forEach(c => c.revealed = true)
  playerType.value = getHandType(playerCards.value)
}

function getHandType(cards: Card[]): string {
  const sorted = [...cards].sort((a,b) => a.value - b.value)
  const [a,b,c] = sorted
  const sameSuit = a.suit === b.suit && b.suit === c.suit
  const consecutive = b.value === a.value+1 && c.value === b.value+1
  // A-2-3 也算顺子
  const a23 = a.value===2 && b.value===3 && c.value===14
  const isStraight = consecutive || a23
  const pair = a.value===b.value || b.value===c.value || a.value===c.value
  const triple = a.value===b.value && b.value===c.value

  if (triple) return '豹子'
  if (sameSuit && isStraight) return '顺金'
  if (sameSuit) return '金花'
  if (isStraight) return '顺子'
  if (pair) return '对子'
  return '单张'
}

function handRank(type: string): number {
  const map: Record<string, number> = {'豹子':6,'顺金':5,'金花':4,'顺子':3,'对子':2,'单张':1}
  return map[type] || 0
}

function doCall() {
  if (playerChips.value < currentBet.value) { uni.showToast({title:'积分不足',icon:'none'}); return }
  playerChips.value -= currentBet.value
  pot.value += currentBet.value
  aiTurn()
}

function doRaise() {
  const amt = currentBet.value * 2
  if (playerChips.value < amt) { uni.showToast({title:'积分不足',icon:'none'}); return }
  playerChips.value -= amt
  pot.value += amt
  currentBet.value = amt
  aiTurn()
}

function doCompare() {
  if (playerChips.value < currentBet.value) { uni.showToast({title:'积分不足',icon:'none'}); return }
  playerChips.value -= currentBet.value
  pot.value += currentBet.value
  // 比牌
  revealAll()
  const pType = getHandType(playerCards.value)
  const aType = getHandType(aiCards.value)
  playerType.value = pType; aiType.value = aType
  const pRank = handRank(pType), aRank = handRank(aType)
  if (pRank > aRank || (pRank === aRank && compareHigh(playerCards.value, aiCards.value) > 0)) {
    resultMsg.value = '🎉 你赢了！'
    playerChips.value += pot.value
  } else {
    resultMsg.value = '😔 AI赢了'
  }
  resultDetail.value = `你: ${pType} vs AI: ${aType}`
  pot.value = 0; roundOver.value = true
}

function doFold() {
  resultMsg.value = '你弃牌了'; pot.value = 0; roundOver.value = true
  resultDetail.value = '失去本局积分'
}

function aiTurn() {
  // 简单AI逻辑
  const aiType = getHandType(aiCards.value)
  const rank = handRank(aiType)
  if (rank >= 3 && Math.random() < 0.5) {
    // AI加注
    const amt = currentBet.value
    currentBet.value = amt
  }
}

function revealAll() {
  aiCards.value.forEach(c => c.revealed = true)
  playerCards.value.forEach(c => c.revealed = true)
  looked.value = true
}

function compareHigh(a: Card[], b: Card[]): number {
  const as = [...a].sort((x,y) => y.value-x.value).map(c=>c.value)
  const bs = [...b].sort((x,y) => y.value-x.value).map(c=>c.value)
  for (let i=0;i<3;i++) { if(as[i]!==bs[i]) return as[i]-bs[i] }
  return 0
}

function resetChips() {
  playerChips.value = 1000
  uni.setStorageSync('zjh_chips', 1000)
  newRound()
}

function goBack() { uni.navigateBack() }

onMounted(() => {
  playerChips.value = uni.getStorageSync('zjh_chips') || 1000
  newRound()
})
</script>

<style lang="scss" scoped>
.game-container { min-height: 100vh; background: linear-gradient(180deg, #1a472a, #0d2818); display: flex; flex-direction: column; align-items: center; padding: 20rpx; position: relative; }
.header { width: 100%; max-width: 700rpx; display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.back-btn { font-size: 48rpx; color: #fff; font-weight: 700; padding: 0 16rpx; }
.title { font-size: 44rpx; font-weight: bold; color: #f8d90f; }
.info { display: flex; gap: 12rpx; }
.info-text { font-size: 24rpx; color: #dfe6e9; background: rgba(255,255,255,0.15); padding: 6rpx 14rpx; border-radius: 16rpx; }
.ai-area, .player-area { display: flex; flex-direction: column; align-items: center; gap: 10rpx; margin: 16rpx 0; }
.player-label { padding: 6rpx 20rpx; background: rgba(255,255,255,0.1); border-radius: 20rpx; }
.label-text { font-size: 26rpx; color: #dfe6e9; }
.cards-row { display: flex; gap: 16rpx; }
.card { width: 100rpx; height: 140rpx; border-radius: 12rpx; display: flex; align-items: center; justify-content: center; }
.card.revealed { background: #fff; box-shadow: 0 4rpx 12rpx rgba(0,0,0,0.3); }
.card.hidden { background: linear-gradient(135deg, #667eea, #764ba2); }
.card-suit { font-size: 32rpx; font-weight: bold; }
.card-suit.red { color: #e94560; }
.card-suit.black { color: #333; }
.card-back { font-size: 48rpx; color: #fff; }
.type-label { font-size: 24rpx; color: #f8d90f; background: rgba(248,217,15,0.2); padding: 6rpx 16rpx; border-radius: 16rpx; }
.pot-area { margin: 20rpx 0; }
.pot-chips { display: flex; align-items: center; gap: 8rpx; background: rgba(248,217,15,0.2); padding: 12rpx 32rpx; border-radius: 30rpx; }
.pot-emoji { font-size: 32rpx; }
.pot-text { font-size: 32rpx; color: #f8d90f; font-weight: bold; }
.actions { display: flex; flex-wrap: wrap; gap: 12rpx; justify-content: center; margin-top: 16rpx; width: 100%; max-width: 700rpx; }
.action-btn { padding: 14rpx 28rpx; border-radius: 24rpx; font-size: 24rpx; }
.call-btn { background: #50e3c2; color: #1a1a2e; }
.raise-btn { background: #f5a623; color: #fff; }
.compare-btn { background: #e94560; color: #fff; }
.fold-btn { background: rgba(255,255,255,0.2); color: #aaa; }
.peek-btn { background: #4a90d9; color: #fff; }
.overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 99; }
.overlay-content { text-align: center; padding: 30rpx; }
.overlay-msg { font-size: 52rpx; color: #fff; font-weight: bold; margin-bottom: 16rpx; display: block; }
.overlay-detail { font-size: 28rpx; color: #dfe6e9; margin-bottom: 12rpx; display: block; }
.overlay-chips { font-size: 26rpx; color: #f8d90f; margin-bottom: 24rpx; display: block; }
.btn-row { display: flex; gap: 20rpx; justify-content: center; }
.btn { background: #50e3c2; padding: 16rpx 40rpx; border-radius: 30rpx; }
.btn.secondary { background: #f5a623; }
.btn-text { font-size: 28rpx; color: #fff; }
</style>