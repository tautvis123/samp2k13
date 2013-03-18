-- phpMyAdmin SQL Dump
-- version 3.5.7
-- http://www.phpmyadmin.net
--
-- Host: db4free.net:3306
-- Erstellungszeit: 18. Mrz 2013 um 10:19
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
  `username` varchar(25) COLLATE latin1_german1_ci NOT NULL,
  `password` char(64) COLLATE latin1_german1_ci NOT NULL,
  `email` varchar(128) COLLATE latin1_german1_ci NOT NULL,
  `ip` varchar(17) COLLATE latin1_german1_ci NOT NULL DEFAULT '0',
  `justRegistered` int(1) NOT NULL DEFAULT '1',
  `adminLevel` int(1) NOT NULL DEFAULT '0',
  `faction` int(2) NOT NULL DEFAULT '0',
  `factionRank` int(1) NOT NULL DEFAULT '0',
  `wantedLevel` int(2) NOT NULL DEFAULT '0',
  `job` int(2) NOT NULL DEFAULT '0',
  `cash` int(11) NOT NULL DEFAULT '0',
  `bank` int(21) NOT NULL DEFAULT '0',
  `level` int(2) NOT NULL DEFAULT '0',
  `skin` int(3) NOT NULL DEFAULT '0',
  `health` float NOT NULL DEFAULT '0',
  `armor` float NOT NULL DEFAULT '0',
  `posX` float NOT NULL DEFAULT '0',
  `posY` float NOT NULL DEFAULT '0',
  `posZ` float NOT NULL DEFAULT '0',
  `posA` float NOT NULL DEFAULT '0',
  `logins` int(10) NOT NULL DEFAULT '0',
  `warns` int(1) NOT NULL DEFAULT '0',
  `warning1` varchar(128) COLLATE latin1_german1_ci NOT NULL,
  `warning2` varchar(128) COLLATE latin1_german1_ci NOT NULL,
  `warning3` varchar(128) COLLATE latin1_german1_ci NOT NULL,
  `banstamp` int(20) NOT NULL DEFAULT '0',
  `vehicleID1` int(5) NOT NULL DEFAULT '0',
  `vehicleID2` int(5) NOT NULL DEFAULT '0',
  `vehicleID3` int(5) NOT NULL DEFAULT '0',
  `licenseCar` int(1) NOT NULL DEFAULT '0',
  `licenseBike` int(1) NOT NULL DEFAULT '0',
  `licenseAir` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`),
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german1_ci;

--
-- Daten für Tabelle `accounts`
--

INSERT INTO `accounts` (`username`, `password`, `email`, `ip`, `justRegistered`, `adminLevel`, `faction`, `factionRank`, `wantedLevel`, `job`, `cash`, `bank`, `level`, `skin`, `health`, `armor`, `posX`, `posY`, `posZ`, `posA`, `logins`, `warns`, `warning1`, `warning2`, `warning3`, `banstamp`, `vehicleID1`, `vehicleID2`, `vehicleID3`, `licenseCar`, `licenseBike`, `licenseAir`) VALUES
('Jake_Turner', 'test', 'test@test.de', '176.198.202.130', 0, 3, 3, 0, 0, 0, -1812096152, 0, 0, 0, 0, 0, 1946.54, 1464.6, 10.8129, 350.014, 7, -1, '0', '0', '0', 0, 0, 0, 0, 0, 0, 0),
('Harti', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', 'hearteyy@gmail.com', '127.0.0.1', 0, 3, 5, 4, 0, -1, 40, -1, 2450, 282, 100, 0, -1856.56, 32.809, 71.6034, 7.20086, 63, 2, '', '', '', 0, 0, 1, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `configuration`
--

CREATE TABLE `configuration` (
  `motd` varchar(129) COLLATE latin1_german1_ci NOT NULL,
  `faction_1_funds` int(11) NOT NULL DEFAULT '0',
  `faction_2_funds` int(11) NOT NULL DEFAULT '0',
  `faction_3_funds` int(11) NOT NULL DEFAULT '0',
  `faction_4_funds` int(11) NOT NULL DEFAULT '0',
  `faction_5_funds` int(11) NOT NULL DEFAULT '0',
  `taxes` int(11) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german1_ci;

--
-- Daten für Tabelle `configuration`
--

INSERT INTO `configuration` (`motd`, `faction_1_funds`, `faction_2_funds`, `faction_3_funds`, `faction_4_funds`, `faction_5_funds`, `taxes`) VALUES
('test', 0, 0, 0, 0, 0, 133337);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vehicles`
--

CREATE TABLE `vehicles` (
  `vehicleID` int(5) NOT NULL DEFAULT '-1',
  `owner` varchar(25) COLLATE latin1_german1_ci NOT NULL DEFAULT 'none',
  `model` int(4) NOT NULL DEFAULT '-1',
  `posX` float NOT NULL DEFAULT '-1',
  `posY` float NOT NULL DEFAULT '-1',
  `posZ` float NOT NULL DEFAULT '-1',
  `posA` float NOT NULL DEFAULT '-1',
  `color1` int(2) NOT NULL DEFAULT '-1',
  `color2` int(2) NOT NULL DEFAULT '-1',
  `navigation` int(2) NOT NULL DEFAULT '-1',
  PRIMARY KEY (`vehicleID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german1_ci;
