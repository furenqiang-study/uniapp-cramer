/**
 * 黄金预测 API
 */
import { get } from './request'

export interface GoldPriceInfo {
  id: number
  date: string
  price_cny: number
  price_usd: number
  change_pct: number
  open: number
  high: number
  low: number
  close: number
  volume: number
  created_at?: string
  is_realtime?: boolean
  update_time?: string
  source?: string
}

export interface GoldRealtimeData {
  shanghai?: {
    price: number
    yesterday_close: number
    open: number
    high: number
    low: number
    time: string
    prev_settle: number
    volume: number
    change: number
    change_pct: number
    date: string
    name: string
  }
  newyork?: {
    price: number
    open: number
    high: number
    low: number
    time: string
    prev_settle: number
    date: string
    name: string
  }
  london?: {
    price: number
    prev_close: number
    open: number
    high: number
    low: number
    time: string
    date: string
    name: string
  }
}

export interface GoldPredictionInfo {
  id?: number
  predict_date: string
  predict_price: number
  algorithm: string
  confidence: number
  trend: string
  change_pct: number
  created_at?: string
}

export interface GoldPredictResult {
  current_price: number
  current_date: string
  algorithm: string
  predictions: GoldPredictionInfo[]
  confidence_avg: number
  trend_summary: string
}

export interface GoldPredictParams {
  days_options: { value: number; label: string; desc: string }[]
  algorithm_options: { value: string; label: string; desc: string }[]
}

export function getGoldPrices(days: number = 30) {
  return get<GoldPriceInfo[]>('/api/gold/prices', { days })
}

export function getLatestPrice() {
  return get<GoldPriceInfo>('/api/gold/latest')
}

export function getRealtimeGold() {
  return get<GoldRealtimeData>('/api/gold/realtime')
}

export function predictGold(days: number = 7, algorithm: string = 'ensemble') {
  return get<GoldPredictResult>('/api/gold/predict', { days, algorithm })
}

export function getGoldPredictions(limit: number = 20) {
  return get<GoldPredictionInfo[]>('/api/gold/predictions', { limit })
}

export function getGoldPredictParams() {
  return get<GoldPredictParams>('/api/gold/params')
}
