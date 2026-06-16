<template>
  <view class="camera-container">
    <!-- 顶部导航栏 -->
    <view class="nav-bar">
      <view class="nav-back" @tap="goBack">
        <text class="nav-back-icon">‹</text>
      </view>
      <text class="nav-title">相机拍照</text>
      <view style="width: 60rpx;"></view>
    </view>

    <!-- 未拍照状态：预览区域 -->
    <view v-if="!photoSrc" class="preview-area">
      <!-- H5端：用原生 video 容器 -->
      <!-- #ifdef H5 -->
      <view id="h5CameraContainer" class="h5-camera-container"></view>
      <!-- #endif -->

      <!-- APP端：使用plus相机预览 -->
      <!-- #ifdef APP-PLUS -->
      <view v-if="cameraReady" class="app-camera-area">
        <text class="camera-hint-icon">📷</text>
        <text class="camera-hint-text">点击下方按钮拍照</text>
      </view>
      <!-- #endif -->

      <!-- 微信小程序端：使用camera组件 -->
      <!-- #ifdef MP-WEIXIN -->
      <camera v-if="cameraReady" class="mp-camera" device-position="back" flash="auto"></camera>
      <!-- #endif -->

      <!-- 拍照前提示 -->
      <view v-if="!cameraReady && !permissionDenied" class="camera-hint">
        <text class="camera-hint-icon">📷</text>
        <text class="camera-hint-text">正在初始化相机...</text>
      </view>

      <!-- 权限被拒绝 -->
      <view v-if="permissionDenied" class="permission-denied">
        <text class="permission-icon">🚫</text>
        <text class="permission-text">摄像头权限未开启</text>
        <text class="permission-desc">请在系统设置中允许本应用访问摄像头</text>
        <button class="permission-btn" @tap="requestCameraPermission">重新申请权限</button>
      </view>

      <!-- 语音启用提示（手机浏览器需要用户交互才能播放语音） -->
      <!-- #ifdef H5 -->
      <view v-if="cameraReady && !permissionDenied && !speechUnlocked" class="speech-unlock" @tap="unlockSpeech">
        <text class="speech-unlock-icon">🔊</text>
        <text class="speech-unlock-text">点击启用语音指导</text>
      </view>
      <!-- #endif -->

      <!-- 实时拍摄建议提示 -->
      <view v-if="cameraReady && !permissionDenied" class="tips-overlay">
        <!-- 九宫格辅助线 -->
        <view class="grid-overlay">
          <view class="grid-line grid-h1"></view>
          <view class="grid-line grid-h2"></view>
          <view class="grid-line grid-v1"></view>
          <view class="grid-line grid-v2"></view>
        </view>
        
        <!-- 顶部提示栏 -->
        <view class="tip-bar" :class="'tip-' + tipType">
          <text class="tip-icon">{{ tipIcon }}</text>
          <text class="tip-text">{{ tipMessage }}</text>
        </view>
        
        <!-- 亮度指示器 -->
        <view class="brightness-indicator">
          <view class="brightness-bar">
            <view class="brightness-fill" :style="{ height: brightnessPercent + '%' }"></view>
          </view>
          <text class="brightness-label">{{ brightnessLabel }}</text>
        </view>
        
        <!-- 方向指引箭头 -->
        <view v-if="directionHint" class="direction-guide">
          <text class="direction-arrow" :class="'arrow-' + directionHint">{{ directionArrow }}</text>
        </view>
      </view>
      
      <!-- 拍照按钮 -->
      <view v-if="cameraReady" class="capture-bar">
        <view class="capture-btn-wrapper" @tap="takePhoto">
          <view class="capture-btn">
            <view class="capture-btn-inner"></view>
          </view>
        </view>
      </view>
    </view>

    <!-- 已拍照状态：预览照片 -->
    <view v-else class="photo-preview-area">
      <image class="photo-preview" :src="photoSrc" mode="aspectFit" />
      <view class="photo-actions">
        <button class="photo-action-btn retake-btn" @tap="retakePhoto">
          <text class="photo-action-icon">🔄</text>
          <text class="photo-action-text">重拍</text>
        </button>
        <button class="photo-action-btn save-btn" @tap="savePhoto">
          <text class="photo-action-icon">💾</text>
          <text class="photo-action-text">保存</text>
        </button>
        <button class="photo-action-btn share-btn" @tap="sharePhoto">
          <text class="photo-action-icon">📤</text>
          <text class="photo-action-text">分享</text>
        </button>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onBeforeUnmount, nextTick } from 'vue'

// ============ 状态 ============
const cameraReady = ref(false)
const permissionDenied = ref(false)
const photoSrc = ref('')

let stream: MediaStream | null = null
let videoEl: HTMLVideoElement | null = null
let analysisCanvas: HTMLCanvasElement | null = null
let analysisCtx: CanvasRenderingContext2D | null = null
let analysisTimer: number | null = null
let prevFrameData: Uint8ClampedArray | null = null

// ============ 实时分析提示状态 ============
const tipMessage = ref('正在分析画面...')
const tipIcon = ref('🔍')
const tipType = ref<'good' | 'warn' | 'bad'>('good')
const brightnessPercent = ref(50)
const brightnessLabel = ref('适中')
const directionHint = ref('')
const directionArrow = ref('')
const speechUnlocked = ref(false)
let lastSpokenText = ''
let lastSpokenAt = 0

// 上次分析结果（用于平滑过渡，避免频繁跳动）
const ANALYSIS_INTERVAL = 300 // 毫秒

// ============ 生命周期 ============
onMounted(() => {
  requestCameraPermission()
})

onBeforeUnmount(() => {
  stopCamera()
})

// ============ 方法 ============

/** 申请摄像头权限 */
async function requestCameraPermission() {
  permissionDenied.value = false
  cameraReady.value = false

  // #ifdef H5
  try {
    stream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: 'environment', width: { ideal: 1920 }, height: { ideal: 1080 } },
      audio: false
    })
    await nextTick()
    attachStreamToVideo()
  } catch (e: any) {
    console.error('摄像头权限获取失败:', e)
    permissionDenied.value = true
  }
  // #endif

  // #ifdef APP-PLUS
  try {
    // 检查权限
    const hasPerm = await checkCameraPermission()
    if (hasPerm) {
      cameraReady.value = true
    } else {
      const granted = await requestAppCameraPermission()
      if (granted) {
        cameraReady.value = true
      } else {
        permissionDenied.value = true
      }
    }
  } catch (e) {
    permissionDenied.value = true
  }
  // #endif

  // #ifdef MP-WEIXIN
  cameraReady.value = true
  // #endif
}

/** 检查摄像头权限 (APP) */
function checkCameraPermission(): Promise<boolean> {
  return new Promise((resolve) => {
    // #ifdef APP-PLUS
    // @ts-ignore
    plus.android.requestPermissions(
      ['android.permission.CAMERA'],
      (e: any) => {
        if (e.deniedAlways && e.deniedAlways.length > 0) {
          resolve(false)
        } else if (e.denied && e.denied.length > 0) {
          resolve(false)
        } else {
          resolve(true)
        }
      },
      () => resolve(false)
    )
    // #endif
    // #ifndef APP-PLUS
    resolve(true)
    // #endif
  })
}

/** 申请摄像头权限 (APP) */
function requestAppCameraPermission(): Promise<boolean> {
  return new Promise((resolve) => {
    // #ifdef APP-PLUS
    uni.authorize({
      scope: 'scope.camera',
      success: () => resolve(true),
      fail: () => resolve(false)
    })
    // #endif
    // #ifndef APP-PLUS
    resolve(true)
    // #endif
  })
}

/** H5端：将 MediaStream 绑定到原生 video 元素 */
function attachStreamToVideo() {
  if (!stream) return

  const container = document.getElementById('h5CameraContainer')
  if (!container) {
    console.error('找不到 h5CameraContainer')
    // 兜底：尝试延迟重试
    setTimeout(() => {
      const retryContainer = document.getElementById('h5CameraContainer')
      if (retryContainer) {
        createAndAttachVideo(retryContainer)
      } else {
        permissionDenied.value = true
      }
    }, 300)
    return
  }

  createAndAttachVideo(container)
}

function createAndAttachVideo(container: HTMLElement) {
  // 清除旧的 video
  container.innerHTML = ''

  const video = document.createElement('video')
  video.setAttribute('autoplay', '')
  video.setAttribute('playsinline', '')
  video.setAttribute('muted', '')
  video.style.width = '100%'
  video.style.height = '100%'
  video.style.objectFit = 'cover'
  video.style.display = 'block'

  container.appendChild(video)
  videoEl = video

  video.srcObject = stream!
  video.onloadedmetadata = () => {
    video.play().then(() => {
      cameraReady.value = true
      startAnalysis()
    }).catch((err) => {
      console.error('video.play() 失败:', err)
      video.muted = true
      video.play().then(() => {
        cameraReady.value = true
        startAnalysis()
      }).catch(() => {
        cameraReady.value = true
        startAnalysis()
      })
    })
  }

  video.onerror = (e) => {
    console.error('video 元素错误:', e)
    permissionDenied.value = true
  }
}

/** 停止相机 */
function stopCamera() {
  stopAnalysis()
  if (stream) {
    stream.getTracks().forEach(track => track.stop())
    stream = null
  }
  if (videoEl) {
    videoEl.srcObject = null
    videoEl = null
  }
  analysisCanvas = null
  analysisCtx = null
  prevFrameData = null
  // #ifdef H5
  const container = document.getElementById('h5CameraContainer')
  if (container) container.innerHTML = ''
  // #endif
}

// ============ 实时画面分析 ============

/** 开始实时分析 */
function startAnalysis() {
  stopAnalysis()
  // 创建用于分析的隐藏 canvas
  analysisCanvas = document.createElement('canvas')
  analysisCanvas.width = 160
  analysisCanvas.height = 120
  analysisCtx = analysisCanvas.getContext('2d', { willReadFrequently: true })
  analysisTimer = window.setInterval(analyzeFrame, ANALYSIS_INTERVAL)
}

/** 停止实时分析 */
function stopAnalysis() {
  if (analysisTimer !== null) {
    clearInterval(analysisTimer)
    analysisTimer = null
  }
}

/** 分析一帧画面 */
function analyzeFrame() {
  if (!videoEl || !analysisCtx || !analysisCanvas) return
  if (videoEl.readyState < 2) return

  const w = analysisCanvas.width
  const h = analysisCanvas.height

  try {
    analysisCtx.drawImage(videoEl, 0, 0, w, h)
  } catch {
    return
  }

  const imageData = analysisCtx.getImageData(0, 0, w, h)
  const data = imageData.data

  // 1. 计算整体亮度
  const brightness = calcBrightness(data, w, h)
  updateBrightness(brightness)

  // 2. 计算九宫格区域亮度，判断方向
  const zones = calcZoneBrightness(data, w, h)
  updateDirection(zones)

  // 3. 构图分析
  const composition = analyzeComposition(data, w, h)
  updateCompositionTips(composition)

  // 4. 抖动检测
  if (prevFrameData) {
    checkStability(data, prevFrameData)
  }
  prevFrameData = new Uint8ClampedArray(data)

  // 5. 综合提示
  updateOverallTip(brightness, zones, composition)

  // 6. 语音播报当前建议（限频，避免刷屏）
  speakTipMessage(tipMessage.value)
}

/** 计算平均亮度 (0-255) */
function calcBrightness(data: Uint8ClampedArray, w: number, h: number): number {
  let total = 0
  const pixelCount = w * h
  for (let i = 0; i < data.length; i += 4) {
    total += data[i] * 0.299 + data[i + 1] * 0.587 + data[i + 2] * 0.114
  }
  return total / pixelCount
}

/** 计算九宫格各区域亮度 (3x3) */
function calcZoneBrightness(data: Uint8ClampedArray, w: number, h: number): number[][] {
  const zones: number[][] = []
  const zoneW = Math.floor(w / 3)
  const zoneH = Math.floor(h / 3)

  for (let row = 0; row < 3; row++) {
    zones[row] = []
    for (let col = 0; col < 3; col++) {
      let sum = 0
      let count = 0
      const startX = col * zoneW
      const startY = row * zoneH
      const endX = startX + zoneW
      const endY = startY + zoneH

      // 每隔 2 个像素采样一次，提升性能
      for (let y = startY; y < endY; y += 2) {
        for (let x = startX; x < endX; x += 2) {
          const idx = (y * w + x) * 4
          sum += data[idx] * 0.299 + data[idx + 1] * 0.587 + data[idx + 2] * 0.114
          count++
        }
      }
      zones[row][col] = count > 0 ? sum / count : 128
    }
  }
  return zones
}

/** 更新亮度显示 */
function updateBrightness(brightness: number) {
  // 亮度映射到百分比 (0-255 → 0-100)
  const percent = Math.round((brightness / 255) * 100)
  brightnessPercent.value = percent

  if (brightness < 40) {
    brightnessLabel.value = '太暗'
    tipType.value = 'bad'
  } else if (brightness < 80) {
    brightnessLabel.value = '偏暗'
    tipType.value = 'warn'
  } else if (brightness < 200) {
    brightnessLabel.value = '适中'
    tipType.value = 'good'
  } else if (brightness < 230) {
    brightnessLabel.value = '偏亮'
    tipType.value = 'warn'
  } else {
    brightnessLabel.value = '过曝'
    tipType.value = 'bad'
  }
}

/** 更新方向提示 */
function updateDirection(zones: number[][]) {
  // 左半部分平均亮度
  const leftAvg = (zones[0][0] + zones[1][0] + zones[2][0] + zones[0][1] + zones[1][1] + zones[2][1]) / 6
  // 右半部分平均亮度
  const rightAvg = (zones[0][1] + zones[1][1] + zones[2][1] + zones[0][2] + zones[1][2] + zones[2][2]) / 6
  // 上半部分
  const topAvg = (zones[0][0] + zones[0][1] + zones[0][2]) / 3
  // 下半部分
  const bottomAvg = (zones[2][0] + zones[2][1] + zones[2][2]) / 3

  const horizontalDiff = leftAvg - rightAvg
  const verticalDiff = topAvg - bottomAvg

  const threshold = 30 // 亮度差阈值

  if (Math.abs(horizontalDiff) > threshold) {
    if (horizontalDiff > 0) {
      directionHint.value = 'right'
      directionArrow.value = '→'
    } else {
      directionHint.value = 'left'
      directionArrow.value = '←'
    }
  } else if (Math.abs(verticalDiff) > threshold) {
    if (verticalDiff > 0) {
      directionHint.value = 'down'
      directionArrow.value = '↓'
    } else {
      directionHint.value = 'up'
      directionArrow.value = '↑'
    }
  } else {
    directionHint.value = ''
    directionArrow.value = ''
  }
}

/** 抖动检测 */
function checkStability(current: Uint8ClampedArray, prev: Uint8ClampedArray) {
  let diff = 0
  const sampleStep = 16 // 每隔16像素采样
  let count = 0
  for (let i = 0; i < current.length; i += sampleStep) {
    diff += Math.abs(current[i] - prev[i])
    count++
  }
  const avgDiff = diff / count

  if (avgDiff > 25) {
    // 画面变化很大，可能在移动
    tipMessage.value = '📷 画面不稳定，请保持稳定'
    tipIcon.value = '⚠️'
  }
}

/** 分析构图质量 */
function analyzeComposition(data: Uint8ClampedArray, w: number, h: number) {
  const edgeThreshold = 50 // 边缘检测阈值
  let leftEdges = 0, rightEdges = 0, topEdges = 0, bottomEdges = 0
  let leftSymmetryDiff = 0, rightSymmetryDiff = 0
  
  // 计算边缘和对称性
  for (let y = 1; y < h - 1; y += 2) {
    for (let x = 1; x < w - 1; x += 2) {
      const idx = (y * w + x) * 4
      const nextXIdx = (y * w + x + 1) * 4
      const nextYIdx = ((y + 1) * w + x) * 4
      
      const currentGray = data[idx] * 0.299 + data[idx + 1] * 0.587 + data[idx + 2] * 0.114
      const nextXGray = data[nextXIdx] * 0.299 + data[nextXIdx + 1] * 0.587 + data[nextXIdx + 2] * 0.114
      const nextYGray = data[nextYIdx] * 0.299 + data[nextYIdx + 1] * 0.587 + data[nextYIdx + 2] * 0.114
      
      // 水平边缘
      const hDiff = Math.abs(currentGray - nextXGray)
      // 垂直边缘
      const vDiff = Math.abs(currentGray - nextYGray)
      
      if (hDiff > edgeThreshold) {
        if (x < w / 3) leftEdges++
        else if (x > w * 2 / 3) rightEdges++
      }
      if (vDiff > edgeThreshold) {
        if (y < h / 3) topEdges++
        else if (y > h * 2 / 3) bottomEdges++
      }
      
      // 对称性分析
      const mirroredX = w - 1 - x
      const mirroredIdx = (y * w + mirroredX) * 4
      const mirroredGray = data[mirroredIdx] * 0.299 + data[mirroredIdx + 1] * 0.587 + data[mirroredIdx + 2] * 0.114
      
      if (x < w / 2) leftSymmetryDiff += Math.abs(currentGray - mirroredGray)
      else rightSymmetryDiff += Math.abs(currentGray - mirroredGray)
    }
  }
  
  return {
    leftEdges,
    rightEdges,
    topEdges,
    bottomEdges,
    leftSymmetryDiff,
    rightSymmetryDiff,
    totalEdges: leftEdges + rightEdges + topEdges + bottomEdges
  }
}

/** 更新构图提示 */
function updateCompositionTips(composition: any) {
  const { leftEdges, rightEdges, topEdges, bottomEdges, leftSymmetryDiff, rightSymmetryDiff, totalEdges } = composition
  
  // 主体偏移检测
  const hDiff = leftEdges - rightEdges
  const vDiff = topEdges - bottomEdges
  
  if (Math.abs(hDiff) > 20 || Math.abs(vDiff) > 20) {
    if (Math.abs(hDiff) > Math.abs(vDiff)) {
      directionHint.value = hDiff > 0 ? 'right' : 'left'
      directionArrow.value = hDiff > 0 ? '→' : '←'
      tipMessage.value = `📌 主体偏左，建议向右移动手机`
      if (hDiff < 0) tipMessage.value = `📌 主体偏右，建议向左移动手机`
    } else {
      directionHint.value = vDiff > 0 ? 'down' : 'up'
      directionArrow.value = vDiff > 0 ? '↓' : '↑'
      tipMessage.value = `📌 主体偏上，建议向下移动手机`
      if (vDiff < 0) tipMessage.value = `📌 主体偏下，建议向上移动手机`
    }
    tipIcon.value = '📐'
    tipType.value = 'warn'
    return
  }
  
  // 对称性检测
  const symmetryDiff = Math.abs(leftSymmetryDiff - rightSymmetryDiff)
  if (symmetryDiff > 5000) {
    if (leftSymmetryDiff > rightSymmetryDiff) {
      tipMessage.value = `🔄 左侧细节多于右侧，建议向右调整取景`
      directionHint.value = 'right'
      directionArrow.value = '→'
    } else {
      tipMessage.value = `🔄 右侧细节多于左侧，建议向左调整取景`
      directionHint.value = 'left'
      directionArrow.value = '←'
    }
    tipIcon.value = '⚖️'
    tipType.value = 'warn'
    return
  }
}

/** 解锁语音播放（手机浏览器需要用户交互触发） */
function unlockSpeech() {
  // #ifdef H5
  try {
    if ('speechSynthesis' in window) {
      const utter = new SpeechSynthesisUtterance('语音指导已开启')
      utter.lang = 'zh-CN'
      utter.rate = 1.0
      window.speechSynthesis.speak(utter)
      speechUnlocked.value = true
    }
  } catch {}
  // #endif
}

/** 语音播报提示信息 */
function speakTipMessage(text: string) {
  if (!text || text === lastSpokenText) return
  const now = Date.now()
  // 3秒内不重复播报相同内容；避免频繁触发
  if (now - lastSpokenAt < 3000 && text === lastSpokenText) return

  lastSpokenText = text
  lastSpokenAt = now

  // #ifdef H5
  try {
    if ('speechSynthesis' in window) {
      window.speechSynthesis.cancel()
      const utter = new SpeechSynthesisUtterance(text)
      utter.lang = 'zh-CN'
      utter.rate = 1.0
      utter.pitch = 1.0
      window.speechSynthesis.speak(utter)
    }
  } catch (e) {
    // 静默失败，不影响拍摄
  }
  // #endif

  // #ifdef APP-PLUS
  try {
    // @ts-ignore
    if (plus?.speech) {
      // @ts-ignore
      plus.speech.startSpeaking(text, 'zh-CN')
    }
  } catch (e) {
    // 静默失败
  }
  // #endif

  // #ifdef MP-WEIXIN
  try {
    // 微信小程序内置同声组件（基础库版本较新可使用，否则静默）
    const plugin = requirePlugin('WechatSI')
    if (plugin?.textToSpeech) {
      plugin.textToSpeech({ lang: 'zh_CN', content: text })
    }
  } catch (e) {
    // 静默失败
  }
  // #endif
}

/** 综合提示更新 */
function updateOverallTip(brightness: number, zones: number[][], composition?: any) {
  // 亮度优先级最高
  if (brightness < 40) {
    tipMessage.value = '🌑 光线太暗，建议移到光线更亮的地方'
    tipIcon.value = '💡'
    tipType.value = 'bad'
    return
  }
  if (brightness < 80) {
    tipMessage.value = '🔅 光线偏暗，建议靠近光源或开启闪光灯'
    tipIcon.value = '💡'
    tipType.value = 'warn'
    return
  }
  if (brightness > 230) {
    tipMessage.value = '☀️ 画面过曝，建议避开强光或调整角度'
    tipIcon.value = '⚠️'
    tipType.value = 'bad'
    return
  }
  if (brightness > 200) {
    tipMessage.value = '🔆 画面偏亮，建议稍调暗光线'
    tipIcon.value = '💡'
    tipType.value = 'warn'
    return
  }

  // 检查构图：九宫格中心区域是否适合主体
  const centerBrightness = zones[1][1]
  const avgBrightness = zones.flat().reduce((a, b) => a + b, 0) / 9
  const centerDiff = Math.abs(centerBrightness - avgBrightness)

  // 检查是否过半区域是纯黑/纯白（可能被遮挡）
  const darkZones = zones.flat().filter(z => z < 20).length
  const brightZones = zones.flat().filter(z => z > 245).length

  if (darkZones >= 5) {
    tipMessage.value = '🖐️ 画面大部分区域过暗，可能被遮挡'
    tipIcon.value = '⚠️'
    tipType.value = 'bad'
    return
  }

  if (brightZones >= 5) {
    tipMessage.value = '☀️ 画面大部分区域过亮，请调整角度'
    tipIcon.value = '⚠️'
    tipType.value = 'bad'
    return
  }

  // 画面亮度适中，方向也无明显偏移
  if (!directionHint.value) {
    tipMessage.value = '✅ 画面构图良好，可以拍照'
    tipIcon.value = '📸'
    tipType.value = 'good'
  } else {
    // 有方向提示
    const dirMap: Record<string, string> = {
      left: '向左转动',
      right: '向右转动',
      up: '向上调整',
      down: '向下调整'
    }
    tipMessage.value = `🧭 建议${dirMap[directionHint.value]}以获得更好光线`
    tipIcon.value = '📐'
    tipType.value = 'warn'
  }
}

/** 拍照 */
async function takePhoto() {
  uni.showLoading({ title: '拍照中...' })

  try {
    // #ifdef H5
    await takePhotoH5()
    // #endif

    // #ifdef APP-PLUS
    await takePhotoApp()
    // #endif

    // #ifdef MP-WEIXIN
    await takePhotoWeixin()
    // #endif

    uni.hideLoading()
    uni.showToast({ title: '拍照成功', icon: 'success' })
  } catch (e) {
    uni.hideLoading()
    console.error('拍照失败:', e)
    uni.showToast({ title: '拍照失败', icon: 'none' })
  }
}

/** APP 端拍照 */
function takePhotoApp(): Promise<void> {
  return new Promise((resolve, reject) => {
    // #ifdef APP-PLUS
    const cmr = plus.camera.getCamera()
    cmr.captureImage(
      (path: string) => {
        plus.io.resolveLocalFileSystemURL(path, (entry: any) => {
          photoSrc.value = entry.toLocalURL()
          resolve()
        }, reject)
      },
      (error: any) => reject(error),
      { filename: '_doc/camera/', index: '1' as any }
    )
    // #endif
    // #ifndef APP-PLUS
    resolve()
    // #endif
  })
}

/** H5 端拍照 */
async function takePhotoH5() {
  if (!videoEl || !stream) throw new Error('视频元素未就绪')

  const canvas = document.createElement('canvas')
  canvas.width = videoEl.videoWidth || 640
  canvas.height = videoEl.videoHeight || 480
  const ctx = canvas.getContext('2d')
  if (!ctx) throw new Error('无法创建 Canvas 上下文')

  ctx.drawImage(videoEl, 0, 0, canvas.width, canvas.height)
  const dataUrl = canvas.toDataURL('image/jpeg', 0.9)
  photoSrc.value = dataUrl

  stopCamera()
}

/** 微信小程序端拍照 */
function takePhotoWeixin(): Promise<void> {
  return new Promise((resolve, reject) => {
    // #ifdef MP-WEIXIN
    const ctx = uni.createCameraContext()
    ctx.takePhoto({
      quality: 'high',
      success: (res: any) => {
        photoSrc.value = res.tempImagePath
        resolve()
      },
      fail: (err: any) => reject(err)
    })
    // #endif
    // #ifndef MP-WEIXIN
    resolve()
    // #endif
  })
}

/** 重拍 */
async function retakePhoto() {
  photoSrc.value = ''
  await nextTick()
  requestCameraPermission()
}

/** 保存照片 */
function savePhoto() {
  if (!photoSrc.value) return

  // #ifdef H5
  const link = document.createElement('a')
  link.href = photoSrc.value
  link.download = `photo_${Date.now()}.jpg`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  uni.showToast({ title: '已开始下载', icon: 'success' })
  // #endif

  // #ifdef APP-PLUS
  uni.saveImageToPhotosAlbum({
    filePath: photoSrc.value,
    success: () => {
      uni.showToast({ title: '已保存到相册', icon: 'success' })
    },
    fail: (err: any) => {
      if (String(err.errMsg || err.message || '').includes('deny') || String(err.errMsg || err.message || '').includes('cancel')) {
        uni.showToast({ title: '请授权相册权限', icon: 'none' })
      } else {
        uni.showToast({ title: '保存失败', icon: 'none' })
      }
    }
  })
  // #endif

  // #ifdef MP-WEIXIN
  uni.saveImageToPhotosAlbum({
    filePath: photoSrc.value,
    success: () => {
      uni.showToast({ title: '已保存到相册', icon: 'success' })
    },
    fail: (err: any) => {
      if (String(err.errMsg || '').includes('deny') || String(err.errMsg || '').includes('cancel')) {
        uni.showToast({ title: '请授权相册权限', icon: 'none' })
      } else {
        uni.showToast({ title: '保存失败', icon: 'none' })
      }
    }
  })
  // #endif
}

/** 分享照片 */
function sharePhoto() {
  // #ifdef APP-PLUS
  if (!photoSrc.value) return
  plus.share.sendWithSystem(
    { type: 'image', pictures: [photoSrc.value] },
    () => { uni.showToast({ title: '分享成功', icon: 'success' }) },
    (err: any) => { console.error('分享失败', err) }
  )
  // #endif

  // #ifndef APP-PLUS
  uni.showToast({ title: '请长按图片保存后分享', icon: 'none' })
  // #endif
}

/** 返回 */
function goBack() {
  stopSpeaking()
  stopCamera()
  uni.navigateBack()
}

// 确保离开页面时停止语音
function stopSpeaking() {
  // #ifdef H5
  try { if ('speechSynthesis' in window) window.speechSynthesis.cancel() } catch {}
  // #endif
}
</script>

<style lang="scss" scoped>
.camera-container {
  min-height: 100vh;
  background: #000;
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
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(10px);
  padding-top: var(--status-bar-height, 0);
  position: relative;
  z-index: 10;
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

// ========== 相机预览 ==========
.preview-area {
  flex: 1;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

// H5 摄像头容器
.h5-camera-container {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1;
}

// 小程序 camera 组件
.mp-camera {
  width: 100%;
  height: 100%;
}

// APP 相机就绪提示
.app-camera-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
}

// ========== 拍照提示 ==========
.camera-hint {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
  z-index: 5;
}

.camera-hint-icon {
  font-size: 100rpx;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.6; transform: scale(1.1); }
}

.camera-hint-text {
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.7);
}

// ========== 权限拒绝 ==========
.permission-denied {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
  padding: 60rpx;
  z-index: 5;
}

.permission-icon {
  font-size: 100rpx;
}

.permission-text {
  font-size: 34rpx;
  font-weight: 600;
  color: #fff;
}

.permission-desc {
  font-size: 26rpx;
  color: rgba(255, 255, 255, 0.6);
  text-align: center;
}

.permission-btn {
  margin-top: 30rpx;
  background: linear-gradient(135deg, #ff6b35, #f7931e);
  color: #fff;
  font-size: 28rpx;
  padding: 16rpx 60rpx;
  border-radius: 40rpx;
  border: none;
}

// ========== 实时拍摄建议 ==========
.tips-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 6;
  pointer-events: none;
}

// 九宫格辅助线
.grid-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
}

.grid-line {
  position: absolute;
  background: rgba(255, 255, 255, 0.15);
}

.grid-h1 {
  left: 0;
  right: 0;
  top: 33.33%;
  height: 1px;
}

.grid-h2 {
  left: 0;
  right: 0;
  top: 66.66%;
  height: 1px;
}

.grid-v1 {
  top: 0;
  bottom: 0;
  left: 33.33%;
  width: 1px;
}

.grid-v2 {
  top: 0;
  bottom: 0;
  left: 66.66%;
  width: 1px;
}

// 顶部提示栏
.tip-bar {
  position: absolute;
  top: 20rpx;
  left: 20rpx;
  right: 20rpx;
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 16rpx 24rpx;
  border-radius: 16rpx;
  backdrop-filter: blur(10px);

  &.tip-good {
    background: rgba(34, 197, 94, 0.25);
    border: 1px solid rgba(34, 197, 94, 0.4);
  }

  &.tip-warn {
    background: rgba(234, 179, 8, 0.25);
    border: 1px solid rgba(234, 179, 8, 0.4);
  }

  &.tip-bad {
    background: rgba(239, 68, 68, 0.25);
    border: 1px solid rgba(239, 68, 68, 0.4);
  }
}

.tip-icon {
  font-size: 32rpx;
  flex-shrink: 0;
}

.tip-text {
  font-size: 26rpx;
  color: #fff;
  line-height: 1.4;
}

// 亮度指示器
.brightness-indicator {
  position: absolute;
  right: 24rpx;
  top: 50%;
  transform: translateY(-50%);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  width: 30rpx;
}

.brightness-bar {
  width: 8rpx;
  height: 200rpx;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 4rpx;
  overflow: hidden;
  position: relative;
  // 垂直显示：底部为暗，顶部为亮
  display: flex;
  flex-direction: column-reverse;
}

.brightness-fill {
  width: 100%;
  background: linear-gradient(to top, #ef4444, #eab308, #22c55e);
  border-radius: 4rpx;
  transition: height 0.3s ease;
}

.brightness-label {
  font-size: 20rpx;
  color: rgba(255, 255, 255, 0.8);
  white-space: nowrap;
  writing-mode: vertical-rl;
  text-orientation: mixed;
}

// 方向指引箭头
.direction-guide {
  position: absolute;
  bottom: 200rpx;
  left: 0;
  right: 0;
  display: flex;
  justify-content: center;
  pointer-events: none;
}

.direction-arrow {
  font-size: 72rpx;
  color: rgba(255, 255, 255, 0.7);
  animation: arrow-bounce 1s infinite;
  text-shadow: 0 0 20px rgba(0, 0, 0, 0.5);

  &.arrow-left {
    animation-name: arrow-left-anim;
  }
  &.arrow-right {
    animation-name: arrow-right-anim;
  }
  &.arrow-up {
    animation-name: arrow-up-anim;
  }
  &.arrow-down {
    animation-name: arrow-down-anim;
  }
}

@keyframes arrow-left-anim {
  0%, 100% { transform: translateX(0); opacity: 0.7; }
  50% { transform: translateX(-20rpx); opacity: 1; }
}

@keyframes arrow-right-anim {
  0%, 100% { transform: translateX(0); opacity: 0.7; }
  50% { transform: translateX(20rpx); opacity: 1; }
}

@keyframes arrow-up-anim {
  0%, 100% { transform: translateY(0); opacity: 0.7; }
  50% { transform: translateY(-20rpx); opacity: 1; }
}

@keyframes arrow-down-anim {
  0%, 100% { transform: translateY(0); opacity: 0.7; }
  50% { transform: translateY(20rpx); opacity: 1; }
}

// ========== 拍照按钮 ==========
.capture-bar {
  position: absolute;
  bottom: 80rpx;
  left: 0;
  right: 0;
  display: flex;
  justify-content: center;
  z-index: 10;
}

.capture-btn-wrapper {
  width: 140rpx;
  height: 140rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  padding: 8rpx;

  &:active {
    transform: scale(0.9);
  }
}

.capture-btn {
  width: 120rpx;
  height: 120rpx;
  background: #fff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.capture-btn-inner {
  width: 100rpx;
  height: 100rpx;
  background: #fff;
  border-radius: 50%;
  border: 4rpx solid #eee;
}

// ========== 照片预览 ==========
.photo-preview-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  position: relative;
}

.photo-preview {
  flex: 1;
  width: 100%;
}

.photo-actions {
  display: flex;
  justify-content: space-around;
  align-items: center;
  padding: 40rpx 30rpx;
  padding-bottom: calc(40rpx + env(safe-area-inset-bottom, 0));
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(10px);
}

.photo-action-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
  background: rgba(255, 255, 255, 0.15);
  border: none;
  color: #fff;
  padding: 24rpx 48rpx;
  border-radius: 20rpx;
  font-size: 24rpx;
  line-height: 1.4;

  &::after {
    border: none;
  }

  &:active {
    opacity: 0.7;
  }
}

.photo-action-icon {
  font-size: 44rpx;
}

.photo-action-text {
  font-size: 24rpx;
  color: #fff;
}

.retake-btn {
  background: rgba(255, 255, 255, 0.15);
}

// ========== 语音解锁按钮 ==========
.speech-unlock {
  position: absolute;
  bottom: 240rpx;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 20rpx 36rpx;
  background: rgba(59, 130, 246, 0.6);
  border: 1px solid rgba(59, 130, 246, 0.8);
  border-radius: 40rpx;
  backdrop-filter: blur(10px);
  z-index: 20;
  animation: pulse-glow 2s infinite;

  &:active {
    opacity: 0.8;
    transform: translateX(-50%) scale(0.95);
  }
}

@keyframes pulse-glow {
  0%, 100% { box-shadow: 0 0 10px rgba(59, 130, 246, 0.3); }
  50% { box-shadow: 0 0 25px rgba(59, 130, 246, 0.6); }
}

.speech-unlock-icon {
  font-size: 36rpx;
}

.speech-unlock-text {
  font-size: 26rpx;
  color: #fff;
  font-weight: 500;
}

.save-btn {
  background: linear-gradient(135deg, #ff6b35, #f7931e);
}

.share-btn {
  background: rgba(255, 255, 255, 0.15);
}
</style>