/*
 Navicat Premium Data Transfer

 Source Server         : 120.48.35.53
 Source Server Type    : MySQL
 Source Server Version : 50744
 Source Host           : 120.48.35.53:3306
 Source Schema         : study_uniapp

 Target Server Type    : MySQL
 Target Server Version : 50744
 File Encoding         : 65001

 Date: 30/06/2026 17:54:20
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ent_album
-- ----------------------------
DROP TABLE IF EXISTS `ent_album`;
CREATE TABLE `ent_album`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '专辑ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '专辑名称',
  `artist_id` int(11) NULL DEFAULT NULL COMMENT '歌手ID',
  `cover_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '封面URL',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '专辑简介',
  `release_date` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '发行日期',
  `song_count` int(11) NULL DEFAULT NULL COMMENT '歌曲数',
  `play_count` bigint(20) NULL DEFAULT NULL COMMENT '播放量',
  `status` smallint(6) NULL DEFAULT NULL COMMENT '状态',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_album_artist_id`(`artist_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_album
-- ----------------------------

-- ----------------------------
-- Table structure for ent_artist
-- ----------------------------
DROP TABLE IF EXISTS `ent_artist`;
CREATE TABLE `ent_artist`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '歌手ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '歌手名称',
  `avatar_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像URL',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '歌手简介',
  `region` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '地区: 内地/港台/海外/欧美/日韩',
  `song_count` int(11) NULL DEFAULT NULL COMMENT '歌曲数',
  `fan_count` int(11) NULL DEFAULT NULL COMMENT '粉丝数',
  `status` smallint(6) NULL DEFAULT NULL COMMENT '状态',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_artist_name`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 65 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_artist
-- ----------------------------
INSERT INTO `ent_artist` VALUES (49, '周杰伦', 'https://picsum.photos/200/200?random=a0', '', '华语', 0, 2000000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (50, '林俊杰', 'https://picsum.photos/200/200?random=a1', '', '华语', 0, 1500000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (51, '邓紫棋', 'https://picsum.photos/200/200?random=a2', '', '华语', 0, 1200000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (52, '薛之谦', 'https://picsum.photos/200/200?random=a3', '', '华语', 0, 1000000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (53, '陈奕迅', 'https://picsum.photos/200/200?random=a4', '', '港台', 0, 1800000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (54, 'Taylor Swift', 'https://picsum.photos/200/200?random=a5', '', '欧美', 0, 3000000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (55, '五月天', 'https://picsum.photos/200/200?random=a6', '', '华语', 0, 1600000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (56, '周杰伦', 'https://picsum.photos/200/200?random=a0', '', '华语', 0, 2000000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (57, '毛不易', 'https://picsum.photos/200/200?random=a7', '', '华语', 0, 800000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (58, '林俊杰', 'https://picsum.photos/200/200?random=a1', '', '华语', 0, 1500000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (59, '邓紫棋', 'https://picsum.photos/200/200?random=a2', '', '华语', 0, 1200000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (60, '薛之谦', 'https://picsum.photos/200/200?random=a3', '', '华语', 0, 1000000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (61, '陈奕迅', 'https://picsum.photos/200/200?random=a4', '', '港台', 0, 1800000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (62, 'Taylor Swift', 'https://picsum.photos/200/200?random=a5', '', '欧美', 0, 3000000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (63, '五月天', 'https://picsum.photos/200/200?random=a6', '', '华语', 0, 1600000, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_artist` VALUES (64, '毛不易', 'https://picsum.photos/200/200?random=a7', '', '华语', 0, 800000, 1, '2026-06-15 17:46:36');

-- ----------------------------
-- Table structure for ent_banner
-- ----------------------------
DROP TABLE IF EXISTS `ent_banner`;
CREATE TABLE `ent_banner`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标题',
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '图片URL',
  `link_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '链接类型: url/game/music/video/novel',
  `link_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '链接值',
  `position` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '位置: game/music/video/novel/home',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `status` smallint(6) NULL DEFAULT NULL COMMENT '状态(0禁用/1启用)',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_banner_position`(`position`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 73 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_banner
-- ----------------------------
INSERT INTO `ent_banner` VALUES (55, '热门H5小游戏合集', 'https://picsum.photos/800/400?random=1', 'url', '', 'game', 1, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (56, '经典俄罗斯方块', 'https://picsum.photos/800/400?random=2', 'url', '', 'game', 2, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (57, '2048挑战赛', 'https://picsum.photos/800/400?random=3', 'url', '', 'game', 3, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (58, '华语热歌榜', 'https://picsum.photos/800/400?random=4', 'url', '', 'music', 1, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (59, '新歌首发推荐', 'https://picsum.photos/800/400?random=5', 'url', '', 'music', 2, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (60, '经典影视回顾', 'https://picsum.photos/800/400?random=6', 'url', '', 'video', 1, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (61, '热门H5小游戏合集', 'https://picsum.photos/800/400?random=1', 'url', '', 'game', 1, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (62, '热门动漫推荐', 'https://picsum.photos/800/400?random=7', 'url', '', 'video', 2, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (63, '经典俄罗斯方块', 'https://picsum.photos/800/400?random=2', 'url', '', 'game', 2, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (64, '玄幻小说强推', 'https://picsum.photos/800/400?random=8', 'url', '', 'novel', 1, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (65, '2048挑战赛', 'https://picsum.photos/800/400?random=3', 'url', '', 'game', 3, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (66, '限时免费小说', 'https://picsum.photos/800/400?random=9', 'url', '', 'novel', 2, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (67, '华语热歌榜', 'https://picsum.photos/800/400?random=4', 'url', '', 'music', 1, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (68, '新歌首发推荐', 'https://picsum.photos/800/400?random=5', 'url', '', 'music', 2, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (69, '经典影视回顾', 'https://picsum.photos/800/400?random=6', 'url', '', 'video', 1, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (70, '热门动漫推荐', 'https://picsum.photos/800/400?random=7', 'url', '', 'video', 2, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_banner` VALUES (71, '玄幻小说强推', 'https://picsum.photos/800/400?random=8', 'url', '', 'novel', 1, 1, '2026-06-15 17:46:35');
INSERT INTO `ent_banner` VALUES (72, '限时免费小说', 'https://picsum.photos/800/400?random=9', 'url', '', 'novel', 2, 1, '2026-06-15 17:46:35');

-- ----------------------------
-- Table structure for ent_category
-- ----------------------------
DROP TABLE IF EXISTS `ent_category`;
CREATE TABLE `ent_category`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `parent_id` int(11) NULL DEFAULT NULL COMMENT '父分类ID,0为顶级',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类名称',
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '类型: game/music/video/novel',
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类图标',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `status` smallint(6) NULL DEFAULT NULL COMMENT '状态(0禁用/1启用)',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_category_type`(`type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 217 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_category
-- ----------------------------
INSERT INTO `ent_category` VALUES (163, 0, '休闲益智', 'game', '', 1, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (164, 0, '动作冒险', 'game', '', 2, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (165, 0, '棋牌桌游', 'game', '', 3, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (166, 0, '角色扮演', 'game', '', 4, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (167, 0, '休闲益智', 'game', '', 1, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (168, 0, '竞技对战', 'game', '', 5, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (169, 0, '单机小游戏', 'game', '', 6, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (170, 0, '动作冒险', 'game', '', 2, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (171, 0, '流行', 'music', '', 1, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (172, 0, '棋牌桌游', 'game', '', 3, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (173, 0, '摇滚', 'music', '', 2, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (174, 0, '角色扮演', 'game', '', 4, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (175, 0, '古风', 'music', '', 3, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (176, 0, '竞技对战', 'game', '', 5, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (177, 0, '民谣', 'music', '', 4, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (178, 0, '单机小游戏', 'game', '', 6, 1, '2026-06-15 17:46:32');
INSERT INTO `ent_category` VALUES (179, 0, '电子', 'music', '', 5, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (180, 0, '流行', 'music', '', 1, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (181, 0, '经典老歌', 'music', '', 6, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (182, 0, '摇滚', 'music', '', 2, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (183, 0, '纯音乐', 'music', '', 7, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (184, 0, '古风', 'music', '', 3, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (185, 0, '电影', 'video', '', 1, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (186, 0, '民谣', 'music', '', 4, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (187, 0, '电视剧', 'video', '', 2, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (188, 0, '电子', 'music', '', 5, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (189, 0, '综艺', 'video', '', 3, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (190, 0, '经典老歌', 'music', '', 6, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (191, 0, '动漫', 'video', '', 4, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (192, 0, '纯音乐', 'music', '', 7, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (193, 0, '纪录片', 'video', '', 5, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (194, 0, '电影', 'video', '', 1, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (195, 0, '短视频', 'video', '', 6, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (196, 0, '电视剧', 'video', '', 2, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (197, 0, '玄幻', 'novel', '', 1, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (198, 0, '综艺', 'video', '', 3, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (199, 0, '仙侠', 'novel', '', 2, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (200, 0, '动漫', 'video', '', 4, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (201, 0, '都市', 'novel', '', 3, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (202, 0, '纪录片', 'video', '', 5, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (203, 0, '言情', 'novel', '', 4, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (204, 0, '短视频', 'video', '', 6, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (205, 0, '悬疑', 'novel', '', 5, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (206, 0, '玄幻', 'novel', '', 1, 1, '2026-06-15 17:46:33');
INSERT INTO `ent_category` VALUES (207, 0, '历史', 'novel', '', 6, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_category` VALUES (208, 0, '仙侠', 'novel', '', 2, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_category` VALUES (209, 0, '科幻', 'novel', '', 7, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_category` VALUES (210, 0, '都市', 'novel', '', 3, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_category` VALUES (211, 0, '短篇', 'novel', '', 8, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_category` VALUES (212, 0, '言情', 'novel', '', 4, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_category` VALUES (213, 0, '悬疑', 'novel', '', 5, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_category` VALUES (214, 0, '历史', 'novel', '', 6, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_category` VALUES (215, 0, '科幻', 'novel', '', 7, 1, '2026-06-15 17:46:34');
INSERT INTO `ent_category` VALUES (216, 0, '短篇', 'novel', '', 8, 1, '2026-06-15 17:46:34');

-- ----------------------------
-- Table structure for ent_favorite
-- ----------------------------
DROP TABLE IF EXISTS `ent_favorite`;
CREATE TABLE `ent_favorite`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `content_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内容类型: game/music/video/novel',
  `content_id` int(11) NOT NULL COMMENT '内容ID',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '收藏时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_user_content_fav`(`user_id`, `content_type`, `content_id`) USING BTREE,
  INDEX `ix_ent_favorite_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_favorite
-- ----------------------------

-- ----------------------------
-- Table structure for ent_game
-- ----------------------------
DROP TABLE IF EXISTS `ent_game`;
CREATE TABLE `ent_game`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '游戏ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '游戏名称',
  `cover_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '封面图URL',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '游戏简介',
  `category_id` int(11) NULL DEFAULT NULL COMMENT '分类ID',
  `game_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '游戏类型: h5/iframe/embed',
  `game_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '游戏地址/嵌入URL',
  `difficulty` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '难度: easy/medium/hard',
  `is_free` smallint(6) NULL DEFAULT NULL COMMENT '是否免费 1是0否',
  `tags` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标签,逗号分隔',
  `play_count` int(11) NULL DEFAULT NULL COMMENT '游玩次数',
  `score` float NULL DEFAULT NULL COMMENT '评分',
  `score_count` int(11) NULL DEFAULT NULL COMMENT '评分人数',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `status` smallint(6) NULL DEFAULT NULL COMMENT '状态(0下架/1上架)',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_game_title`(`title`) USING BTREE,
  INDEX `ix_ent_game_category_id`(`category_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 51 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_game
-- ----------------------------
INSERT INTO `ent_game` VALUES (31, '2048数字合并', 'https://picsum.photos/300/200?random=g1', '经典的2048数字合并游戏，滑动方块合并相同数字，挑战最高分！支持键盘方向键和触屏滑动。', 1, 'h5', '/static/games/2048.html', 'easy', 1, '益智,数字,休闲', 12580, 4.5, 0, 1, 1, '2026-06-15 17:46:34', '2026-06-16 09:25:47');
INSERT INTO `ent_game` VALUES (32, '五子棋', 'https://picsum.photos/300/200?random=g2', '经典五子棋游戏，支持人机对战和双人对战。AI三档难度可调节，支持悔棋功能。', 3, 'h5', '/static/games/gomoku.html', 'medium', 1, '棋牌,策略,对战', 8900, 4.6, 0, 2, 1, '2026-06-15 17:46:34', '2026-06-16 09:25:47');
INSERT INTO `ent_game` VALUES (33, '消消乐', 'https://picsum.photos/300/200?random=g3', '经典三消游戏！交换相邻水果元素，消除3个以上相同元素得分。限时30步挑战最高分！', 1, 'h5', '/static/games/match3.html', 'easy', 1, '消除,休闲,益智', 15600, 4.8, 0, 3, 1, '2026-06-15 17:46:34', '2026-06-16 09:25:47');
INSERT INTO `ent_game` VALUES (34, '打砖块', 'https://picsum.photos/300/200?random=g4', '复古街机风动作小游戏！控制挡板反弹小球消除砖块，多关卡进阶，挑战你的反应力。', 2, 'h5', '/static/games/breakout.html', 'medium', 1, '动作,街机,经典', 6200, 4.4, 0, 4, 1, '2026-06-15 17:46:35', '2026-06-16 09:25:47');
INSERT INTO `ent_game` VALUES (35, '扫雷经典版', 'https://picsum.photos/300/200?random=g5', 'Windows经典扫雷游戏！根据数字提示找出所有地雷位置。支持初级/中级/高级三种难度。', 1, 'h5', '/static/games/minesweeper.html', 'medium', 1, '经典,益智,策略', 7650, 4.7, 0, 5, 1, '2026-06-15 17:46:35', '2026-06-16 09:25:47');
INSERT INTO `ent_game` VALUES (36, '2048数字合并', 'https://picsum.photos/300/200?random=g1', '经典的2048数字合并游戏，滑动方块合并相同数字，挑战最高分！支持键盘方向键和触屏滑动。', 1, 'h5', '/static/games/2048.html', 'easy', 1, '益智,数字,休闲', 12580, 4.5, 0, 1, 1, '2026-06-15 17:46:35', '2026-06-16 09:25:47');
INSERT INTO `ent_game` VALUES (37, '五子棋', 'https://picsum.photos/300/200?random=g2', '经典五子棋游戏，支持人机对战和双人对战。AI三档难度可调节，支持悔棋功能。', 3, 'h5', '/static/games/gomoku.html', 'medium', 1, '棋牌,策略,对战', 8900, 4.6, 0, 2, 1, '2026-06-15 17:46:35', '2026-06-16 09:25:47');
INSERT INTO `ent_game` VALUES (38, '消消乐', 'https://picsum.photos/300/200?random=g3', '经典三消游戏！交换相邻水果元素，消除3个以上相同元素得分。限时30步挑战最高分！', 1, 'h5', '/static/games/match3.html', 'easy', 1, '消除,休闲,益智', 15600, 4.8, 0, 3, 1, '2026-06-15 17:46:35', '2026-06-16 09:25:47');
INSERT INTO `ent_game` VALUES (39, '打砖块', 'https://picsum.photos/300/200?random=g4', '复古街机风动作小游戏！控制挡板反弹小球消除砖块，多关卡进阶，挑战你的反应力。', 2, 'h5', '/static/games/breakout.html', 'medium', 1, '动作,街机,经典', 6200, 4.4, 0, 4, 1, '2026-06-15 17:46:35', '2026-06-16 09:25:47');
INSERT INTO `ent_game` VALUES (40, '扫雷经典版', 'https://picsum.photos/300/200?random=g5', 'Windows经典扫雷游戏！根据数字提示找出所有地雷位置。支持初级/中级/高级三种难度。', 1, 'h5', '/static/games/minesweeper.html', 'medium', 1, '经典,益智,策略', 7650, 4.7, 0, 5, 1, '2026-06-15 17:46:35', '2026-06-16 09:25:47');
INSERT INTO `ent_game` VALUES (41, '接金币', 'https://picsum.photos/300/200?random=6', '鼠标控制托盘接金币躲炸弹，限时60秒', 1, 'h5', '/static/games/coin-catch.html', 'easy', 1, '休闲,反应', 9200, 4.5, 0, 6, 1, '2026-06-16 09:58:22', '2026-06-16 09:58:22');
INSERT INTO `ent_game` VALUES (42, '贪吃蛇', 'https://picsum.photos/300/200?random=7', '经典贪吃蛇，三档难度可选', 6, 'h5', '/static/games/snake.html', 'easy', 1, '经典,怀旧', 11500, 4.6, 0, 7, 1, '2026-06-16 09:58:22', '2026-06-16 09:58:22');
INSERT INTO `ent_game` VALUES (43, '打地鼠', 'https://picsum.photos/300/200?random=8', '点击击打冒出地鼠，限时60秒', 1, 'h5', '/static/games/whack-mole.html', 'easy', 1, '解压,休闲', 8700, 4.4, 0, 8, 1, '2026-06-16 09:58:22', '2026-06-16 09:58:22');
INSERT INTO `ent_game` VALUES (44, '飞鸟穿越', 'https://picsum.photos/300/200?random=9', 'Flappy Bird同款，躲避管道障碍', 2, 'h5', '/static/games/flappy-bird.html', 'easy', 1, '躲避,闯关', 13400, 4.7, 0, 9, 1, '2026-06-16 09:58:22', '2026-06-16 09:58:22');
INSERT INTO `ent_game` VALUES (45, '数字拼图', 'https://picsum.photos/300/200?random=10', '3×3数字滑块拼图，锻炼逻辑', 1, 'h5', '/static/games/sliding-puzzle.html', 'easy', 1, '益智,拼图', 6800, 4.5, 0, 10, 1, '2026-06-16 09:58:22', '2026-06-16 09:58:22');
INSERT INTO `ent_game` VALUES (46, '射击气球', 'https://picsum.photos/300/200?random=11', '射击上升气球，限时90秒', 2, 'h5', '/static/games/balloon-shoot.html', 'easy', 1, '射击,休闲', 7900, 4.3, 0, 11, 1, '2026-06-16 09:58:22', '2026-06-16 09:58:22');
INSERT INTO `ent_game` VALUES (47, '国旗配对', 'https://picsum.photos/300/200?random=12', '记忆翻牌配对游戏，双难度', 1, 'h5', '/static/games/flag-match.html', 'easy', 1, '益智,记忆', 6500, 4.4, 0, 12, 1, '2026-06-16 10:21:00', '2026-06-16 10:21:00');
INSERT INTO `ent_game` VALUES (48, '跳棋', 'https://picsum.photos/300/200?random=13', '经典六角跳棋，双人对战', 3, 'h5', '/static/games/checkers.html', 'easy', 1, '棋牌,策略', 5200, 4.3, 0, 13, 1, '2026-06-16 10:21:00', '2026-06-16 10:21:00');
INSERT INTO `ent_game` VALUES (49, '中国象棋', 'https://picsum.photos/300/200?random=14', '国标象棋，完整走棋规则', 3, 'h5', '/static/games/chinese-chess.html', 'easy', 1, '棋牌,象棋', 9800, 4.7, 0, 14, 1, '2026-06-16 10:21:00', '2026-06-16 10:21:00');
INSERT INTO `ent_game` VALUES (50, '炸金花', 'https://picsum.photos/300/200?random=15', '虚拟积分版卡牌对战', 3, 'h5', '/static/games/zjh-poker.html', 'easy', 1, '棋牌,卡牌', 11200, 4.5, 0, 15, 1, '2026-06-16 10:21:00', '2026-06-16 10:21:00');

-- ----------------------------
-- Table structure for ent_game_play_record
-- ----------------------------
DROP TABLE IF EXISTS `ent_game_play_record`;
CREATE TABLE `ent_game_play_record`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `game_id` int(11) NOT NULL COMMENT '游戏ID',
  `session_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会话ID',
  `start_at` datetime(0) NULL DEFAULT NULL COMMENT '开始时间',
  `end_at` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  `duration_sec` int(11) NULL DEFAULT NULL COMMENT '游玩时长(秒)',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_game_play_record_game_id`(`game_id`) USING BTREE,
  INDEX `ix_ent_game_play_record_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_game_play_record
-- ----------------------------

-- ----------------------------
-- Table structure for ent_game_screenshot
-- ----------------------------
DROP TABLE IF EXISTS `ent_game_screenshot`;
CREATE TABLE `ent_game_screenshot`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `game_id` int(11) NOT NULL COMMENT '游戏ID',
  `url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '截图URL',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_game_screenshot_game_id`(`game_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_game_screenshot
-- ----------------------------

-- ----------------------------
-- Table structure for ent_history
-- ----------------------------
DROP TABLE IF EXISTS `ent_history`;
CREATE TABLE `ent_history`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `content_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内容类型: game/music/video/novel',
  `content_id` int(11) NOT NULL COMMENT '内容ID',
  `progress` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '进度信息(如小说章节/视频时间点)',
  `extra_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '扩展JSON数据',
  `last_at` datetime(0) NULL DEFAULT NULL COMMENT '最后访问时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_user_content_hist`(`user_id`, `content_type`, `content_id`) USING BTREE,
  INDEX `ix_ent_history_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_history
-- ----------------------------
INSERT INTO `ent_history` VALUES (1, 1, 'music', 178, '', '', '2026-06-16 15:31:36');
INSERT INTO `ent_history` VALUES (2, 1, 'music', 186, '', '', '2026-06-30 17:36:06');

-- ----------------------------
-- Table structure for ent_novel
-- ----------------------------
DROP TABLE IF EXISTS `ent_novel`;
CREATE TABLE `ent_novel`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '小说ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '书名',
  `author` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '作者',
  `cover_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '封面URL',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '简介',
  `category_id` int(11) NULL DEFAULT NULL COMMENT '分类ID',
  `genre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '类型: 玄幻/仙侠/都市/言情/悬疑/历史/科幻/短篇',
  `gender` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '频道: male/female',
  `word_count` bigint(20) NULL DEFAULT NULL COMMENT '总字数',
  `chapter_count` int(11) NULL DEFAULT NULL COMMENT '总章节数',
  `status_text` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '状态: 连载中/完本',
  `tags` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标签,逗号分隔',
  `is_free` smallint(6) NULL DEFAULT NULL COMMENT '是否免费',
  `is_vip` smallint(6) NULL DEFAULT NULL COMMENT '是否VIP',
  `read_count` bigint(20) NULL DEFAULT NULL COMMENT '阅读量',
  `score` float NULL DEFAULT NULL COMMENT '评分',
  `score_count` int(11) NULL DEFAULT NULL COMMENT '评分人数',
  `last_chapter` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '最新章节名',
  `last_update` datetime(0) NULL DEFAULT NULL COMMENT '最后更新时间',
  `is_recommend` smallint(6) NULL DEFAULT NULL COMMENT '是否推荐',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `status` smallint(6) NULL DEFAULT NULL COMMENT '状态(0下架/1上架)',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `is_new` smallint(6) NULL DEFAULT 0 COMMENT '是否上新',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_novel_category_id`(`category_id`) USING BTREE,
  INDEX `ix_ent_novel_title`(`title`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_novel
-- ----------------------------
INSERT INTO `ent_novel` VALUES (1, '斗破苍穹', '天蚕土豆', 'https://picsum.photos/200/280?random=n1', '三十年河东，三十年河西，莫欺少年穷！年仅15岁的萧炎，创造了家族空前绝后的修炼纪录。然而在这位少年的眼中，这仅仅只是一个开始。', 0, '玄幻', 'male', 5300000, 1648, '完本', '玄幻,热血,升级', 1, 0, 28000000, 8.8, 0, '第一千六百四十八章 结束，也是开始', NULL, 1, 0, 1, '2026-06-15 17:46:40', '2026-06-15 17:46:40', 0);
INSERT INTO `ent_novel` VALUES (2, '完美世界', '辰东', 'https://picsum.photos/200/280?random=n2', '一粒尘可填海，一根草斩尽日月星辰。天地间，一位少年从石村走出，一切从这里开始。', 0, '玄幻', 'male', 5800000, 2016, '完本', '玄幻,热血,大帝', 1, 0, 22000000, 8.7, 0, '', NULL, 1, 0, 1, '2026-06-15 17:46:40', '2026-06-15 17:46:40', 0);
INSERT INTO `ent_novel` VALUES (3, '全职高手', '蝴蝶蓝', 'https://picsum.photos/200/280?random=n3', '网游荣耀中被誉为教科书级别的顶尖高手叶修，因为种种原因遭到俱乐部的驱逐。离开职业圈的他，在一家网吧成了一个小小的网管。', 0, '都市', 'male', 3200000, 1728, '完本', '游戏,电竞,热血', 1, 0, 18000000, 9, 0, '', NULL, 1, 0, 1, '2026-06-15 17:46:40', '2026-06-15 17:46:40', 0);
INSERT INTO `ent_novel` VALUES (4, '盗墓笔记', '南派三叔', 'https://picsum.photos/200/280?random=n4', '五十年前，一群长沙土夫子挖到了一部战国帛书，记载了一个奇特战国古墓的位置。五十年后，其中一个土夫子的孙子在他的笔记中发现了这个秘密。', 0, '悬疑', 'male', 4500000, 980, '完本', '悬疑,探险,古墓', 1, 0, 25000000, 8.9, 0, '', NULL, 0, 0, 1, '2026-06-15 17:46:40', '2026-06-15 17:46:40', 0);
INSERT INTO `ent_novel` VALUES (5, '诛仙', '萧鼎', 'https://picsum.photos/200/280?random=n5', '天地不仁，以万物为刍狗。一个普通的少年，机缘巧合之下卷入了正邪两道的纷争之中，踏上了修真之路。', 0, '仙侠', 'male', 2800000, 465, '完本', '仙侠,经典,情感', 1, 0, 20000000, 8.6, 0, '', NULL, 0, 0, 1, '2026-06-15 17:46:40', '2026-06-15 17:46:40', 0);
INSERT INTO `ent_novel` VALUES (6, '微微一笑很倾城', '顾漫', 'https://picsum.photos/200/280?random=n6', '计算机系学霸贝微微在游戏中结识了校草大神肖奈，两人从游戏中的搭档发展到现实中的恋人。', 0, '言情', 'female', 580000, 186, '完本', '言情,游戏,甜宠', 1, 0, 15000000, 8.3, 0, '', NULL, 0, 0, 1, '2026-06-15 17:46:40', '2026-06-15 17:46:40', 0);
INSERT INTO `ent_novel` VALUES (7, '诡秘之主', '爱潜水的乌贼', 'https://picsum.photos/200/280?random=n7', '蒸汽与机械的浪潮中，谁能触及非凡？历史和黑暗的迷雾里，又是谁在窥视？我从诡秘中醒来，步入这个不一样的世界。', 0, '玄幻', 'male', 4200000, 1432, '完本', '西幻,克苏鲁,神秘', 1, 0, 16000000, 9.2, 0, '', NULL, 1, 0, 1, '2026-06-15 17:46:40', '2026-06-15 17:46:40', 0);
INSERT INTO `ent_novel` VALUES (8, '雪中悍刀行', '烽火戏诸侯', 'https://picsum.photos/200/280?random=n8', '北凉世子徐凤年，不愿做那笼中雀、井底蛙，他手持一柄木刀，行走于江湖庙堂之间，终成一代大侠。', 0, '仙侠', 'male', 4500000, 1120, '完本', '武侠,权谋,热血', 1, 0, 14000000, 8.5, 0, '', NULL, 0, 0, 1, '2026-06-15 17:46:40', '2026-06-15 17:46:40', 0);
INSERT INTO `ent_novel` VALUES (9, '大奉打更人', '卖报小郎君', 'https://picsum.photos/200/280?random=n9', '这个世界有儒释道三教，有妖族和巫族。许七安穿越而来，从一个小人物逐步成长为举世瞩目的强者。', 0, '玄幻', 'male', 5100000, 1580, '完本', '穿越,探案,爽文', 1, 0, 19000000, 8.8, 0, '', NULL, 1, 0, 1, '2026-06-15 17:46:40', '2026-06-15 17:46:40', 0);
INSERT INTO `ent_novel` VALUES (10, '长月烬明', '藤萍', 'https://picsum.photos/200/280?random=n10', '为了拯救被魔神澹台烬毁灭的世界，黎苏苏回到五百年前，化身为叶夕雾，试图阻止澹台烬的黑化之路。', 0, '言情', 'female', 720000, 210, '完本', '仙侠,言情,虐恋', 1, 0, 12000000, 8.1, 0, '', NULL, 0, 0, 1, '2026-06-15 17:46:40', '2026-06-15 17:46:40', 1);
INSERT INTO `ent_novel` VALUES (11, '赘婿', '愤怒的香蕉', 'https://picsum.photos/200/280?random=n11', '现代金融界巨头宁毅穿越到古代，成为苏家的赘婿。凭借现代知识和商业头脑，在古代社会掀起了一场商业革命。', 0, '历史', 'male', 4800000, 1150, '连载中', '穿越,商战,历史', 1, 0, 11000000, 8.4, 0, '第一千一百五十章 风云再起', NULL, 0, 0, 1, '2026-06-15 17:46:40', '2026-06-15 17:46:40', 0);
INSERT INTO `ent_novel` VALUES (12, '知否知否应是绿肥红瘦', '关心则乱', 'https://picsum.photos/200/280?random=n12', '穿越到古代的盛明兰，从一个庶女成长为当家主母的故事。宅斗权谋，家长里短，一个古代女子的奋斗史。', 0, '言情', 'female', 2100000, 680, '完本', '宅斗,言情,古代', 1, 0, 13000000, 8.6, 0, '', NULL, 0, 0, 1, '2026-06-15 17:46:40', '2026-06-15 17:46:40', 0);
INSERT INTO `ent_novel` VALUES (13, '斗破苍穹', '天蚕土豆', 'https://picsum.photos/200/280?random=n1', '三十年河东，三十年河西，莫欺少年穷！年仅15岁的萧炎，创造了家族空前绝后的修炼纪录。然而在这位少年的眼中，这仅仅只是一个开始。', 0, '玄幻', 'male', 5300000, 1648, '完本', '玄幻,热血,升级', 1, 0, 28000000, 8.8, 0, '第一千六百四十八章 结束，也是开始', NULL, 1, 0, 1, '2026-06-15 17:46:40', '2026-06-15 17:46:40', 0);
INSERT INTO `ent_novel` VALUES (14, '完美世界', '辰东', 'https://picsum.photos/200/280?random=n2', '一粒尘可填海，一根草斩尽日月星辰。天地间，一位少年从石村走出，一切从这里开始。', 0, '玄幻', 'male', 5800000, 2016, '完本', '玄幻,热血,大帝', 1, 0, 22000000, 8.7, 0, '', NULL, 1, 0, 1, '2026-06-15 17:46:41', '2026-06-15 17:46:41', 0);
INSERT INTO `ent_novel` VALUES (15, '全职高手', '蝴蝶蓝', 'https://picsum.photos/200/280?random=n3', '网游荣耀中被誉为教科书级别的顶尖高手叶修，因为种种原因遭到俱乐部的驱逐。离开职业圈的他，在一家网吧成了一个小小的网管。', 0, '都市', 'male', 3200000, 1728, '完本', '游戏,电竞,热血', 1, 0, 18000000, 9, 0, '', NULL, 1, 0, 1, '2026-06-15 17:46:41', '2026-06-15 17:46:41', 0);
INSERT INTO `ent_novel` VALUES (16, '盗墓笔记', '南派三叔', 'https://picsum.photos/200/280?random=n4', '五十年前，一群长沙土夫子挖到了一部战国帛书，记载了一个奇特战国古墓的位置。五十年后，其中一个土夫子的孙子在他的笔记中发现了这个秘密。', 0, '悬疑', 'male', 4500000, 980, '完本', '悬疑,探险,古墓', 1, 0, 25000000, 8.9, 0, '', NULL, 0, 0, 1, '2026-06-15 17:46:41', '2026-06-15 17:46:41', 0);
INSERT INTO `ent_novel` VALUES (17, '诛仙', '萧鼎', 'https://picsum.photos/200/280?random=n5', '天地不仁，以万物为刍狗。一个普通的少年，机缘巧合之下卷入了正邪两道的纷争之中，踏上了修真之路。', 0, '仙侠', 'male', 2800000, 465, '完本', '仙侠,经典,情感', 1, 0, 20000000, 8.6, 0, '', NULL, 0, 0, 1, '2026-06-15 17:46:41', '2026-06-15 17:46:41', 0);
INSERT INTO `ent_novel` VALUES (18, '微微一笑很倾城', '顾漫', 'https://picsum.photos/200/280?random=n6', '计算机系学霸贝微微在游戏中结识了校草大神肖奈，两人从游戏中的搭档发展到现实中的恋人。', 0, '言情', 'female', 580000, 186, '完本', '言情,游戏,甜宠', 1, 0, 15000000, 8.3, 0, '', NULL, 0, 0, 1, '2026-06-15 17:46:41', '2026-06-15 17:46:41', 0);
INSERT INTO `ent_novel` VALUES (19, '诡秘之主', '爱潜水的乌贼', 'https://picsum.photos/200/280?random=n7', '蒸汽与机械的浪潮中，谁能触及非凡？历史和黑暗的迷雾里，又是谁在窥视？我从诡秘中醒来，步入这个不一样的世界。', 0, '玄幻', 'male', 4200000, 1432, '完本', '西幻,克苏鲁,神秘', 1, 0, 16000000, 9.2, 0, '', NULL, 1, 0, 1, '2026-06-15 17:46:41', '2026-06-15 17:46:41', 0);
INSERT INTO `ent_novel` VALUES (20, '雪中悍刀行', '烽火戏诸侯', 'https://picsum.photos/200/280?random=n8', '北凉世子徐凤年，不愿做那笼中雀、井底蛙，他手持一柄木刀，行走于江湖庙堂之间，终成一代大侠。', 0, '仙侠', 'male', 4500000, 1120, '完本', '武侠,权谋,热血', 1, 0, 14000000, 8.5, 0, '', NULL, 0, 0, 1, '2026-06-15 17:46:41', '2026-06-15 17:46:41', 0);
INSERT INTO `ent_novel` VALUES (21, '大奉打更人', '卖报小郎君', 'https://picsum.photos/200/280?random=n9', '这个世界有儒释道三教，有妖族和巫族。许七安穿越而来，从一个小人物逐步成长为举世瞩目的强者。', 0, '玄幻', 'male', 5100000, 1580, '完本', '穿越,探案,爽文', 1, 0, 19000000, 8.8, 0, '', NULL, 1, 0, 1, '2026-06-15 17:46:41', '2026-06-15 17:46:41', 0);
INSERT INTO `ent_novel` VALUES (22, '长月烬明', '藤萍', 'https://picsum.photos/200/280?random=n10', '为了拯救被魔神澹台烬毁灭的世界，黎苏苏回到五百年前，化身为叶夕雾，试图阻止澹台烬的黑化之路。', 0, '言情', 'female', 720000, 210, '完本', '仙侠,言情,虐恋', 1, 0, 12000000, 8.1, 0, '', NULL, 0, 0, 1, '2026-06-15 17:46:41', '2026-06-15 17:46:41', 1);
INSERT INTO `ent_novel` VALUES (23, '赘婿', '愤怒的香蕉', 'https://picsum.photos/200/280?random=n11', '现代金融界巨头宁毅穿越到古代，成为苏家的赘婿。凭借现代知识和商业头脑，在古代社会掀起了一场商业革命。', 0, '历史', 'male', 4800000, 1150, '连载中', '穿越,商战,历史', 1, 0, 11000000, 8.4, 0, '第一千一百五十章 风云再起', NULL, 0, 0, 1, '2026-06-15 17:46:41', '2026-06-15 17:46:41', 0);
INSERT INTO `ent_novel` VALUES (24, '知否知否应是绿肥红瘦', '关心则乱', 'https://picsum.photos/200/280?random=n12', '穿越到古代的盛明兰，从一个庶女成长为当家主母的故事。宅斗权谋，家长里短，一个古代女子的奋斗史。', 0, '言情', 'female', 2100000, 680, '完本', '宅斗,言情,古代', 1, 0, 13000000, 8.6, 0, '', NULL, 0, 0, 1, '2026-06-15 17:46:41', '2026-06-15 17:46:41', 0);

-- ----------------------------
-- Table structure for ent_novel_chapter
-- ----------------------------
DROP TABLE IF EXISTS `ent_novel_chapter`;
CREATE TABLE `ent_novel_chapter`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '章节ID',
  `novel_id` int(11) NOT NULL COMMENT '小说ID',
  `volume_id` int(11) NULL DEFAULT NULL COMMENT '卷ID',
  `chapter_num` int(11) NULL DEFAULT NULL COMMENT '章节序号',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '章节标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '章节内容',
  `word_count` int(11) NULL DEFAULT NULL COMMENT '字数',
  `is_free` smallint(6) NULL DEFAULT NULL COMMENT '是否免费',
  `is_vip` smallint(6) NULL DEFAULT NULL COMMENT '是否VIP章节',
  `status` smallint(6) NULL DEFAULT NULL COMMENT '状态',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_novel_chapter_novel_id`(`novel_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_novel_chapter
-- ----------------------------
INSERT INTO `ent_novel_chapter` VALUES (1, 1, 1, 1, '第1章 开始的旅程', '这是《斗破苍穹》第1章的示例内容。\n\n  天蚕土豆创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 176, 1, 0, 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_chapter` VALUES (2, 1, 1, 2, '第2章 开始的旅程', '这是《斗破苍穹》第2章的示例内容。\n\n  天蚕土豆创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 176, 1, 0, 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_chapter` VALUES (3, 1, 1, 3, '第3章 开始的旅程', '这是《斗破苍穹》第3章的示例内容。\n\n  天蚕土豆创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 176, 1, 0, 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_chapter` VALUES (4, 1, 1, 4, '第4章 开始的旅程', '这是《斗破苍穹》第4章的示例内容。\n\n  天蚕土豆创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 176, 1, 0, 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_chapter` VALUES (5, 1, 1, 5, '第5章 开始的旅程', '这是《斗破苍穹》第5章的示例内容。\n\n  天蚕土豆创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 176, 1, 0, 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_chapter` VALUES (6, 2, 2, 1, '第1章 开始的旅程', '这是《完美世界》第1章的示例内容。\n\n  辰东创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 174, 1, 0, 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_chapter` VALUES (7, 2, 2, 2, '第2章 开始的旅程', '这是《完美世界》第2章的示例内容。\n\n  辰东创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 174, 1, 0, 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_chapter` VALUES (8, 2, 2, 3, '第3章 开始的旅程', '这是《完美世界》第3章的示例内容。\n\n  辰东创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 174, 1, 0, 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_chapter` VALUES (9, 2, 2, 4, '第4章 开始的旅程', '这是《完美世界》第4章的示例内容。\n\n  辰东创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 174, 1, 0, 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_chapter` VALUES (10, 2, 2, 5, '第5章 开始的旅程', '这是《完美世界》第5章的示例内容。\n\n  辰东创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 174, 1, 0, 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_chapter` VALUES (11, 3, 3, 1, '第1章 开始的旅程', '这是《全职高手》第1章的示例内容。\n\n  蝴蝶蓝创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 175, 1, 0, 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_chapter` VALUES (12, 13, 4, 1, '第1章 开始的旅程', '这是《斗破苍穹》第1章的示例内容。\n\n  天蚕土豆创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 176, 1, 0, 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_chapter` VALUES (13, 3, 3, 2, '第2章 开始的旅程', '这是《全职高手》第2章的示例内容。\n\n  蝴蝶蓝创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 175, 1, 0, 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_chapter` VALUES (14, 13, 4, 2, '第2章 开始的旅程', '这是《斗破苍穹》第2章的示例内容。\n\n  天蚕土豆创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 176, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (15, 3, 3, 3, '第3章 开始的旅程', '这是《全职高手》第3章的示例内容。\n\n  蝴蝶蓝创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 175, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (16, 13, 4, 3, '第3章 开始的旅程', '这是《斗破苍穹》第3章的示例内容。\n\n  天蚕土豆创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 176, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (17, 3, 3, 4, '第4章 开始的旅程', '这是《全职高手》第4章的示例内容。\n\n  蝴蝶蓝创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 175, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (18, 13, 4, 4, '第4章 开始的旅程', '这是《斗破苍穹》第4章的示例内容。\n\n  天蚕土豆创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 176, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (19, 3, 3, 5, '第5章 开始的旅程', '这是《全职高手》第5章的示例内容。\n\n  蝴蝶蓝创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 175, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (20, 13, 4, 5, '第5章 开始的旅程', '这是《斗破苍穹》第5章的示例内容。\n\n  天蚕土豆创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 176, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (21, 14, 5, 1, '第1章 开始的旅程', '这是《完美世界》第1章的示例内容。\n\n  辰东创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 174, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (22, 14, 5, 2, '第2章 开始的旅程', '这是《完美世界》第2章的示例内容。\n\n  辰东创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 174, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (23, 14, 5, 3, '第3章 开始的旅程', '这是《完美世界》第3章的示例内容。\n\n  辰东创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 174, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (24, 14, 5, 4, '第4章 开始的旅程', '这是《完美世界》第4章的示例内容。\n\n  辰东创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 174, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (25, 14, 5, 5, '第5章 开始的旅程', '这是《完美世界》第5章的示例内容。\n\n  辰东创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 174, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (26, 15, 6, 1, '第1章 开始的旅程', '这是《全职高手》第1章的示例内容。\n\n  蝴蝶蓝创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 175, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (27, 15, 6, 2, '第2章 开始的旅程', '这是《全职高手》第2章的示例内容。\n\n  蝴蝶蓝创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 175, 1, 0, 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_chapter` VALUES (28, 15, 6, 3, '第3章 开始的旅程', '这是《全职高手》第3章的示例内容。\n\n  蝴蝶蓝创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 175, 1, 0, 1, '2026-06-15 17:46:43');
INSERT INTO `ent_novel_chapter` VALUES (29, 15, 6, 4, '第4章 开始的旅程', '这是《全职高手》第4章的示例内容。\n\n  蝴蝶蓝创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 175, 1, 0, 1, '2026-06-15 17:46:43');
INSERT INTO `ent_novel_chapter` VALUES (30, 15, 6, 5, '第5章 开始的旅程', '这是《全职高手》第5章的示例内容。\n\n  蝴蝶蓝创作的这部作品，讲述了一个精彩的故事。\n\n  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n  （以上为示例内容，实际内容需要根据完整文本来填充）', 175, 1, 0, 1, '2026-06-15 17:46:43');

-- ----------------------------
-- Table structure for ent_novel_read_record
-- ----------------------------
DROP TABLE IF EXISTS `ent_novel_read_record`;
CREATE TABLE `ent_novel_read_record`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `novel_id` int(11) NOT NULL COMMENT '小说ID',
  `chapter_id` int(11) NULL DEFAULT NULL COMMENT '当前章节ID',
  `chapter_num` int(11) NULL DEFAULT NULL COMMENT '当前章节序号',
  `progress` float NULL DEFAULT NULL COMMENT '章节内阅读进度(0-1)',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '记录时间',
  `updated_at` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_novel_read_record_user_id`(`user_id`) USING BTREE,
  INDEX `ix_ent_novel_read_record_novel_id`(`novel_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_novel_read_record
-- ----------------------------

-- ----------------------------
-- Table structure for ent_novel_volume
-- ----------------------------
DROP TABLE IF EXISTS `ent_novel_volume`;
CREATE TABLE `ent_novel_volume`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `novel_id` int(11) NOT NULL COMMENT '小说ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '卷名',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_novel_volume_novel_id`(`novel_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_novel_volume
-- ----------------------------
INSERT INTO `ent_novel_volume` VALUES (1, 1, '第一卷 初出茅庐', 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_volume` VALUES (2, 2, '第一卷 初出茅庐', 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_volume` VALUES (3, 3, '第一卷 初出茅庐', 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_volume` VALUES (4, 13, '第一卷 初出茅庐', 1, '2026-06-15 17:46:41');
INSERT INTO `ent_novel_volume` VALUES (5, 14, '第一卷 初出茅庐', 1, '2026-06-15 17:46:42');
INSERT INTO `ent_novel_volume` VALUES (6, 15, '第一卷 初出茅庐', 1, '2026-06-15 17:46:42');

-- ----------------------------
-- Table structure for ent_playlist
-- ----------------------------
DROP TABLE IF EXISTS `ent_playlist`;
CREATE TABLE `ent_playlist`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '歌单ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '歌单名称',
  `cover_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '封面URL',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '歌单简介',
  `creator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者名称',
  `creator_id` int(11) NULL DEFAULT NULL COMMENT '创建者ID',
  `tags` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标签,逗号分隔',
  `song_count` int(11) NULL DEFAULT NULL COMMENT '歌曲数',
  `play_count` bigint(20) NULL DEFAULT NULL COMMENT '播放量',
  `is_recommend` smallint(6) NULL DEFAULT NULL COMMENT '是否推荐',
  `status` smallint(6) NULL DEFAULT NULL COMMENT '状态',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 49 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_playlist
-- ----------------------------
INSERT INTO `ent_playlist` VALUES (37, '华语经典500首', 'https://picsum.photos/300/300?random=p1', '精选华语流行金曲，陪伴你的每一个日夜', '编辑推荐', 0, '华语,经典,流行', 50, 1200000, 1, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_playlist` VALUES (38, '深夜民谣集', 'https://picsum.photos/300/300?random=p2', '一个人的夜晚，让民谣治愈你', '音乐编辑', 0, '民谣,安静,夜晚', 30, 680000, 1, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_playlist` VALUES (39, '摇滚不死', 'https://picsum.photos/300/300?random=p3', '燃烧你的热血青春', '摇滚老炮', 0, '摇滚,热血,青春', 40, 520000, 1, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_playlist` VALUES (40, '古风雅韵', 'https://picsum.photos/300/300?random=p4', '穿越千年的旋律', '古风达人', 0, '古风,国风,中国风', 35, 450000, 1, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_playlist` VALUES (41, '欧美热单', 'https://picsum.photos/300/300?random=p5', '当下最火的欧美流行音乐', '环球音乐', 0, '欧美,流行,热歌', 45, 890000, 1, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_playlist` VALUES (42, '运动健身BGM', 'https://picsum.photos/300/300?random=p6', '燃脂必备，运动更有动力', '健身达人', 0, '运动,电子,节奏', 25, 320000, 1, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_playlist` VALUES (43, '华语经典500首', 'https://picsum.photos/300/300?random=p1', '精选华语流行金曲，陪伴你的每一个日夜', '编辑推荐', 0, '华语,经典,流行', 50, 1200000, 1, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_playlist` VALUES (44, '深夜民谣集', 'https://picsum.photos/300/300?random=p2', '一个人的夜晚，让民谣治愈你', '音乐编辑', 0, '民谣,安静,夜晚', 30, 680000, 1, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_playlist` VALUES (45, '摇滚不死', 'https://picsum.photos/300/300?random=p3', '燃烧你的热血青春', '摇滚老炮', 0, '摇滚,热血,青春', 40, 520000, 1, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_playlist` VALUES (46, '古风雅韵', 'https://picsum.photos/300/300?random=p4', '穿越千年的旋律', '古风达人', 0, '古风,国风,中国风', 35, 450000, 1, 1, 0, '2026-06-15 17:46:38', '2026-06-15 17:46:38');
INSERT INTO `ent_playlist` VALUES (47, '欧美热单', 'https://picsum.photos/300/300?random=p5', '当下最火的欧美流行音乐', '环球音乐', 0, '欧美,流行,热歌', 45, 890000, 1, 1, 0, '2026-06-15 17:46:38', '2026-06-15 17:46:38');
INSERT INTO `ent_playlist` VALUES (48, '运动健身BGM', 'https://picsum.photos/300/300?random=p6', '燃脂必备，运动更有动力', '健身达人', 0, '运动,电子,节奏', 25, 320000, 1, 1, 0, '2026-06-15 17:46:38', '2026-06-15 17:46:38');

-- ----------------------------
-- Table structure for ent_playlist_song
-- ----------------------------
DROP TABLE IF EXISTS `ent_playlist_song`;
CREATE TABLE `ent_playlist_song`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `playlist_id` int(11) NOT NULL COMMENT '歌单ID',
  `song_id` int(11) NOT NULL COMMENT '歌曲ID',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `added_at` datetime(0) NULL DEFAULT NULL COMMENT '添加时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_playlist_song_playlist_id`(`playlist_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_playlist_song
-- ----------------------------

-- ----------------------------
-- Table structure for ent_song
-- ----------------------------
DROP TABLE IF EXISTS `ent_song`;
CREATE TABLE `ent_song`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '歌曲ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '歌曲名称',
  `artist_id` int(11) NULL DEFAULT NULL COMMENT '歌手ID',
  `artist_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '歌手名称(冗余)',
  `album_id` int(11) NULL DEFAULT NULL COMMENT '专辑ID',
  `cover_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '封面URL',
  `audio_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '音频URL',
  `lyrics` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '歌词(LRC格式)',
  `duration` int(11) NULL DEFAULT NULL COMMENT '时长(秒)',
  `genre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '曲风: 流行/摇滚/古风/民谣/电子/经典/纯音乐',
  `language` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '语种',
  `is_free` smallint(6) NULL DEFAULT NULL COMMENT '是否免费 1是0否',
  `play_count` bigint(20) NULL DEFAULT NULL COMMENT '播放量',
  `score` float NULL DEFAULT NULL COMMENT '评分',
  `status` smallint(6) NULL DEFAULT NULL COMMENT '状态',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_song_title`(`title`) USING BTREE,
  INDEX `ix_ent_song_artist_id`(`artist_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 193 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_song
-- ----------------------------
INSERT INTO `ent_song` VALUES (145, '晴天', 1, '周杰伦', 0, 'https://picsum.photos/300/300?random=s1', '', '', 269, '流行', '华语', 1, 4500000, 4.9, 1, 0, '2026-06-15 17:46:35', '2026-06-15 17:46:35');
INSERT INTO `ent_song` VALUES (146, '七里香', 1, '周杰伦', 0, 'https://picsum.photos/300/300?random=s2', '', '', 299, '流行', '华语', 1, 3800000, 4.8, 1, 0, '2026-06-15 17:46:35', '2026-06-15 17:46:35');
INSERT INTO `ent_song` VALUES (147, '稻香', 1, '周杰伦', 0, 'https://picsum.photos/300/300?random=s3', '', '', 223, '流行', '华语', 1, 4200000, 4.9, 1, 0, '2026-06-15 17:46:35', '2026-06-15 17:46:35');
INSERT INTO `ent_song` VALUES (148, '夜曲', 1, '周杰伦', 0, 'https://picsum.photos/300/300?random=s4', '', '', 235, '流行', '华语', 1, 3600000, 4.7, 1, 0, '2026-06-15 17:46:35', '2026-06-15 17:46:35');
INSERT INTO `ent_song` VALUES (149, '修炼爱情', 2, '林俊杰', 0, 'https://picsum.photos/300/300?random=s5', '', '', 270, '流行', '华语', 1, 3200000, 4.8, 1, 0, '2026-06-15 17:46:35', '2026-06-15 17:46:35');
INSERT INTO `ent_song` VALUES (150, '可惜没如果', 2, '林俊杰', 0, 'https://picsum.photos/300/300?random=s6', '', '', 298, '流行', '华语', 1, 2800000, 4.7, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (151, '江南', 2, '林俊杰', 0, 'https://picsum.photos/300/300?random=s7', '', '', 265, '流行', '华语', 1, 3500000, 4.8, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (152, '晴天', 1, '周杰伦', 0, 'https://picsum.photos/300/300?random=s1', '', '', 269, '流行', '华语', 1, 4500000, 4.9, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (153, '泡沫', 3, '邓紫棋', 0, 'https://picsum.photos/300/300?random=s8', '', '', 262, '流行', '华语', 1, 2500000, 4.6, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (154, '七里香', 1, '周杰伦', 0, 'https://picsum.photos/300/300?random=s2', '', '', 299, '流行', '华语', 1, 3800000, 4.8, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (155, '光年之外', 3, '邓紫棋', 0, 'https://picsum.photos/300/300?random=s9', '', '', 235, '流行', '华语', 1, 3100000, 4.7, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (156, '稻香', 1, '周杰伦', 0, 'https://picsum.photos/300/300?random=s3', '', '', 223, '流行', '华语', 1, 4200000, 4.9, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (157, '演员', 4, '薛之谦', 0, 'https://picsum.photos/300/300?random=s10', '', '', 290, '流行', '华语', 1, 4100000, 4.8, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (158, '夜曲', 1, '周杰伦', 0, 'https://picsum.photos/300/300?random=s4', '', '', 235, '流行', '华语', 1, 3600000, 4.7, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (159, '认真的雪', 4, '薛之谦', 0, 'https://picsum.photos/300/300?random=s11', '', '', 248, '流行', '华语', 1, 2600000, 4.5, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (160, '修炼爱情', 2, '林俊杰', 0, 'https://picsum.photos/300/300?random=s5', '', '', 270, '流行', '华语', 1, 3200000, 4.8, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (161, '十年', 5, '陈奕迅', 0, 'https://picsum.photos/300/300?random=s12', '', '', 208, '流行', '华语', 1, 5200000, 4.9, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (162, '可惜没如果', 2, '林俊杰', 0, 'https://picsum.photos/300/300?random=s6', '', '', 298, '流行', '华语', 1, 2800000, 4.7, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (163, '浮夸', 5, '陈奕迅', 0, 'https://picsum.photos/300/300?random=s13', '', '', 282, '粤语', '华语', 1, 4800000, 4.8, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (164, '富士山下', 5, '陈奕迅', 0, 'https://picsum.photos/300/300?random=s14', '', '', 264, '粤语', '华语', 1, 3900000, 4.7, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (165, '江南', 2, '林俊杰', 0, 'https://picsum.photos/300/300?random=s7', '', '', 265, '流行', '华语', 1, 3500000, 4.8, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (166, 'Love Story', 6, 'Taylor Swift', 0, 'https://picsum.photos/300/300?random=s15', '', '', 235, '流行', '华语', 1, 6100000, 4.8, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (167, '泡沫', 3, '邓紫棋', 0, 'https://picsum.photos/300/300?random=s8', '', '', 262, '流行', '华语', 1, 2500000, 4.6, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (168, 'Shake It Off', 6, 'Taylor Swift', 0, 'https://picsum.photos/300/300?random=s16', '', '', 219, '流行', '华语', 1, 5500000, 4.7, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (169, '光年之外', 3, '邓紫棋', 0, 'https://picsum.photos/300/300?random=s9', '', '', 235, '流行', '华语', 1, 3100000, 4.7, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (170, '倔强', 7, '五月天', 0, 'https://picsum.photos/300/300?random=s17', '', '', 275, '摇滚', '华语', 1, 4300000, 4.9, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (171, '演员', 4, '薛之谦', 0, 'https://picsum.photos/300/300?random=s10', '', '', 290, '流行', '华语', 1, 4100000, 4.8, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (172, '知足', 7, '五月天', 0, 'https://picsum.photos/300/300?random=s18', '', '', 302, '摇滚', '华语', 1, 3800000, 4.8, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (173, '认真的雪', 4, '薛之谦', 0, 'https://picsum.photos/300/300?random=s11', '', '', 248, '流行', '华语', 1, 2600000, 4.5, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (174, '突然好想你', 7, '五月天', 0, 'https://picsum.photos/300/300?random=s19', '', '', 326, '摇滚', '华语', 1, 4600000, 4.9, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (175, '十年', 5, '陈奕迅', 0, 'https://picsum.photos/300/300?random=s12', '', '', 208, '流行', '华语', 1, 5200000, 4.9, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (176, '像我这样的人', 8, '毛不易', 0, 'https://picsum.photos/300/300?random=s20', '', '', 268, '民谣', '华语', 1, 3200000, 4.7, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (177, '浮夸', 5, '陈奕迅', 0, 'https://picsum.photos/300/300?random=s13', '', '', 282, '粤语', '华语', 1, 4800000, 4.8, 1, 0, '2026-06-15 17:46:36', '2026-06-15 17:46:36');
INSERT INTO `ent_song` VALUES (178, '消愁', 8, '毛不易', 0, 'https://picsum.photos/300/300?random=s21', '', '', 285, '民谣', '华语', 1, 2900002, 4.6, 1, 0, '2026-06-15 17:46:37', '2026-06-16 15:31:36');
INSERT INTO `ent_song` VALUES (179, '富士山下', 5, '陈奕迅', 0, 'https://picsum.photos/300/300?random=s14', '', '', 264, '粤语', '华语', 1, 3900000, 4.7, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_song` VALUES (180, '平凡之路', 0, '朴树', 0, 'https://picsum.photos/300/300?random=s22', '', '', 290, '民谣', '华语', 1, 5800000, 4.9, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_song` VALUES (181, 'Love Story', 6, 'Taylor Swift', 0, 'https://picsum.photos/300/300?random=s15', '', '', 235, '流行', '华语', 1, 6100000, 4.8, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_song` VALUES (182, '起风了', 0, '买辣椒也用券', 0, 'https://picsum.photos/300/300?random=s23', '', '', 325, '古风', '华语', 1, 4100000, 4.7, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_song` VALUES (183, 'Shake It Off', 6, 'Taylor Swift', 0, 'https://picsum.photos/300/300?random=s16', '', '', 219, '流行', '华语', 1, 5500000, 4.7, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_song` VALUES (184, '孤勇者', 5, '陈奕迅', 0, 'https://picsum.photos/300/300?random=s24', '', '', 262, '流行', '华语', 1, 6800000, 4.8, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_song` VALUES (185, '倔强', 7, '五月天', 0, 'https://picsum.photos/300/300?random=s17', '', '', 275, '摇滚', '华语', 1, 4300000, 4.9, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_song` VALUES (186, '知足', 7, '五月天', 0, 'https://picsum.photos/300/300?random=s18', '', '', 302, '摇滚', '华语', 1, 3800001, 4.8, 1, 0, '2026-06-15 17:46:37', '2026-06-30 17:36:06');
INSERT INTO `ent_song` VALUES (187, '突然好想你', 7, '五月天', 0, 'https://picsum.photos/300/300?random=s19', '', '', 326, '摇滚', '华语', 1, 4600000, 4.9, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_song` VALUES (188, '像我这样的人', 8, '毛不易', 0, 'https://picsum.photos/300/300?random=s20', '', '', 268, '民谣', '华语', 1, 3200000, 4.7, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_song` VALUES (189, '消愁', 8, '毛不易', 0, 'https://picsum.photos/300/300?random=s21', '', '', 285, '民谣', '华语', 1, 2900000, 4.6, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_song` VALUES (190, '平凡之路', 0, '朴树', 0, 'https://picsum.photos/300/300?random=s22', '', '', 290, '民谣', '华语', 1, 5800000, 4.9, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_song` VALUES (191, '起风了', 0, '买辣椒也用券', 0, 'https://picsum.photos/300/300?random=s23', '', '', 325, '古风', '华语', 1, 4100000, 4.7, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_song` VALUES (192, '孤勇者', 5, '陈奕迅', 0, 'https://picsum.photos/300/300?random=s24', '', '', 262, '流行', '华语', 1, 6800000, 4.8, 1, 0, '2026-06-15 17:46:37', '2026-06-15 17:46:37');

-- ----------------------------
-- Table structure for ent_song_play_record
-- ----------------------------
DROP TABLE IF EXISTS `ent_song_play_record`;
CREATE TABLE `ent_song_play_record`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `song_id` int(11) NOT NULL COMMENT '歌曲ID',
  `play_duration` int(11) NULL DEFAULT NULL COMMENT '播放时长(秒)',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '播放时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_song_play_record_user_id`(`user_id`) USING BTREE,
  INDEX `ix_ent_song_play_record_song_id`(`song_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_song_play_record
-- ----------------------------
INSERT INTO `ent_song_play_record` VALUES (1, 1, 178, 0, '2026-06-15 17:48:33');
INSERT INTO `ent_song_play_record` VALUES (2, 1, 178, 0, '2026-06-16 15:31:36');
INSERT INTO `ent_song_play_record` VALUES (3, 1, 186, 0, '2026-06-30 17:36:06');

-- ----------------------------
-- Table structure for ent_video
-- ----------------------------
DROP TABLE IF EXISTS `ent_video`;
CREATE TABLE `ent_video`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '视频ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `cover_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '封面URL',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '简介',
  `category_id` int(11) NULL DEFAULT NULL COMMENT '分类ID',
  `video_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '类型: movie/series/variety/anime/documentary/short',
  `region` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '地区',
  `year` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '年份',
  `director` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '导演',
  `actors` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '演员,逗号分隔',
  `tags` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标签,逗号分隔',
  `episode_count` int(11) NULL DEFAULT NULL COMMENT '总集数',
  `status_text` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '状态: 完结/连载中',
  `is_free` smallint(6) NULL DEFAULT NULL COMMENT '是否免费',
  `play_count` bigint(20) NULL DEFAULT NULL COMMENT '播放量',
  `score` float NULL DEFAULT NULL COMMENT '评分',
  `score_count` int(11) NULL DEFAULT NULL COMMENT '评分人数',
  `is_hot` smallint(6) NULL DEFAULT NULL COMMENT '是否热播',
  `is_new` smallint(6) NULL DEFAULT NULL COMMENT '是否上新',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `status` smallint(6) NULL DEFAULT NULL COMMENT '状态(0下架/1上架)',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_video_title`(`title`) USING BTREE,
  INDEX `ix_ent_video_category_id`(`category_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 65 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_video
-- ----------------------------
INSERT INTO `ent_video` VALUES (49, '流浪地球2', 'https://picsum.photos/300/400?random=v1', '太阳即将毁灭，人类在地球表面建造出巨大的推进器，寻找新的家园。然而宇宙之路危机四伏，为了拯救地球，流浪地球时代的年轻人再次挺身而出，展开争分夺秒的生死之战。', 0, 'movie', '大陆', '2023', '郭帆', '吴京,刘德华,李雪健', '科幻,灾难,冒险', 1, '完结', 1, 8900000, 9.3, 0, 1, 0, 0, 1, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_video` VALUES (50, '三体', 'https://picsum.photos/300/400?random=v2', '纳米材料学家汪淼被警官史强带到联合作战中心，得知地球基础科学出现了异常扰动，科学界人心惶惶。', 0, 'series', '大陆', '2023', '杨磊', '张鲁一,于和伟,陈瑾', '科幻,悬疑,剧情', 30, '完结', 1, 12000000, 8.7, 0, 1, 0, 0, 1, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_video` VALUES (51, '繁花', 'https://picsum.photos/300/400?random=v3', '九十年代的上海，阿宝在时代的浪潮中抓住机遇，凭借出色的商业头脑和不懈的努力，成为了商界的后起之秀。', 0, 'series', '大陆', '2024', '王家卫', '胡歌,马伊琍,唐嫣', '年代,剧情,商战', 30, '完结', 1, 15000000, 8.9, 0, 1, 1, 0, 1, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_video` VALUES (52, '庆余年2', 'https://picsum.photos/300/400?random=v4', '范闲在经历种种磨难后，终于回到了京都。他将面临更加复杂的政治斗争和更加危险的敌人。', 0, 'series', '大陆', '2024', '孙皓', '张若昀,李沁,陈道明', '古装,权谋,喜剧', 36, '完结', 1, 18000000, 8.5, 0, 0, 1, 0, 1, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_video` VALUES (53, '铃芽之旅', 'https://picsum.photos/300/400?random=v5', '少女铃芽在偶遇神秘青年草太后，踏上了关闭灾难之门的旅程。在旅途中，她逐渐了解了关于自己和这片土地的秘密。', 0, 'anime', '日本', '2023', '新海诚', '原菜乃华,松村北斗', '动画,奇幻,冒险', 1, '完结', 1, 6500000, 8.6, 0, 0, 0, 0, 1, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_video` VALUES (54, '星际穿越', 'https://picsum.photos/300/400?random=v6', '在不远的未来，地球气候急剧变化，农作物相继枯萎。前NASA宇航员库珀为拯救人类，穿越虫洞寻找新家园。', 0, 'movie', '欧美', '2014', '克里斯托弗·诺兰', '马修·麦康纳,安妮·海瑟薇', '科幻,冒险,剧情', 1, '完结', 1, 12000000, 9.4, 0, 0, 0, 0, 1, '2026-06-15 17:46:37', '2026-06-15 17:46:37');
INSERT INTO `ent_video` VALUES (55, '鬼灭之刃', 'https://picsum.photos/300/400?random=v7', '卖炭少年炭治郎的家人被鬼杀害，唯一幸存的妹妹祢豆子也变成了鬼。为了寻找让妹妹变回人类的方法，炭治郎踏上了斩鬼之路。', 0, 'anime', '日本', '2019', '外崎春雄', '花江夏树,的場光昭', '动画,热血,战斗', 26, '完结', 1, 9800000, 9.1, 0, 0, 0, 0, 1, '2026-06-15 17:46:38', '2026-06-15 17:46:38');
INSERT INTO `ent_video` VALUES (56, '国家地理纪录片', 'https://picsum.photos/300/400?random=v8', '国家地理出品的年度自然纪录片，探索地球上最壮观的自然景观和最神奇的生物。', 0, 'documentary', '欧美', '2024', '', '', '自然,探索,科学', 12, '完结', 1, 3200000, 9, 0, 0, 0, 0, 1, '2026-06-15 17:46:38', '2026-06-15 17:46:38');
INSERT INTO `ent_video` VALUES (57, '流浪地球2', 'https://picsum.photos/300/400?random=v1', '太阳即将毁灭，人类在地球表面建造出巨大的推进器，寻找新的家园。然而宇宙之路危机四伏，为了拯救地球，流浪地球时代的年轻人再次挺身而出，展开争分夺秒的生死之战。', 0, 'movie', '大陆', '2023', '郭帆', '吴京,刘德华,李雪健', '科幻,灾难,冒险', 1, '完结', 1, 8900000, 9.3, 0, 1, 0, 0, 1, '2026-06-15 17:46:38', '2026-06-15 17:46:38');
INSERT INTO `ent_video` VALUES (58, '三体', 'https://picsum.photos/300/400?random=v2', '纳米材料学家汪淼被警官史强带到联合作战中心，得知地球基础科学出现了异常扰动，科学界人心惶惶。', 0, 'series', '大陆', '2023', '杨磊', '张鲁一,于和伟,陈瑾', '科幻,悬疑,剧情', 30, '完结', 1, 12000000, 8.7, 0, 1, 0, 0, 1, '2026-06-15 17:46:38', '2026-06-15 17:46:38');
INSERT INTO `ent_video` VALUES (59, '繁花', 'https://picsum.photos/300/400?random=v3', '九十年代的上海，阿宝在时代的浪潮中抓住机遇，凭借出色的商业头脑和不懈的努力，成为了商界的后起之秀。', 0, 'series', '大陆', '2024', '王家卫', '胡歌,马伊琍,唐嫣', '年代,剧情,商战', 30, '完结', 1, 15000000, 8.9, 0, 1, 1, 0, 1, '2026-06-15 17:46:38', '2026-06-15 17:46:38');
INSERT INTO `ent_video` VALUES (60, '庆余年2', 'https://picsum.photos/300/400?random=v4', '范闲在经历种种磨难后，终于回到了京都。他将面临更加复杂的政治斗争和更加危险的敌人。', 0, 'series', '大陆', '2024', '孙皓', '张若昀,李沁,陈道明', '古装,权谋,喜剧', 36, '完结', 1, 18000000, 8.5, 0, 0, 1, 0, 1, '2026-06-15 17:46:38', '2026-06-15 17:46:38');
INSERT INTO `ent_video` VALUES (61, '铃芽之旅', 'https://picsum.photos/300/400?random=v5', '少女铃芽在偶遇神秘青年草太后，踏上了关闭灾难之门的旅程。在旅途中，她逐渐了解了关于自己和这片土地的秘密。', 0, 'anime', '日本', '2023', '新海诚', '原菜乃华,松村北斗', '动画,奇幻,冒险', 1, '完结', 1, 6500000, 8.6, 0, 0, 0, 0, 1, '2026-06-15 17:46:38', '2026-06-15 17:46:38');
INSERT INTO `ent_video` VALUES (62, '星际穿越', 'https://picsum.photos/300/400?random=v6', '在不远的未来，地球气候急剧变化，农作物相继枯萎。前NASA宇航员库珀为拯救人类，穿越虫洞寻找新家园。', 0, 'movie', '欧美', '2014', '克里斯托弗·诺兰', '马修·麦康纳,安妮·海瑟薇', '科幻,冒险,剧情', 1, '完结', 1, 12000000, 9.4, 0, 0, 0, 0, 1, '2026-06-15 17:46:38', '2026-06-15 17:46:38');
INSERT INTO `ent_video` VALUES (63, '鬼灭之刃', 'https://picsum.photos/300/400?random=v7', '卖炭少年炭治郎的家人被鬼杀害，唯一幸存的妹妹祢豆子也变成了鬼。为了寻找让妹妹变回人类的方法，炭治郎踏上了斩鬼之路。', 0, 'anime', '日本', '2019', '外崎春雄', '花江夏树,的場光昭', '动画,热血,战斗', 26, '完结', 1, 9800000, 9.1, 0, 0, 0, 0, 1, '2026-06-15 17:46:38', '2026-06-15 17:46:38');
INSERT INTO `ent_video` VALUES (64, '国家地理纪录片', 'https://picsum.photos/300/400?random=v8', '国家地理出品的年度自然纪录片，探索地球上最壮观的自然景观和最神奇的生物。', 0, 'documentary', '欧美', '2024', '', '', '自然,探索,科学', 12, '完结', 1, 3200000, 9, 0, 0, 0, 0, 1, '2026-06-15 17:46:38', '2026-06-15 17:46:38');

-- ----------------------------
-- Table structure for ent_video_episode
-- ----------------------------
DROP TABLE IF EXISTS `ent_video_episode`;
CREATE TABLE `ent_video_episode`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `video_id` int(11) NOT NULL COMMENT '视频ID',
  `episode_num` int(11) NULL DEFAULT NULL COMMENT '集数',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分集标题',
  `cover_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分集封面',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '视频URL',
  `duration` int(11) NULL DEFAULT NULL COMMENT '时长(秒)',
  `is_free` smallint(6) NULL DEFAULT NULL COMMENT '是否免费',
  `status` smallint(6) NULL DEFAULT NULL COMMENT '状态',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_video_episode_video_id`(`video_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 201 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_video_episode
-- ----------------------------
INSERT INTO `ent_video_episode` VALUES (151, 50, 1, '第1集', '', 'https://example.com/video/50/ep1.mp4', 0, 1, 1, '2026-06-15 17:46:38');
INSERT INTO `ent_video_episode` VALUES (152, 50, 2, '第2集', '', 'https://example.com/video/50/ep2.mp4', 0, 1, 1, '2026-06-15 17:46:38');
INSERT INTO `ent_video_episode` VALUES (153, 50, 3, '第3集', '', 'https://example.com/video/50/ep3.mp4', 0, 1, 1, '2026-06-15 17:46:38');
INSERT INTO `ent_video_episode` VALUES (154, 50, 4, '第4集', '', 'https://example.com/video/50/ep4.mp4', 0, 1, 1, '2026-06-15 17:46:38');
INSERT INTO `ent_video_episode` VALUES (155, 50, 5, '第5集', '', 'https://example.com/video/50/ep5.mp4', 0, 1, 1, '2026-06-15 17:46:38');
INSERT INTO `ent_video_episode` VALUES (156, 51, 1, '第1集', '', 'https://example.com/video/51/ep1.mp4', 0, 1, 1, '2026-06-15 17:46:38');
INSERT INTO `ent_video_episode` VALUES (157, 51, 2, '第2集', '', 'https://example.com/video/51/ep2.mp4', 0, 1, 1, '2026-06-15 17:46:38');
INSERT INTO `ent_video_episode` VALUES (158, 51, 3, '第3集', '', 'https://example.com/video/51/ep3.mp4', 0, 1, 1, '2026-06-15 17:46:38');
INSERT INTO `ent_video_episode` VALUES (159, 51, 4, '第4集', '', 'https://example.com/video/51/ep4.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (160, 51, 5, '第5集', '', 'https://example.com/video/51/ep5.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (161, 58, 1, '第1集', '', 'https://example.com/video/58/ep1.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (162, 52, 1, '第1集', '', 'https://example.com/video/52/ep1.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (163, 58, 2, '第2集', '', 'https://example.com/video/58/ep2.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (164, 52, 2, '第2集', '', 'https://example.com/video/52/ep2.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (165, 58, 3, '第3集', '', 'https://example.com/video/58/ep3.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (166, 52, 3, '第3集', '', 'https://example.com/video/52/ep3.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (167, 58, 4, '第4集', '', 'https://example.com/video/58/ep4.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (168, 52, 4, '第4集', '', 'https://example.com/video/52/ep4.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (169, 58, 5, '第5集', '', 'https://example.com/video/58/ep5.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (170, 52, 5, '第5集', '', 'https://example.com/video/52/ep5.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (171, 59, 1, '第1集', '', 'https://example.com/video/59/ep1.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (172, 55, 1, '第1集', '', 'https://example.com/video/55/ep1.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (173, 59, 2, '第2集', '', 'https://example.com/video/59/ep2.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (174, 55, 2, '第2集', '', 'https://example.com/video/55/ep2.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (175, 55, 3, '第3集', '', 'https://example.com/video/55/ep3.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (176, 59, 3, '第3集', '', 'https://example.com/video/59/ep3.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (177, 55, 4, '第4集', '', 'https://example.com/video/55/ep4.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (178, 59, 4, '第4集', '', 'https://example.com/video/59/ep4.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (179, 55, 5, '第5集', '', 'https://example.com/video/55/ep5.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (180, 59, 5, '第5集', '', 'https://example.com/video/59/ep5.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (181, 56, 1, '第1集', '', 'https://example.com/video/56/ep1.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (182, 60, 1, '第1集', '', 'https://example.com/video/60/ep1.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (183, 56, 2, '第2集', '', 'https://example.com/video/56/ep2.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (184, 60, 2, '第2集', '', 'https://example.com/video/60/ep2.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (185, 56, 3, '第3集', '', 'https://example.com/video/56/ep3.mp4', 0, 1, 1, '2026-06-15 17:46:39');
INSERT INTO `ent_video_episode` VALUES (186, 60, 3, '第3集', '', 'https://example.com/video/60/ep3.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (187, 56, 4, '第4集', '', 'https://example.com/video/56/ep4.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (188, 60, 4, '第4集', '', 'https://example.com/video/60/ep4.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (189, 56, 5, '第5集', '', 'https://example.com/video/56/ep5.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (190, 60, 5, '第5集', '', 'https://example.com/video/60/ep5.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (191, 63, 1, '第1集', '', 'https://example.com/video/63/ep1.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (192, 63, 2, '第2集', '', 'https://example.com/video/63/ep2.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (193, 63, 3, '第3集', '', 'https://example.com/video/63/ep3.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (194, 63, 4, '第4集', '', 'https://example.com/video/63/ep4.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (195, 63, 5, '第5集', '', 'https://example.com/video/63/ep5.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (196, 64, 1, '第1集', '', 'https://example.com/video/64/ep1.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (197, 64, 2, '第2集', '', 'https://example.com/video/64/ep2.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (198, 64, 3, '第3集', '', 'https://example.com/video/64/ep3.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (199, 64, 4, '第4集', '', 'https://example.com/video/64/ep4.mp4', 0, 1, 1, '2026-06-15 17:46:40');
INSERT INTO `ent_video_episode` VALUES (200, 64, 5, '第5集', '', 'https://example.com/video/64/ep5.mp4', 0, 1, 1, '2026-06-15 17:46:40');

-- ----------------------------
-- Table structure for ent_video_play_record
-- ----------------------------
DROP TABLE IF EXISTS `ent_video_play_record`;
CREATE TABLE `ent_video_play_record`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `video_id` int(11) NOT NULL COMMENT '视频ID',
  `episode_id` int(11) NULL DEFAULT NULL COMMENT '分集ID',
  `episode_num` int(11) NULL DEFAULT NULL COMMENT '播放到第几集',
  `progress_sec` int(11) NULL DEFAULT NULL COMMENT '播放进度(秒)',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '记录时间',
  `updated_at` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_ent_video_play_record_user_id`(`user_id`) USING BTREE,
  INDEX `ix_ent_video_play_record_video_id`(`video_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ent_video_play_record
-- ----------------------------

-- ----------------------------
-- Table structure for gold_predictions
-- ----------------------------
DROP TABLE IF EXISTS `gold_predictions`;
CREATE TABLE `gold_predictions`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `predict_date` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '预测目标日期',
  `predict_price` float NOT NULL COMMENT '预测价格(元/克)',
  `algorithm` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ensemble' COMMENT '预测模型: ma/ema/lr/ensemble',
  `params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '预测参数JSON',
  `confidence` float NULL DEFAULT NULL COMMENT '置信度(0-100)',
  `trend` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '趋势: up/down/stable',
  `change_pct` float NULL DEFAULT NULL COMMENT '预测涨跌幅(%)',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_gold_predictions_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gold_predictions
-- ----------------------------
INSERT INTO `gold_predictions` VALUES (1, 1, '2026-07-07', 947.46, 'ensemble', '{\"days\": 7, \"algorithm\": \"ensemble\"}', 95, 'up', 7.87, '2026-06-30 16:23:26');
INSERT INTO `gold_predictions` VALUES (2, 1, '2026-07-07', 947.66, 'ensemble', '{\"days\": 7, \"algorithm\": \"ensemble\"}', 95, 'up', 7.9, '2026-06-30 16:25:59');
INSERT INTO `gold_predictions` VALUES (3, 1, '2026-07-07', 881.19, 'ma', '{\"days\": 7, \"algorithm\": \"ma\"}', 91.7, 'up', 0.33, '2026-06-30 16:26:14');
INSERT INTO `gold_predictions` VALUES (4, 1, '2026-07-14', 1054.69, 'lr', '{\"days\": 14, \"algorithm\": \"lr\"}', 94.7, 'up', 20.08, '2026-06-30 16:43:21');
INSERT INTO `gold_predictions` VALUES (5, 1, '2026-07-07', 881.84, 'ema', '{\"days\": 7, \"algorithm\": \"ema\"}', 93.7, 'up', 0.4, '2026-06-30 17:01:38');
INSERT INTO `gold_predictions` VALUES (6, 1, '2026-07-07', 881.03, 'ma', '{\"days\": 7, \"algorithm\": \"ma\"}', 91.7, 'up', 0.31, '2026-06-30 17:16:21');
INSERT INTO `gold_predictions` VALUES (7, 1, '2026-07-07', 884.22, 'ma', '{\"days\": 7, \"algorithm\": \"ma\"}', 91.7, 'up', 0.67, '2026-06-30 17:20:04');
INSERT INTO `gold_predictions` VALUES (8, 1, '2026-07-30', 947.56, 'ensemble', '{\"days\": 30, \"algorithm\": \"ensemble\"}', 95, 'up', 7.88, '2026-06-30 17:26:59');

-- ----------------------------
-- Table structure for gold_prices
-- ----------------------------
DROP TABLE IF EXISTS `gold_prices`;
CREATE TABLE `gold_prices`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `date` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '日期 YYYY-MM-DD',
  `price_cny` float NOT NULL COMMENT '人民币金价(元/克)',
  `price_usd` float NULL DEFAULT NULL COMMENT '美元金价(美元/盎司)',
  `change_pct` float NULL DEFAULT NULL COMMENT '涨跌幅(%)',
  `open` float NULL DEFAULT NULL COMMENT '开盘价(元/克)',
  `high` float NULL DEFAULT NULL COMMENT '最高价(元/克)',
  `low` float NULL DEFAULT NULL COMMENT '最低价(元/克)',
  `close` float NULL DEFAULT NULL COMMENT '收盘价(元/克)',
  `volume` int(11) NULL DEFAULT NULL COMMENT '成交量',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ix_gold_prices_date`(`date`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 824 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gold_prices
-- ----------------------------
INSERT INTO `gold_prices` VALUES (94, '2026-06-30', 879.67, 3773.91, -0.86, 883.9, 885.5, 862.13, 879.67, 47798, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (95, '2026-06-29', 887.34, 3806.81, 0.51, 883, 894.97, 882.22, 887.34, 48028, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (96, '2026-06-26', 882.84, 3787.51, 1.14, 872, 884.2, 870.76, 882.84, 38350, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (97, '2026-06-25', 872.86, 3744.69, -2.36, 885.3, 887.5, 865.79, 872.86, 54840, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (98, '2026-06-24', 894, 3835.38, -0.49, 898.99, 904.5, 884.57, 894, 45664, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (99, '2026-06-23', 898.4, 3854.26, -1.76, 916, 917.01, 895.69, 898.4, 35878, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (100, '2026-06-22', 914.5, 3923.33, -2.27, 915.41, 920.19, 908.2, 914.5, 40438, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (101, '2026-06-18', 935.78, 4014.63, -0.43, 939, 950.8, 930.93, 935.78, 39280, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (102, '2026-06-17', 939.8, 4031.87, -0.01, 942, 945.9, 936.69, 939.8, 38186, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (103, '2026-06-16', 939.9, 4032.3, 0.17, 941.99, 948.9, 936.37, 939.9, 39656, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (104, '2026-06-15', 938.3, 4025.44, 3.34, 914.94, 943.12, 908.92, 938.3, 37206, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (105, '2026-06-12', 908, 3895.45, 1.28, 890.07, 915, 883.48, 908, 43994, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (106, '2026-06-11', 896.5, 3846.11, -2.07, 906, 913, 883.33, 896.5, 61770, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (107, '2026-06-10', 915.45, 3927.41, -3.07, 947.5, 951.24, 909.75, 915.45, 60130, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (108, '2026-06-09', 944.42, 4051.69, 0.36, 945, 950, 942.65, 944.42, 22924, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (109, '2026-06-08', 941, 4037.02, -3.42, 974, 974.6, 932.5, 941, 66222, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (110, '2026-06-05', 974.3, 4179.88, 0, 983.5, 984.75, 966.6, 974.3, 32018, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (111, '2026-06-04', 974.3, 4179.88, 0.11, 974.73, 978.5, 966.95, 974.3, 35260, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (112, '2026-06-03', 973.24, 4175.33, -1.39, 985.99, 986.99, 971.88, 973.24, 29598, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (113, '2026-06-02', 987, 4234.37, 0.61, 982, 988.58, 970.29, 987, 44352, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (114, '2026-06-01', 981, 4208.63, -0.31, 986, 999.5, 980, 981, 35280, '2026-06-30 14:38:13');
INSERT INTO `gold_prices` VALUES (115, '2026-05-29', 984.02, 4221.58, 2.37, 960.96, 986.93, 958.4, 984.02, 41450, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (116, '2026-05-28', 961.2, 4123.68, -2.11, 969, 978, 956, 961.2, 80918, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (117, '2026-05-27', 981.95, 4212.7, -0.94, 986.99, 991.47, 979.9, 981.95, 37404, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (118, '2026-05-26', 991.29, 4252.77, -0.54, 1000, 1001.5, 990.25, 991.29, 32004, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (119, '2026-05-25', 996.64, 4275.72, 0.54, 990.76, 1002, 985.06, 996.64, 27950, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (120, '2026-05-22', 991.31, 4252.86, 0.1, 991.7, 998.98, 986, 991.31, 27392, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (121, '2026-05-21', 990.32, 4248.61, 0.55, 987.7, 1001.94, 981.49, 990.32, 34654, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (122, '2026-05-20', 984.9, 4225.36, -1.37, 996, 998.7, 979.25, 984.9, 70216, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (123, '2026-05-19', 998.6, 4284.13, -0.06, 999, 1005.43, 995, 998.6, 41134, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (124, '2026-05-18', 999.2, 4286.71, -0.65, 1001, 1004.5, 987.1, 999.2, 66122, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (125, '2026-05-15', 1005.76, 4314.85, -2.23, 1026.6, 1029.56, 1000.01, 1005.76, 81424, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (126, '2026-05-14', 1028.7, 4413.26, -0.11, 1029, 1030.8, 1022, 1028.7, 36624, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (127, '2026-05-13', 1029.8, 4417.98, 0.13, 1029.8, 1032.67, 1017.3, 1029.8, 34600, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (128, '2026-05-12', 1028.49, 4412.36, 0.34, 1024, 1040.8, 1023, 1028.49, 49802, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (129, '2026-05-11', 1025, 4397.39, -0.86, 1034.4, 1040.5, 1018.94, 1025, 44108, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (130, '2026-05-08', 1033.86, 4435.4, -0.46, 1038.51, 1044, 1030, 1033.86, 30634, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (131, '2026-05-07', 1038.6, 4455.74, 1.18, 1030, 1041.78, 1022.06, 1038.6, 42720, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (132, '2026-05-06', 1026.5, 4403.83, 1.29, 1017.87, 1026.74, 1014.42, 1026.5, 35900, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (133, '2026-04-30', 1013.4, 4347.63, 0.46, 1007.5, 1014.4, 995.2, 1013.4, 46212, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (134, '2026-04-29', 1008.8, 4327.89, -1.21, 1007, 1015.5, 1005, 1008.8, 60870, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (135, '2026-04-28', 1021.2, 4381.09, -1.55, 1035, 1036.9, 1018.76, 1021.2, 60694, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (136, '2026-04-27', 1037.25, 4449.95, 0.38, 1037.3, 1043.3, 1033.51, 1037.25, 36902, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (137, '2026-04-24', 1033.3, 4433, -0.34, 1039.5, 1044.34, 1027, 1033.3, 59404, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (138, '2026-04-23', 1036.8, 4448.02, -1.13, 1047, 1048.18, 1033.89, 1036.8, 71406, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (139, '2026-04-22', 1048.67, 4498.94, -0.17, 1052.98, 1052.98, 1036, 1048.67, 75672, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (140, '2026-04-21', 1050.48, 4506.7, -0.24, 1054.56, 1057.84, 1048.22, 1050.48, 53454, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (141, '2026-04-20', 1053, 4517.52, 0.03, 1054, 1070.8, 1045, 1053, 65724, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (142, '2026-04-17', 1052.7, 4516.23, -0.55, 1058.84, 1058.89, 1047.52, 1052.7, 30756, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (143, '2026-04-16', 1058.5, 4541.11, 0.33, 1055.5, 1061.25, 1050.55, 1058.5, 33730, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (144, '2026-04-15', 1055, 4526.1, 0.76, 1047, 1067.66, 1045.2, 1055, 53834, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (145, '2026-04-14', 1047, 4491.77, 0.48, 1037, 1051.8, 1035.94, 1047, 41742, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (146, '2026-04-13', 1042, 4470.32, -0.39, 1049, 1053.6, 1031, 1042, 47234, '2026-06-30 14:38:14');
INSERT INTO `gold_prices` VALUES (147, '2026-04-10', 1046.05, 4487.7, 0.68, 1048, 1055.37, 1043, 1046.05, 41402, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (148, '2026-04-09', 1039, 4457.45, -1.84, 1056, 1057.11, 1035.62, 1039, 58436, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (149, '2026-04-08', 1058.51, 4541.15, 2.92, 1031.11, 1069.99, 1020.65, 1058.51, 65284, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (150, '2026-04-07', 1028.5, 4412.41, -0.61, 1030.77, 1034.55, 1024.5, 1028.5, 56118, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (151, '2026-04-03', 1034.79, 4439.39, 0.82, 1022.07, 1044.26, 1017.6, 1034.79, 49346, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (152, '2026-04-02', 1026.4, 4403.4, -1.88, 1053, 1060.91, 1011.11, 1026.4, 99224, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (153, '2026-04-01', 1046.1, 4487.91, 3, 1020.11, 1049.37, 1017.6, 1046.1, 70138, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (154, '2026-03-31', 1015.68, 4357.41, 0.66, 1017, 1030.33, 1007.5, 1015.68, 59994, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (155, '2026-03-30', 1009, 4328.75, 1.69, 987.5, 1015.28, 985, 1009, 91148, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (156, '2026-03-27', 992.2, 4256.67, 0.29, 985.14, 999.11, 975.1, 992.2, 81692, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (157, '2026-03-26', 989.31, 4244.28, -2.39, 1018, 1019.46, 982.52, 989.31, 85694, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (158, '2026-03-25', 1013.51, 4348.1, 3.63, 977, 1024, 967.5, 1013.51, 80426, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (159, '2026-03-24', 977.99, 4195.71, 6.19, 970, 998, 956.85, 977.99, 87880, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (160, '2026-03-23', 920.99, 3951.17, -11.49, 1038.38, 1044, 913.94, 920.99, 104370, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (161, '2026-03-20', 1040.6, 4464.32, -2.02, 1035.3, 1055, 1002.1, 1040.6, 84142, '2026-06-30 14:38:15');
INSERT INTO `gold_prices` VALUES (162, '2026-03-19', 1062, 4556.13, -4.48, 1096, 1096.66, 1056.68, 1062, 75754, '2026-06-30 14:38:16');
INSERT INTO `gold_prices` VALUES (163, '2026-03-18', 1111.83, 4769.9, -0.34, 1112.5, 1117.25, 1107.43, 1111.83, 47378, '2026-06-30 14:38:16');
INSERT INTO `gold_prices` VALUES (164, '2026-03-17', 1115.6, 4786.08, 0.06, 1113.5, 1120.3, 1109, 1115.6, 39198, '2026-06-30 14:38:16');
INSERT INTO `gold_prices` VALUES (165, '2026-03-16', 1114.96, 4783.33, -1.44, 1138, 1139.02, 1109.98, 1114.96, 51450, '2026-06-30 14:38:16');
INSERT INTO `gold_prices` VALUES (166, '2026-03-13', 1131.2, 4853, -1.33, 1146.26, 1149.05, 1129.3, 1131.2, 52266, '2026-06-30 14:38:16');
INSERT INTO `gold_prices` VALUES (167, '2026-03-12', 1146.45, 4918.43, -0.33, 1148, 1151, 1140.7, 1146.45, 33864, '2026-06-30 14:38:16');
INSERT INTO `gold_prices` VALUES (168, '2026-03-11', 1150.3, 4934.95, 0.41, 1148, 1158.97, 1144, 1150.3, 40346, '2026-06-30 14:38:16');
INSERT INTO `gold_prices` VALUES (169, '2026-03-10', 1145.6, 4914.78, 0.51, 1137.5, 1151.51, 1132.64, 1145.6, 45916, '2026-06-30 14:38:16');
INSERT INTO `gold_prices` VALUES (170, '2026-03-09', 1139.8, 4889.9, 0.13, 1132, 1150, 1119.1, 1139.8, 69750, '2026-06-30 14:38:16');
INSERT INTO `gold_prices` VALUES (171, '2026-03-06', 1138.3, 4883.46, -0.93, 1149.98, 1151, 1130.04, 1138.3, 45712, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (172, '2026-03-05', 1148.93, 4929.07, -0.34, 1156, 1159.59, 1140, 1148.93, 50766, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (173, '2026-03-04', 1152.8, 4945.67, -2.42, 1148.09, 1166.99, 1122.4, 1152.8, 93672, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (174, '2026-03-03', 1181.33, 5068.07, -1.52, 1194.93, 1202.5, 1173, 1181.33, 81118, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (175, '2026-03-02', 1199.51, 5146.06, 5.02, 1145.5, 1209.96, 1144.1, 1199.51, 60946, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (176, '2026-02-27', 1142.15, 4899.98, -0.07, 1139.01, 1147.29, 1134.14, 1142.15, 38408, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (177, '2026-02-26', 1143, 4903.63, -0.17, 1145, 1150.99, 1140.38, 1143, 28110, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (178, '2026-02-25', 1145, 4912.21, -0.17, 1145.6, 1151.05, 1132.96, 1145, 29238, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (179, '2026-02-24', 1147, 4920.79, 3.47, 1158.5, 1158.5, 1139, 1147, 27306, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (180, '2026-02-13', 1108.5, 4755.62, -1.29, 1123.6, 1126.51, 1084.5, 1108.5, 43780, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (181, '2026-02-12', 1123, 4817.82, -0.12, 1135, 1136.5, 1115.35, 1123, 24712, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (182, '2026-02-11', 1124.3, 4823.4, 0.65, 1123.5, 1128.1, 1115, 1124.3, 28974, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (183, '2026-02-10', 1117, 4792.08, -0.16, 1119.5, 1130.8, 1114.5, 1117, 31460, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (184, '2026-02-09', 1118.8, 4799.81, 2.55, 1095.31, 1130.88, 1092, 1118.8, 47556, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (185, '2026-02-06', 1091, 4680.54, -1.36, 1092, 1102.15, 1048.88, 1091, 60490, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (186, '2026-02-05', 1106, 4744.89, -2.99, 1133.63, 1136, 1077, 1106, 61992, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (187, '2026-02-04', 1140.03, 4890.89, 3.96, 1109, 1140.8, 1096, 1140.03, 69688, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (188, '2026-02-03', 1096.6, 4704.57, 6.78, 1063, 1096.8, 1032.99, 1096.6, 53896, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (189, '2026-02-02', 1027, 4405.97, -11.77, 1155.03, 1156.01, 1004.59, 1027, 86250, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (190, '2026-01-30', 1164, 4993.72, -6.54, 1239.53, 1248.52, 1140.41, 1164, 163308, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (191, '2026-01-29', 1245.4, 5342.94, 5.23, 1180.44, 1255, 1177.25, 1245.4, 109490, '2026-06-30 14:38:17');
INSERT INTO `gold_prices` VALUES (192, '2026-01-28', 1183.51, 5077.42, 3.54, 1142.03, 1185.5, 1130, 1183.51, 77772, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (193, '2026-01-27', 1143, 4903.63, -0.11, 1142, 1148.03, 1125, 1143, 109368, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (194, '2026-01-26', 1144.3, 4909.2, 3.07, 1104, 1145.6, 1100.25, 1144.3, 82850, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (195, '2026-01-23', 1110.2, 4762.91, 2.46, 1084, 1113.18, 1080.41, 1110.2, 54268, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (196, '2026-01-22', 1083.5, 4648.36, -0.24, 1089.96, 1093.8, 1069.28, 1083.5, 57076, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (197, '2026-01-21', 1086.1, 4659.52, 2.87, 1058.95, 1095.79, 1054.5, 1086.1, 95478, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (198, '2026-01-20', 1055.77, 4529.4, 1.03, 1044.42, 1056.7, 1042.74, 1055.77, 45718, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (199, '2026-01-19', 1045, 4483.19, 1.32, 1033.65, 1048.8, 1017.86, 1045, 48810, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (200, '2026-01-16', 1031.4, 4424.85, -0.23, 1034, 1034.5, 1026, 1031.4, 40854, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (201, '2026-01-15', 1033.8, 4435.14, -0.37, 1037, 1039.7, 1026.58, 1033.8, 45450, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (202, '2026-01-14', 1037.6, 4451.45, 1.15, 1026, 1038.09, 1024.21, 1037.6, 66216, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (203, '2026-01-13', 1025.79, 4400.78, 0.36, 1022.07, 1031.5, 1022, 1025.79, 58002, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (204, '2026-01-12', 1022.12, 4385.04, 1.91, 1003.2, 1028, 1000.2, 1022.12, 57430, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (205, '2026-01-09', 1003, 4303.01, 0.72, 993, 1004.1, 990.2, 1003, 32426, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (206, '2026-01-08', 995.86, 4272.38, -0.34, 997, 1002, 991.28, 995.86, 48788, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (207, '2026-01-07', 999.22, 4286.79, -0.3, 1003, 1007.66, 995.13, 999.22, 63134, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (208, '2026-01-06', 1002.2, 4299.58, 0.96, 992.6, 1004.62, 988.51, 1002.2, 44252, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (209, '2026-01-05', 992.69, 4258.78, 1.9, 987.26, 993.76, 986.01, 992.69, 44012, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (210, '2026-01-01', 974.21, 4179.5, 0, 986.5, 989.5, 960.75, 974.21, 67710, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (211, '2025-12-31', 974.21, 4179.5, -0.81, 986.5, 989.5, 960.75, 974.21, 67710, '2026-06-30 14:38:18');
INSERT INTO `gold_prices` VALUES (212, '2025-12-30', 982.2, 4213.77, -2.27, 1000.8, 1003.69, 969.31, 982.2, 95822, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (213, '2025-12-29', 1005, 4311.59, -0.35, 1011.08, 1017, 1000, 1005, 57238, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (214, '2025-12-26', 1008.52, 4326.69, 0.54, 1003.49, 1017.19, 1002.2, 1008.52, 51524, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (215, '2025-12-25', 1003.1, 4303.44, -0.39, 1008, 1009, 998.18, 1003.1, 28920, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (216, '2025-12-24', 1007.05, 4320.38, 0.06, 1008, 1016.72, 994.97, 1007.05, 55632, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (217, '2025-12-23', 1006.45, 4317.81, 1.45, 991.07, 1011.65, 989.99, 1006.45, 62062, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (218, '2025-12-22', 992.1, 4256.25, 1.66, 975, 994.8, 973.1, 992.1, 59384, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (219, '2025-12-19', 975.9, 4186.75, 0.14, 973.5, 981.5, 969.14, 975.9, 48286, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (220, '2025-12-18', 974.52, 4180.83, 0.18, 972, 977.2, 971.45, 974.52, 42672, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (221, '2025-12-17', 972.8, 4173.45, 0.84, 964.03, 977.21, 964, 972.8, 49760, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (222, '2025-12-16', 964.7, 4138.7, -1.26, 977.2, 977.86, 962.31, 964.7, 69962, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (223, '2025-12-15', 977.05, 4191.68, 1.27, 976, 979.32, 959.36, 977.05, 77786, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (224, '2025-12-12', 964.8, 4139.13, 1.32, 951.5, 965.85, 951, 964.8, 51038, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (225, '2025-12-11', 952.21, 4085.11, 0.1, 950, 961.54, 948.77, 952.21, 33596, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (226, '2025-12-10', 951.3, 4081.21, 0.49, 950.9, 954.02, 947.46, 951.3, 28814, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (227, '2025-12-09', 946.7, 4061.47, -0.71, 953.5, 953.5, 944.5, 946.7, 35824, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (228, '2025-12-08', 953.5, 4090.65, -0.26, 955.03, 961.29, 949.68, 953.5, 43378, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (229, '2025-12-05', 956.01, 4101.41, 0.81, 950.39, 956.7, 947.67, 956.01, 29878, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (230, '2025-12-04', 948.3, 4068.34, -0.18, 951, 958.52, 945.35, 948.3, 41664, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (231, '2025-12-03', 949.99, 4075.59, -0.49, 950.61, 957.18, 944.5, 949.99, 26942, '2026-06-30 14:38:19');
INSERT INTO `gold_prices` VALUES (232, '2025-12-02', 954.65, 4095.58, -0.37, 958.27, 962, 950, 954.65, 45456, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (233, '2025-12-01', 958.2, 4110.81, 1.14, 945.5, 962.28, 943, 958.2, 60628, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (234, '2025-11-28', 947.42, 4064.56, 0.46, 942, 949.9, 940.8, 947.42, 30246, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (235, '2025-11-27', 943.1, 4046.03, 0.21, 945.5, 945.5, 938.04, 943.1, 46178, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (236, '2025-11-26', 941.1, 4037.45, 0.05, 939.6, 945.63, 934.53, 941.1, 57208, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (237, '2025-11-25', 940.6, 4035.3, 1.58, 928.82, 944.7, 928.6, 940.6, 61774, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (238, '2025-11-24', 926, 3972.67, 0.37, 922.96, 935.02, 922.96, 926, 53158, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (239, '2025-11-21', 922.6, 3958.08, -0.8, 928.02, 938, 921, 922.6, 50498, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (240, '2025-11-20', 930, 3989.83, -0.42, 939.9, 943.18, 925, 930, 51966, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (241, '2025-11-19', 933.9, 4006.56, 2.03, 923, 936, 920.29, 933.9, 62688, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (242, '2025-11-18', 915.31, 3926.81, -1.61, 930.22, 933.06, 915.31, 915.31, 59742, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (243, '2025-11-17', 930.3, 3991.12, -1.87, 942.06, 945.06, 919.28, 930.3, 82068, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (244, '2025-11-14', 948, 4067.05, -1.12, 961, 964.65, 947, 948, 45922, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (245, '2025-11-13', 958.74, 4113.13, 1.51, 945, 960.45, 943.49, 958.74, 66608, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (246, '2025-11-12', 944.5, 4052.04, -0.21, 948.5, 949.22, 938.16, 944.5, 51666, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (247, '2025-11-11', 946.5, 4060.62, 1.45, 936.5, 950.65, 933.93, 946.5, 63048, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (248, '2025-11-10', 933, 4002.7, 1.71, 918, 934.15, 913.3, 933, 51204, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (249, '2025-11-07', 917.27, 3935.21, -0.01, 920.5, 921, 909, 917.27, 37088, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (250, '2025-11-06', 917.4, 3935.77, 0.87, 909.8, 918.3, 908.5, 917.4, 40590, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (251, '2025-11-05', 909.5, 3901.88, -0.68, 915.35, 916, 901.75, 909.5, 59552, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (252, '2025-11-04', 915.75, 3928.69, -0.43, 917.9, 922.62, 909.4, 915.75, 64372, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (253, '2025-11-03', 919.7, 3945.64, -0.14, 918.61, 924.8, 906, 919.7, 67556, '2026-06-30 14:38:20');
INSERT INTO `gold_prices` VALUES (254, '2025-10-31', 921, 3951.22, 1.49, 907.28, 923.45, 906.28, 921, 54322, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (255, '2025-10-30', 907.5, 3893.3, -0.5, 917.35, 918.66, 894.02, 907.5, 57302, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (256, '2025-10-29', 912.1, 3913.03, 1.72, 895.8, 913, 890.4, 912.1, 52130, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (257, '2025-10-28', 896.68, 3846.88, -3.6, 920.5, 926.49, 895.1, 896.68, 67744, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (258, '2025-10-27', 930.2, 3990.69, -0.51, 931.88, 946.5, 928, 930.2, 55720, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (259, '2025-10-24', 935, 4011.28, -0.54, 940.06, 949.84, 933.92, 935, 55614, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (260, '2025-10-23', 940.05, 4032.94, -0.89, 924.14, 945.7, 921.62, 940.05, 63090, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (261, '2025-10-22', 948.5, 4069.2, -3.9, 973, 973.35, 931, 948.5, 99064, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (262, '2025-10-21', 986.97, 4234.24, 1.36, 978, 999, 977, 986.97, 87030, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (263, '2025-10-20', 973.7, 4177.31, -2.15, 980.07, 989.92, 959.17, 973.7, 71848, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (264, '2025-10-17', 995.1, 4269.12, 2.88, 968.99, 999.96, 965.8, 995.1, 84604, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (265, '2025-10-16', 967.25, 4149.64, 0.92, 958, 969.08, 954.2, 967.25, 87610, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (266, '2025-10-15', 958.4, 4111.67, 1.97, 941, 958.8, 931, 958.4, 55176, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (267, '2025-10-14', 939.9, 4032.3, 1.46, 925.53, 962, 925.5, 939.9, 94894, '2026-06-30 14:38:21');
INSERT INTO `gold_prices` VALUES (268, '2025-10-13', 926.4, 3974.38, 3.19, 902, 926.5, 898.8, 926.4, 63730, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (269, '2025-10-10', 897.8, 3851.69, -1.5, 913.5, 917.96, 895.1, 897.8, 71242, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (270, '2025-10-09', 911.5, 3910.46, 4.59, 914.1, 915.89, 900.31, 911.5, 51446, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (271, '2025-09-30', 871.5, 3738.86, 1.04, 864.7, 875.8, 861.18, 871.5, 48604, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (272, '2025-09-29', 862.5, 3700.24, 1.14, 853, 863.5, 851.01, 862.5, 61916, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (273, '2025-09-26', 852.8, 3658.63, 0.09, 853, 854.3, 846.66, 852.8, 50644, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (274, '2025-09-25', 852, 3655.2, -0.5, 855.5, 856.46, 847.66, 852, 53524, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (275, '2025-09-24', 856.3, 3673.65, 0.81, 854.58, 856.7, 848.92, 856.3, 48028, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (276, '2025-09-23', 849.45, 3644.26, 1.14, 841.2, 850.72, 839.02, 849.45, 53156, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (277, '2025-09-22', 839.9, 3603.29, 1.68, 825.81, 841.4, 824.82, 839.9, 45222, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (278, '2025-09-19', 826, 3543.65, 0.19, 827.5, 828.5, 822.02, 826, 46932, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (279, '2025-09-18', 824.45, 3537, -0.67, 830.55, 835.6, 821.87, 824.45, 49462, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (280, '2025-09-17', 830, 3560.81, -0.99, 838.2, 839.7, 830, 830, 57144, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (281, '2025-09-16', 838.3, 3596.42, 1.19, 829.48, 838.79, 828, 838.3, 43660, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (282, '2025-09-15', 828.46, 3554.21, -0.22, 830, 831.7, 825.35, 828.46, 33778, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (283, '2025-09-12', 830.3, 3562.1, 0.52, 824.52, 831.66, 823.64, 830.3, 51318, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (284, '2025-09-11', 826, 3543.65, -0.48, 830.31, 832.8, 825.42, 826, 36270, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (285, '2025-09-10', 829.97, 3560.69, -0.22, 830.04, 836.95, 824.07, 829.97, 49162, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (286, '2025-09-09', 831.84, 3568.71, 1.32, 822.5, 833.62, 821.21, 831.84, 62614, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (287, '2025-09-08', 821, 3522.2, 1.16, 811.25, 821.87, 810.17, 821, 63934, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (288, '2025-09-05', 811.55, 3481.66, 0.32, 810.5, 813.64, 807.5, 811.55, 37212, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (289, '2025-09-04', 809, 3470.72, -0.12, 812.5, 818.31, 803.88, 809, 73492, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (290, '2025-09-03', 810, 3475.01, 1.27, 802, 812.66, 798.1, 810, 70262, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (291, '2025-09-02', 799.88, 3431.6, 0.68, 795, 805.38, 794.4, 799.88, 51864, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (292, '2025-09-01', 794.5, 3408.51, 1.66, 781.6, 798.35, 781.35, 794.5, 64412, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (293, '2025-08-29', 781.51, 3352.79, 0.21, 781.27, 782.5, 779.03, 781.51, 27326, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (294, '2025-08-28', 779.84, 3345.62, 0.29, 778.01, 781.4, 777.32, 779.84, 30942, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (295, '2025-08-27', 777.6, 3336.01, 0.1, 777.84, 779.89, 776.67, 777.6, 27306, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (296, '2025-08-26', 776.8, 3332.58, 0.18, 776.3, 778.8, 775, 776.8, 27558, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (297, '2025-08-25', 775.4, 3326.57, 0.52, 770.18, 778.33, 769.3, 775.4, 31936, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (298, '2025-08-22', 771.4, 3309.41, -0.03, 771.5, 773.9, 769.77, 771.4, 21306, '2026-06-30 14:38:22');
INSERT INTO `gold_prices` VALUES (299, '2025-08-21', 771.65, 3310.48, 0.24, 771.66, 774.04, 771.1, 771.65, 19030, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (300, '2025-08-20', 769.8, 3302.55, -0.34, 771.99, 772.81, 767.32, 769.8, 30080, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (301, '2025-08-19', 772.46, 3313.96, -0.29, 774.2, 774.2, 770.8, 772.46, 21362, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (302, '2025-08-18', 774.7, 3323.57, 0.22, 772.6, 775.31, 770.41, 774.7, 22224, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (303, '2025-08-15', 773, 3316.28, -0.27, 773.8, 774, 770, 773, 23234, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (304, '2025-08-14', 775.1, 3325.29, 0, 775.59, 776.88, 773.55, 775.1, 22284, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (305, '2025-08-13', 775.1, 3325.29, 0.25, 773.4, 775.28, 770.22, 775.1, 32602, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (306, '2025-08-12', 773.2, 3317.13, -0.26, 774.48, 775.27, 772, 773.2, 32784, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (307, '2025-08-11', 775.25, 3325.93, -1.02, 781.98, 784.7, 775.05, 775.25, 40398, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (308, '2025-08-08', 783.2, 3360.04, 0.15, 779.6, 784.45, 778.8, 783.2, 33164, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (309, '2025-08-07', 782, 3354.89, 0.36, 778.1, 782.3, 776.78, 782, 31738, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (310, '2025-08-06', 779.2, 3342.88, -0.1, 776.9, 781.7, 775.17, 779.2, 29226, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (311, '2025-08-05', 780, 3346.31, 0.57, 778.9, 781.78, 777.01, 780, 34196, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (312, '2025-08-04', 775.6, 3327.43, 1.12, 768.2, 777.6, 768.01, 775.6, 47492, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (313, '2025-08-01', 767, 3290.54, 0.05, 768, 769.02, 764.78, 767, 24784, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (314, '2025-07-31', 766.58, 3288.73, -0.37, 770.8, 770.8, 763.21, 766.58, 32458, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (315, '2025-07-30', 769.4, 3300.83, 0.31, 767.5, 771.2, 767.22, 769.4, 26258, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (316, '2025-07-29', 767.05, 3290.75, -0.59, 771, 771.29, 764.16, 767.05, 37834, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (317, '2025-07-28', 771.6, 3310.27, -0.21, 770.6, 771.84, 767, 771.6, 34706, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (318, '2025-07-25', 773.2, 3317.13, -0.25, 772.5, 775.25, 770.5, 773.2, 29664, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (319, '2025-07-24', 775.1, 3325.29, -1.65, 788, 788.3, 773.71, 775.1, 46624, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (320, '2025-07-23', 788.11, 3381.1, 1.04, 781.8, 789, 780.5, 788.11, 61076, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (321, '2025-07-22', 780.01, 3346.35, 0.39, 778.8, 783, 778.11, 780.01, 49546, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (322, '2025-07-21', 777, 3333.44, 0.46, 775.5, 778.19, 774.01, 777, 40260, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (323, '2025-07-18', 773.48, 3318.34, 0.35, 770.2, 773.5, 767.3, 773.48, 24176, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (324, '2025-07-17', 770.78, 3306.75, -0.18, 772.04, 778.23, 769.54, 770.78, 31414, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (325, '2025-07-16', 772.2, 3312.84, -0.5, 774.1, 775, 769.68, 772.2, 27070, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (326, '2025-07-15', 776.1, 3329.58, -0.14, 776, 777, 771.8, 776.1, 30068, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (327, '2025-07-14', 777.21, 3334.34, 1.04, 771.74, 777.5, 770.45, 777.21, 38158, '2026-06-30 14:38:23');
INSERT INTO `gold_prices` VALUES (328, '2025-07-11', 769.2, 3299.97, -0, 768, 771.67, 766.4, 769.2, 32652, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (329, '2025-07-10', 769.21, 3300.02, 0.76, 761.13, 769.8, 761.13, 769.21, 26330, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (330, '2025-07-09', 763.4, 3275.09, -1.05, 770.3, 771, 761.46, 763.4, 38972, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (331, '2025-07-08', 771.5, 3309.84, 0.47, 766.1, 772.79, 764.55, 771.5, 28986, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (332, '2025-07-07', 767.87, 3294.27, -0.5, 771.5, 772.5, 765.39, 767.87, 38836, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (333, '2025-07-04', 771.76, 3310.96, -0.51, 774.44, 774.79, 767.12, 771.76, 39244, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (334, '2025-07-03', 775.71, 3327.9, 0.71, 773.38, 777.71, 771.88, 775.71, 31568, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (335, '2025-07-02', 770.22, 3304.35, -0.23, 774.5, 776, 770.12, 770.22, 29774, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (336, '2025-07-01', 772, 3311.99, 1.01, 760.5, 772.37, 760.5, 772, 39118, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (337, '2025-06-30', 764.3, 3278.95, 0.15, 763, 764.3, 755.8, 764.3, 57766, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (338, '2025-06-27', 763.15, 3274.02, -1.31, 771.75, 773.18, 761.99, 763.15, 38222, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (339, '2025-06-26', 773.31, 3317.61, 0.21, 769, 773.31, 767.65, 773.31, 30338, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (340, '2025-06-25', 771.7, 3310.7, 0.38, 769.11, 771.8, 762.33, 771.7, 35850, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (341, '2025-06-24', 768.75, 3298.04, -1.19, 782.5, 784.3, 767.03, 768.75, 51470, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (342, '2025-06-23', 778, 3337.73, 0.14, 775, 781, 773.8, 778, 36698, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (343, '2025-06-20', 776.95, 3333.22, -0.04, 780.5, 781.5, 774.29, 776.95, 37966, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (344, '2025-06-19', 777.25, 3334.51, -0.58, 782.8, 785.6, 776.3, 777.25, 40164, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (345, '2025-06-18', 781.79, 3353.99, -0.12, 783.54, 785.3, 778.5, 781.79, 28124, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (346, '2025-06-17', 782.75, 3358.11, -0.65, 788, 789.24, 779.11, 782.75, 40822, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (347, '2025-06-16', 787.9, 3380.2, -0.43, 791.5, 796.84, 787.4, 787.9, 53136, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (348, '2025-06-13', 791.3, 3394.79, 1.41, 782, 797.7, 781.5, 791.3, 71924, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (349, '2025-06-12', 780.3, 3347.59, 0.74, 773.5, 783.3, 771.11, 780.3, 50430, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (350, '2025-06-11', 774.6, 3323.14, 0.22, 774, 776.36, 771, 774.6, 38634, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (351, '2025-06-10', 772.9, 3315.85, 0.12, 770.45, 773.8, 766.31, 772.9, 50072, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (352, '2025-06-09', 772, 3311.99, -1, 778.5, 780, 763.99, 772, 46744, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (353, '2025-06-06', 779.79, 3345.41, -0.15, 785, 785.62, 773.39, 779.79, 52784, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (354, '2025-06-05', 781, 3350.6, 0.16, 777.59, 784.2, 776.79, 781, 38196, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (355, '2025-06-04', 779.75, 3345.24, 0.21, 778.72, 782.2, 774.19, 779.75, 42944, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (356, '2025-06-03', 778.1, 3338.16, 1.33, 785.02, 787.05, 778, 778.1, 65402, '2026-06-30 14:38:24');
INSERT INTO `gold_prices` VALUES (357, '2025-05-30', 767.91, 3294.44, 0.71, 767.08, 772.56, 764.5, 767.91, 47430, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (358, '2025-05-29', 762.5, 3271.23, -0.83, 769, 770.4, 756.3, 762.5, 45904, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (359, '2025-05-28', 768.9, 3298.69, 0.07, 765, 770.49, 764.47, 768.9, 48096, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (360, '2025-05-27', 768.4, 3296.54, -0.72, 773.8, 777.5, 767.33, 768.4, 61308, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (361, '2025-05-26', 773.98, 3320.48, -0.21, 778, 783.19, 773.77, 773.98, 61062, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (362, '2025-05-23', 775.6, 3327.43, -0.27, 774.38, 777, 767.27, 775.6, 48148, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (363, '2025-05-22', 777.7, 3336.44, 0.5, 773.5, 781.87, 769.5, 777.7, 60470, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (364, '2025-05-21', 773.8, 3319.71, 2.83, 757.1, 775.5, 755.53, 773.8, 80624, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (365, '2025-05-20', 752.5, 3228.33, -0.25, 755.29, 756.38, 750.16, 752.5, 49174, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (366, '2025-05-19', 754.37, 3236.35, 0.95, 737, 758, 735.65, 754.37, 51646, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (367, '2025-05-16', 747.28, 3205.93, 1.61, 741.74, 755.5, 741.74, 747.28, 64128, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (368, '2025-05-15', 735.47, 3155.27, -3.05, 755.14, 755.67, 729.66, 735.47, 79414, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (369, '2025-05-14', 758.6, 3254.5, -0.63, 761, 764.75, 757, 758.6, 56790, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (370, '2025-05-13', 763.4, 3275.09, 0.69, 755, 764.68, 752.85, 763.4, 76248, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (371, '2025-05-12', 758.2, 3252.78, -3.41, 786.5, 788.59, 756.82, 758.2, 81162, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (372, '2025-05-09', 785, 3367.76, -0.32, 789.9, 793.58, 773.96, 785, 65384, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (373, '2025-05-08', 787.5, 3378.48, -1.41, 797, 805.5, 785.18, 787.5, 97666, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (374, '2025-05-07', 798.78, 3426.88, 0.73, 794.15, 804.47, 791.15, 798.78, 67566, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (375, '2025-05-06', 792.97, 3401.95, 1.73, 780.82, 797.35, 780.82, 792.97, 65320, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (376, '2025-04-30', 779.5, 3344.16, -0.29, 781.69, 786, 778.47, 779.5, 31770, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (377, '2025-04-29', 781.8, 3354.03, 0.46, 780.7, 792, 778.92, 781.8, 58706, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (378, '2025-04-28', 778.2, 3338.59, -0.84, 784.6, 789, 775.65, 778.2, 68346, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (379, '2025-04-25', 784.8, 3366.9, -1.08, 793.6, 800, 780.9, 784.8, 65020, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (380, '2025-04-24', 793.4, 3403.8, 0.92, 786.7, 802.87, 773.03, 793.4, 108798, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (381, '2025-04-23', 786.18, 3372.82, -4.88, 824.43, 826.96, 781.35, 786.18, 111776, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (382, '2025-04-22', 826.5, 3545.8, 2.8, 805.5, 833.79, 804.96, 826.5, 124468, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (383, '2025-04-21', 803.98, 3449.19, 2.14, 788, 803.98, 786.7, 803.98, 63642, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (384, '2025-04-18', 787.1, 3376.77, -0.18, 787.99, 790.2, 776.6, 787.1, 38420, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (385, '2025-04-17', 788.48, 3382.69, 0.99, 782.78, 795.4, 780.1, 788.48, 74514, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (386, '2025-04-16', 780.75, 3349.53, 2.5, 761.31, 781, 760.79, 780.75, 56632, '2026-06-30 14:38:25');
INSERT INTO `gold_prices` VALUES (387, '2025-04-15', 761.71, 3267.84, -0.1, 761.22, 763.56, 755.88, 761.71, 39928, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (388, '2025-04-14', 762.47, 3271.1, 0.63, 759.97, 764.95, 755.62, 762.47, 59868, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (389, '2025-04-11', 757.7, 3250.64, 2.32, 740.44, 761.85, 738.85, 757.7, 64976, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (390, '2025-04-10', 740.52, 3176.93, 1.76, 730.01, 743.9, 726.23, 740.52, 61000, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (391, '2025-04-09', 727.73, 3122.06, 1.41, 719, 728, 714.97, 727.73, 76830, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (392, '2025-04-08', 717.6, 3078.6, 0.57, 716, 719.38, 708.9, 717.6, 69454, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (393, '2025-04-07', 713.5, 3061.01, -3.45, 703.8, 726.03, 700.25, 713.5, 54032, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (394, '2025-04-03', 739, 3170.41, 0.98, 733.5, 746.3, 730.1, 739, 60530, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (395, '2025-04-02', 731.8, 3139.52, -0.53, 735, 736.78, 729.1, 731.8, 48508, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (396, '2025-04-01', 735.7, 3156.25, 0.78, 729, 738.26, 724.8, 735.7, 63980, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (397, '2025-03-31', 730.01, 3131.84, 1.29, 719.02, 730.6, 717.8, 730.01, 51530, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (398, '2025-03-28', 720.7, 3091.9, 1.66, 713, 721.62, 709.83, 720.7, 44234, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (399, '2025-03-27', 708.95, 3041.49, 0.22, 707.99, 709.6, 704.95, 708.95, 22506, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (400, '2025-03-26', 707.4, 3034.84, 0.41, 705.88, 708.3, 704.23, 707.4, 30690, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (401, '2025-03-25', 704.49, 3022.36, -0.19, 706, 706.26, 702.1, 704.49, 21898, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (402, '2025-03-24', 705.8, 3027.98, -0.01, 706.8, 707.44, 699.66, 705.8, 31724, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (403, '2025-03-21', 705.9, 3028.41, -0.42, 708.91, 709.56, 704.6, 705.9, 42146, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (404, '2025-03-20', 708.9, 3041.28, 0.23, 707, 710.38, 703.3, 708.9, 44446, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (405, '2025-03-19', 707.3, 3034.41, 1.1, 702, 708.4, 701.96, 707.3, 49428, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (406, '2025-03-18', 699.62, 3001.47, 0.68, 695.7, 700.99, 694, 699.62, 47612, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (407, '2025-03-17', 694.9, 2981.22, 0.3, 694.99, 696.5, 692.5, 694.9, 29862, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (408, '2025-03-14', 692.8, 2972.21, 1.32, 686.2, 696.97, 685.23, 692.8, 52316, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (409, '2025-03-13', 683.8, 2933.6, 0.7, 679.14, 685.5, 678.31, 683.8, 38038, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (410, '2025-03-12', 679.02, 2913.09, 0.45, 679, 679.98, 677.11, 679.02, 28258, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (411, '2025-03-11', 676, 2900.13, -0.81, 679.47, 680.15, 674.5, 676, 32314, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (412, '2025-03-10', 681.5, 2923.73, 0.32, 679.15, 681.6, 676.95, 681.5, 35650, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (413, '2025-03-07', 679.3, 2914.29, -0.01, 676.43, 680.2, 676.25, 679.3, 34834, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (414, '2025-03-06', 679.35, 2914.51, -0.23, 680.7, 681.3, 675.01, 679.35, 27742, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (415, '2025-03-05', 680.9, 2921.15, 0.36, 678.8, 682.2, 677.29, 680.9, 38992, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (416, '2025-03-04', 678.48, 2910.77, 1.09, 673.1, 678.5, 672.52, 678.48, 37330, '2026-06-30 14:38:26');
INSERT INTO `gold_prices` VALUES (417, '2025-03-03', 671.18, 2879.45, 0.13, 671.94, 672.33, 664.65, 671.18, 38978, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (418, '2025-02-28', 670.3, 2875.68, -0.84, 674.5, 677.13, 669.33, 670.3, 54768, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (419, '2025-02-27', 676, 2900.13, -0.51, 679.99, 681.52, 674.75, 676, 39514, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (420, '2025-02-26', 679.46, 2914.98, -0.85, 685.1, 685.6, 674.09, 679.46, 46270, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (421, '2025-02-25', 685.29, 2939.99, -0.02, 687.49, 688.3, 682.95, 685.29, 43440, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (422, '2025-02-24', 685.45, 2940.68, 0.34, 681.16, 685.6, 681.16, 685.45, 38222, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (423, '2025-02-21', 683.11, 2930.64, -0.8, 688.1, 688.2, 681, 683.11, 50056, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (424, '2025-02-20', 688.62, 2954.27, 0.32, 686.9, 688.91, 683.14, 688.62, 33068, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (425, '2025-02-19', 686.45, 2944.97, 0.59, 682.47, 688.8, 681.8, 686.45, 30860, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (426, '2025-02-18', 682.45, 2927.8, 0.95, 677.4, 682.46, 676.16, 682.45, 38346, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (427, '2025-02-17', 676, 2900.13, -1.44, 685.3, 686, 673.4, 676, 59146, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (428, '2025-02-14', 685.9, 2942.61, 0.34, 683.5, 686.95, 682.48, 685.9, 26224, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (429, '2025-02-13', 683.57, 2932.61, 0.55, 677.99, 684.92, 674.05, 683.57, 44820, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (430, '2025-02-12', 679.84, 2916.61, -0.51, 681.6, 683.45, 675.84, 679.84, 45086, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (431, '2025-02-11', 683.3, 2931.45, 0.61, 681.7, 690.28, 678, 683.3, 65132, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (432, '2025-02-10', 679.17, 2913.73, 1.59, 669, 679.17, 666.36, 679.17, 49752, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (433, '2025-02-07', 668.55, 2868.17, 0.28, 668.25, 669.5, 662.17, 668.55, 29000, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (434, '2025-02-06', 666.66, 2860.06, -0.11, 669, 671.5, 665.78, 666.66, 33924, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (435, '2025-02-05', 667.39, 2863.2, 3.87, 665.71, 668.66, 663.85, 667.39, 30732, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (436, '2025-01-27', 642.5, 2756.41, -0.48, 646.8, 648.8, 642.5, 642.5, 16214, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (437, '2025-01-24', 645.6, 2769.71, 0.25, 643.9, 647.14, 639.98, 645.6, 34248, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (438, '2025-01-23', 644, 2762.85, 0.08, 643.4, 645.09, 641, 644, 38686, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (439, '2025-01-22', 643.5, 2760.7, 0.81, 637.05, 646.06, 636.89, 643.5, 43698, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (440, '2025-01-21', 638.32, 2738.48, 0.18, 636.5, 638.4, 631.31, 638.32, 28352, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (441, '2025-01-20', 637.15, 2733.46, -0.05, 637.85, 638.8, 632, 637.15, 33644, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (442, '2025-01-17', 637.46, 2734.79, 0.14, 638.42, 641, 637.1, 637.46, 41014, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (443, '2025-01-16', 636.59, 2731.06, 0.35, 635.1, 638, 632.78, 636.59, 32840, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (444, '2025-01-15', 634.4, 2721.66, 0.7, 630.55, 634.95, 629.08, 634.4, 28120, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (445, '2025-01-14', 630.02, 2702.87, -0.95, 633.51, 634, 629.72, 630.02, 41656, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (446, '2025-01-13', 636.08, 2728.87, 0.3, 634.6, 638, 630.1, 636.08, 38294, '2026-06-30 14:38:27');
INSERT INTO `gold_prices` VALUES (447, '2025-01-10', 634.2, 2720.81, 0.67, 630.7, 634.55, 630.23, 634.2, 25406, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (448, '2025-01-09', 629.99, 2702.74, 0.43, 627, 630.5, 625.7, 629.99, 27194, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (449, '2025-01-08', 627.3, 2691.2, 0.41, 626, 627.34, 624.01, 627.3, 31146, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (450, '2025-01-07', 624.75, 2680.26, 0.13, 625.3, 625.75, 618.42, 624.75, 33542, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (451, '2025-01-06', 623.95, 2676.83, -0.42, 627.54, 627.8, 623.34, 623.95, 27510, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (452, '2025-01-03', 626.6, 2688.2, 1, 623.84, 627.53, 622, 626.6, 32524, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (453, '2025-01-02', 620.4, 2661.6, 0.91, 618.8, 622.5, 618.8, 620.4, 23650, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (454, '2024-12-31', 614.8, 2637.58, -0.23, 615.89, 617.3, 613.4, 614.8, 23754, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (455, '2024-12-30', 616.2, 2643.58, -0.35, 615.82, 617.69, 613.82, 616.2, 21672, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (456, '2024-12-27', 618.35, 2652.81, 0.2, 617.2, 619.67, 616.38, 618.35, 18376, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (457, '2024-12-26', 617.1, 2647.44, 0.13, 616.6, 618.69, 615.21, 617.1, 13956, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (458, '2024-12-25', 616.3, 2644.01, 0.2, 614.4, 617.49, 613.7, 616.3, 15684, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (459, '2024-12-24', 615.1, 2638.86, -0.43, 614.9, 616.11, 613.28, 615.1, 17994, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (460, '2024-12-23', 617.75, 2650.23, 0.9, 611.06, 618.2, 610.5, 617.75, 23622, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (461, '2024-12-20', 612.21, 2626.47, -0.29, 612.8, 616, 607.37, 612.21, 35722, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (462, '2024-12-19', 614, 2634.14, -0.41, 616.56, 617.38, 607, 614, 40022, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (463, '2024-12-18', 616.54, 2645.04, -0.21, 615.6, 618.2, 613.6, 616.54, 26986, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (464, '2024-12-17', 617.85, 2650.66, -0.03, 619.2, 620.75, 616.5, 617.85, 23666, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (465, '2024-12-16', 618.06, 2651.56, -0.51, 618, 621, 616, 618.06, 30564, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (466, '2024-12-13', 621.2, 2665.03, -1.15, 627.2, 628.1, 621.03, 621.2, 30056, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (467, '2024-12-12', 628.4, 2695.92, 0.75, 625.5, 630.17, 623.2, 628.4, 34920, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (468, '2024-12-11', 623.75, 2675.97, 0.73, 619.9, 626.98, 619.9, 623.75, 37360, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (469, '2024-12-10', 619.2, 2656.45, 0.32, 618.06, 622.38, 617.8, 619.2, 37426, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (470, '2024-12-09', 617.2, 2647.87, 0.55, 613.06, 618.5, 611, 617.2, 36344, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (471, '2024-12-06', 613.8, 2633.29, -0.34, 616.33, 617.4, 608.8, 613.8, 26792, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (472, '2024-12-05', 615.9, 2642.3, -0.01, 615.27, 618, 612.83, 615.9, 19164, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (473, '2024-12-04', 615.95, 2642.51, -0.06, 616, 618.7, 614.8, 615.95, 20398, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (474, '2024-12-03', 616.3, 2644.01, 0.6, 615.17, 618.1, 613.05, 616.3, 29950, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (475, '2024-12-02', 612.6, 2628.14, -0.33, 615, 616.38, 607.8, 612.6, 34100, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (476, '2024-11-29', 614.6, 2636.72, 0.56, 612, 616.42, 608.71, 614.6, 32904, '2026-06-30 14:38:28');
INSERT INTO `gold_prices` VALUES (477, '2024-11-28', 611.15, 2621.92, -0.43, 614, 615.2, 605.56, 611.15, 25584, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (478, '2024-11-27', 613.8, 2633.29, 1.17, 609.58, 614.04, 606.63, 613.8, 28986, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (479, '2024-11-26', 606.7, 2602.83, -1.56, 620.44, 620.44, 605, 606.7, 39502, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (480, '2024-11-25', 616.3, 2644.01, -1.19, 625.5, 627.1, 613.96, 616.3, 54274, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (481, '2024-11-22', 623.7, 2675.76, 1.17, 618, 623.9, 615.8, 623.7, 35696, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (482, '2024-11-21', 616.49, 2644.83, 1.37, 609.9, 616.5, 608.6, 616.49, 31334, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (483, '2024-11-20', 608.16, 2609.09, 0.19, 609, 611.62, 606.7, 608.16, 29882, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (484, '2024-11-19', 607, 2604.11, 1.39, 600.25, 608.32, 599.32, 607, 36664, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (485, '2024-11-18', 598.7, 2568.51, 1.13, 594.88, 600.9, 591.51, 598.7, 34272, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (486, '2024-11-15', 592, 2539.76, 0.12, 590.36, 595.36, 590.2, 592, 42574, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (487, '2024-11-14', 591.3, 2536.76, -1.94, 602.7, 604.2, 590.7, 591.3, 44206, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (488, '2024-11-13', 603, 2586.95, 0.05, 601.02, 605.19, 600.67, 603, 32504, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (489, '2024-11-12', 602.7, 2585.67, -1.71, 613, 613, 602.6, 602.7, 41738, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (490, '2024-11-11', 613.2, 2630.71, 0.11, 614.3, 619.7, 612.6, 613.2, 39964, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (491, '2024-11-08', 612.53, 2627.84, 0.41, 610, 617.8, 609, 612.53, 36492, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (492, '2024-11-07', 610.02, 2617.07, -2.4, 622.5, 622.5, 609.17, 610.02, 35576, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (493, '2024-11-06', 625, 2681.34, 0.27, 623.4, 629, 620.5, 625, 32934, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (494, '2024-11-05', 623.31, 2674.09, 0.03, 623.47, 624.79, 619.82, 623.31, 29906, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (495, '2024-11-04', 623.1, 2673.18, -0.66, 627.3, 630.7, 621.48, 623.1, 30792, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (496, '2024-11-01', 627.25, 2690.99, -1.06, 633.65, 634, 622.76, 627.25, 38584, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (497, '2024-10-31', 634, 2719.95, -0.32, 634.99, 636.97, 631.8, 634, 25212, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (498, '2024-10-30', 636.02, 2728.61, 1.07, 628.7, 637.3, 627.5, 636.02, 32102, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (499, '2024-10-29', 629.3, 2699.78, 0.72, 623.45, 629.81, 623.06, 629.3, 30860, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (500, '2024-10-28', 624.78, 2680.39, 0.51, 621.5, 625.7, 620.32, 624.78, 34402, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (501, '2024-10-25', 621.6, 2666.75, -0.19, 623.78, 624.8, 619.2, 621.6, 36852, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (502, '2024-10-24', 622.8, 2671.9, -0.91, 628.3, 628.3, 616.28, 622.8, 41230, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (503, '2024-10-23', 628.5, 2696.35, 0.59, 624.73, 628.5, 623.9, 628.5, 39504, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (504, '2024-10-22', 624.8, 2680.48, 0.19, 625.85, 626.5, 619.5, 624.8, 35494, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (505, '2024-10-21', 623.6, 2675.33, 1.18, 617.8, 624.45, 616, 623.6, 35260, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (506, '2024-10-18', 616.3, 2644.01, 0.67, 610.68, 621, 610.68, 616.3, 43652, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (507, '2024-10-17', 612.21, 2626.47, 0.44, 609.06, 613.35, 608.5, 612.21, 30234, '2026-06-30 14:38:29');
INSERT INTO `gold_prices` VALUES (508, '2024-10-16', 609.5, 2614.84, 1.13, 601.93, 610.05, 601.5, 609.5, 33168, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (509, '2024-10-15', 602.7, 2585.67, 0.42, 600.88, 602.88, 597.5, 602.7, 28932, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (510, '2024-10-14', 600.2, 2574.94, 0.54, 596.8, 602.2, 595.33, 600.2, 34126, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (511, '2024-10-11', 596.99, 2561.17, 1.12, 590.18, 597.36, 589, 596.99, 22288, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (512, '2024-10-10', 590.4, 2532.9, 0.38, 588.6, 590.4, 585.64, 590.4, 24036, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (513, '2024-10-09', 588.14, 2523.2, -0.89, 595, 595.99, 586, 588.14, 31242, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (514, '2024-10-08', 593.4, 2545.77, -0.31, 594.05, 597.45, 592.31, 593.4, 29114, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (515, '2024-09-30', 595.25, 2553.7, -0.22, 597.68, 598.56, 591.54, 595.25, 32856, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (516, '2024-09-27', 596.55, 2559.28, -0.11, 600, 600.79, 594.82, 596.55, 34314, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (517, '2024-09-26', 597.2, 2562.07, 0.23, 596, 599.3, 596, 597.2, 25178, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (518, '2024-09-25', 595.8, 2556.06, 0.64, 591.9, 599.15, 590.7, 595.8, 33114, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (519, '2024-09-24', 592, 2539.76, 0.05, 593, 594.5, 590.78, 592, 29444, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (520, '2024-09-23', 591.7, 2538.47, 0.65, 589.85, 593.7, 586, 591.7, 35264, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (521, '2024-09-20', 587.9, 2522.17, 0.88, 584.96, 588.2, 581.6, 587.9, 32622, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (522, '2024-09-19', 582.8, 2500.29, 0.14, 583.3, 586.13, 578.66, 582.8, 27884, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (523, '2024-09-18', 582, 2496.86, -0.1, 583.51, 584.8, 581.8, 582, 18102, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (524, '2024-09-13', 582.6, 2499.43, 1.37, 574.51, 583.8, 574.22, 582.6, 40256, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (525, '2024-09-12', 574.7, 2465.54, -0.1, 574.68, 574.9, 571.3, 574.7, 21926, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (526, '2024-09-11', 575.3, 2468.12, 0.52, 572.69, 575.5, 571.2, 575.3, 32260, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (527, '2024-09-10', 572.31, 2455.29, 0.48, 570.5, 572.6, 569.44, 572.31, 20900, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (528, '2024-09-09', 569.6, 2443.66, -0.52, 571.06, 574.1, 565.13, 569.6, 30992, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (529, '2024-09-06', 572.6, 2456.53, 0.23, 572.85, 573.6, 570.4, 572.6, 23614, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (530, '2024-09-05', 571.28, 2450.87, 0.69, 568.6, 571.5, 567, 571.28, 27944, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (531, '2024-09-04', 567.36, 2434.05, -0.64, 570.29, 571.5, 566.25, 567.36, 29234, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (532, '2024-09-03', 571.04, 2449.84, 0.13, 570.99, 571.7, 569.22, 571.04, 18878, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (533, '2024-09-02', 570.3, 2446.67, -0.57, 573.1, 574.28, 568.25, 570.3, 34718, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (534, '2024-08-30', 573.59, 2460.78, -0.19, 574.7, 575.77, 571.7, 573.59, 57888, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (535, '2024-08-29', 574.7, 2465.54, 0.24, 572, 575.71, 571, 574.7, 33154, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (536, '2024-08-28', 573.32, 2459.62, -0.21, 574, 576.1, 572.6, 573.32, 30778, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (537, '2024-08-27', 574.5, 2464.68, -0.03, 575.63, 576.36, 572.3, 574.5, 37314, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (538, '2024-08-26', 574.7, 2465.54, 0.69, 572.8, 574.8, 571, 574.7, 30410, '2026-06-30 14:38:30');
INSERT INTO `gold_prices` VALUES (539, '2024-08-23', 570.75, 2448.6, -0.25, 572.6, 572.81, 566.64, 570.75, 26728, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (540, '2024-08-22', 572.2, 2454.82, -0.37, 574, 575.17, 570.72, 572.2, 34244, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (541, '2024-08-21', 574.33, 2463.95, 0.4, 577, 577, 570.43, 574.33, 41912, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (542, '2024-08-20', 572.05, 2454.17, -0.03, 570.6, 573.37, 569.4, 572.05, 30320, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (543, '2024-08-19', 572.2, 2454.82, 1.2, 568.98, 574.32, 568.03, 572.2, 58496, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (544, '2024-08-16', 565.4, 2425.64, 0.02, 567, 567.9, 561.7, 565.4, 23132, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (545, '2024-08-15', 565.3, 2425.21, -0.31, 568.35, 568.35, 560.3, 565.3, 33582, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (546, '2024-08-14', 567.04, 2432.68, -0.13, 567.8, 568.8, 563.74, 567.04, 36294, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (547, '2024-08-13', 567.8, 2435.94, 0.65, 564.03, 570.9, 564.03, 567.8, 30012, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (548, '2024-08-12', 564.15, 2420.28, 0.68, 560.4, 564.15, 558.85, 564.15, 23264, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (549, '2024-08-09', 560.33, 2403.89, 1.03, 558, 561.5, 555.83, 560.33, 30548, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (550, '2024-08-08', 554.6, 2379.31, 0.03, 556, 556.79, 551.8, 554.6, 38340, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (551, '2024-08-07', 554.46, 2378.71, 0.15, 554.93, 555.56, 550, 554.46, 46536, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (552, '2024-08-06', 553.65, 2375.23, -1.26, 548.5, 556.98, 543, 553.65, 60238, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (553, '2024-08-05', 560.7, 2405.48, -1.79, 570, 572.24, 553, 560.7, 69322, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (554, '2024-08-02', 570.93, 2449.37, 0.46, 567.26, 571.5, 566, 570.93, 44282, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (555, '2024-08-01', 568.29, 2438.04, 0.87, 563.5, 570.5, 563, 568.29, 39882, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (556, '2024-07-31', 563.4, 2417.06, 0.89, 558.2, 565.74, 556.6, 563.4, 46918, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (557, '2024-07-30', 558.45, 2395.83, 0.01, 558.4, 559.34, 552.88, 558.45, 27374, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (558, '2024-07-29', 558.4, 2395.61, 0.61, 555.37, 561.2, 554.8, 558.4, 30428, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (559, '2024-07-26', 554.99, 2380.98, 0.54, 550.01, 555.95, 548.15, 554.99, 27326, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (560, '2024-07-25', 552, 2368.16, -2.46, 566.2, 568, 550.5, 552, 51086, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (561, '2024-07-24', 565.95, 2428, 1.06, 562.5, 566.29, 561.05, 565.95, 25484, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (562, '2024-07-23', 560, 2402.48, -0.51, 561.66, 563.47, 558.36, 560, 30358, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (563, '2024-07-22', 562.88, 2414.83, 0.3, 560.3, 563.58, 556.2, 562.88, 39192, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (564, '2024-07-19', 561.2, 2407.63, -2.81, 576, 576.3, 560.01, 561.2, 47188, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (565, '2024-07-18', 577.4, 2477.13, 0, 577.7, 579.8, 572.35, 577.4, 31836, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (566, '2024-07-17', 577.4, 2477.13, 1.16, 571.49, 581.23, 569.8, 577.4, 53146, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (567, '2024-07-16', 570.8, 2448.81, 1.21, 567, 570.89, 565.5, 570.8, 37172, '2026-06-30 14:38:31');
INSERT INTO `gold_prices` VALUES (568, '2024-07-15', 564, 2419.64, 0.14, 563.12, 567.5, 561.5, 564, 25994, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (569, '2024-07-12', 563.2, 2416.21, 0.33, 561, 567.84, 560.75, 563.2, 38818, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (570, '2024-07-11', 561.35, 2408.27, 0.24, 560.94, 562.3, 559, 561.35, 22800, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (571, '2024-07-10', 559.99, 2402.43, 0.83, 555.9, 559.99, 554.35, 559.99, 23572, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (572, '2024-07-09', 555.4, 2382.74, -0.75, 559, 559.8, 554, 555.4, 20038, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (573, '2024-07-08', 559.6, 2400.76, 0.3, 557.45, 563.1, 554.9, 559.6, 32774, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (574, '2024-07-05', 557.95, 2393.68, 0.31, 556.95, 558.05, 555.7, 557.95, 17288, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (575, '2024-07-04', 556.2, 2386.17, 0.43, 554.05, 558, 553.88, 556.2, 27352, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (576, '2024-07-03', 553.8, 2375.88, 0.82, 549, 554, 548.45, 553.8, 24946, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (577, '2024-07-02', 549.31, 2356.62, 0.08, 551.13, 551.6, 548.2, 549.31, 16070, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (578, '2024-07-01', 548.85, 2354.64, -0.14, 550.03, 551.62, 547.47, 548.85, 19008, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (579, '2024-06-28', 549.6, 2357.86, 1.07, 546.5, 549.88, 546.42, 549.6, 28478, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (580, '2024-06-27', 543.78, 2332.89, -0.44, 545.24, 546.75, 541.8, 543.78, 21862, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (581, '2024-06-26', 546.19, 2343.23, -0.58, 550, 550.2, 544.53, 546.19, 30966, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (582, '2024-06-25', 549.35, 2356.79, -0.01, 549.15, 551.3, 548.31, 549.35, 19014, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (583, '2024-06-24', 549.42, 2357.09, -1.3, 558.48, 558.74, 548, 549.42, 21738, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (584, '2024-06-21', 556.65, 2388.11, 0.48, 552.5, 558.8, 552.5, 556.65, 29532, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (585, '2024-06-20', 554, 2376.74, 0.75, 549.41, 554.21, 548.77, 554, 30112, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (586, '2024-06-19', 549.9, 2359.15, 0.53, 547.07, 550.19, 545.98, 549.9, 22486, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (587, '2024-06-18', 547, 2346.71, -0.03, 547.33, 549, 545.8, 547, 17554, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (588, '2024-06-17', 547.18, 2347.48, 0.2, 550.05, 550.78, 546.46, 547.18, 23482, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (589, '2024-06-14', 546.1, 2342.84, 0, 544.8, 547.98, 541.12, 546.1, 19988, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (590, '2024-06-13', 546.09, 2342.8, 0.13, 545.23, 551, 543.64, 546.09, 23268, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (591, '2024-06-12', 545.4, 2339.84, 0.31, 543.45, 546.5, 543.45, 545.4, 15886, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (592, '2024-06-11', 543.74, 2332.72, -2.86, 546.5, 546.5, 541.5, 543.74, 26370, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (593, '2024-06-07', 559.75, 2401.4, 0.17, 557.33, 562, 555.63, 559.75, 25028, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (594, '2024-06-06', 558.81, 2397.37, 1.53, 550.5, 560.83, 550.5, 558.81, 27432, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (595, '2024-06-05', 550.4, 2361.29, -0.47, 548.91, 552.72, 547.12, 550.4, 22670, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (596, '2024-06-04', 553, 2372.45, 0.7, 549.98, 554.74, 549.15, 553, 18416, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (597, '2024-06-03', 549.15, 2355.93, -0.75, 552.1, 556.95, 546, 549.15, 34680, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (598, '2024-05-31', 553.3, 2373.73, 0.34, 551, 554.37, 550.4, 553.3, 18140, '2026-06-30 14:38:32');
INSERT INTO `gold_prices` VALUES (599, '2024-05-30', 551.4, 2365.58, -0.76, 554.02, 554.81, 548.5, 551.4, 25654, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (600, '2024-05-29', 555.6, 2383.6, 0.54, 554, 558, 553.7, 555.6, 21530, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (601, '2024-05-28', 552.6, 2370.73, 0.13, 553, 556.25, 552.5, 552.6, 24074, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (602, '2024-05-27', 551.9, 2367.73, 0.13, 551.17, 553.97, 550, 551.9, 20636, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (603, '2024-05-24', 551.2, 2364.72, -0.91, 557.7, 557.7, 547, 551.2, 21436, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (604, '2024-05-23', 556.25, 2386.39, -2.12, 568.08, 568.5, 553.5, 556.25, 34682, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (605, '2024-05-22', 568.32, 2438.17, -0.12, 570.01, 572.99, 567.8, 568.32, 23012, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (606, '2024-05-21', 569, 2441.09, -0.89, 572.83, 576.5, 567.32, 569, 27452, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (607, '2024-05-20', 574.1, 2462.97, 2.28, 562, 577.8, 561.4, 574.1, 65302, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (608, '2024-05-17', 561.3, 2408.05, 0.12, 559.5, 561.4, 558, 561.3, 25546, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (609, '2024-05-16', 560.6, 2405.05, 0.86, 555.07, 563.33, 554, 560.6, 38472, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (610, '2024-05-15', 555.8, 2384.46, 1, 552.36, 556.38, 551.5, 555.8, 25402, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (611, '2024-05-14', 550.32, 2360.95, -0.41, 551.73, 553.5, 550.32, 550.32, 23412, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (612, '2024-05-13', 552.61, 2370.77, -0.56, 556.38, 557.12, 552.06, 552.61, 30858, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (613, '2024-05-10', 555.7, 2384.03, 2.3, 543.18, 556.3, 543.18, 555.7, 44728, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (614, '2024-05-09', 543.18, 2330.32, -0.11, 544.49, 545.22, 543, 543.18, 19734, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (615, '2024-05-08', 543.78, 2332.89, -0.19, 543.33, 546, 542.54, 543.78, 18868, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (616, '2024-05-07', 544.82, 2337.35, 0.06, 544.14, 547.2, 543.4, 544.82, 25264, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (617, '2024-05-06', 544.49, 2335.94, -0.26, 539.1, 544.49, 538.05, 544.49, 24854, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (618, '2024-04-30', 545.9, 2341.99, -0.58, 549.99, 550.3, 545.69, 545.9, 20906, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (619, '2024-04-29', 549.1, 2355.71, -0.65, 554, 554.32, 548.05, 549.1, 23710, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (620, '2024-04-26', 552.7, 2371.16, 0.91, 548.45, 553, 545.62, 552.7, 23604, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (621, '2024-04-25', 547.7, 2349.71, -0.04, 547.4, 551.98, 544.05, 547.7, 29598, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (622, '2024-04-24', 547.92, 2350.65, 0.74, 543, 549.85, 542.92, 547.92, 39730, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (623, '2024-04-23', 543.88, 2333.32, -2.28, 552.9, 554.2, 542, 543.88, 53298, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (624, '2024-04-22', 556.59, 2387.85, -1.51, 563.96, 567.7, 554.8, 556.59, 36398, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (625, '2024-04-19', 565.15, 2424.57, 0.38, 563.65, 573.3, 560.01, 565.15, 48872, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (626, '2024-04-18', 563, 2415.35, -0.28, 566.59, 568.5, 557.45, 563, 35230, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (627, '2024-04-17', 564.6, 2422.21, 0.25, 564.05, 570.4, 562.5, 564.6, 41454, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (628, '2024-04-16', 563.22, 2416.29, 0.74, 559.01, 568.96, 552.82, 563.22, 40956, '2026-06-30 14:38:33');
INSERT INTO `gold_prices` VALUES (629, '2024-04-15', 559.1, 2398.62, -1.49, 567.3, 582, 557, 559.1, 73308, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (630, '2024-04-12', 567.53, 2434.78, 2.41, 554.08, 568.68, 553, 567.53, 52218, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (631, '2024-04-11', 554.19, 2377.55, -0.59, 556.03, 556.9, 550.68, 554.19, 42422, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (632, '2024-04-10', 557.5, 2391.75, 0.31, 556.23, 559, 553.7, 557.5, 31616, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (633, '2024-04-09', 555.8, 2384.46, 0.25, 553.61, 557.45, 550, 555.8, 49982, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (634, '2024-04-08', 554.4, 2378.45, 3.09, 537.71, 558.68, 537.71, 554.4, 61588, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (635, '2024-04-03', 537.8, 2307.24, 0.82, 534.28, 540.5, 532.6, 537.8, 33888, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (636, '2024-04-02', 533.4, 2288.36, 0, 530.4, 533.99, 527, 533.4, 35854, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (637, '2024-04-01', 533.4, 2288.36, 0.74, 528.21, 533.69, 527, 533.4, 30532, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (638, '2024-03-29', 529.5, 2271.63, 2.13, 520.38, 532.22, 518.5, 529.5, 41928, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (639, '2024-03-28', 518.48, 2224.35, 0.54, 517, 518.77, 515.5, 518.48, 34564, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (640, '2024-03-27', 515.7, 2212.42, 0.58, 517, 517.8, 513.5, 515.7, 32650, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (641, '2024-03-26', 512.75, 2199.77, 0.26, 512, 514.16, 512, 512.75, 26382, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (642, '2024-03-25', 511.4, 2193.98, 0.06, 511.89, 515.35, 510.5, 511.4, 38030, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (643, '2024-03-22', 511.1, 2192.69, -0.7, 514.78, 514.84, 507.75, 511.1, 31734, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (644, '2024-03-21', 514.7, 2208.13, 1.94, 504.2, 515, 503.75, 514.7, 39906, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (645, '2024-03-20', 504.9, 2166.09, 0.18, 503.89, 505.24, 503.49, 504.9, 20770, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (646, '2024-03-19', 504, 2162.23, 0.12, 504.66, 505.5, 503.2, 504, 24744, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (647, '2024-03-18', 503.39, 2159.61, -0.65, 505.85, 506.79, 502.35, 503.39, 28008, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (648, '2024-03-15', 506.7, 2173.81, 0.3, 505.04, 507.07, 503.8, 506.7, 24258, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (649, '2024-03-14', 505.2, 2167.38, 0.12, 505.09, 508.4, 504.8, 505.2, 20680, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (650, '2024-03-13', 504.6, 2164.8, -0.17, 504.8, 506.19, 503, 504.6, 23734, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (651, '2024-03-12', 505.45, 2168.45, -0.38, 507, 508.12, 505.2, 505.45, 26596, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (652, '2024-03-11', 507.4, 2176.82, 0.52, 506.13, 510.47, 503.94, 507.4, 35172, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (653, '2024-03-08', 504.8, 2165.66, -0.04, 507.5, 507.5, 502.08, 504.8, 30146, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (654, '2024-03-07', 505.01, 2166.56, 1.11, 500.17, 506, 499.34, 505.01, 34736, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (655, '2024-03-06', 499.49, 2142.88, 0.62, 497.65, 501.21, 497, 499.49, 22396, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (656, '2024-03-05', 496.4, 2129.62, 1.46, 489.19, 496.5, 489.09, 496.4, 30874, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (657, '2024-03-04', 489.27, 2099.04, 1.28, 484, 490.05, 482.8, 489.27, 36116, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (658, '2024-03-01', 483.1, 2072.57, 0.43, 480.39, 483.25, 479.8, 483.1, 16950, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (659, '2024-02-29', 481.04, 2063.73, 0.17, 479.2, 481.3, 479.2, 481.04, 9088, '2026-06-30 14:38:34');
INSERT INTO `gold_prices` VALUES (660, '2024-02-28', 480.2, 2060.12, -0.17, 481, 481.46, 480.1, 480.2, 10058, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (661, '2024-02-27', 481, 2063.56, 0.15, 479.91, 481, 479.3, 481, 13530, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (662, '2024-02-26', 480.3, 2060.55, 0.44, 478.7, 480.95, 478.7, 480.3, 11330, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (663, '2024-02-23', 478.19, 2051.5, -0.29, 479.41, 479.9, 478, 478.19, 10584, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (664, '2024-02-22', 479.6, 2057.55, 0, 479.5, 480.3, 478.7, 479.6, 8462, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (665, '2024-02-21', 479.6, 2057.55, -0.08, 480.5, 481.1, 479.5, 479.6, 10544, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (666, '2024-02-20', 480, 2059.27, -0.12, 480.21, 480.21, 479.08, 480, 10580, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (667, '2024-02-19', 480.6, 2061.84, 0.12, 478.73, 480.6, 478.61, 480.6, 14086, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (668, '2024-02-09', 480, 2059.27, -0.22, 480.12, 482, 479.85, 480, 3740, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (669, '2024-02-08', 481.06, 2063.81, 0.17, 479.98, 482.2, 479.85, 481.06, 8962, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (670, '2024-02-07', 480.25, 2060.34, 0.19, 479.6, 481.14, 479.01, 480.25, 7254, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (671, '2024-02-06', 479.35, 2056.48, -0.09, 480.02, 480.65, 477, 479.35, 7662, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (672, '2024-02-05', 479.8, 2058.41, -0.79, 483.17, 483.95, 479.8, 479.8, 14578, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (673, '2024-02-02', 483.64, 2074.88, 0.51, 480, 483.73, 480, 483.64, 16510, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (674, '2024-02-01', 481.2, 2064.41, 0.17, 480.51, 482.8, 480.51, 481.2, 13600, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (675, '2024-01-31', 480.39, 2060.94, -0.01, 480.27, 482, 480.11, 480.39, 11942, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (676, '2024-01-30', 480.44, 2061.15, 0.12, 479.01, 480.79, 478.6, 480.44, 10084, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (677, '2024-01-29', 479.85, 2058.62, 0.18, 478.85, 479.96, 477.76, 479.85, 11592, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (678, '2024-01-26', 478.99, 2054.93, 0.59, 476.53, 479, 476.48, 478.99, 10724, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (679, '2024-01-25', 476.2, 2042.96, -0.54, 479.25, 479.25, 476.03, 476.2, 19028, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (680, '2024-01-24', 478.78, 2054.03, -0.11, 478.03, 479.06, 477.75, 478.78, 18202, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (681, '2024-01-23', 479.31, 2056.31, 0.19, 479, 479.66, 477.5, 479.31, 17762, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (682, '2024-01-22', 478.38, 2052.32, -0.52, 481.3, 481.5, 478.1, 478.38, 14924, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (683, '2024-01-19', 480.9, 2063.13, 0.57, 478.1, 480.9, 477.85, 480.9, 15132, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (684, '2024-01-18', 478.19, 2051.5, 0.04, 479, 480.19, 477.5, 478.19, 14620, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (685, '2024-01-17', 478, 2050.69, -1, 481.8, 482.6, 477.66, 478, 26774, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (686, '2024-01-16', 482.85, 2071.49, -0.05, 482.6, 483.15, 482.2, 482.85, 20196, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (687, '2024-01-15', 483.07, 2072.44, 0.58, 480.8, 483.3, 480.8, 483.07, 18890, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (688, '2024-01-12', 480.3, 2060.55, 0.33, 478.62, 480.5, 476.84, 480.3, 12572, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (689, '2024-01-11', 478.7, 2053.69, 0.01, 479.13, 480.1, 478.11, 478.7, 12648, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (690, '2024-01-10', 478.67, 2053.56, -0.13, 479.59, 480.5, 478.4, 478.67, 21666, '2026-06-30 14:38:35');
INSERT INTO `gold_prices` VALUES (691, '2024-01-09', 479.31, 2056.31, -0.23, 479, 480.8, 477.2, 479.31, 17238, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (692, '2024-01-08', 480.4, 2060.98, 0, 479.88, 482.99, 478, 480.4, 22316, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (693, '2024-01-05', 480.4, 2060.98, -0.12, 481.65, 482, 480, 480.4, 11812, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (694, '2024-01-04', 481, 2063.56, -0.1, 479.5, 481.5, 477.6, 481, 19160, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (695, '2024-01-03', 481.5, 2065.7, -0.42, 481.63, 482.69, 480.74, 481.5, 15314, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (696, '2024-01-02', 483.55, 2074.5, 0.74, 479, 483.55, 479, 483.55, 14514, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (697, '2023-12-29', 480, 2059.27, -0.44, 480.32, 481.7, 478.82, 480, 10046, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (698, '2023-12-28', 482.14, 2068.45, 0.16, 481.5, 484.4, 481.5, 482.14, 9982, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (699, '2023-12-27', 481.37, 2065.14, 0.17, 479.85, 482.3, 478.72, 481.37, 13786, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (700, '2023-12-26', 480.54, 2061.58, 0.28, 478.82, 480.6, 478.82, 480.54, 13276, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (701, '2023-12-25', 479.2, 2055.83, 0.19, 480, 481.6, 478.25, 479.2, 15314, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (702, '2023-12-22', 478.3, 2051.97, 0.58, 474.6, 479.75, 474.6, 478.3, 7576, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (703, '2023-12-21', 475.55, 2040.18, -0.13, 475.01, 476.33, 474.32, 475.55, 7796, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (704, '2023-12-20', 476.19, 2042.92, 0.54, 473.42, 476.19, 473.42, 476.19, 11364, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (705, '2023-12-19', 473.63, 2031.94, 0.07, 473.55, 474.3, 472.5, 473.63, 9078, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (706, '2023-12-18', 473.3, 2030.52, -0.17, 474.61, 475.1, 470.5, 473.3, 19928, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (707, '2023-12-15', 474.1, 2033.95, -0.19, 474.16, 475.3, 473, 474.1, 9438, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (708, '2023-12-14', 475, 2037.82, 1.71, 467.7, 475, 466.7, 475, 17664, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (709, '2023-12-13', 467, 2003.49, -0.17, 468, 469.96, 466.7, 467, 19782, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (710, '2023-12-12', 467.8, 2006.93, -0.3, 469.3, 469.6, 466.4, 467.8, 27826, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (711, '2023-12-11', 469.22, 2013.02, -1.03, 474.25, 474.25, 468.2, 469.22, 19948, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (712, '2023-12-08', 474.1, 2033.95, 0.06, 473.73, 475.22, 472.1, 474.1, 10298, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (713, '2023-12-07', 473.8, 2032.67, 0.09, 472.3, 474.59, 472.3, 473.8, 9502, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (714, '2023-12-06', 473.39, 2030.91, 0.02, 472.15, 473.39, 470.7, 473.39, 15864, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (715, '2023-12-05', 473.3, 2030.52, -1.47, 479.4, 479.95, 471.17, 473.3, 15336, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (716, '2023-12-04', 480.35, 2060.77, 1.23, 474.3, 485, 473.4, 480.35, 28332, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (717, '2023-12-01', 474.5, 2035.67, 0.06, 473.6, 475.48, 473.46, 474.5, 7318, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (718, '2023-11-30', 474.2, 2034.38, 0.08, 473.7, 475.3, 473.5, 474.2, 11366, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (719, '2023-11-29', 473.81, 2032.71, 0.58, 471.1, 475.6, 470.36, 473.81, 14098, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (720, '2023-11-28', 471.1, 2021.08, 0.34, 469.8, 471.3, 469, 471.1, 9166, '2026-06-30 14:38:36');
INSERT INTO `gold_prices` VALUES (721, '2023-11-27', 469.5, 2014.22, 0.96, 465.7, 469.91, 465.2, 469.5, 8324, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (722, '2023-11-24', 465.04, 1995.09, 0.08, 463.9, 465.48, 463.9, 465.04, 10480, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (723, '2023-11-23', 464.65, 1993.41, -0.14, 464.8, 467.19, 463.58, 464.65, 11586, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (724, '2023-11-22', 465.3, 1996.2, -0.23, 465.4, 468.73, 464.49, 465.3, 19782, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (725, '2023-11-21', 466.36, 2000.75, 0.16, 465.15, 467, 462.8, 466.36, 14508, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (726, '2023-11-20', 465.63, 1997.62, -1.15, 470.91, 471.69, 465.63, 465.63, 13930, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (727, '2023-11-17', 471.03, 2020.78, 0.04, 469.83, 472.95, 469.83, 471.03, 9548, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (728, '2023-11-16', 470.84, 2019.97, -0.14, 472.72, 472.72, 469.5, 470.84, 8818, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (729, '2023-11-15', 471.5, 2022.8, 0.29, 469.9, 472.7, 469.18, 471.5, 8330, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (730, '2023-11-14', 470.15, 2017.01, 0.37, 467.96, 470.6, 466, 470.15, 9366, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (731, '2023-11-13', 468.44, 2009.67, -0.23, 467.66, 468.85, 465.5, 468.44, 14076, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (732, '2023-11-10', 469.5, 2014.22, 0.49, 466.8, 470.53, 466, 469.5, 9306, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (733, '2023-11-09', 467.21, 2004.4, -0.74, 469.99, 470.69, 467.06, 467.21, 11832, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (734, '2023-11-08', 470.69, 2019.33, -0.09, 470.2, 471.47, 468.63, 470.69, 8010, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (735, '2023-11-07', 471.1, 2021.08, -0.69, 474.21, 475.88, 471.05, 471.1, 10830, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (736, '2023-11-06', 474.35, 2035.03, -0.45, 476.06, 478.3, 474.01, 474.35, 11692, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (737, '2023-11-03', 476.5, 2044.25, 0.11, 476.4, 477, 475.11, 476.5, 8210, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (738, '2023-11-02', 476, 2042.11, 0.25, 476.34, 477.3, 474.81, 476, 8298, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (739, '2023-11-01', 474.8, 2036.96, -0.37, 477.2, 479.5, 474.1, 474.8, 16282, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (740, '2023-10-31', 476.56, 2044.51, -0.01, 476.5, 478.54, 475.68, 476.56, 12090, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (741, '2023-10-30', 476.6, 2044.68, 0.22, 474.7, 480.49, 473.8, 476.6, 16320, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (742, '2023-10-27', 475.54, 2040.13, 0.35, 473.5, 475.6, 471.82, 475.54, 14248, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (743, '2023-10-26', 473.9, 2033.1, 0.52, 472.3, 474.3, 470.2, 473.9, 12592, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (744, '2023-10-25', 471.44, 2022.54, -0.25, 471.3, 472.85, 470.1, 471.44, 6500, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (745, '2023-10-24', 472.6, 2027.52, 0.08, 472.52, 473.45, 471.8, 472.6, 7698, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (746, '2023-10-23', 472.21, 2025.85, -0.39, 473.6, 476.45, 470, 472.21, 12376, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (747, '2023-10-20', 474.05, 2033.74, 1, 470.1, 475.09, 469.44, 474.05, 14590, '2026-06-30 14:38:37');
INSERT INTO `gold_prices` VALUES (748, '2023-10-19', 469.35, 2013.58, 0.6, 468.6, 470.79, 466.7, 469.35, 9654, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (749, '2023-10-18', 466.53, 2001.48, 0.81, 463.2, 466.88, 462.8, 466.53, 7998, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (750, '2023-10-17', 462.8, 1985.48, 0.53, 460.37, 463.2, 460, 462.8, 6618, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (751, '2023-10-16', 460.35, 1974.96, 1.53, 455.66, 464.09, 455.26, 460.35, 13758, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (752, '2023-10-13', 453.4, 1945.15, 0.09, 453, 454.44, 451.71, 453.4, 5406, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (753, '2023-10-12', 453, 1943.43, 0.73, 452.34, 453.3, 449, 453, 10852, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (754, '2023-10-11', 449.7, 1929.28, 0.04, 448.32, 450.5, 447.5, 449.7, 10796, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (755, '2023-10-10', 449.5, 1928.42, 2.63, 446.02, 451, 446.02, 449.5, 18816, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (756, '2023-10-09', 438, 1879.08, -1.79, 438, 453.5, 438, 438, 20072, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (757, '2023-09-28', 446, 1913.4, -3.67, 464.48, 464.48, 446, 446, 42530, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (758, '2023-09-27', 463, 1986.33, -1.96, 471.77, 471.9, 462.8, 463, 24460, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (759, '2023-09-26', 472.25, 2026.02, -0.26, 473.15, 473.15, 470.7, 472.25, 12060, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (760, '2023-09-25', 473.5, 2031.38, 0.47, 470.84, 473.5, 470.3, 473.5, 7186, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (761, '2023-09-22', 471.3, 2021.94, -0.07, 471.3, 472.86, 468.32, 471.3, 19886, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (762, '2023-09-21', 471.65, 2023.44, -0.14, 472.37, 473.82, 471.2, 471.65, 11464, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (763, '2023-09-20', 472.32, 2026.32, 0.37, 471.28, 473.3, 470.23, 472.32, 22202, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (764, '2023-09-19', 470.6, 2018.94, 0.35, 468.11, 471, 467, 470.6, 17666, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (765, '2023-09-18', 468.98, 2011.99, -0.06, 470.8, 472.7, 466.16, 468.98, 38396, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (766, '2023-09-15', 469.25, 2013.15, -0.58, 473.12, 480.5, 465.51, 469.25, 44002, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (767, '2023-09-14', 472, 2024.95, 0.52, 468.84, 474.6, 468.6, 472, 30820, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (768, '2023-09-13', 469.55, 2014.43, 0.27, 467.5, 470.54, 467.27, 469.55, 20680, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (769, '2023-09-12', 468.3, 2009.07, 0.07, 468.29, 468.7, 467.06, 468.3, 19430, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (770, '2023-09-11', 467.98, 2007.7, 0.17, 467.05, 468.67, 466.51, 467.98, 21882, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (771, '2023-09-08', 467.2, 2004.35, 0.67, 465.3, 467.69, 464.1, 467.2, 16298, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (772, '2023-09-07', 464.1, 1991.05, 0.08, 464.5, 465, 463.67, 464.1, 15000, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (773, '2023-09-06', 463.75, 1989.55, -0.33, 464.2, 465.19, 463.75, 463.75, 15112, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (774, '2023-09-05', 465.3, 1996.2, 0.06, 464.11, 465.35, 463.25, 465.3, 13816, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (775, '2023-09-04', 465, 1994.91, 0.45, 463.8, 465.88, 461.87, 465, 18382, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (776, '2023-09-01', 462.92, 1985.99, -0.16, 463.25, 463.4, 461.18, 462.92, 15122, '2026-06-30 14:38:38');
INSERT INTO `gold_prices` VALUES (777, '2023-08-31', 463.65, 1989.12, 0.5, 462.2, 463.74, 461.7, 463.65, 14660, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (778, '2023-08-30', 461.35, 1979.26, 0.23, 459.6, 462.4, 459, 461.35, 16586, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (779, '2023-08-29', 460.29, 1974.71, 0.22, 459.13, 461, 458.71, 460.29, 12106, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (780, '2023-08-28', 459.29, 1970.42, 0.13, 459.4, 459.7, 457.66, 459.29, 17174, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (781, '2023-08-25', 458.7, 1967.89, -0.06, 458.7, 459.5, 458.3, 458.7, 13766, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (782, '2023-08-24', 458.99, 1969.13, 0.18, 458.5, 460.15, 458.03, 458.99, 13918, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (783, '2023-08-23', 458.15, 1965.53, 0.21, 457.7, 458.5, 456.41, 458.15, 16052, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (784, '2023-08-22', 457.2, 1961.45, -0.1, 457.1, 457.59, 455.95, 457.2, 17158, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (785, '2023-08-21', 457.65, 1963.38, 0.38, 455.9, 457.72, 455.2, 457.65, 18414, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (786, '2023-08-18', 455.9, 1955.87, -0.2, 456.77, 457, 455.3, 455.9, 16352, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (787, '2023-08-17', 456.8, 1959.74, 0, 456.9, 457.39, 455.61, 456.8, 12468, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (788, '2023-08-16', 456.79, 1959.69, 0.2, 455.84, 457.2, 455.46, 456.79, 19718, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (789, '2023-08-15', 455.9, 1955.87, 0.07, 455.65, 456, 454.6, 455.9, 11974, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (790, '2023-08-14', 455.6, 1954.59, 0.17, 455.1, 456, 454.7, 455.6, 13492, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (791, '2023-08-11', 454.83, 1951.28, 0.4, 453.46, 455.25, 453.2, 454.83, 15828, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (792, '2023-08-10', 453.02, 1943.52, -0.4, 454.01, 454.63, 452.58, 453.02, 18298, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (793, '2023-08-09', 454.85, 1951.37, 0.05, 454.5, 455.41, 454, 454.85, 12088, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (794, '2023-08-08', 454.61, 1950.34, -0.09, 454.33, 455.5, 453.9, 454.61, 10212, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (795, '2023-08-07', 455, 1952.01, 0.33, 453.79, 455.83, 452, 455, 10288, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (796, '2023-08-04', 453.5, 1945.58, -0.2, 454, 454.42, 452.85, 453.5, 14210, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (797, '2023-08-03', 454.4, 1949.44, -0.47, 456.5, 456.8, 454.15, 454.4, 15032, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (798, '2023-08-02', 456.55, 1958.66, 0.03, 456.12, 456.63, 454.54, 456.55, 17118, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (799, '2023-08-01', 456.4, 1958.02, 0.24, 456, 457.78, 456, 456.4, 12398, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (800, '2023-07-31', 455.3, 1953.3, 0.07, 456.3, 456.4, 454.72, 455.3, 17308, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (801, '2023-07-28', 455, 1952.01, -0.79, 458.62, 459, 454.21, 455, 29974, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (802, '2023-07-27', 458.62, 1967.54, 0.26, 457.7, 459, 456.4, 458.62, 12756, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (803, '2023-07-26', 457.45, 1962.52, 0.43, 455.5, 457.58, 454.1, 457.45, 16590, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (804, '2023-07-25', 455.5, 1954.16, -0.63, 458.3, 458.56, 455.38, 455.5, 23888, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (805, '2023-07-24', 458.4, 1966.6, 0.01, 458, 458.5, 456.4, 458.4, 14796, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (806, '2023-07-21', 458.35, 1966.38, -0.56, 460, 460, 457.6, 458.35, 14970, '2026-06-30 14:38:39');
INSERT INTO `gold_prices` VALUES (807, '2023-07-20', 460.94, 1977.5, -0.23, 461.2, 462.41, 459.89, 460.94, 14540, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (808, '2023-07-19', 462, 1982.04, 1.32, 456.1, 462.5, 456, 462, 26068, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (809, '2023-07-18', 456, 1956.3, 0.42, 454.19, 456.15, 453.2, 456, 16490, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (810, '2023-07-17', 454.1, 1948.15, 0.34, 453.1, 454.98, 452.4, 454.1, 17010, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (811, '2023-07-14', 452.55, 1941.5, -0.48, 455, 455, 452.1, 452.55, 16718, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (812, '2023-07-13', 454.71, 1950.77, 0.85, 451, 455.1, 450.6, 454.71, 27014, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (813, '2023-07-12', 450.89, 1934.38, 0.19, 450.83, 451.6, 450.35, 450.89, 12180, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (814, '2023-07-11', 450.02, 1930.65, -0.27, 450.76, 451.21, 448.95, 450.02, 15512, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (815, '2023-07-10', 451.25, 1935.92, 0.3, 449.71, 451.68, 449.51, 451.25, 14890, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (816, '2023-07-07', 449.9, 1930.13, -0.04, 450.13, 450.8, 447.03, 449.9, 18586, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (817, '2023-07-06', 450.1, 1930.99, -0.08, 451.05, 452.49, 449.8, 450.1, 14892, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (818, '2023-07-05', 450.45, 1932.49, 0.08, 450.46, 450.8, 449.54, 450.45, 12070, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (819, '2023-07-04', 450.08, 1930.91, 0.12, 449.02, 451.27, 448.8, 450.08, 30134, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (820, '2023-07-03', 449.53, 1928.55, 0.21, 448.75, 450.8, 448.2, 449.53, 21732, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (821, '2023-06-30', 448.58, 1924.47, 0.34, 447.9, 448.8, 445.85, 448.58, 19600, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (822, '2023-06-29', 447.08, 1918.03, 0.02, 446.81, 447.99, 446.53, 447.08, 22048, '2026-06-30 14:38:40');
INSERT INTO `gold_prices` VALUES (823, '2023-06-28', 447, 1917.69, -0.45, 447.82, 448.7, 445.8, 447, 24554, '2026-06-30 14:38:40');

-- ----------------------------
-- Table structure for laptop_models
-- ----------------------------
DROP TABLE IF EXISTS `laptop_models`;
CREATE TABLE `laptop_models`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '机型名称',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '品牌',
  `price_min` int(11) NULL DEFAULT NULL COMMENT '最低价(元)',
  `price_max` int(11) NULL DEFAULT NULL COMMENT '最高价(元)',
  `price_tag` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '价格标签 如3000-4000',
  `year` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '年款',
  `is_new` int(11) NULL DEFAULT NULL COMMENT '是否2026新款 1是0否',
  `cpu` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'CPU型号',
  `cpu_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'CPU定位 entry/mainstream/high/flagship',
  `cpu_desc` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'CPU通俗解释',
  `ram` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内存 如16GB/32GB',
  `ram_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '内存类型',
  `ram_freq` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '内存频率',
  `ram_expandable` int(11) NULL DEFAULT NULL COMMENT '是否可扩展 1是0否',
  `ram_desc` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '内存通俗解释',
  `storage` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '硬盘 如512GB SSD',
  `storage_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '硬盘协议',
  `storage_desc` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '硬盘通俗解释',
  `gpu` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '显卡型号',
  `gpu_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '显卡类型 integrated/discrete',
  `gpu_desc` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '显卡通俗解释',
  `screen_size` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '屏幕尺寸',
  `screen_resolution` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分辨率',
  `screen_refresh` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '刷新率',
  `screen_color_gamut` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '色域',
  `screen_brightness` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '亮度',
  `screen_desc` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '屏幕通俗解释',
  `weight` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '重量',
  `thickness` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '厚度',
  `material` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '材质',
  `portability_desc` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '便携通俗解释',
  `battery` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '电池容量',
  `battery_life` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '办公续航时长',
  `fast_charge` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '快充能力',
  `battery_desc` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '续航通俗解释',
  `ports` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '接口列表',
  `ports_desc` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '接口通俗解释',
  `features` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '特色功能',
  `score_office` float NULL DEFAULT NULL COMMENT '办公性能分(30)',
  `score_graphics` float NULL DEFAULT NULL COMMENT '图形设计分(20)',
  `score_fluency` float NULL DEFAULT NULL COMMENT '流畅续航分(20)',
  `score_portability` float NULL DEFAULT NULL COMMENT '便携质感分(15)',
  `score_value` float NULL DEFAULT NULL COMMENT '性价比分(15)',
  `score_total` float NULL DEFAULT NULL COMMENT '综合总分',
  `scene_tags` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '适用场景标签 JSON数组',
  `scene_basic` int(11) NULL DEFAULT NULL COMMENT '基础办公匹配度0-100',
  `scene_multi` int(11) NULL DEFAULT NULL COMMENT '多任务办公匹配度',
  `scene_design` int(11) NULL DEFAULT NULL COMMENT '设计美工匹配度',
  `scene_video` int(11) NULL DEFAULT NULL COMMENT '视频剪辑匹配度',
  `scene_3d` int(11) NULL DEFAULT NULL COMMENT '三维建模匹配度',
  `scene_ai` int(11) NULL DEFAULT NULL COMMENT 'AI办公匹配度',
  `scene_travel` int(11) NULL DEFAULT NULL COMMENT '商旅便携匹配度',
  `scene_entertainment` int(11) NULL DEFAULT NULL COMMENT '轻度娱乐匹配度',
  `pros` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '优点',
  `cons` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '缺点',
  `buy_guide` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '购买建议/避坑提示',
  `suitable_for` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '适合人群',
  `not_suitable_for` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '不适合人群',
  `is_thin` int(11) NULL DEFAULT NULL COMMENT '是否轻薄本 1是0否',
  `weight_kg` float NULL DEFAULT NULL COMMENT '重量(kg) 用于筛选',
  `created_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `buy_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of laptop_models
-- ----------------------------
INSERT INTO `laptop_models` VALUES (1, '联想IdeaPad 15 2026款', '联想', 3299, 3999, '3000-4000', '2026', 1, 'AMD Ryzen 5 7530U', 'entry', '6核12线程，日常办公、网课、文档处理绰绰有余，功耗低续航长', '16GB', 'DDR4', '3200MHz', 1, '16G内存日常办公完全够用，支持扩展到32G，后期不担心不够用', '512GB SSD', 'NVMe', '512G固态硬盘，开机8秒，Office秒开，存文档照片够用', 'AMD Radeon集成显卡', 'integrated', '集成显卡，办公看视频没问题，不适合玩大型游戏和专业设计', '15.6英寸', '1920x1080', '60Hz', '45%NTSC', '250nit', '15.6寸大屏，1080P分辨率看文档清晰，色域一般，不适合设计修图', '1.65kg', '17.9mm', '工程塑料', '1.65kg在15寸本里算轻的，日常通勤可以接受', '42Wh', '约6-8小时', '支持快充，1小时充至60%', '42Wh电池办公能用大半天，中度使用需要带充电器', 'USB-C x1, USB-A x2, HDMI x1, 耳机孔, SD卡槽', '接口齐全，USB-C/HDMI/USB-A都有，接投影U盘很方便', '指纹解锁, 数字小键盘', 20, 8, 18, 10, 14, 70, '[\"基础办公\", \"学生网课\"]', 85, 55, 30, 20, 15, 20, 60, 50, '价格实惠，大屏办公舒适，接口齐全，支持内存扩展', '色域低不适合设计，性能仅够基础办公，塑料机身质感一般', '注意选R5版本别选R3，内存一定选16G别选8G，这是2026年办公基本线', '预算有限的学生、基础办公、网课学习', '设计师、视频剪辑、游戏玩家', 0, 1.65, '2026-05-28 07:43:19', '2026-05-28 07:43:19', 'https://re.jd.com/search?keyword=联想IdeaPad+15+2026款');
INSERT INTO `laptop_models` VALUES (2, '荣耀MagicBook X16 2026款', '荣耀', 3499, 3999, '3000-4000', '2026', 1, 'Intel Core i5-13420H', 'entry', '4核8线程标压处理器，办公性能比低压U强一档，多开软件更流畅', '16GB', 'LPDDR4X', '4266MHz', 0, '16G高频内存，办公多开不卡，但不可扩展，买的时候一步到位', '512GB SSD', 'NVMe', '512G固态，读写速度快，开机和软件启动都很迅速', 'Intel UHD集成显卡', 'integrated', 'Intel集成显卡，办公看视频流畅，不适合游戏和专业图形处理', '16英寸', '1920x1200', '60Hz', '100%sRGB', '300nit', '16寸大屏+100%sRGB高色域，这个价位难得！看文档修图都舒服', '1.62kg', '17.9mm', '铝合金', '1.62kg铝合金机身，质感比同价位塑料本好很多', '60Wh', '约8-10小时', '65W快充', '60Wh大电池，办公一整天不插电，65W快充回血很快', 'USB-C x1, USB-A x2, HDMI x1, 耳机孔', '常用接口都有，USB-C支持充电和数据传输', '指纹电源二合一, 多屏协同, 护眼模式', 22, 12, 20, 11, 14, 79, '[\"基础办公\", \"学生网课\"]', 90, 60, 50, 25, 15, 25, 65, 55, '高色域屏幕在这个价位很难得，铝合金机身质感好，续航长', '内存不可扩展，集成显卡性能有限', '这个价位性价比之王，尤其高色域屏幕，办公修图都行', '预算有限但对屏幕有要求的用户，基础办公学生', '视频剪辑、游戏玩家', 0, 1.62, '2026-05-28 07:43:19', '2026-05-28 07:43:19', 'https://re.jd.com/search?keyword=荣耀MagicBook+X16+2026款');
INSERT INTO `laptop_models` VALUES (3, '联想小新Pro 16 2026款', '联想', 4999, 5999, '4000-6000', '2026', 1, 'AMD Ryzen 7 8845H', 'mainstream', '8核16线程标压处理器，性能强劲，多任务办公、轻度设计都能胜任', '32GB', 'LPDDR5X', '7500MHz', 0, '32G超大内存，开几十个标签页+微信钉钉+WPS同时运行完全不卡', '1TB SSD', 'NVMe PCIe4.0', '1TB大容量固态，存大量文件不用焦虑空间不够', 'AMD Radeon 780M集成显卡', 'integrated', '目前最强核显，性能接近入门独显，PS修图和轻度剪辑可以搞定', '16英寸', '2560x1600', '120Hz', '100%sRGB', '400nit', '2.5K高清屏+120Hz高刷，色彩准确画面细腻，办公修图都很爽', '1.95kg', '17.5mm', '铝合金', '1.95kg在16寸性能本里算轻的，日常通勤OK', '75Wh', '约10-12小时', '100W快充', '75Wh超大电池，重度办公也能撑一整天，100W快充半小时充一半', 'USB-C x2, USB-A x2, HDMI 2.0 x1, SD卡槽, 耳机孔', '接口丰富，双USB-C+双USB-A+HDMI+SD卡槽，外接设备不用转接器', 'IR人脸识别, 1080P摄像头, 杜比音效, 护眼模式', 27, 16, 20, 11, 14, 88, '[\"多任务办公\", \"设计美工\", \"基础办公\"]', 95, 90, 75, 50, 35, 55, 55, 70, '32G大内存+1TB硬盘一步到位，2.5K高刷屏素质优秀，续航超长', '1.95kg略重，没有独显做不了重度设计和剪辑', '这个价位最全能的选择，办公设计都能搞定，R7+32G+1TB配置很良心', '多任务办公用户、轻度设计师、追求全面的职场人', '重度视频剪辑、3D建模、大型游戏玩家', 0, 1.95, '2026-05-28 07:43:19', '2026-05-28 07:43:19', 'https://re.jd.com/search?keyword=联想小新Pro+16+2026款');
INSERT INTO `laptop_models` VALUES (4, '华为MateBook 14 2026款', '华为', 5299, 5999, '4000-6000', '2026', 1, 'Intel Core Ultra 5 125H', 'mainstream', 'Intel新一代AI处理器，4性能核+8能效核，AI办公和日常任务都很强', '16GB', 'LPDDR5X', '7467MHz', 0, '16G高频内存，办公流畅，但重度多任务建议选32G版本', '512GB SSD', 'NVMe PCIe4.0', '512G固态够日常办公用，文件多建议搭配云盘或移动硬盘', 'Intel Arc集成显卡', 'integrated', 'Intel Arc核显，支持AI加速，PS修图和1080P视频剪辑可以应对', '14.2英寸', '2880x1800', '120Hz', '100%sRGB/P3广色域', '450nit', '2.8K OLED级色彩，P3广色域，设计师看了都说好，护眼认证', '1.31kg', '14.5mm', '铝合金一体成型', '仅1.31kg，比两瓶矿泉水还轻，通勤出差无压力', '60Wh', '约8-10小时', '65W超级快充', '60Wh电池+低功耗处理器，办公一整天没问题，手机充电器也能充', 'USB-C x2, USB-A x1, HDMI x1, 耳机孔', 'USB-C支持充电和数据，HDMI直连投影，日常够用', 'AI慧眼(智能追踪), 超级终端(华为多设备协同), 指纹电源键, 护眼模式', 25, 15, 19, 14, 12, 85, '[\"商旅便携\", \"多任务办公\", \"基础办公\"]', 90, 80, 70, 40, 25, 65, 95, 60, '极轻机身+顶级屏幕+华为生态协同，商旅办公首选', '接口偏少，内存不可扩展，重度任务性能不足', '华为用户首选，多屏协同生态无敌，屏幕素质同价位顶级', '经常出差的商务人士、华为生态用户、注重屏幕的办公用户', '重度剪辑建模、游戏玩家、预算敏感用户', 1, 1.31, '2026-05-28 07:43:19', '2026-05-28 07:43:19', 'https://re.jd.com/search?keyword=华为MateBook+14+2026款');
INSERT INTO `laptop_models` VALUES (5, '华硕无畏Pro15 2026款', '华硕', 4999, 5699, '4000-6000', '2026', 1, 'AMD Ryzen 7 8845H', 'mainstream', '8核16线程高性能处理器，多任务办公、PS修图、轻度剪辑都流畅', '16GB', 'LPDDR5X', '6400MHz', 0, '16G高频内存，办公多开流畅', '512GB SSD', 'NVMe PCIe4.0', '512G固态，读写快，日常办公够用', 'AMD Radeon 780M集成显卡', 'integrated', '旗舰级核显，PS/AI设计软件可以跑，轻度PR剪辑也OK', '15.6英寸', '2880x1620', '120Hz', '100%DCI-P3', '600nit', '2.8K OLED屏幕，600nit超高亮度，P3广色域，色彩惊艳，设计师利器', '1.7kg', '17.9mm', '铝合金', '1.7kg在15寸本里算轻的，日常通勤没问题', '70Wh', '约8-10小时', '90W快充', '70Wh大电池，办公续航一整天', 'USB-C x2, USB-A x1, HDMI 2.0 x1, MicroSD, 耳机孔', '双USB-C+USB-A+HDMI，日常接口齐全', 'OLED屏幕, AI降噪, 杜比全景声, 指纹解锁', 26, 17, 19, 12, 13, 87, '[\"设计美工\", \"多任务办公\", \"轻度娱乐\"]', 88, 85, 88, 55, 35, 50, 60, 65, 'OLED屏幕色彩顶级，性能强劲，性价比高', 'OLED有烧屏风险需注意，没有独显做不了重度设计', '设计师预算有限首选，OLED屏幕素质碾压同价位，注意避免长时间显示静态画面', '设计师、对屏幕要求高的办公用户', '重度视频剪辑、3D建模', 0, 1.7, '2026-05-28 07:43:19', '2026-05-28 07:43:19', 'https://re.jd.com/search?keyword=华硕无畏Pro15+2026款');
INSERT INTO `laptop_models` VALUES (6, '联想小新Pro 16 2026 独显版', '联想', 6499, 7499, '6000-8000', '2026', 1, 'AMD Ryzen 7 8845H', 'high', '8核16线程标压高性能处理器，重度多任务、设计剪辑都能胜任', '32GB', 'LPDDR5X', '7500MHz', 0, '32G超大内存，同时开PS+PR+浏览器几十个标签都稳如泰山', '1TB SSD', 'NVMe PCIe4.0', '1TB大容量高速固态，存4K素材也够用', 'NVIDIA RTX 4060 8GB', 'discrete', '独立显卡！PS/AI设计无压力，PR剪辑4K视频流畅，还能玩大部分游戏', '16英寸', '2560x1600', '120Hz', '100%sRGB', '400nit', '2.5K高刷屏，色彩准确，设计修图和日常办公都很舒适', '2.0kg', '17.9mm', '铝合金', '2.0kg有独显算轻的，通勤可以接受', '75Wh', '约7-9小时', '100W快充', '75Wh大电池，日常办公大半天，用独显的话续航会缩短', 'USB-C x2, USB-A x2, HDMI 2.1 x1, SD卡槽, 耳机孔, 网口', '接口最全的笔记本之一，网口/HDMI/SD卡槽全有，不用转接器', 'RTX4060独显, AI加速, 1080P摄像头, 杜比音效, 数字小键盘', 29, 19, 19, 10, 13, 90, '[\"视频剪辑\", \"设计美工\", \"多任务办公\"]', 90, 92, 90, 85, 70, 75, 45, 85, '独显+32G大内存，设计剪辑全能选手，接口齐全', '2.0kg偏重，续航不如核显版', '需要独显做设计剪辑的最佳选择，比游戏本轻便比轻薄本性能强', '设计师、视频剪辑师、需要独显的办公用户', '追求极致轻薄的用户', 0, 2, '2026-05-28 07:43:20', '2026-05-28 07:43:20', 'https://re.jd.com/search?keyword=联想小新Pro+16+2026+独显版');
INSERT INTO `laptop_models` VALUES (7, '华为MateBook X Pro 2026款', '华为', 7999, 8999, '6000-8000', '2026', 1, 'Intel Core Ultra 7 155H', 'high', 'Intel旗舰AI处理器，6性能核+8能效核+NPU，AI办公和专业任务都强', '32GB', 'LPDDR5X', '7467MHz', 0, '32G超高频内存，重度多任务毫无压力', '1TB SSD', 'NVMe PCIe4.0', '1TB大容量固态，存什么都够', 'Intel Arc集成显卡', 'integrated', 'Intel Arc核显+NPU AI加速，轻度设计和AI应用可以胜任', '14.2英寸', '3120x2080', '120Hz', '100%DCI-P3', '600nit', '3.1K顶级屏幕，P3广色域600nit，色彩精准度DeltaE<1，设计师最爱', '0.98kg', '13.5mm', '镁铝合金一体成型', '不到1kg！极致轻薄，单手轻松拿起，出差神器', '72Wh', '约10-12小时', '90W超级快充', '72Wh大电池塞进1kg机身，续航一整天，90W快充回血超快', 'Thunderbolt 4 x2, USB-C x1, 耳机孔', '3个USB-C(含2个雷电4)，需要转接器接传统USB设备', 'AI慧眼, 超级终端, 压感触控板, 指纹解锁, 六扬声器', 27, 14, 20, 15, 11, 87, '[\"商旅便携\", \"多任务办公\", \"AI办公\"]', 92, 88, 72, 45, 30, 80, 98, 60, '不到1kg极致轻薄，3.1K顶级屏幕，AI处理器，华为生态', '接口少需要转接器，没有独显，价格较高', '追求极致轻薄+顶级屏幕的不二之选，华为生态加分', '高端商务人士、华为生态用户、追求极致便携的用户', '重度设计剪辑、游戏玩家、预算敏感用户', 1, 0.98, '2026-05-28 07:43:20', '2026-05-28 07:43:20', 'https://re.jd.com/search?keyword=华为MateBook+X+Pro+2026款');
INSERT INTO `laptop_models` VALUES (8, '荣耀MagicBook Art 14 2026款', '荣耀', 6299, 7299, '6000-8000', '2026', 1, 'Intel Core Ultra 5 125H', 'mainstream', 'Intel AI处理器，4性能核+8能效核，AI办公和日常任务表现优秀', '32GB', 'LPDDR5X', '7467MHz', 0, '32G大内存，多任务办公丝滑流畅', '1TB SSD', 'NVMe PCIe4.0', '1TB大容量，办公文件随便存', 'Intel Arc集成显卡', 'integrated', 'Intel Arc核显，办公设计轻度使用OK', '14.6英寸', '3120x2080', '120Hz', '100%DCI-P3', '700nit', '3.1K OLED屏幕，700nit峰值亮度，P3广色域，户外也能看清', '1.07kg', '12.9mm', '镁铝合金', '1.07kg超轻薄，12.9mm超薄，随身携带无负担', '75Wh', '约10-12小时', '100W快充', '75Wh超大电池，续航一整天，100W快充半小时充50%', 'Thunderbolt 4 x1, USB-C x2, USB-A x1, HDMI x1, 耳机孔', '比华为多一个USB-A和HDMI，不用转接器更方便', 'AI字幕, 隔空手势, 指纹解锁, 六扬声器, 护眼认证', 26, 14, 20, 15, 13, 88, '[\"商旅便携\", \"多任务办公\", \"AI办公\"]', 92, 85, 72, 42, 28, 78, 96, 60, '1kg级轻薄+3.1K OLED+32G+1TB，接口比华为丰富，性价比高', '没有独显，荣耀生态不如华为丰富', '比华为MateBook X Pro便宜2000+但配置几乎一样，性价比更高', '注重性价比的轻薄本用户、商务出差人士', '重度设计剪辑、游戏玩家', 1, 1.07, '2026-05-28 07:43:20', '2026-05-28 07:43:20', 'https://re.jd.com/search?keyword=荣耀MagicBook+Art+14+2026款');
INSERT INTO `laptop_models` VALUES (9, 'ThinkPad X1 Carbon 2026款', 'ThinkPad', 9999, 11999, '8000-12000', '2026', 1, 'Intel Core Ultra 7 155H', 'high', 'Intel旗舰AI处理器，6性能核+8能效核+NPU，专业办公和AI任务游刃有余', '32GB', 'LPDDR5X', '7467MHz', 0, '32G超高频内存，同时运行虚拟机、Docker、大型项目都不卡', '1TB SSD', 'NVMe PCIe4.0', '1TB高速固态，企业级数据读写', 'Intel Arc集成显卡', 'integrated', 'Intel Arc核显+NPU，办公和AI应用足够', '14英寸', '2880x1800', '120Hz', '100%DCI-P3', '500nit', '2.8K OLED屏幕，500nit亮度，P3广色域，色彩精准，商务演示效果出色', '1.08kg', '14.9mm', '碳纤维+镁铝合金', '1.08kg碳纤维机身，坚固耐用又轻便，商务出差首选', '57Wh', '约8-10小时', '65W快充', '57Wh电池配合低功耗处理器，办公一整天', 'Thunderbolt 4 x2, USB-A x2, HDMI 2.0 x1, 耳机孔', '双雷电4+双USB-A+HDMI，商务接口齐全', '经典小红点, ThinkPad键盘, IR+虹膜人脸识别, MIL-STD-810H军标认证, vPro企业管理', 28, 13, 20, 14, 10, 85, '[\"商旅便携\", \"多任务办公\", \"AI办公\"]', 92, 90, 68, 42, 30, 78, 95, 55, 'ThinkPad经典品质，碳纤维超轻，键盘手感顶级，军标认证耐用', '价格较高，没有独显，性价比一般', '企业采购首选，品质和稳定性无敌，注意选2.8K OLED屏幕版本', '企业高管、商务精英、ThinkPad老用户', '设计师、游戏玩家、追求性价比的用户', 1, 1.08, '2026-05-28 07:43:20', '2026-05-28 07:43:20', 'https://re.jd.com/search?keyword=ThinkPad+X1+Carbon+2026款');
INSERT INTO `laptop_models` VALUES (10, 'MacBook Air M4 2026款', 'Apple', 8999, 10999, '8000-12000', '2026', 1, 'Apple M4芯片', 'high', '苹果自研M4芯片，10核CPU+10核GPU+16核NPU，能效比极高', '16GB', '统一内存', '', 0, '16G统一内存，macOS优化好，实际体验相当于Windows 32G', '512GB SSD', 'NVMe', '512G固态，苹果SSD读写速度行业顶级', 'M4集成10核GPU', 'integrated', 'M4 GPU性能强劲，Final Cut剪辑4K无压力，AI运算飞快', '15.3英寸', '2880x1864', '120Hz', 'P3广色域', '600nit', 'Liquid Retina显示屏，P3广色域600nit，色彩精准度行业顶级', '1.51kg', '11.5mm', '100%再生铝金属', '1.51kg+11.5mm，15寸大屏做到这个重量厚度，工艺顶级', '66.5Wh', '约15-18小时', '70W快充', 'M4能效比逆天，办公续航可达18小时，两天不充电都行', 'Thunderbolt 4/USB-C x2, MagSafe充电口, 耳机孔', '只有2个USB-C，需要转接器接传统设备，MagSafe磁吸充电很方便', 'Touch ID, 空间音频, Apple Intelligence AI, macOS生态, 无风扇静音设计', 28, 17, 20, 14, 11, 90, '[\"商旅便携\", \"视频剪辑\", \"AI办公\", \"多任务办公\"]', 95, 92, 80, 82, 55, 90, 90, 70, '续航逆天18小时，M4芯片性能强，无风扇静音，macOS生态优秀', '接口少需要转接器，软件生态不如Windows丰富，价格高', '苹果生态用户必选，续航和静音是最大卖点，注意512G存储可能不够用', '苹果生态用户、创意工作者、追求续航和静音的商务人士', 'Windows必须用户、游戏玩家、预算有限的用户', 1, 1.51, '2026-05-28 07:43:20', '2026-05-28 07:43:20', 'https://re.jd.com/search?keyword=MacBook+Air+M4+2026款');
INSERT INTO `laptop_models` VALUES (11, '华硕灵耀14 2026 旗舰版', '华硕', 8499, 9999, '8000-12000', '2026', 1, 'Intel Core Ultra 9 185H', 'flagship', 'Intel最强AI处理器，6性能核+8能效核+2超低功耗核+NPU，性能怪兽', '32GB', 'LPDDR5X', '7467MHz', 0, '32G超高频内存，专业工作流毫无压力', '1TB SSD', 'NVMe PCIe4.0', '1TB高速固态，大型项目文件随便存', 'Intel Arc集成显卡', 'integrated', 'Intel Arc核显+NPU，AI创作和轻度设计可以胜任', '14英寸', '2880x1800', '120Hz', '100%DCI-P3', '600nit', '2.8K OLED华硕好屏，600nit P3广色域，DeltaE<1专业级色准', '1.29kg', '13.9mm', '铝合金CNC工艺', '1.29kg轻薄机身，CNC工艺质感出众', '75Wh', '约10-12小时', '90W快充', '75Wh大电池，旗舰处理器也能续航一整天', 'Thunderbolt 4 x2, USB-A x1, HDMI 2.1 x1, MicroSD, 耳机孔', '双雷电4+USB-A+HDMI+SD卡槽，接口丰富不用转接', 'AI降噪, OLED屏幕, 1080P摄像头, 哈曼卡顿音效, 指纹解锁', 29, 16, 20, 13, 11, 89, '[\"AI办公\", \"设计美工\", \"多任务办公\", \"商旅便携\"]', 92, 92, 82, 55, 40, 92, 80, 65, '旗舰处理器+OLED屏幕+轻薄机身，AI性能顶级', '没有独显，价格偏高', 'AI办公需求强烈用户的最佳选择，Ultra 9处理器NPU性能最强', 'AI办公用户、创意工作者、追求极致性能的轻薄本用户', '重度游戏、预算有限用户', 1, 1.29, '2026-05-28 07:43:20', '2026-05-28 07:43:20', 'https://re.jd.com/search?keyword=华硕灵耀14+2026+旗舰版');
INSERT INTO `laptop_models` VALUES (12, 'MacBook Pro 16 M4 Pro 2026款', 'Apple', 18999, 24999, '12000+', '2026', 1, 'Apple M4 Pro芯片', 'flagship', '苹果M4 Pro芯片，12核CPU+18核GPU+16核NPU，专业创作性能怪兽', '36GB', '统一内存', '', 0, '36G统一内存，处理8K视频、大型3D项目、AI模型训练都绑绑的', '512GB SSD', 'NVMe', '512G起步，建议选1TB版本，苹果SSD读写速度行业最快', 'M4 Pro集成18核GPU', 'discrete', '18核GPU性能媲美RTX4070，Final Cut/达芬奇剪辑8K无压力', '16.2英寸', '3456x2234', '120Hz', 'P3广色域', '1600nit HDR', 'Liquid Retina XDR显示屏，1600nit HDR峰值亮度，专业影视创作标配', '2.14kg', '16.8mm', '100%再生铝金属', '2.14kg在16寸专业本里算正常，移动办公可以接受', '100Wh', '约15-18小时', '140W快充', '100Wh超大电池+M4 Pro高能效，续航18小时，专业工作也能撑一整天', 'Thunderbolt 5 x3, HDMI 2.1 x1, SD卡槽, MagSafe, 耳机孔', '3个雷电5+HDMI+SD卡槽，专业接口齐全，外接显示器不用转接', 'Liquid Retina XDR, ProMotion 120Hz, Apple Intelligence, 空间音频, 六扬声器', 30, 20, 20, 9, 10, 89, '[\"视频剪辑\", \"三维建模\", \"AI办公\", \"设计美工\"]', 95, 95, 92, 95, 85, 95, 50, 80, '专业创作性能无敌，续航超长，屏幕顶级，macOS生态优秀', '价格昂贵，重量偏大，游戏生态差', '专业视频剪辑/音乐制作/AI开发的终极选择，建议选1TB版本', '专业视频剪辑师、音乐制作人、AI开发者、高端创意工作者', '普通办公用户(杀鸡用牛刀)、游戏玩家、预算有限用户', 0, 2.14, '2026-05-28 07:43:20', '2026-05-28 07:43:20', 'https://re.jd.com/search?keyword=MacBook+Pro+16+M4+Pro+2026款');
INSERT INTO `laptop_models` VALUES (13, 'ThinkPad X1 Extreme 2026款', 'ThinkPad', 12999, 15999, '12000+', '2026', 1, 'Intel Core Ultra 9 185H', 'flagship', 'Intel旗舰处理器，6P+8E+2LPE核心+NPU，专业工作站级别性能', '32GB', 'DDR5', '5600MHz', 1, '32G DDR5可扩展到64G，专业工作流灵活升级', '1TB SSD', 'NVMe PCIe4.0', '1TB企业级固态，双M.2插槽可扩展', 'NVIDIA RTX 4070 8GB', 'discrete', 'RTX 4070专业独显，3D建模渲染、4K视频剪辑、AI训练都能胜任', '16英寸', '3840x2400', '120Hz', '100%DCI-P3', '600nit', '4K+ OLED屏幕，600nit P3广色域，专业色准DeltaE<1', '1.88kg', '17.9mm', '碳纤维+镁铝合金', '1.88kg塞进RTX4070，碳纤维机身兼顾轻便和坚固', '90Wh', '约8-10小时', '130W快充', '90Wh大电池，日常办公一整天，用独显重度工作建议插电', 'Thunderbolt 4 x2, USB-A x2, HDMI 2.1 x1, SD卡槽, 网口, 耳机孔', '最全接口：双雷电4+双USB-A+HDMI+网口+SD卡槽，外接设备随便接', 'RTX4070独显, 双M.2扩展, 网口, MIL-STD-810H军标, vPro企业管理, IR人脸识别', 30, 20, 19, 10, 9, 88, '[\"三维建模\", \"视频剪辑\", \"设计美工\", \"AI办公\"]', 88, 95, 92, 90, 92, 88, 55, 85, '4K OLED+RTX4070+可扩展，专业移动工作站，接口最全', '价格昂贵，重量偏大，续航一般', '需要Windows专业工作站的终极选择，3D建模/AI训练首选', '3D建模师、工程师、AI开发者、需要Windows专业软件的用户', '普通办公用户、预算有限用户、追求轻薄的用户', 0, 1.88, '2026-05-28 07:43:20', '2026-05-28 07:43:20', 'https://re.jd.com/search?keyword=ThinkPad+X1+Extreme+2026款');
INSERT INTO `laptop_models` VALUES (14, '华为MateBook X Pro 2026 微绒典藏版', '华为', 12999, 14999, '12000+', '2026', 1, 'Intel Core Ultra 9 185H', 'flagship', 'Intel最强AI处理器，旗舰级性能+NPU AI加速', '32GB', 'LPDDR5X', '7467MHz', 0, '32G超高频内存，旗舰级多任务处理能力', '2TB SSD', 'NVMe PCIe4.0', '2TB超大容量，存什么都够用', 'Intel Arc集成显卡', 'integrated', 'Intel Arc核显+NPU，AI办公和轻度创作可以胜任', '14.2英寸', '3120x2080', '120Hz', '100%DCI-P3', '600nit', '3.1K顶级OLED屏幕，P3广色域600nit，DeltaE<1专业色准', '0.98kg', '13.5mm', '微绒金属+镁铝合金', '0.98kg极致轻薄，微绒工艺手感温润，尊贵质感', '72Wh', '约10-12小时', '90W超级快充', '72Wh大电池，旗舰处理器也能续航一整天', 'Thunderbolt 4 x2, USB-C x1, 耳机孔', '3个USB-C含2个雷电4，需要转接器', '微绒工艺, AI慧眼, 超级终端, 六扬声器, 压感触控板, 指纹解锁', 28, 14, 20, 15, 8, 85, '[\"商旅便携\", \"AI办公\", \"多任务办公\"]', 92, 90, 72, 45, 30, 85, 98, 60, '0.98kg极致轻薄+微绒工艺尊贵质感+2TB超大存储+AI处理器', '没有独显，接口少，价格昂贵', '华为旗舰商务本，追求极致轻薄+尊贵质感的用户首选', '高端商务人士、华为生态深度用户、追求极致品质的用户', '设计师(无独显)、游戏玩家、追求性价比的用户', 1, 0.98, '2026-05-28 07:43:20', '2026-05-28 07:43:20', 'https://re.jd.com/search?keyword=华为MateBook+X+Pro+2026+微绒典藏版');

-- ----------------------------
-- Table structure for laptop_recommendations
-- ----------------------------
DROP TABLE IF EXISTS `laptop_recommendations`;
CREATE TABLE `laptop_recommendations`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `budget` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '预算区间',
  `scenes` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '选择的场景 JSON数组',
  `preferences` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '偏好选项 JSON数组',
  `extra_demand` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '额外需求',
  `result_ids` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '推荐机型ID列表 逗号分隔',
  `result_detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '推荐结果详情JSON',
  `created_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of laptop_recommendations
-- ----------------------------
INSERT INTO `laptop_recommendations` VALUES (1, 1, '4000-6000', '[\"basic\", \"multi\"]', '[\"thin\", \"battery\"]', '', '3,4,5', '[\"联想小新Pro 16 2026款\", \"华为MateBook 14 2026款\", \"华硕无畏Pro15 2026款\"]', '2026-05-28 07:53:00');
INSERT INTO `laptop_recommendations` VALUES (2, 1, '4000-6000', '[\"basic\", \"multi\"]', '[\"thin\", \"battery\"]', '', '3,4,5', '[\"联想小新Pro 16 2026款\", \"华为MateBook 14 2026款\", \"华硕无畏Pro15 2026款\"]', '2026-05-28 07:53:38');
INSERT INTO `laptop_recommendations` VALUES (3, 1, '8000-12000', '[\"video\", \"design\"]', '[\"screen\"]', '', '10,11,7', '[\"MacBook Air M4 2026款\", \"华硕灵耀14 2026 旗舰版\", \"华为MateBook X Pro 2026款\"]', '2026-05-28 07:53:40');
INSERT INTO `laptop_recommendations` VALUES (4, 1, '6000-8000', '[\"travel\", \"ai\"]', '[\"thin\", \"battery\"]', '', '8,6', '[\"荣耀MagicBook Art 14 2026款\", \"联想小新Pro 16 2026 独显版\"]', '2026-05-28 07:53:43');
INSERT INTO `laptop_recommendations` VALUES (5, 1, '6000-8000', '[\"ai\"]', '[\"ram\", \"screen\"]', '游戏本带独显', '8,6', '[\"荣耀MagicBook Art 14 2026款\", \"联想小新Pro 16 2026 独显版\"]', '2026-05-28 08:03:10');
INSERT INTO `laptop_recommendations` VALUES (6, 1, '6000-8000', '[\"ai\"]', '[\"ram\", \"screen\"]', '游戏本带独显', '8,6', '[\"荣耀MagicBook Art 14 2026款\", \"联想小新Pro 16 2026 独显版\"]', '2026-05-28 08:03:36');
INSERT INTO `laptop_recommendations` VALUES (7, 1, '12000+', '[\"basic\"]', '[\"brand\"]', '有独显', '12,14,13', '[\"MacBook Pro 16 M4 Pro 2026款\", \"华为MateBook X Pro 2026 微绒典藏版\", \"ThinkPad X1 Extreme 2026款\"]', '2026-05-28 08:23:23');
INSERT INTO `laptop_recommendations` VALUES (8, 1, '6000-8000', '[\"ai\"]', '[\"ram\", \"battery\"]', '游戏本，带独显', '8,6', '[\"荣耀MagicBook Art 14 2026款\", \"联想小新Pro 16 2026 独显版\"]', '2026-05-28 08:24:27');
INSERT INTO `laptop_recommendations` VALUES (9, 1, '6000-8000', '[\"entertainment\"]', '[\"battery\", \"brand\"]', '不要苹果电脑', '6,8', '[\"联想小新Pro 16 2026 独显版\", \"荣耀MagicBook Art 14 2026款\"]', '2026-06-15 05:45:54');
INSERT INTO `laptop_recommendations` VALUES (10, 1, '4000-6000', '[\"ai\"]', '[\"ram\", \"battery\", \"brand\"]', '', '4,3,5', '[\"华为MateBook 14 2026款\", \"联想小新Pro 16 2026款\", \"华硕无畏Pro15 2026款\"]', '2026-06-16 07:32:33');

-- ----------------------------
-- Table structure for menus
-- ----------------------------
DROP TABLE IF EXISTS `menus`;
CREATE TABLE `menus`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '菜单名称',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图标',
  `path` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '页面路径',
  `parent_id` int(11) NULL DEFAULT NULL COMMENT '父菜单ID(0为顶级)',
  `sort_order` int(11) NULL DEFAULT NULL COMMENT '排序',
  `status` smallint(6) NULL DEFAULT NULL COMMENT '状态(0禁用/1启用)',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of menus
-- ----------------------------
INSERT INTO `menus` VALUES (1, '首页', 'home', 'pages/home/home', 0, 1, 1, '2026-05-28 12:16:16', '2026-05-28 12:16:16');
INSERT INTO `menus` VALUES (2, '系统管理', 'settings', '', 0, 2, 1, '2026-05-28 12:16:16', '2026-05-28 12:16:16');
INSERT INTO `menus` VALUES (3, '菜单管理', 'menu', 'pages/menu/menu', 2, 1, 1, '2026-05-28 12:16:16', '2026-05-28 12:16:16');
INSERT INTO `menus` VALUES (4, '用户管理', 'person', '', 2, 2, 1, '2026-05-28 12:16:16', '2026-05-28 12:16:16');
INSERT INTO `menus` VALUES (5, '日志管理', 'document', '', 2, 3, 1, '2026-05-28 12:16:16', '2026-05-28 12:16:16');
INSERT INTO `menus` VALUES (6, '工具', 'tools', '', 0, 3, 1, '2026-05-28 12:16:16', '2026-05-28 12:16:16');
INSERT INTO `menus` VALUES (7, '相机拍照', 'camera', 'pages/camera/camera', 6, 1, 1, '2026-05-28 12:16:16', '2026-05-28 12:16:16');
INSERT INTO `menus` VALUES (8, '我的', 'profile', 'pages/profile/profile', 0, 4, 1, '2026-05-28 12:16:16', '2026-05-28 12:16:16');

-- ----------------------------
-- Table structure for operation_logs
-- ----------------------------
DROP TABLE IF EXISTS `operation_logs`;
CREATE TABLE `operation_logs`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` int(11) NULL DEFAULT NULL COMMENT '操作用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作用户名',
  `action` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作类型(login/create/update/delete)',
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模块名(menu/user等)',
  `detail` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '操作详情',
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作IP',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 58 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of operation_logs
-- ----------------------------
INSERT INTO `operation_logs` VALUES (1, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-05-28 12:29:12');
INSERT INTO `operation_logs` VALUES (2, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-05-28 12:31:06');
INSERT INTO `operation_logs` VALUES (3, 1, 'admin', 'create', 'menu', '新增菜单: 测试菜单', '127.0.0.1', '2026-05-28 12:31:14');
INSERT INTO `operation_logs` VALUES (4, 1, 'admin', 'update', 'menu', '更新菜单: 测试菜单(已修改) (ID: 9)', '127.0.0.1', '2026-05-28 12:31:17');
INSERT INTO `operation_logs` VALUES (5, 1, 'admin', 'delete', 'menu', '删除菜单: 测试菜单(已修改) (ID: 9)', '127.0.0.1', '2026-05-28 12:31:21');
INSERT INTO `operation_logs` VALUES (6, 1, 'admin', 'update', 'user', '更新个人信息', '127.0.0.1', '2026-05-28 12:31:28');
INSERT INTO `operation_logs` VALUES (7, 2, 'admin2', 'login', 'auth', '用户 admin2 登录成功', '127.0.0.1', '2026-05-28 14:34:51');
INSERT INTO `operation_logs` VALUES (8, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-05-28 15:14:32');
INSERT INTO `operation_logs` VALUES (9, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-05-28 15:45:53');
INSERT INTO `operation_logs` VALUES (10, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-05-28 15:47:34');
INSERT INTO `operation_logs` VALUES (11, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-05-28 15:49:06');
INSERT INTO `operation_logs` VALUES (12, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-05-28 15:50:52');
INSERT INTO `operation_logs` VALUES (13, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-05-28 15:51:58');
INSERT INTO `operation_logs` VALUES (14, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-05-28 15:52:57');
INSERT INTO `operation_logs` VALUES (15, 1, 'admin', 'recommend', 'laptop', '笔记本推荐: 预算4000-6000, 场景basic,multi', '127.0.0.1', '2026-05-28 15:53:00');
INSERT INTO `operation_logs` VALUES (16, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-05-28 15:53:33');
INSERT INTO `operation_logs` VALUES (17, 1, 'admin', 'recommend', 'laptop', '笔记本推荐: 预算4000-6000, 场景basic,multi', '127.0.0.1', '2026-05-28 15:53:38');
INSERT INTO `operation_logs` VALUES (18, 1, 'admin', 'recommend', 'laptop', '笔记本推荐: 预算8000-12000, 场景video,design', '127.0.0.1', '2026-05-28 15:53:41');
INSERT INTO `operation_logs` VALUES (19, 1, 'admin', 'recommend', 'laptop', '笔记本推荐: 预算6000-8000, 场景travel,ai', '127.0.0.1', '2026-05-28 15:53:43');
INSERT INTO `operation_logs` VALUES (20, 1, 'admin', 'recommend', 'laptop', '笔记本推荐: 预算6000-8000, 场景ai', '127.0.0.1', '2026-05-28 16:03:10');
INSERT INTO `operation_logs` VALUES (21, 1, 'admin', 'recommend', 'laptop', '笔记本推荐: 预算6000-8000, 场景ai', '127.0.0.1', '2026-05-28 16:03:36');
INSERT INTO `operation_logs` VALUES (22, 1, 'admin', 'recommend', 'laptop', '笔记本推荐: 预算12000+, 场景basic', '127.0.0.1', '2026-05-28 16:23:23');
INSERT INTO `operation_logs` VALUES (23, 1, 'admin', 'recommend', 'laptop', '笔记本推荐: 预算6000-8000, 场景ai', '127.0.0.1', '2026-05-28 16:24:27');
INSERT INTO `operation_logs` VALUES (24, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-05-29 16:28:18');
INSERT INTO `operation_logs` VALUES (25, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-15 13:45:21');
INSERT INTO `operation_logs` VALUES (26, 1, 'admin', 'recommend', 'laptop', '笔记本推荐: 预算6000-8000, 场景entertainment', '192.168.16.2', '2026-06-15 13:45:55');
INSERT INTO `operation_logs` VALUES (27, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-06-15 14:45:18');
INSERT INTO `operation_logs` VALUES (28, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-06-15 16:17:03');
INSERT INTO `operation_logs` VALUES (29, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-16 14:52:59');
INSERT INTO `operation_logs` VALUES (30, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-16 14:59:16');
INSERT INTO `operation_logs` VALUES (31, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-16 15:18:18');
INSERT INTO `operation_logs` VALUES (32, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-16 15:19:13');
INSERT INTO `operation_logs` VALUES (33, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-16 15:20:11');
INSERT INTO `operation_logs` VALUES (34, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-16 15:21:16');
INSERT INTO `operation_logs` VALUES (35, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-16 15:23:46');
INSERT INTO `operation_logs` VALUES (36, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-16 15:24:52');
INSERT INTO `operation_logs` VALUES (37, 1, 'admin', 'recommend', 'laptop', '笔记本推荐: 预算4000-6000, 场景ai', '192.168.16.2', '2026-06-16 15:32:34');
INSERT INTO `operation_logs` VALUES (38, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-06-16 17:06:31');
INSERT INTO `operation_logs` VALUES (39, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-06-18 09:23:01');
INSERT INTO `operation_logs` VALUES (40, 1, 'admin', 'create', 'user', '管理员创建用户 Eric', '127.0.0.1', '2026-06-18 18:41:46');
INSERT INTO `operation_logs` VALUES (41, 3, 'Eric', 'login', 'auth', '用户 Eric 登录成功', '127.0.0.1', '2026-06-18 18:42:21');
INSERT INTO `operation_logs` VALUES (42, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-18 20:35:07');
INSERT INTO `operation_logs` VALUES (43, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-22 09:17:50');
INSERT INTO `operation_logs` VALUES (44, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-23 10:58:12');
INSERT INTO `operation_logs` VALUES (45, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-06-26 12:29:43');
INSERT INTO `operation_logs` VALUES (46, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-29 10:27:40');
INSERT INTO `operation_logs` VALUES (47, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-06-30 11:37:24');
INSERT INTO `operation_logs` VALUES (48, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-06-30 14:35:52');
INSERT INTO `operation_logs` VALUES (49, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-06-30 14:37:48');
INSERT INTO `operation_logs` VALUES (50, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-06-30 16:20:17');
INSERT INTO `operation_logs` VALUES (51, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '127.0.0.1', '2026-06-30 16:23:25');
INSERT INTO `operation_logs` VALUES (52, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-30 17:15:51');
INSERT INTO `operation_logs` VALUES (53, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-30 17:19:48');
INSERT INTO `operation_logs` VALUES (54, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-30 17:25:22');
INSERT INTO `operation_logs` VALUES (55, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-30 17:28:55');
INSERT INTO `operation_logs` VALUES (56, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-30 17:32:20');
INSERT INTO `operation_logs` VALUES (57, 1, 'admin', 'login', 'auth', '用户 admin 登录成功', '192.168.16.2', '2026-06-30 17:41:39');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码(bcrypt加密)',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像URL',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '角色(admin/user)',
  `status` smallint(6) NULL DEFAULT NULL COMMENT '状态(0禁用/1启用)',
  `created_at` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ix_users_username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin', '$2b$12$LthJ8uTZqjIUHX4XFtDP1u.TmEgisXcZzGiwKUNQyfFyXSnSVEBKy', '超级管理员', '', '13800000000', 'admin', 1, '2026-05-28 12:16:16', '2026-05-28 12:31:28');
INSERT INTO `users` VALUES (2, 'admin2', '$2b$12$LthJ8uTZqjIUHX4XFtDP1u.TmEgisXcZzGiwKUNQyfFyXSnSVEBKy', '超级管理员', '', '13800000000', 'admin', 1, '2026-05-28 12:16:16', '2026-05-28 12:31:28');
INSERT INTO `users` VALUES (3, 'Eric', '$2b$12$saHHeU.G.FO56DcALCEnwuqdtSxRbsIqkVLfj3uhCJdah5yBVU80y', '艾瑞克', '', '12', 'user', 1, '2026-06-18 18:41:45', '2026-06-18 18:41:45');

SET FOREIGN_KEY_CHECKS = 1;
