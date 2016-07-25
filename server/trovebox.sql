-- MySQL dump 10.13  Distrib 5.5.49, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: trovebox
-- ------------------------------------------------------
-- Server version	5.5.49-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `action`
--

DROP TABLE IF EXISTS `action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `action` (
  `id` varchar(6) NOT NULL,
  `owner` varchar(127) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `appId` varchar(255) DEFAULT NULL,
  `targetId` varchar(255) DEFAULT NULL,
  `targetType` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `targetUrl` varchar(1000) DEFAULT NULL,
  `permalink` varchar(1000) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `datePosted` varchar(255) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  PRIMARY KEY (`owner`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action`
--

LOCK TABLES `action` WRITE;
/*!40000 ALTER TABLE `action` DISABLE KEYS */;
/*!40000 ALTER TABLE `action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity`
--

DROP TABLE IF EXISTS `activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activity` (
  `id` varchar(6) NOT NULL,
  `owner` varchar(127) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `appId` varchar(255) NOT NULL,
  `type` varchar(32) NOT NULL,
  `elementId` varchar(6) NOT NULL,
  `data` text NOT NULL,
  `permission` tinyint(1) NOT NULL DEFAULT '0',
  `dateCreated` int(10) unsigned NOT NULL,
  PRIMARY KEY (`owner`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity`
--

LOCK TABLES `activity` WRITE;
/*!40000 ALTER TABLE `activity` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  PRIMARY KEY (`key`),
  UNIQUE KEY `key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES ('version','4.0.2');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `album`
--

DROP TABLE IF EXISTS `album`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `album` (
  `id` varchar(6) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `name` varchar(255) NOT NULL,
  `groups` text,
  `extra` text,
  `countPublic` int(10) unsigned NOT NULL DEFAULT '0',
  `countPrivate` int(10) unsigned NOT NULL DEFAULT '0',
  `dateLastPhotoAdded` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`owner`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `album`
--

LOCK TABLES `album` WRITE;
/*!40000 ALTER TABLE `album` DISABLE KEYS */;
/*!40000 ALTER TABLE `album` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `albumGroup`
--

DROP TABLE IF EXISTS `albumGroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `albumGroup` (
  `owner` varchar(127) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `album` varchar(127) NOT NULL,
  `group` varchar(127) NOT NULL,
  UNIQUE KEY `owner` (`owner`,`album`,`group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `albumGroup`
--

LOCK TABLES `albumGroup` WRITE;
/*!40000 ALTER TABLE `albumGroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `albumGroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `aliasOf` varchar(255) DEFAULT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config`
--

LOCK TABLES `config` WRITE;
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
/*!40000 ALTER TABLE `config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `credential`
--

DROP TABLE IF EXISTS `credential`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credential` (
  `id` varchar(30) NOT NULL,
  `owner` varchar(127) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `image` text,
  `clientSecret` varchar(255) DEFAULT NULL,
  `userToken` varchar(255) DEFAULT NULL,
  `userSecret` varchar(255) DEFAULT NULL,
  `permissions` varchar(255) DEFAULT NULL,
  `verifier` varchar(255) DEFAULT NULL,
  `type` varchar(100) NOT NULL,
  `status` int(11) DEFAULT '0',
  `dateCreated` int(11) DEFAULT NULL,
  PRIMARY KEY (`owner`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `credential`
--

LOCK TABLES `credential` WRITE;
/*!40000 ALTER TABLE `credential` DISABLE KEYS */;
INSERT INTO `credential` VALUES ('d7f6836fb0ed030c7a87a5e56a24ad','support@delightfuldev.com','support@delightfuldev.com','Import Demo',NULL,'7deed398f8','2f6f818edb2ad6ecc9e9c7f9e430a4','fd755e427c','','aa3679aaf6','access',1,1469379351);
/*!40000 ALTER TABLE `credential` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `elementAlbum`
--

DROP TABLE IF EXISTS `elementAlbum`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `elementAlbum` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `owner` varchar(255) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `type` enum('photo') NOT NULL,
  `element` varchar(6) NOT NULL,
  `album` varchar(6) NOT NULL,
  `order` smallint(11) unsigned NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`owner`,`type`,`element`,`album`),
  KEY `owner` (`owner`,`album`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `elementAlbum`
--

LOCK TABLES `elementAlbum` WRITE;
/*!40000 ALTER TABLE `elementAlbum` DISABLE KEYS */;
/*!40000 ALTER TABLE `elementAlbum` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER update_album_counts_on_insert AFTER INSERT ON elementAlbum
  FOR EACH ROW
  BEGIN
    SET @countPublic=(SELECT COUNT(*) FROM photo AS p INNER JOIN elementAlbum AS ea ON p.id = ea.element WHERE ea.owner=NEW.owner AND ea.album=NEW.album AND p.owner=NEW.owner AND p.permission='1');
    SET @countPrivate=(SELECT COUNT(*) FROM photo AS p INNER JOIN elementAlbum AS ea ON p.id = ea.element WHERE ea.owner=NEW.owner AND ea.album=NEW.album AND p.owner=NEW.owner);
    UPDATE album SET countPublic=@countPublic, countPrivate=@countPrivate WHERE owner=NEW.owner AND id=NEW.album;
  END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER update_album_counts_on_delete AFTER DELETE ON elementAlbum
  FOR EACH ROW
  BEGIN
    SET @countPublic=(SELECT COUNT(*) FROM photo AS p INNER JOIN elementAlbum AS ea ON p.id = ea.element WHERE ea.owner=OLD.owner AND ea.album=OLD.album AND p.owner=OLD.owner AND p.permission='1');
    SET @countPrivate=(SELECT COUNT(*) FROM photo AS p INNER JOIN elementAlbum AS ea ON p.id = ea.element WHERE ea.owner=OLD.owner AND ea.album=OLD.album AND p.owner=OLD.owner);
    UPDATE album SET countPublic=@countPublic, countPrivate=@countPrivate WHERE owner=OLD.owner AND id=OLD.album;
  END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `elementGroup`
--

DROP TABLE IF EXISTS `elementGroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `elementGroup` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `owner` varchar(127) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `type` enum('photo','album') NOT NULL,
  `element` varchar(6) NOT NULL,
  `group` varchar(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `owner` (`owner`,`type`,`element`,`group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `elementGroup`
--

LOCK TABLES `elementGroup` WRITE;
/*!40000 ALTER TABLE `elementGroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `elementGroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `elementTag`
--

DROP TABLE IF EXISTS `elementTag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `elementTag` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `owner` varchar(127) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `type` enum('photo') NOT NULL,
  `element` varchar(6) NOT NULL DEFAULT 'photo',
  `tag` varchar(127) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`owner`,`type`,`element`,`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tag mapping table for photos (and videos in the future)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `elementTag`
--

LOCK TABLES `elementTag` WRITE;
/*!40000 ALTER TABLE `elementTag` DISABLE KEYS */;
/*!40000 ALTER TABLE `elementTag` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER update_tag_counts_on_insert AFTER INSERT ON elementTag
  FOR EACH ROW
  BEGIN
    SET @countPublic=(SELECT COUNT(*) FROM photo AS p INNER JOIN elementTag AS et ON p.id = et.element WHERE et.owner=NEW.owner AND et.tag=NEW.tag AND p.owner=NEW.owner AND p.permission='1');
    SET @countPrivate=(SELECT COUNT(*) FROM photo AS p INNER JOIN elementTag AS et ON p.id = et.element WHERE et.owner=NEW.owner AND et.tag=NEW.tag AND p.owner=NEW.owner);
  UPDATE tag SET countPublic=@countPublic, countPrivate=@countPrivate WHERE owner=NEW.owner AND id=NEW.tag;
  END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER update_tag_counts_on_delete AFTER DELETE ON elementTag
  FOR EACH ROW
  BEGIN
    SET @countPublic=(SELECT COUNT(*) FROM photo AS p INNER JOIN elementTag AS et ON p.id = et.element WHERE et.owner=OLD.owner AND et.tag=OLD.tag AND p.owner=OLD.owner AND p.permission='1');
    SET @countPrivate=(SELECT COUNT(*) FROM photo AS p INNER JOIN elementTag AS et ON p.id = et.element WHERE et.owner=OLD.owner AND et.tag=OLD.tag AND p.owner=OLD.owner);
    UPDATE tag SET countPublic=@countPublic, countPrivate=@countPrivate WHERE owner=OLD.owner AND id=OLD.tag;
  END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `group`
--

DROP TABLE IF EXISTS `group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group` (
  `id` varchar(6) NOT NULL,
  `owner` varchar(127) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `appId` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `permission` tinyint(4) NOT NULL COMMENT 'Bitmask of permissions',
  UNIQUE KEY `id` (`id`,`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group`
--

LOCK TABLES `group` WRITE;
/*!40000 ALTER TABLE `group` DISABLE KEYS */;
/*!40000 ALTER TABLE `group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groupMember`
--

DROP TABLE IF EXISTS `groupMember`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groupMember` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(127) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `group` varchar(6) NOT NULL,
  `email` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `owner` (`owner`,`group`,`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groupMember`
--

LOCK TABLES `groupMember` WRITE;
/*!40000 ALTER TABLE `groupMember` DISABLE KEYS */;
/*!40000 ALTER TABLE `groupMember` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `photo`
--

DROP TABLE IF EXISTS `photo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `photo` (
  `id` varchar(6) NOT NULL,
  `owner` varchar(127) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `appId` varchar(255) NOT NULL,
  `host` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` text,
  `key` varchar(255) DEFAULT NULL,
  `hash` varchar(255) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `rotation` enum('0','90','180','270') NOT NULL DEFAULT '0',
  `extra` text,
  `exif` text,
  `latitude` float(10,6) DEFAULT NULL,
  `longitude` float(10,6) DEFAULT NULL,
  `views` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `permission` int(11) DEFAULT NULL,
  `license` varchar(255) DEFAULT NULL,
  `dateTaken` int(11) DEFAULT NULL,
  `dateTakenDay` int(11) DEFAULT NULL,
  `dateTakenMonth` int(11) DEFAULT NULL,
  `dateTakenYear` int(11) DEFAULT NULL,
  `dateUploaded` int(11) DEFAULT NULL,
  `dateUploadedDay` int(11) DEFAULT NULL,
  `dateUploadedMonth` int(11) DEFAULT NULL,
  `dateUploadedYear` int(11) DEFAULT NULL,
  `dateSortByDay` varchar(14) NOT NULL,
  `filenameOriginal` varchar(255) DEFAULT NULL,
  `pathOriginal` varchar(1000) DEFAULT NULL,
  `pathBase` varchar(1000) DEFAULT NULL,
  `albums` text,
  `groups` text,
  `tags` text,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  UNIQUE KEY `owner` (`owner`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `photo`
--

LOCK TABLES `photo` WRITE;
/*!40000 ALTER TABLE `photo` DISABLE KEYS */;
/*!40000 ALTER TABLE `photo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `photoVersion`
--

DROP TABLE IF EXISTS `photoVersion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `photoVersion` (
  `id` varchar(6) NOT NULL DEFAULT '',
  `owner` varchar(127) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `key` varchar(127) NOT NULL DEFAULT '',
  `path` varchar(1000) DEFAULT NULL,
  UNIQUE KEY `id` (`owner`,`id`,`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `photoVersion`
--

LOCK TABLES `photoVersion` WRITE;
/*!40000 ALTER TABLE `photoVersion` DISABLE KEYS */;
/*!40000 ALTER TABLE `photoVersion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `relationship`
--

DROP TABLE IF EXISTS `relationship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relationship` (
  `actor` varchar(127) NOT NULL,
  `follows` varchar(127) NOT NULL,
  `dateCreated` datetime NOT NULL,
  PRIMARY KEY (`actor`,`follows`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relationship`
--

LOCK TABLES `relationship` WRITE;
/*!40000 ALTER TABLE `relationship` DISABLE KEYS */;
/*!40000 ALTER TABLE `relationship` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resourceMap`
--

DROP TABLE IF EXISTS `resourceMap`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resourceMap` (
  `id` varchar(6) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `resource` text NOT NULL,
  `dateCreated` int(11) NOT NULL,
  PRIMARY KEY (`owner`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resourceMap`
--

LOCK TABLES `resourceMap` WRITE;
/*!40000 ALTER TABLE `resourceMap` DISABLE KEYS */;
/*!40000 ALTER TABLE `resourceMap` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shareToken`
--

DROP TABLE IF EXISTS `shareToken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shareToken` (
  `id` varchar(10) NOT NULL,
  `owner` varchar(127) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `type` enum('album','photo','photos','video') NOT NULL,
  `data` varchar(255) NOT NULL,
  `dateExpires` int(10) unsigned NOT NULL,
  PRIMARY KEY (`owner`,`id`),
  KEY `owner` (`owner`,`type`,`data`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shareToken`
--

LOCK TABLES `shareToken` WRITE;
/*!40000 ALTER TABLE `shareToken` DISABLE KEYS */;
/*!40000 ALTER TABLE `shareToken` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tag`
--

DROP TABLE IF EXISTS `tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag` (
  `id` varchar(127) NOT NULL,
  `owner` varchar(127) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `countPublic` int(11) NOT NULL DEFAULT '0',
  `countPrivate` int(11) NOT NULL DEFAULT '0',
  `extra` text NOT NULL,
  UNIQUE KEY `owner` (`owner`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tag`
--

LOCK TABLES `tag` WRITE;
/*!40000 ALTER TABLE `tag` DISABLE KEYS */;
/*!40000 ALTER TABLE `tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` varchar(255) NOT NULL COMMENT 'User''s email address',
  `password` varchar(64) NOT NULL,
  `extra` text NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES ('support@delightfuldev.com','4a8df2f15b941e8dcab4f3cc5a739228452baf8c','[]','2016-07-25 05:42:27');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webhook`
--

DROP TABLE IF EXISTS `webhook`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `webhook` (
  `id` varchar(6) NOT NULL,
  `owner` varchar(127) NOT NULL,
  `actor` varchar(127) NOT NULL,
  `appId` varchar(255) DEFAULT NULL,
  `callback` varchar(1000) DEFAULT NULL,
  `topic` varchar(255) DEFAULT NULL,
  UNIQUE KEY `owner` (`owner`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webhook`
--

LOCK TABLES `webhook` WRITE;
/*!40000 ALTER TABLE `webhook` DISABLE KEYS */;
/*!40000 ALTER TABLE `webhook` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-07-25  5:42:56
