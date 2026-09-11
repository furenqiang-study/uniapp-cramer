<template>
  <view class="page">
    <PageBack />
    <view class="head">
      <text class="h1">治疗档案</text>
    </view>

    <view class="search card">
      <input class="input" v-model="keyword" placeholder="搜索方案名" @confirm="load" />
      <text class="btn" @tap="load">搜索</text>
    </view>

    <view v-if="list.length === 0" class="empty card">
      <text class="empty-t">暂无档案</text>
      <text class="empty-s">完成一次治疗后将自动生成可追溯档案</text>
    </view>

    <view v-for="item in list" :key="item.id" class="item card" @tap="openDetail(item)">
      <view class="row">
        <text class="name">{{ item.protocolName }}</text>
        <text class="status" :class="item.status === 0 ? 'run' : 'done'">{{ item.status === 0 ? '进行中' : '已完成' }}</text>
      </view>
      <text class="time">{{ fmt(item.startedAt) }}</text>
      <view class="meta">
        <text>{{ item.durationMin }} 分钟</text>
        <text>{{ item.stats?.minTemp ?? item.minTemp ?? '-' }}~{{ item.stats?.maxTemp ?? item.maxTemp ?? '-' }}°C</text>
        <text>报警 {{ item.alarms?.length ?? item.alarmCount ?? 0 }}</text>
      </view>
      <view class="actions">
        <button class="btn ghost" @tap.stop="onExport(item)">导出</button>
        <button class="btn solid" @tap.stop="onReproduce(item)">一键复现</button>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import PageBack from '@/components/PageBack.vue'
import { loadSessions, exportSessionJson, defaultProtocols } from '@/services/store/therapyStore'
import type { TherapySession, Protocol } from '@/services/types'
import { listSessions, exportSession, reproduceSession } from '@/api/coolcap'
import { useTherapy } from '@/services/store/useTherapy'

const list = ref<any[]>([])
const keyword = ref('')
const { currentProtocol } = useTherapy()

onShow(() => {
  load()
})

async function load() {
  const local = loadSessions()
  list.value = [...local]
  try {
    const res = await listSessions({ page: 1, page_size: 50, keyword: keyword.value })
    if (res.code === 200 && res.data?.list) {
      const remote = res.data.list.map((r: any) => ({
        id: r.id,
        remote: true,
        sessionNo: r.session_no,
        protocolName: r.protocol_name,
        status: r.status,
        startedAt: r.start_time ? new Date(r.start_time).getTime() : Date.now(),
        durationMin: r.duration_min,
        minTemp: r.min_temp,
        maxTemp: r.max_temp,
        avgTemp: r.avg_temp,
        alarmCount: r.alarm_count,
        alarms: [],
        stats: { minTemp: r.min_temp, maxTemp: r.max_temp, avgTemp: r.avg_temp }
      }))
      // merge unique by sessionNo
      const seen = new Set(local.map((l: any) => l.id))
      for (const r of remote) {
        if (!seen.has(`remote_${r.id}`)) {
          list.value.push({ ...r, id: `remote_${r.id}`, realId: r.id })
        }
      }
    }
  } catch (e) {}
}

function fmt(ts: number) {
  const d = new Date(ts)
  const p = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}`
}

function openDetail(item: any) {
  uni.setStorageSync('cc_archive_item', item)
  uni.navigateTo({ url: '/pages/archive/detail' })
}

function onExport(item: any) {
  if (item.remote || item.realId) {
    exportSession(item.realId || item.id).then((res) => {
      uni.setClipboardData({
        data: JSON.stringify(res.data),
        success: () => uni.showToast({ title: '已复制档案JSON', icon: 'none' })
      })
    }).catch(() => exportSessionJson(item))
    return
  }
  exportSessionJson(item)
  uni.showToast({ title: '已导出 JSON', icon: 'success' })
}

async function onReproduce(item: any) {
  if (item.remote || item.realId) {
    try {
      const res = await reproduceSession(item.realId)
      if (res.code === 200 && res.data?.protocol_snapshot) {
        const snap = res.data.protocol_snapshot
        currentProtocol.value = {
          id: String(snap.id || item.realId),
          name: snap.name || item.protocolName,
          builtin: false,
          updatedAt: Date.now(),
          note: '来自档案复现',
          stages: (snap.stages || []).map((s: any) => ({
            name: s.name,
            durationMin: s.duration_min,
            targetTemp: s.target_temp,
            maxDuty: s.max_duty
          }))
        }
        uni.showToast({ title: '已复现历史参数', icon: 'success' })
        return
      }
    } catch (e) {}
  }
  const snap = item.protocolSnapshot || item.protocol_snapshot
  const stages = snap?.stages || defaultProtocols()[0].stages
  currentProtocol.value = {
    id: `rep_${Date.now()}`,
    name: `${item.protocolName}-复现`,
    builtin: false,
    updatedAt: Date.now(),
    note: '来自档案复现',
    stages: stages.map((s: any) => ({
      name: s.name,
      durationMin: s.durationMin ?? s.duration_min,
      targetTemp: s.targetTemp ?? s.target_temp,
      maxDuty: s.maxDuty ?? s.max_duty
    }))
  }
  uni.showToast({ title: '已复现历史参数', icon: 'success' })
}
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  padding: 88rpx 28rpx 48rpx;
  background: #f4f7fb;
}
.head { margin-bottom: 20rpx; }
.h1 { font-size: 40rpx; font-weight: 700; color: #0f172a; }
.card {
  background: #fff;
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: 0 2rpx 8rpx rgba(15, 23, 42, 0.04);
}
.search {
  display: flex;
  align-items: center;
  gap: 16rpx;
}
.input {
  flex: 1;
  height: 72rpx;
  background: #f8fafc;
  border-radius: 16rpx;
  padding: 0 20rpx;
  font-size: 26rpx;
}
.btn.sm, .btn {
  font-size: 24rpx;
}
.search .btn {
  padding: 0 28rpx;
  height: 72rpx;
  line-height: 72rpx;
  border-radius: 16rpx;
  background: #0ea5e9;
  color: #fff;
}
.empty { text-align: center; padding: 60rpx 20rpx; }
.empty-t { display: block; font-size: 30rpx; font-weight: 600; color: #0f172a; margin-bottom: 8rpx; }
.empty-s { font-size: 24rpx; color: #94a3b8; }
.row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8rpx; }
.name { font-size: 28rpx; font-weight: 600; color: #0f172a; }
.status {
  font-size: 20rpx;
  padding: 4rpx 12rpx;
  border-radius: 999rpx;
  &.done { background: #ecfdf5; color: #047857; }
  &.run { background: #e0f2fe; color: #0369a1; }
}
.time { font-size: 22rpx; color: #94a3b8; display: block; margin-bottom: 12rpx; }
.meta {
  display: flex;
  gap: 20rpx;
  font-size: 22rpx;
  color: #64748b;
  margin-bottom: 16rpx;
}
.actions { display: flex; gap: 16rpx; }
.actions .btn {
  flex: 1;
  height: 68rpx;
  line-height: 68rpx;
  border-radius: 14rpx;
  border: none;
  &.ghost { background: #f1f5f9; color: #0f172a; }
  &.solid { background: linear-gradient(135deg, #0ea5e9, #0284c7); color: #fff; }
}
</style>
