<template>
  <view class="page">
    <PageBack />
    <view class="card" v-if="item">
      <text class="title">{{ item.protocolName }}</text>
      <text class="sub">{{ fmt(item.startedAt) }} · {{ item.durationMin }} 分钟</text>
      <view class="stats">
        <view class="s"><text class="sv">{{ item.stats?.minTemp ?? item.minTemp ?? '-' }}</text><text class="sl">最低°C</text></view>
        <view class="s"><text class="sv">{{ item.stats?.avgTemp ?? item.avgTemp ?? '-' }}</text><text class="sl">均温°C</text></view>
        <view class="s"><text class="sv">{{ item.stats?.maxTemp ?? item.maxTemp ?? '-' }}</text><text class="sl">最高°C</text></view>
        <view class="s"><text class="sv">{{ item.alarms?.length ?? item.alarmCount ?? 0 }}</text><text class="sl">报警</text></view>
      </view>
    </view>

    <view class="card" v-if="points.length">
      <text class="sec-t">温度回放（均值）</text>
      <canvas id="replayCanvas" canvas-id="replayCanvas" class="chart" />
    </view>

    <view class="card" v-if="alarms.length">
      <text class="sec-t">报警列表</text>
      <view v-for="(a, i) in alarms" :key="i" class="alarm">
        <text class="lv" :class="a.level">{{ a.level }}</text>
        <text class="msg">{{ a.message }}</text>
      </view>
    </view>

    <view class="actions">
      <button class="btn ghost" @tap="onExportJson">导出 JSON</button>
      <button class="btn ghost" @tap="onExportCsv">导出 CSV</button>
      <button class="btn solid" @tap="onReproduce">一键复现</button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, getCurrentInstance, nextTick, onMounted, ref } from 'vue'
import PageBack from '@/components/PageBack.vue'
import { defaultProtocols, exportSessionCsv, exportSessionJson } from '@/services/store/therapyStore'
import { useTherapy } from '@/services/store/useTherapy'
import type { Protocol, TherapySession } from '@/services/types'
import { getSession } from '@/api/coolcap'

const item = ref<any>(uni.getStorageSync('cc_archive_item') || null)
const { currentProtocol } = useTherapy()
const instance = getCurrentInstance()

const points = computed(() => item.value?.points || [])
const alarms = computed(() => item.value?.alarms || [])

onMounted(async () => {
  // 入库档案：拉取完整采样点
  const realId = item.value?.realId
  if (realId) {
    try {
      const res = await getSession(Number(realId))
      if (res.code === 200 && res.data) {
        const d = res.data
        item.value = {
          ...item.value,
          protocolName: d.protocol_name,
          durationMin: d.duration_min,
          minTemp: d.min_temp,
          maxTemp: d.max_temp,
          avgTemp: d.avg_temp,
          alarmCount: d.alarm_count,
          envTemp: d.env_temp,
          envHumidity: d.env_humidity,
          dewPoint: d.dew_point,
          endReason: d.end_reason,
          startedAt: d.start_time ? new Date(d.start_time).getTime() : item.value.startedAt,
          points: (d.points || []).map((p: any) => ({
            t: p.t ? new Date(p.t).getTime() : Date.now(),
            zones: {
              F: p.zone_f,
              TL: p.zone_tl,
              TR: p.zone_tr,
              P: p.zone_p,
              OL: p.zone_ol,
              OR: p.zone_or
            },
            power: p.avg_power || 0,
            deltaT: p.delta_t || 0
          })),
          alarms: d.alarms || [],
          stats: {
            minTemp: d.min_temp,
            maxTemp: d.max_temp,
            avgTemp: d.avg_temp
          }
        }
      }
    } catch (e) {}
  }
  nextTick(() => setTimeout(draw, 80))
})

function fmt(ts: number) {
  const d = new Date(ts)
  const p = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}`
}

function draw() {
  const pts = points.value.slice(-80)
  const ctx = uni.createCanvasContext('replayCanvas', instance?.proxy as any)
  const w = 320
  const h = 160
  ctx.setFillStyle('#fff')
  ctx.fillRect(0, 0, w, h)
  if (pts.length < 2) {
    ctx.setFillStyle('#94A3B8')
    ctx.setFontSize(12)
    ctx.fillText('本地档案无足够采样点（远程档案请从列表导出）', 20, 80)
    ctx.draw()
    return
  }
  const temps = pts.map((p: any) => {
    if (p.zones) {
      const vals = Object.values(p.zones) as number[]
      return vals.reduce((a, b) => a + b, 0) / vals.length
    }
    const vals = [p.zone_f, p.zone_tl, p.zone_tr, p.zone_p, p.zone_ol, p.zone_or].filter((x: any) => x != null)
    return vals.length ? vals.reduce((a: number, b: number) => a + b, 0) / vals.length : 0
  })
  let min = Math.min(...temps) - 1
  let max = Math.max(...temps) + 1
  const pad = { l: 30, r: 10, t: 12, b: 16 }
  ctx.beginPath()
  temps.forEach((t: number, i: number) => {
    const x = pad.l + ((w - pad.l - pad.r) * i) / (temps.length - 1)
    const y = pad.t + ((max - t) / (max - min)) * (h - pad.t - pad.b)
    if (i === 0) ctx.moveTo(x, y)
    else ctx.lineTo(x, y)
  })
  ctx.setStrokeStyle('#0EA5E9')
  ctx.setLineWidth(2)
  ctx.stroke()
  ctx.draw()
}

function onExportJson() {
  if (item.value?.remote) {
    uni.showToast({ title: '请在列表页导出远程档案', icon: 'none' })
    return
  }
  exportSessionJson(item.value as TherapySession)
}

function onExportCsv() {
  if (item.value?.remote) {
    uni.showToast({ title: '请在列表页导出远程档案', icon: 'none' })
    return
  }
  exportSessionCsv(item.value as TherapySession)
}

function onReproduce() {
  const snap = item.value?.protocolSnapshot
  const stages = snap?.stages || defaultProtocols()[0].stages
  currentProtocol.value = {
    id: `rep_${Date.now()}`,
    name: `${item.value.protocolName}-复现`,
    builtin: false,
    updatedAt: Date.now(),
    stages: stages.map((s: any) => ({
      name: s.name,
      durationMin: s.durationMin ?? s.duration_min,
      targetTemp: s.targetTemp ?? s.target_temp,
      maxDuty: s.maxDuty ?? s.max_duty
    }))
  }
  uni.showToast({ title: '已复现到当前治疗', icon: 'success' })
}
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  padding: 88rpx 28rpx 48rpx;
  background: #f4f7fb;
}
.card {
  background: #fff;
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 8rpx rgba(15, 23, 42, 0.04);
}
.title { display: block; font-size: 32rpx; font-weight: 700; color: #0f172a; }
.sub { display: block; font-size: 22rpx; color: #94a3b8; margin: 8rpx 0 20rpx; }
.stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 8rpx; }
.s { text-align: center; }
.sv { display: block; font-size: 30rpx; font-weight: 700; color: #0f172a; }
.sl { font-size: 20rpx; color: #94a3b8; }
.sec-t { display: block; font-size: 26rpx; font-weight: 600; color: #0f172a; margin-bottom: 12rpx; }
.chart { width: 320px; height: 160px; }
.alarm {
  display: flex;
  gap: 12rpx;
  align-items: flex-start;
  padding: 10rpx 0;
  border-bottom: 1rpx solid #f1f5f9;
}
.lv {
  font-size: 18rpx;
  padding: 2rpx 10rpx;
  border-radius: 8rpx;
  background: #f1f5f9;
  color: #64748b;
  &.critical { background: #fee2e2; color: #b91c1c; }
  &.warning { background: #fffbeb; color: #b45309; }
  &.info { background: #e0f2fe; color: #0369a1; }
}
.msg { font-size: 22rpx; color: #334155; flex: 1; }
.actions { display: flex; flex-direction: column; gap: 16rpx; }
.btn {
  width: 100%;
  height: 80rpx;
  line-height: 80rpx;
  border-radius: 20rpx;
  font-size: 28rpx;
  border: none;
  &.ghost { background: #f1f5f9; color: #0f172a; }
  &.solid { background: linear-gradient(135deg, #0ea5e9, #0284c7); color: #fff; }
}
</style>
