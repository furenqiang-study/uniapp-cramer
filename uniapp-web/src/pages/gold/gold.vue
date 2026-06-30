<template>
  <view class="gold-container">
    <!-- 顶部导航栏 -->
    <view class="nav-bar">
      <view class="nav-back" @tap="goBack">
        <text class="nav-back-icon">‹</text>
      </view>
      <text class="nav-title">黄金预测</text>
      <view class="nav-refresh" @tap="refreshAll">
        <text class="refresh-icon" :class="{ spinning: refreshing }">↻</text>
      </view>
    </view>

    <scroll-view class="content-wrapper" scroll-y>
      <!-- 实时金价卡片 - 上海黄金交易所 -->
      <view class="price-card">
        <view class="price-header">
          <view class="price-header-left">
            <text class="price-label">🥇 {{ latestPrice?.source || '上海黄金交易所' }}</text>
            <view v-if="latestPrice?.is_realtime" class="realtime-badge">
              <view class="realtime-dot"></view>
              <text class="realtime-text">实时</text>
            </view>
          </view>
          <text class="price-update">{{ latestPrice?.date || '--' }} {{ latestPrice?.update_time || '' }}</text>
        </view>
        <view class="price-main">
          <text class="price-value">{{ latestPrice?.price_cny?.toFixed(2) || '--' }}</text>
          <text class="price-unit">元/克</text>
          <view class="price-change" :class="priceChangeClass">
            <text class="change-icon">{{ priceChangeIcon }}</text>
            <text class="change-value">{{ formatChange(latestPrice?.change_pct) }}%</text>
          </view>
        </view>
        <view class="price-detail">
          <view class="detail-item">
            <text class="detail-label">开盘</text>
            <text class="detail-value">{{ latestPrice?.open?.toFixed(2) || '--' }}</text>
          </view>
          <view class="detail-item">
            <text class="detail-label">最高</text>
            <text class="detail-value">{{ latestPrice?.high?.toFixed(2) || '--' }}</text>
          </view>
          <view class="detail-item">
            <text class="detail-label">最低</text>
            <text class="detail-value">{{ latestPrice?.low?.toFixed(2) || '--' }}</text>
          </view>
          <view class="detail-item">
            <text class="detail-label">昨结</text>
            <text class="detail-value">{{ (latestPrice as any)?.prev_settle?.toFixed(2) || '--' }}</text>
          </view>
        </view>
      </view>

      <!-- 国际金价三栏 -->
      <view v-if="realtimeData" class="intl-card">
        <view class="intl-item" v-if="realtimeData.newyork">
          <text class="intl-name">纽约期货</text>
          <text class="intl-price">${{ realtimeData.newyork.price?.toFixed(2) || '--' }}</text>
          <text class="intl-unit">美元/盎司</text>
        </view>
        <view class="intl-divider" v-if="realtimeData.newyork && realtimeData.london"></view>
        <view class="intl-item" v-if="realtimeData.london">
          <text class="intl-name">伦敦现货</text>
          <text class="intl-price">${{ realtimeData.london.price?.toFixed(2) || '--' }}</text>
          <text class="intl-unit">美元/盎司</text>
        </view>
      </view>

      <!-- 价格走势图 -->
      <view class="chart-section">
        <view class="section-header">
          <text class="section-title">价格走势</text>
          <view class="period-tabs">
            <view
              v-for="tab in periodTabs"
              :key="tab.value"
              class="period-tab"
              :class="{ active: selectedPeriod === tab.value }"
              @tap="switchPeriod(tab.value)"
            >
              <text class="period-text">{{ tab.label }}</text>
            </view>
          </view>
        </view>
        <view v-if="priceList.length" class="chart-area">
          <view class="chart-canvas">
            <view
              v-for="(line, idx) in chartLines"
              :key="'l' + idx"
              class="chart-line"
              :style="{
                left: line.x1 + 'rpx',
                top: line.y1 + 'rpx',
                width: line.length + 'rpx',
                transform: 'rotate(' + line.angle + 'deg)',
              }"
            ></view>
            <view
              v-for="(pt, idx) in chartPoints"
              :key="'p' + idx"
              class="chart-point"
              :style="{ left: pt.x + 'rpx', top: pt.y + 'rpx' }"
            >
              <view class="point-dot"></view>
              <text class="point-label" :class="{ 'label-up': pt.isUp, 'label-down': !pt.isUp }">
                {{ pt.price }}
              </text>
            </view>
          </view>
          <view class="chart-dates">
            <text
              v-for="(d, idx) in chartDates"
              :key="'d' + idx"
              class="chart-date"
            >{{ d }}</text>
          </view>
        </view>
        <view v-else class="chart-empty">
          <text class="empty-text">暂无走势数据</text>
        </view>
      </view>

      <!-- 预测面板 -->
      <view class="predict-section">
        <view class="section-header">
          <text class="section-title">智能预测</text>
        </view>

        <!-- 参数设置 -->
        <view class="params-card">
          <view class="param-row">
            <text class="param-label">预测天数</text>
            <view class="param-options">
              <view
                v-for="opt in daysOptions"
                :key="opt.value"
                class="param-option"
                :class="{ active: predictDays === opt.value }"
                @tap="predictDays = opt.value"
              >
                <text class="option-text">{{ opt.label }}</text>
              </view>
            </view>
          </view>
          <view class="param-row">
            <text class="param-label">预测模型</text>
            <view class="param-options algorithm-options">
              <view
                v-for="opt in algorithmOptions"
                :key="opt.value"
                class="param-option"
                :class="{ active: predictAlgorithm === opt.value }"
                @tap="predictAlgorithm = opt.value"
              >
                <text class="option-text">{{ opt.label }}</text>
              </view>
            </view>
          </view>
          <button class="predict-btn" :loading="predictLoading" @tap="handlePredict">
            开始预测
          </button>
        </view>

        <!-- 预测结果 -->
        <view v-if="predictResult" class="result-card">
          <view class="result-header">
            <view class="result-summary">
              <text class="result-label">预测趋势</text>
              <view class="trend-badge" :class="'trend-' + predictResult.trend_summary">
                <text class="trend-icon">{{ trendIcon }}</text>
                <text class="trend-text">{{ trendText }}</text>
              </view>
            </view>
            <view class="result-confidence">
              <text class="confidence-label">置信度</text>
              <text class="confidence-value">{{ predictResult.confidence_avg }}%</text>
            </view>
          </view>

          <!-- 预测走势图 -->
          <view v-if="predictChartLines.length" class="predict-chart">
            <view class="predict-chart-label">
              <view class="legend-item">
                <view class="legend-dot legend-history"></view>
                <text class="legend-text">历史</text>
              </view>
              <view class="legend-item">
                <view class="legend-dot legend-predict"></view>
                <text class="legend-text">预测</text>
              </view>
            </view>
            <view class="chart-canvas predict-canvas">
              <view
                v-for="(line, idx) in predictChartLines"
                :key="'pl' + idx"
                class="chart-line"
                :class="{ 'predict-line': line.isPredict }"
                :style="{
                  left: line.x1 + 'rpx',
                  top: line.y1 + 'rpx',
                  width: line.length + 'rpx',
                  transform: 'rotate(' + line.angle + 'deg)',
                }"
              ></view>
              <view
                v-for="(pt, idx) in predictChartPoints"
                :key="'pp' + idx"
                class="chart-point"
                :class="{ 'predict-point': pt.isPredict }"
                :style="{ left: pt.x + 'rpx', top: pt.y + 'rpx' }"
              >
                <view class="point-dot" :class="{ 'predict-dot': pt.isPredict }"></view>
                <text class="point-label" :class="{ 'label-up': pt.isUp, 'label-down': !pt.isUp }">
                  {{ pt.price }}
                </text>
              </view>
            </view>
          </view>

          <!-- 预测列表 -->
          <view class="predict-list">
            <view
              v-for="item in predictResult.predictions"
              :key="item.predict_date"
              class="predict-item"
            >
              <view class="predict-item-left">
                <text class="predict-date">{{ formatDate(item.predict_date) }}</text>
                <view class="predict-trend-tag" :class="'trend-' + item.trend">
                  <text class="trend-tag-text">{{ item.trend === 'up' ? '↑' : item.trend === 'down' ? '↓' : '→' }}</text>
                </view>
              </view>
              <view class="predict-item-right">
                <text class="predict-price">¥{{ item.predict_price.toFixed(2) }}</text>
                <text class="predict-change" :class="item.change_pct >= 0 ? 'text-up' : 'text-down'">
                  {{ item.change_pct >= 0 ? '+' : '' }}{{ item.change_pct }}%
                </text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <!-- 历史预测记录 -->
      <view class="history-section">
        <view class="section-header">
          <text class="section-title">预测记录</text>
        </view>
        <view v-if="historyList.length" class="history-list">
          <view
            v-for="item in historyList"
            :key="item.id"
            class="history-item"
          >
            <view class="history-left">
              <view class="history-algorithm-badge">
                <text class="algorithm-text">{{ getAlgorithmName(item.algorithm) }}</text>
              </view>
              <text class="history-date">{{ formatDateTime(item.created_at) }}</text>
            </view>
            <view class="history-right">
              <text class="history-price">¥{{ item.predict_price.toFixed(2) }}</text>
              <view class="history-trend" :class="'trend-' + item.trend">
                <text class="history-trend-text">{{ item.trend === 'up' ? '看涨' : item.trend === 'down' ? '看跌' : '持平' }}</text>
              </view>
            </view>
          </view>
        </view>
        <view v-else class="history-empty">
          <text class="empty-text">暂无预测记录</text>
        </view>
      </view>

      <view class="bottom-space"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
  getGoldPrices,
  getLatestPrice,
  getRealtimeGold,
  predictGold,
  getGoldPredictions,
  getGoldPredictParams,
  type GoldPriceInfo,
  type GoldRealtimeData,
  type GoldPredictResult,
  type GoldPredictionInfo,
} from '@/api/gold'

const latestPrice = ref<GoldPriceInfo | null>(null)
const realtimeData = ref<GoldRealtimeData | null>(null)
const priceList = ref<GoldPriceInfo[]>([])
const predictResult = ref<GoldPredictResult | null>(null)
const historyList = ref<GoldPredictionInfo[]>([])
const daysOptions = ref<{ value: number; label: string; desc: string }[]>([])
const algorithmOptions = ref<{ value: string; label: string; desc: string }[]>([])
const selectedPeriod = ref(30)
const predictDays = ref(7)
const predictAlgorithm = ref('ensemble')
const predictLoading = ref(false)
const refreshing = ref(false)

const periodTabs = [
  { value: 7, label: '7天' },
  { value: 30, label: '30天' },
  { value: 90, label: '90天' },
]

const ALGORITHM_NAMES: Record<string, string> = {
  ma: '移动平均',
  ema: '指数平滑',
  lr: '线性回归',
  ensemble: '集成模型',
}

const priceChangeClass = computed(() => {
  if (!latestPrice.value) return ''
  return latestPrice.value.change_pct >= 0 ? 'change-up' : 'change-down'
})

const priceChangeIcon = computed(() => {
  if (!latestPrice.value) return ''
  return latestPrice.value.change_pct >= 0 ? '▲' : '▼'
})

const trendIcon = computed(() => {
  if (!predictResult.value) return '→'
  const t = predictResult.value.trend_summary
  return t === 'up' ? '↑' : t === 'down' ? '↓' : '→'
})

const trendText = computed(() => {
  if (!predictResult.value) return '持平'
  const t = predictResult.value.trend_summary
  return t === 'up' ? '看涨' : t === 'down' ? '看跌' : '持平'
})

function formatChange(val?: number): string {
  if (val === undefined || val === null) return '0.00'
  return val >= 0 ? `+${val.toFixed(2)}` : val.toFixed(2)
}

function formatDate(dateStr: string): string {
  if (!dateStr) return ''
  const parts = dateStr.split('-')
  if (parts.length === 3) return `${parseInt(parts[1])}月${parseInt(parts[2])}日`
  return dateStr
}

function formatDateTime(dt: string | undefined): string {
  if (!dt) return ''
  const d = new Date(dt)
  if (isNaN(d.getTime())) return dt
  return `${d.getMonth() + 1}/${d.getDate()} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`
}

function getAlgorithmName(type: string): string {
  return ALGORITHM_NAMES[type] || type
}

function buildChartPoints(data: { price: number; isPredict?: boolean }[], canvasW: number, canvasH: number) {
  if (data.length < 2) return { points: [], lines: [] }
  const prices = data.map(d => d.price)
  const minP = Math.min(...prices)
  const maxP = Math.max(...prices)
  const range = maxP - minP || 1
  const padY = 40
  const usableH = canvasH - padY * 2
  const stepX = canvasW / (data.length - 1)

  const points = data.map((d, i) => {
    const x = i * stepX
    const y = canvasH - padY - ((d.price - minP) / range) * usableH
    return {
      x: Math.round(x),
      y: Math.round(y),
      price: d.price.toFixed(0),
      isUp: d.price >= (data[Math.max(0, i - 1)]?.price || d.price),
      isPredict: d.isPredict || false,
    }
  })

  const lines: { x1: number; y1: number; length: number; angle: number; isPredict?: boolean }[] = []
  for (let i = 0; i < points.length - 1; i++) {
    const p1 = points[i]
    const p2 = points[i + 1]
    const dx = p2.x - p1.x
    const dy = p2.y - p1.y
    const length = Math.sqrt(dx * dx + dy * dy)
    const angle = Math.atan2(dy, dx) * (180 / Math.PI)
    lines.push({
      x1: p1.x,
      y1: p1.y,
      length: Math.round(length),
      angle,
      isPredict: p1.isPredict || p2.isPredict,
    })
  }

  return { points, lines }
}

const chartPoints = computed(() => {
  const data = priceList.value.map(p => ({ price: p.price_cny }))
  const { points } = buildChartPoints(data, 650, 300)
  return points
})

const chartLines = computed(() => {
  const data = priceList.value.map(p => ({ price: p.price_cny }))
  const { lines } = buildChartPoints(data, 650, 300)
  return lines
})

const chartDates = computed(() => {
  const list = priceList.value
  if (list.length <= 7) return list.map(p => formatDate(p.date))
  const step = Math.ceil(list.length / 6)
  const dates: string[] = []
  for (let i = 0; i < list.length; i += step) {
    dates.push(formatDate(list[i].date))
  }
  if (dates[dates.length - 1] !== formatDate(list[list.length - 1].date)) {
    dates.push(formatDate(list[list.length - 1].date))
  }
  return dates
})

const predictChartPoints = computed(() => {
  if (!predictResult.value) return []
  const histData = priceList.value.slice(-7).map(p => ({ price: p.price_cny, isPredict: false }))
  const predData = predictResult.value.predictions.map(p => ({ price: p.predict_price, isPredict: true }))
  const allData = [...histData, ...predData]
  const { points } = buildChartPoints(allData, 650, 250)
  return points
})

const predictChartLines = computed(() => {
  if (!predictResult.value) return []
  const histData = priceList.value.slice(-7).map(p => ({ price: p.price_cny, isPredict: false }))
  const predData = predictResult.value.predictions.map(p => ({ price: p.predict_price, isPredict: true }))
  const allData = [...histData, ...predData]
  const { lines } = buildChartPoints(allData, 650, 250)
  return lines
})

onMounted(() => {
  loadLatestPrice()
  loadRealtimeData()
  loadPriceList()
  loadParams()
  loadHistory()
})

async function loadLatestPrice() {
  try {
    const res = await getLatestPrice()
    if (res.data) latestPrice.value = res.data
  } catch (e) {}
}

async function loadRealtimeData() {
  try {
    const res = await getRealtimeGold()
    if (res.data) realtimeData.value = res.data
  } catch (e) {}
}

async function loadPriceList() {
  try {
    const res = await getGoldPrices(selectedPeriod.value)
    if (res.data) priceList.value = res.data
  } catch (e) {}
}

async function loadParams() {
  try {
    const res = await getGoldPredictParams()
    if (res.data) {
      daysOptions.value = res.data.days_options || []
      algorithmOptions.value = res.data.algorithm_options || []
    }
  } catch (e) {}
}

async function loadHistory() {
  try {
    const res = await getGoldPredictions(10)
    if (res.data) historyList.value = res.data
  } catch (e) {}
}

async function refreshAll() {
  refreshing.value = true
  await Promise.allSettled([loadLatestPrice(), loadRealtimeData()])
  refreshing.value = false
}

function switchPeriod(val: number) {
  selectedPeriod.value = val
  loadPriceList()
}

async function handlePredict() {
  predictLoading.value = true
  try {
    const res = await predictGold(predictDays.value, predictAlgorithm.value)
    if (res.data) {
      predictResult.value = res.data
      loadHistory()
    }
  } catch (e) {
    uni.showToast({ title: '预测失败', icon: 'none' })
  } finally {
    predictLoading.value = false
  }
}

function goBack() {
  uni.navigateBack()
}
</script>

<style lang="scss" scoped>
.gold-container {
  min-height: 100vh;
  background: #f5f6fa;
  display: flex;
  flex-direction: column;
}

// ========== 导航栏 ==========
.nav-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 88rpx;
  padding: 0 24rpx;
  background: linear-gradient(135deg, #667eea, #764ba2);
  padding-top: var(--status-bar-height, 0);
}

.nav-back {
  width: 60rpx;
  height: 60rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-back-icon {
  font-size: 48rpx;
  color: #fff;
  font-weight: 300;
}

.nav-title {
  font-size: 34rpx;
  font-weight: 600;
  color: #fff;
}

.nav-refresh {
  width: 60rpx;
  height: 60rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.refresh-icon {
  font-size: 40rpx;
  color: #fff;

  &.spinning {
    animation: spin 1s linear infinite;
  }
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

// ========== 内容区 ==========
.content-wrapper {
  flex: 1;
  padding: 20rpx 30rpx;
}

// ========== 金价卡片 ==========
.price-card {
  background: linear-gradient(135deg, #667eea, #764ba2);
  border-radius: 24rpx;
  padding: 30rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 8rpx 30rpx rgba(102, 126, 234, 0.3);
}

.price-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.price-header-left {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.price-label {
  font-size: 26rpx;
  color: rgba(255, 255, 255, 0.8);
}

.realtime-badge {
  display: flex;
  align-items: center;
  gap: 6rpx;
  padding: 4rpx 12rpx;
  border-radius: 16rpx;
  background: rgba(76, 175, 80, 0.3);
}

.realtime-dot {
  width: 12rpx;
  height: 12rpx;
  border-radius: 50%;
  background: #4caf50;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

.realtime-text {
  font-size: 20rpx;
  color: #fff;
  font-weight: 600;
}

.price-update {
  font-size: 22rpx;
  color: rgba(255, 255, 255, 0.6);
}

.price-main {
  display: flex;
  align-items: baseline;
  gap: 12rpx;
  margin-bottom: 24rpx;
}

.price-value {
  font-size: 64rpx;
  font-weight: 700;
  color: #fff;
}

.price-unit {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.7);
}

.price-change {
  display: flex;
  align-items: center;
  gap: 4rpx;
  padding: 6rpx 14rpx;
  border-radius: 20rpx;

  &.change-up {
    background: rgba(76, 175, 80, 0.3);
  }
  &.change-down {
    background: rgba(244, 67, 54, 0.3);
  }
}

.change-icon {
  font-size: 20rpx;
  color: #fff;
}

.change-value {
  font-size: 24rpx;
  color: #fff;
  font-weight: 600;
}

.price-detail {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16rpx;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 16rpx;
  padding: 20rpx;
}

.detail-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6rpx;
}

.detail-label {
  font-size: 22rpx;
  color: rgba(255, 255, 255, 0.6);
}

.detail-value {
  font-size: 26rpx;
  color: #fff;
  font-weight: 600;
}

// ========== 国际金价 ==========
.intl-card {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 20rpx;
  padding: 24rpx 30rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.04);
}

.intl-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6rpx;
}

.intl-name {
  font-size: 22rpx;
  color: #999;
}

.intl-price {
  font-size: 32rpx;
  font-weight: 700;
  color: #333;
}

.intl-unit {
  font-size: 20rpx;
  color: #bbb;
}

.intl-divider {
  width: 2rpx;
  height: 60rpx;
  background: #f0f0f0;
}

// ========== 通用section ==========
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #333;
}

// ========== 走势图 ==========
.chart-section {
  background: #fff;
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.04);
}

.period-tabs {
  display: flex;
  gap: 12rpx;
}

.period-tab {
  padding: 8rpx 20rpx;
  border-radius: 20rpx;
  background: #f5f6fa;

  &.active {
    background: linear-gradient(135deg, #667eea, #764ba2);
  }
}

.period-text {
  font-size: 24rpx;
  color: #666;

  .active & {
    color: #fff;
    font-weight: 600;
  }
}

.chart-area {
  margin-top: 20rpx;
}

.chart-canvas {
  position: relative;
  height: 300rpx;
  margin: 0 20rpx;
}

.chart-line {
  position: absolute;
  height: 3rpx;
  background: #667eea;
  transform-origin: 0 50%;

  &.predict-line {
    background: #ff6b35;
    border-style: dashed;
  }
}

.chart-point {
  position: absolute;
  transform: translate(-50%, -50%);
  display: flex;
  flex-direction: column;
  align-items: center;
}

.point-dot {
  width: 12rpx;
  height: 12rpx;
  border-radius: 50%;
  background: #667eea;
  border: 3rpx solid #fff;
  box-shadow: 0 2rpx 6rpx rgba(102, 126, 234, 0.3);

  &.predict-dot {
    background: #ff6b35;
    box-shadow: 0 2rpx 6rpx rgba(255, 107, 53, 0.3);
  }
}

.point-label {
  font-size: 18rpx;
  margin-top: 8rpx;
  white-space: nowrap;

  &.label-up {
    color: #4caf50;
  }
  &.label-down {
    color: #f44336;
  }
}

.chart-dates {
  display: flex;
  justify-content: space-between;
  padding: 10rpx 20rpx 0;
}

.chart-date {
  font-size: 20rpx;
  color: #bbb;
}

.chart-empty,
.history-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60rpx 0;
}

.empty-text {
  font-size: 28rpx;
  color: #999;
}

// ========== 预测面板 ==========
.predict-section {
  margin-bottom: 24rpx;
}

.params-card {
  background: #fff;
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.04);
}

.param-row {
  margin-bottom: 24rpx;
}

.param-label {
  font-size: 28rpx;
  font-weight: 600;
  color: #333;
  margin-bottom: 16rpx;
  display: block;
}

.param-options {
  display: flex;
  gap: 16rpx;

  &.algorithm-options {
    flex-wrap: wrap;
  }
}

.param-option {
  padding: 14rpx 28rpx;
  border-radius: 16rpx;
  background: #f5f6fa;
  border: 2rpx solid transparent;

  &.active {
    border-color: #667eea;
    background: rgba(102, 126, 234, 0.08);
  }
}

.option-text {
  font-size: 26rpx;
  color: #666;

  .active & {
    color: #667eea;
    font-weight: 600;
  }
}

.predict-btn {
  width: 100%;
  height: 88rpx;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff;
  border-radius: 44rpx;
  font-size: 30rpx;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  box-shadow: 0 8rpx 20rpx rgba(102, 126, 234, 0.3);

  &::after {
    border: none;
  }
}

// ========== 预测结果 ==========
.result-card {
  background: #fff;
  border-radius: 24rpx;
  padding: 24rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.04);
}

.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}

.result-summary {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.result-label {
  font-size: 28rpx;
  color: #666;
}

.trend-badge {
  display: flex;
  align-items: center;
  gap: 6rpx;
  padding: 8rpx 20rpx;
  border-radius: 20rpx;

  &.trend-up {
    background: rgba(76, 175, 80, 0.1);
  }
  &.trend-down {
    background: rgba(244, 67, 54, 0.1);
  }
  &.trend-stable {
    background: rgba(255, 193, 7, 0.1);
  }
}

.trend-icon {
  font-size: 28rpx;
}

.trend-text {
  font-size: 26rpx;
  font-weight: 600;

  .trend-up & { color: #4caf50; }
  .trend-down & { color: #f44336; }
  .trend-stable & { color: #ff9800; }
}

.result-confidence {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.confidence-label {
  font-size: 24rpx;
  color: #999;
}

.confidence-value {
  font-size: 32rpx;
  font-weight: 700;
  color: #667eea;
}

// ========== 预测走势图 ==========
.predict-chart {
  margin-bottom: 24rpx;
}

.predict-chart-label {
  display: flex;
  gap: 24rpx;
  margin-bottom: 16rpx;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.legend-dot {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;

  &.legend-history { background: #667eea; }
  &.legend-predict { background: #ff6b35; }
}

.legend-text {
  font-size: 22rpx;
  color: #999;
}

.predict-canvas {
  height: 250rpx;
}

// ========== 预测列表 ==========
.predict-list {
  border-top: 1rpx solid #f5f5f5;
  padding-top: 16rpx;
}

.predict-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16rpx 0;
  border-bottom: 1rpx solid #fafafa;

  &:last-child {
    border-bottom: none;
  }
}

.predict-item-left {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.predict-date {
  font-size: 28rpx;
  color: #333;
}

.predict-trend-tag {
  width: 36rpx;
  height: 36rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;

  &.trend-up { background: rgba(76, 175, 80, 0.1); }
  &.trend-down { background: rgba(244, 67, 54, 0.1); }
  &.trend-stable { background: rgba(255, 193, 7, 0.1); }
}

.trend-tag-text {
  font-size: 22rpx;
  font-weight: 700;

  .trend-up & { color: #4caf50; }
  .trend-down & { color: #f44336; }
  .trend-stable & { color: #ff9800; }
}

.predict-item-right {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.predict-price {
  font-size: 30rpx;
  font-weight: 700;
  color: #333;
}

.predict-change {
  font-size: 24rpx;
  font-weight: 600;

  &.text-up { color: #4caf50; }
  &.text-down { color: #f44336; }
}

// ========== 历史记录 ==========
.history-section {
  margin-bottom: 24rpx;
}

.history-list {
  background: #fff;
  border-radius: 24rpx;
  padding: 10rpx 24rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.04);
}

.history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 0;
  border-bottom: 1rpx solid #f5f5f5;

  &:last-child {
    border-bottom: none;
  }
}

.history-left {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.history-algorithm-badge {
  padding: 4rpx 14rpx;
  border-radius: 8rpx;
  background: rgba(102, 126, 234, 0.1);
}

.algorithm-text {
  font-size: 22rpx;
  color: #667eea;
  font-weight: 600;
}

.history-date {
  font-size: 24rpx;
  color: #999;
}

.history-right {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.history-price {
  font-size: 28rpx;
  font-weight: 600;
  color: #333;
}

.history-trend {
  padding: 4rpx 14rpx;
  border-radius: 12rpx;

  &.trend-up { background: rgba(76, 175, 80, 0.1); }
  &.trend-down { background: rgba(244, 67, 54, 0.1); }
  &.trend-stable { background: rgba(255, 193, 7, 0.1); }
}

.history-trend-text {
  font-size: 22rpx;
  font-weight: 600;

  .trend-up & { color: #4caf50; }
  .trend-down & { color: #f44336; }
  .trend-stable & { color: #ff9800; }
}

.bottom-space {
  height: 60rpx;
}
</style>
