-- MySQL Database Friends.sql
-- Builds Database, loads data, executes query/script operation within the Database
DROP DATABASE IF EXISTS MindsetDB;
CREATE DATABASE MindsetDB;
USE MindsetDB;

CREATE TABLE Friends (
  FriendID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(100) NOT NULL,
  Attitude ENUM('positive', 'neutral', 'toxic') NOT NULL,
  CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE `Self` (
  SelfID INT AUTO_INCREMENT PRIMARY KEY,
  Confidence INT NOT NULL DEFAULT 0 CHECK (Confidence BETWEEN 0 AND 100),
  Doubt INT NOT NULL DEFAULT 0 CHECK (Doubt >= 0),
  UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE `Future` (
  FutureID INT AUTO_INCREMENT PRIMARY KEY,
  Goal VARCHAR(150) NOT NULL,
  Excuses VARCHAR(255) NULL,
  CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Dreams (
  DreamID INT AUTO_INCREMENT PRIMARY KEY,
  Dream VARCHAR(150) NOT NULL,
  `Limit` VARCHAR(255) NULL,
  CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Friends (Name, Attitude) VALUES
  ('Alex', 'positive'),
  ('Blair', 'toxic'),
  ('Casey', 'neutral'),
  ('Devon', 'toxic');
INSERT INTO `Self` (Confidence, Doubt) VALUES
  (45, 3),
  (100, 0),
  (70, 1);
INSERT INTO `Future` (Goal, Excuses) VALUES
  ('Launch the project', NULL),
  ('Learn MySQL', 'No time'),
  ('Build good habits', NULL);
INSERT INTO Dreams (Dream, `Limit`) VALUES
  ('Start a business', NULL),
  ('Travel the world', 'Budget'),
  ('Earn a diploma', NULL);

DELETE FROM Friends WHERE Attitude = 'toxic';
UPDATE `Self`
SET Confidence = 100
WHERE Doubt > 0;

-- Use IS NULL instead of = NULL because NULL is not comparable with equality in SQL.
SELECT * FROM `Future` WHERE Excuses IS NULL;
-- Limit is quoted because it is commonly used as a SQL keyword.
SELECT * FROM Dreams WHERE `Limit` IS NULL;
