"""CoolCap 冰帽业务路由（YL_ 表）"""
from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from database import get_db
from models.coolcap import (
    YLAlarm, YLControlCommand, YLDevice, YLEnvSample, YLPatient,
    YLProtocol, YLProtocolStage, YLSafetyProfile, YLSession,
    YLSessionPoint, YLSessionZone
)
from models.user import User
from schemas.coolcap import (
    AlarmIn, ApiResponse, CommandIn, DeviceIn, EnvSampleIn, PatientIn,
    ProtocolIn, SessionCreateIn, SessionFinishIn
)
from services.auth import get_current_user

router = APIRouter(prefix="/api/coolcap", tags=["CoolCap冰帽"])


# ---------- 患者 ----------
@router.get("/patients", response_model=ApiResponse)
def list_patients(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.query(YLPatient).filter(YLPatient.user_id == user.id, YLPatient.status == 1).order_by(YLPatient.id.desc()).all()
    return ApiResponse(data=[{
        "id": r.id, "name": r.name, "gender": r.gender, "birth_date": r.birth_date,
        "diagnosis": r.diagnosis, "chemo_regimen": r.chemo_regimen, "allergy_note": r.allergy_note
    } for r in rows])


@router.post("/patients", response_model=ApiResponse)
def create_patient(body: PatientIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    p = YLPatient(user_id=user.id, **body.model_dump())
    db.add(p)
    db.commit()
    db.refresh(p)
    return ApiResponse(message="创建成功", data={"id": p.id})


@router.put("/patients/{pid}", response_model=ApiResponse)
def update_patient(pid: int, body: PatientIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    p = db.query(YLPatient).filter(YLPatient.id == pid, YLPatient.user_id == user.id).first()
    if not p:
        raise HTTPException(404, "患者不存在")
    for k, v in body.model_dump().items():
        setattr(p, k, v)
    db.commit()
    return ApiResponse(message="更新成功")


# ---------- 设备 ----------
@router.get("/devices", response_model=ApiResponse)
def list_devices(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.query(YLDevice).filter(YLDevice.user_id == user.id).order_by(YLDevice.id.desc()).all()
    return ApiResponse(data=[{
        "id": r.id, "device_sn": r.device_sn, "ble_name": r.ble_name, "model": r.model,
        "zone_count": r.zone_count, "firmware": r.firmware, "status": r.status,
        "last_online_at": r.last_online_at.isoformat() if r.last_online_at else None
    } for r in rows])


@router.post("/devices", response_model=ApiResponse)
def upsert_device(body: DeviceIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    row = db.query(YLDevice).filter(YLDevice.device_sn == body.device_sn).first()
    if not row:
        row = YLDevice(user_id=user.id, **body.model_dump())
        db.add(row)
    else:
        row.user_id = user.id
        row.ble_name = body.ble_name
        row.model = body.model
        row.zone_count = body.zone_count
        row.firmware = body.firmware
        row.remark = body.remark
        row.status = 1
        row.last_online_at = datetime.now()
    db.commit()
    db.refresh(row)
    return ApiResponse(message="绑定成功", data={"id": row.id, "device_sn": row.device_sn})


# ---------- 方案 ----------
def _protocol_out(p: YLProtocol) -> dict:
    return {
        "id": p.id,
        "user_id": p.user_id,
        "name": p.name,
        "is_builtin": p.is_builtin,
        "description": p.description,
        "total_duration_min": p.total_duration_min,
        "status": p.status,
        "updated_at": p.updated_at.isoformat() if p.updated_at else None,
        "stages": [{
            "id": s.id,
            "name": s.name,
            "duration_min": s.duration_min,
            "target_temp": s.target_temp,
            "max_duty": s.max_duty,
            "note": s.note,
            "sort_order": s.sort_order,
        } for s in sorted(p.stages, key=lambda x: x.sort_order)]
    }


def _ensure_builtin_protocols(db: Session):
    if db.query(YLProtocol).filter(YLProtocol.is_builtin == 1).count() > 0:
        return
    presets = [
        ("标准化疗冷却（预冷30+维持90+回温30）", "紫杉烷类等常规方案",
         [("预冷", 30, 18, 70), ("维持", 90, 16, 100), ("回温", 30, 22, 40)]),
        ("快速预冷（15+60）", "缩短预冷",
         [("快速预冷", 15, 17, 90), ("维持", 60, 16, 100)]),
        ("温和方案（高耐受）", "耐受优先",
         [("预冷", 30, 19, 60), ("维持", 90, 18, 80), ("回温", 20, 23, 35)]),
    ]
    for name, desc, stages in presets:
        p = YLProtocol(user_id=0, name=name, is_builtin=1, description=desc,
                       total_duration_min=sum(s[1] for s in stages), status=1)
        db.add(p)
        db.flush()
        for i, (sn, dur, temp, duty) in enumerate(stages, 1):
            db.add(YLProtocolStage(protocol_id=p.id, sort_order=i, name=sn,
                                   duration_min=dur, target_temp=temp, max_duty=duty))
    db.commit()


@router.get("/protocols", response_model=ApiResponse)
def list_protocols(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    _ensure_builtin_protocols(db)
    rows = db.query(YLProtocol).filter(
        (YLProtocol.user_id == user.id) | (YLProtocol.is_builtin == 1),
        YLProtocol.status == 1
    ).order_by(YLProtocol.is_builtin.desc(), YLProtocol.id.asc()).all()
    return ApiResponse(data=[_protocol_out(p) for p in rows])


@router.post("/protocols", response_model=ApiResponse)
def create_protocol(body: ProtocolIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    total = sum(s.duration_min for s in body.stages)
    p = YLProtocol(
        user_id=user.id, name=body.name, description=body.description,
        is_builtin=0, total_duration_min=total, status=1
    )
    db.add(p)
    db.flush()
    for i, s in enumerate(body.stages, 1):
        db.add(YLProtocolStage(
            protocol_id=p.id, sort_order=i, name=s.name, duration_min=s.duration_min,
            target_temp=s.target_temp, max_duty=s.max_duty, note=s.note
        ))
    db.commit()
    db.refresh(p)
    return ApiResponse(message="创建成功", data=_protocol_out(p))


@router.put("/protocols/{pid}", response_model=ApiResponse)
def update_protocol(pid: int, body: ProtocolIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    p = db.query(YLProtocol).filter(YLProtocol.id == pid, YLProtocol.user_id == user.id).first()
    if not p:
        raise HTTPException(404, "方案不存在或不可修改内置方案")
    if p.is_builtin == 1:
        raise HTTPException(400, "内置方案不可编辑，请另存为自定义方案")
    p.name = body.name
    p.description = body.description
    p.total_duration_min = sum(s.duration_min for s in body.stages)
    db.query(YLProtocolStage).filter(YLProtocolStage.protocol_id == p.id).delete()
    for i, s in enumerate(body.stages, 1):
        db.add(YLProtocolStage(
            protocol_id=p.id, sort_order=i, name=s.name, duration_min=s.duration_min,
            target_temp=s.target_temp, max_duty=s.max_duty, note=s.note
        ))
    db.commit()
    db.refresh(p)
    return ApiResponse(message="更新成功", data=_protocol_out(p))


@router.delete("/protocols/{pid}", response_model=ApiResponse)
def delete_protocol(pid: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    p = db.query(YLProtocol).filter(YLProtocol.id == pid, YLProtocol.user_id == user.id, YLProtocol.is_builtin == 0).first()
    if not p:
        raise HTTPException(404, "方案不存在")
    db.delete(p)
    db.commit()
    return ApiResponse(message="删除成功")


# ---------- 会话档案 ----------
@router.get("/sessions", response_model=ApiResponse)
def list_sessions(
    page: int = 1,
    page_size: int = 20,
    keyword: str = "",
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    q = db.query(YLSession).filter(YLSession.user_id == user.id)
    if keyword:
        q = q.filter(YLSession.protocol_name.contains(keyword))
    total = q.count()
    rows = q.order_by(YLSession.start_time.desc()).offset((page - 1) * page_size).limit(page_size).all()
    return ApiResponse(data={
        "total": total,
        "list": [{
            "id": r.id,
            "session_no": r.session_no,
            "protocol_name": r.protocol_name,
            "status": r.status,
            "start_time": r.start_time.isoformat() if r.start_time else None,
            "end_time": r.end_time.isoformat() if r.end_time else None,
            "duration_min": r.duration_min,
            "min_temp": r.min_temp,
            "max_temp": r.max_temp,
            "avg_temp": r.avg_temp,
            "max_delta_t": r.max_delta_t,
            "alarm_count": r.alarm_count,
            "end_reason": r.end_reason,
            "env_temp": r.env_temp,
            "env_humidity": r.env_humidity,
            "dew_point": r.dew_point,
        } for r in rows]
    })


@router.post("/sessions/start", response_model=ApiResponse)
def start_session(body: SessionCreateIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    protocol = None
    if body.protocol_id:
        protocol = db.query(YLProtocol).filter(YLProtocol.id == body.protocol_id).first()
        if not protocol:
            raise HTTPException(404, "方案不存在")
    device_id = None
    if body.device_sn:
        dev = db.query(YLDevice).filter(YLDevice.device_sn == body.device_sn).first()
        if dev:
            device_id = dev.id
            dev.status = 2
            dev.last_online_at = datetime.now()

    # Magnus dew point
    rh = max(1.0, min(100.0, body.env_humidity))
    a, b = 17.62, 243.12
    gamma = (a * body.env_temp) / (b + body.env_temp) + math_log(rh / 100.0)
    dew = (b * gamma) / (a - gamma)

    snapshot = _protocol_out(protocol) if protocol else None
    s = YLSession(
        session_no=f"S{datetime.now().strftime('%Y%m%d%H%M%S')}{user.id}",
        user_id=user.id,
        patient_id=body.patient_id,
        device_id=device_id,
        protocol_id=body.protocol_id,
        protocol_name=protocol.name if protocol else "自定义",
        protocol_snapshot=snapshot,
        status=0,
        start_time=datetime.now(),
        env_temp=body.env_temp,
        env_humidity=body.env_humidity,
        dew_point=round(dew, 1),
        note=body.note,
    )
    db.add(s)
    db.add(YLControlCommand(
        user_id=user.id, device_id=device_id, cmd="START",
        payload={"protocol_id": body.protocol_id, "env_temp": body.env_temp, "env_humidity": body.env_humidity},
        result=1,
    ))
    db.commit()
    db.refresh(s)
    return ApiResponse(message="会话已开始", data={
        "id": s.id, "session_no": s.session_no, "start_time": s.start_time.isoformat(),
        "dew_point": s.dew_point, "protocol": snapshot
    })


@router.get("/sessions/{sid}", response_model=ApiResponse)
def get_session(sid: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    s = db.query(YLSession).filter(YLSession.id == sid, YLSession.user_id == user.id).first()
    if not s:
        raise HTTPException(404, "会话不存在")
    points = db.query(YLSessionPoint).filter(YLSessionPoint.session_id == sid).order_by(YLSessionPoint.ts.asc()).all()
    zones = db.query(YLSessionZone).filter(YLSessionZone.session_id == sid).all()
    alarms = db.query(YLAlarm).filter(YLAlarm.session_id == sid).order_by(YLAlarm.occurred_at.asc()).all()
    return ApiResponse(data={
        "id": s.id,
        "session_no": s.session_no,
        "protocol_name": s.protocol_name,
        "protocol_snapshot": s.protocol_snapshot,
        "status": s.status,
        "start_time": s.start_time.isoformat() if s.start_time else None,
        "end_time": s.end_time.isoformat() if s.end_time else None,
        "duration_min": s.duration_min,
        "min_temp": s.min_temp,
        "max_temp": s.max_temp,
        "avg_temp": s.avg_temp,
        "max_delta_t": s.max_delta_t,
        "alarm_count": s.alarm_count,
        "end_reason": s.end_reason,
        "env_temp": s.env_temp,
        "env_humidity": s.env_humidity,
        "dew_point": s.dew_point,
        "points": [{
            "t": p.ts.isoformat(),
            "zone_f": p.zone_f, "zone_tl": p.zone_tl, "zone_tr": p.zone_tr,
            "zone_p": p.zone_p, "zone_ol": p.zone_ol, "zone_or": p.zone_or,
            "avg_power": p.avg_power, "delta_t": p.delta_t
        } for p in points],
        "zones": [{
            "zone_id": z.zone_id, "zone_name": z.zone_name, "setpoint": z.setpoint,
            "min_temp": z.min_temp, "max_temp": z.max_temp, "avg_temp": z.avg_temp,
            "avg_power": z.avg_power, "compensate_count": z.compensate_count
        } for z in zones],
        "alarms": [{
            "id": a.id, "level": a.level, "code": a.code, "message": a.message,
            "zone_id": a.zone_id, "occurred_at": a.occurred_at.isoformat() if a.occurred_at else None
        } for a in alarms]
    })


@router.post("/sessions/{sid}/finish", response_model=ApiResponse)
def finish_session(sid: int, body: SessionFinishIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    s = db.query(YLSession).filter(YLSession.id == sid, YLSession.user_id == user.id).first()
    if not s:
        raise HTTPException(404, "会话不存在")
    if s.status != 0:
        raise HTTPException(400, "会话已结束")
    end = datetime.now()
    s.status = body.status
    s.end_time = end
    s.duration_min = max(1, int((end - s.start_time).total_seconds() // 60))
    s.end_reason = body.end_reason
    s.min_temp = body.min_temp
    s.max_temp = body.max_temp
    s.avg_temp = body.avg_temp
    s.max_delta_t = body.max_delta_t
    s.alarm_count = body.alarm_count

    # batch insert points (cap to avoid huge payload)
    for p in body.points[:5000]:
        db.add(YLSessionPoint(
            session_id=s.id,
            ts=p.ts if isinstance(p.ts, datetime) else datetime.fromisoformat(str(p.ts).replace("Z", "")),
            zone_f=p.zone_f, zone_tl=p.zone_tl, zone_tr=p.zone_tr,
            zone_p=p.zone_p, zone_ol=p.zone_ol, zone_or=p.zone_or,
            avg_power=p.avg_power, delta_t=p.delta_t
        ))
    for z in body.zones:
        db.add(YLSessionZone(
            session_id=s.id,
            zone_id=str(z.get("zone_id", "")),
            zone_name=str(z.get("zone_name", "")),
            setpoint=float(z.get("setpoint") or 0),
            min_temp=z.get("min_temp"),
            max_temp=z.get("max_temp"),
            avg_temp=z.get("avg_temp"),
            avg_power=float(z.get("avg_power") or 0),
            compensate_count=int(z.get("compensate_count") or 0),
        ))
    for a in body.alarms:
        db.add(YLAlarm(
            session_id=s.id, user_id=user.id, device_id=s.device_id,
            zone_id=a.get("zone_id"),
            level=str(a.get("level") or "info"),
            code=str(a.get("code") or "UNKNOWN"),
            message=str(a.get("message") or ""),
            occurred_at=datetime.now(),
            ack=1,
            ack_at=datetime.now(),
        ))

    if s.device:
        s.device.status = 1
        s.device.last_online_at = end
    db.add(YLControlCommand(user_id=user.id, device_id=s.device_id, session_id=s.id,
                            cmd="STOP", payload={"reason": body.end_reason}, result=1))
    db.commit()
    return ApiResponse(message="会话已归档", data={"id": s.id, "session_no": s.session_no})


@router.get("/sessions/{sid}/export", response_model=ApiResponse)
def export_session(sid: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """临床追溯导出：返回完整 JSON 结构（前端可转 CSV）"""
    return get_session(sid, user, db)


@router.post("/sessions/{sid}/reproduce", response_model=ApiResponse)
def reproduce_session(sid: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """一键复现：将历史方案参数写回为可立即使用的运行参数"""
    s = db.query(YLSession).filter(YLSession.id == sid, YLSession.user_id == user.id).first()
    if not s:
        raise HTTPException(404, "会话不存在")
    snap = s.protocol_snapshot or {}
    stages = snap.get("stages") or []
    first = stages[0] if stages else None
    return ApiResponse(message="已生成复现参数", data={
        "protocol_id": s.protocol_id,
        "protocol_name": s.protocol_name,
        "protocol_snapshot": snap,
        "setpoints": {
            "F": (first or {}).get("target_temp", 18),
            "TL": (first or {}).get("target_temp", 16),
            "TR": (first or {}).get("target_temp", 16),
            "P": (first or {}).get("target_temp", 16),
            "OL": (first or {}).get("target_temp", 16),
            "OR": (first or {}).get("target_temp", 16),
        },
        "max_duty": (first or {}).get("max_duty", 100),
    })


# ---------- 报警 ----------
@router.get("/alarms", response_model=ApiResponse)
def list_alarms(
    page: int = 1,
    page_size: int = 20,
    level: str = "",
    session_id: Optional[int] = None,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    q = db.query(YLAlarm).filter(YLAlarm.user_id == user.id)
    if level:
        q = q.filter(YLAlarm.level == level)
    if session_id:
        q = q.filter(YLAlarm.session_id == session_id)
    total = q.count()
    rows = q.order_by(YLAlarm.occurred_at.desc()).offset((page - 1) * page_size).limit(page_size).all()
    return ApiResponse(data={
        "total": total,
        "list": [{
            "id": r.id, "session_id": r.session_id, "zone_id": r.zone_id,
            "level": r.level, "code": r.code, "message": r.message,
            "occurred_at": r.occurred_at.isoformat() if r.occurred_at else None,
            "ack": r.ack
        } for r in rows]
    })


@router.post("/alarms", response_model=ApiResponse)
def create_alarm(body: AlarmIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    device_id = None
    if body.device_sn:
        dev = db.query(YLDevice).filter(YLDevice.device_sn == body.device_sn).first()
        device_id = dev.id if dev else None
    a = YLAlarm(
        session_id=body.session_id, user_id=user.id, device_id=device_id,
        zone_id=body.zone_id, level=body.level, code=body.code,
        message=body.message, occurred_at=datetime.now()
    )
    db.add(a)
    db.commit()
    db.refresh(a)
    return ApiResponse(message="已记录", data={"id": a.id})


@router.post("/alarms/{aid}/ack", response_model=ApiResponse)
def ack_alarm(aid: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    a = db.query(YLAlarm).filter(YLAlarm.id == aid, YLAlarm.user_id == user.id).first()
    if not a:
        raise HTTPException(404, "报警不存在")
    a.ack = 1
    a.ack_at = datetime.now()
    db.commit()
    return ApiResponse(message="已确认")


# ---------- 环境采样 ----------
@router.post("/env/samples", response_model=ApiResponse)
def push_env(body: EnvSampleIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    db.add(YLEnvSample(
        session_id=body.session_id, user_id=user.id,
        temp=body.temp, humidity=body.humidity, dew_point=body.dew_point,
        margin=body.margin, safe=body.safe, ts=datetime.now()
    ))
    db.commit()
    return ApiResponse(message="ok")


@router.get("/env/latest", response_model=ApiResponse)
def env_latest(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    row = db.query(YLEnvSample).filter(YLEnvSample.user_id == user.id).order_by(YLEnvSample.id.desc()).first()
    if not row:
        return ApiResponse(data=None)
    return ApiResponse(data={
        "temp": row.temp, "humidity": row.humidity, "dew_point": row.dew_point,
        "margin": row.margin, "safe": row.safe, "ts": row.ts.isoformat() if row.ts else None
    })


# ---------- 安全包络 ----------
@router.get("/safety", response_model=ApiResponse)
def get_safety(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    row = db.query(YLSafetyProfile).filter(YLSafetyProfile.user_id == user.id).order_by(YLSafetyProfile.id.asc()).first()
    if not row:
        row = YLSafetyProfile(user_id=user.id)
        db.add(row)
        db.commit()
        db.refresh(row)
    return ApiResponse(data={
        "id": row.id,
        "name": row.name,
        "scalp_lower_limit": row.scalp_lower_limit,
        "scalp_hard_stop": row.scalp_hard_stop,
        "hot_side_warn": row.hot_side_warn,
        "hot_side_stop": row.hot_side_stop,
        "current_max": row.current_max,
        "dew_point_margin": row.dew_point_margin,
        "delta_target": row.delta_target,
        "max_duty": row.max_duty,
    })


@router.post("/commands", response_model=ApiResponse)
def push_command(body: CommandIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    device_id = None
    if body.device_sn:
        dev = db.query(YLDevice).filter(YLDevice.device_sn == body.device_sn).first()
        device_id = dev.id if dev else None
    c = YLControlCommand(
        session_id=body.session_id, user_id=user.id, device_id=device_id,
        cmd=body.cmd, payload=body.payload, result=0, created_at=datetime.now()
    )
    db.add(c)
    db.commit()
    db.refresh(c)
    return ApiResponse(message="指令已入队", data={"id": c.id})


def math_log(x: float) -> float:
    import math
    return math.log(x)
