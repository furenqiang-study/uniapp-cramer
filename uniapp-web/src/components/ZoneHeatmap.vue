<template>
  <view class="zone-heatmap card">
    <view class="head">
      <text class="title">头皮热力图</text>
      <text class="sub">头皮侧实测 · 非冷端温度</text>
    </view>
    <view class="canvas-wrap">
      <canvas
        id="headCanvas"
        canvas-id="headCanvas"
        class="canvas"
        @touchstart="onTap"
      />
    </view>
    <view class="legend">
      <view class="leg"><view class="sw" style="background:#0369A1" /><text>≤14°</text></view>
      <view class="leg"><view class="sw" style="background:#0EA5E9" /><text>18°</text></view>
      <view class="leg"><view class="sw" style="background:#7DD3FC" /><text>22°</text></view>
      <view class="leg"><view class="sw" style="background:#FDE68A" /><text>≥25°</text></view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { getCurrentInstance, nextTick, onMounted, ref, watch } from 'vue'
import type { ZoneId, ZoneTelemetry } from '@/services/types'
import { zoneColor } from '@/services/types'

const props = defineProps<{ zones: ZoneTelemetry[] }>()
const emit = defineEmits<{ (e: 'select', id: ZoneId): void }>()
const instance = getCurrentInstance()

const regions: Record<ZoneId, { x: number; y: number; w: number; h: number; label: string }> = {
  F: { x: 90, y: 36, w: 100, h: 56, label: '额' },
  TL: { x: 36, y: 100, w: 70, h: 70, label: '左颞' },
  TR: { x: 174, y: 100, w: 70, h: 70, label: '右颞' },
  P: { x: 90, y: 100, w: 100, h: 70, label: '顶' },
  OL: { x: 56, y: 178, w: 80, h: 64, label: '左枕' },
  OR: { x: 144, y: 178, w: 80, h: 64, label: '右枕' }
}

onMounted(() => nextTick(() => setTimeout(draw, 60)))

watch(
  () => props.zones.map((z) => `${z.id}:${z.scalpTemp}:${z.compensated}:${z.contact}:${z.fault}`).join('|'),
  () => draw()
)

function draw() {
  const ctx = uni.createCanvasContext('headCanvas', instance?.proxy as any)
  ctx.setFillStyle('#F8FAFC')
  ctx.setStrokeStyle('#CBD5E1')
  ctx.setLineWidth(2)
  ctx.beginPath()
  ctx.arc(140, 140, 120, 0, Math.PI * 2)
  ctx.fill()
  ctx.stroke()

  // front marker
  ctx.setFillStyle('#94A3B8')
  ctx.beginPath()
  ctx.moveTo(130, 28)
  ctx.lineTo(150, 28)
  ctx.lineTo(140, 14)
  ctx.closePath()
  ctx.fill()

  for (const z of props.zones) {
    const r = regions[z.id]
    ctx.setFillStyle(zoneColor(z.scalpTemp))
    roundRect(ctx, r.x, r.y, r.w, r.h, 12)
    ctx.fill()
    ctx.setFillStyle('#0F172A')
    ctx.setFontSize(12)
    ctx.fillText(r.label, r.x + 8, r.y + 22)
    ctx.setFontSize(14)
    ctx.fillText(`${z.scalpTemp.toFixed(1)}°`, r.x + 8, r.y + 42)
    if (z.compensated) {
      ctx.setStrokeStyle('#0284C7')
      ctx.setLineWidth(2)
      roundRect(ctx, r.x, r.y, r.w, r.h, 12)
      ctx.stroke()
    }
    if (!z.contact || z.fault) {
      ctx.setFillStyle('rgba(239,68,68,0.35)')
      roundRect(ctx, r.x, r.y, r.w, r.h, 12)
      ctx.fill()
    }
  }
  ctx.draw()
}

function roundRect(ctx: any, x: number, y: number, w: number, h: number, r: number) {
  ctx.beginPath()
  ctx.moveTo(x + r, y)
  ctx.arcTo(x + w, y, x + w, y + h, r)
  ctx.arcTo(x + w, y + h, x, y + h, r)
  ctx.arcTo(x, y + h, x, y, r)
  ctx.arcTo(x, y, x + w, y, r)
  ctx.closePath()
}

function onTap(e: any) {
  const touch = e.touches?.[0] || e.detail
  const x = touch?.x
  const y = touch?.y
  if (x == null || y == null) return
  // H5 canvas may report CSS pixels; our canvas is 280x300 logical
  for (const id of Object.keys(regions) as ZoneId[]) {
    const r = regions[id]
    if (x >= r.x && x <= r.x + r.w && y >= r.y && y <= r.y + r.h) {
      emit('select', id)
      return
    }
  }
}
</script>

<style lang="scss" scoped>
.zone-heatmap {
  background: #fff;
  border-radius: 24rpx;
  padding: 20rpx;
  box-shadow: 0 2rpx 8rpx rgba(15, 23, 42, 0.04);
}
.head { margin-bottom: 8rpx; }
.title { font-size: 28rpx; font-weight: 600; color: #0f172a; }
.sub { display: block; font-size: 20rpx; color: #94a3b8; margin-top: 4rpx; }
.canvas-wrap { display: flex; justify-content: center; }
.canvas { width: 280px; height: 300px; }
.legend {
  display: flex;
  justify-content: center;
  gap: 20rpx;
}
.leg {
  display: flex;
  align-items: center;
  gap: 6rpx;
  font-size: 20rpx;
  color: #64748b;
}
.sw {
  width: 16rpx;
  height: 16rpx;
  border-radius: 4rpx;
}
</style>
