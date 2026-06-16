<template>
  <view class="laptop-container">
    <!-- 顶部导航栏 -->
    <view class="nav-bar">
      <view class="nav-back" @tap="goBack">
        <text class="nav-back-icon">‹</text>
      </view>
      <text class="nav-title">笔记本电脑智能推荐</text>
      <view class="nav-placeholder"></view>
    </view>

    <!-- 步骤指示器 -->
    <view class="steps-bar">
      <view
        class="step-item"
        v-for="(step, index) in steps"
        :key="index"
        :class="{ active: currentStep === index, done: currentStep > index }"
      >
        <view class="step-circle">
          <text class="step-num">{{ currentStep > index ? '✓' : index + 1 }}</text>
        </view>
        <text class="step-label">{{ step }}</text>
      </view>
      <view class="step-line" :style="{ width: `${(currentStep / 3) * 100}%` }"></view>
    </view>

    <!-- 第1步：选择预算 -->
    <view class="step-content" v-if="currentStep === 0">
      <view class="section-card">
        <view class="section-header-row">
          <text class="section-emoji">💰</text>
          <text class="section-main-title">您的预算区间是多少？</text>
        </view>
        <text class="section-desc">选择最适合您的价位档，我们会精准匹配</text>
        <view class="option-list">
          <view
            class="option-card"
            v-for="item in budgets"
            :key="item.value"
            :class="{ selected: selectedBudget === item.value }"
            @tap="selectBudget(item.value)"
          >
            <view class="option-left">
              <text class="option-price">{{ item.label }}</text>
              <text class="option-desc">{{ item.desc }}</text>
            </view>
            <view class="option-check" v-if="selectedBudget === item.value">
              <text class="check-icon">✓</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- 第2步：选择场景 -->
    <view class="step-content" v-if="currentStep === 1">
      <view class="section-card">
        <view class="section-header-row">
          <text class="section-emoji">🎯</text>
          <text class="section-main-title">您的核心办公场景？</text>
        </view>
        <text class="section-desc">可多选，帮助我们了解您的使用需求</text>
        <view class="scene-grid">
          <view
            class="scene-card"
            v-for="item in scenes"
            :key="item.value"
            :class="{ selected: selectedScenes.includes(item.value) }"
            @tap="toggleScene(item.value)"
          >
            <text class="scene-name">{{ item.label }}</text>
            <text class="scene-desc">{{ item.desc }}</text>
            <view class="scene-check" v-if="selectedScenes.includes(item.value)">
              <text class="check-icon">✓</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- 第3步：偏好选择 -->
    <view class="step-content" v-if="currentStep === 2">
      <view class="section-card">
        <view class="section-header-row">
          <text class="section-emoji">⚡</text>
          <text class="section-main-title">您的硬性偏好</text>
        </view>
        <text class="section-desc">选择您最看重的特性（可多选）</text>
        <view class="pref-list">
          <view
            class="pref-item"
            v-for="item in preferences"
            :key="item.value"
            :class="{ selected: selectedPrefs.includes(item.value) }"
            @tap="togglePref(item.value)"
          >
            <view class="pref-left">
              <text class="pref-name">{{ item.label }}</text>
            </view>
            <view class="pref-switch" :class="{ on: selectedPrefs.includes(item.value) }">
              <view class="switch-dot"></view>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- 第4步：额外需求 -->
    <view class="step-content" v-if="currentStep === 3">
      <view class="section-card">
        <view class="section-header-row">
          <text class="section-emoji">✏️</text>
          <text class="section-main-title">其他特殊需求</text>
        </view>
        <text class="section-desc">选填，告诉我们您的个性化需求</text>
        <textarea
          class="extra-input"
          v-model="extraDemand"
          placeholder="例如：需要网口、需要触控屏、必须华为/苹果生态、经常户外使用..."
          :maxlength="200"
        />
        <text class="char-count">{{ extraDemand.length }}/200</text>
      </view>
    </view>

    <!-- 底部按钮 -->
    <view class="bottom-bar">
      <view
        class="btn-prev"
        v-if="currentStep > 0"
        @tap="prevStep"
      >
        <text class="btn-prev-text">上一步</text>
      </view>
      <view
        class="btn-next"
        :class="{ disabled: !canNext }"
        @tap="nextStep"
      >
        <text class="btn-next-text">{{ currentStep === 3 ? '开始推荐' : '下一步' }}</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { getLaptopOptions, recommendLaptop } from '@/api/laptop'

const steps = ['预算', '场景', '偏好', '特殊需求']
const currentStep = ref(0)

// 选项数据
const budgets = ref<any[]>([])
const scenes = ref<any[]>([])
const preferences = ref<any[]>([])

// 用户选择
const selectedBudget = ref('')
const selectedScenes = ref<string[]>([])
const selectedPrefs = ref<string[]>([])
const extraDemand = ref('')

// 是否可下一步
const canNext = computed(() => {
  if (currentStep.value === 0) return !!selectedBudget.value
  if (currentStep.value === 1) return selectedScenes.value.length > 0
  return true
})

onMounted(() => {
  loadOptions()
})

async function loadOptions() {
  try {
    const res = await getLaptopOptions()
    if (res.data) {
      budgets.value = res.data.budgets || []
      scenes.value = res.data.scenes || []
      preferences.value = res.data.preferences || []
    }
  } catch (e) {
    console.error('加载选项失败', e)
  }
}

function selectBudget(value: string) {
  selectedBudget.value = value
}

function toggleScene(value: string) {
  const index = selectedScenes.value.indexOf(value)
  if (index > -1) {
    selectedScenes.value.splice(index, 1)
  } else {
    selectedScenes.value.push(value)
  }
}

function togglePref(value: string) {
  const index = selectedPrefs.value.indexOf(value)
  if (index > -1) {
    selectedPrefs.value.splice(index, 1)
  } else {
    selectedPrefs.value.push(value)
  }
}

function prevStep() {
  if (currentStep.value > 0) {
    currentStep.value--
  }
}

async function nextStep() {
  if (!canNext.value) return

  if (currentStep.value < 3) {
    currentStep.value++
  } else {
    // 提交推荐
    await submitRecommend()
  }
}

async function submitRecommend() {
  uni.showLoading({ title: '智能匹配中...' })
  try {
    const res = await recommendLaptop({
      budget: selectedBudget.value,
      scenes: selectedScenes.value,
      preferences: selectedPrefs.value,
      extra_demand: extraDemand.value,
    })
    uni.hideLoading()
    if (res.data) {
      // 用storage传递数据，避免URL过长导致URI malformed
      uni.setStorageSync('laptopRecommendResult', JSON.stringify(res.data))
      uni.navigateTo({
        url: '/pages/laptop/result',
      })
    }
  } catch (e) {
    uni.hideLoading()
    uni.showToast({ title: '推荐失败，请重试', icon: 'none' })
  }
}

function goBack() {
  uni.navigateBack()
}
</script>

<style lang="scss" scoped>
.laptop-container {
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

// ========== 步骤指示器 ==========
.steps-bar {
  display: flex;
  justify-content: space-between;
  padding: 30rpx 50rpx 20rpx;
  background: #fff;
  position: relative;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.04);
}

.step-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
  z-index: 1;
}

.step-circle {
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  background: #e0e0e0;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.step-item.active .step-circle {
  background: linear-gradient(135deg, #667eea, #764ba2);
}

.step-item.done .step-circle {
  background: #4caf50;
}

.step-num {
  font-size: 24rpx;
  color: #999;
  font-weight: 700;
}

.step-item.active .step-num,
.step-item.done .step-num {
  color: #fff;
}

.step-label {
  font-size: 22rpx;
  color: #999;
}

.step-item.active .step-label {
  color: #667eea;
  font-weight: 600;
}

.step-item.done .step-label {
  color: #4caf50;
}

.step-line {
  position: absolute;
  top: 54rpx;
  left: 50rpx;
  height: 4rpx;
  background: linear-gradient(135deg, #667eea, #764ba2);
  transition: width 0.3s;
}

// ========== 步骤内容 ==========
.step-content {
  padding: 24rpx 30rpx;
}

.section-card {
  background: #fff;
  border-radius: 24rpx;
  padding: 36rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.04);
}

.section-header-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 12rpx;
}

.section-emoji {
  font-size: 40rpx;
}

.section-main-title {
  font-size: 34rpx;
  font-weight: 700;
  color: #333;
}

.section-desc {
  font-size: 26rpx;
  color: #999;
  margin-bottom: 30rpx;
}

// ========== 预算选项 ==========
.option-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.option-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 28rpx 30rpx;
  background: #f8f9fc;
  border-radius: 20rpx;
  border: 2rpx solid transparent;
  transition: all 0.2s;

  &:active {
    transform: scale(0.98);
  }
}

.option-card.selected {
  border-color: #667eea;
  background: rgba(102, 126, 234, 0.06);
}

.option-left {
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.option-price {
  font-size: 30rpx;
  font-weight: 700;
  color: #333;
}

.option-desc {
  font-size: 24rpx;
  color: #999;
}

.option-check {
  width: 44rpx;
  height: 44rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex;
  align-items: center;
  justify-content: center;
}

.check-icon {
  font-size: 24rpx;
  color: #fff;
  font-weight: 700;
}

// ========== 场景选择 ==========
.scene-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 20rpx;
}

.scene-card {
  width: calc(50% - 10rpx);
  padding: 24rpx;
  background: #f8f9fc;
  border-radius: 20rpx;
  border: 2rpx solid transparent;
  position: relative;
  transition: all 0.2s;

  &:active {
    transform: scale(0.97);
  }
}

.scene-card.selected {
  border-color: #667eea;
  background: rgba(102, 126, 234, 0.06);
}

.scene-name {
  font-size: 28rpx;
  font-weight: 700;
  color: #333;
  display: block;
  margin-bottom: 8rpx;
}

.scene-desc {
  font-size: 22rpx;
  color: #999;
  display: block;
}

.scene-check {
  position: absolute;
  top: 16rpx;
  right: 16rpx;
  width: 36rpx;
  height: 36rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex;
  align-items: center;
  justify-content: center;
}

// ========== 偏好开关 ==========
.pref-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.pref-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 28rpx 30rpx;
  background: #f8f9fc;
  border-radius: 20rpx;
  transition: all 0.2s;

  &:active {
    transform: scale(0.98);
  }
}

.pref-item.selected {
  background: rgba(102, 126, 234, 0.06);
}

.pref-left {
  display: flex;
  align-items: center;
}

.pref-name {
  font-size: 28rpx;
  color: #333;
  font-weight: 500;
}

.pref-switch {
  width: 88rpx;
  height: 48rpx;
  border-radius: 24rpx;
  background: #ddd;
  position: relative;
  transition: all 0.3s;
}

.pref-switch.on {
  background: linear-gradient(135deg, #667eea, #764ba2);
}

.switch-dot {
  width: 40rpx;
  height: 40rpx;
  border-radius: 50%;
  background: #fff;
  position: absolute;
  top: 4rpx;
  left: 4rpx;
  transition: all 0.3s;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.15);
}

.pref-switch.on .switch-dot {
  left: 44rpx;
}

// ========== 额外需求 ==========
.extra-input {
  width: 100%;
  height: 200rpx;
  background: #f8f9fc;
  border-radius: 20rpx;
  padding: 24rpx;
  font-size: 28rpx;
  color: #333;
  box-sizing: border-box;
  line-height: 1.6;
}

.char-count {
  display: block;
  text-align: right;
  font-size: 22rpx;
  color: #ccc;
  margin-top: 10rpx;
}

// ========== 底部按钮 ==========
.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  gap: 20rpx;
  padding: 20rpx 30rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  background: #fff;
  box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.04);
}

.btn-prev {
  flex: 1;
  height: 88rpx;
  border-radius: 44rpx;
  background: #f0f0f0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-prev-text {
  font-size: 30rpx;
  color: #666;
  font-weight: 600;
}

.btn-next {
  flex: 2;
  height: 88rpx;
  border-radius: 44rpx;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-next.disabled {
  opacity: 0.5;
}

.btn-next-text {
  font-size: 30rpx;
  color: #fff;
  font-weight: 600;
}
</style>