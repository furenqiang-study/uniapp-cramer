<template>
  <view class="weather-page">
    <!-- 自定义导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-content">
        <view class="nav-left" @click="goBack">
          <text class="back-icon">‹</text>
        </view>
        <text class="nav-title">天气预报</text>
        <view class="nav-right" @click="toggleCityPicker">
          <text class="city-icon">📍</text>
        </view>
      </view>
    </view>

    <!-- 城市选择面板 -->
    <view v-if="showCityPicker" class="city-picker-mask" @click="toggleCityPicker">
      <view class="city-picker" @click.stop>
        <view class="city-picker-header">
          <text class="city-picker-title">选择城市</text>
          <view class="city-picker-close" @click="toggleCityPicker">
            <text class="close-icon">✕</text>
          </view>
        </view>
        <!-- 搜索框 -->
        <view class="city-search">
          <input
            class="city-search-input"
            v-model="searchText"
            placeholder="输入城市名称搜索"
            @input="onSearchInput"
          />
        </view>
        <!-- 城市网格 -->
        <scroll-view scroll-y class="city-scroll">
          <view v-if="filteredCities.length > 0" class="city-grid">
            <view
              v-for="city in filteredCities"
              :key="city.code"
              :class="['city-item', { active: currentCity === city.name }]"
              @click="selectCity(city.name)"
            >
              <text class="city-item-name">{{ city.name }}</text>
              <text class="city-item-province">{{ city.province }}</text>
            </view>
          </view>
          <view v-else class="city-empty">
            <text class="city-empty-text">未找到匹配城市</text>
          </view>
        </scroll-view>
      </view>
    </view>

    <!-- 主内容区 -->
    <scroll-view scroll-y class="main-scroll" :style="{ height: scrollHeight + 'px' }">
      <!-- 加载状态 -->
      <view v-if="loading && !weatherData" class="loading-wrap">
        <view class="loading-spinner-wrap">
          <view class="loading-spinner"></view>
        </view>
        <text class="loading-text">正在获取天气数据...</text>
      </view>

      <view v-else-if="weatherData" class="weather-content">
        <!-- 当前天气卡片 -->
        <view class="current-card">
          <view class="current-bg"></view>
          <view class="current-info">
            <view class="current-city-row">
              <text class="current-city">📍 {{ weatherData.current.city }}</text>
              <text class="current-update" v-if="weatherData.updateTime">
                {{ weatherData.updateTime.slice(11, 16) }} 更新
              </text>
            </view>
            <view class="current-temp-row">
              <text class="current-icon">{{ weatherData.current.icon }}</text>
              <text class="current-temp">{{ weatherData.current.tempC }}°</text>
            </view>
            <text class="current-desc">{{ weatherData.current.weatherDesc }}</text>
            <!-- 详细信息网格 -->
            <view class="detail-grid">
              <view class="detail-item">
                <text class="detail-icon">💧</text>
                <text class="detail-value">{{ weatherData.current.humidity }}%</text>
                <text class="detail-label">湿度</text>
              </view>
              <view class="detail-item">
                <text class="detail-icon">🌬️</text>
                <text class="detail-value">{{ weatherData.current.windPower || weatherData.current.windSpeedKmph }}</text>
                <text class="detail-label">{{ weatherData.current.windDir16Point }}</text>
              </view>
              <view class="detail-item" v-if="weatherData.current.aqi">
                <text class="detail-icon">🍃</text>
                <text class="detail-value" :style="{ color: getAqiColor(weatherData.current.aqi) }">{{ weatherData.current.aqi }}</text>
                <text class="detail-label">{{ weatherData.current.aqiDesc || '空气质量' }}</text>
              </view>
              <view class="detail-item" v-if="weatherData.current.sunrise">
                <text class="detail-icon">🌅</text>
                <text class="detail-value">{{ weatherData.current.sunrise }}</text>
                <text class="detail-label">日出</text>
              </view>
              <view class="detail-item" v-if="weatherData.current.sunset">
                <text class="detail-icon">🌇</text>
                <text class="detail-value">{{ weatherData.current.sunset }}</text>
                <text class="detail-label">日落</text>
              </view>
              <view class="detail-item" v-if="weatherData.current.visibility && weatherData.current.visibility !== '--'">
                <text class="detail-icon">👁️</text>
                <text class="detail-value">{{ weatherData.current.visibility }}km</text>
                <text class="detail-label">能见度</text>
              </view>
              <view class="detail-item" v-if="weatherData.current.uvIndex && weatherData.current.uvIndex !== '--'">
                <text class="detail-icon">☀️</text>
                <text class="detail-value">{{ weatherData.current.uvIndex }}</text>
                <text class="detail-label">紫外线</text>
              </view>
              <view class="detail-item" v-if="weatherData.current.pressure && weatherData.current.pressure !== '--'">
                <text class="detail-icon">🌡️</text>
                <text class="detail-value">{{ weatherData.current.pressure }}hPa</text>
                <text class="detail-label">气压</text>
              </view>
            </view>
          </view>
        </view>

        <!-- 限行信息 -->
        <view v-if="weatherData.limit" class="limit-section">
          <view class="section-header">
            <text class="section-title">🚗 限行信息</text>
          </view>
          <view class="limit-content">
            <text class="limit-info">今日限行：{{ weatherData.limit.tailNumber }}</text>
            <text class="limit-time" v-if="weatherData.limit.time">({{ weatherData.limit.time }})</text>
          </view>
        </view>

        <!-- 逐小时预报（折线图） -->
        <view v-if="weatherData.hourly && weatherData.hourly.length > 0" class="hourly-section">
          <view class="section-header">
            <text class="section-title">⏰ 逐小时预报</text>
          </view>
          <scroll-view scroll-x class="hourly-scroll">
            <view class="hourly-chart-wrap" :style="{ width: hourlyChartWidth + 'px' }">
              <!-- 温度折线图 -->
              <view class="hourly-chart">
                <!-- 连接线段 -->
                <view
                  v-for="(line, lIdx) in hourlyLines"
                  :key="'line' + lIdx"
                  class="chart-line"
                  :style="{
                    left: line.x + 'px',
                    top: line.y + 'px',
                    width: line.length + 'px',
                    transform: 'rotate(' + line.angle + 'deg)'
                  }"
                ></view>
                <!-- 温度数据点 -->
                <view
                  v-for="(pt, pIdx) in hourlyPoints"
                  :key="'pt' + pIdx"
                  class="chart-dot"
                  :style="{ left: pt.x + 'px', top: pt.y + 'px' }"
                ></view>
                <!-- 温度值标签 -->
                <view
                  v-for="(pt, tIdx) in hourlyPoints"
                  :key="'temp' + tIdx"
                  class="chart-temp-label"
                  :style="{ left: pt.x + 'px', top: (pt.y - 20) + 'px' }"
                >{{ weatherData.hourly[tIdx].tempC }}°</view>
              </view>
              <!-- 时间与天气图标 -->
              <view class="hourly-info-list">
                <view
                  v-for="(h, idx) in weatherData.hourly"
                  :key="idx"
                  class="hourly-info-item"
                >
                  <text class="hourly-time">{{ h.time }}</text>
                  <image v-if="h.weatherUrl" :src="h.weatherUrl" class="hourly-icon-img" mode="aspectFit" />
                  <text v-else class="hourly-icon">{{ h.icon }}</text>
                  <text class="hourly-desc">{{ h.weatherDesc }}</text>
                </view>
              </view>
            </view>
          </scroll-view>
        </view>

        <!-- 未来预报 -->
        <view class="forecast-section">
          <view class="section-header">
            <text class="section-title">📅 未来预报</text>
          </view>
          <view class="forecast-list">
            <view
              v-for="(day, idx) in weatherData.forecast"
              :key="idx"
              class="forecast-card"
            >
              <view class="forecast-left">
                <text class="forecast-date">{{ formatForecastDate(day.date) }}</text>
                <text class="forecast-desc">{{ day.weatherDesc }} / {{ day.weatherNightDesc }}</text>
                <view v-if="day.aqi && day.aqi.aqiName" class="forecast-aqi-tag">
                  <image v-if="day.aqi.aqiUrl" :src="day.aqi.aqiUrl" class="forecast-aqi-icon" mode="aspectFit" />
                  <text class="forecast-aqi-text">{{ day.aqi.aqiName }}</text>
                </view>
              </view>
              <view class="forecast-center">
                <image v-if="day.dayWeatherUrl" :src="day.dayWeatherUrl" class="forecast-icon-img" mode="aspectFit" />
                <text v-else class="forecast-icon">{{ day.icon }}</text>
              </view>
              <view class="forecast-right">
                <view class="forecast-temp-bar">
                  <view class="temp-bar-bg">
                    <view
                      class="temp-bar-fill"
                      :style="{ width: getTempBarWidth(day) + '%', background: getTempBarColor(day) }"
                    ></view>
                  </view>
                  <text class="forecast-temp">{{ day.minTempC }}° / {{ day.maxTempC }}°</text>
                </view>
              </view>
            </view>
          </view>
        </view>

        <!-- 生活指数 -->
        <view v-if="lifeIndexList.length > 0" class="life-index-section">
          <view class="section-header">
            <text class="section-title">💡 生活指数</text>
          </view>
          <view class="life-index-grid">
            <view
              v-for="(item, idx) in lifeIndexList"
              :key="idx"
              class="life-index-item"
              @click="toggleLifeIndexDetail(item)"
            >
              <view class="life-index-row">
                <image v-if="item.url" :src="item.url" class="life-index-icon-img" mode="aspectFit" />
                <text class="life-index-name">{{ item.name }}</text>
                <text class="life-index-info">{{ item.info }}</text>
              </view>
              <view v-if="expandedLifeIndex === item.name && item.detail" class="life-index-detail">
                <text class="life-index-detail-text">{{ item.detail }}</text>
              </view>
            </view>
          </view>
        </view>

        <!-- 备用数据提示 -->
        <view v-if="weatherData.isFallback" class="fallback-tip">
          <text class="fallback-icon">⚠️</text>
          <text class="fallback-text">天气数据暂时无法获取，显示为模拟数据</text>
        </view>
      </view>

      <!-- 空状态 -->
      <view v-else class="empty-wrap">
        <text class="empty-icon">🌤️</text>
        <text class="empty-text">暂无天气数据</text>
        <view class="empty-btn" @click="loadWeather">
          <text class="empty-btn-text">点击重试</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { getWeather, getCities } from '@/api/weather'
import type { WeatherData, CityInfo } from '@/api/weather'

const statusBarHeight = ref(0)
const scrollHeight = ref(0)
const loading = ref(false)
const weatherData = ref<WeatherData | null>(null)
const currentCity = ref('北京')
const showCityPicker = ref(false)
const searchText = ref('')
const cities = ref<CityInfo[]>([])
const expandedLifeIndex = ref('')

// 折线图常量
const CHART_ITEM_WIDTH = 72
const CHART_HEIGHT = 90

// 折线图容器宽度
const hourlyChartWidth = computed(() => {
  if (!weatherData.value?.hourly) return 0
  return weatherData.value.hourly.length * CHART_ITEM_WIDTH
})

// 温度数据点坐标
const hourlyPoints = computed(() => {
  if (!weatherData.value?.hourly?.length) return []
  const items = weatherData.value.hourly
  const temps = items.map(h => parseInt(h.tempC)).filter(t => !isNaN(t))
  if (temps.length === 0) return []
  const minT = Math.min(...temps)
  const maxT = Math.max(...temps)
  const range = maxT - minT || 1
  const padding = 15
  return temps.map((temp, i) => ({
    x: i * CHART_ITEM_WIDTH + CHART_ITEM_WIDTH / 2,
    y: padding + (1 - (temp - minT) / range) * (CHART_HEIGHT - padding * 2),
  }))
})

// 连接线段（位置+角度）
const hourlyLines = computed(() => {
  const pts = hourlyPoints.value
  const lines: Array<{ x: number; y: number; length: number; angle: number }> = []
  for (let i = 0; i < pts.length - 1; i++) {
    const p1 = pts[i]
    const p2 = pts[i + 1]
    const dx = p2.x - p1.x
    const dy = p2.y - p1.y
    const length = Math.sqrt(dx * dx + dy * dy)
    const angle = Math.atan2(dy, dx) * (180 / Math.PI)
    lines.push({ x: p1.x, y: p1.y, length, angle })
  }
  return lines
})

// 生活指数列表（排除非指数字段）
const lifeIndexList = computed(() => {
  if (!weatherData.value?.lifeIndex) return []
  const excludeKeys = ['time']
  return Object.entries(weatherData.value.lifeIndex)
    .filter(([key]) => !excludeKeys.includes(key))
    .map(([, item]) => item)
})

// 搜索过滤城市
const filteredCities = computed(() => {
  if (!searchText.value) return cities.value
  const kw = searchText.value.toLowerCase()
  return cities.value.filter(
    c => c.name.toLowerCase().includes(kw) || c.province.toLowerCase().includes(kw)
  )
})

onMounted(() => {
  const sysInfo = uni.getSystemInfoSync()
  statusBarHeight.value = sysInfo.statusBarHeight || 0
  scrollHeight.value = sysInfo.windowHeight - statusBarHeight.value - 44
  loadCities()
  loadWeather()
})

async function loadCities() {
  try {
    const res = await getCities()
    if (res.code === 200) {
      cities.value = res.data
    }
  } catch (e) {
    console.error('加载城市列表失败:', e)
  }
}

async function loadWeather() {
  loading.value = true
  try {
    const res = await getWeather(currentCity.value)
    if (res.code === 200) {
      weatherData.value = res.data
    }
  } catch (e) {
    console.error('加载天气失败:', e)
  } finally {
    loading.value = false
  }
}

function toggleCityPicker() {
  showCityPicker.value = !showCityPicker.value
  if (showCityPicker.value) searchText.value = ''
}

function selectCity(name: string) {
  currentCity.value = name
  showCityPicker.value = false
  weatherData.value = null
  loadWeather()
}

function onSearchInput() {
  // 搜索由 computed 自动处理
}

function toggleLifeIndexDetail(item: { name: string; detail: string }) {
  if (!item.detail) return
  expandedLifeIndex.value = expandedLifeIndex.value === item.name ? '' : item.name
}

function goBack() {
  uni.navigateBack()
}

function formatForecastDate(dateStr: string): string {
  if (!dateStr) return ''
  const parts = dateStr.split('-')
  if (parts.length >= 3) {
    return `${parseInt(parts[1])}月${parseInt(parts[2])}日`
  }
  return dateStr
}

function getTempBarWidth(day: { minTempC: string; maxTempC: string }): number {
  const min = parseInt(day.minTempC)
  const max = parseInt(day.maxTempC)
  if (isNaN(min) || isNaN(max)) return 50
  const range = max - min
  return Math.max(30, Math.min(100, 30 + range * 8))
}

function getTempBarColor(day: { maxTempC: string }): string {
  const max = parseInt(day.maxTempC)
  if (isNaN(max)) return '#4CAF50'
  if (max >= 35) return '#FF5722'
  if (max >= 30) return '#FF9800'
  if (max >= 20) return '#4CAF50'
  if (max >= 10) return '#2196F3'
  return '#607D8B'
}

function getAqiColor(aqi: string): string {
  const val = parseInt(aqi)
  if (isNaN(val)) return '#4CAF50'
  if (val <= 50) return '#4CAF50'
  if (val <= 100) return '#FFC107'
  if (val <= 150) return '#FF9800'
  if (val <= 200) return '#FF5722'
  if (val <= 300) return '#9C27B0'
  return '#7E0023'
}
</script>

<style scoped>
.weather-page {
  min-height: 100vh;
  background: linear-gradient(180deg, #667eea 0%, #764ba2 30%, #f5f6fa 60%);
}

/* 导航栏 */
.nav-bar {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  position: sticky;
  top: 0;
  z-index: 100;
}
.nav-content {
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 12px;
}
.nav-left, .nav-right {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.back-icon {
  font-size: 28px;
  color: #fff;
  font-weight: bold;
}
.nav-title {
  font-size: 17px;
  font-weight: 600;
  color: #fff;
}
.city-icon {
  font-size: 20px;
}

/* 城市选择面板 */
.city-picker-mask {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  z-index: 200;
  display: flex;
  align-items: flex-end;
}
.city-picker {
  width: 100%;
  max-height: 70vh;
  background: #fff;
  border-radius: 24px 24px 0 0;
  overflow: hidden;
}
.city-picker-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
}
.city-picker-title {
  font-size: 17px;
  font-weight: 600;
  color: #333;
}
.city-picker-close {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.close-icon {
  font-size: 18px;
  color: #999;
}
.city-search {
  padding: 12px 20px;
}
.city-search-input {
  width: 100%;
  height: 40px;
  background: #f5f6fa;
  border-radius: 20px;
  padding: 0 16px;
  font-size: 14px;
}
.city-scroll {
  max-height: calc(70vh - 120px);
  padding: 0 16px 20px;
}
.city-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}
.city-item {
  width: calc(25% - 8px);
  padding: 12px 0;
  background: #f5f6fa;
  border-radius: 12px;
  text-align: center;
  transition: all 0.2s;
}
.city-item.active {
  background: linear-gradient(135deg, #667eea, #764ba2);
}
.city-item.active .city-item-name,
.city-item.active .city-item-province {
  color: #fff;
}
.city-item-name {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  display: block;
}
.city-item-province {
  font-size: 11px;
  color: #999;
  margin-top: 2px;
  display: block;
}
.city-empty {
  padding: 40px 0;
  text-align: center;
}
.city-empty-text {
  color: #999;
  font-size: 14px;
}

/* 加载状态 */
.loading-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding-top: 120px;
}
.loading-spinner-wrap {
  width: 48px;
  height: 48px;
  position: relative;
}
.loading-spinner {
  width: 48px;
  height: 48px;
  border: 3px solid rgba(102, 126, 234, 0.2);
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin {
  to { transform: rotate(360deg); }
}
.loading-text {
  margin-top: 16px;
  font-size: 14px;
  color: #666;
}

/* 当前天气卡片 */
.weather-content {
  padding: 0 16px 24px;
}
.current-card {
  position: relative;
  border-radius: 20px;
  overflow: hidden;
  margin-bottom: 16px;
  margin-top: -20px;
}
.current-bg {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(102,126,234,0.1), rgba(118,75,162,0.08));
  backdrop-filter: blur(10px);
}
.current-info {
  position: relative;
  padding: 20px;
  background: rgba(255,255,255,0.95);
}
.current-city-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}
.current-city {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}
.current-update {
  font-size: 12px;
  color: #999;
}
.current-temp-row {
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 12px 0;
}
.current-icon {
  font-size: 64px;
  margin-right: 16px;
}
.current-temp {
  font-size: 72px;
  font-weight: 200;
  color: #333;
  line-height: 1;
}
.current-desc {
  text-align: center;
  font-size: 18px;
  color: #555;
  font-weight: 500;
}
.current-feels {
  text-align: center;
  font-size: 13px;
  color: #999;
  margin-top: 4px;
  display: block;
}

/* 详情网格 */
.detail-grid {
  display: flex;
  justify-content: space-around;
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}
.detail-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}
.detail-icon {
  font-size: 20px;
}
.detail-value {
  font-size: 14px;
  font-weight: 600;
  color: #333;
}
.detail-label {
  font-size: 11px;
  color: #999;
}

/* 未来预报 */
.forecast-section {
  background: #fff;
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
}
.section-header {
  margin-bottom: 12px;
}
.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}
.forecast-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.forecast-card {
  display: flex;
  align-items: center;
  padding: 12px;
  background: #f8f9fd;
  border-radius: 12px;
}
.forecast-left {
  flex: 1;
}
.forecast-date {
  font-size: 15px;
  font-weight: 600;
  color: #333;
  display: block;
}
.forecast-desc {
  font-size: 12px;
  color: #888;
  margin-top: 2px;
  display: block;
}
.forecast-center {
  width: 50px;
  display: flex;
  justify-content: center;
}
.forecast-icon {
  font-size: 28px;
}
.forecast-right {
  flex: 1;
}
.forecast-temp-bar {
  display: flex;
  align-items: center;
  gap: 8px;
}
.temp-bar-bg {
  flex: 1;
  height: 6px;
  background: #e8e8e8;
  border-radius: 3px;
  overflow: hidden;
}
.temp-bar-fill {
  height: 100%;
  border-radius: 3px;
  transition: width 0.5s ease;
}
.forecast-temp {
  font-size: 13px;
  color: #555;
  white-space: nowrap;
}

/* 限行信息 */
.limit-section {
  background: #fff;
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
  margin-bottom: 16px;
}
.limit-content {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 14px;
  background: #FFF8E1;
  border-radius: 10px;
}
.limit-info {
  font-size: 14px;
  font-weight: 600;
  color: #F57F17;
}
.limit-time {
  font-size: 12px;
  color: #FFB300;
}

/* 逐小时预报（折线图） */
.hourly-section {
  background: #fff;
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
  margin-bottom: 16px;
}
.hourly-scroll {
  white-space: nowrap;
}
.hourly-chart-wrap {
  display: inline-flex;
  flex-direction: column;
}
.hourly-chart {
  position: relative;
  height: 90px;
  margin-bottom: 8px;
}
.chart-line {
  position: absolute;
  height: 2.5px;
  background: linear-gradient(90deg, #667eea, #764ba2);
  transform-origin: 0 50%;
  border-radius: 2px;
}
.chart-dot {
  position: absolute;
  width: 8px;
  height: 8px;
  background: #667eea;
  border: 2px solid #fff;
  border-radius: 50%;
  transform: translate(-50%, -50%);
  box-shadow: 0 1px 4px rgba(102,126,234,0.4);
  z-index: 2;
}
.chart-temp-label {
  position: absolute;
  transform: translateX(-50%);
  font-size: 11px;
  font-weight: 600;
  color: #667eea;
  white-space: nowrap;
  z-index: 3;
}
.hourly-info-list {
  display: flex;
}
.hourly-info-item {
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  min-width: 72px;
}
.hourly-time {
  font-size: 12px;
  color: #888;
}
.hourly-icon-img {
  width: 28px;
  height: 28px;
}
.hourly-icon {
  font-size: 24px;
}
.hourly-desc {
  font-size: 11px;
  color: #999;
  white-space: nowrap;
}

/* 未来预报 - AQI 标签 */
.forecast-aqi-tag {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  margin-top: 4px;
  padding: 2px 8px;
  background: #f0f7f0;
  border-radius: 8px;
}
.forecast-aqi-icon {
  width: 16px;
  height: 16px;
}
.forecast-aqi-text {
  font-size: 11px;
  color: #4CAF50;
}
.forecast-icon-img {
  width: 32px;
  height: 32px;
}

/* 生活指数 */
.life-index-section {
  background: #fff;
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
  margin-bottom: 16px;
}
.life-index-grid {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.life-index-item {
  padding: 10px 12px;
  background: #f8f9fd;
  border-radius: 10px;
}
.life-index-row {
  display: flex;
  align-items: center;
  gap: 8px;
}
.life-index-icon-img {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}
.life-index-name {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  min-width: 60px;
}
.life-index-info {
  font-size: 13px;
  color: #666;
  flex: 1;
}
.life-index-detail {
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px solid #eee;
}
.life-index-detail-text {
  font-size: 12px;
  color: #888;
  line-height: 1.6;
}

/* 备用数据提示 */
.fallback-tip {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 12px;
  margin-top: 12px;
  background: #FFF3E0;
  border-radius: 12px;
}
.fallback-icon {
  font-size: 16px;
}
.fallback-text {
  font-size: 13px;
  color: #E65100;
}

/* 空状态 */
.empty-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 120px;
}
.empty-icon {
  font-size: 64px;
  margin-bottom: 16px;
}
.empty-text {
  font-size: 15px;
  color: #999;
  margin-bottom: 20px;
}
.empty-btn {
  padding: 10px 28px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  border-radius: 20px;
}
.empty-btn-text {
  font-size: 14px;
  color: #fff;
}
</style>