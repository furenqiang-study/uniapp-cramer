export interface MenuItem {
  id: string
  name: string
  icon: string
  path: string
  parentId: string | null
  sort: number
  status: 0 | 1
  type: 1 | 2 | 3
  permission: string
  createTime: string
  children?: MenuItem[]
}

let menuList: MenuItem[] = []

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2, 8)
}

function formatNow(): string {
  const now = new Date()
  const pad = (n: number) => n.toString().padStart(2, '0')
  return `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`
}

function delay(ms = 300): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms))
}

export async function getMenuTree(): Promise<MenuItem[]> {
  await delay()
  return JSON.parse(JSON.stringify(menuList))
}

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
    menuList.push(newItem)
  }

  return JSON.parse(JSON.stringify(newItem))
}

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