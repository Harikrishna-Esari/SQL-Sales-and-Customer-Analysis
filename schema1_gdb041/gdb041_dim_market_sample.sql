-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: gdb041
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `dim_market_sample`
--

DROP TABLE IF EXISTS `dim_market_sample`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dim_market_sample` (
  `market` varchar(255) NOT NULL,
  `sub_zone` varchar(255) NOT NULL,
  `region` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dim_market_sample`
--

LOCK TABLES `dim_market_sample` WRITE;
/*!40000 ALTER TABLE `dim_market_sample` DISABLE KEYS */;
INSERT INTO `dim_market_sample` VALUES ('China','ROA','APAC'),('India','India','APAC'),('Indonesia','ROA','APAC'),('Japan','ROA','APAC'),('Pakistan','ROA','APAC'),('Philiphines','ROA','APAC'),('South Korea','ROA','APAC'),('Australia','ANZ','APAC'),('Newzealand','ANZ','APAC'),('Bangladesh','ROA','APAC'),('France','SE','EU'),('Germany','NE','EU'),('Italy','SE','EU'),('Netherlands','NE','EU'),('Norway','NE','EU'),('Poland','NE','EU'),('Portugal','SE','EU'),('Spain','SE','EU'),('Sweden','NE','EU'),('Austria','NE','EU'),('United Kingdom','NE','EU'),('USA','nan','nan'),('Canada','nan','nan'),('Chile','LATAM','LATAM'),('Columbia','LATAM','LATAM'),('Mexico','LATAM','LATAM'),('Brazil','LATAM','LATAM');
/*!40000 ALTER TABLE `dim_market_sample` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-31 14:55:43
