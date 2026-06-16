<template>
  <view class="result-container">
    <!-- 顶部导航栏 -->
    <view class="nav-bar">
      <view class="nav-back" @tap="goBack">
        <text class="nav-back-icon">‹</text>
      </view>
      <text class="nav-title">推荐结果</text>
      <view class="nav-placeholder"></view>
    </view>

    <!-- 推荐摘要 -->
    <view class="summary-card">
      <text class="summary-emoji">🎯</text>
      <view class="summary-info">
        <text class="summary-title">已为您匹配到3款最优机型</text>
        <text class="summary-desc">预算 {{ resultData.budget }}元 | {{ sceneNames }}</text>
      </view>
    </view>

    <!-- 推荐机型列表 -->
    <view class="laptop-list">
      <view
        class="laptop-card"
        v-for="(laptop, index) in laptops"
        :key="laptop.id"
      >
        <!-- 排名标签 -->
        <view class="rank-badge" :class="`rank-${index}`">
          <text class="rank-text">{{ laptop.rank_label }}</text>
        </view>

        <!-- 基本信息 -->
        <view class="laptop-header">
          <view class="laptop-name-row">
            <text class="laptop-name">{{ laptop.name }}</text>
            <view class="new-tag" v-if="laptop.is_new">
              <text class="new-tag-text">2026新款</text>
            </view>
          </view>
          <view class="laptop-price-row">
            <text class="laptop-price">¥{{ laptop.price_tag }}</text>
            <text class="match-score">匹配度 {{ laptop.match_score }}%</text>
          </view>
        </view>

        <!-- 场景标签 -->
        <view class="tag-row">
          <view class="scene-tag" v-for="tag in laptop.scene_tags" :key="tag">
            <text class="scene-tag-text">{{ tag }}</text>
          </view>
        </view>

        <!-- 综合评分 -->
        <view class="score-section">
          <view class="score-header">
            <text class="score-title">综合性能评分</text>
            <text class="score-total">{{ laptop.score.total }}<text class="score-max">/100</text></text>
          </view>
          <view class="score-bars">
            <view class="score-bar-item" v-for="bar in getScoreBars(laptop.score)" :key="bar.label">
              <text class="bar-label">{{ bar.label }}</text>
              <view class="bar-track">
                <view class="bar-fill" :style="{ width: bar.percent + '%', background: bar.color }"></view>
              </view>
              <text class="bar-value">{{ bar.value }}/{{ bar.max }}</text>
            </view>
          </view>
        </view>

        <!-- 适配说明 -->
        <view class="match-section">
          <text class="match-icon">💡</text>
          <text class="match-text">{{ laptop.match_reason }}</text>
        </view>

        <!-- 配置详情（可展开） -->
        <view class="config-section">
          <view class="config-toggle" @tap="toggleConfig(index)">
            <text class="config-toggle-text">查看完整配置清单</text>
            <text class="config-toggle-arrow">{{ expandedIndex === index ? '▲' : '▼' }}</text>
          </view>
          <view class="config-detail" v-if="expandedIndex === index">
            <view class="config-item">
              <text class="config-label">🖥️ 处理器CPU</text>
              <text class="config-value">{{ laptop.config.cpu }}</text>
              <text class="config-desc">{{ laptop.config.cpu_desc }}</text>
            </view>
            <view class="config-item">
              <text class="config-label">🧠 内存RAM</text>
              <text class="config-value">{{ laptop.config.ram }} {{ laptop.config.ram_type }} {{ laptop.config.ram_freq }}</text>
              <text class="config-desc">{{ laptop.config.ram_desc }}</text>
            </view>
            <view class="config-item">
              <text class="config-label">💾 硬盘ROM</text>
              <text class="config-value">{{ laptop.config.storage }} ({{ laptop.config.storage_type }})</text>
              <text class="config-desc">{{ laptop.config.storage_desc }}</text>
            </view>
            <view class="config-item">
              <text class="config-label">🎮 显卡GPU</text>
              <text class="config-value">{{ laptop.config.gpu }}</text>
              <text class="config-desc">{{ laptop.config.gpu_desc }}</text>
            </view>
            <view class="config-item">
              <text class="config-label">📱 屏幕素质</text>
              <text class="config-value">{{ laptop.config.screen_size }} {{ laptop.config.screen_resolution }} {{ laptop.config.screen_refresh }} {{ laptop.config.screen_color_gamut }}</text>
              <text class="config-desc">{{ laptop.config.screen_desc }}</text>
            </view>
            <view class="config-item">
              <text class="config-label">⚖️ 机身便携</text>
              <text class="config-value">{{ laptop.config.weight }} {{ laptop.config.thickness }} {{ laptop.config.material }}</text>
              <text class="config-desc">{{ laptop.config.portability_desc }}</text>
            </view>
            <view class="config-item">
              <text class="config-label">🔋 续航电池</text>
              <text class="config-value">{{ laptop.config.battery }} | 续航{{ laptop.config.battery_life }} | {{ laptop.config.fast_charge }}</text>
              <text class="config-desc">{{ laptop.config.battery_desc }}</text>
            </view>
            <view class="config-item">
              <text class="config-label">🔌 接口配置</text>
              <text class="config-value">{{ laptop.config.ports }}</text>
              <text class="config-desc">{{ laptop.config.ports_desc }}</text>
            </view>
            <view class="config-item" v-if="laptop.config.features">
              <text class="config-label">✨ 特色功能</text>
              <text class="config-value">{{ laptop.config.features }}</text>
            </view>
          </view>
        </view>

        <!-- 优缺点 -->
        <view class="pros-cons">
          <view class="pros-item">
            <text class="pros-icon">✅</text>
            <text class="pros-text">{{ laptop.pros }}</text>
          </view>
          <view class="cons-item">
            <text class="cons-icon">⚠️</text>
            <text class="cons-text">{{ laptop.cons }}</text>
          </view>
        </view>

        <!-- 去京东购买 -->
        <view class="buy-section" v-if="laptop.buy_url">
          <view class="btn-buy" @tap="openBuyUrl(laptop.buy_url)">
            <text class="btn-buy-text">🛒 去京东查看价格</text>
          </view>
        </view>

        <!-- 购机避坑 -->
        <view class="guide-section" v-if="laptop.buy_guide">
          <view class="guide-header">
            <text class="guide-icon">🛡️</text>
            <text class="guide-title">购机避坑提示</text>
          </view>
          <text class="guide-text">{{ laptop.buy_guide }}</text>
          <view class="suitable-row" v-if="laptop.suitable_for">
            <text class="suitable-label">适合：</text>
            <text class="suitable-value">{{ laptop.suitable_for }}</text>
          </view>
          <view class="suitable-row" v-if="laptop.not_suitable_for">
            <text class="suitable-label warn">不适合：</text>
            <text class="suitable-value">{{ laptop.not_suitable_for }}</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 底部按钮 -->
    <view class="bottom-bar">
      <view class="btn-restart" @tap="restart">
        <text class="btn-restart-text">重新推荐</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'

const resultData = ref<any>({
  budget: '',
  scenes: [],
  preferences: [],
  laptops: [],
})

const expandedIndex = ref(-1)

const laptops = computed(() => resultData.value.laptops || [])

const sceneNames = computed(() => {
  const map: Record<string, string> = {
    basic: '基础办公', multi: '多任务办公', design: '设计美工',
    video: '视频剪辑', '3d': '三维建模', ai: 'AI办公',
    travel: '商旅便携', entertainment: '轻度娱乐',
  }
  return (resultData.value.scenes || []).map((s: string) => map[s] || s).join('、')
})

onLoad(() => {
  try {
    const stored = uni.getStorageSync('laptopRecommendResult')
    if (stored) {
      resultData.value = JSON.parse(stored)
      uni.removeStorageSync('laptopRecommendResult')
    }
  } catch (e) {
    console.error('解析推荐结果失败', e)
  }
})

function getScoreBars(score: any) {
  return [
    { label: '办公性能', value: score.office, max: 30, percent: (score.office / 30) * 100, color: '#667eea' },
    { label: '图形设计', value: score.graphics, max: 20, percent: (score.graphics / 20) * 100, color: '#f093fb' },
    { label: '流畅续航', value: score.fluency, max: 20, percent: (score.fluency / 20) * 100, color: '#4facfe' },
    { label: '便携质感', value: score.portability, max: 15, percent: (score.portability / 15) * 100, color: '#43e97b' },
    { label: '性价比', value: score.value, max: 15, percent: (score.value / 15) * 100, color: '#fa709a' },
  ]
}

function toggleConfig(index: number) {
  expandedIndex.value = expandedIndex.value === index ? -1 : index
}

function goBack() {
  uni.navigateBack()
}

function openBuyUrl(url: string) {
  // #ifdef H5
  window.open(url, '_blank')
  // #endif
  // #ifndef H5
  uni.setClipboardData({
    data: url,
    success: () => {
      uni.showToast({ title: '链接已复制，请在浏览器打开', icon: 'none' })
    }
  })
  // #endif
}

function restart() {
  uni.navigateBack()
}
</script>

<style lang="scss" scoped>
.result-container {
  min-height: 100vh;
  background: #f5f6fa;
  padding-bottom: 140rpx;
}

// ========== 导航栏 ==========
.nav-bar {
  background: linear-gradient(135deg, #667eea, #764ba2);
  padding: 60rpx 30rpx 30rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
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
  font-weight: 700;
  color: #fff;
}

.nav-placeholder {
  width: 60rpx;
}

// ========== 推荐摘要 ==========
.summary-card {
  margin: 24rpx 30rpx;
  padding: 30rpx;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08), rgba(118, 75, 162, 0.08));
  border-radius: 20rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
  border: 2rpx solid rgba(102, 126, 234, 0.15);
}

.summary-emoji {
  font-size: 48rpx;
}

.summary-info {
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.summary-title {
  font-size: 30rpx;
  font-weight: 700;
  color: #333;
}

.summary-desc {
  font-size: 24rpx;
  color: #666;
}

// ========== 机型列表 ==========
.laptop-list {
  padding: 0 30rpx;
  display: flex;
  flex-direction: column;
  gap: 30rpx;
}

.laptop-card {
  background: #fff;
  border-radius: 24rpx;
  padding: 0;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.06);
  overflow: hidden;
  position: relative;
}

// 排名标签
.rank-badge {
  padding: 12rpx 30rpx;
  display: inline-flex;
}

.rank-0 {
  background: linear-gradient(135deg, #ff6b35, #f7931e);
}

.rank-1 {
  background: linear-gradient(135deg, #667eea, #764ba2);
}

.rank-2 {
  background: linear-gradient(135deg, #43e97b, #38f9d7);
}

.rank-text {
  font-size: 24rpx;
  font-weight: 700;
  color: #fff;
}

// 基本信息
.laptop-header {
  padding: 20rpx 30rpx 0;
}

.laptop-name-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 12rpx;
}

.laptop-name {
  font-size: 32rpx;
  font-weight: 700;
  color: #333;
}

.new-tag {
  background: rgba(255, 107, 53, 0.1);
  border-radius: 8rpx;
  padding: 4rpx 12rpx;
}

.new-tag-text {
  font-size: 20rpx;
  color: #ff6b35;
  font-weight: 600;
}

.laptop-price-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.laptop-price {
  font-size: 36rpx;
  font-weight: 700;
  color: #ff6b35;
}

.match-score {
  font-size: 24rpx;
  color: #667eea;
  font-weight: 600;
  background: rgba(102, 126, 234, 0.08);
  padding: 6rpx 16rpx;
  border-radius: 20rpx;
}

// 场景标签
.tag-row {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
  padding: 16rpx 30rpx 0;
}

.scene-tag {
  background: #f0f4ff;
  border-radius: 12rpx;
  padding: 6rpx 16rpx;
}

.scene-tag-text {
  font-size: 22rpx;
  color: #667eea;
}

// 评分
.score-section {
  margin: 20rpx 30rpx 0;
  padding: 24rpx;
  background: #f8f9fc;
  border-radius: 20rpx;
}

.score-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.score-title {
  font-size: 26rpx;
  font-weight: 600;
  color: #666;
}

.score-total {
  font-size: 40rpx;
  font-weight: 700;
  color: #ff6b35;
}

.score-max {
  font-size: 24rpx;
  color: #ccc;
  font-weight: 400;
}

.score-bars {
  display: flex;
  flex-direction: column;
  gap: 14rpx;
}

.score-bar-item {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.bar-label {
  font-size: 22rpx;
  color: #999;
  width: 120rpx;
  flex-shrink: 0;
}

.bar-track {
  flex: 1;
  height: 16rpx;
  background: #e8e8e8;
  border-radius: 8rpx;
  overflow: hidden;
}

.bar-fill {
  height: 100%;
  border-radius: 8rpx;
  transition: width 0.5s ease;
}

.bar-value {
  font-size: 22rpx;
  color: #666;
  width: 80rpx;
  text-align: right;
  flex-shrink: 0;
}

// 适配说明
.match-section {
  margin: 16rpx 30rpx 0;
  padding: 20rpx 24rpx;
  background: rgba(102, 126, 234, 0.04);
  border-radius: 16rpx;
  display: flex;
  gap: 12rpx;
  border-left: 6rpx solid #667eea;
}

.match-icon {
  font-size: 28rpx;
  flex-shrink: 0;
}

.match-text {
  font-size: 24rpx;
  color: #555;
  line-height: 1.6;
}

// 配置详情
.config-section {
  margin: 16rpx 30rpx 0;
}

.config-toggle {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 0;
  border-top: 1rpx solid #f0f0f0;
}

.config-toggle-text {
  font-size: 26rpx;
  color: #667eea;
  font-weight: 500;
}

.config-toggle-arrow {
  font-size: 22rpx;
  color: #667eea;
}

.config-detail {
  padding: 0 0 10rpx;
}

.config-item {
  padding: 16rpx 0;
  border-bottom: 1rpx solid #f5f5f5;

  &:last-child {
    border-bottom: none;
  }
}

.config-label {
  font-size: 24rpx;
  font-weight: 600;
  color: #333;
  display: block;
  margin-bottom: 8rpx;
}

.config-value {
  font-size: 26rpx;
  color: #333;
  display: block;
  margin-bottom: 6rpx;
}

.config-desc {
  font-size: 22rpx;
  color: #999;
  line-height: 1.5;
  display: block;
}

// 优缺点
.pros-cons {
  margin: 16rpx 30rpx 0;
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.pros-item,
.cons-item {
  display: flex;
  gap: 12rpx;
  align-items: flex-start;
}

.pros-icon,
.cons-icon {
  font-size: 24rpx;
  flex-shrink: 0;
  margin-top: 2rpx;
}

.pros-text {
  font-size: 24rpx;
  color: #4caf50;
  line-height: 1.5;
}

.cons-text {
  font-size: 24rpx;
  color: #ff9800;
  line-height: 1.5;
}

// 去京东购买按钮
.buy-section {
  margin: 20rpx 30rpx 0;
}

.btn-buy {
  height: 80rpx;
  border-radius: 40rpx;
  background: linear-gradient(135deg, #e53935, #ff5252);
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-buy-text {
  font-size: 28rpx;
  color: #fff;
  font-weight: 600;
}

// 购机避坑
.guide-section {
  margin: 16rpx 30rpx 0;
  padding: 20rpx 24rpx;
  background: #fff9f0;
  border-radius: 16rpx;
  margin-bottom: 30rpx;
}

.guide-header {
  display: flex;
  align-items: center;
  gap: 10rpx;
  margin-bottom: 12rpx;
}

.guide-icon {
  font-size: 28rpx;
}

.guide-title {
  font-size: 26rpx;
  font-weight: 600;
  color: #333;
}

.guide-text {
  font-size: 24rpx;
  color: #666;
  line-height: 1.6;
  display: block;
  margin-bottom: 12rpx;
}

.suitable-row {
  display: flex;
  gap: 8rpx;
  margin-top: 8rpx;
}

.suitable-label {
  font-size: 22rpx;
  color: #4caf50;
  font-weight: 600;
  flex-shrink: 0;
}

.suitable-label.warn {
  color: #ff5722;
}

.suitable-value {
  font-size: 22rpx;
  color: #666;
}

// ========== 底部按钮 ==========
.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 20rpx 30rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  background: #fff;
  box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.04);
}

.btn-restart {
  height: 88rpx;
  border-radius: 44rpx;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-restart-text {
  font-size: 30rpx;
  color: #fff;
  font-weight: 600;
}
</style>