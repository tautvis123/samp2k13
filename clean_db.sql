-- phpMyAdmin SQL Dump
-- version 3.5.7
-- http://www.phpmyadmin.net
--
-- Host: db4free.net:3306
-- Erstellungszeit: 09. Mrz 2013 um 16:03
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
  PRIMARY KEY (`username`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `accounts`
--

INSERT INTO `accounts` (`username`, `password`, `email`, `ip_address`, `admin_level`, `faction`, `faction_rank`, `job`, `cash`, `cc`, `level`, `skin`, `health`, `armor`, `position_X`, `position_Y`, `position_Z`, `position_A`, `logins`, `warns`, `warning1`, `warning2`, `warning3`, `vehicleID1`, `vehicleID2`, `vehicleID3`, `license_car`, `license_bike`, `license_air`) VALUES
('Jake_Turner', '098f6bcd4621d373cade4e832627b4f6', 'test@test.de', '192.168.111.1', 5, 0, 0, 0, 0, 0, 0, 0, 101, 100, 43.8944, -14.0822, 2.59124, 243.126, 1, 0, '0', '0', '0', 0, 0, 0, 0, 0, 0),
('Harti', '098f6bcd4621d373cade4e832627b4f6', 'hearteyy@gmail.com', '127.0.0.1', 5, 1, 5, 0, 0, -1, 0, 0, 0, 0, 1958.33, 1343.12, 15.36, 0, 1, 0, '0', '0', '0', 0, 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `configuration`
--

CREATE TABLE `configuration` (
  `motd` varchar(129) NOT NULL,
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
('heyyy joooooo äüöß', 0, 0, 0, 0, 0, 133337);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vehicles`
--

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
