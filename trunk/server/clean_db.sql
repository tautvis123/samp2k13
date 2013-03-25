-- phpMyAdmin SQL Dump
-- version 3.5.7
-- http://www.phpmyadmin.net
--
-- Host: db4free.net:3306
-- Erstellungszeit: 25. Mrz 2013 um 11:48
-- Server Version: 5.6.10
-- PHP-Version: 5.3.10-1ubuntu3.6

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
  `username` varchar(25) COLLATE latin1_german1_ci NOT NULL,
  `password` char(64) COLLATE latin1_german1_ci NOT NULL,
  `email` varchar(128) COLLATE latin1_german1_ci NOT NULL,
  `ip` varchar(17) COLLATE latin1_german1_ci NOT NULL,
  `justRegistered` int(1) NOT NULL,
  `adminLevel` int(1) NOT NULL,
  `faction` int(2) NOT NULL,
  `factionRank` int(1) NOT NULL,
  `duty` int(1) NOT NULL,
  `wantedLevel` int(2) NOT NULL,
  `job` int(2) NOT NULL,
  `cash` int(11) NOT NULL,
  `bank` int(21) NOT NULL,
  `level` int(2) NOT NULL,
  `skin` int(3) NOT NULL,
  `health` float NOT NULL,
  `armor` float NOT NULL,
  `posX` float NOT NULL,
  `posY` float NOT NULL,
  `posZ` float NOT NULL,
  `posA` float NOT NULL,
  `logins` int(10) NOT NULL,
  `warns` int(1) NOT NULL,
  `warning1` varchar(128) COLLATE latin1_german1_ci NOT NULL,
  `warning2` varchar(128) COLLATE latin1_german1_ci NOT NULL,
  `warning3` varchar(128) COLLATE latin1_german1_ci NOT NULL,
  `banstamp` int(20) NOT NULL,
  `vehicle1` varchar(8) COLLATE latin1_german1_ci NOT NULL,
  `vehicle2` varchar(8) COLLATE latin1_german1_ci NOT NULL,
  `vehicle3` varchar(8) COLLATE latin1_german1_ci NOT NULL,
  `licenseCar` int(1) NOT NULL,
  `licenseTruck` int(1) NOT NULL,
  `licenseBike` int(1) NOT NULL,
  `licenseAir` int(1) NOT NULL,
  PRIMARY KEY (`username`),
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german1_ci;

--
-- Daten für Tabelle `accounts`
--

INSERT INTO `accounts` (`username`, `password`, `email`, `ip`, `justRegistered`, `adminLevel`, `faction`, `factionRank`, `duty`, `wantedLevel`, `job`, `cash`, `bank`, `level`, `skin`, `health`, `armor`, `posX`, `posY`, `posZ`, `posA`, `logins`, `warns`, `warning1`, `warning2`, `warning3`, `banstamp`, `vehicle1`, `vehicle2`, `vehicle3`, `licenseCar`, `licenseTruck`, `licenseBike`, `licenseAir`) VALUES
('Jake_Turner', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', 'test@test.de', '192.168.111.1', 0, 3, 1, 3, 1, 0, 0, 100020, 0, 5, 0, 0, 0, 1958.33, 1343.12, 15.36, 0, 57, -1, '0', '0', '0', 0, '0', '0', '0', 0, 0, 0, 0),
('Harti', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', 'hearteyy@gmail.com', '127.0.0.1', 0, 3, 1, 1, 1, 0, -1, 107120, -1, 2450, 280, 62, 100, 1531.32, -1638.69, 14.2428, 166.009, 340, 0, '', '', '', 0, '1', '1', '0', 0, 0, 0, 0),
('frittenbude', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', 'test@test.de', '88.152.21.251', 0, 3, 1, 1, 0, 0, 0, 133037, 0, 0, 0, 0, 0, 1188.7, -1332.13, 13.5611, 197.083, 12, 0, 'homo', '0', '0', 0, '0', '0', '0', 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `configuration`
--

CREATE TABLE `configuration` (
  `motd` varchar(129) COLLATE latin1_german1_ci NOT NULL,
  `faction_1_funds` int(11) NOT NULL,
  `faction_2_funds` int(11) NOT NULL,
  `faction_3_funds` int(11) NOT NULL,
  `faction_4_funds` int(11) NOT NULL,
  `faction_5_funds` int(11) NOT NULL,
  `taxes` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german1_ci;

--
-- Daten für Tabelle `configuration`
--

INSERT INTO `configuration` (`motd`, `faction_1_funds`, `faction_2_funds`, `faction_3_funds`, `faction_4_funds`, `faction_5_funds`, `taxes`) VALUES
('harti ist der kuhlste', 0, 0, 0, 0, 0, 133337);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vehicles`
--

CREATE TABLE `vehicles` (
  `plate` varchar(8) COLLATE latin1_german1_ci NOT NULL,
  `vehicleid` int(4) NOT NULL,
  `owner` varchar(25) COLLATE latin1_german1_ci NOT NULL,
  `model` int(3) NOT NULL,
  `health` float NOT NULL,
  `panelDamage` char(13) COLLATE latin1_german1_ci NOT NULL,
  `doorDamage` char(11) COLLATE latin1_german1_ci NOT NULL,
  `lightDamage` char(7) COLLATE latin1_german1_ci NOT NULL,
  `tireDamage` char(7) COLLATE latin1_german1_ci NOT NULL,
  `paintjob` int(1) NOT NULL,
  `mods` varchar(69) COLLATE latin1_german1_ci NOT NULL,
  `posX` float NOT NULL,
  `posY` float NOT NULL,
  `posZ` float NOT NULL,
  `posA` float NOT NULL,
  `color1` int(2) NOT NULL,
  `color2` int(2) NOT NULL,
  `navigation` int(1) NOT NULL,
  `locked` int(1) NOT NULL,
  `fuel` int(1) NOT NULL,
  `filled` int(3) NOT NULL,
  PRIMARY KEY (`plate`),
  UNIQUE KEY `plate` (`plate`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german1_ci;

--
-- Daten für Tabelle `vehicles`
--

INSERT INTO `vehicles` (`plate`, `vehicleid`, `owner`, `model`, `health`, `panelDamage`, `doorDamage`, `lightDamage`, `tireDamage`, `paintjob`, `mods`, `posX`, `posY`, `posZ`, `posA`, `color1`, `color2`, `navigation`, `locked`, `fuel`, `filled`) VALUES
('keepme', 0, '', 0, 0, '0', '0', '0', '0', 0, '0|0|0|0|0|0|0|0|0|0|0|0|0|0', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('LS-XX-00', 2, 'Jake_Turner', 451, 970.504, '0|1|0|0|0|2|0', '0|0|0|0|0|0', '0|0|1|0', '0|0|0|0', 3, '0|0|0|0|0|0|0|0|0|0|0|0|0|0', 1584.63, -1626.65, 13.0793, 137.718, 1, 1, 0, 0, 0, 100),
('LS-FF-22', 1, 'frittenbude', 487, 1000, '0|0|0|0|0|0|0', '0|0|0|0|0|0', '0|0|0|0', '0|0|0|0', 3, '0|0|0|0|0|0|0|0|0|0|0|0|0|0', -2353.85, 775.676, 99.8447, 210.746, 2, 1, 0, 0, 0, 100);
