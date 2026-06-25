/**
 * 天气预报 API
 * 数据来源：腾讯天气 (i.news.qq.com)
 * 通过后端 /api/weather/tencent-raw 代理请求，避免跨域
 * 生产环境不依赖 Vite proxy，由后端转发腾讯天气数据
 */
import { get } from './request'

// 城市信息
export interface CityInfo {
  code: string
  name: string
  province: string
}

// 当前天气
export interface CurrentWeather {
  city: string
  tempC: string
  feelsLikeC: string
  humidity: string
  windSpeedKmph: string
  windDir16Point: string
  windPower: string
  visibility: string
  pressure: string
  uvIndex: string
  weatherDesc: string
  icon: string
  observationTime: string
  aqi: string
  aqiDesc: string
  sunrise: string
  sunset: string
}

// 逐小时预报
export interface HourlyForecast {
  time: string
  tempC: string
  weatherDesc: string
  icon: string
  windDir: string
  windPower: string
  weatherUrl: string
}

// 每日预报 AQI 信息
export interface ForecastDayAqi {
  aqi: number
  aqiLevel: number
  aqiName: string
  aqiUrl: string
}

// 天气预报（每日）
export interface ForecastDay {
  date: string
  maxTempC: string
  minTempC: string
  avgTempC: string
  weatherDesc: string
  weatherNightDesc: string
  dayIcon: string
  nightIcon: string
  icon: string
  windDir: string
  windPower: string
  /** 白天天气图标 URL */
  dayWeatherUrl: string
  /** 夜间天气图标 URL */
  nightWeatherUrl: string
  /** 每日 AQI */
  aqi: ForecastDayAqi
  sunHour?: string
  uvIndex?: string
}

// 生活指数
export interface LifeIndexItem {
  name: string
  info: string
  detail: string
  url: string
}

export interface LifeIndex {
  [key: string]: LifeIndexItem
}

// 日出日落信息（多天）
export interface SunriseSunset {
  sunrise: string
  sunset: string
  time: string  // 格式: 20260618
}

// 完整天气数据
export interface WeatherData {
  current: CurrentWeather
  forecast: ForecastDay[]
  hourly: HourlyForecast[]
  lifeIndex: LifeIndex
  limit: { tailNumber: string; time: string } | null
  rise: SunriseSunset[]       // 15天日出日落
  updateTime: string
  isFallback?: boolean
}

// 天气描述 → emoji 图标映射
function weatherDescToIcon(desc: string): string {
  if (!desc) return '🌤️'
  if (desc.includes('晴')) return '☀️'
  if (desc.includes('多云') && !desc.includes('晴')) return '⛅'
  if (desc.includes('阴')) return '☁️'
  if (desc.includes('雾') || desc.includes('霾')) return '🌫️'
  if (desc.includes('雷') && desc.includes('雨')) return '⛈️'
  if (desc.includes('雪') && desc.includes('雨')) return '🌨️'
  if (desc.includes('暴雪') || desc.includes('大雪')) return '❄️'
  if (desc.includes('雪')) return '🌨️'
  if (desc.includes('暴雨') || desc.includes('大雨')) return '🌧️'
  if (desc.includes('中雨')) return '🌧️'
  if (desc.includes('小雨') || desc.includes('阵雨') || desc.includes('毛毛雨')) return '🌦️'
  if (desc.includes('雨')) return '🌧️'
  return '🌤️'
}

// 热门城市列表（静态数据，与后端同步）
const HOT_CITIES: CityInfo[] = [
  { code: 'beijing', name: '北京', province: '北京' },
  { code: 'shanghai', name: '上海', province: '上海' },
  { code: 'guangzhou', name: '广州', province: '广东' },
  { code: 'shenzhen', name: '深圳', province: '广东' },
  { code: 'chengdu', name: '成都', province: '四川' },
  { code: 'hangzhou', name: '杭州', province: '浙江' },
  { code: 'wuhan', name: '武汉', province: '湖北' },
  { code: 'nanjing', name: '南京', province: '江苏' },
  { code: 'chongqing', name: '重庆', province: '重庆' },
  { code: 'xian', name: '西安', province: '陕西' },
  { code: 'changsha', name: '长沙', province: '湖南' },
  { code: 'tianjin', name: '天津', province: '天津' },
  { code: 'suzhou', name: '苏州', province: '江苏' },
  { code: 'zhengzhou', name: '郑州', province: '河南' },
  { code: 'dongguan', name: '东莞', province: '广东' },
  { code: 'qingdao', name: '青岛', province: '山东' },
  { code: 'kunming', name: '昆明', province: '云南' },
  { code: 'dalian', name: '大连', province: '辽宁' },
  { code: 'xiamen', name: '厦门', province: '福建' },
  { code: 'hefei', name: '合肥', province: '安徽' },
  { code: 'fuzhou', name: '福州', province: '福建' },
  { code: 'jinan', name: '济南', province: '山东' },
  { code: 'wenzhen', name: '温州', province: '浙江' },
  { code: 'harbin', name: '哈尔滨', province: '黑龙江' },
  { code: 'nanning', name: '南宁', province: '广西' },
  { code: 'guiyang', name: '贵阳', province: '贵州' },
  { code: 'urumqi', name: '乌鲁木齐', province: '新疆' },
  { code: 'lhasa', name: '拉萨', province: '西藏' },
  { code: 'sanya', name: '三亚', province: '海南' },
  { code: 'haikou', name: '海口', province: '海南' },
]

// 城市名 → 省份映射
const CITY_PROVINCE_MAP: Record<string, string> = {}
HOT_CITIES.forEach(c => {
  CITY_PROVINCE_MAP[c.name] = c.province
})

/**
 * 解析腾讯天气 API 返回的数据
 */
function parseTencentWeatherData(data: any, city: string): WeatherData | null {
  try {
    const dataSection = data?.data || data
    if (!dataSection) return null

    // --- 当前天气 (observe) ---
    const observe = dataSection.observe || {}
    const current: CurrentWeather = {
      city,
      tempC: String(observe.degree ?? '--'),
      feelsLikeC: String(observe.degree ?? '--'),
      humidity: String(observe.humidity ?? '--'),
      windSpeedKmph: '--',
      windDir16Point: observe.wind_direction_name || '',
      windPower: observe.wind_power || '',
      visibility: String(observe.visibility ?? '--'),
      pressure: String(observe.pressure ?? '--'),
      uvIndex: '--',
      weatherDesc: observe.weather || '',
      icon: weatherDescToIcon(observe.weather || ''),
      observationTime: observe.update_time || '',
      aqi: '',
      aqiDesc: '',
      sunrise: '',
      sunset: '',
    }

    // --- 空气质量 (air) ---
    const air = dataSection.air
    if (air) {
      current.aqi = String(air.aqi ?? '')
      current.aqiDesc = air.aqi_name || ''
    }

    // --- 日出日落 (rise) ---
    const riseList = dataSection.rise
    if (Array.isArray(riseList) && riseList.length > 0) {
      current.sunrise = riseList[0].sunrise || ''
      current.sunset = riseList[0].sunset || ''
    }

    // --- 未来预报 (forecast_24h) ---
    const forecast24h = dataSection.forecast_24h
    const forecast: ForecastDay[] = []
    if (Array.isArray(forecast24h)) {
      for (const day of forecast24h) {
        if (!day || typeof day !== 'object') continue
        const maxDeg = parseInt(day.max_degree)
        const minDeg = parseInt(day.min_degree)
        // 构建每日 AQI
        const dayAqi: ForecastDayAqi = {
          aqi: day.aqi ?? 0,
          aqiLevel: day.aqi_level ?? 0,
          aqiName: day.aqi_name || '',
          aqiUrl: day.aqi_url || '',
        }
        forecast.push({
          date: day.time || '',
          maxTempC: String(day.max_degree ?? '--'),
          minTempC: String(day.min_degree ?? '--'),
          avgTempC: (!isNaN(maxDeg) && !isNaN(minDeg)) ? String(Math.floor((maxDeg + minDeg) / 2)) : '--',
          weatherDesc: day.day_weather || '',
          weatherNightDesc: day.night_weather || '',
          dayIcon: weatherDescToIcon(day.day_weather || ''),
          nightIcon: weatherDescToIcon(day.night_weather || ''),
          icon: weatherDescToIcon(day.day_weather || ''),
          windDir: day.day_wind_direction || '',
          windPower: day.day_wind_power || '',
          dayWeatherUrl: day.day_weather_url || '',
          nightWeatherUrl: day.night_weather_url || '',
          aqi: dayAqi,
        })
      }
    }

    // --- 逐小时预报 (forecast_1h) ---
    const forecast1h = dataSection.forecast_1h
    const hourly: HourlyForecast[] = []
    if (Array.isArray(forecast1h)) {
      for (const h of forecast1h) {
        if (!h || typeof h !== 'object') continue
        const updateTime = h.update_time || ''
        let hourStr = ''
        if (updateTime.length >= 12) {
          hourStr = `${updateTime.substring(8, 10)}:${updateTime.substring(10, 12)}`
        } else if (updateTime.length >= 10) {
          hourStr = updateTime.substring(8, 10)
        }
        hourly.push({
          time: hourStr,
          tempC: String(h.degree ?? '--'),
          weatherDesc: h.weather || '',
          icon: weatherDescToIcon(h.weather || ''),
          windDir: h.wind_direction || '',
          windPower: h.wind_power || '',
          weatherUrl: h.weather_url || '',
        })
      }
    }

    // --- 生活指数 (index) --- 动态解析所有指数
    const indexData = dataSection.index
    const lifeIndex: LifeIndex = {}
    if (indexData && typeof indexData === 'object') {
      for (const key of Object.keys(indexData)) {
        const item = indexData[key]
        if (item && typeof item === 'object' && item.name) {
          lifeIndex[key] = {
            name: item.name || '',
            info: item.info || '',
            detail: item.detail || '',
            url: item.url || '',
          }
        }
      }
    }

    // --- 限行 (limit) ---
    const limitData = dataSection.limit
    let limit: { tailNumber: string; time: string } | null = null
    if (limitData && typeof limitData === 'object') {
      limit = {
        tailNumber: limitData.tail_number || '',
        time: limitData.time || '',
      }
    }

    // --- 日出日落 (rise) --- 15天数据
    const rise: SunriseSunset[] = []
    if (Array.isArray(riseList)) {
      for (const r of riseList) {
        if (r && typeof r === 'object') {
          rise.push({
            sunrise: r.sunrise || '',
            sunset: r.sunset || '',
            time: r.time || '',
          })
        }
      }
    }

    return {
      current,
      forecast,
      hourly,
      lifeIndex,
      limit,
      rise,
      updateTime: new Date().toLocaleString('zh-CN'),
    }
  } catch (e) {
    console.error('[Weather] 解析腾讯天气数据失败:', e)
    return null
  }
}

/**
 * 从后端代理获取腾讯天气原始数据（避免生产环境跨域）
 */
async function fetchFromTencentWeather(city: string): Promise<WeatherData | null> {
  try {
    const province = CITY_PROVINCE_MAP[city] || city
    const res = await get<Record<string, any>>('/api/weather/tencent-raw', {
      province,
      city,
      weather_type: 'observe|forecast_1h|forecast_24h|index|alarm|limit|tips|rise',
    })
    // get() 返回 { code, message, data } 结构
    if (!res || res.code !== 200 || !res.data) return null
    return parseTencentWeatherData(res.data as any, city)
  } catch (e) {
    console.error('[Weather] 天气请求失败:', e)
    return null
  }
}

/**
 * 获取天气预报 —— 优先通过后端代理获取腾讯天气，失败则走后端解析，最终 fallback
 */
export async function getWeather(city: string = '北京'): Promise<{ code: number; data: WeatherData }> {
  // 1. 先尝试直接请求腾讯天气
  const tencentData = await fetchFromTencentWeather(city)
  if (tencentData) {
    return { code: 200, data: tencentData }
  }

  // 2. 腾讯天气失败，尝试走后端
  try {
    const res = await get<WeatherData>('/api/weather', { city })
    return res
  } catch {
    // 3. 都失败，返回备用数据
    return { code: 200, data: generateFallbackWeather(city) }
  }
}

/**
 * 获取热门城市列表（优先后端，失败返回本地静态数据）
 */
export async function getCities(): Promise<{ code: number; data: CityInfo[] }> {
  try {
    const res = await get<CityInfo[]>('/api/weather/cities')
    return res
  } catch {
    // 后端不可用时返回本地静态城市列表
    return { code: 200, data: HOT_CITIES }
  }
}

/**
 * 生成备用天气数据（所有 API 都失败时）
 */
function generateFallbackWeather(city: string): WeatherData {
  const now = new Date()
  const month = now.getMonth() + 1
  let baseTemp: number
  if ([12, 1, 2].includes(month)) baseTemp = Math.floor(Math.random() * 13) - 5
  else if ([3, 4, 5].includes(month)) baseTemp = Math.floor(Math.random() * 15) + 10
  else if ([6, 7, 8].includes(month)) baseTemp = Math.floor(Math.random() * 13) + 25
  else baseTemp = Math.floor(Math.random() * 16) + 12

  const weatherTypes = [
    { desc: '晴', icon: '☀️' },
    { desc: '多云', icon: '⛅' },
    { desc: '阴', icon: '☁️' },
    { desc: '小雨', icon: '🌦️' },
  ]
  const wt = weatherTypes[Math.floor(Math.random() * weatherTypes.length)]
  const humidity = Math.floor(Math.random() * 55) + 30
  const windDirs = ['北风', '东北风', '东风', '东南风', '南风', '西南风', '西风', '西北风']
  const windDir = windDirs[Math.floor(Math.random() * windDirs.length)]

  const forecast: ForecastDay[] = []
  for (let i = 0; i < 7; i++) {
    const dayDate = new Date(now.getTime() + i * 86400000)
    const dayWt = weatherTypes[Math.floor(Math.random() * weatherTypes.length)]
    const dayMax = baseTemp + Math.floor(Math.random() * 6) + 2
    const dayMin = baseTemp - Math.floor(Math.random() * 6) - 2
    const mm = String(dayDate.getMonth() + 1).padStart(2, '0')
    const dd = String(dayDate.getDate()).padStart(2, '0')
    forecast.push({
      date: `${dayDate.getFullYear()}-${mm}-${dd}`,
      maxTempC: String(dayMax),
      minTempC: String(dayMin),
      avgTempC: String(Math.floor((dayMax + dayMin) / 2)),
      weatherDesc: dayWt.desc,
      weatherNightDesc: dayWt.desc,
      dayIcon: dayWt.icon,
      nightIcon: dayWt.icon,
      icon: dayWt.icon,
      windDir,
      windPower: '1-3',
      dayWeatherUrl: '',
      nightWeatherUrl: '',
      aqi: { aqi: 0, aqiLevel: 0, aqiName: '', aqiUrl: '' },
    })
  }

  return {
    current: {
      city,
      tempC: String(baseTemp),
      feelsLikeC: String(baseTemp + Math.floor(Math.random() * 6) - 3),
      humidity: String(humidity),
      windSpeedKmph: String(Math.floor(Math.random() * 20) + 5),
      windDir16Point: windDir,
      windPower: '1-3',
      visibility: String(Math.floor(Math.random() * 20) + 5),
      pressure: String(Math.floor(Math.random() * 25) + 1000),
      uvIndex: String(Math.floor(Math.random() * 7) + 1),
      weatherDesc: wt.desc,
      icon: wt.icon,
      observationTime: `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`,
      aqi: '',
      aqiDesc: '',
      sunrise: '05:30',
      sunset: '19:30',
    },
    forecast,
    hourly: [],
    lifeIndex: {},
    limit: null,
    rise: [],
    updateTime: now.toLocaleString('zh-CN'),
    isFallback: true,
  }
}