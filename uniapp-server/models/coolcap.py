"""CoolCap 冰帽医疗数据模型（表前缀 YL_）"""
from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, DateTime, SmallInteger, Float, Text, JSON,
    ForeignKey, Index, Boolean
)
from sqlalchemy.orm import relationship
from database import Base


class YLPatient(Base):
    """患者档案"""
    __tablename__ = "YL_PATIENT"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="患者ID")
    user_id = Column(Integer, index=True, comment="关联users.id")
    name = Column(String(50), nullable=False, comment="姓名")
    gender = Column(SmallInteger, default=0, comment="0未知/1男/2女")
    birth_date = Column(String(20), default="", comment="出生日期YYYY-MM-DD")
    diagnosis = Column(String(120), default="", comment="诊断/化疗方案说明")
    chemo_regimen = Column(String(120), default="", comment="化疗方案名")
    allergy_note = Column(String(255), default="", comment="过敏/备注")
    status = Column(SmallInteger, default=1, comment="0停用/1启用")
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)


class YLDevice(Base):
    """冰帽设备"""
    __tablename__ = "YL_DEVICE"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, index=True, comment="绑定用户")
    device_sn = Column(String(64), unique=True, nullable=False, index=True, comment="设备序列号")
    ble_name = Column(String(64), default="", comment="蓝牙广播名")
    model = Column(String(50), default="CoolCap-SC6", comment="型号")
    zone_count = Column(SmallInteger, default=6, comment="分区数")
    firmware = Column(String(32), default="1.0.0", comment="固件版本")
    status = Column(SmallInteger, default=0, comment="0离线/1在线/2治疗中")
    last_online_at = Column(DateTime, nullable=True)
    remark = Column(String(255), default="")
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)


class YLProtocol(Base):
    """治疗时序方案"""
    __tablename__ = "YL_PROTOCOL"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, index=True, comment="所属用户；内置方案可为0")
    name = Column(String(100), nullable=False, comment="方案名称")
    is_builtin = Column(SmallInteger, default=0, comment="0自定义/1内置")
    description = Column(String(255), default="")
    total_duration_min = Column(Integer, default=0, comment="总时长分钟")
    status = Column(SmallInteger, default=1)
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)

    stages = relationship(
        "YLProtocolStage",
        back_populates="protocol",
        cascade="all, delete-orphan",
        order_by="YLProtocolStage.sort_order",
    )


class YLProtocolStage(Base):
    """方案阶段"""
    __tablename__ = "YL_PROTOCOL_STAGE"

    id = Column(Integer, primary_key=True, autoincrement=True)
    protocol_id = Column(Integer, ForeignKey("YL_PROTOCOL.id", ondelete="CASCADE"), index=True)
    sort_order = Column(SmallInteger, default=1, comment="阶段序号")
    name = Column(String(50), nullable=False, comment="阶段名：预冷/维持/回温")
    duration_min = Column(Integer, nullable=False, comment="时长分钟")
    target_temp = Column(Float, nullable=False, comment="目标头皮温度°C")
    max_duty = Column(Float, default=100, comment="最大功率%")
    note = Column(String(255), default="")

    protocol = relationship("YLProtocol", back_populates="stages")


class YLSafetyProfile(Base):
    """安全包络（全局或用户级）"""
    __tablename__ = "YL_SAFETY_PROFILE"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, index=True, default=0)
    name = Column(String(50), default="默认安全包络")
    scalp_lower_limit = Column(Float, default=12.0, comment="头皮下限°C")
    scalp_hard_stop = Column(Float, default=10.0, comment="紧急停机°C")
    hot_side_warn = Column(Float, default=60.0)
    hot_side_stop = Column(Float, default=65.0)
    current_max = Column(Float, default=2.0, comment="TEC最大电流A")
    dew_point_margin = Column(Float, default=2.0, comment="露点安全余量°C")
    delta_target = Column(Float, default=1.5, comment="全头温差目标°C")
    max_duty = Column(Float, default=100.0)
    status = Column(SmallInteger, default=1)
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)


class YLSession(Base):
    """治疗会话档案"""
    __tablename__ = "YL_SESSION"

    id = Column(Integer, primary_key=True, autoincrement=True)
    session_no = Column(String(40), unique=True, nullable=False, index=True)
    user_id = Column(Integer, index=True)
    patient_id = Column(Integer, ForeignKey("YL_PATIENT.id"), index=True, nullable=True)
    device_id = Column(Integer, ForeignKey("YL_DEVICE.id"), index=True, nullable=True)
    protocol_id = Column(Integer, ForeignKey("YL_PROTOCOL.id"), index=True, nullable=True)
    protocol_name = Column(String(100), default="")
    protocol_snapshot = Column(JSON, nullable=True, comment="方案快照")
    status = Column(SmallInteger, default=0, comment="0进行中/1已完成/2异常中止")
    start_time = Column(DateTime, default=datetime.now)
    end_time = Column(DateTime, nullable=True)
    duration_min = Column(Integer, default=0)
    env_temp = Column(Float, nullable=True, comment="环境温度")
    env_humidity = Column(Float, nullable=True, comment="湿度%")
    dew_point = Column(Float, nullable=True)
    min_temp = Column(Float, nullable=True)
    max_temp = Column(Float, nullable=True)
    avg_temp = Column(Float, nullable=True)
    max_delta_t = Column(Float, nullable=True)
    alarm_count = Column(Integer, default=0)
    end_reason = Column(String(100), default="用户结束")
    note = Column(String(255), default="")
    created_at = Column(DateTime, default=datetime.now)

    device = relationship("YLDevice", foreign_keys=[device_id])
    protocol = relationship("YLProtocol", foreign_keys=[protocol_id])
    patient = relationship("YLPatient", foreign_keys=[patient_id])


class YLSessionPoint(Base):
    """治疗时序采样点"""
    __tablename__ = "YL_SESSION_POINT"

    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(Integer, ForeignKey("YL_SESSION.id", ondelete="CASCADE"), index=True)
    ts = Column(DateTime, nullable=False, index=True, comment="采样时间")
    zone_f = Column(Float, nullable=True)
    zone_tl = Column(Float, nullable=True)
    zone_tr = Column(Float, nullable=True)
    zone_p = Column(Float, nullable=True)
    zone_ol = Column(Float, nullable=True)
    zone_or = Column(Float, nullable=True)
    avg_power = Column(Float, default=0)
    delta_t = Column(Float, default=0)

    __table_args__ = (
        Index("ix_yl_session_point_session_ts", "session_id", "ts"),
    )


class YLSessionZone(Base):
    """会话分区汇总"""
    __tablename__ = "YL_SESSION_ZONE"

    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(Integer, ForeignKey("YL_SESSION.id", ondelete="CASCADE"), index=True)
    zone_id = Column(String(8), nullable=False, comment="F/TL/TR/P/OL/OR")
    zone_name = Column(String(20), default="")
    setpoint = Column(Float, default=0)
    min_temp = Column(Float, nullable=True)
    max_temp = Column(Float, nullable=True)
    avg_temp = Column(Float, nullable=True)
    avg_power = Column(Float, default=0)
    compensate_count = Column(Integer, default=0)


class YLAlarm(Base):
    """报警记录"""
    __tablename__ = "YL_ALARM"

    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(Integer, index=True, nullable=True)
    user_id = Column(Integer, index=True)
    device_id = Column(Integer, index=True, nullable=True)
    zone_id = Column(String(8), nullable=True)
    level = Column(String(16), default="info", comment="info/warning/critical")
    code = Column(String(40), nullable=False, comment="FROST_RISK/HOT_WARN/...")
    message = Column(String(255), default="")
    occurred_at = Column(DateTime, default=datetime.now, index=True)
    ack = Column(SmallInteger, default=0, comment="0未确认/1已确认")
    ack_at = Column(DateTime, nullable=True)


class YLEnvSample(Base):
    """环境温湿度采样"""
    __tablename__ = "YL_ENV_SAMPLE"

    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(Integer, index=True, nullable=True)
    user_id = Column(Integer, index=True)
    temp = Column(Float, nullable=False)
    humidity = Column(Float, nullable=False)
    dew_point = Column(Float, nullable=False)
    margin = Column(Float, default=2.0)
    safe = Column(Boolean, default=True)
    ts = Column(DateTime, default=datetime.now, index=True)


class YLControlCommand(Base):
    """下行控制指令审计"""
    __tablename__ = "YL_CONTROL_COMMAND"

    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(Integer, index=True, nullable=True)
    user_id = Column(Integer, index=True)
    device_id = Column(Integer, index=True, nullable=True)
    cmd = Column(String(40), nullable=False, comment="START/STOP/SET_SETPOINT/SET_ENV/...")
    payload = Column(JSON, nullable=True)
    result = Column(SmallInteger, default=0, comment="0待执行/1成功/2失败")
    created_at = Column(DateTime, default=datetime.now)
