<script setup lang="ts">
import { onLaunch, onShow, onHide } from '@dcloudio/uni-app'

onLaunch(() => {
  const token = uni.getStorageSync('token') || uni.getStorageSync('cc_token')
  const pages = getCurrentPages()
  const current = pages[pages.length - 1] as any
  const route = current?.route || current?.page?.route || ''
  // 仅在无 token 且不在登录页时跳转，避免登录成功后被 onLaunch 顶回登录
  if (!token && !String(route).includes('login')) {
    uni.reLaunch({ url: '/pages/login/login' })
  }
})

onShow(() => {})
onHide(() => {})
</script>

<style lang="scss">
@import "uview-plus/index.scss";

page {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC',
    'Hiragino Sans GB', 'Microsoft YaHei', 'Helvetica Neue', Helvetica, Arial,
    sans-serif;
  font-size: 28rpx;
  color: #0f172a;
  background-color: #f4f7fb;
  box-sizing: border-box;
  -webkit-font-smoothing: antialiased;
}

view,
text,
scroll-view,
swiper,
input,
textarea,
button,
image {
  box-sizing: border-box;
}

button::after {
  border: none;
}

::-webkit-scrollbar {
  display: none;
  width: 0;
  height: 0;
  color: transparent;
}

.safe-area-bottom {
  padding-bottom: constant(safe-area-inset-bottom);
  padding-bottom: env(safe-area-inset-bottom);
}
</style>
