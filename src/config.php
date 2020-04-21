<?php

/**
  * Configuration for database connection
  *
  */

$host       = "k8s-demo-app-mysql";
$username   = "root";
$password   = "triliopass";
$dbname     = "test"; // will use later
$dsn        = "mysql:host=$host;dbname=$dbname"; // will use later
$options    = array(
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
              );
