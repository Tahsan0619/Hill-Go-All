-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 31, 2026 at 04:54 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hillgo`
--

-- --------------------------------------------------------

--
-- Table structure for table `activity_logs`
--

CREATE TABLE `activity_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `text` varchar(255) NOT NULL,
  `by` varchar(255) NOT NULL DEFAULT 'System',
  `category` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `addresses`
--

CREATE TABLE `addresses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `label` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `lat` decimal(10,7) DEFAULT NULL,
  `lng` decimal(10,7) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `app_notifications`
--

CREATE TABLE `app_notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `role` varchar(32) NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text DEFAULT NULL,
  `type` varchar(48) NOT NULL DEFAULT 'general',
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `app_notifications`
--

INSERT INTO `app_notifications` (`id`, `user_id`, `role`, `title`, `body`, `type`, `data`, `read_at`, `created_at`, `updated_at`) VALUES
(1, NULL, 'admin', 'New rider registered', 'Smoke Test Rider (+8801116439445)', 'registration', '[]', NULL, '2026-07-31 02:43:50', '2026-07-31 02:43:50'),
(2, NULL, 'admin', 'New rider registered', 'Presence Test (+8801721109255)', 'registration', '[]', NULL, '2026-07-31 02:44:08', '2026-07-31 02:44:08'),
(3, 5, 'rider', 'New job offer', 'Ride job ৳418', 'offer', '{\"trip_id\":1}', NULL, '2026-07-31 03:44:42', '2026-07-31 03:44:42'),
(4, 4, 'customer', 'Finding your driver', 'Ride RID-FKWJSD4 — searching nearby bike drivers.', 'ride', '{\"ride_id\":1}', NULL, '2026-07-31 03:44:42', '2026-07-31 03:44:42'),
(5, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":2}', NULL, '2026-07-31 03:46:38', '2026-07-31 03:46:38'),
(6, 4, 'customer', 'Finding your driver', 'Ride RID-FLLHWC7 — searching nearby bike drivers.', 'ride', '{\"ride_id\":2}', NULL, '2026-07-31 03:46:38', '2026-07-31 03:46:38'),
(7, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":2}', NULL, '2026-07-31 03:52:21', '2026-07-31 03:52:21'),
(8, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":2}', NULL, '2026-07-31 03:53:32', '2026-07-31 03:53:32'),
(9, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":2}', NULL, '2026-07-31 03:54:32', '2026-07-31 03:54:32'),
(10, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 03:54:48', '2026-07-31 03:54:48'),
(11, 4, 'customer', 'Finding your driver', 'Ride RID-FOICS20 — searching nearby bike drivers.', 'ride', '{\"ride_id\":3}', NULL, '2026-07-31 03:54:48', '2026-07-31 03:54:48'),
(12, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 03:55:19', '2026-07-31 03:55:19'),
(13, 5, 'rider', 'New job offer', 'Ride job ৳1740', 'offer', '{\"trip_id\":4}', NULL, '2026-07-31 03:55:40', '2026-07-31 03:55:40'),
(14, 4, 'customer', 'Finding your driver', 'Ride RID-FOTMK62 — searching nearby bike drivers.', 'ride', '{\"ride_id\":4}', NULL, '2026-07-31 03:55:40', '2026-07-31 03:55:40'),
(15, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 03:55:50', '2026-07-31 03:55:50'),
(16, 5, 'rider', 'New job offer', 'Ride job ৳1740', 'offer', '{\"trip_id\":4}', NULL, '2026-07-31 03:56:11', '2026-07-31 03:56:11'),
(17, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 03:56:23', '2026-07-31 03:56:23'),
(18, 5, 'rider', 'New job offer', 'Ride job ৳1740', 'offer', '{\"trip_id\":4}', NULL, '2026-07-31 03:56:44', '2026-07-31 03:56:44'),
(19, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 03:56:54', '2026-07-31 03:56:54'),
(20, 5, 'rider', 'New job offer', 'Ride job ৳1740', 'offer', '{\"trip_id\":4}', NULL, '2026-07-31 03:57:19', '2026-07-31 03:57:19'),
(21, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 03:57:20', '2026-07-31 03:57:20'),
(22, 4, 'customer', 'Finding your driver', 'Ride RID-FPF0ID0 — searching nearby bike drivers.', 'ride', '{\"ride_id\":5}', NULL, '2026-07-31 03:57:20', '2026-07-31 03:57:20'),
(23, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 03:57:29', '2026-07-31 03:57:29'),
(24, 5, 'rider', 'New job offer', 'Ride job ৳1740', 'offer', '{\"trip_id\":4}', NULL, '2026-07-31 03:57:54', '2026-07-31 03:57:54'),
(25, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 03:57:54', '2026-07-31 03:57:54'),
(26, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 03:58:05', '2026-07-31 03:58:05'),
(27, 5, 'rider', 'New job offer', 'Ride job ৳1740', 'offer', '{\"trip_id\":4}', NULL, '2026-07-31 03:58:25', '2026-07-31 03:58:25'),
(28, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 03:58:25', '2026-07-31 03:58:25'),
(29, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 03:58:40', '2026-07-31 03:58:40'),
(30, 5, 'rider', 'New job offer', 'Ride job ৳1740', 'offer', '{\"trip_id\":4}', NULL, '2026-07-31 03:59:00', '2026-07-31 03:59:00'),
(31, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 03:59:00', '2026-07-31 03:59:00'),
(32, 5, 'rider', 'New job offer', 'Ride job ৳1740', 'offer', '{\"trip_id\":6}', NULL, '2026-07-31 03:59:07', '2026-07-31 03:59:07'),
(33, 4, 'customer', 'Finding your driver', 'Ride RID-FQ1XIG2 — searching nearby bike drivers.', 'ride', '{\"ride_id\":6}', NULL, '2026-07-31 03:59:07', '2026-07-31 03:59:07'),
(34, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 03:59:11', '2026-07-31 03:59:11'),
(35, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 03:59:32', '2026-07-31 03:59:32'),
(36, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 03:59:45', '2026-07-31 03:59:45'),
(37, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:00:10', '2026-07-31 04:00:10'),
(38, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:00:20', '2026-07-31 04:00:20'),
(39, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:00:45', '2026-07-31 04:00:45'),
(40, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:00:55', '2026-07-31 04:00:55'),
(41, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:01:32', '2026-07-31 04:01:32'),
(42, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:01:32', '2026-07-31 04:01:32'),
(43, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:02:32', '2026-07-31 04:02:32'),
(44, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:02:32', '2026-07-31 04:02:32'),
(45, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:03:32', '2026-07-31 04:03:32'),
(46, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:03:32', '2026-07-31 04:03:32'),
(47, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:04:34', '2026-07-31 04:04:34'),
(48, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:04:34', '2026-07-31 04:04:34'),
(49, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:05:33', '2026-07-31 04:05:33'),
(50, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:05:33', '2026-07-31 04:05:33'),
(51, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:06:35', '2026-07-31 04:06:35'),
(52, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:06:36', '2026-07-31 04:06:36'),
(53, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:07:32', '2026-07-31 04:07:32'),
(54, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:07:32', '2026-07-31 04:07:32'),
(55, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:08:32', '2026-07-31 04:08:32'),
(56, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:08:32', '2026-07-31 04:08:32'),
(57, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:09:32', '2026-07-31 04:09:32'),
(58, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:09:32', '2026-07-31 04:09:32'),
(59, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:10:05', '2026-07-31 04:10:05'),
(60, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:10:05', '2026-07-31 04:10:05'),
(61, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:10:37', '2026-07-31 04:10:37'),
(62, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:10:38', '2026-07-31 04:10:38'),
(63, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:11:15', '2026-07-31 04:11:15'),
(64, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:11:15', '2026-07-31 04:11:15'),
(65, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:11:50', '2026-07-31 04:11:50'),
(66, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:11:50', '2026-07-31 04:11:50'),
(67, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:12:26', '2026-07-31 04:12:26'),
(68, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:12:26', '2026-07-31 04:12:26'),
(69, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:13:01', '2026-07-31 04:13:01'),
(70, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:13:01', '2026-07-31 04:13:01'),
(71, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:13:32', '2026-07-31 04:13:32'),
(72, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:13:32', '2026-07-31 04:13:32'),
(73, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 04:13:45', '2026-07-31 04:13:45'),
(74, 4, 'customer', 'Finding your driver', 'Ride RID-FVA3OI9 — searching nearby bike drivers.', 'ride', '{\"ride_id\":7}', NULL, '2026-07-31 04:13:45', '2026-07-31 04:13:45'),
(75, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:14:03', '2026-07-31 04:14:03'),
(76, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:14:03', '2026-07-31 04:14:03'),
(77, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 04:14:16', '2026-07-31 04:14:16'),
(78, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:14:36', '2026-07-31 04:14:36'),
(79, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:14:36', '2026-07-31 04:14:36'),
(80, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 04:14:48', '2026-07-31 04:14:48'),
(81, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:15:07', '2026-07-31 04:15:07'),
(82, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:15:07', '2026-07-31 04:15:07'),
(83, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 04:15:21', '2026-07-31 04:15:21'),
(84, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:15:39', '2026-07-31 04:15:39'),
(85, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:15:39', '2026-07-31 04:15:39'),
(86, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 04:15:54', '2026-07-31 04:15:54'),
(87, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:16:11', '2026-07-31 04:16:11'),
(88, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:16:11', '2026-07-31 04:16:11'),
(89, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 04:16:26', '2026-07-31 04:16:26'),
(90, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:16:42', '2026-07-31 04:16:42'),
(91, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:16:42', '2026-07-31 04:16:42'),
(92, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 04:16:57', '2026-07-31 04:16:57'),
(93, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:17:15', '2026-07-31 04:17:15'),
(94, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:17:15', '2026-07-31 04:17:15'),
(95, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 04:17:30', '2026-07-31 04:17:30'),
(96, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 04:17:46', '2026-07-31 04:17:46'),
(97, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 04:17:46', '2026-07-31 04:17:46'),
(98, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 10:17:57', '2026-07-31 10:17:57'),
(99, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:17:57', '2026-07-31 10:17:57'),
(100, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 10:17:57', '2026-07-31 10:17:57'),
(101, 4, 'customer', 'Driver assigned', 'Demo Rider is on the way.', 'ride', '{\"ride_id\":3}', NULL, '2026-07-31 10:18:14', '2026-07-31 10:18:14'),
(102, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 10:19:12', '2026-07-31 10:19:12'),
(103, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:19:12', '2026-07-31 10:19:12'),
(104, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 10:19:12', '2026-07-31 10:19:12'),
(105, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 10:19:45', '2026-07-31 10:19:45'),
(106, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:19:45', '2026-07-31 10:19:45'),
(107, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 10:19:45', '2026-07-31 10:19:45'),
(108, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 10:20:48', '2026-07-31 10:20:48'),
(109, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:20:48', '2026-07-31 10:20:48'),
(110, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 10:20:48', '2026-07-31 10:20:48'),
(111, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 10:21:51', '2026-07-31 10:21:51'),
(112, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:21:51', '2026-07-31 10:21:51'),
(113, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 10:21:51', '2026-07-31 10:21:51'),
(114, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 10:22:54', '2026-07-31 10:22:54'),
(115, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:22:54', '2026-07-31 10:22:54'),
(116, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":7}', NULL, '2026-07-31 10:22:54', '2026-07-31 10:22:54'),
(117, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 10:23:43', '2026-07-31 10:23:43'),
(118, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 10:23:48', '2026-07-31 10:23:48'),
(119, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":8}', NULL, '2026-07-31 10:23:58', '2026-07-31 10:23:58'),
(120, 4, 'customer', 'Finding your driver', 'Ride RID-FYXH5R4 — searching nearby bike drivers.', 'ride', '{\"ride_id\":8}', NULL, '2026-07-31 10:23:58', '2026-07-31 10:23:58'),
(121, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:24:03', '2026-07-31 10:24:03'),
(122, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 10:24:03', '2026-07-31 10:24:03'),
(123, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 10:24:07', '2026-07-31 10:24:07'),
(124, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":8}', NULL, '2026-07-31 10:25:01', '2026-07-31 10:25:01'),
(125, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:25:04', '2026-07-31 10:25:04'),
(126, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 10:25:10', '2026-07-31 10:25:10'),
(127, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":8}', NULL, '2026-07-31 10:26:04', '2026-07-31 10:26:04'),
(128, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:26:07', '2026-07-31 10:26:07'),
(129, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 10:26:13', '2026-07-31 10:26:13'),
(130, 5, 'rider', 'New job offer', 'Ride job ৳65', 'offer', '{\"trip_id\":3}', NULL, '2026-07-31 10:26:16', '2026-07-31 10:26:16'),
(131, 5, 'rider', 'New job offer', 'Ride job ৳74', 'offer', '{\"trip_id\":9}', NULL, '2026-07-31 10:26:16', '2026-07-31 10:26:16'),
(132, 4, 'customer', 'Finding your driver', 'Ride RID-FZR54D0 — searching nearby bike drivers.', 'ride', '{\"ride_id\":9}', NULL, '2026-07-31 10:26:16', '2026-07-31 10:26:16'),
(133, 4, 'customer', 'Driver assigned', 'Demo Rider is on the way.', 'ride', '{\"ride_id\":3}', NULL, '2026-07-31 10:26:16', '2026-07-31 10:26:16'),
(134, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:28:05', '2026-07-31 10:28:05'),
(135, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":8}', NULL, '2026-07-31 10:28:05', '2026-07-31 10:28:05'),
(136, 5, 'rider', 'New job offer', 'Ride job ৳74', 'offer', '{\"trip_id\":9}', NULL, '2026-07-31 10:28:05', '2026-07-31 10:28:05'),
(137, 5, 'rider', 'New job offer', 'Ride job ৳74', 'offer', '{\"trip_id\":10}', NULL, '2026-07-31 10:28:05', '2026-07-31 10:28:05'),
(138, 4, 'customer', 'Finding your driver', 'Ride RID-G0EJB50 — searching nearby bike drivers.', 'ride', '{\"ride_id\":10}', NULL, '2026-07-31 10:28:05', '2026-07-31 10:28:05'),
(139, 5, 'rider', 'New job offer', 'Ride job ৳74', 'offer', '{\"trip_id\":9}', NULL, '2026-07-31 10:28:05', '2026-07-31 10:28:05'),
(140, 4, 'customer', 'Driver assigned', 'Demo Rider is on the way.', 'ride', '{\"ride_id\":10}', NULL, '2026-07-31 10:28:05', '2026-07-31 10:28:05'),
(141, 4, 'customer', 'Finding your driver', 'Ride RID-G13CEV3 — searching nearby bike drivers.', 'ride', '{\"ride_id\":11}', NULL, '2026-07-31 10:30:01', '2026-07-31 10:30:01'),
(142, 5, 'rider', 'New job offer', 'Ride job ৳105', 'offer', '{\"trip_id\":11}', NULL, '2026-07-31 10:32:03', '2026-07-31 10:32:03'),
(143, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:32:03', '2026-07-31 10:32:03'),
(144, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":8}', NULL, '2026-07-31 10:32:03', '2026-07-31 10:32:03'),
(145, 5, 'rider', 'New job offer', 'Ride job ৳74', 'offer', '{\"trip_id\":9}', NULL, '2026-07-31 10:32:03', '2026-07-31 10:32:03'),
(146, 4, 'customer', 'Driver assigned', 'Demo Rider is on the way.', 'ride', '{\"ride_id\":11}', NULL, '2026-07-31 10:32:15', '2026-07-31 10:32:15'),
(147, 5, 'rider', 'New job offer', 'Ride job ৳105', 'offer', '{\"trip_id\":11}', NULL, '2026-07-31 10:32:17', '2026-07-31 10:32:17'),
(148, 5, 'rider', 'New job offer', 'Ride job ৳105', 'offer', '{\"trip_id\":11}', NULL, '2026-07-31 10:32:49', '2026-07-31 10:32:49'),
(149, 5, 'rider', 'New job offer', 'Ride job ৳105', 'offer', '{\"trip_id\":12}', NULL, '2026-07-31 10:33:25', '2026-07-31 10:33:25'),
(150, 4, 'customer', 'Finding your driver', 'Ride RID-G2B0D72 — searching nearby bike drivers.', 'ride', '{\"ride_id\":12}', NULL, '2026-07-31 10:33:25', '2026-07-31 10:33:25'),
(151, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:33:31', '2026-07-31 10:33:31'),
(152, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":8}', NULL, '2026-07-31 10:33:31', '2026-07-31 10:33:31'),
(153, 5, 'rider', 'New job offer', 'Ride job ৳74', 'offer', '{\"trip_id\":9}', NULL, '2026-07-31 10:33:31', '2026-07-31 10:33:31'),
(154, 5, 'rider', 'New job offer', 'Ride job ৳124', 'offer', '{\"trip_id\":13}', NULL, '2026-07-31 10:34:48', '2026-07-31 10:34:48'),
(155, 4, 'customer', 'Finding your driver', 'Ride RID-G2SUMX7 — searching nearby bike drivers.', 'ride', '{\"ride_id\":13}', NULL, '2026-07-31 10:34:48', '2026-07-31 10:34:48'),
(156, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:34:51', '2026-07-31 10:34:51'),
(157, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":8}', NULL, '2026-07-31 10:34:51', '2026-07-31 10:34:51'),
(158, 5, 'rider', 'New job offer', 'Ride job ৳74', 'offer', '{\"trip_id\":9}', NULL, '2026-07-31 10:34:51', '2026-07-31 10:34:51'),
(159, 5, 'rider', 'New job offer', 'Ride job ৳105', 'offer', '{\"trip_id\":11}', NULL, '2026-07-31 10:34:51', '2026-07-31 10:34:51'),
(160, 4, 'customer', 'Driver assigned', 'Demo Rider is on the way.', 'ride', '{\"ride_id\":13}', NULL, '2026-07-31 10:34:56', '2026-07-31 10:34:56'),
(161, 4, 'customer', 'Ride completed', 'Fare ৳124. Thanks for riding with HillGo!', 'ride', '{\"ride_id\":13}', NULL, '2026-07-31 10:39:01', '2026-07-31 10:39:01'),
(162, 5, 'rider', 'Trip completed', '৳124 earned (net credited to balance).', 'earning', '{\"trip_id\":13}', NULL, '2026-07-31 10:39:01', '2026-07-31 10:39:01'),
(163, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:39:01', '2026-07-31 10:39:01'),
(164, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":8}', NULL, '2026-07-31 10:39:01', '2026-07-31 10:39:01'),
(165, 5, 'rider', 'New job offer', 'Ride job ৳74', 'offer', '{\"trip_id\":9}', NULL, '2026-07-31 10:39:01', '2026-07-31 10:39:01'),
(166, 5, 'rider', 'New job offer', 'Ride job ৳105', 'offer', '{\"trip_id\":11}', NULL, '2026-07-31 10:39:01', '2026-07-31 10:39:01'),
(167, 5, 'rider', 'New job offer', 'Ride job ৳4351', 'offer', '{\"trip_id\":14}', NULL, '2026-07-31 10:40:01', '2026-07-31 10:40:01'),
(168, 4, 'customer', 'Finding your driver', 'Ride RID-G4NX2Z8 — searching nearby bike drivers.', 'ride', '{\"ride_id\":14}', NULL, '2026-07-31 10:40:01', '2026-07-31 10:40:01'),
(169, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 10:40:04', '2026-07-31 10:40:04'),
(170, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":8}', NULL, '2026-07-31 10:40:04', '2026-07-31 10:40:04'),
(171, 5, 'rider', 'New job offer', 'Ride job ৳74', 'offer', '{\"trip_id\":9}', NULL, '2026-07-31 10:40:04', '2026-07-31 10:40:04'),
(172, 5, 'rider', 'New job offer', 'Ride job ৳105', 'offer', '{\"trip_id\":11}', NULL, '2026-07-31 10:40:04', '2026-07-31 10:40:04'),
(173, 4, 'customer', 'Driver assigned', 'Demo Rider is on the way.', 'ride', '{\"ride_id\":14}', NULL, '2026-07-31 10:40:11', '2026-07-31 10:40:11'),
(174, 5, 'rider', 'Ride cancelled', 'Ride RID-G4NX2Z8 was cancelled by the customer.', 'ride', '[]', NULL, '2026-07-31 10:40:19', '2026-07-31 10:40:19');

-- --------------------------------------------------------

--
-- Table structure for table `app_settings`
--

CREATE TABLE `app_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `key` varchar(255) NOT NULL,
  `value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`value`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `app_settings`
--

INSERT INTO `app_settings` (`id`, `key`, `value`, `created_at`, `updated_at`) VALUES
(1, 'orgName', '\"HillGo Enterprise\"', '2026-07-31 01:56:44', '2026-07-31 01:56:44'),
(2, 'orgEmail', '\"admin@hillgo.app\"', '2026-07-31 01:56:44', '2026-07-31 01:56:44'),
(3, 'orgPhone', '\"+880 9612-445566\"', '2026-07-31 01:56:44', '2026-07-31 01:56:44'),
(4, 'orgAddress', '\"Level 8, Rangs Tower, Dhaka 1215\"', '2026-07-31 01:56:44', '2026-07-31 01:56:44'),
(5, 'timezone', '\"Asia\\/Dhaka\"', '2026-07-31 01:56:44', '2026-07-31 01:56:44'),
(6, 'twoFactor', 'false', '2026-07-31 01:56:44', '2026-07-31 01:56:44'),
(7, 'emailAlerts', 'true', '2026-07-31 01:56:44', '2026-07-31 01:56:44'),
(8, 'smsAlerts', 'false', '2026-07-31 01:56:44', '2026-07-31 01:56:44');

-- --------------------------------------------------------

--
-- Table structure for table `blog_posts`
--

CREATE TABLE `blog_posts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `body` longtext NOT NULL,
  `author` varchar(255) NOT NULL DEFAULT 'HillGo Team',
  `cover_image` varchar(255) DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cache`
--

INSERT INTO `cache` (`key`, `value`, `expiration`) VALUES
('hillgo-cache-2afb5d822a5bc13a9b8dc1401002804f', 'i:2;', 1785487489),
('hillgo-cache-2afb5d822a5bc13a9b8dc1401002804f:timer', 'i:1785487489;', 1785487489),
('hillgo-cache-512757d78f9ca2ad611c4315fc0d048d', 'i:1;', 1785491974),
('hillgo-cache-512757d78f9ca2ad611c4315fc0d048d:timer', 'i:1785491974;', 1785491974),
('hillgo-cache-51a579d9f64b859f0d9d1e4dbe599c60', 'i:1;', 1785490998),
('hillgo-cache-51a579d9f64b859f0d9d1e4dbe599c60:timer', 'i:1785490998;', 1785490998),
('hillgo-cache-725980f775056522d850ef39fb80259e', 'i:3;', 1785491525),
('hillgo-cache-725980f775056522d850ef39fb80259e:timer', 'i:1785491525;', 1785491525),
('hillgo-cache-77e8208b275ff0f1bd0298da2b4d9a87', 'i:1;', 1785493745),
('hillgo-cache-77e8208b275ff0f1bd0298da2b4d9a87:timer', 'i:1785493745;', 1785493745),
('hillgo-cache-7ad6d6ead1b97a1e41dd830857e9c7f2', 'i:1;', 1785490997),
('hillgo-cache-7ad6d6ead1b97a1e41dd830857e9c7f2:timer', 'i:1785490997;', 1785490997),
('hillgo-cache-825f54beff5d1c68aae4637bf60f828e', 'i:1;', 1785490998),
('hillgo-cache-825f54beff5d1c68aae4637bf60f828e:timer', 'i:1785490998;', 1785490998),
('hillgo-cache-8c32647d48481088715f14ed2fd0708d', 'i:1;', 1785490998),
('hillgo-cache-8c32647d48481088715f14ed2fd0708d:timer', 'i:1785490998;', 1785490998),
('hillgo-cache-8dc0217468609300bfc0c490b94e45e8', 'i:1;', 1785488768),
('hillgo-cache-8dc0217468609300bfc0c490b94e45e8:timer', 'i:1785488768;', 1785488768),
('hillgo-cache-9cfcbeb6130fbaca20d6c6ffcbdfc646', 'i:1;', 1785489264),
('hillgo-cache-9cfcbeb6130fbaca20d6c6ffcbdfc646:timer', 'i:1785489264;', 1785489264),
('hillgo-cache-a5067a9dc613b6c024452579fc006ade', 'i:1;', 1785491970),
('hillgo-cache-a5067a9dc613b6c024452579fc006ade:timer', 'i:1785491970;', 1785491970),
('hillgo-cache-cb154aff09d252f39ccf35fda5451540', 'i:1;', 1785494014),
('hillgo-cache-cb154aff09d252f39ccf35fda5451540:timer', 'i:1785494014;', 1785494014),
('hillgo-cache-pricing.courier', 'a:10:{s:10:\"parcelBase\";i:50;s:5:\"perKm\";i:12;s:5:\"perKg\";i:8;s:17:\"expressMultiplier\";d:1.4;s:18:\"priorityMultiplier\";d:1.25;s:8:\"surgeCap\";i:100;s:21:\"platformCommissionPct\";i:12;s:20:\"weeklyGoalDeliveries\";i:50;s:22:\"topPerformerMultiplier\";d:1.2;s:13:\"withdrawalMin\";i:500;}', 1785491615),
('hillgo-cache-pricing.customer', 'a:14:{s:8:\"rideBase\";i:30;s:9:\"ridePerKm\";i:15;s:10:\"ridePerMin\";i:1;s:11:\"rideMinimum\";i:50;s:15:\"foodDeliveryFee\";i:30;s:21:\"freeDeliveryThreshold\";i:300;s:10:\"parcelBase\";i:40;s:11:\"parcelPerKm\";i:12;s:11:\"parcelPerKg\";i:8;s:13:\"parcelMinimum\";i:50;s:19:\"marketplaceDelivery\";i:40;s:18:\"hotelServiceFeePct\";i:5;s:18:\"rentalDriverPerDay\";i:1500;s:21:\"rentalInsurancePerDay\";i:300;}', 1785494457),
('hillgo-cache-pricing.merchant', 'a:6:{s:21:\"platformCommissionPct\";i:15;s:15:\"orderServiceFee\";i:25;s:9:\"taxVatPct\";i:5;s:15:\"settlementCycle\";s:6:\"weekly\";s:17:\"earlyPayoutFeePct\";i:2;s:15:\"minPayoutAmount\";i:1000;}', 1785491614),
('hillgo-cache-pricing.rider', 'a:14:{s:8:\"rideBase\";i:30;s:9:\"ridePerKm\";i:15;s:10:\"ridePerMin\";i:1;s:11:\"rideMinimum\";i:50;s:14:\"bikeMultiplier\";d:0.7;s:13:\"carMultiplier\";i:1;s:12:\"xlMultiplier\";d:1.5;s:10:\"foodJobFee\";i:30;s:10:\"parcelBase\";i:40;s:11:\"parcelPerKm\";i:12;s:11:\"parcelPerKg\";i:8;s:13:\"parcelMinimum\";i:50;s:12:\"defaultSurge\";d:1.8;s:21:\"platformCommissionPct\";i:15;}', 1785494461);

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `contact_inquiries`
--

CREATE TABLE `contact_inquiries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `service_interest` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `status` enum('new','read','replied','archived') NOT NULL DEFAULT 'new',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `courier_documents`
--

CREATE TABLE `courier_documents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `courier_profile_id` bigint(20) UNSIGNED NOT NULL,
  `doc_key` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `status` enum('pending','action_required','uploaded','verified') NOT NULL DEFAULT 'pending',
  `file_path` varchar(255) DEFAULT NULL,
  `expires_at` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `courier_profiles`
--

CREATE TABLE `courier_profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `vehicle_type` varchar(255) NOT NULL DEFAULT 'Motorbike',
  `vehicle_name` varchar(255) DEFAULT NULL,
  `plate` varchar(255) DEFAULT NULL,
  `rating` decimal(3,2) NOT NULL DEFAULT 0.00,
  `deliveries_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `verified` tinyint(1) NOT NULL DEFAULT 0,
  `bank_verified` tinyint(1) NOT NULL DEFAULT 0,
  `bank_last4` varchar(8) DEFAULT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `lat` decimal(10,7) DEFAULT NULL,
  `lng` decimal(10,7) DEFAULT NULL,
  `last_location_at` timestamp NULL DEFAULT NULL,
  `balance` decimal(12,2) NOT NULL DEFAULT 0.00,
  `nid` varchar(255) DEFAULT NULL,
  `kyc_status` enum('pending','action_required','uploaded','verified','rejected') NOT NULL DEFAULT 'pending',
  `kyc_submitted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `courier_profiles`
--

INSERT INTO `courier_profiles` (`id`, `user_id`, `code`, `vehicle_type`, `vehicle_name`, `plate`, `rating`, `deliveries_count`, `verified`, `bank_verified`, `bank_last4`, `online`, `lat`, `lng`, `last_location_at`, `balance`, `nid`, `kyc_status`, `kyc_submitted_at`, `created_at`, `updated_at`) VALUES
(1, 7, 'CG-FJZ1TG3', 'Motorbike', 'Demo Bike', 'DHAKA-DEMO-04', 0.00, 0, 1, 0, NULL, 0, NULL, NULL, NULL, 0.00, NULL, 'verified', NULL, '2026-07-31 03:42:06', '2026-07-31 03:42:06');

-- --------------------------------------------------------

--
-- Table structure for table `courier_withdrawals`
--

CREATE TABLE `courier_withdrawals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `courier_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `method` varchar(255) NOT NULL DEFAULT 'bKash',
  `bank_last4` varchar(8) DEFAULT NULL,
  `status` enum('pending','approved','rejected','paid') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customer_profiles`
--

CREATE TABLE `customer_profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `tier` varchar(255) NOT NULL DEFAULT 'Bronze',
  `wallet_balance` decimal(12,2) NOT NULL DEFAULT 0.00,
  `loyalty_points` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `orders_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `rating` decimal(3,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `customer_profiles`
--

INSERT INTO `customer_profiles` (`id`, `user_id`, `code`, `tier`, `wallet_balance`, `loyalty_points`, `orders_count`, `rating`, `created_at`, `updated_at`) VALUES
(1, 4, 'HG-FJYVSF0', 'Bronze', 500.00, 12, 0, 0.00, '2026-07-31 03:42:05', '2026-07-31 10:39:01');

-- --------------------------------------------------------

--
-- Table structure for table `districts`
--

CREATE TABLE `districts` (
  `id` varchar(255) NOT NULL,
  `division_id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `status` enum('open','closed') NOT NULL DEFAULT 'closed',
  `opened_at` timestamp NULL DEFAULT NULL,
  `allow_customer` tinyint(1) NOT NULL DEFAULT 0,
  `allow_rider` tinyint(1) NOT NULL DEFAULT 0,
  `allow_merchant` tinyint(1) NOT NULL DEFAULT 0,
  `allow_courier` tinyint(1) NOT NULL DEFAULT 0,
  `note` varchar(255) NOT NULL DEFAULT '',
  `updated_by` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `districts`
--

INSERT INTO `districts` (`id`, `division_id`, `name`, `status`, `opened_at`, `allow_customer`, `allow_rider`, `allow_merchant`, `allow_courier`, `note`, `updated_by`, `created_at`, `updated_at`) VALUES
('barishal__barguna', 'barishal', 'Barguna', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('barishal__barishal', 'barishal', 'Barishal', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('barishal__bhola', 'barishal', 'Bhola', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('barishal__jhalokathi', 'barishal', 'Jhalokathi', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('barishal__patuakhali', 'barishal', 'Patuakhali', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('barishal__pirojpur', 'barishal', 'Pirojpur', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__bandarban', 'chattogram', 'Bandarban', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__brahmanbaria', 'chattogram', 'Brahmanbaria', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__chandpur', 'chattogram', 'Chandpur', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__chattogram', 'chattogram', 'Chattogram', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__coxs-bazar', 'chattogram', 'Cox\'s Bazar', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__cumilla', 'chattogram', 'Cumilla', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__feni', 'chattogram', 'Feni', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__khagrachhari', 'chattogram', 'Khagrachhari', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__lakshmipur', 'chattogram', 'Lakshmipur', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__noakhali', 'chattogram', 'Noakhali', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__rangamati', 'chattogram', 'Rangamati', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__dhaka', 'dhaka', 'Dhaka', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__faridpur', 'dhaka', 'Faridpur', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__gazipur', 'dhaka', 'Gazipur', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__gopalganj', 'dhaka', 'Gopalganj', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__kishoreganj', 'dhaka', 'Kishoreganj', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__madaripur', 'dhaka', 'Madaripur', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__manikganj', 'dhaka', 'Manikganj', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__munshiganj', 'dhaka', 'Munshiganj', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__narayanganj', 'dhaka', 'Narayanganj', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__narsingdi', 'dhaka', 'Narsingdi', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__rajbari', 'dhaka', 'Rajbari', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__shariatpur', 'dhaka', 'Shariatpur', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__tangail', 'dhaka', 'Tangail', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('khulna__bagerhat', 'khulna', 'Bagerhat', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('khulna__chuadanga', 'khulna', 'Chuadanga', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('khulna__jashore', 'khulna', 'Jashore', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('khulna__jhenaidah', 'khulna', 'Jhenaidah', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('khulna__khulna', 'khulna', 'Khulna', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('khulna__kushtia', 'khulna', 'Kushtia', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('khulna__magura', 'khulna', 'Magura', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('khulna__meherpur', 'khulna', 'Meherpur', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('khulna__narail', 'khulna', 'Narail', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('khulna__satkhira', 'khulna', 'Satkhira', 'open', '2026-07-31 01:56:43', 1, 1, 1, 1, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('mymensingh__jamalpur', 'mymensingh', 'Jamalpur', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('mymensingh__mymensingh', 'mymensingh', 'Mymensingh', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('mymensingh__netrokona', 'mymensingh', 'Netrokona', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('mymensingh__sherpur', 'mymensingh', 'Sherpur', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__bogura', 'rajshahi', 'Bogura', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__chapainawabganj', 'rajshahi', 'Chapainawabganj', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__joypurhat', 'rajshahi', 'Joypurhat', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__naogaon', 'rajshahi', 'Naogaon', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__natore', 'rajshahi', 'Natore', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__pabna', 'rajshahi', 'Pabna', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__rajshahi', 'rajshahi', 'Rajshahi', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__sirajganj', 'rajshahi', 'Sirajganj', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__dinajpur', 'rangpur', 'Dinajpur', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__gaibandha', 'rangpur', 'Gaibandha', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__kurigram', 'rangpur', 'Kurigram', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__lalmonirhat', 'rangpur', 'Lalmonirhat', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__nilphamari', 'rangpur', 'Nilphamari', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__panchagarh', 'rangpur', 'Panchagarh', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__rangpur', 'rangpur', 'Rangpur', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__thakurgaon', 'rangpur', 'Thakurgaon', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('sylhet__habiganj', 'sylhet', 'Habiganj', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('sylhet__moulvibazar', 'sylhet', 'Moulvibazar', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('sylhet__sunamganj', 'sylhet', 'Sunamganj', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('sylhet__sylhet', 'sylhet', 'Sylhet', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', '2026-07-31 01:56:43', '2026-07-31 01:56:43');

-- --------------------------------------------------------

--
-- Table structure for table `divisions`
--

CREATE TABLE `divisions` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `zone` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `divisions`
--

INSERT INTO `divisions` (`id`, `name`, `zone`, `created_at`, `updated_at`) VALUES
('barishal', 'Barishal', 'Southern', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram', 'Chattogram', 'Coastal Hub', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka', 'Dhaka', 'Central Hub', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('khulna', 'Khulna', 'Southwest', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('mymensingh', 'Mymensingh', 'North-Central', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi', 'Rajshahi', 'Northwest', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur', 'Rangpur', 'Northern Zone', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('sylhet', 'Sylhet', 'Northeast', '2026-07-31 01:56:43', '2026-07-31 01:56:43');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` varchar(255) NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `faqs`
--

CREATE TABLE `faqs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category` varchar(255) NOT NULL DEFAULT 'General',
  `question` varchar(255) NOT NULL,
  `answer` text NOT NULL,
  `sort` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hotels`
--

CREATE TABLE `hotels` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `location` varchar(255) NOT NULL,
  `rating` decimal(3,2) NOT NULL DEFAULT 0.00,
  `stars` tinyint(3) UNSIGNED NOT NULL DEFAULT 3,
  `price_per_night` decimal(12,2) NOT NULL,
  `amenities` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`amenities`)),
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `reviews_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hotel_bookings`
--

CREATE TABLE `hotel_bookings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `check_in` date NOT NULL,
  `check_out` date NOT NULL,
  `nights` smallint(5) UNSIGNED NOT NULL,
  `guests` smallint(5) UNSIGNED NOT NULL DEFAULT 1,
  `rooms` smallint(5) UNSIGNED NOT NULL DEFAULT 1,
  `guest_name` varchar(255) NOT NULL,
  `guest_phone` varchar(255) NOT NULL,
  `room_total` decimal(12,2) NOT NULL,
  `service_fee` decimal(12,2) NOT NULL,
  `total` decimal(12,2) NOT NULL,
  `status` enum('upcoming','completed','cancelled') NOT NULL DEFAULT 'upcoming',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `incentives`
--

CREATE TABLE `incentives` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL DEFAULT '',
  `multiplier` decimal(4,2) NOT NULL DEFAULT 1.00,
  `district` varchar(255) NOT NULL DEFAULT '',
  `goal_deliveries` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `bonus_tk` decimal(12,2) NOT NULL DEFAULT 0.00,
  `valid_until` date DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `incentive_enrollments`
--

CREATE TABLE `incentive_enrollments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `incentive_id` bigint(20) UNSIGNED NOT NULL,
  `courier_id` bigint(20) UNSIGNED NOT NULL,
  `progress` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `completed` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` smallint(5) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_redemptions`
--

CREATE TABLE `loyalty_redemptions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `reward_id` bigint(20) UNSIGNED NOT NULL,
  `points` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_rewards`
--

CREATE TABLE `loyalty_rewards` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL DEFAULT '',
  `points` int(10) UNSIGNED NOT NULL,
  `type` varchar(255) NOT NULL DEFAULT 'voucher',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `loyalty_rewards`
--

INSERT INTO `loyalty_rewards` (`id`, `title`, `description`, `points`, `type`, `active`, `created_at`, `updated_at`) VALUES
(1, 'Delivery voucher', '৳50 off any delivery', 500, 'voucher', 1, '2026-07-31 01:56:44', '2026-07-31 01:56:44'),
(2, 'Free delivery pass', 'One free delivery', 800, 'voucher', 1, '2026-07-31 01:56:44', '2026-07-31 01:56:44'),
(3, 'Marketplace coupon', '৳100 marketplace coupon', 1200, 'voucher', 1, '2026-07-31 01:56:44', '2026-07-31 01:56:44'),
(4, 'Priority support', '30 days priority support', 1500, 'entitlement', 1, '2026-07-31 01:56:44', '2026-07-31 01:56:44');

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_tiers`
--

CREATE TABLE `loyalty_tiers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `threshold` int(10) UNSIGNED NOT NULL,
  `sort` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `loyalty_tiers`
--

INSERT INTO `loyalty_tiers` (`id`, `name`, `threshold`, `sort`, `created_at`, `updated_at`) VALUES
(1, 'Bronze', 0, 0, '2026-07-31 01:56:44', '2026-07-31 01:56:44'),
(2, 'Silver', 1000, 1, '2026-07-31 01:56:44', '2026-07-31 01:56:44'),
(3, 'Gold', 2000, 2, '2026-07-31 01:56:44', '2026-07-31 01:56:44'),
(4, 'Platinum', 5000, 3, '2026-07-31 01:56:44', '2026-07-31 01:56:44');

-- --------------------------------------------------------

--
-- Table structure for table `merchant_onboardings`
--

CREATE TABLE `merchant_onboardings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `business_name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `owner` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `subcategories` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`subcategories`)),
  `phone` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `district_id` varchar(255) DEFAULT NULL,
  `zip` varchar(16) DEFAULT NULL,
  `docs` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`docs`)),
  `logo_path` varchar(255) DEFAULT NULL,
  `storefront_path` varchar(255) DEFAULT NULL,
  `status` enum('pending','changes_requested','approved','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `merchant_onboardings`
--

INSERT INTO `merchant_onboardings` (`id`, `store_id`, `user_id`, `business_name`, `description`, `owner`, `category`, `subcategories`, `phone`, `email`, `address`, `city`, `district_id`, `zip`, `docs`, `logo_path`, `storefront_path`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 6, 'Demo Kitchen', 'HillGo demo merchant store', 'Demo Merchant', 'Restaurant', NULL, '+8801710000003', 'merchant@demo.hillgo.app', 'Gulshan 1, Dhaka', 'Dhaka', 'dhaka__dhaka', NULL, NULL, NULL, NULL, 'approved', '2026-07-31 03:42:05', '2026-07-31 03:42:05');

-- --------------------------------------------------------

--
-- Table structure for table `merchant_payouts`
--

CREATE TABLE `merchant_payouts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `method` varchar(255) NOT NULL DEFAULT 'Bank',
  `status` enum('pending','processing','completed','rejected') NOT NULL DEFAULT 'pending',
  `early_request` tinyint(1) NOT NULL DEFAULT 0,
  `fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_07_31_070935_create_personal_access_tokens_table', 1),
(5, '2026_07_31_100001_create_core_tables', 1),
(6, '2026_07_31_100002_create_customer_tables', 1),
(7, '2026_07_31_100003_create_rider_merchant_tables', 1),
(8, '2026_07_31_100004_create_ops_tables', 1),
(9, '2026_07_31_100005_create_public_web_tables', 1),
(10, '2026_07_31_100006_add_prefs_to_users', 1),
(11, '2026_07_31_120000_make_users_email_nullable', 2);

-- --------------------------------------------------------

--
-- Table structure for table `newsletter_subscribers`
--

CREATE TABLE `newsletter_subscribers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `channel` enum('food','marketplace') NOT NULL DEFAULT 'food',
  `priority` enum('standard','express','priority','scheduled') NOT NULL DEFAULT 'standard',
  `scheduled_for` timestamp NULL DEFAULT NULL,
  `status` enum('new_order','preparing','ready','on_the_way','delivered','rejected','cancelled') NOT NULL DEFAULT 'new_order',
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `service_fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `tax` decimal(12,2) NOT NULL DEFAULT 0.00,
  `delivery_fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `discount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `payment_method` varchar(255) NOT NULL DEFAULT 'cash',
  `delivery_address` varchar(255) DEFAULT NULL,
  `customer_note` varchar(255) DEFAULT NULL,
  `promo_code` varchar(255) DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `rating` tinyint(3) UNSIGNED DEFAULT NULL,
  `district_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `qty` int(10) UNSIGNED NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `otp_codes`
--

CREATE TABLE `otp_codes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `phone` varchar(255) NOT NULL,
  `role` varchar(32) NOT NULL,
  `purpose` varchar(32) NOT NULL DEFAULT 'login',
  `code_hash` varchar(255) NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `consumed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `otp_codes`
--

INSERT INTO `otp_codes` (`id`, `phone`, `role`, `purpose`, `code_hash`, `attempts`, `expires_at`, `consumed_at`, `created_at`, `updated_at`) VALUES
(1, '+8801710000001', 'customer', 'login', '$2y$12$w9OLNBKbPB5CoiqSQoJ99OB//EBDWjJk5CYRJSRuUlmUSzaOpZXme', 0, '2026-07-31 03:47:18', NULL, '2026-07-31 03:42:18', '2026-07-31 03:42:18'),
(4, '+8801710000002', 'rider', 'login', '$2y$12$jqSwKkncug3hQpYwQULidOIpQ7YsupHlO8oMfN.Yo0p5l2cU1Dt/G', 0, '2026-07-31 04:03:30', NULL, '2026-07-31 03:58:30', '2026-07-31 03:58:30');

-- --------------------------------------------------------

--
-- Table structure for table `parcels`
--

CREATE TABLE `parcels` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `customer_id` bigint(20) UNSIGNED DEFAULT NULL,
  `type` varchar(255) NOT NULL DEFAULT 'Box',
  `priority` enum('standard','express','priority') NOT NULL DEFAULT 'standard',
  `fulfillment_channel` enum('courier','rider') NOT NULL DEFAULT 'courier',
  `courier_id` bigint(20) UNSIGNED DEFAULT NULL,
  `rider_id` bigint(20) UNSIGNED DEFAULT NULL,
  `sender_name` varchar(255) DEFAULT NULL,
  `sender_phone` varchar(255) DEFAULT NULL,
  `pickup_address` varchar(255) NOT NULL,
  `pickup_lat` decimal(10,7) DEFAULT NULL,
  `pickup_lng` decimal(10,7) DEFAULT NULL,
  `receiver_name` varchar(255) DEFAULT NULL,
  `receiver_phone` varchar(255) DEFAULT NULL,
  `drop_address` varchar(255) NOT NULL,
  `drop_lat` decimal(10,7) DEFAULT NULL,
  `drop_lng` decimal(10,7) DEFAULT NULL,
  `weight_kg` decimal(8,2) NOT NULL DEFAULT 0.50,
  `distance_km` decimal(8,2) NOT NULL DEFAULT 0.00,
  `fare` decimal(12,2) NOT NULL DEFAULT 0.00,
  `earnings` decimal(12,2) NOT NULL DEFAULT 0.00,
  `surge_bonus` decimal(12,2) NOT NULL DEFAULT 0.00,
  `status` enum('booked','assigned','picked_up','in_transit','delivered','failed','cancelled') NOT NULL DEFAULT 'booked',
  `pickup_otp_hash` varchar(255) DEFAULT NULL,
  `delivery_otp_hash` varchar(255) DEFAULT NULL,
  `fail_reason` varchar(255) DEFAULT NULL,
  `fragile` tinyint(1) NOT NULL DEFAULT 0,
  `notes` varchar(255) DEFAULT NULL,
  `payment_method` varchar(255) NOT NULL DEFAULT 'cash',
  `picked_up_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `district_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `parcel_otp_logs`
--

CREATE TABLE `parcel_otp_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `parcel_id` bigint(20) UNSIGNED NOT NULL,
  `stage` enum('pickup','delivery') NOT NULL,
  `success` tinyint(1) NOT NULL,
  `by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `parcel_proofs`
--

CREATE TABLE `parcel_proofs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `parcel_id` bigint(20) UNSIGNED NOT NULL,
  `type` enum('photo','signature') NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `partner_applications`
--

CREATE TABLE `partner_applications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `phone` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `vehicle_type` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `district_id` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `rider_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payment_methods`
--

CREATE TABLE `payment_methods` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `type` varchar(255) NOT NULL,
  `label` varchar(255) NOT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details`)),
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 1, 'admin', 'bc59cc1ef87c4f66be4564b8637f34b5b9417ab15c216afa2924539af20f866b', '[\"*\"]', '2026-07-31 04:05:35', NULL, '2026-07-31 02:14:17', '2026-07-31 04:05:35'),
(2, 'App\\Models\\User', 1, 'admin', 'cab70132f8c70c4c94e159cec8c87aab6645ac94c90572d37bd2a2d22c032749', '[\"*\"]', NULL, NULL, '2026-07-31 02:25:08', '2026-07-31 02:25:08'),
(3, 'App\\Models\\User', 2, 'rider', '6caa6b0a9c0f5942d50fa97fc22323e64b4d2561ce5ca6aac14240879bd800e2', '[\"*\"]', '2026-07-31 02:43:50', NULL, '2026-07-31 02:43:50', '2026-07-31 02:43:50'),
(4, 'App\\Models\\User', 3, 'rider', 'eddabcca246bbb47d2ed241e9a2a95a7b7b5f6f49a0e2f46427da6a42f07a883', '[\"*\"]', '2026-07-31 02:44:08', NULL, '2026-07-31 02:44:08', '2026-07-31 02:44:08'),
(5, 'App\\Models\\User', 1, 'admin', '5c33bc2ecbd632e8f08a79b787ab2cdf0c22cbda91389efc0aafc17a443c83a9', '[\"*\"]', '2026-07-31 03:05:07', NULL, '2026-07-31 03:05:07', '2026-07-31 03:05:07'),
(6, 'App\\Models\\User', 1, 'admin', 'affc24356f00da43fa7eef7d5c686ec8f3632425d2d7218baaa545e3d9a4ba75', '[\"*\"]', NULL, NULL, '2026-07-31 03:42:17', '2026-07-31 03:42:17'),
(7, 'App\\Models\\User', 4, 'customer', 'a301cc3c232e45ddc8fd558c6bf0acd71487a2c6eb9b299a26a3c3016ea8f188', '[\"*\"]', NULL, NULL, '2026-07-31 03:42:17', '2026-07-31 03:42:17'),
(8, 'App\\Models\\User', 6, 'merchant', '2f1b822a62867074c46a79252b35b4c83b8a5cad91fe96773112a2d7d57bab95', '[\"*\"]', NULL, NULL, '2026-07-31 03:42:18', '2026-07-31 03:42:18'),
(9, 'App\\Models\\User', 7, 'courier_agent', '2e6184b2fa22ea8604b50dd48c0acbc4d8cedcab06c1e7340497f0d1848c5de3', '[\"*\"]', NULL, NULL, '2026-07-31 03:42:18', '2026-07-31 03:42:18'),
(10, 'App\\Models\\User', 4, 'customer', '7b20183c787e50d4dd95bed334ca1003e3f322011ab1e7609f84b0141ce32860', '[\"*\"]', NULL, NULL, '2026-07-31 03:42:18', '2026-07-31 03:42:18'),
(11, 'App\\Models\\User', 5, 'rider', 'edf089ea3e69e1c5f6bd7a2a598e821ee9cd604c0db16a0bd8af9b952f3b6f03', '[\"*\"]', NULL, NULL, '2026-07-31 03:42:19', '2026-07-31 03:42:19'),
(12, 'App\\Models\\User', 4, 'customer', 'b712c2b23bcb6863f98023ad222d3327207881fe242579d0b437ae950f8aeeb3', '[\"*\"]', '2026-07-31 03:59:35', NULL, '2026-07-31 03:43:11', '2026-07-31 03:59:35'),
(13, 'App\\Models\\User', 5, 'rider', 'f90f1ece2afd17b54d4a3c90a9b708f32985b8fd068b02db055bae36e58c3fdd', '[\"*\"]', '2026-07-31 10:19:32', NULL, '2026-07-31 03:43:39', '2026-07-31 10:19:32'),
(14, 'App\\Models\\User', 6, 'merchant', '4f34d2c86fd37cd7ecbbf313aeab753cae0390e5a9664ec234941ee3833082df', '[\"*\"]', '2026-07-31 04:00:22', NULL, '2026-07-31 03:51:23', '2026-07-31 04:00:22'),
(15, 'App\\Models\\User', 4, 'customer', 'ced23e2cb8a0eedf6a25e6bb09e03b48aa721396bd2268a2bb3cd019672b859b', '[\"*\"]', '2026-07-31 03:57:20', NULL, '2026-07-31 03:57:19', '2026-07-31 03:57:20'),
(16, 'App\\Models\\User', 5, 'rider', 'ff41a83208b0b7bb15ed2df327ec7cd45bff165984ad49911278e1301198f048', '[\"*\"]', '2026-07-31 03:57:21', NULL, '2026-07-31 03:57:20', '2026-07-31 03:57:21'),
(17, 'App\\Models\\User', 5, 'rider', '208a27c2ed1dc6712d63d53f2ee34c494943dadaaa9e5e0efe541ad1b1ea509d', '[\"*\"]', '2026-07-31 10:41:07', NULL, '2026-07-31 03:58:34', '2026-07-31 10:41:07'),
(18, 'App\\Models\\User', 4, 'customer', 'bdb97b41e4ad4c8138c8f96c977451c3f932fa039fbd6a761857f4d86bf67674', '[\"*\"]', '2026-07-31 10:40:19', NULL, '2026-07-31 04:13:02', '2026-07-31 10:40:19'),
(19, 'App\\Models\\User', 5, 'rider', '22edf63f63c857a75e1ffc8cba38fbda1819fa177bf579cd5076cd7872322b9c', '[\"*\"]', '2026-07-31 04:17:18', NULL, '2026-07-31 04:17:18', '2026-07-31 04:17:18'),
(20, 'App\\Models\\User', 5, 'rider', '644c244d3584546358fc1bf0c5c854bcab844355497bff0f86d94730be9dda49', '[\"*\"]', '2026-07-31 10:19:13', NULL, '2026-07-31 10:19:12', '2026-07-31 10:19:13'),
(21, 'App\\Models\\User', 5, 'rider', 'ebff6de984cee04937cc164c3a73c931246ae9e7b002d7406a496578f1db1ff4', '[\"*\"]', '2026-07-31 10:22:16', NULL, '2026-07-31 10:22:16', '2026-07-31 10:22:16'),
(22, 'App\\Models\\User', 5, 'rider', '07de0092d2fe16603780a46a3b0353501fa2bc7135243a6a40a3536b11a8ad78', '[\"*\"]', '2026-07-31 10:26:16', NULL, '2026-07-31 10:26:15', '2026-07-31 10:26:16'),
(23, 'App\\Models\\User', 4, 'customer', '14d24cdd82f6dc41b19ea2a479bb2b994148e000716cdbf2c77979649894c63a', '[\"*\"]', '2026-07-31 10:26:36', NULL, '2026-07-31 10:26:16', '2026-07-31 10:26:36'),
(24, 'App\\Models\\User', 5, 'rider', 'b80666bd7d448262536331cbec345e9ea0735990b0bece82ad39d2f59fb3e377', '[\"*\"]', '2026-07-31 10:28:05', NULL, '2026-07-31 10:28:04', '2026-07-31 10:28:05'),
(25, 'App\\Models\\User', 4, 'customer', 'f0cba863ea7e62f1167fbc13b812efd47cfc0679eb77ffb152e436eda17f5e52', '[\"*\"]', '2026-07-31 10:28:05', NULL, '2026-07-31 10:28:05', '2026-07-31 10:28:05'),
(26, 'App\\Models\\User', 5, 'rider', '2949a76a4d81e0d4c2be9adf6ccbab21218a2e7180b7d555abaf87d73b448100', '[\"*\"]', '2026-07-31 10:31:26', NULL, '2026-07-31 10:31:26', '2026-07-31 10:31:26'),
(27, 'App\\Models\\User', 5, 'rider', '2adbd73a2254d0d2572c9cf38ad099377bfbcc8fde13b8698f75c9398616dda9', '[\"*\"]', '2026-07-31 10:32:04', NULL, '2026-07-31 10:32:04', '2026-07-31 10:32:04'),
(28, 'App\\Models\\User', 5, 'rider', '6a861309090aee2d0498059e87871e0ebfeeff0f33e1eb42b2a977c67e811cf7', '[\"*\"]', '2026-07-31 10:32:35', NULL, '2026-07-31 10:32:35', '2026-07-31 10:32:35');

-- --------------------------------------------------------

--
-- Table structure for table `pricing_audits`
--

CREATE TABLE `pricing_audits` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `panel` varchar(255) NOT NULL,
  `field` varchar(255) NOT NULL,
  `old_value` varchar(255) DEFAULT NULL,
  `new_value` varchar(255) DEFAULT NULL,
  `by` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pricing_settings`
--

CREATE TABLE `pricing_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `panel` varchar(255) NOT NULL,
  `values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`values`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pricing_settings`
--

INSERT INTO `pricing_settings` (`id`, `panel`, `values`, `created_at`, `updated_at`) VALUES
(1, 'customer', '{\"rideBase\":30,\"ridePerKm\":15,\"ridePerMin\":1,\"rideMinimum\":50,\"foodDeliveryFee\":30,\"freeDeliveryThreshold\":300,\"parcelBase\":40,\"parcelPerKm\":12,\"parcelPerKg\":8,\"parcelMinimum\":50,\"marketplaceDelivery\":40,\"hotelServiceFeePct\":5,\"rentalDriverPerDay\":1500,\"rentalInsurancePerDay\":300}', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
(2, 'rider', '{\"rideBase\":30,\"ridePerKm\":15,\"ridePerMin\":1,\"rideMinimum\":50,\"bikeMultiplier\":0.7,\"carMultiplier\":1,\"xlMultiplier\":1.5,\"foodJobFee\":30,\"parcelBase\":40,\"parcelPerKm\":12,\"parcelPerKg\":8,\"parcelMinimum\":50,\"defaultSurge\":1.8,\"platformCommissionPct\":15}', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
(3, 'merchant', '{\"platformCommissionPct\":15,\"orderServiceFee\":25,\"taxVatPct\":5,\"settlementCycle\":\"weekly\",\"earlyPayoutFeePct\":2,\"minPayoutAmount\":1000}', '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
(4, 'courier', '{\"parcelBase\":50,\"perKm\":12,\"perKg\":8,\"expressMultiplier\":1.4,\"priorityMultiplier\":1.25,\"surgeCap\":100,\"platformCommissionPct\":12,\"weeklyGoalDeliveries\":50,\"topPerformerMultiplier\":1.2,\"withdrawalMin\":500}', '2026-07-31 01:56:43', '2026-07-31 01:56:43');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(12,2) NOT NULL,
  `sku` varchar(255) DEFAULT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `low_stock_alert` int(11) NOT NULL DEFAULT 5,
  `track_stock` tinyint(1) NOT NULL DEFAULT 0,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `status` enum('active','hidden') NOT NULL DEFAULT 'active',
  `marketplace_category` varchar(255) DEFAULT NULL,
  `rating` decimal(3,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product_categories`
--

CREATE TABLE `product_categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `color` varchar(16) DEFAULT NULL,
  `is_visible` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `promos`
--

CREATE TABLE `promos` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL DEFAULT '',
  `code` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `min_order_tk` decimal(10,2) NOT NULL DEFAULT 0.00,
  `expires_at` date DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `usage_limit` int(10) UNSIGNED DEFAULT NULL,
  `used_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rental_bookings`
--

CREATE TABLE `rental_bookings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `vehicle_id` bigint(20) UNSIGNED NOT NULL,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `pickup_location` varchar(255) NOT NULL,
  `dropoff_location` varchar(255) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `days` smallint(5) UNSIGNED NOT NULL,
  `with_driver` tinyint(1) NOT NULL DEFAULT 0,
  `renter_name` varchar(255) NOT NULL,
  `renter_phone` varchar(255) NOT NULL,
  `vehicle_total` decimal(12,2) NOT NULL,
  `driver_fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `insurance_fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL,
  `status` enum('upcoming','completed','cancelled') NOT NULL DEFAULT 'upcoming',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rental_vehicles`
--

CREATE TABLE `rental_vehicles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `price_per_day` decimal(12,2) NOT NULL,
  `seats` tinyint(3) UNSIGNED NOT NULL DEFAULT 4,
  `transmission` varchar(255) NOT NULL DEFAULT 'Manual',
  `fuel` varchar(255) NOT NULL DEFAULT 'Petrol',
  `rating` decimal(3,2) NOT NULL DEFAULT 0.00,
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `features` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`features`)),
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `rating` tinyint(3) UNSIGNED NOT NULL,
  `comment` text DEFAULT NULL,
  `verified` tinyint(1) NOT NULL DEFAULT 1,
  `reply` text DEFAULT NULL,
  `replied_at` timestamp NULL DEFAULT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `hidden` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rider_documents`
--

CREATE TABLE `rider_documents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `rider_profile_id` bigint(20) UNSIGNED NOT NULL,
  `doc_key` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `status` enum('pending','action_required','uploaded','verified') NOT NULL DEFAULT 'pending',
  `file_path` varchar(255) DEFAULT NULL,
  `token_number` varchar(255) DEFAULT NULL,
  `note` varchar(255) NOT NULL DEFAULT '',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rider_payouts`
--

CREATE TABLE `rider_payouts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `rider_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `method` varchar(255) NOT NULL DEFAULT 'bKash',
  `period_from` date DEFAULT NULL,
  `period_to` date DEFAULT NULL,
  `ref` varchar(255) NOT NULL DEFAULT '',
  `tips` decimal(12,2) NOT NULL DEFAULT 0.00,
  `surge` decimal(12,2) NOT NULL DEFAULT 0.00,
  `deductions` decimal(12,2) NOT NULL DEFAULT 0.00,
  `note` varchar(255) NOT NULL DEFAULT '',
  `status` enum('pending','processing','paid','rejected') NOT NULL DEFAULT 'pending',
  `source` enum('admin_salary','cash_out') NOT NULL DEFAULT 'admin_salary',
  `paid_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rider_profiles`
--

CREATE TABLE `rider_profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `vehicle_type` enum('bike','car','xl') DEFAULT NULL,
  `vehicle_make` varchar(255) DEFAULT NULL,
  `vehicle_model` varchar(255) DEFAULT NULL,
  `vehicle_year` varchar(8) DEFAULT NULL,
  `plate` varchar(255) DEFAULT NULL,
  `vehicle_photo` varchar(255) DEFAULT NULL,
  `rating` decimal(3,2) NOT NULL DEFAULT 0.00,
  `rating_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `lat` decimal(10,7) DEFAULT NULL,
  `lng` decimal(10,7) DEFAULT NULL,
  `last_location_at` timestamp NULL DEFAULT NULL,
  `online_since` timestamp NULL DEFAULT NULL,
  `online_seconds_today` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `balance` decimal(12,2) NOT NULL DEFAULT 0.00,
  `payout_method` varchar(255) NOT NULL DEFAULT 'bKash',
  `kyc_status` enum('pending','action_required','uploaded','verified','rejected') NOT NULL DEFAULT 'pending',
  `kyc_priority` tinyint(1) NOT NULL DEFAULT 0,
  `kyc_flagged` tinyint(1) NOT NULL DEFAULT 0,
  `kyc_submitted_at` timestamp NULL DEFAULT NULL,
  `legal_name` varchar(255) DEFAULT NULL,
  `home_address` varchar(255) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `nid` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rider_profiles`
--

INSERT INTO `rider_profiles` (`id`, `user_id`, `code`, `vehicle_type`, `vehicle_make`, `vehicle_model`, `vehicle_year`, `plate`, `vehicle_photo`, `rating`, `rating_count`, `online`, `lat`, `lng`, `last_location_at`, `online_since`, `online_seconds_today`, `balance`, `payout_method`, `kyc_status`, `kyc_priority`, `kyc_flagged`, `kyc_submitted_at`, `legal_name`, `home_address`, `dob`, `nid`, `created_at`, `updated_at`) VALUES
(1, 2, 'HG-RD-EZ5QLM1', 'car', 'Toyota', 'Axio', '2020', 'DHK-1234', NULL, 0.00, 0, 0, NULL, NULL, NULL, NULL, 0, 0.00, 'bKash', 'pending', 0, 0, NULL, 'Smoke Test Rider', 'House 1, Road 2, Gulshan', '1995-05-10', '1234567890123', '2026-07-31 02:43:50', '2026-07-31 02:43:50'),
(2, 3, 'HG-RD-EZ9M149', NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0, 0, NULL, NULL, NULL, NULL, 0, 0.00, 'bKash', 'pending', 0, 0, NULL, NULL, NULL, NULL, NULL, '2026-07-31 02:44:08', '2026-07-31 02:44:08'),
(3, 5, 'HG-RD-FJYXT84', 'bike', 'Honda', 'CB', NULL, 'DHAKA-DEMO-02', NULL, 0.00, 0, 1, NULL, NULL, NULL, '2026-07-31 10:32:04', 179, 0.00, 'bKash', 'verified', 0, 0, NULL, 'Demo Rider', NULL, NULL, NULL, '2026-07-31 03:42:05', '2026-07-31 10:32:04');

-- --------------------------------------------------------

--
-- Table structure for table `rides`
--

CREATE TABLE `rides` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `rider_id` bigint(20) UNSIGNED DEFAULT NULL,
  `vehicle_type` enum('bike','car','xl') NOT NULL DEFAULT 'bike',
  `pickup` varchar(255) NOT NULL,
  `drop` varchar(255) NOT NULL,
  `pickup_lat` decimal(10,7) DEFAULT NULL,
  `pickup_lng` decimal(10,7) DEFAULT NULL,
  `drop_lat` decimal(10,7) DEFAULT NULL,
  `drop_lng` decimal(10,7) DEFAULT NULL,
  `distance_km` decimal(8,2) NOT NULL DEFAULT 0.00,
  `duration_min` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `fare` decimal(12,2) NOT NULL DEFAULT 0.00,
  `surge` decimal(4,2) NOT NULL DEFAULT 1.00,
  `status` enum('searching','assigned','in_progress','completed','cancelled') NOT NULL DEFAULT 'searching',
  `payment_method` varchar(255) NOT NULL DEFAULT 'cash',
  `rating` tinyint(3) UNSIGNED DEFAULT NULL,
  `rating_comment` varchar(255) DEFAULT NULL,
  `cancel_reason` varchar(255) DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `district_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rides`
--

INSERT INTO `rides` (`id`, `code`, `customer_id`, `rider_id`, `vehicle_type`, `pickup`, `drop`, `pickup_lat`, `pickup_lng`, `drop_lat`, `drop_lng`, `distance_km`, `duration_min`, `fare`, `surge`, `status`, `payment_method`, `rating`, `rating_comment`, `cancel_reason`, `completed_at`, `district_id`, `created_at`, `updated_at`) VALUES
(1, 'RID-FKWJSD4', 4, NULL, 'bike', 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 'Mymensingh, Mymensingh Sadar Upazila, Mymensingh District, Mymensingh Division, 2200, Bangladesh', 24.9454341, 90.6011677, 24.7482129, 90.4099158, 35.07, 41, 418.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled while searching', NULL, 'dhaka__dhaka', '2026-07-31 03:44:42', '2026-07-31 03:45:47'),
(2, 'RID-FLLHWC7', 4, NULL, 'bike', 'Hazrat Shahjalal International Airport, Airport Road, MODC Mess Road, Barontek, Manikdi, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Uttara, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1231, Bangladesh', 23.8431441, 90.4053032, 23.8693275, 90.3926893, 3.84, 5, 65.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled while searching', NULL, 'dhaka__dhaka', '2026-07-31 03:46:38', '2026-07-31 03:54:44'),
(3, 'RID-FOICS20', 4, 5, 'bike', 'Hazrat Shahjalal International Airport, Airport Road, MODC Mess Road, Barontek, Manikdi, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Uttara, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1231, Bangladesh', 23.8431441, 90.4053032, 23.8693275, 90.3926893, 3.84, 5, 65.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'pre-bot cleanup', NULL, 'dhaka__dhaka', '2026-07-31 03:54:47', '2026-07-31 10:26:16'),
(4, 'RID-FOTMK62', 4, NULL, 'bike', 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 'Dhaka District, Dhaka Division, Bangladesh', 24.9447390, 90.6015203, 23.7804927, 90.3582974, 155.05, 130, 1740.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled while searching', NULL, 'dhaka__dhaka', '2026-07-31 03:55:40', '2026-07-31 03:59:05'),
(5, 'RID-FPF0ID0', 4, NULL, 'bike', 'Gulshan 1, Dhaka', 'Banani, Dhaka', 23.7808000, 90.4142000, 23.7936000, 90.4066000, 3.20, 12, 63.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'pre-bot cleanup', NULL, 'dhaka__dhaka', '2026-07-31 03:57:20', '2026-07-31 10:19:12'),
(6, 'RID-FQ1XIG2', 4, NULL, 'bike', 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 'Dhaka District, Dhaka Division, Bangladesh', 24.9447390, 90.6015203, 23.7804927, 90.3582974, 155.05, 130, 1740.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled while searching', NULL, 'dhaka__dhaka', '2026-07-31 03:59:07', '2026-07-31 03:59:35'),
(7, 'RID-FVA3OI9', 4, NULL, 'bike', 'Dhaka, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8103000, 90.4125000, 23.8316678, 90.4248321, 4.13, 8, 70.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled while searching', NULL, 'dhaka__dhaka', '2026-07-31 04:13:45', '2026-07-31 10:23:54'),
(8, 'RID-FYXH5R4', 4, NULL, 'bike', 'Dhaka, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8103000, 90.4125000, 23.8316678, 90.4248321, 4.13, 8, 70.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'pre-bot cleanup', NULL, 'dhaka__dhaka', '2026-07-31 10:23:58', '2026-07-31 10:23:58'),
(9, 'RID-FZR54D0', 4, NULL, 'bike', 'Gulshan 1, Dhaka', 'Banani 11, Dhaka', 23.7808875, 90.4169271, 23.7937000, 90.4066000, 4.20, 12, 74.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'pre-bot cleanup', NULL, 'dhaka__dhaka', '2026-07-31 10:26:16', '2026-07-31 10:26:16'),
(10, 'RID-G0EJB50', 4, 5, 'bike', 'BOT-PICKUP-493685 Gulshan 1, Dhaka', 'Banani 11, Dhaka', 23.7808875, 90.4169271, 23.7937000, 90.4066000, 4.20, 12, 74.00, 1.00, 'assigned', 'cash', NULL, NULL, NULL, NULL, 'dhaka__dhaka', '2026-07-31 10:28:05', '2026-07-31 10:28:05'),
(11, 'RID-G13CEV3', 4, NULL, 'bike', 'Gulshan, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.7921765, 90.4155528, 23.8316678, 90.4248321, 7.40, 9, 105.00, 1.00, 'searching', 'cash', NULL, NULL, NULL, NULL, 'dhaka__dhaka', '2026-07-31 10:30:01', '2026-07-31 10:32:17'),
(12, 'RID-G2B0D72', 4, NULL, 'bike', 'Gulshan, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.7921765, 90.4155528, 23.8316678, 90.4248321, 7.40, 9, 105.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled while searching', NULL, 'dhaka__dhaka', '2026-07-31 10:33:25', '2026-07-31 10:33:40'),
(13, 'RID-G2SUMX7', 4, 5, 'bike', 'Dhaka-Mymensingh Highway, Purbo Arichpur, Cherag Ali, Tongi, Gazipur Sadar Upazila, Gazipur District, Dhaka Division, 1712, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8999712, 90.3990639, 23.8316678, 90.4248321, 9.25, 8, 124.00, 1.00, 'completed', 'cash', NULL, NULL, NULL, '2026-07-31 10:39:01', 'dhaka__dhaka', '2026-07-31 10:34:48', '2026-07-31 10:39:01'),
(14, 'RID-G4NX2Z8', 4, 5, 'bike', 'Dhaka, Bangladesh', 'Cox\'s Bazar District, Chattogram Division, Bangladesh', 23.8103000, 90.4125000, 21.4420039, 91.9812464, 392.71, 294, 4351.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled by customer', NULL, 'dhaka__dhaka', '2026-07-31 10:40:01', '2026-07-31 10:40:19');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('9cEh52QIo9bcDSZaDxe6OptnXi14PVsy9lQEeF51', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8875', 'eyJfdG9rZW4iOiJuNDdKWG5mMkJsbGhCRm8zS1lmN1pnalhROWZ1Vk0xZFVPOUxhSVhnIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1785490051),
('NmcE8VqHSbojPk5mNDn3Gbxt1PVMkGt07INOAJtt', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0', 'eyJfdG9rZW4iOiJYYUhTQndCaWY5akJNeFRiUHVNSEhyaEJLYXV1TXZ1ZzQ1UjNnMDlvIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1785485526),
('Vskjhsm29WAUksq6wwSMjbVGCrkhPYXhoQZpw3dI', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Cursor/3.5.17 Chrome/142.0.7444.265 Electron/39.8.1 Safari/537.36', 'eyJfdG9rZW4iOiJDVVJ6OFpBNWtzalBGTHRlTGIzVmlNUU4xZVJLcFdGc1hjMmhYaWE4IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1785485357);

-- --------------------------------------------------------

--
-- Table structure for table `sos_alerts`
--

CREATE TABLE `sos_alerts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `type` varchar(255) NOT NULL,
  `location_label` varchar(255) NOT NULL DEFAULT '',
  `lat` decimal(10,7) DEFAULT NULL,
  `lng` decimal(10,7) DEFAULT NULL,
  `status` enum('active','resolved') NOT NULL DEFAULT 'active',
  `resolved_at` timestamp NULL DEFAULT NULL,
  `resolved_by` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sos_contacts`
--

CREATE TABLE `sos_contacts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(255) NOT NULL,
  `relation` varchar(255) NOT NULL DEFAULT '',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stores`
--

CREATE TABLE `stores` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `owner_name` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `subcategories` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`subcategories`)),
  `description` text DEFAULT NULL,
  `specialties` varchar(255) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `district_id` varchar(255) DEFAULT NULL,
  `zip` varchar(16) DEFAULT NULL,
  `lat` decimal(10,7) DEFAULT NULL,
  `lng` decimal(10,7) DEFAULT NULL,
  `is_open` tinyint(1) NOT NULL DEFAULT 0,
  `accepting_orders` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('active','pending','onboarding','suspended') NOT NULL DEFAULT 'onboarding',
  `rating` decimal(3,2) NOT NULL DEFAULT 0.00,
  `rating_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `hours` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`hours`)),
  `banner` varchar(255) DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `profile_strength` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `balance` decimal(12,2) NOT NULL DEFAULT 0.00,
  `free_delivery` tinyint(1) NOT NULL DEFAULT 0,
  `eta_label` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `stores`
--

INSERT INTO `stores` (`id`, `code`, `user_id`, `name`, `owner_name`, `category`, `subcategories`, `description`, `specialties`, `bio`, `address`, `city`, `district_id`, `zip`, `lat`, `lng`, `is_open`, `accepting_orders`, `status`, `rating`, `rating_count`, `hours`, `banner`, `logo`, `profile_strength`, `balance`, `free_delivery`, `eta_label`, `created_at`, `updated_at`) VALUES
(1, 'HG-MRT-FJYZRX7', 6, 'Demo Kitchen', 'Demo Merchant', 'Restaurant', NULL, 'HillGo demo merchant store', NULL, NULL, 'Gulshan 1, Dhaka', 'Dhaka', 'dhaka__dhaka', NULL, NULL, NULL, 1, 1, 'active', 0.00, 0, NULL, NULL, NULL, 80, 0.00, 0, '25-35 min', '2026-07-31 03:42:05', '2026-07-31 03:42:05');

-- --------------------------------------------------------

--
-- Table structure for table `support_tickets`
--

CREATE TABLE `support_tickets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `role` varchar(32) NOT NULL DEFAULT 'customer',
  `subject` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `status` enum('open','answered','closed') NOT NULL DEFAULT 'open',
  `reply` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `testimonials`
--

CREATE TABLE `testimonials` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `role` varchar(255) DEFAULT NULL,
  `quote` text NOT NULL,
  `rating` tinyint(3) UNSIGNED NOT NULL DEFAULT 5,
  `sort` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trips`
--

CREATE TABLE `trips` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `type` enum('ride','food','parcel') NOT NULL,
  `rider_id` bigint(20) UNSIGNED DEFAULT NULL,
  `customer_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ref_type` varchar(255) DEFAULT NULL,
  `ref_id` bigint(20) UNSIGNED DEFAULT NULL,
  `pickup_name` varchar(255) DEFAULT NULL,
  `pickup_address` varchar(255) DEFAULT NULL,
  `pickup_lat` decimal(10,7) DEFAULT NULL,
  `pickup_lng` decimal(10,7) DEFAULT NULL,
  `drop_name` varchar(255) DEFAULT NULL,
  `drop_address` varchar(255) DEFAULT NULL,
  `drop_lat` decimal(10,7) DEFAULT NULL,
  `drop_lng` decimal(10,7) DEFAULT NULL,
  `distance_km` decimal(8,2) NOT NULL DEFAULT 0.00,
  `duration_min` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `earning` decimal(12,2) NOT NULL DEFAULT 0.00,
  `tip` decimal(12,2) NOT NULL DEFAULT 0.00,
  `payment_method` enum('cash','digital') NOT NULL DEFAULT 'digital',
  `cod_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `surge` decimal(4,2) NOT NULL DEFAULT 1.00,
  `vehicle_required` enum('bike','car','xl') DEFAULT NULL,
  `weight_kg` decimal(8,2) DEFAULT NULL,
  `package_label` varchar(255) DEFAULT NULL,
  `status` enum('requested','accepted','arriving','arrived','in_progress','picked_up','in_transit','completed','cancelled','expired','declined') NOT NULL DEFAULT 'requested',
  `offered_at` timestamp NULL DEFAULT NULL,
  `offer_expires_at` timestamp NULL DEFAULT NULL,
  `declined_rider_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`declined_rider_ids`)),
  `accepted_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `trips`
--

INSERT INTO `trips` (`id`, `code`, `type`, `rider_id`, `customer_id`, `ref_type`, `ref_id`, `pickup_name`, `pickup_address`, `pickup_lat`, `pickup_lng`, `drop_name`, `drop_address`, `drop_lat`, `drop_lng`, `distance_km`, `duration_min`, `earning`, `tip`, `payment_method`, `cod_amount`, `surge`, `vehicle_required`, `weight_kg`, `package_label`, `status`, `offered_at`, `offer_expires_at`, `declined_rider_ids`, `accepted_at`, `completed_at`, `created_at`, `updated_at`) VALUES
(1, 'HG-6A6C6E8A5E136', 'ride', NULL, 4, 'rides', 1, 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 24.9454341, 90.6011677, 'Mymensingh, Mymensingh Sadar Upazila, Mymensingh District, Mymensingh Division, 2200, Bangladesh', 'Mymensingh, Mymensingh Sadar Upazila, Mymensingh District, Mymensingh Division, 2200, Bangladesh', 24.7482129, 90.4099158, 35.07, 41, 418.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', NULL, NULL, '[5]', NULL, NULL, '2026-07-31 03:44:42', '2026-07-31 03:45:47'),
(2, 'HG-6A6C6EFEBA868', 'ride', 5, 4, 'rides', 2, 'Hazrat Shahjalal International Airport, Airport Road, MODC Mess Road, Barontek, Manikdi, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Hazrat Shahjalal International Airport, Airport Road, MODC Mess Road, Barontek, Manikdi, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8431441, 90.4053032, 'Uttara, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1231, Bangladesh', 'Uttara, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1231, Bangladesh', 23.8693275, 90.3926893, 3.84, 5, 65.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 03:54:32', '2026-07-31 03:55:02', '[]', NULL, NULL, '2026-07-31 03:46:38', '2026-07-31 03:54:44'),
(3, 'HG-6A6C70E80910F', 'ride', 5, 4, 'rides', 3, 'Hazrat Shahjalal International Airport, Airport Road, MODC Mess Road, Barontek, Manikdi, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Hazrat Shahjalal International Airport, Airport Road, MODC Mess Road, Barontek, Manikdi, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8431441, 90.4053032, 'Uttara, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1231, Bangladesh', 'Uttara, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1231, Bangladesh', 23.8693275, 90.3926893, 3.84, 5, 65.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 10:26:16', '2026-07-31 10:27:16', '[]', '2026-07-31 10:26:16', NULL, '2026-07-31 03:54:48', '2026-07-31 10:26:16'),
(4, 'HG-6A6C711CA1302', 'ride', 5, 4, 'rides', 4, 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 24.9447390, 90.6015203, 'Dhaka District, Dhaka Division, Bangladesh', 'Dhaka District, Dhaka Division, Bangladesh', 23.7804927, 90.3582974, 155.05, 130, 1740.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 03:59:00', '2026-07-31 03:59:30', '[]', NULL, NULL, '2026-07-31 03:55:40', '2026-07-31 03:59:05'),
(5, 'HG-6A6C71805DB44', 'ride', 5, 4, 'rides', 5, 'Gulshan 1, Dhaka', 'Gulshan 1, Dhaka', 23.7808000, 90.4142000, 'Banani, Dhaka', 'Banani, Dhaka', 23.7936000, 90.4066000, 3.20, 12, 63.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'requested', '2026-07-31 10:40:04', '2026-07-31 10:41:04', '[]', NULL, NULL, '2026-07-31 03:57:20', '2026-07-31 10:40:04'),
(6, 'HG-6A6C71EB46453', 'ride', 5, 4, 'rides', 6, 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 24.9447390, 90.6015203, 'Dhaka District, Dhaka Division, Bangladesh', 'Dhaka District, Dhaka Division, Bangladesh', 23.7804927, 90.3582974, 155.05, 130, 1740.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 03:59:07', '2026-07-31 03:59:37', '[]', NULL, NULL, '2026-07-31 03:59:07', '2026-07-31 03:59:35'),
(7, 'HG-6A6C7559359D2', 'ride', 5, 4, 'rides', 7, 'Dhaka, Bangladesh', 'Dhaka, Bangladesh', 23.8103000, 90.4125000, 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8316678, 90.4248321, 4.13, 8, 70.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 10:22:54', '2026-07-31 10:23:54', '[]', NULL, NULL, '2026-07-31 04:13:45', '2026-07-31 10:23:54'),
(8, 'HG-6A6C77BE273BD', 'ride', 5, 4, 'rides', 8, 'Dhaka, Bangladesh', 'Dhaka, Bangladesh', 23.8103000, 90.4125000, 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8316678, 90.4248321, 4.13, 8, 70.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'requested', '2026-07-31 10:40:04', '2026-07-31 10:41:04', '[]', NULL, NULL, '2026-07-31 10:23:58', '2026-07-31 10:40:04'),
(9, 'HG-6A6C7848885B5', 'ride', 5, 4, 'rides', 9, 'Gulshan 1, Dhaka', 'Gulshan 1, Dhaka', 23.7808875, 90.4169271, 'Banani 11, Dhaka', 'Banani 11, Dhaka', 23.7937000, 90.4066000, 4.20, 12, 74.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'requested', '2026-07-31 10:40:04', '2026-07-31 10:41:04', '[]', NULL, NULL, '2026-07-31 10:26:16', '2026-07-31 10:40:04'),
(10, 'HG-6A6C78B5AB5E4', 'ride', 5, 4, 'rides', 10, 'BOT-PICKUP-493685 Gulshan 1, Dhaka', 'BOT-PICKUP-493685 Gulshan 1, Dhaka', 23.7808875, 90.4169271, 'Banani 11, Dhaka', 'Banani 11, Dhaka', 23.7937000, 90.4066000, 4.20, 12, 74.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 10:28:05', '2026-07-31 10:29:05', '[]', '2026-07-31 10:28:05', NULL, '2026-07-31 10:28:05', '2026-07-31 10:32:03'),
(11, 'HG-6A6C79296FCF4', 'ride', 5, 4, 'rides', 11, 'Gulshan, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, Bangladesh', 'Gulshan, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, Bangladesh', 23.7921765, 90.4155528, 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8316678, 90.4248321, 7.40, 9, 105.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'requested', '2026-07-31 10:40:04', '2026-07-31 10:41:04', '[]', NULL, NULL, '2026-07-31 10:30:01', '2026-07-31 10:40:04'),
(12, 'HG-6A6C79F53845C', 'ride', 5, 4, 'rides', 12, 'Gulshan, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, Bangladesh', 'Gulshan, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, Bangladesh', 23.7921765, 90.4155528, 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8316678, 90.4248321, 7.40, 9, 105.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 10:33:25', '2026-07-31 10:34:25', '[]', NULL, NULL, '2026-07-31 10:33:25', '2026-07-31 10:33:40'),
(13, 'HG-6A6C7A4864E6F', 'ride', 5, 4, 'rides', 13, 'Dhaka-Mymensingh Highway, Purbo Arichpur, Cherag Ali, Tongi, Gazipur Sadar Upazila, Gazipur District, Dhaka Division, 1712, Bangladesh', 'Dhaka-Mymensingh Highway, Purbo Arichpur, Cherag Ali, Tongi, Gazipur Sadar Upazila, Gazipur District, Dhaka Division, 1712, Bangladesh', 23.8999712, 90.3990639, 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8316678, 90.4248321, 9.25, 8, 124.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'completed', '2026-07-31 10:34:48', '2026-07-31 10:35:48', '[]', '2026-07-31 10:34:56', '2026-07-31 10:39:01', '2026-07-31 10:34:48', '2026-07-31 10:39:01'),
(14, 'HG-6A6C7B8151925', 'ride', 5, 4, 'rides', 14, 'Dhaka, Bangladesh', 'Dhaka, Bangladesh', 23.8103000, 90.4125000, 'Cox\'s Bazar District, Chattogram Division, Bangladesh', 'Cox\'s Bazar District, Chattogram Division, Bangladesh', 21.4420039, 91.9812464, 392.71, 294, 4351.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 10:40:01', '2026-07-31 10:41:01', '[]', '2026-07-31 10:40:11', NULL, '2026-07-31 10:40:01', '2026-07-31 10:40:19');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `role` enum('super_admin','admin','customer','rider','merchant','courier_agent') NOT NULL DEFAULT 'customer',
  `name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `status` enum('active','suspended','onboarding','pending') NOT NULL DEFAULT 'active',
  `district_id` varchar(255) DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `language` varchar(16) NOT NULL DEFAULT 'en',
  `prefs` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`prefs`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `role`, `name`, `email`, `phone`, `email_verified_at`, `password`, `status`, `district_id`, `remember_token`, `created_at`, `updated_at`, `avatar`, `language`, `prefs`) VALUES
(1, 'super_admin', 'HillGo Super Admin', 'admin@hillgo.app', NULL, NULL, '$2y$12$N.hLfuFm/KEkUiW.Cd9uMu9O2tjoSy.0j9f1fZXlSlfgbGm1wxJTq', 'active', NULL, NULL, '2026-07-31 01:56:44', '2026-07-31 01:56:44', NULL, 'en', NULL),
(2, 'rider', 'Smoke Test Rider', NULL, '+8801116439445', NULL, '$2y$12$nGIS/9CJ1FKA5HSmwCqNSe88rygufusMF0e9rWujGzsTA/AwBByW.', 'onboarding', 'khulna__bagerhat', NULL, '2026-07-31 02:43:50', '2026-07-31 02:43:50', NULL, 'en', NULL),
(3, 'rider', 'Presence Test', NULL, '+8801721109255', NULL, '$2y$12$epQSZ6EB2TElw4KZyPYx5.EGcSOdl3B3Vi9c3VOzNIf5GQeSjplRu', 'onboarding', NULL, NULL, '2026-07-31 02:44:08', '2026-07-31 02:44:08', NULL, 'en', NULL),
(4, 'customer', 'Demo Customer', 'customer@demo.hillgo.app', '+8801710000001', NULL, '$2y$12$Xcg5as7h0KbwnSain33YAeA.Pf5bJc8CW9iGx2LCyMzFkKDW62Oiy', 'active', 'dhaka__dhaka', NULL, '2026-07-31 03:42:05', '2026-07-31 03:42:05', NULL, 'en', NULL),
(5, 'rider', 'Demo Rider', 'rider@demo.hillgo.app', '+8801710000002', NULL, '$2y$12$iiEaKfbxMnptbdhN0bCCtOHNaDW86s067hnrZgemj1z3VgDN43IG6', 'active', 'dhaka__dhaka', NULL, '2026-07-31 03:42:05', '2026-07-31 03:42:05', NULL, 'en', NULL),
(6, 'merchant', 'Demo Merchant', 'merchant@demo.hillgo.app', '+8801710000003', NULL, '$2y$12$6bzzrCeIJGZB7BuvVQy4TusRdWTMsUZcjBhs2JFTed7JAnRUm9neO', 'active', 'dhaka__dhaka', NULL, '2026-07-31 03:42:05', '2026-07-31 03:42:05', NULL, 'en', NULL),
(7, 'courier_agent', 'Demo Courier', 'courier@demo.hillgo.app', '+8801710000004', NULL, '$2y$12$jCvfdcbQry5aZ94TnCbauuDYE4STj69.inY0UKjKUJI4JbomlKoEO', 'active', 'dhaka__dhaka', NULL, '2026-07-31 03:42:06', '2026-07-31 03:42:06', NULL, 'en', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `wallet_transactions`
--

CREATE TABLE `wallet_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `direction` enum('credit','debit') NOT NULL,
  `ref_type` varchar(255) DEFAULT NULL,
  `ref_id` bigint(20) UNSIGNED DEFAULT NULL,
  `note` varchar(255) NOT NULL DEFAULT '',
  `balance_after` decimal(12,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `activity_logs_created_at_index` (`created_at`);

--
-- Indexes for table `addresses`
--
ALTER TABLE `addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `addresses_user_id_foreign` (`user_id`);

--
-- Indexes for table `app_notifications`
--
ALTER TABLE `app_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `app_notifications_user_id_read_at_index` (`user_id`,`read_at`),
  ADD KEY `app_notifications_role_created_at_index` (`role`,`created_at`);

--
-- Indexes for table `app_settings`
--
ALTER TABLE `app_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `app_settings_key_unique` (`key`);

--
-- Indexes for table `blog_posts`
--
ALTER TABLE `blog_posts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `blog_posts_slug_unique` (`slug`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `contact_inquiries`
--
ALTER TABLE `contact_inquiries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `contact_inquiries_status_created_at_index` (`status`,`created_at`);

--
-- Indexes for table `courier_documents`
--
ALTER TABLE `courier_documents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `courier_documents_courier_profile_id_doc_key_unique` (`courier_profile_id`,`doc_key`);

--
-- Indexes for table `courier_profiles`
--
ALTER TABLE `courier_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `courier_profiles_user_id_unique` (`user_id`),
  ADD UNIQUE KEY `courier_profiles_code_unique` (`code`);

--
-- Indexes for table `courier_withdrawals`
--
ALTER TABLE `courier_withdrawals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `courier_withdrawals_code_unique` (`code`),
  ADD KEY `courier_withdrawals_courier_id_foreign` (`courier_id`);

--
-- Indexes for table `customer_profiles`
--
ALTER TABLE `customer_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `customer_profiles_user_id_unique` (`user_id`),
  ADD UNIQUE KEY `customer_profiles_code_unique` (`code`);

--
-- Indexes for table `districts`
--
ALTER TABLE `districts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `districts_division_id_status_index` (`division_id`,`status`);

--
-- Indexes for table `divisions`
--
ALTER TABLE `divisions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  ADD KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`);

--
-- Indexes for table `faqs`
--
ALTER TABLE `faqs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hotels`
--
ALTER TABLE `hotels`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hotel_bookings`
--
ALTER TABLE `hotel_bookings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hotel_bookings_code_unique` (`code`),
  ADD KEY `hotel_bookings_hotel_id_foreign` (`hotel_id`),
  ADD KEY `hotel_bookings_customer_id_foreign` (`customer_id`);

--
-- Indexes for table `incentives`
--
ALTER TABLE `incentives`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `incentives_code_unique` (`code`);

--
-- Indexes for table `incentive_enrollments`
--
ALTER TABLE `incentive_enrollments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `incentive_enrollments_incentive_id_courier_id_unique` (`incentive_id`,`courier_id`),
  ADD KEY `incentive_enrollments_courier_id_foreign` (`courier_id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `loyalty_redemptions`
--
ALTER TABLE `loyalty_redemptions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `loyalty_redemptions_user_id_foreign` (`user_id`),
  ADD KEY `loyalty_redemptions_reward_id_foreign` (`reward_id`);

--
-- Indexes for table `loyalty_rewards`
--
ALTER TABLE `loyalty_rewards`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `loyalty_tiers`
--
ALTER TABLE `loyalty_tiers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `loyalty_tiers_name_unique` (`name`);

--
-- Indexes for table `merchant_onboardings`
--
ALTER TABLE `merchant_onboardings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `merchant_onboardings_store_id_foreign` (`store_id`),
  ADD KEY `merchant_onboardings_user_id_foreign` (`user_id`),
  ADD KEY `merchant_onboardings_district_id_foreign` (`district_id`);

--
-- Indexes for table `merchant_payouts`
--
ALTER TABLE `merchant_payouts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `merchant_payouts_code_unique` (`code`),
  ADD KEY `merchant_payouts_store_id_foreign` (`store_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `newsletter_subscribers`
--
ALTER TABLE `newsletter_subscribers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `newsletter_subscribers_email_unique` (`email`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `orders_code_unique` (`code`),
  ADD KEY `orders_district_id_foreign` (`district_id`),
  ADD KEY `orders_store_id_status_index` (`store_id`,`status`),
  ADD KEY `orders_customer_id_channel_index` (`customer_id`,`channel`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_items_order_id_foreign` (`order_id`),
  ADD KEY `order_items_product_id_foreign` (`product_id`);

--
-- Indexes for table `otp_codes`
--
ALTER TABLE `otp_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `otp_codes_phone_role_purpose_index` (`phone`,`role`,`purpose`);

--
-- Indexes for table `parcels`
--
ALTER TABLE `parcels`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `parcels_code_unique` (`code`),
  ADD KEY `parcels_customer_id_foreign` (`customer_id`),
  ADD KEY `parcels_rider_id_foreign` (`rider_id`),
  ADD KEY `parcels_district_id_foreign` (`district_id`),
  ADD KEY `parcels_status_created_at_index` (`status`,`created_at`),
  ADD KEY `parcels_courier_id_index` (`courier_id`);

--
-- Indexes for table `parcel_otp_logs`
--
ALTER TABLE `parcel_otp_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `parcel_otp_logs_parcel_id_foreign` (`parcel_id`),
  ADD KEY `parcel_otp_logs_by_user_id_foreign` (`by_user_id`);

--
-- Indexes for table `parcel_proofs`
--
ALTER TABLE `parcel_proofs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `parcel_proofs_parcel_id_foreign` (`parcel_id`);

--
-- Indexes for table `partner_applications`
--
ALTER TABLE `partner_applications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `partner_applications_district_id_foreign` (`district_id`),
  ADD KEY `partner_applications_rider_user_id_foreign` (`rider_user_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD PRIMARY KEY (`id`),
  ADD KEY `payment_methods_user_id_foreign` (`user_id`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `pricing_audits`
--
ALTER TABLE `pricing_audits`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pricing_audits_panel_created_at_index` (`panel`,`created_at`);

--
-- Indexes for table `pricing_settings`
--
ALTER TABLE `pricing_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pricing_settings_panel_unique` (`panel`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `products_category_id_foreign` (`category_id`),
  ADD KEY `products_store_id_status_index` (`store_id`,`status`),
  ADD KEY `products_marketplace_category_index` (`marketplace_category`);

--
-- Indexes for table `product_categories`
--
ALTER TABLE `product_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_categories_store_id_foreign` (`store_id`);

--
-- Indexes for table `promos`
--
ALTER TABLE `promos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `promos_code_unique` (`code`);

--
-- Indexes for table `rental_bookings`
--
ALTER TABLE `rental_bookings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rental_bookings_code_unique` (`code`),
  ADD KEY `rental_bookings_vehicle_id_foreign` (`vehicle_id`),
  ADD KEY `rental_bookings_customer_id_foreign` (`customer_id`);

--
-- Indexes for table `rental_vehicles`
--
ALTER TABLE `rental_vehicles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reviews_store_id_foreign` (`store_id`),
  ADD KEY `reviews_customer_id_foreign` (`customer_id`),
  ADD KEY `reviews_order_id_foreign` (`order_id`);

--
-- Indexes for table `rider_documents`
--
ALTER TABLE `rider_documents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rider_documents_rider_profile_id_doc_key_unique` (`rider_profile_id`,`doc_key`);

--
-- Indexes for table `rider_payouts`
--
ALTER TABLE `rider_payouts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rider_payouts_code_unique` (`code`),
  ADD KEY `rider_payouts_rider_id_foreign` (`rider_id`);

--
-- Indexes for table `rider_profiles`
--
ALTER TABLE `rider_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rider_profiles_user_id_unique` (`user_id`),
  ADD UNIQUE KEY `rider_profiles_code_unique` (`code`),
  ADD KEY `rider_profiles_online_vehicle_type_index` (`online`,`vehicle_type`);

--
-- Indexes for table `rides`
--
ALTER TABLE `rides`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rides_code_unique` (`code`),
  ADD KEY `rides_rider_id_foreign` (`rider_id`),
  ADD KEY `rides_district_id_foreign` (`district_id`),
  ADD KEY `rides_status_created_at_index` (`status`,`created_at`),
  ADD KEY `rides_customer_id_index` (`customer_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `sos_alerts`
--
ALTER TABLE `sos_alerts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sos_alerts_user_id_foreign` (`user_id`),
  ADD KEY `sos_alerts_status_created_at_index` (`status`,`created_at`);

--
-- Indexes for table `sos_contacts`
--
ALTER TABLE `sos_contacts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sos_contacts_user_id_foreign` (`user_id`);

--
-- Indexes for table `stores`
--
ALTER TABLE `stores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `stores_code_unique` (`code`),
  ADD KEY `stores_user_id_foreign` (`user_id`),
  ADD KEY `stores_district_id_foreign` (`district_id`),
  ADD KEY `stores_status_category_index` (`status`,`category`);

--
-- Indexes for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `support_tickets_user_id_foreign` (`user_id`);

--
-- Indexes for table `testimonials`
--
ALTER TABLE `testimonials`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `trips`
--
ALTER TABLE `trips`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `trips_code_unique` (`code`),
  ADD KEY `trips_customer_id_foreign` (`customer_id`),
  ADD KEY `trips_rider_id_status_index` (`rider_id`,`status`),
  ADD KEY `trips_status_offer_expires_at_index` (`status`,`offer_expires_at`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD UNIQUE KEY `users_phone_unique` (`phone`),
  ADD KEY `users_district_id_foreign` (`district_id`),
  ADD KEY `users_role_status_index` (`role`,`status`);

--
-- Indexes for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `wallet_transactions_user_id_created_at_index` (`user_id`,`created_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `addresses`
--
ALTER TABLE `addresses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `app_notifications`
--
ALTER TABLE `app_notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=175;

--
-- AUTO_INCREMENT for table `app_settings`
--
ALTER TABLE `app_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `blog_posts`
--
ALTER TABLE `blog_posts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `contact_inquiries`
--
ALTER TABLE `contact_inquiries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `courier_documents`
--
ALTER TABLE `courier_documents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `courier_profiles`
--
ALTER TABLE `courier_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `courier_withdrawals`
--
ALTER TABLE `courier_withdrawals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customer_profiles`
--
ALTER TABLE `customer_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `faqs`
--
ALTER TABLE `faqs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hotels`
--
ALTER TABLE `hotels`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hotel_bookings`
--
ALTER TABLE `hotel_bookings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `incentives`
--
ALTER TABLE `incentives`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `incentive_enrollments`
--
ALTER TABLE `incentive_enrollments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `loyalty_redemptions`
--
ALTER TABLE `loyalty_redemptions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `loyalty_rewards`
--
ALTER TABLE `loyalty_rewards`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `loyalty_tiers`
--
ALTER TABLE `loyalty_tiers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `merchant_onboardings`
--
ALTER TABLE `merchant_onboardings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `merchant_payouts`
--
ALTER TABLE `merchant_payouts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `newsletter_subscribers`
--
ALTER TABLE `newsletter_subscribers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `otp_codes`
--
ALTER TABLE `otp_codes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `parcels`
--
ALTER TABLE `parcels`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `parcel_otp_logs`
--
ALTER TABLE `parcel_otp_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `parcel_proofs`
--
ALTER TABLE `parcel_proofs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `partner_applications`
--
ALTER TABLE `partner_applications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payment_methods`
--
ALTER TABLE `payment_methods`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `pricing_audits`
--
ALTER TABLE `pricing_audits`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pricing_settings`
--
ALTER TABLE `pricing_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_categories`
--
ALTER TABLE `product_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `promos`
--
ALTER TABLE `promos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rental_bookings`
--
ALTER TABLE `rental_bookings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rental_vehicles`
--
ALTER TABLE `rental_vehicles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rider_documents`
--
ALTER TABLE `rider_documents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rider_payouts`
--
ALTER TABLE `rider_payouts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rider_profiles`
--
ALTER TABLE `rider_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `rides`
--
ALTER TABLE `rides`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `sos_alerts`
--
ALTER TABLE `sos_alerts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sos_contacts`
--
ALTER TABLE `sos_contacts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `stores`
--
ALTER TABLE `stores`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `support_tickets`
--
ALTER TABLE `support_tickets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `testimonials`
--
ALTER TABLE `testimonials`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trips`
--
ALTER TABLE `trips`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `addresses`
--
ALTER TABLE `addresses`
  ADD CONSTRAINT `addresses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `app_notifications`
--
ALTER TABLE `app_notifications`
  ADD CONSTRAINT `app_notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `courier_documents`
--
ALTER TABLE `courier_documents`
  ADD CONSTRAINT `courier_documents_courier_profile_id_foreign` FOREIGN KEY (`courier_profile_id`) REFERENCES `courier_profiles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `courier_profiles`
--
ALTER TABLE `courier_profiles`
  ADD CONSTRAINT `courier_profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `courier_withdrawals`
--
ALTER TABLE `courier_withdrawals`
  ADD CONSTRAINT `courier_withdrawals_courier_id_foreign` FOREIGN KEY (`courier_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `customer_profiles`
--
ALTER TABLE `customer_profiles`
  ADD CONSTRAINT `customer_profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `districts`
--
ALTER TABLE `districts`
  ADD CONSTRAINT `districts_division_id_foreign` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `hotel_bookings`
--
ALTER TABLE `hotel_bookings`
  ADD CONSTRAINT `hotel_bookings_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `hotel_bookings_hotel_id_foreign` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `incentive_enrollments`
--
ALTER TABLE `incentive_enrollments`
  ADD CONSTRAINT `incentive_enrollments_courier_id_foreign` FOREIGN KEY (`courier_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `incentive_enrollments_incentive_id_foreign` FOREIGN KEY (`incentive_id`) REFERENCES `incentives` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `loyalty_redemptions`
--
ALTER TABLE `loyalty_redemptions`
  ADD CONSTRAINT `loyalty_redemptions_reward_id_foreign` FOREIGN KEY (`reward_id`) REFERENCES `loyalty_rewards` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `loyalty_redemptions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `merchant_onboardings`
--
ALTER TABLE `merchant_onboardings`
  ADD CONSTRAINT `merchant_onboardings_district_id_foreign` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `merchant_onboardings_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `merchant_onboardings_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `merchant_payouts`
--
ALTER TABLE `merchant_payouts`
  ADD CONSTRAINT `merchant_payouts_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orders_district_id_foreign` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `orders_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `parcels`
--
ALTER TABLE `parcels`
  ADD CONSTRAINT `parcels_courier_id_foreign` FOREIGN KEY (`courier_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `parcels_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `parcels_district_id_foreign` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `parcels_rider_id_foreign` FOREIGN KEY (`rider_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `parcel_otp_logs`
--
ALTER TABLE `parcel_otp_logs`
  ADD CONSTRAINT `parcel_otp_logs_by_user_id_foreign` FOREIGN KEY (`by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `parcel_otp_logs_parcel_id_foreign` FOREIGN KEY (`parcel_id`) REFERENCES `parcels` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `parcel_proofs`
--
ALTER TABLE `parcel_proofs`
  ADD CONSTRAINT `parcel_proofs_parcel_id_foreign` FOREIGN KEY (`parcel_id`) REFERENCES `parcels` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `partner_applications`
--
ALTER TABLE `partner_applications`
  ADD CONSTRAINT `partner_applications_district_id_foreign` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `partner_applications_rider_user_id_foreign` FOREIGN KEY (`rider_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD CONSTRAINT `payment_methods_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `product_categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `products_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `product_categories`
--
ALTER TABLE `product_categories`
  ADD CONSTRAINT `product_categories_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `rental_bookings`
--
ALTER TABLE `rental_bookings`
  ADD CONSTRAINT `rental_bookings_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `rental_bookings_vehicle_id_foreign` FOREIGN KEY (`vehicle_id`) REFERENCES `rental_vehicles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `reviews_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `rider_documents`
--
ALTER TABLE `rider_documents`
  ADD CONSTRAINT `rider_documents_rider_profile_id_foreign` FOREIGN KEY (`rider_profile_id`) REFERENCES `rider_profiles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `rider_payouts`
--
ALTER TABLE `rider_payouts`
  ADD CONSTRAINT `rider_payouts_rider_id_foreign` FOREIGN KEY (`rider_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `rider_profiles`
--
ALTER TABLE `rider_profiles`
  ADD CONSTRAINT `rider_profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `rides`
--
ALTER TABLE `rides`
  ADD CONSTRAINT `rides_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `rides_district_id_foreign` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `rides_rider_id_foreign` FOREIGN KEY (`rider_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `sos_alerts`
--
ALTER TABLE `sos_alerts`
  ADD CONSTRAINT `sos_alerts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sos_contacts`
--
ALTER TABLE `sos_contacts`
  ADD CONSTRAINT `sos_contacts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `stores`
--
ALTER TABLE `stores`
  ADD CONSTRAINT `stores_district_id_foreign` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `stores_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD CONSTRAINT `support_tickets_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `trips`
--
ALTER TABLE `trips`
  ADD CONSTRAINT `trips_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `trips_rider_id_foreign` FOREIGN KEY (`rider_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_district_id_foreign` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD CONSTRAINT `wallet_transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
