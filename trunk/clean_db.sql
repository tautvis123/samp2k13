/*
Navicat MySQL Data Transfer

Source Server         : Homeserver
Source Server Version : 50610
Source Host           : localhost:3306
Source Database       : sampss

Target Server Type    : MYSQL
Target Server Version : 50610
File Encoding         : 65001

Date: 2013-03-07 19:57:29
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `accounts`
-- ----------------------------
DROP TABLE IF EXISTS `accounts`;
CREATE TABLE `accounts` (
  `id` varchar(16) NOT NULL,
  `username` varchar(25) NOT NULL,
  `password` varchar(65) NOT NULL,
  `email` varchar(129) NOT NULL,
  `ip_address` varchar(17) NOT NULL DEFAULT '-1',
  `admin_level` int(2) NOT NULL DEFAULT '-1',
  `faction` int(2) NOT NULL DEFAULT '-1',
  `faction_rank` int(2) NOT NULL DEFAULT '-1',
  `job` int(2) NOT NULL DEFAULT '-1',
  `cash` int(11) NOT NULL DEFAULT '-1',
  `cc` int(21) NOT NULL DEFAULT '-1',
  `level` int(3) NOT NULL DEFAULT '-1',
  `skin` int(4) NOT NULL DEFAULT '-1',
  `health` float NOT NULL DEFAULT '-1',
  `armor` float NOT NULL DEFAULT '-1',
  `position_X` float NOT NULL DEFAULT '-1',
  `position_Y` float NOT NULL DEFAULT '-1',
  `position_Z` float NOT NULL DEFAULT '-1',
  `position_A` float NOT NULL DEFAULT '-1',
  `logins` int(11) NOT NULL DEFAULT '-1',
  `warns` int(2) NOT NULL DEFAULT '-1',
  `warning1` varchar(128) NOT NULL DEFAULT '-1',
  `warning2` varchar(128) NOT NULL DEFAULT '-1',
  `warning3` varchar(128) NOT NULL DEFAULT '-1',
  `vehicleID1` int(5) NOT NULL DEFAULT '-1',
  `vehicleID2` int(5) NOT NULL DEFAULT '-1',
  `vehicleID3` int(5) NOT NULL DEFAULT '-1',
  `license_car` int(2) NOT NULL DEFAULT '-1',
  `license_bike` int(2) NOT NULL DEFAULT '-1',
  `license_air` int(2) NOT NULL DEFAULT '-1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of accounts
-- ----------------------------
INSERT INTO `accounts` VALUES ('1337', 'Jake_Turner', '098f6bcd4621d373cade4e832627b4f6', 'test@test.de', '192.168.111.1', '5', '0', '0', '0', '0', '0', '0', '0', '101', '100', '43.8944', '-14.0822', '2.59124', '243.126', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `configurations`
-- ----------------------------
DROP TABLE IF EXISTS `configurations`;
CREATE TABLE `configurations` (
  `motd` varchar(129) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of configurations
-- ----------------------------

-- ----------------------------
-- Table structure for `vehicles`
-- ----------------------------
DROP TABLE IF EXISTS `vehicles`;
CREATE TABLE `vehicles` (
  `vehicleID` int(5) NOT NULL DEFAULT '-1',
  `owner` varchar(25) NOT NULL DEFAULT 'none',
  `model` int(4) NOT NULL DEFAULT '-1',
  `position_X` float NOT NULL DEFAULT '-1',
  `position_Y` float NOT NULL DEFAULT '-1',
  `position_Z` float NOT NULL DEFAULT '-1',
  `position_A` float NOT NULL DEFAULT '-1',
  `color1` int(2) NOT NULL DEFAULT '-1',
  `color2` int(2) NOT NULL DEFAULT '-1',
  `navigation` int(2) NOT NULL DEFAULT '-1',
  PRIMARY KEY (`vehicleID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vehicles
-- ----------------------------
