/**
 * 娱乐中心 API 接口
 */
import { get, post, del } from './request'

// ==================== 公共接口 ====================

/** 获取分类列表 */
export const getCategories = (type: string) => get(`/api/ent/categories/${type}`)

/** 获取轮播图 */
export const getBanners = (position: string) => get(`/api/ent/banners/${position}`)

/** 添加收藏 */
export const addFavorite = (content_type: string, content_id: number) =>
  post('/api/ent/favorite', { content_type, content_id })

/** 取消收藏 */
export const removeFavorite = (content_type: string, content_id: number) =>
  del(`/api/ent/favorite?content_type=${content_type}&content_id=${content_id}`)

/** 检查收藏状态 */
export const checkFavorite = (content_type: string, content_id: number) =>
  get(`/api/ent/favorite/check?content_type=${content_type}&content_id=${content_id}`)

/** 获取收藏列表 */
export const getFavorites = (content_type: string, page = 1, page_size = 20) =>
  get(`/api/ent/favorites?content_type=${content_type}&page=${page}&page_size=${page_size}`)

/** 获取历史记录 */
export const getHistory = (content_type: string, page = 1, page_size = 20) =>
  get(`/api/ent/history?content_type=${content_type}&page=${page}&page_size=${page_size}`)

/** 清空历史记录 */
export const clearHistory = (content_type: string) =>
  del(`/api/ent/history?content_type=${content_type}`)

/** 全局搜索 */
export const globalSearch = (keyword: string, type = 'all') =>
  get(`/api/ent/search?keyword=${keyword}&type=${type}`)

// ==================== 游戏中心 ====================

/** 游戏首页数据 */
export const getGameHome = () => get('/api/ent/game/home')

/** 游戏列表 */
export const getGameList = (params: {
  page?: number; page_size?: number; category_id?: number;
  keyword?: string; sort_by?: string; is_free?: number;
}) => get('/api/ent/game/list', params)

/** 游戏详情 */
export const getGameDetail = (id: number) => get(`/api/ent/game/detail/${id}`)

/** 开始游戏 */
export const startGame = (id: number) => post(`/api/ent/game/play/${id}`)

/** 结束游戏 */
export const endGame = (id: number, session_id: string, duration_sec: number) =>
  post(`/api/ent/game/play/end/${id}`, { session_id, duration_sec })

/** 游戏排行榜 */
export const getGameRank = (rank_type = 'hot', limit = 20) =>
  get(`/api/ent/game/rank?rank_type=${rank_type}&limit=${limit}`)

/** 我的游戏 */
export const getMyGames = (type = 'recent') => get(`/api/ent/game/my?type=${type}`)

// ==================== 音乐中心 ====================

/** 音乐首页数据 */
export const getMusicHome = () => get('/api/ent/music/home')

/** 歌曲列表 */
export const getSongList = (params: {
  page?: number; page_size?: number; genre?: string;
  language?: string; keyword?: string; sort_by?: string;
}) => get('/api/ent/music/songs', params)

/** 歌曲详情 */
export const getSongDetail = (id: number) => get(`/api/ent/music/song/${id}`)

/** 播放歌曲（记录播放） */
export const playSong = (id: number) => post(`/api/ent/music/song/${id}/play`)

/** 歌单列表 */
export const getPlaylistList = (params?: { page?: number; page_size?: number; keyword?: string; sort_by?: string }) =>
  get('/api/ent/music/playlists', params)

/** 歌单详情 */
export const getPlaylistDetail = (id: number) => get(`/api/ent/music/playlist/${id}`)

/** 歌手列表 */
export const getArtistList = (params?: { page?: number; page_size?: number; region?: string; keyword?: string }) =>
  get('/api/ent/music/artists', params)

/** 歌手详情 */
export const getArtistDetail = (id: number) => get(`/api/ent/music/artist/${id}`)

/** 音乐排行榜 */
export const getMusicRank = (rank_type = 'hot', limit = 20) =>
  get(`/api/ent/music/rank?rank_type=${rank_type}&limit=${limit}`)

/** 我的音乐 */
export const getMyMusic = (type = 'recent') => get(`/api/ent/music/my?type=${type}`)

// ==================== 视频影音 ====================

/** 视频首页数据 */
export const getVideoHome = () => get('/api/ent/video/home')

/** 视频列表 */
export const getVideoList = (params: {
  page?: number; page_size?: number; category_id?: number;
  video_type?: string; region?: string; year?: string;
  keyword?: string; sort_by?: string;
}) => get('/api/ent/video/list', params)

/** 视频详情 */
export const getVideoDetail = (id: number) => get(`/api/ent/video/detail/${id}`)

/** 更新播放进度 */
export const updateVideoProgress = (data: {
  video_id: number; episode_id?: number; episode_num?: number; progress_sec?: number;
}) => post('/api/ent/video/progress', data)

/** 视频排行榜 */
export const getVideoRank = (rank_type = 'hot', limit = 20) =>
  get(`/api/ent/video/rank?rank_type=${rank_type}&limit=${limit}`)

/** 我的影音 */
export const getMyVideos = (type = 'history') => get(`/api/ent/video/my?type=${type}`)

// ==================== 网络小说 ====================

/** 小说首页数据 */
export const getNovelHome = () => get('/api/ent/novel/home')

/** 小说列表 */
export const getNovelList = (params: {
  page?: number; page_size?: number; category_id?: number;
  genre?: string; gender?: string; status_text?: string;
  keyword?: string; sort_by?: string;
}) => get('/api/ent/novel/list', params)

/** 小说详情 */
export const getNovelDetail = (id: number) => get(`/api/ent/novel/detail/${id}`)

/** 获取章节内容 */
export const getChapterContent = (chapter_id: number) => get(`/api/ent/novel/chapter/${chapter_id}`)

/** 更新阅读进度 */
export const updateReadProgress = (data: {
  novel_id: number; chapter_id?: number; chapter_num?: number; progress?: number;
}) => post('/api/ent/novel/read/progress', data)

/** 小说排行榜 */
export const getNovelRank = (rank_type = 'hot', limit = 20) =>
  get(`/api/ent/novel/rank?rank_type=${rank_type}&limit=${limit}`)

/** 我的书架 */
export const getMyNovels = (type = 'shelf') => get(`/api/ent/novel/my?type=${type}`)

/** 在线搜索小说（实时爬取 piquge.com） */
export const crawlSearchNovels = (keyword: string, page = 1) =>
  get(`/api/ent/novel/crawl/search?keyword=${encodeURIComponent(keyword)}&page=${page}`)

/** 获取小说详情+章节列表（实时爬取） */
export const crawlNovelInfo = (url: string, loadChapters = false) =>
  get(`/api/ent/novel/crawl/info?url=${encodeURIComponent(url)}&load_chapters=${loadChapters}`)

/** 获取完整章节目录（实时爬取） */
export const crawlChapterList = (url: string) =>
  get(`/api/ent/novel/crawl/chapters?url=${encodeURIComponent(url)}`)

/** 获取章节正文内容（实时爬取） */
export const crawlChapterContent = (url: string) =>
  get(`/api/ent/novel/crawl/chapter?url=${encodeURIComponent(url)}`)
