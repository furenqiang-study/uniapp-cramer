import { defineConfig } from 'vite'
import uni from '@dcloudio/vite-plugin-uni'
import { resolve } from 'path'

export default defineConfig({
  base: '/uniapp-cramer/',
  plugins: [uni()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src')
    }
  },
  server: {
    port: 5173,
    host: '0.0.0.0',
    proxy: {
      '/uniapp-api': {
        target: 'http://localhost:8022',
        changeOrigin: true,
        rewrite: (path: string) => path.replace(/^\/uniapp-api/, '/api')
      },
      // 腾讯天气 API 代理
      '/tencent-weather': {
        target: 'https://i.news.qq.com',
        changeOrigin: true,
        rewrite: (path: string) => path.replace(/^\/tencent-weather/, ''),
        headers: {
          'Referer': 'https://tianqi.qq.com/',
          'Origin': 'https://tianqi.qq.com'
        }
      }
    }
  }
})