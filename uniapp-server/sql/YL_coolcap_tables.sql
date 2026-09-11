-- CoolCap 医疗业务表（前缀 YL_）
-- 数据库：study_uniapp（与现有库共用）
-- 说明：应用启动时 SQLAlchemy create_all 也会建表；本文件供人工/DBA 对照

CREATE TABLE IF NOT EXISTS `YL_PATIENT` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NULL DEFAULT NULL COMMENT '关联users.id',
  `name` VARCHAR(50) NOT NULL COMMENT '姓名',
  `gender` SMALLINT DEFAULT 0,
  `birth_date` VARCHAR(20) DEFAULT '',
  `diagnosis` VARCHAR(120) DEFAULT '',
  `chemo_regimen` VARCHAR(120) DEFAULT '',
  `allergy_note` VARCHAR(255) DEFAULT '',
  `status` SMALLINT DEFAULT 1,
  `created_at` DATETIME NULL,
  `updated_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  KEY `ix_yl_patient_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='患者档案';

CREATE TABLE IF NOT EXISTS `YL_DEVICE` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NULL,
  `device_sn` VARCHAR(64) NOT NULL,
  `ble_name` VARCHAR(64) DEFAULT '',
  `model` VARCHAR(50) DEFAULT 'CoolCap-SC6',
  `zone_count` SMALLINT DEFAULT 6,
  `firmware` VARCHAR(32) DEFAULT '1.0.0',
  `status` SMALLINT DEFAULT 0,
  `last_online_at` DATETIME NULL,
  `remark` VARCHAR(255) DEFAULT '',
  `created_at` DATETIME NULL,
  `updated_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_yl_device_sn` (`device_sn`),
  KEY `ix_yl_device_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='冰帽设备';

CREATE TABLE IF NOT EXISTS `YL_PROTOCOL` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT DEFAULT 0,
  `name` VARCHAR(100) NOT NULL,
  `is_builtin` SMALLINT DEFAULT 0,
  `description` VARCHAR(255) DEFAULT '',
  `total_duration_min` INT DEFAULT 0,
  `status` SMALLINT DEFAULT 1,
  `created_at` DATETIME NULL,
  `updated_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  KEY `ix_yl_protocol_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='治疗时序方案';

CREATE TABLE IF NOT EXISTS `YL_PROTOCOL_STAGE` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `protocol_id` INT NOT NULL,
  `sort_order` SMALLINT DEFAULT 1,
  `name` VARCHAR(50) NOT NULL,
  `duration_min` INT NOT NULL,
  `target_temp` FLOAT NOT NULL,
  `max_duty` FLOAT DEFAULT 100,
  `note` VARCHAR(255) DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `ix_yl_stage_protocol` (`protocol_id`),
  CONSTRAINT `fk_yl_stage_protocol` FOREIGN KEY (`protocol_id`) REFERENCES `YL_PROTOCOL` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='方案阶段';

CREATE TABLE IF NOT EXISTS `YL_SAFETY_PROFILE` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT DEFAULT 0,
  `name` VARCHAR(50) DEFAULT '默认安全包络',
  `scalp_lower_limit` FLOAT DEFAULT 12,
  `scalp_hard_stop` FLOAT DEFAULT 10,
  `hot_side_warn` FLOAT DEFAULT 60,
  `hot_side_stop` FLOAT DEFAULT 65,
  `current_max` FLOAT DEFAULT 2.0,
  `dew_point_margin` FLOAT DEFAULT 2.0,
  `delta_target` FLOAT DEFAULT 1.5,
  `max_duty` FLOAT DEFAULT 100,
  `status` SMALLINT DEFAULT 1,
  `created_at` DATETIME NULL,
  `updated_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  KEY `ix_yl_safety_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='安全包络';

CREATE TABLE IF NOT EXISTS `YL_SESSION` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `session_no` VARCHAR(40) NOT NULL,
  `user_id` INT NULL,
  `patient_id` INT NULL,
  `device_id` INT NULL,
  `protocol_id` INT NULL,
  `protocol_name` VARCHAR(100) DEFAULT '',
  `protocol_snapshot` JSON NULL,
  `status` SMALLINT DEFAULT 0,
  `start_time` DATETIME NULL,
  `end_time` DATETIME NULL,
  `duration_min` INT DEFAULT 0,
  `env_temp` FLOAT NULL,
  `env_humidity` FLOAT NULL,
  `dew_point` FLOAT NULL,
  `min_temp` FLOAT NULL,
  `max_temp` FLOAT NULL,
  `avg_temp` FLOAT NULL,
  `max_delta_t` FLOAT NULL,
  `alarm_count` INT DEFAULT 0,
  `end_reason` VARCHAR(100) DEFAULT '',
  `note` VARCHAR(255) DEFAULT '',
  `created_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_yl_session_no` (`session_no`),
  KEY `ix_yl_session_user` (`user_id`),
  KEY `ix_yl_session_start` (`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='治疗会话档案';

CREATE TABLE IF NOT EXISTS `YL_SESSION_POINT` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `session_id` INT NOT NULL,
  `ts` DATETIME NOT NULL,
  `zone_f` FLOAT NULL,
  `zone_tl` FLOAT NULL,
  `zone_tr` FLOAT NULL,
  `zone_p` FLOAT NULL,
  `zone_ol` FLOAT NULL,
  `zone_or` FLOAT NULL,
  `avg_power` FLOAT DEFAULT 0,
  `delta_t` FLOAT DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `ix_yl_sp_session` (`session_id`),
  KEY `ix_yl_session_point_session_ts` (`session_id`, `ts`),
  CONSTRAINT `fk_yl_sp_session` FOREIGN KEY (`session_id`) REFERENCES `YL_SESSION` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='治疗采样点';

CREATE TABLE IF NOT EXISTS `YL_SESSION_ZONE` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `session_id` INT NOT NULL,
  `zone_id` VARCHAR(8) NOT NULL,
  `zone_name` VARCHAR(20) DEFAULT '',
  `setpoint` FLOAT DEFAULT 0,
  `min_temp` FLOAT NULL,
  `max_temp` FLOAT NULL,
  `avg_temp` FLOAT NULL,
  `avg_power` FLOAT DEFAULT 0,
  `compensate_count` INT DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `ix_yl_sz_session` (`session_id`),
  CONSTRAINT `fk_yl_sz_session` FOREIGN KEY (`session_id`) REFERENCES `YL_SESSION` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会话分区汇总';

CREATE TABLE IF NOT EXISTS `YL_ALARM` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `session_id` INT NULL,
  `user_id` INT NULL,
  `device_id` INT NULL,
  `zone_id` VARCHAR(8) NULL,
  `level` VARCHAR(16) DEFAULT 'info',
  `code` VARCHAR(40) NOT NULL,
  `message` VARCHAR(255) DEFAULT '',
  `occurred_at` DATETIME NULL,
  `ack` SMALLINT DEFAULT 0,
  `ack_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  KEY `ix_yl_alarm_session` (`session_id`),
  KEY `ix_yl_alarm_user` (`user_id`),
  KEY `ix_yl_alarm_time` (`occurred_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报警记录';

CREATE TABLE IF NOT EXISTS `YL_ENV_SAMPLE` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `session_id` INT NULL,
  `user_id` INT NULL,
  `temp` FLOAT NOT NULL,
  `humidity` FLOAT NOT NULL,
  `dew_point` FLOAT NOT NULL,
  `margin` FLOAT DEFAULT 2.0,
  `safe` TINYINT DEFAULT 1,
  `ts` DATETIME NULL,
  PRIMARY KEY (`id`),
  KEY `ix_yl_env_session` (`session_id`),
  KEY `ix_yl_env_ts` (`ts`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='环境采样';

CREATE TABLE IF NOT EXISTS `YL_CONTROL_COMMAND` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `session_id` INT NULL,
  `user_id` INT NULL,
  `device_id` INT NULL,
  `cmd` VARCHAR(40) NOT NULL,
  `payload` JSON NULL,
  `result` SMALLINT DEFAULT 0,
  `created_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  KEY `ix_yl_cmd_session` (`session_id`),
  KEY `ix_yl_cmd_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='控制指令审计';
