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
        rewrite: (path: string) => path.replace(/^\/uniapp-api/, '')
      }
    }
  }
})