<template>
  <view class="page">
    <view class="top">
      <view>
        <text class="h1">治疗</text>
        <text class="sub">{{ snapshot.deviceName }}</text>
      </view>
      <view class="top-right" @tap="goAlarm">
        <text class="bell">🔔</text>
        <view v-if="alarmCount" class="badge">{{ alarmCount }}</view>
      </view>
    </view>

    <view class="conn card" @tap="onToggleConn">
      <StatusChip
        :label="connLabel"
        :tone="connected ? 'ok' : connecting ? 'primary' : 'idle'"
      />
      <text class="conn-action">{{ connected ? '断开' : connecting ? '连接中…' : '连接设备' }}</text>
    </view>

    <view class="hero card">
      <view class="hero-row">
        <text class="state">{{ running ? '治疗进行中' : '设备待机' }}</text>
        <text class="uniformity" :class="snap.uniformity">{{ uniformLabel }}</text>
      </view>
      <view class="elapsed">
        <text class="num">{{ elapsedText }}</text>
        <text class="unit">已治疗</text>
      </view>
      <view class="hero-meta">
        <text>全头温差 {{ snap.deltaT.toFixed(1) }}°C</text>
        <text>均温 {{ snap.meanT.toFixed(1) }}°C</text>
        <text>{{ currentProtocol.name }}</text>
      </view>
      <view v-if="snap.clampedByDewpoint" class="warn-line">露点防护：已自动上调目标温度</view>
      <button v-if="!running" class="btn primary" :disabled="!connected" @tap="onStart">
        开始治疗
      </button>
      <button v-else class="btn danger" @tap="onStop">结束并归档</button>
    </view>

    <view class="mini-grid">
      <view class="mini card">
        <text class="mv">{{ snap.env.dewPoint.toFixed(1) }}°</text>
        <text class="ml">露点</text>
      </view>
      <view class="mini card">
        <text class="mv">{{ minTempText }}</text>
        <text class="ml">最低头皮温</text>
      </view>
      <view class="mini card">
        <text class="mv">{{ alarmCount }}</text>
        <text class="ml">待处理报警</text>
      </view>
    </view>

    <view class="sec">
      <text class="sec-title">分区速览</text>
      <view class="zones">
        <ZoneCard v-for="z in zones" :key="z.id" :zone="z" />
      </view>
    </view>

    <view class="sec">
      <EnvDewpointCard :env="snap.env" :clamp-hint="snap.clampedByDewpoint" :min-setpoint="minSetpoint" />
    </view>

    <view class="sec">
      <view class="sec-head">
        <text class="sec-title">治疗历史</text>
        <text class="sec-link" @tap="goArchive">全部档案 ›</text>
      </view>
      <view v-if="history.length === 0" class="hist-empty card">
        <text class="hist-empty-t">暂无入库记录</text>
        <text class="hist-empty-s">结束治疗并归档后，数据将写入数据库</text>
      </view>
      <view
        v-for="item in history"
        :key="item.id"
        class="hist-item card"
        @tap="openHistory(item)"
      >
        <view class="hist-row">
          <text class="hist-name">{{ item.protocolName }}</text>
          <text class="hist-tag">{{ item.source === 'db' ? '已入库' : '本地' }}</text>
        </view>
        <text class="hist-time">{{ fmtTime(item.startedAt) }}</text>
        <view class="hist-meta">
          <text>{{ item.durationMin }} 分钟</text>
          <text>{{ item.minTemp }}~{{ item.maxTemp }}°C</text>
          <text>报警 {{ item.alarmCount }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onShow, onHide, onUnload } from '@dcloudio/uni-app'
import StatusChip from '@/components/StatusChip.vue'
import ZoneCard from '@/components/ZoneCard.vue'
import EnvDewpointCard from '@/components/EnvDewpointCard.vue'
import { useTherapy } from '@/services/store/useTherapy'
import { listProtocols, startSession, finishSession, bindDevice, pushCommand, pushEnvSample, listSessions } from '@/api/coolcap'
import { loadSessions } from '@/services/store/therapyStore'

const {
  snapshot: snap,
  zones,
  connected,
  connecting,
  running,
  alarmCount,
  currentProtocol,
  protocols,
  connect,
  disconnect,
  start,
  stop,
  refreshProtocols,
  setRemoteSessionId,
  remoteSessionId
} = useTherapy()

const snapshot = snap

const history = ref<any[]>([])

const connLabel = computed(() => {
  if (connected.value) return '已连接'
  if (connecting.value) return '连接中'
  return '未连接'
})

const uniformLabel = computed(() => {
  const m = { excellent: '均匀度优', good: '均匀度良', poor: '均匀度差' }
  return m[snap.value.uniformity]
})

const elapsedText = computed(() => {
  const t = snap.value.startTime ? Math.floor((Date.now() - snap.value.startTime) / 1000) : 0
  const m = Math.floor(t / 60)
  const s = t % 60
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
})

const minTempText = computed(() => {
  const t = Math.min(...zones.value.map((z) => z.scalpTemp))
  return `${t.toFixed(1)}°`
})

const minSetpoint = computed(() => Math.min(...zones.value.map((z) => z.setpoint)))

async function onToggleConn() {
  if (connected.value) {
    if (running.value) {
      uni.showToast({ title: '请先结束治疗', icon: 'none' })
      return
    }
    await disconnect()
  } else {
    await connect()
    try {
      await bindDevice({
        device_sn: 'CoolCap-SC6',
        ble_name: snap.value.deviceName,
        model: 'CoolCap-SC6',
        zone_count: 6,
        firmware: '1.0.0'
      })
      await pushEnvSample({
        temp: snap.value.env.temp,
        humidity: snap.value.env.humidity,
        dew_point: snap.value.env.dewPoint,
        margin: snap.value.env.margin,
        safe: snap.value.env.safe
      })
    } catch (e) {
      // 后端未启动时忽略，保持本地模拟
    }
    uni.showToast({ title: '模拟设备已连接', icon: 'none' })
  }
}

async function onStart() {
  start(currentProtocol.value)
  pushCommand({ cmd: 'START', device_sn: 'CoolCap-SC6', payload: { protocol: currentProtocol.value.name } }).catch(() => {})
  try {
    const res = await startSession({
      protocol_id: Number((currentProtocol.value as any).id) || undefined,
      device_sn: 'CoolCap-SC6',
      env_temp: snap.value.env.temp,
      env_humidity: snap.value.env.humidity
    })
    if (res?.data?.id) setRemoteSessionId(Number(res.data.id))
  } catch (e) {
    // offline ok
  }
}

function onStop() {
  uni.showModal({
    title: '结束治疗',
    content: '将生成治疗档案并归档，确认结束？',
    success: async (r) => {
      if (!r.confirm) return
      const remoteId = remoteSessionId.value
      const ses = stop('用户结束')
      pushCommand({ cmd: 'STOP', device_sn: 'CoolCap-SC6' }).catch(() => {})
      if (remoteId) {
        try {
          await finishSession(remoteId, {
            end_reason: '用户结束',
            min_temp: ses.stats.minTemp,
            max_temp: ses.stats.maxTemp,
            avg_temp: ses.stats.avgTemp,
            max_delta_t: Math.max(0, ses.stats.maxTemp - ses.stats.minTemp),
            alarm_count: ses.alarms.length,
            points: ses.points.map((p) => ({
              ts: new Date(p.t).toISOString(),
              zone_f: p.zones.F,
              zone_tl: p.zones.TL,
              zone_tr: p.zones.TR,
              zone_p: p.zones.P,
              zone_ol: p.zones.OL,
              zone_or: p.zones.OR,
              avg_power: p.power,
              delta_t: p.deltaT
            })),
            zones: [],
            alarms: ses.alarms.map((a) => ({
              zone_id: a.zoneId,
              level: a.level,
              code: a.code,
              message: a.message
            }))
          })
        } catch (e) {}
      }
      uni.showToast({ title: '已归档', icon: 'success' })
      uni.switchTab({ url: '/pages/archive/archive' })
    }
  })
}

function goAlarm() {
  uni.navigateTo({ url: '/pages/alarm/alarm' })
}

function goArchive() {
  uni.switchTab({ url: '/pages/archive/archive' })
}

function fmtTime(ts: number) {
  const d = new Date(ts)
  const p = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}`
}

function openHistory(item: any) {
  uni.setStorageSync('cc_archive_item', item)
  uni.navigateTo({ url: '/pages/archive/detail' })
}

async function loadHistory() {
  const local = (loadSessions() || []).slice(0, 3).map((s: any) => ({
    id: s.id,
    remote: false,
    protocolName: s.protocolName,
    status: s.status ?? 1,
    startedAt: s.startedAt,
    durationMin: s.durationMin,
    minTemp: s.stats?.minTemp ?? '-',
    maxTemp: s.stats?.maxTemp ?? '-',
    avgTemp: s.stats?.avgTemp ?? '-',
    alarmCount: s.alarms?.length ?? 0,
    alarms: s.alarms || [],
    points: s.points || [],
    stats: s.stats,
    protocolSnapshot: s.protocolSnapshot,
    source: 'local'
  }))

  let remote: any[] = []
  try {
    const res = await listSessions({ page: 1, page_size: 3 })
    if (res.code === 200 && Array.isArray(res.data?.list)) {
      remote = res.data.list.map((r: any) => ({
        id: `remote_${r.id}`,
        realId: r.id,
        remote: true,
        protocolName: r.protocol_name,
        status: r.status,
        startedAt: r.start_time ? new Date(r.start_time).getTime() : Date.now(),
        durationMin: r.duration_min,
        minTemp: r.min_temp ?? '-',
        maxTemp: r.max_temp ?? '-',
        avgTemp: r.avg_temp ?? '-',
        alarmCount: r.alarm_count ?? 0,
        alarms: [],
        points: [],
        stats: { minTemp: r.min_temp, maxTemp: r.max_temp, avgTemp: r.avg_temp },
        source: 'db'
      }))
    }
  } catch (e) {}

  // 优先展示已入库记录
  const merged = [...remote, ...local.filter((l: any) => !remote.some((r: any) => r.protocolName === l.protocolName && Math.abs((r.startedAt || 0) - (l.startedAt || 0)) < 120000))]
  history.value = merged.slice(0, 5)
}

onShow(async () => {
  loadHistory()
  try {
    await refreshProtocols()
    const res = await listProtocols()
    if (res.code === 200 && Array.isArray(res.data) && res.data.length) {
      const mapped = res.data.map((p: any) => ({
        id: String(p.id),
        name: p.name,
        builtin: p.is_builtin === 1,
        updatedAt: Date.now(),
        note: p.description,
        stages: p.stages.map((s: any) => ({
          name: s.name,
          durationMin: s.duration_min,
          targetTemp: s.target_temp,
          maxDuty: s.max_duty
        }))
      }))
      protocols.value = mapped
      if (!running.value) currentProtocol.value = mapped[0]
    }
  } catch (e) {}
})
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  padding: 24rpx 28rpx 48rpx;
  background: #f4f7fb;
}
.top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}
.h1 { font-size: 40rpx; font-weight: 700; color: #0f172a; display: block; }
.sub { font-size: 22rpx; color: #64748b; }
.top-right { position: relative; padding: 8rpx; }
.bell { font-size: 36rpx; }
.badge {
  position: absolute;
  top: 0;
  right: 0;
  min-width: 28rpx;
  height: 28rpx;
  line-height: 28rpx;
  text-align: center;
  border-radius: 999rpx;
  background: #ef4444;
  color: #fff;
  font-size: 18rpx;
  padding: 0 6rpx;
}
.card {
  background: #fff;
  border-radius: 24rpx;
  box-shadow: 0 2rpx 8rpx rgba(15, 23, 42, 0.04);
}
.conn {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 24rpx;
  margin-bottom: 20rpx;
}
.conn-action { font-size: 24rpx; color: #0ea5e9; }
.hero {
  padding: 28rpx;
  margin-bottom: 20rpx;
}
.hero-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8rpx;
}
.state { font-size: 28rpx; font-weight: 600; color: #0f172a; }
.uniformity {
  font-size: 22rpx;
  padding: 4rpx 14rpx;
  border-radius: 999rpx;
  background: #ecfdf5;
  color: #047857;
  &.good { background: #fffbeb; color: #b45309; }
  &.poor { background: #fef2f2; color: #b91c1c; }
}
.elapsed {
  display: flex;
  align-items: baseline;
  gap: 12rpx;
  margin: 8rpx 0 12rpx;
}
.num {
  font-size: 72rpx;
  font-weight: 700;
  color: #0f172a;
  font-variant-numeric: tabular-nums;
}
.unit { font-size: 24rpx; color: #64748b; }
.hero-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx 20rpx;
  font-size: 22rpx;
  color: #64748b;
  margin-bottom: 20rpx;
}
.warn-line {
  font-size: 22rpx;
  color: #b45309;
  background: #fffbeb;
  padding: 10rpx 16rpx;
  border-radius: 12rpx;
  margin-bottom: 16rpx;
}
.btn {
  width: 100%;
  height: 88rpx;
  line-height: 88rpx;
  border-radius: 20rpx;
  font-size: 30rpx;
  font-weight: 600;
  border: none;
  &.primary {
    background: linear-gradient(135deg, #0ea5e9, #0284c7);
    color: #fff;
  }
  &.danger {
    background: #ef4444;
    color: #fff;
  }
  &[disabled] {
    opacity: 0.5;
  }
}
.mini-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16rpx;
  margin-bottom: 28rpx;
}
.mini {
  padding: 20rpx 12rpx;
  text-align: center;
}
.mv { display: block; font-size: 32rpx; font-weight: 700; color: #0f172a; }
.ml { font-size: 20rpx; color: #94a3b8; }
.sec { margin-bottom: 28rpx; }
.sec-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;
}
.sec-title { font-size: 28rpx; font-weight: 600; color: #0f172a; display: block; }
.sec-link { font-size: 24rpx; color: #0ea5e9; }
.hist-empty {
  padding: 32rpx 24rpx;
  text-align: center;
}
.hist-empty-t { display: block; font-size: 26rpx; color: #0f172a; font-weight: 600; margin-bottom: 8rpx; }
.hist-empty-s { font-size: 22rpx; color: #94a3b8; }
.hist-item {
  padding: 20rpx 24rpx;
  margin-bottom: 12rpx;
}
.hist-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6rpx;
}
.hist-name { font-size: 26rpx; font-weight: 600; color: #0f172a; flex: 1; padding-right: 12rpx; }
.hist-tag {
  font-size: 18rpx;
  padding: 4rpx 12rpx;
  border-radius: 999rpx;
  background: #e0f2fe;
  color: #0369a1;
}
.hist-time { display: block; font-size: 20rpx; color: #94a3b8; margin-bottom: 8rpx; }
.hist-meta {
  display: flex;
  gap: 16rpx;
  font-size: 20rpx;
  color: #64748b;
}
.zones {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16rpx;
}
</style>
