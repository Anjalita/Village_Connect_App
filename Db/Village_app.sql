CREATE DATABASE  IF NOT EXISTS `village_app` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `village_app`;

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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
INSERT INTO `announcements` VALUES (7,'podey','tharathil poyi kallik','2024-07-16 17:34:53'),(9,'awer','aera','2024-07-16 17:35:10'),(10,'Meeting 1','meeting about the water problem will be discussed in the meeting ahlling at 5.00 PM today be present for the meeting','2024-07-17 09:31:05'),(11,'Miniproject','the app is all set to air with few moments.\nBe raedy','2024-07-19 09:41:21'),(12,'Done with editing Admin','Little more changes \nhoping to finish it tom','2024-07-19 18:00:22'),(13,'Checking','Checking 121','2024-07-20 15:20:53'),(15,'sdhsdx','sdfhsdf','2024-07-22 12:22:40'),(17,'Done anoucements page','Ready to flex 01','2024-07-22 12:34:34'),(18,'Done anoucements page','Ready to flex ','2024-07-22 12:36:41'),(19,'ajsofj','gasgsad','2024-07-22 12:57:43'),(20,'CHeck 1','Check','2024-07-29 14:01:06');
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
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `price`
--

LOCK TABLES `price` WRITE;
/*!40000 ALTER TABLE `price` DISABLE KEYS */;
INSERT INTO `price` VALUES (6,1,2,0.00,'July 2024'),(7,1,7,36385.00,'July 2024'),(8,1,23,40815.00,'July 2024'),(9,1,11,0.00,'July 2024'),(11,1,14,0.00,'July 2024'),(12,1,27,37447.00,'July 2024'),(13,1,16,0.00,'July 2024'),(14,1,17,33134.00,'July 2024'),(15,1,20,43027.00,'July 2024'),(16,1,21,24876.00,'July 2024'),(17,1,22,32182.00,'July 2024'),(20,1,29,33068.00,'July 2024'),(21,2,17,17080.00,'July 2024'),(25,4,7,0.00,'July 2024'),(26,2,2,0.00,'July 2024'),(27,2,18,0.00,'July 2024');
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `queries`
--

LOCK TABLES `queries` WRITE;
/*!40000 ALTER TABLE `queries` DISABLE KEYS */;
INSERT INTO `queries` VALUES (1,'user','what is current market value of suger cane','2024-07-17 17:33:36','NULL'),(2,'user','asdgsdgsd','2024-07-17 17:51:32','NULL'),(3,'user','Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took','2024-07-17 17:52:52','//////////'),(4,'ebeyjoeregi','I\'d enik mathre kanoolu','2024-07-17 18:07:06','fkfkh'),(5,'','edey','2024-07-19 17:13:53','wegdsgxsdsgdhh'),(6,'user','Done with project - Anjalita','2024-07-21 15:37:50','gsgsjjsngbwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww'),(7,'user','dfndfm','2024-07-22 16:23:18',NULL),(8,'user','Enquiry 1','2024-07-22 17:05:14',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suggestions`
--

LOCK TABLES `suggestions` WRITE;
/*!40000 ALTER TABLE `suggestions` DISABLE KEYS */;
INSERT INTO `suggestions` VALUES (1,'fff','sssss','user','2024-07-17 01:05:54','xxxxxxxx'),(2,'asfas','afsfsa','ebeyjoeregi','2024-07-17 09:23:28',NULL),(3,'asfasf','safsaassa','ebeyjoeregi','2024-07-17 09:27:11','eeee'),(4,'asfasf','fsafas','user','2024-07-17 09:28:40','khff'),(5,'asgasg','gagasasg','user','2024-07-17 09:41:18',NULL),(6,'fxhsd','hdshds','username','2024-07-17 13:42:50',NULL),(7,'dgsgsd.1','dsgdsg','username','2024-07-17 13:43:02',NULL),(8,'ehda sugamalle','adhe suhaman ninko\n','user','2024-07-17 23:29:10',NULL),(9,'edye ellam working Allen?','alleyo ball','ebeyjoeregi','2024-07-17 23:36:54',NULL),(10,'dfnd','bdnbd','','2024-07-19 22:44:08',NULL),(11,'aju','aju','user','2024-07-21 21:11:52',NULL),(12,'ebey','Ebey','ebeyjoeregi','2024-07-21 21:12:32','hdhd'),(13,'Sugegstion','suggestion 1','user','2024-07-22 22:35:43',NULL);
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
INSERT INTO `users` VALUES (1,'alexander','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','admin','Alexander','9874563210','Village Home','President',1,'president@villageapp.com'),(2,'aju','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','user','Aju Thomas','9874563210','Mary Hill','Student',0,'aju@gmail.com'),(3,'anusha','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','user','Anusha Nayak','9874563210','Surathkal','Student',0,'anusha@gmail.com'),(18,'user','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','user','User World','1234567891','User Home','User Work',1,'user@user.com'),(19,'admin','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','admin','Admin Name','123-456-7890','Admin Address','Administrator',1,'admin@example.com'),(24,'ebeyjoeregi','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','user','Ebey Joe Regi','9497698743','Kannur','Fasrmer',1,'ebeyjoeregi@gmail.co'),(26,'anjalita','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','user','Anjalita','987456321','Surathkal','Farmer',0,'anjalita@sjec.ac.in'),(30,'veena','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','admin','Veena Vijayan','9874563210','Thenguparambil House','Secretary',1,'secretary@villageapp.com'),(32,'sara','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','admin','Sara Blonda','9874563210','Village House','Treasurer',1,'treasurer@villageapp.com'),(34,'edwin','$2b$10$fykowCYgWtFT7dI34CvK0OPt1oKj7addl2lJQlTmK4iIrmtg5xmzy','user','Edwin Regi','9874563210','Kannur','Student',0,'edwinregi@gmail.com');
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

-- Dump completed on 2024-07-29 19:36:57
