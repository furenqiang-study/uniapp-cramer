"""API接口测试脚本"""
import urllib.request
import json

BASE = "http://localhost:8022"
token = ""

def api(method, path, data=None):
    global token
    url = BASE + path
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    resp = urllib.request.urlopen(req)
    result = json.loads(resp.read().decode())
    return result

print("=" * 50)
print("1. 健康检查")
r = api("GET", "/api/health")
print(f"   结果: {r}")
assert r["status"] == "ok", "健康检查失败"

print("\n2. 登录 (admin/123456)")
r = api("POST", "/api/auth/login", {"username": "admin", "password": "123456"})
print(f"   code: {r['code']}, message: {r['message']}")
assert r["code"] == 200, f"登录失败: {r}"
token = r["data"]["access_token"]
print(f"   token: {token[:20]}...")
print(f"   用户: {r['data']['user']}")

print("\n3. 获取当前用户")
r = api("GET", "/api/auth/current")
print(f"   code: {r['code']}, 用户: {r['data']['username']} ({r['data']['nickname']})")
assert r["code"] == 200

print("\n4. 获取菜单列表(树形)")
r = api("GET", "/api/menus?tree=true")
print(f"   code: {r['code']}, 菜单数: {len(r['data'])}")
for m in r["data"]:
    children = m.get("children", [])
    print(f"   - {m['name']} ({m['icon']}) path={m['path']} children={len(children)}")
assert r["code"] == 200

print("\n5. 获取菜单列表(平铺)")
r = api("GET", "/api/menus?tree=false")
print(f"   code: {r['code']}, 菜单数: {len(r['data'])}")
assert r["code"] == 200

print("\n6. 新增菜单")
r = api("POST", "/api/menus", {"name": "测试菜单", "icon": "🔧", "path": "/test", "parent_id": 0, "sort_order": 99, "status": 1})
print(f"   code: {r['code']}, 新菜单ID: {r['data']['id']}, name: {r['data']['name']}")
assert r["code"] == 200
new_id = r["data"]["id"]

print("\n7. 修改菜单")
r = api("PUT", f"/api/menus/{new_id}", {"name": "测试菜单(已修改)", "status": 0})
print(f"   code: {r['code']}, name: {r['data']['name']}, status: {r['data']['status']}")
assert r["code"] == 200

print("\n8. 获取单个菜单详情")
r = api("GET", f"/api/menus/{new_id}")
print(f"   code: {r['code']}, name: {r['data']['name']}")
assert r["code"] == 200

print("\n9. 删除菜单")
r = api("DELETE", f"/api/menus/{new_id}")
print(f"   code: {r['code']}, message: {r['message']}")
assert r["code"] == 200

print("\n10. 首页统计")
r = api("GET", "/api/home/stats")
print(f"    code: {r['code']}")
print(f"    用户数: {r['data']['userCount']}, 菜单数: {r['data']['menuCount']}")
print(f"    日志总数: {r['data']['logCount']}, 今日操作: {r['data']['todayLogCount']}")
print(f"    最近登录: {len(r['data']['recentLogins'])}条")
assert r["code"] == 200

print("\n11. 用户信息")
r = api("GET", "/api/users/profile")
print(f"    code: {r['code']}, username: {r['data']['username']}, nickname: {r['data']['nickname']}")
assert r["code"] == 200

print("\n12. 更新用户信息")
r = api("PUT", "/api/users/profile", {"nickname": "超级管理员"})
print(f"    code: {r['code']}, nickname: {r['data']['nickname']}")
assert r["code"] == 200

print("\n13. 操作日志列表")
r = api("GET", "/api/logs?page=1&page_size=5")
print(f"    code: {r['code']}, total: {r['data']['total']}, 当前页: {len(r['data']['list'])}条")
for log in r["data"]["list"]:
    print(f"    - [{log['action']}] {log['username']} | {log['module']} | {log['detail']} | {log['created_at']}")
assert r["code"] == 200

print("\n14. 登录失败测试")
try:
    r = api("POST", "/api/auth/login", {"username": "admin", "password": "wrong"})
    print(f"    结果: {r}")
except Exception as e:
    print(f"    预期的错误: {e}")

print("\n15. 未授权访问测试")
try:
    old_token = token
    token = ""
    r = api("GET", "/api/menus")
    print(f"    结果: {r}")
except urllib.error.HTTPError as e:
    print(f"    预期的401错误: {e.code}")
finally:
    token = old_token

print("\n" + "=" * 50)
print("✅ 所有接口测试完成！")