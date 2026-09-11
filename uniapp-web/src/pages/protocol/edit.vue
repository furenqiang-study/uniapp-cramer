<template>
  <view class="page">
    <PageBack />
    <view class="card">
      <text class="label">方案名称</text>
      <input class="input" v-model="form.name" placeholder="例如：自定义温和方案" />
      <text class="label">备注</text>
      <input class="input" v-model="form.note" placeholder="可选" />
    </view>

    <view class="card">
      <view class="sec-head">
        <text class="label">阶段列表</text>
        <text class="add" @tap="addStage">+ 添加阶段</text>
      </view>
      <view v-for="(s, i) in form.stages" :key="i" class="stage">
        <input class="input sm" v-model="s.name" placeholder="阶段名" />
        <view class="row">
          <text class="k">时长(分)</text>
          <slider class="slider" :value="s.durationMin" :min="5" :max="180" :step="5" activeColor="#0EA5E9" @change="(e:any)=>s.durationMin=e.detail.value" />
          <text class="v">{{ s.durationMin }}</text>
        </view>
        <view class="row">
          <text class="k">目标温度</text>
          <slider class="slider" :value="s.targetTemp" :min="10" :max="25" :step="0.5" activeColor="#0EA5E9" @change="(e:any)=>s.targetTemp=e.detail.value" />
          <text class="v">{{ s.targetTemp }}°C</text>
        </view>
        <view class="row">
          <text class="k">功率上限</text>
          <slider class="slider" :value="s.maxDuty" :min="20" :max="100" :step="5" activeColor="#0EA5E9" @change="(e:any)=>s.maxDuty=e.detail.value" />
          <text class="v">{{ s.maxDuty }}%</text>
        </view>
        <text v-if="form.stages.length>1" class="del" @tap="removeStage(i)">删除该阶段</text>
      </view>
    </view>

    <button class="btn" @tap="save">保存方案</button>
  </view>
</template>

<script setup lang="ts">
import { reactive } from 'vue'
import PageBack from '@/components/PageBack.vue'
import type { Protocol, ProtocolStage } from '@/services/types'
import { upsertProtocol } from '@/services/store/therapyStore'
import { useTherapy } from '@/services/store/useTherapy'
import { createProtocol } from '@/api/coolcap'

const { refreshProtocols, protocols } = useTherapy()

const edit = uni.getStorageSync('cc_edit_protocol') as Protocol | null

const form = reactive<Protocol>(
  edit
    ? JSON.parse(JSON.stringify(edit))
    : {
        id: `proto_${Date.now()}`,
        name: '',
        builtin: false,
        note: '',
        updatedAt: Date.now(),
        stages: [{ name: '预冷', durationMin: 30, targetTemp: 18, maxDuty: 70 }]
      }
)

function addStage() {
  form.stages.push({ name: `阶段${form.stages.length + 1}`, durationMin: 30, targetTemp: 16, maxDuty: 90 })
}

function removeStage(i: number) {
  form.stages.splice(i, 1)
}

async function save() {
  if (!form.name) {
    uni.showToast({ title: '请填写方案名称', icon: 'none' })
    return
  }
  if (!form.stages.length) {
    uni.showToast({ title: '至少一个阶段', icon: 'none' })
    return
  }
  upsertProtocol({ ...form, builtin: false })
  refreshProtocols()
  try {
    await createProtocol({
      name: form.name,
      description: form.note || '',
      stages: form.stages.map((s: ProtocolStage) => ({
        name: s.name,
        duration_min: s.durationMin,
        target_temp: s.targetTemp,
        max_duty: s.maxDuty,
        note: ''
      }))
    })
  } catch (e) {}
  uni.removeStorageSync('cc_edit_protocol')
  uni.showToast({ title: '已保存', icon: 'success' })
  setTimeout(() => uni.navigateBack(), 400)
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
.label { display: block; font-size: 24rpx; color: #64748b; margin-bottom: 8rpx; }
.input {
  height: 80rpx;
  background: #f8fafc;
  border-radius: 16rpx;
  padding: 0 20rpx;
  margin-bottom: 20rpx;
  font-size: 28rpx;
  &.sm { height: 72rpx; }
}
.sec-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12rpx;
}
.add { color: #0ea5e9; font-size: 24rpx; }
.stage {
  padding: 16rpx 0;
  border-bottom: 1rpx solid #f1f5f9;
  margin-bottom: 8rpx;
}
.row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin: 8rpx 0;
}
.k { width: 140rpx; font-size: 22rpx; color: #64748b; }
.slider { flex: 1; }
.v { width: 100rpx; text-align: right; font-size: 22rpx; color: #0f172a; font-variant-numeric: tabular-nums; }
.del { font-size: 22rpx; color: #ef4444; }
.btn {
  width: 100%;
  height: 88rpx;
  line-height: 88rpx;
  border-radius: 20rpx;
  background: linear-gradient(135deg, #0ea5e9, #0284c7);
  color: #fff;
  font-size: 30rpx;
  border: none;
}
</style>
