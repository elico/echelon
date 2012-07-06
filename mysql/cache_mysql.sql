DROP TABLE IF EXISTS `temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE  TABLE `ytcache`.`temp1` (

  `id` INT NOT NULL ,

  `videoId` VARCHAR(4000) NOT NULL ,

  `url` VARCHAR(4000) NOT NULL ,

  `lastAccessed` TIMESTAMP NOT NULL ,

  `moreData` INT NOT NULL ,

  PRIMARY KEY (`id`) );


