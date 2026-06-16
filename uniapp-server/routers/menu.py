"""菜单路由"""
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from database import get_db
from models.menu import Menu
from models.user import User
from models.log import OperationLog
from schemas.menu import MenuCreate, MenuUpdate, MenuInfo
from schemas.user import ApiResponse
from services.auth import get_current_user

router = APIRouter(prefix="/api/menus", tags=["菜单"])


def build_menu_tree(menus: list, parent_id: int = 0) -> list:
    """构建菜单树形结构"""
    tree = []
    for menu in menus:
        if menu.parent_id == parent_id:
            children = build_menu_tree(menus, menu.id)
            node = MenuInfo(
                id=menu.id,
                name=menu.name,
                icon=menu.icon,
                path=menu.path,
                parent_id=menu.parent_id,
                sort_order=menu.sort_order,
                status=menu.status,
                created_at=menu.created_at,
                updated_at=menu.updated_at,
                children=children if children else [],
            )
            tree.append(node)
    tree.sort(key=lambda x: x.sort_order)
    return tree


@router.get("", response_model=ApiResponse)
def get_menus(
    tree: bool = True,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """获取菜单列表"""
    menus = db.query(Menu).order_by(Menu.sort_order).all()
    if tree:
        tree_data = build_menu_tree(menus)
        return ApiResponse(code=200, message="success", data=[m.model_dump() for m in tree_data])
    else:
        menu_list = [MenuInfo.model_validate(m).model_dump() for m in menus]
        return ApiResponse(code=200, message="success", data=menu_list)


@router.get("/{menu_id}", response_model=ApiResponse)
def get_menu(
    menu_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """获取单个菜单详情"""
    menu = db.query(Menu).filter(Menu.id == menu_id).first()
    if not menu:
        return ApiResponse(code=404, message="菜单不存在")
    return ApiResponse(code=200, message="success", data=MenuInfo.model_validate(menu).model_dump())


@router.post("", response_model=ApiResponse)
def create_menu(
    data: MenuCreate,
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """新增菜单"""
    menu = Menu(**data.model_dump())
    db.add(menu)
    db.commit()
    db.refresh(menu)

    # 记录日志
    client_ip = request.client.host if request.client else ""
    log = OperationLog(
        user_id=current_user.id,
        username=current_user.username,
        action="create",
        module="menu",
        detail=f"新增菜单: {menu.name}",
        ip=client_ip,
    )
    db.add(log)
    db.commit()

    return ApiResponse(code=200, message="创建成功", data=MenuInfo.model_validate(menu).model_dump())


@router.put("/{menu_id}", response_model=ApiResponse)
def update_menu(
    menu_id: int,
    data: MenuUpdate,
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """更新菜单"""
    menu = db.query(Menu).filter(Menu.id == menu_id).first()
    if not menu:
        return ApiResponse(code=404, message="菜单不存在")

    update_data = data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(menu, key, value)
    db.commit()
    db.refresh(menu)

    # 记录日志
    client_ip = request.client.host if request.client else ""
    log = OperationLog(
        user_id=current_user.id,
        username=current_user.username,
        action="update",
        module="menu",
        detail=f"更新菜单: {menu.name} (ID: {menu_id})",
        ip=client_ip,
    )
    db.add(log)
    db.commit()

    return ApiResponse(code=200, message="更新成功", data=MenuInfo.model_validate(menu).model_dump())


@router.delete("/{menu_id}", response_model=ApiResponse)
def delete_menu(
    menu_id: int,
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """删除菜单"""
    menu = db.query(Menu).filter(Menu.id == menu_id).first()
    if not menu:
        return ApiResponse(code=404, message="菜单不存在")

    # 同时删除子菜单
    db.query(Menu).filter(Menu.parent_id == menu_id).delete()
    menu_name = menu.name
    db.delete(menu)
    db.commit()

    # 记录日志
    client_ip = request.client.host if request.client else ""
    log = OperationLog(
        user_id=current_user.id,
        username=current_user.username,
        action="delete",
        module="menu",
        detail=f"删除菜单: {menu_name} (ID: {menu_id})",
        ip=client_ip,
    )
    db.add(log)
    db.commit()

    return ApiResponse(code=200, message="删除成功")