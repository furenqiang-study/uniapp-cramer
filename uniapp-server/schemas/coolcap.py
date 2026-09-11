"""CoolCap schemas（YL_ 业务）"""
from datetime import datetime
from typing import Any, List, Optional
from pydantic import BaseModel, Field


class ApiResponse(BaseModel):
    code: int = 200
    message: str = "success"
    data: Any = None


class StageIn(BaseModel):
    name: str
    duration_min: int = Field(ge=1, le=480)
    target_temp: float = Field(ge=5, le=35)
    max_duty: float = Field(ge=0, le=100)
    note: str = ""


class ProtocolIn(BaseModel):
    name: str
    description: str = ""
    stages: List[StageIn]


class ProtocolOut(BaseModel):
    id: int
    user_id: int
    name: str
    is_builtin: int
    description: str
    total_duration_min: int
    status: int
    stages: List[dict]
    updated_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


class SessionCreateIn(BaseModel):
    protocol_id: Optional[int] = None
    patient_id: Optional[int] = None
    device_sn: Optional[str] = None
    env_temp: float = 26
    env_humidity: float = 55
    note: str = ""


class SessionPointIn(BaseModel):
    ts: datetime
    zone_f: Optional[float] = None
    zone_tl: Optional[float] = None
    zone_tr: Optional[float] = None
    zone_p: Optional[float] = None
    zone_ol: Optional[float] = None
    zone_or: Optional[float] = None
    avg_power: float = 0
    delta_t: float = 0


class SessionFinishIn(BaseModel):
    status: int = 1
    end_reason: str = "用户结束"
    min_temp: Optional[float] = None
    max_temp: Optional[float] = None
    avg_temp: Optional[float] = None
    max_delta_t: Optional[float] = None
    alarm_count: int = 0
    points: List[SessionPointIn] = []
    zones: List[dict] = []
    alarms: List[dict] = []


class AlarmIn(BaseModel):
    session_id: Optional[int] = None
    device_sn: Optional[str] = None
    zone_id: Optional[str] = None
    level: str = "info"
    code: str
    message: str = ""


class PatientIn(BaseModel):
    name: str
    gender: int = 0
    birth_date: str = ""
    diagnosis: str = ""
    chemo_regimen: str = ""
    allergy_note: str = ""


class DeviceIn(BaseModel):
    device_sn: str
    ble_name: str = ""
    model: str = "CoolCap-SC6"
    zone_count: int = 6
    firmware: str = "1.0.0"
    remark: str = ""


class EnvSampleIn(BaseModel):
    temp: float
    humidity: float
    dew_point: float
    margin: float = 2.0
    safe: bool = True
    session_id: Optional[int] = None


class CommandIn(BaseModel):
    cmd: str
    payload: dict = {}
    device_sn: Optional[str] = None
    session_id: Optional[int] = None
