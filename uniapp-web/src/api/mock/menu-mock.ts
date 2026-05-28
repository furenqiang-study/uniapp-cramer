/**
 * 菜单管理 Mock 数据 & 模拟接口
 * 后续对接真实接口时，只需替换此文件中的模拟实现即可
 */

export interface MenuItem {
  id: string
  name: string
  icon: string
  path: string
  parentId: string | null
  sort: number
  status: 0 | 1  // 0-禁用 1-启用
  type: 1 | 2 | 3  // 1-目录 2-菜单 3-按钮
  permission: string
  createTime: string
  children?: MenuItem[]
}

// 模拟数据存储
let menuList: MenuItem[] = [
  {
    id: '1',
    name: '系统管理',
    icon: '⚙️',
    path: '/system',
    parentId: null,
    sort: 1,
    status: 1,
    type: 1,
    permission: '',
    createTime: '2026-01-15 10:00:00',
    children: [
      {
        id: '1-1',
        name: '用户管理',
        icon: '👤',
        path: '/system/user',
        parentId: '1',
        sort: 1,
        status: 1,
        type: 2,
        permission: 'system:user:list',
        createTime: '2026-01-15 10:00:00'
      },
      {
        id: '1-2',
        name: '角色管理',
        icon: '🎭',
        path: '/system/role',
        parentId: '1',
        sort: 2,
        status: 1,
        type: 2,
        permission: 'system:role:list',
        createTime: '2026-01-15 10:00:00'
      },
      {
        id: '1-3',
        name: '菜单管理',
        icon: '📋',
        path: '/system/menu',
        parentId: '1',
        sort: 3,
        status: 1,
        type: 2,
        permission: 'system:menu:list',
        createTime: '2026-01-15 10:00:00'
      }
    ]
  },
  {
    id: '2',
    name: '数据管理',
    icon: '📊',
    path: '/data',
    parentId: null,
    sort: 2,
    status: 1,
    type: 1,
    permission: '',
    createTime: '2026-02-20 14:30:00',
    children: [
      {
        id: '2-1',
        name: '数据统计',
        icon: '📈',
        path: '/data/statistics',
        parentId: '2',
        sort: 1,
        status: 1,
        type: 2,
        permission: 'data:statistics:list',
        createTime: '2026-02-20 14:30:00'
      },
      {
        id: '2-2',
        name: '数据报表',
        icon: '📑',
        path: '/data/report',
        parentId: '2',
        sort: 2,
        status: 0,
        type: 2,
        permission: 'data:report:list',
        createTime: '2026-02-20 14:30:00'
      }
    ]
  },
  {
    id: '3',
    name: '内容管理',
    icon: '📝',
    path: '/content',
    parentId: null,
    sort: 3,
    status: 1,
    type: 1,
    permission: '',
    createTime: '2026-03-10 09:15:00',
    children: [
      {
        id: '3-1',
        name: '文章管理',
        icon: '📄',
        path: '/content/article',
        parentId: '3',
        sort: 1,
        status: 1,
        type: 2,
        permission: 'content:article:list',
        createTime: '2026-03-10 09:15:00'
      },
      {
        id: '3-2',
        name: '分类管理',
        icon: '🏷️',
        path: '/content/category',
        parentId: '3',
        sort: 2,
        status: 1,
        type: 2,
        permission: 'content:category:list',
        createTime: '2026-03-10 09:15:00'
      }
    ]
  },
  {
    id: '4',
    name: '财务管理',
    icon: '💰',
    path: '/finance',
    parentId: null,
    sort: 4,
    status: 1,
    type: 1,
    permission: '',
    createTime: '2026-04-05 16:45:00',
    children: [
      {
        id: '4-1',
        name: '订单管理',
        icon: '🛒',
        path: '/finance/order',
        parentId: '4',
        sort: 1,
        status: 1,
        type: 2,
        permission: 'finance:order:list',
        createTime: '2026-04-05 16:45:00'
      },
      {
        id: '4-2',
        name: '退款管理',
        icon: '💸',
        path: '/finance/refund',
        parentId: '4',
        sort: 2,
        status: 0,
        type: 2,
        permission: 'finance:refund:list',
        createTime: '2026-04-05 16:45:00'
      }
    ]
  },
  {
    id: '5',
    name: '营销管理',
    icon: '🎯',
    path: '/marketing',
    parentId: null,
    sort: 5,
    status: 0,
    type: 1,
    permission: '',
    createTime: '2026-05-01 11:20:00',
    children: [
      {
        id: '5-1',
        name: '优惠券管理',
        icon: '🎫',
        path: '/marketing/coupon',
        parentId: '5',
        sort: 1,
        status: 0,
        type: 2,
        permission: 'marketing:coupon:list',
        createTime: '2026-05-01 11:20:00'
      }
    ]
  }
]

// 辅助函数：生成唯一 ID
function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2, 8)
}

// 辅助函数：格式化当前时间
function formatNow(): string {
  const now = new Date()
  const pad = (n: number) => n.toString().padStart(2, '0')
  return `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`
}

// 模拟延迟
function delay(ms = 300): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms))
}

// ========== 模拟 API 接口 ==========

/** 获取菜单列表（树形结构） */
export async function getMenuTree(): Promise<MenuItem[]> {
  await delay()
  return JSON.parse(JSON.stringify(menuList))
}

/** 获取菜单平铺列表 */
export async function getMenuList(): Promise<MenuItem[]> {
  await delay()
  const flatList: MenuItem[] = []
  function flatten(list: MenuItem[]) {
    list.forEach(item => {
      const { children, ...rest } = item
      flatList.push(rest as MenuItem)
      if (children) flatten(children)
    })
  }
  flatten(menuList)
  return JSON.parse(JSON.stringify(flatList))
}

/** 新增菜单 */
export async function addMenu(data: Partial<MenuItem>): Promise<MenuItem> {
  await delay()
  const newItem: MenuItem = {
    id: generateId(),
    name: data.name || '',
    icon: data.icon || '📄',
    path: data.path || '',
    parentId: data.parentId || null,
    sort: data.sort || 0,
    status: data.status ?? 1,
    type: data.type || 2,
    permission: data.permission || '',
    createTime: formatNow()
  }

  if (newItem.parentId) {
    // 添加为子菜单
    function addToParent(list: MenuItem[]): boolean {
      for (const item of list) {
        if (item.id === newItem.parentId) {
          if (!item.children) item.children = []
          item.children.push(newItem)
          return true
        }
        if (item.children && addToParent(item.children)) return true
      }
      return false
    }
    addToParent(menuList)
  } else {
    // 添加为顶级菜单
    menuList.push(newItem)
  }

  return JSON.parse(JSON.stringify(newItem))
}

/** 修改菜单 */
export async function updateMenu(id: string, data: Partial<MenuItem>): Promise<MenuItem | null> {
  await delay()
  let found: MenuItem | null = null

  function updateInList(list: MenuItem[]): boolean {
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === id) {
        list[i] = { ...list[i], ...data, id } as MenuItem
        found = list[i]
        return true
      }
      if (list[i].children && updateInList(list[i].children!)) return true
    }
    return false
  }

  updateInList(menuList)
  return found ? JSON.parse(JSON.stringify(found)) : null
}

/** 删除菜单 */
export async function deleteMenu(id: string): Promise<boolean> {
  await delay()

  function deleteFromList(list: MenuItem[]): boolean {
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === id) {
        list.splice(i, 1)
        return true
      }
      if (list[i].children && deleteFromList(list[i].children!)) return true
    }
    return false
  }

  return deleteFromList(menuList)
}

/** 获取单个菜单详情 */
export async function getMenuDetail(id: string): Promise<MenuItem | null> {
  await delay()

  function findInList(list: MenuItem[]): MenuItem | null {
    for (const item of list) {
      if (item.id === id) return JSON.parse(JSON.stringify(item))
      if (item.children) {
        const found = findInList(item.children)
        if (found) return found
      }
    }
    return null
  }

  return findInList(menuList)
}