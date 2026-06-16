<template>
  <view class="earth-container">
    <!-- 顶部栏 -->
    <view class="top-bar">
      <view class="back-btn" @tap="goBack">
        <text class="back-icon">‹</text>
        <text class="back-text">返回</text>
      </view>
      <text class="page-title">🌍 漫游地球</text>
      <view class="placeholder"></view>
    </view>

    <!-- 搜索栏 -->
    <view class="search-bar">
      <input
        class="search-input"
        v-model="searchCity"
        placeholder="输入城市名称，如：北京"
        confirm-type="search"
        @confirm="searchLocation"
      />
      <view class="search-btn" @tap="searchLocation">
        <text class="search-btn-text">定位</text>
      </view>
    </view>

    <!-- 搜索结果提示 -->
    <view class="search-tip" v-if="tipText">
      <text class="tip-text">{{ tipText }}</text>
    </view>

    <!-- Cesium 容器 -->
    <view class="cesium-wrap">
      <view id="cesiumContainer" class="cesium-container"></view>
    </view>

    <!-- 快捷城市 -->
    <view class="quick-cities">
      <text class="quick-title">快捷城市：</text>
      <view class="city-tags">
        <view class="city-tag" v-for="city in quickCities" :key="city.name" @tap="flyToCity(city)">
          <text class="city-tag-text">{{ city.name }}</text>
        </view>
      </view>
    </view>

    <!-- 航线飞行 -->
    <view class="flight-section">
      <text class="quick-title">✈️ 航线飞行：</text>
      <view class="city-tags">
        <view class="flight-tag" v-for="f in flightRoutes" :key="f.name" @tap="startFlight(f)">
          <text class="flight-tag-text">{{ f.name }}</text>
        </view>
      </view>
      <view class="flight-controls" v-if="isFlying">
        <view class="flight-btn" @tap="togglePause">
          <text class="flight-btn-text">{{ isPaused ? '▶️ 继续' : '⏸ 暂停' }}</text>
        </view>
        <view class="flight-btn" @tap="stopFlight">
          <text class="flight-btn-text">⏹ 停止</text>
        </view>
        <text class="flight-info">{{ flightInfo }}</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
declare const Cesium: any

const searchCity = ref('')
const tipText = ref('')
let viewer: any = null

// 航线飞行相关
const isFlying = ref(false)
const isPaused = ref(false)
const flightInfo = ref('')
let flightEntities: any[] = []
let flightListener: any = null
let flightStartTime: any = null
let flightDuration = 30 // 秒
let pauseTime = 0
let pausedAt = 0

interface CityInfo { name: string; lon: number; lat: number; height?: number }
interface FlightRoute { name: string; from: CityInfo; to: CityInfo; color?: string }
const flightRoutes: FlightRoute[] = [
  { name: '北京→纽约', from: { name: '北京', lon: 116.4074, lat: 39.9042 }, to: { name: '纽约', lon: -74.006, lat: 40.7128 }, color: '#00f2fe' },
  { name: '上海→巴黎', from: { name: '上海', lon: 121.4737, lat: 31.2304 }, to: { name: '巴黎', lon: 2.3522, lat: 48.8566 }, color: '#ff6b6b' },
  { name: '北京→东京', from: { name: '北京', lon: 116.4074, lat: 39.9042 }, to: { name: '东京', lon: 139.6917, lat: 35.6895 }, color: '#ffd93d' },
  { name: '伦敦→悉尼', from: { name: '伦敦', lon: -0.1276, lat: 51.5074 }, to: { name: '悉尼', lon: 151.2093, lat: -33.8688 }, color: '#6bcb77' },
  { name: '迪拜→纽约', from: { name: '迪拜', lon: 55.2708, lat: 25.2048 }, to: { name: '纽约', lon: -74.006, lat: 40.7128 }, color: '#9b59b6' },
  { name: '上海→伦敦', from: { name: '上海', lon: 121.4737, lat: 31.2304 }, to: { name: '伦敦', lon: -0.1276, lat: 51.5074 }, color: '#e67e22' }
]

const quickCities: CityInfo[] = [
  { name: '北京', lon: 116.4074, lat: 39.9042, height: 50000 },
  { name: '上海', lon: 121.4737, lat: 31.2304, height: 50000 },
  { name: '东京', lon: 139.6917, lat: 35.6895, height: 80000 },
  { name: '纽约', lon: -74.006, lat: 40.7128, height: 80000 },
  { name: '巴黎', lon: 2.3522, lat: 48.8566, height: 80000 },
  { name: '伦敦', lon: -0.1276, lat: 51.5074, height: 80000 },
  { name: '悉尼', lon: 151.2093, lat: -33.8688, height: 80000 },
  { name: '迪拜', lon: 55.2708, lat: 25.2048, height: 80000 },
  { name: '罗马', lon: 12.4964, lat: 41.9028, height: 80000 },
  { name: '莫斯科', lon: 37.6173, lat: 55.7558, height: 80000 }
]

function initCesium() {
  const container = document.getElementById('cesiumContainer')
  if (!container) return

  // Cesium Ion Token（使用默认公开token，正式环境建议替换）
  Cesium.Ion.defaultAccessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJlYWE1OWUxNy1mMWZiLTQzYjYtYTQ0OS1kMWFjYmFkNjc5YzciLCJpZCI6NDQzNDEsImlhdCI6MTYxMzY2NTk3NH0.v3UbHbj_lpFj3FClMJa6WDnOChkQjOQRiKdHB5mFBmg'

  viewer = new Cesium.Viewer('cesiumContainer', {
    animation: false,
    timeline: false,
    baseLayerPicker: false,
    geocoder: false,
    homeButton: false,
    sceneModePicker: false,
    navigationHelpButton: false,
    fullscreenButton: false,
    infoBox: false,
    selectionIndicator: false,
    shouldAnimate: true,
    requestRenderMode: false,
    // 天地图影像底图（EPSG:4326 投影）
    baseLayer: new Cesium.ImageryLayer(
      new Cesium.WebMapTileServiceImageryProvider({
        url: 'http://{s}.tianditu.gov.cn/img_c/wmts?service=wmts&request=GetTile&version=1.0.0&LAYER=img&tileMatrixSet=c&TileMatrix={TileMatrix}&TileRow={TileRow}&TileCol={TileCol}&style=default&format=tiles&tk=440b96d736fad95da7934bc130a2258a',
        layer: 'tdtImg_c',
        style: 'default',
        format: 'tiles',
        tileMatrixSetID: 'c',
        subdomains: ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7'],
        tilingScheme: new Cesium.GeographicTilingScheme(),
        tileMatrixLabels: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19'],
        maximumLevel: 18
      })
    )
  })

  // 天地图注记层（中文标注）
  viewer.imageryLayers.add(new Cesium.ImageryLayer(
    new Cesium.WebMapTileServiceImageryProvider({
      url: 'http://{s}.tianditu.gov.cn/cia_c/wmts?service=wmts&request=GetTile&version=1.0.0&LAYER=cia&tileMatrixSet=c&TileMatrix={TileMatrix}&TileRow={TileRow}&TileCol={TileCol}&style=default&format=tiles&tk=440b96d736fad95da7934bc130a2258a',
      layer: 'tdtCia_c',
      style: 'default',
      format: 'tiles',
      tileMatrixSetID: 'c',
      subdomains: ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7'],
      tilingScheme: new Cesium.GeographicTilingScheme(),
      tileMatrixLabels: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19'],
      maximumLevel: 18
    })
  ))

  // 去掉 Cesium 水印
  const cesiumWidget = container.querySelector('.cesium-widget-credits')
  if (cesiumWidget) (cesiumWidget as HTMLElement).style.display = 'none'

  // 初始视角：全球概览，稍偏中国
  viewer.camera.setView({
    destination: Cesium.Cartesian3.fromDegrees(105, 30, 8000000)
  })
}

function flyToCity(city: CityInfo) {
  if (!viewer) return
  tipText.value = `正在飞往 ${city.name}...`
  viewer.camera.flyTo({
    destination: Cesium.Cartesian3.fromDegrees(city.lon, city.lat, city.height || 50000),
    duration: 3,
    complete: () => {
      tipText.value = `已到达 ${city.name} (${city.lat.toFixed(2)}°N, ${city.lon.toFixed(2)}°E)`
      setTimeout(() => { tipText.value = '' }, 3000)
    }
  })
}

async function searchLocation() {
  const city = searchCity.value.trim()
  if (!city) {
    uni.showToast({ title: '请输入城市名称', icon: 'none' })
    return
  }
  tipText.value = `正在搜索 "${city}"...`

  try {
    // 使用 Nominatim（OpenStreetMap）免费地理编码
    const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(city)}&format=json&limit=1&accept-language=zh-CN`
    const res = await fetch(url, {
      headers: { 'User-Agent': 'UniApp-RoamEarth/1.0' }
    })
    const data = await res.json()

    if (data && data.length > 0) {
      const result = data[0]
      const lon = parseFloat(result.lon)
      const lat = parseFloat(result.lat)
      const displayName = result.display_name?.split(',')[0] || city

      tipText.value = `定位到：${displayName} (${lat.toFixed(2)}°N, ${lon.toFixed(2)}°E)`
      if (!viewer) return

      viewer.camera.flyTo({
        destination: Cesium.Cartesian3.fromDegrees(lon, lat, 30000),
        duration: 3,
        complete: () => {
          // 添加标记点
          viewer.entities.add({
            position: Cesium.Cartesian3.fromDegrees(lon, lat),
            point: { pixelSize: 12, color: Cesium.Color.RED },
            label: {
              text: displayName,
              font: '16px sans-serif',
              fillColor: Cesium.Color.WHITE,
              outlineColor: Cesium.Color.BLACK,
              outlineWidth: 2,
              style: Cesium.LabelStyle.FILL_AND_OUTLINE,
              verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
              pixelOffset: new Cesium.Cartesian2(0, -20)
            }
          })
          setTimeout(() => { tipText.value = '' }, 4000)
        }
      })
    } else {
      tipText.value = `未找到 "${city}"，请检查输入`
      setTimeout(() => { tipText.value = '' }, 3000)
    }
  } catch (e) {
    tipText.value = '搜索失败，请检查网络连接'
    setTimeout(() => { tipText.value = '' }, 3000)
  }
}

// ==================== 航线飞行动画 ====================
function startFlight(route: FlightRoute) {
  if (!viewer) return
  stopFlight() // 清理之前的

  const { from, to } = route
  const color = Cesium.Color.fromCssColorString(route.color || '#00f2fe')
  const positions: any[] = []
  const numPoints = 200

  // 生成弧形航线（大圆弧 + 高度抛物线）
  for (let i = 0; i <= numPoints; i++) {
    const t = i / numPoints
    const lon = from.lon + (to.lon - from.lon) * t
    const lat = from.lat + (to.lat - from.lat) * t
    // 高度抛物线：中间最高
    const arcHeight = Math.sin(t * Math.PI) * 800000
    positions.push(Cesium.Cartesian3.fromDegrees(lon, lat, arcHeight))
  }

  // 1. 航线路径（发光线条）
  const pathEntity = viewer.entities.add({
    polyline: {
      positions: positions,
      width: 3,
      material: new Cesium.PolylineGlowMaterialProperty({
        glowPower: 0.2,
        color: color
      }),
      clampToGround: false
    }
  })
  flightEntities.push(pathEntity)

  // 2. 起点标记
  const fromEntity = viewer.entities.add({
    position: Cesium.Cartesian3.fromDegrees(from.lon, from.lat),
    point: { pixelSize: 10, color: Cesium.Color.GREEN },
    label: {
      text: '🛫 ' + from.name,
      font: '14px sans-serif',
      fillColor: Cesium.Color.WHITE,
      outlineColor: Cesium.Color.BLACK,
      outlineWidth: 2,
      style: Cesium.LabelStyle.FILL_AND_OUTLINE,
      verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
      pixelOffset: new Cesium.Cartesian2(0, -15)
    }
  })
  flightEntities.push(fromEntity)

  // 3. 终点标记
  const toEntity = viewer.entities.add({
    position: Cesium.Cartesian3.fromDegrees(to.lon, to.lat),
    point: { pixelSize: 10, color: Cesium.Color.RED },
    label: {
      text: '🛬 ' + to.name,
      font: '14px sans-serif',
      fillColor: Cesium.Color.WHITE,
      outlineColor: Cesium.Color.BLACK,
      outlineWidth: 2,
      style: Cesium.LabelStyle.FILL_AND_OUTLINE,
      verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
      pixelOffset: new Cesium.Cartesian2(0, -15)
    }
  })
  flightEntities.push(toEntity)

  // 4. 飞机实体（GLB 3D模型沿路径移动）
  const planeEntity = viewer.entities.add({
    position: new Cesium.CallbackProperty(() => {
      if (!flightStartTime) return positions[0]
      const now = Cesium.JulianDate.now()
      let elapsed = Cesium.JulianDate.secondsDifference(now, flightStartTime) - pauseTime
      if (elapsed < 0) elapsed = 0
      const t = Math.min(elapsed / flightDuration, 1)
      const idx = Math.floor(t * numPoints)
      return positions[Math.min(idx, numPoints)]
    }, false),
    orientation: new Cesium.CallbackProperty(() => {
      if (!flightStartTime) return Cesium.Quaternion.IDENTITY
      const now = Cesium.JulianDate.now()
      let elapsed = Cesium.JulianDate.secondsDifference(now, flightStartTime) - pauseTime
      if (elapsed < 0) elapsed = 0
      const t = Math.min(elapsed / flightDuration, 1)
      const idx = Math.min(Math.floor(t * numPoints), numPoints - 1)
      if (idx < 0 || idx >= positions.length - 1) return Cesium.Quaternion.IDENTITY
      // 计算飞行方向
      const curPos = positions[idx]
      const nextPos = positions[Math.min(idx + 1, numPoints)]
      const heading = Math.atan2(
        nextPos.x - curPos.x,
        nextPos.y - curPos.y
      )
      // 稍微倾斜（模拟爬升/下降）
      const pitch = (t < 0.15) ? 0.15 : (t > 0.85) ? -0.15 : 0
      const hpr = new Cesium.HeadingPitchRoll(heading, pitch, 0)
      return Cesium.Transforms.headingPitchRollQuaternion(curPos, hpr)
    }, false),
    model: {
      uri: "/uniapp-cramer/earth/Cesium_Air.glb",
      minimumPixelSize: 48,
      maximumScale: 20000,
      silhouetteSize: 2,
      silhouetteColor: Cesium.Color.WHITE
    },
    label: {
      text: '✈️ ' + route.name,
      font: '16px sans-serif',
      fillColor: Cesium.Color.YELLOW,
      outlineColor: Cesium.Color.BLACK,
      outlineWidth: 2,
      style: Cesium.LabelStyle.FILL_AND_OUTLINE,
      verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
      pixelOffset: new Cesium.Cartesian2(0, -30)
    }
  })
  flightEntities.push(planeEntity)

  // 5. 尾迹粒子效果（渐隐线条）
  const trailPositions: any[] = []
  const trailEntity = viewer.entities.add({
    polyline: {
      positions: new Cesium.CallbackProperty(() => {
        return [...trailPositions]
      }, false),
      width: 5,
      material: new Cesium.PolylineGlowMaterialProperty({
        glowPower: 0.4,
        color: new Cesium.CallbackProperty(() => {
          const alpha = 0.8
          return new Cesium.Color(color.red, color.green, color.blue, alpha)
        }, false)
      })
    }
  })
  flightEntities.push(trailEntity)

  // 启动飞行计时器
  flightStartTime = Cesium.JulianDate.now()
  pauseTime = 0
  pausedAt = 0
  isFlying.value = true
  isPaused.value = false
  flightDuration = route.name.includes('→') ? 30 : 20

  // 尾迹更新
  flightListener = () => {
    if (!flightStartTime || isPaused.value) return
    const now = Cesium.JulianDate.now()
    let elapsed = Cesium.JulianDate.secondsDifference(now, flightStartTime) - pauseTime
    if (elapsed < 0) elapsed = 0
    const t = Math.min(elapsed / flightDuration, 1)
    const idx = Math.floor(t * numPoints)

    // 更新尾迹（保留最近30个点）
    if (idx > 0 && idx < positions.length) {
      const start = Math.max(0, idx - 30)
      trailPositions.length = 0
      for (let i = start; i <= idx; i++) trailPositions.push(positions[i])
    }

    // 更新飞行信息
    const percent = Math.floor(t * 100)
    flightInfo.value = `${route.from.name} → ${route.to.name}  ${percent}%`

    // 飞行结束
    if (t >= 1) {
      flightInfo.value = `🎉 ${route.from.name} → ${route.to.name} 到达！`
      setTimeout(() => stopFlight(), 5000)
    }
  }

  // 添加时钟监听
  viewer.clock.onTick.addEventListener(flightListener)

  // 相机跟随飞机
  viewer.clock.onTick.addEventListener(() => {
    if (!flightStartTime || isPaused.value) return
    const now = Cesium.JulianDate.now()
    let elapsed = Cesium.JulianDate.secondsDifference(now, flightStartTime) - pauseTime
    const t = Math.min(elapsed / flightDuration, 1)
    const idx = Math.floor(t * numPoints)
    if (idx >= 0 && idx < positions.length) {
      const pos = positions[idx]
      // 平滑跟随（不覆盖用户手动操作）
    }
  })

  // 初始视角：看航线全景
  viewer.camera.flyTo({
    destination: Cesium.Cartesian3.fromDegrees(
      (from.lon + to.lon) / 2,
      (from.lat + to.lat) / 2,
      Math.max(Math.abs(to.lon - from.lon), Math.abs(to.lat - from.lat)) * 80000
    ),
    duration: 2
  })

  flightInfo.value = `${route.from.name} → ${route.to.name}  出发！`
}

function togglePause() {
  if (!viewer || !flightStartTime) return
  if (isPaused.value) {
    // 继续：补偿暂停时间
    pauseTime += Cesium.JulianDate.secondsDifference(Cesium.JulianDate.now(), pausedAt)
    viewer.clock.shouldAnimate = true
    isPaused.value = false
  } else {
    // 暂停
    pausedAt = Cesium.JulianDate.now()
    viewer.clock.shouldAnimate = false
    isPaused.value = true
  }
}

function stopFlight() {
  if (viewer) {
    if (flightListener) {
      viewer.clock.onTick.removeEventListener(flightListener)
      flightListener = null
    }
    flightEntities.forEach(e => { try { viewer.entities.remove(e) } catch(ex) {} })
  }
  flightEntities = []
  flightStartTime = null
  pauseTime = 0
  pausedAt = 0
  isFlying.value = false
  isPaused.value = false
  flightInfo.value = ''
}

function goBack() {
  stopFlight()
  uni.navigateBack()
}

onMounted(() => {
  // Cesium 是通过 CDN 全局加载的，需要等待 DOM 完全渲染后再初始化
  setTimeout(() => {
    if (typeof Cesium !== 'undefined') {
      try {
        initCesium()
      } catch(e) {
        console.error('Cesium init error:', e)
        tipText.value = 'Cesium 初始化失败: ' + (e as Error).message
      }
    } else {
      tipText.value = 'Cesium 加载失败，请检查网络'
    }
  }, 1000)
})

onUnmounted(() => {
  if (viewer) {
    viewer.destroy()
    viewer = null
  }
})
</script>

<style lang="scss" scoped>
.earth-container {
  min-height: 100vh;
  background: #0a0e27;
  display: flex;
  flex-direction: column;
}

/* 顶部栏 */
.top-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 50rpx 30rpx 20rpx;
  background: rgba(10, 14, 39, 0.95);
  position: relative;
  z-index: 10;
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 4rpx;
}

.back-icon {
  font-size: 48rpx;
  color: #fff;
  font-weight: 700;
}

.back-text {
  font-size: 28rpx;
  color: #aaa;
}

.page-title {
  font-size: 34rpx;
  font-weight: 700;
  color: #fff;
}

.placeholder { width: 80rpx; }

/* 搜索栏 */
.search-bar {
  display: flex;
  align-items: center;
  gap: 16rpx;
  padding: 16rpx 30rpx;
  background: rgba(10, 14, 39, 0.9);
  position: relative;
  z-index: 10;
}

.search-input {
  flex: 1;
  height: 72rpx;
  background: rgba(255, 255, 255, 0.1);
  border: 2rpx solid rgba(255, 255, 255, 0.2);
  border-radius: 36rpx;
  padding: 0 30rpx;
  color: #fff;
  font-size: 28rpx;
}

.search-input::placeholder {
  color: rgba(255, 255, 255, 0.4);
}

.search-btn {
  height: 72rpx;
  padding: 0 36rpx;
  background: linear-gradient(135deg, #4facfe, #00f2fe);
  border-radius: 36rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.search-btn-text {
  color: #fff;
  font-size: 28rpx;
  font-weight: 600;
}

/* 搜索提示 */
.search-tip {
  padding: 10rpx 30rpx;
  background: rgba(10, 14, 39, 0.85);
  position: relative;
  z-index: 10;
}

.tip-text {
  font-size: 24rpx;
  color: #4facfe;
}

/* Cesium 容器 - 占满剩余空间 */
.cesium-wrap {
  flex: 1;
  position: relative;
  width: 100%;
  min-height: 0;
}

.cesium-container {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

/* 覆盖 Cesium 默认样式 */
:deep(.cesium-viewer) {
  position: absolute !important;
  top: 0 !important;
  left: 0 !important;
  width: 100% !important;
  height: 100% !important;
}

:deep(.cesium-widget) {
  position: absolute !important;
  top: 0 !important;
  left: 0 !important;
  width: 100% !important;
  height: 100% !important;
}

:deep(.cesium-widget canvas) {
  width: 100% !important;
  height: 100% !important;
}

/* 快捷城市 */
.quick-cities {
  padding: 20rpx 30rpx;
  background: rgba(10, 14, 39, 0.95);
  position: relative;
  z-index: 10;
  display: flex;
  align-items: flex-start;
  gap: 12rpx;
  flex-wrap: wrap;
}

.quick-title {
  font-size: 24rpx;
  color: #aaa;
  line-height: 52rpx;
  flex-shrink: 0;
}

.city-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
}

.city-tag {
  padding: 8rpx 24rpx;
  background: rgba(79, 172, 254, 0.15);
  border: 2rpx solid rgba(79, 172, 254, 0.3);
  border-radius: 26rpx;

  &:active {
    background: rgba(79, 172, 254, 0.35);
  }
}

.city-tag-text {
  font-size: 24rpx;
  color: #4facfe;
}

/* 航线飞行区域 */
.flight-section {
  padding: 16rpx 30rpx 20rpx;
  background: rgba(10, 14, 39, 0.95);
  position: relative;
  z-index: 10;
}

.flight-tag {
  padding: 8rpx 24rpx;
  background: rgba(255, 215, 0, 0.12);
  border: 2rpx solid rgba(255, 215, 0, 0.35);
  border-radius: 26rpx;

  &:active {
    background: rgba(255, 215, 0, 0.3);
  }
}

.flight-tag-text {
  font-size: 24rpx;
  color: #ffd700;
}

.flight-controls {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-top: 16rpx;
  flex-wrap: wrap;
}

.flight-btn {
  padding: 8rpx 24rpx;
  background: rgba(255, 255, 255, 0.12);
  border: 2rpx solid rgba(255, 255, 255, 0.25);
  border-radius: 20rpx;

  &:active {
    background: rgba(255, 255, 255, 0.25);
  }
}

.flight-btn-text {
  font-size: 24rpx;
  color: #fff;
}

.flight-info {
  font-size: 24rpx;
  color: #ffd700;
  flex: 1;
  text-align: right;
}
</style>
