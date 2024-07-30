-- MySQL dump 10.13  Distrib 8.0.38, for Win64 (x86_64)
--
-- Host: localhost    Database: village_app
-- ------------------------------------------------------
-- Server version	8.0.38

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
-- Table structure for table `announcements`
--

DROP TABLE IF EXISTS `announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `announcements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
INSERT INTO `announcements` VALUES (7,'Heavy Rainfall','Heavy rainfall affected Mangalore Rural, leading to significant flooding in several villages. The local authorities are working to manage the situation and provide assistance to the affected residents.','2024-07-16 17:34:53'),(15,'PEPPER PRICES MAY INCREASE','The cold climate has led to an increase in pepper consumption. As a result, the current prices for pepper in Cochin are at Rs. 580-585 per kilogram, while the best quality is being traded at Rs. 680-700 per kilogram.','2024-07-22 12:22:40'),(19,'Illegally imported arecanut seized','The price of arecanut beginning to fall, Central Arecanut and Cocoa Marketing and Processing Cooperative Ltd. (CAMPCO), Mangaluru, on Friday, wrote to Prime Minister Narendra Modi seeking his intervention to ensure that when illegally imported arecanut seized by the government is auctioned the floor price is maintained.','2024-07-22 12:57:43'),(22,'Weather update','Expected  rain around 9.00 a.m⛈','2024-07-30 00:49:40'),(23,'Power Outage','Due to a scheduled maintenance, there will be a power outage today from 11:00 AM to 5:00 PM. The affected areas include:\n\nHampankatta\nB B Alabi Road\nMG Road\nFalnir First Cross\nKadri\nBendoorwell\nBejai\nKankanady\nPlease plan accordingly and we apologize for any inconvenience caused.','2024-07-30 00:52:48'),(24,'Test','test announcemnts','2024-07-30 04:17:30');
/*!40000 ALTER TABLE `announcements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crop`
--

DROP TABLE IF EXISTS `crop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crop` (
  `id` int NOT NULL AUTO_INCREMENT,
  `crop_name` varchar(255) NOT NULL,
  `avg_price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crop`
--

LOCK TABLES `crop` WRITE;
/*!40000 ALTER TABLE `crop` DISABLE KEYS */;
INSERT INTO `crop` VALUES (1,'Arecanut',36717.33),(2,'Onion',14340.69),(3,'Tomato',10.00),(4,'Carrot',0.00),(5,'Pumpkin',0.00);
/*!40000 ALTER TABLE `crop` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `places`
--

DROP TABLE IF EXISTS `places`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `places` (
  `id` int NOT NULL AUTO_INCREMENT,
  `place_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `places`
--

LOCK TABLES `places` WRITE;
/*!40000 ALTER TABLE `places` DISABLE KEYS */;
INSERT INTO `places` VALUES (1,'Bagalkot'),(2,'Bangalore'),(3,'Belgaum'),(4,'Bellary'),(5,'Bijapur'),(6,'Chamrajnagar'),(7,'Chikmagalur'),(8,'Davangere'),(9,'Dharwad'),(10,'Gadag'),(11,'Hassan'),(12,'Haveri'),(13,'Kalburgi'),(14,'Kolar'),(15,'Koppal'),(16,'Mandya'),(17,'Mangalore (Dakshin Kannada)'),(18,'Mysore'),(19,'Raichur'),(20,'Shimoga'),(21,'Tumkur'),(22,'Udupi'),(23,'Chitradurga'),(27,'Madikeri (Kodagu)'),(29,'Karwar (Uttar Kannada)');
/*!40000 ALTER TABLE `places` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `price`
--

DROP TABLE IF EXISTS `price`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `price` (
  `id` int NOT NULL AUTO_INCREMENT,
  `crop_id` int DEFAULT NULL,
  `place_id` int DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `month_year` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `crop_id` (`crop_id`),
  KEY `place_id` (`place_id`),
  CONSTRAINT `price_ibfk_1` FOREIGN KEY (`crop_id`) REFERENCES `crop` (`id`),
  CONSTRAINT `price_ibfk_2` FOREIGN KEY (`place_id`) REFERENCES `places` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `price`
--

LOCK TABLES `price` WRITE;
/*!40000 ALTER TABLE `price` DISABLE KEYS */;
INSERT INTO `price` VALUES (6,1,2,0.00,'July 2024'),(7,1,7,36385.00,'July 2024'),(8,1,23,40815.00,'July 2024'),(9,1,11,0.00,'July 2024'),(11,1,14,0.00,'July 2024'),(12,1,27,37447.00,'July 2024'),(13,1,16,0.00,'July 2024'),(14,1,17,33134.00,'July 2024'),(15,1,20,43027.00,'July 2024'),(16,1,21,24876.00,'July 2024'),(17,1,22,32182.00,'July 2024'),(20,1,29,33068.00,'July 2024'),(21,2,17,17080.00,'July 2024'),(25,4,7,0.00,'July 2024'),(26,2,2,0.00,'July 2024'),(27,2,18,0.00,'July 2024'),(28,4,17,10.01,'July 2024');
/*!40000 ALTER TABLE `price` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `queries`
--

DROP TABLE IF EXISTS `queries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `queries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `matter` text NOT NULL,
  `time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `admin_response` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `queries`
--

LOCK TABLES `queries` WRITE;
/*!40000 ALTER TABLE `queries` DISABLE KEYS */;
INSERT INTO `queries` VALUES (9,'user','Will the price of arecanut increase next month?','2024-07-30 00:56:04',NULL),(10,'ebeyjoeregi','Installation of CCTV for security','2024-07-30 01:10:50','Will discuss regarding that in upcoming general body meeting.'),(11,'user','possiblity of rain today','2024-07-30 04:25:44','high chance');
/*!40000 ALTER TABLE `queries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suggestions`
--

DROP TABLE IF EXISTS `suggestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `suggestions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `username` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `response` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suggestions`
--

LOCK TABLES `suggestions` WRITE;
/*!40000 ALTER TABLE `suggestions` DISABLE KEYS */;
INSERT INTO `suggestions` VALUES (15,'Poor condition of roads','The roads in many parts of the village are broken down. I request that they be repaired at the earliest, at least by closing the holes in between the roads.','user','2024-07-30 06:38:04',NULL),(16,'General Body meeting','When will the General Body meeting be held?','ebeyjoeregi','2024-07-30 06:49:11','On 15th August 2024');
/*!40000 ALTER TABLE `suggestions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL,
  `user_type` enum('admin','user') NOT NULL,
  `name` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address` varchar(255) NOT NULL,
  `job_title` varchar(255) DEFAULT NULL,
  `activation` tinyint(1) DEFAULT '0',
  `email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'alexander','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','admin','Alexander','9874563210','Village Home','President',1,'president@villageapp.com'),(2,'aju','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','user','Aju Thomas','9874563210','Mary Hill','Student',1,'aju@gmail.com'),(3,'anusha','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','user','Anusha Nayak','9874563210','Surathkal','Student',0,'anusha@gmail.com'),(18,'user','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','user','User World','1234567891','User Home','User Work',1,'user@user.com'),(19,'admin','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','admin','Admin Name','123-456-7890','Admin Address','Administrator',1,'admin@example.com'),(24,'ebeyjoeregi','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','user','Ebey Joe Regi','9497698743','Kannur','Fasrmer',1,'ebeyjoeregi@gmail.co'),(26,'anjalita','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','user','Anjalita','987456321','Surathkal','Farmer',0,'anjalita@sjec.ac.in'),(30,'veena','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','admin','Veena Vijayan','9874563210','Thenguparambil House','Secretary',1,'secretary@villageapp.com'),(32,'sara','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','admin','Sara Blonda','9874563210','Village House','Treasurer',1,'treasurer@villageapp.com'),(34,'edwin','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','user','Edwin Regi','9874563210','Kannur','Student',0,'edwinregi@gmail.com');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-07-30 16:53:15
