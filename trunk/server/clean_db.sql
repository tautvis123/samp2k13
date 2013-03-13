-- phpMyAdmin SQL Dump
-- version 3.5.7
-- http://www.phpmyadmin.net
--
-- Host: db4free.net:3306
-- Erstellungszeit: 13. Mrz 2013 um 23:02
-- Server Version: 5.6.10
-- PHP-Version: 5.3.10-1ubuntu3.5

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Datenbank: `samp2013`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `accounts`
--

CREATE TABLE `accounts` (
  `username` varchar(25) CHARACTER SET latin1 COLLATE latin1_german1_ci NOT NULL,
  `password` varchar(65) CHARACTER SET latin1 COLLATE latin1_german1_ci NOT NULL,
  `email` varchar(129) CHARACTER SET latin1 COLLATE latin1_german1_ci NOT NULL,
  `ip_address` varchar(17) CHARACTER SET latin1 COLLATE latin1_german1_ci NOT NULL DEFAULT '-1',
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
  `warning1` varchar(128) CHARACTER SET latin1 COLLATE latin1_german1_ci NOT NULL DEFAULT '-1',
  `warning2` varchar(128) CHARACTER SET latin1 COLLATE latin1_german1_ci NOT NULL DEFAULT '-1',
  `warning3` varchar(128) CHARACTER SET latin1 COLLATE latin1_german1_ci NOT NULL DEFAULT '-1',
  `vehicleID1` int(5) NOT NULL DEFAULT '-1',
  `vehicleID2` int(5) NOT NULL DEFAULT '-1',
  `vehicleID3` int(5) NOT NULL DEFAULT '-1',
  `license_car` int(2) NOT NULL DEFAULT '-1',
  `license_bike` int(2) NOT NULL DEFAULT '-1',
  `license_air` int(2) NOT NULL DEFAULT '-1',
  PRIMARY KEY (`username`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `accounts`
--

INSERT INTO `accounts` (`username`, `password`, `email`, `ip_address`, `admin_level`, `faction`, `faction_rank`, `job`, `cash`, `cc`, `level`, `skin`, `health`, `armor`, `position_X`, `position_Y`, `position_Z`, `position_A`, `logins`, `warns`, `warning1`, `warning2`, `warning3`, `vehicleID1`, `vehicleID2`, `vehicleID3`, `license_car`, `license_bike`, `license_air`) VALUES
('Jake_Turner', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', 'test@test.de', '176.198.202.130', 3, 1, 0, 0, -1812096152, 0, 0, 0, 0, 0, 1946.54, 1464.6, 10.8129, 350.014, 7, 0, '0', '0', '0', 0, 0, 0, 0, 0, 0),
('Harti', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', 'hearteyy@gmail.com', '127.0.0.1', 3, 2, 4, 0, 2044, -1, 0, 24, 0, 0, 1958.33, 1343.12, 15.36, 0, 99, 3, '0', 'toocoolforschool', '0', 0, 0, 0, 1, 0, 0),
('deinemama', '14828b06d3b42c4ba06556349797206ea68bf952426997c8f42bfa3305384240', 'fewjigjiwg@gjrge.de', '-1', -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, '-1', '-1', '-1', -1, -1, -1, -1, -1, -1);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `configuration`
--

CREATE TABLE `configuration` (
  `motd` varchar(129) CHARACTER SET latin1 COLLATE latin1_german1_ci NOT NULL,
  `faction_1_funds` int(11) NOT NULL DEFAULT '0',
  `faction_2_funds` int(11) NOT NULL DEFAULT '0',
  `faction_3_funds` int(11) NOT NULL DEFAULT '0',
  `faction_4_funds` int(11) NOT NULL DEFAULT '0',
  `faction_5_funds` int(11) NOT NULL DEFAULT '0',
  `taxes` int(11) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `configuration`
--

INSERT INTO `configuration` (`motd`, `faction_1_funds`, `faction_2_funds`, `faction_3_funds`, `faction_4_funds`, `faction_5_funds`, `taxes`) VALUES
('test13', 0, 0, 0, 0, 0, 133337);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vehicles`
--

CREATE TABLE `vehicles` (
  `vehicleID` int(5) NOT NULL DEFAULT '-1',
  `owner` varchar(25) CHARACTER SET latin1 COLLATE latin1_german1_ci NOT NULL DEFAULT 'none',
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
