<template>
  <view class="trend card">
    <view class="head">
      <text class="title">温度趋势</text>
      <view class="chips">
        <text
          v-for="z in zones"
          :key="z.id"
          class="chip"
          :class="{ active: z.id === active }"
          @tap="active = z.id"
        >{{ z.name }}</text>
      </view>
    </view>
    <view class="chart-box">
      <canvas id="trendCanvas" canvas-id="trendCanvas" class="chart" />
    </view>
  </view>
</template>

<script setup lang="ts">
import { getCurrentInstance, nextTick, onMounted, ref, watch } from 'vue'
import type { SessionPoint, ZoneId, ZoneTelemetry } from '@/services/types'

const props = defineProps<{
  zones: ZoneTelemetry[]
  points: SessionPoint[]
  active?: ZoneId
}>()

const active = ref<ZoneId>(props.active || 'P')
const instance = getCurrentInstance()

watch(
  () => props.points.length,
  () => nextTick(draw)
)
watch(active, () => nextTick(draw))

onMounted(() => nextTick(() => setTimeout(draw, 80)))

function draw() {
  const ctx = uni.createCanvasContext('trendCanvas', instance?.proxy as any)
  const w = 320
  const h = 180
  const pad = { l: 36, r: 10, t: 12, b: 24 }

  ctx.setFillStyle('#FFFFFF')
  ctx.fillRect(0, 0, w, h)

  const pts = props.points.slice(-60)
  if (pts.length < 2) {
    ctx.setFillStyle('#94A3B8')
    ctx.setFontSize(12)
    ctx.fillText('治疗中将实时绘制曲线…', 70, 90)
    ctx.draw()
    return
  }

  const temps = pts.map((p) => p.zones[active.value])
  let min = Math.min(...temps, 12)
  let max = Math.max(...temps, 24)
  if (max - min < 4) {
    min -= 2
    max += 2
  }

  // grid
  ctx.setStrokeStyle('#F1F5F9')
  ctx.setLineWidth(1)
  for (let i = 0; i <= 4; i++) {
    const y = pad.t + ((h - pad.t - pad.b) * i) / 4
    ctx.beginPath()
    ctx.moveTo(pad.l, y)
    ctx.lineTo(w - pad.r, y)
    ctx.stroke()
    const label = (max - ((max - min) * i) / 4).toFixed(0)
    ctx.setFillStyle('#94A3B8')
    ctx.setFontSize(10)
    ctx.fillText(label, 6, y + 3)
  }

  // line
  ctx.beginPath()
  pts.forEach((p, i) => {
    const x = pad.l + ((w - pad.l - pad.r) * i) / (pts.length - 1)
    const y = pad.t + ((max - p.zones[active.value]) / (max - min)) * (h - pad.t - pad.b)
    if (i === 0) ctx.moveTo(x, y)
    else ctx.lineTo(x, y)
  })
  ctx.setStrokeStyle('#0EA5E9')
  ctx.setLineWidth(2)
  ctx.stroke()

  // dots
  pts.forEach((p, i) => {
    if (i % 3 !== 0 && i !== pts.length - 1) return
    const x = pad.l + ((w - pad.l - pad.r) * i) / (pts.length - 1)
    const y = pad.t + ((max - p.zones[active.value]) / (max - min)) * (h - pad.t - pad.b)
    ctx.setFillStyle('#0EA5E9')
    ctx.beginPath()
    ctx.arc(x, y, 2.5, 0, Math.PI * 2)
    ctx.fill()
  })

  ctx.draw()
}
</script>

<style lang="scss" scoped>
.trend {
  background: #fff;
  border-radius: 24rpx;
  padding: 20rpx;
  box-shadow: 0 2rpx 8rpx rgba(15, 23, 42, 0.04);
}
.head {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
  margin-bottom: 12rpx;
}
.title { font-size: 28rpx; font-weight: 600; color: #0f172a; }
.chips {
  display: flex;
  flex-wrap: wrap;
  gap: 8rpx;
}
.chip {
  padding: 6rpx 14rpx;
  border-radius: 999rpx;
  background: #f1f5f9;
  font-size: 20rpx;
  color: #64748b;
  &.active {
    background: #e0f2fe;
    color: #0369a1;
  }
}
.chart {
  width: 320px;
  height: 180px;
}
</style>
