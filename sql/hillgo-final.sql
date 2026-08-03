-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 31, 2026 at 11:26 PM
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
  `by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `activity_logs`
--

INSERT INTO `activity_logs` (`id`, `text`, `by`, `by_user_id`, `category`, `created_at`, `updated_at`) VALUES
(1, 'Dhaka (Dhaka) → open', 'HillGo Super Admin', 1, 'region', '2026-07-31 19:42:04', '2026-07-31 19:42:04'),
(2, 'Pricing saved: customer', 'HillGo Super Admin', 1, 'pricing', '2026-07-31 19:42:07', '2026-07-31 19:42:07'),
(3, 'Pricing saved: customer', 'HillGo Super Admin', 1, 'pricing', '2026-07-31 19:42:08', '2026-07-31 19:42:08'),
(4, 'Wallet Demo Customer: +10 ৳ (E2E credit)', 'HillGo Super Admin', 1, 'wallet', '2026-07-31 19:42:09', '2026-07-31 19:42:09'),
(5, 'Courier KYC Demo Courier: verified', 'HillGo Super Admin', 1, 'kyc', '2026-07-31 19:42:38', '2026-07-31 19:42:38'),
(6, 'Dhaka (Dhaka) → open', 'HillGo Super Admin', 1, 'region', '2026-07-31 19:45:36', '2026-07-31 19:45:36'),
(7, 'Pricing saved: customer', 'HillGo Super Admin', 1, 'pricing', '2026-07-31 19:45:38', '2026-07-31 19:45:38'),
(8, 'Pricing saved: customer', 'HillGo Super Admin', 1, 'pricing', '2026-07-31 19:45:39', '2026-07-31 19:45:39'),
(9, 'Wallet Demo Customer: +10 ৳ (E2E credit)', 'HillGo Super Admin', 1, 'wallet', '2026-07-31 19:45:40', '2026-07-31 19:45:40'),
(10, 'Courier KYC Demo Courier: verified', 'HillGo Super Admin', 1, 'kyc', '2026-07-31 19:46:15', '2026-07-31 19:46:15'),
(11, 'Withdrawal Demo Courier: paid ৳500', 'HillGo Super Admin', 1, 'payout', '2026-07-31 19:48:11', '2026-07-31 19:48:11'),
(12, 'SOS alert by Demo Customer (sos)', 'System', 4, NULL, '2026-07-31 19:48:21', '2026-07-31 19:48:21'),
(13, 'SOS #1 resolved', 'HillGo Super Admin', 1, NULL, '2026-07-31 19:48:22', '2026-07-31 19:48:22'),
(14, 'Rider payout Demo Rider: paid ৳100', 'HillGo Super Admin', 1, 'payout', '2026-07-31 19:49:04', '2026-07-31 19:49:04'),
(15, 'Withdrawal Demo Courier: paid ৳500', 'HillGo Super Admin', 1, 'payout', '2026-07-31 19:49:08', '2026-07-31 19:49:08'),
(16, 'SOS alert by Demo Customer (sos)', 'System', 4, NULL, '2026-07-31 19:49:18', '2026-07-31 19:49:18'),
(17, 'SOS #2 resolved', 'HillGo Super Admin', 1, NULL, '2026-07-31 19:49:19', '2026-07-31 19:49:19'),
(18, 'Merchant payout Demo Kitchen: completed ৳1000', 'HillGo Super Admin', 1, 'payout', '2026-07-31 19:49:50', '2026-07-31 19:49:50'),
(19, 'Withdrawal Demo Courier: paid ৳500', 'HillGo Super Admin', 1, 'payout', '2026-07-31 19:49:58', '2026-07-31 19:49:58'),
(20, 'SOS alert by Demo Customer (sos)', 'System', 4, NULL, '2026-07-31 19:50:08', '2026-07-31 19:50:08'),
(21, 'SOS #3 resolved', 'HillGo Super Admin', 1, NULL, '2026-07-31 19:50:09', '2026-07-31 19:50:09'),
(22, 'Merchant payout Demo Kitchen: completed ৳1000', 'HillGo Super Admin', 1, 'payout', '2026-07-31 19:50:45', '2026-07-31 19:50:45'),
(23, 'Rider payout Demo Rider: paid ৳100', 'HillGo Super Admin', 1, 'payout', '2026-07-31 19:50:50', '2026-07-31 19:50:50'),
(24, 'Withdrawal Demo Courier: paid ৳500', 'HillGo Super Admin', 1, 'payout', '2026-07-31 19:50:54', '2026-07-31 19:50:54'),
(25, 'SOS alert by Demo Customer (sos)', 'System', 4, NULL, '2026-07-31 19:51:04', '2026-07-31 19:51:04'),
(26, 'SOS #4 resolved', 'HillGo Super Admin', 1, NULL, '2026-07-31 19:51:04', '2026-07-31 19:51:04'),
(27, 'Dhaka (Dhaka) → open', 'HillGo Super Admin', 1, 'region', '2026-07-31 21:09:53', '2026-07-31 21:09:53'),
(28, 'Pricing saved: customer', 'HillGo Super Admin', 1, 'pricing', '2026-07-31 21:09:55', '2026-07-31 21:09:55'),
(29, 'Pricing saved: customer', 'HillGo Super Admin', 1, 'pricing', '2026-07-31 21:09:56', '2026-07-31 21:09:56'),
(30, 'customer#4 +৳10.00 (520.00→530.00) Admin wallet credit [admin_adjust]', 'HillGo Super Admin', 1, 'wallet', '2026-07-31 21:09:57', '2026-07-31 21:09:57'),
(31, 'Wallet Demo Customer: +10 ৳ (E2E credit)', 'HillGo Super Admin', 1, 'wallet', '2026-07-31 21:09:57', '2026-07-31 21:09:57'),
(32, 'rider#5 +৳53.55 (0.00→53.55) Trip HG-6A6D0F2909947 earnings [trip:19]', 'Demo Rider', 5, 'wallet', '2026-07-31 21:10:10', '2026-07-31 21:10:10'),
(33, 'customer#4 −৳74.00 (530.00→456.00) Ride RID-MDSMB84 [ride:18]', 'Demo Customer', 4, 'wallet', '2026-07-31 21:10:14', '2026-07-31 21:10:14'),
(34, 'customer#4 +৳74.00 (456.00→530.00) Refund ride RID-MDSMB84 [ride:18]', 'Demo Customer', 4, 'wallet', '2026-07-31 21:10:17', '2026-07-31 21:10:17'),
(35, 'store#6 +৳187.00 (0.00→187.00) Order ORD-MDU6105 settled [order:3]', 'Demo Rider', 5, 'wallet', '2026-07-31 21:10:30', '2026-07-31 21:10:30'),
(36, 'rider#5 +৳25.50 (53.55→79.05) Trip HG-6A6D0F405773A earnings [trip:21]', 'Demo Rider', 5, 'wallet', '2026-07-31 21:10:30', '2026-07-31 21:10:30'),
(37, 'Courier KYC Demo Courier: verified', 'HillGo Super Admin', 1, 'kyc', '2026-07-31 21:10:36', '2026-07-31 21:10:36'),
(38, 'courier#7 +৳96.80 (100.00→196.80) Parcel HG-MDXLUW2 earnings [parcel:3]', 'Demo Courier', 7, 'wallet', '2026-07-31 21:10:47', '2026-07-31 21:10:47'),
(39, 'courier#7 +৳403.20 (196.80→600.00) E2E top-up [admin_adjust]', 'System', NULL, 'wallet', '2026-07-31 21:12:07', '2026-07-31 21:12:07'),
(40, 'store#6 +৳813.00 (187.00→1,000.00) E2E store top-up [admin_adjust]', 'System', NULL, 'wallet', '2026-07-31 21:12:08', '2026-07-31 21:12:08'),
(41, 'store#6 −৳1000.00 (1,000.00→0.00) Payout PAY-MEHG7K0 (Bank) [merchant_payout:3]', 'HillGo Super Admin', 1, 'wallet', '2026-07-31 21:12:11', '2026-07-31 21:12:11'),
(42, 'Merchant payout Demo Kitchen: completed ৳1000', 'HillGo Super Admin', 1, 'payout', '2026-07-31 21:12:11', '2026-07-31 21:12:11'),
(43, 'rider#5 +৳20.95 (79.05→100.00) E2E rider top-up [admin_adjust]', 'System', NULL, 'wallet', '2026-07-31 21:12:14', '2026-07-31 21:12:14'),
(44, 'rider#5 −৳100.00 (100.00→0.00) Payout HG-PY-MEISJO3 (bKash) [payout:3]', 'HillGo Super Admin', 1, 'wallet', '2026-07-31 21:12:17', '2026-07-31 21:12:17'),
(45, 'Rider payout Demo Rider: paid ৳100', 'HillGo Super Admin', 1, 'payout', '2026-07-31 21:12:18', '2026-07-31 21:12:18'),
(46, 'courier#7 −৳500.00 (600.00→100.00) Withdrawal WD-MEJSZE1 (bKash) [withdrawal:5]', 'HillGo Super Admin', 1, 'wallet', '2026-07-31 21:12:22', '2026-07-31 21:12:22'),
(47, 'Withdrawal Demo Courier: paid ৳500', 'HillGo Super Admin', 1, 'payout', '2026-07-31 21:12:22', '2026-07-31 21:12:22'),
(48, 'SOS alert by Demo Customer (sos)', 'System', 4, NULL, '2026-07-31 21:12:33', '2026-07-31 21:12:33'),
(49, 'SOS #5 resolved', 'HillGo Super Admin', 1, NULL, '2026-07-31 21:12:34', '2026-07-31 21:12:34'),
(50, 'Barguna (Barishal) → closed', 'HillGo Super Admin', 1, 'region', '2026-07-31 21:15:43', '2026-07-31 21:15:43'),
(51, 'customer#4 +৳1.00 (530.00→531.00) Admin wallet credit [admin_adjust]', 'HillGo Super Admin', 1, 'wallet', '2026-07-31 21:15:44', '2026-07-31 21:15:44'),
(52, 'Wallet Demo Customer: +1 ৳ (catalog-e2e-audit)', 'HillGo Super Admin', 1, 'wallet', '2026-07-31 21:15:44', '2026-07-31 21:15:44'),
(53, 'Barguna (Barishal) → closed', 'HillGo Super Admin', 1, 'region', '2026-07-31 21:20:21', '2026-07-31 21:20:21'),
(54, 'customer#4 +৳1.00 (531.00→532.00) Admin wallet credit [admin_adjust]', 'HillGo Super Admin', 1, 'wallet', '2026-07-31 21:20:22', '2026-07-31 21:20:22'),
(55, 'Wallet Demo Customer: +1 ৳ (catalog-e2e-audit)', 'HillGo Super Admin', 1, 'wallet', '2026-07-31 21:20:22', '2026-07-31 21:20:22');

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
(174, 5, 'rider', 'Ride cancelled', 'Ride RID-G4NX2Z8 was cancelled by the customer.', 'ride', '[]', NULL, '2026-07-31 10:40:19', '2026-07-31 10:40:19'),
(175, 4, 'customer', 'Wallet updated', '৳10 was added to your Hill Wallet.', 'wallet', '[]', NULL, '2026-07-31 19:42:09', '2026-07-31 19:42:09'),
(176, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":5}', NULL, '2026-07-31 19:42:13', '2026-07-31 19:42:13'),
(177, 5, 'rider', 'New job offer', 'Ride job ৳70', 'offer', '{\"trip_id\":8}', NULL, '2026-07-31 19:42:13', '2026-07-31 19:42:13'),
(178, 5, 'rider', 'New job offer', 'Ride job ৳74', 'offer', '{\"trip_id\":9}', NULL, '2026-07-31 19:42:13', '2026-07-31 19:42:13'),
(179, 5, 'rider', 'New job offer', 'Ride job ৳105', 'offer', '{\"trip_id\":11}', NULL, '2026-07-31 19:42:14', '2026-07-31 19:42:14'),
(180, 4, 'customer', 'Driver assigned', 'Demo Rider is on the way.', 'ride', '{\"ride_id\":11}', NULL, '2026-07-31 19:42:15', '2026-07-31 19:42:15'),
(181, 4, 'customer', 'Ride completed', 'Fare ৳105. Thanks for riding with HillGo!', 'ride', '{\"ride_id\":11}', NULL, '2026-07-31 19:42:19', '2026-07-31 19:42:19'),
(182, 5, 'rider', 'Trip completed', '৳105 earned (net credited to balance).', 'earning', '{\"trip_id\":11}', NULL, '2026-07-31 19:42:19', '2026-07-31 19:42:19'),
(183, 6, 'merchant', 'New order', 'Order ORD-LIFHMF9 — ৳250', 'new_order', '{\"order_id\":1}', NULL, '2026-07-31 19:42:26', '2026-07-31 19:42:26'),
(184, 4, 'customer', 'Order placed', 'Your order ORD-LIFHMF9 was sent to Demo Kitchen.', 'food', '{\"order_id\":1}', NULL, '2026-07-31 19:42:26', '2026-07-31 19:42:26'),
(185, 4, 'customer', 'Order accepted', 'Demo Kitchen is preparing your order.', 'food', '{\"order_id\":1}', NULL, '2026-07-31 19:42:27', '2026-07-31 19:42:27'),
(186, 5, 'rider', 'New job offer', 'Food job ৳30', 'offer', '{\"trip_id\":15}', NULL, '2026-07-31 19:42:28', '2026-07-31 19:42:28'),
(187, 4, 'customer', 'Order ready', 'Your order is packed — assigning a rider now.', 'food', '{\"order_id\":1}', NULL, '2026-07-31 19:42:28', '2026-07-31 19:42:28'),
(188, 4, 'customer', 'Rider assigned', 'Demo Rider will deliver your order.', 'food', '{\"order_id\":1}', NULL, '2026-07-31 19:42:30', '2026-07-31 19:42:30'),
(189, 4, 'customer', 'Order on the way', 'Your food is heading to you now.', 'food', '{\"order_id\":1}', NULL, '2026-07-31 19:42:32', '2026-07-31 19:42:32'),
(190, 4, 'customer', 'Order delivered', 'Enjoy your meal! Rate your experience.', 'food', '{\"order_id\":1}', NULL, '2026-07-31 19:42:33', '2026-07-31 19:42:33'),
(191, 6, 'merchant', 'Order delivered', 'Order ORD-LIFHMF9 was delivered.', 'order', '{\"order_id\":1}', NULL, '2026-07-31 19:42:33', '2026-07-31 19:42:33'),
(192, 5, 'rider', 'Trip completed', '৳30 earned (net credited to balance).', 'earning', '{\"trip_id\":15}', NULL, '2026-07-31 19:42:33', '2026-07-31 19:42:33'),
(193, NULL, 'admin', 'Courier bank details changed', 'Demo Courier updated bank details — re-verify.', 'kyc', '[]', NULL, '2026-07-31 19:42:36', '2026-07-31 19:42:36'),
(194, 7, 'courier_agent', 'KYC approved', 'You are verified and can now receive parcel assignments.', 'kyc', '[]', NULL, '2026-07-31 19:42:38', '2026-07-31 19:42:38'),
(195, 7, 'courier_agent', 'New parcel assigned', 'Parcel HG-LIIE3R7: Gulshan Circle 1 → Banani 11', 'parcel_assigned', '{\"parcel_id\":1}', NULL, '2026-07-31 19:42:42', '2026-07-31 19:42:42'),
(196, 4, 'customer', 'Parcel booked', 'Tracking HG-LIIE3R7. Pickup OTP: 2024 · Delivery OTP: 3213 (share with the receiver).', 'parcel', '{\"parcel_id\":1,\"pickup_otp\":\"2024\",\"delivery_otp\":\"3213\"}', NULL, '2026-07-31 19:42:42', '2026-07-31 19:42:42'),
(197, 4, 'customer', 'Parcel picked up', 'Parcel HG-LIIE3R7 was collected by the courier.', 'parcel', '{\"parcel_id\":1}', NULL, '2026-07-31 19:42:45', '2026-07-31 19:42:45'),
(198, 4, 'customer', 'Parcel in transit', 'Parcel HG-LIIE3R7 is on the way.', 'parcel', '{\"parcel_id\":1}', NULL, '2026-07-31 19:42:46', '2026-07-31 19:42:46'),
(199, 4, 'customer', 'Parcel delivered', 'Parcel HG-LIIE3R7 was delivered successfully.', 'parcel', '{\"parcel_id\":1}', NULL, '2026-07-31 19:42:50', '2026-07-31 19:42:50'),
(200, 7, 'courier_agent', 'Delivery complete', '৳110 earned for HG-LIIE3R7.', 'earning', '[]', NULL, '2026-07-31 19:42:50', '2026-07-31 19:42:50'),
(201, 4, 'customer', 'Wallet updated', '৳10 was added to your Hill Wallet.', 'wallet', '[]', NULL, '2026-07-31 19:45:40', '2026-07-31 19:45:40'),
(202, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":16}', NULL, '2026-07-31 19:45:44', '2026-07-31 19:45:44'),
(203, 4, 'customer', 'Finding your driver', 'Ride RID-LJLT9S6 — searching nearby bike drivers.', 'ride', '{\"ride_id\":15}', NULL, '2026-07-31 19:45:44', '2026-07-31 19:45:44'),
(204, 4, 'customer', 'Driver assigned', 'Demo Rider is on the way.', 'ride', '{\"ride_id\":15}', NULL, '2026-07-31 19:45:48', '2026-07-31 19:45:48'),
(205, 4, 'customer', 'Ride completed', 'Fare ৳63. Thanks for riding with HillGo!', 'ride', '{\"ride_id\":15}', NULL, '2026-07-31 19:45:52', '2026-07-31 19:45:52'),
(206, 5, 'rider', 'Trip completed', '৳63 earned (net credited to balance).', 'earning', '{\"trip_id\":16}', NULL, '2026-07-31 19:45:52', '2026-07-31 19:45:52'),
(207, 5, 'rider', 'New job offer', 'Ride job ৳74', 'offer', '{\"trip_id\":17}', NULL, '2026-07-31 19:45:56', '2026-07-31 19:45:56'),
(208, 4, 'customer', 'Finding your driver', 'Ride RID-LJOGXV1 — searching nearby bike drivers.', 'ride', '{\"ride_id\":16}', NULL, '2026-07-31 19:45:56', '2026-07-31 19:45:56'),
(209, 6, 'merchant', 'New order', 'Order ORD-LJPQVE2 — ৳250', 'new_order', '{\"order_id\":2}', NULL, '2026-07-31 19:46:02', '2026-07-31 19:46:02'),
(210, 4, 'customer', 'Order placed', 'Your order ORD-LJPQVE2 was sent to Demo Kitchen.', 'food', '{\"order_id\":2}', NULL, '2026-07-31 19:46:02', '2026-07-31 19:46:02'),
(211, 4, 'customer', 'Order accepted', 'Demo Kitchen is preparing your order.', 'food', '{\"order_id\":2}', NULL, '2026-07-31 19:46:03', '2026-07-31 19:46:03'),
(212, 5, 'rider', 'New job offer', 'Food job ৳30', 'offer', '{\"trip_id\":18}', NULL, '2026-07-31 19:46:04', '2026-07-31 19:46:04'),
(213, 4, 'customer', 'Order ready', 'Your order is packed — assigning a rider now.', 'food', '{\"order_id\":2}', NULL, '2026-07-31 19:46:04', '2026-07-31 19:46:04'),
(214, 4, 'customer', 'Rider assigned', 'Demo Rider will deliver your order.', 'food', '{\"order_id\":2}', NULL, '2026-07-31 19:46:06', '2026-07-31 19:46:06'),
(215, 4, 'customer', 'Order on the way', 'Your food is heading to you now.', 'food', '{\"order_id\":2}', NULL, '2026-07-31 19:46:09', '2026-07-31 19:46:09'),
(216, 4, 'customer', 'Order delivered', 'Enjoy your meal! Rate your experience.', 'food', '{\"order_id\":2}', NULL, '2026-07-31 19:46:10', '2026-07-31 19:46:10'),
(217, 6, 'merchant', 'Order delivered', 'Order ORD-LJPQVE2 was delivered.', 'order', '{\"order_id\":2}', NULL, '2026-07-31 19:46:10', '2026-07-31 19:46:10'),
(218, 5, 'rider', 'Trip completed', '৳30 earned (net credited to balance).', 'earning', '{\"trip_id\":18}', NULL, '2026-07-31 19:46:10', '2026-07-31 19:46:10'),
(219, NULL, 'admin', 'Courier bank details changed', 'Demo Courier updated bank details — re-verify.', 'kyc', '[]', NULL, '2026-07-31 19:46:13', '2026-07-31 19:46:13'),
(220, 7, 'courier_agent', 'KYC approved', 'You are verified and can now receive parcel assignments.', 'kyc', '[]', NULL, '2026-07-31 19:46:15', '2026-07-31 19:46:15'),
(221, 7, 'courier_agent', 'New parcel assigned', 'Parcel HG-LJSRKS8: Gulshan Circle 1 → Banani 11', 'parcel_assigned', '{\"parcel_id\":2}', NULL, '2026-07-31 19:46:18', '2026-07-31 19:46:18'),
(222, 4, 'customer', 'Parcel booked', 'Tracking HG-LJSRKS8. Pickup OTP: 8786 · Delivery OTP: 9820 (share with the receiver).', 'parcel', '{\"parcel_id\":2,\"pickup_otp\":\"8786\",\"delivery_otp\":\"9820\"}', NULL, '2026-07-31 19:46:18', '2026-07-31 19:46:18'),
(223, 4, 'customer', 'Parcel picked up', 'Parcel HG-LJSRKS8 was collected by the courier.', 'parcel', '{\"parcel_id\":2}', NULL, '2026-07-31 19:46:21', '2026-07-31 19:46:21'),
(224, 4, 'customer', 'Parcel in transit', 'Parcel HG-LJSRKS8 is on the way.', 'parcel', '{\"parcel_id\":2}', NULL, '2026-07-31 19:46:22', '2026-07-31 19:46:22'),
(225, 4, 'customer', 'Parcel delivered', 'Parcel HG-LJSRKS8 was delivered successfully.', 'parcel', '{\"parcel_id\":2}', NULL, '2026-07-31 19:46:25', '2026-07-31 19:46:25'),
(226, 7, 'courier_agent', 'Delivery complete', '৳110 earned for HG-LJSRKS8.', 'earning', '[]', NULL, '2026-07-31 19:46:25', '2026-07-31 19:46:25'),
(227, NULL, 'admin', 'Courier withdrawal request', 'Demo Courier: ৳500 via bKash', 'payout', '{\"withdrawal_id\":1}', NULL, '2026-07-31 19:48:10', '2026-07-31 19:48:10'),
(228, 7, 'courier_agent', 'Withdrawal requested', '৳500 request submitted.', 'payout', '[]', NULL, '2026-07-31 19:48:10', '2026-07-31 19:48:10'),
(229, 7, 'courier_agent', 'Withdrawal paid', 'Your withdrawal of ৳500 is paid.', 'payout', '[]', NULL, '2026-07-31 19:48:11', '2026-07-31 19:48:11'),
(230, NULL, 'admin', 'SOS ALERT', 'Demo Customer triggered sos at E2E Banani', 'sos', '{\"alert_id\":1,\"user_id\":4,\"lat\":null,\"lng\":null}', NULL, '2026-07-31 19:48:21', '2026-07-31 19:48:21'),
(231, 4, 'customer', 'SOS resolved', 'Your emergency alert has been marked resolved by our team.', 'sos', '[]', NULL, '2026-07-31 19:48:22', '2026-07-31 19:48:22'),
(232, NULL, 'admin', 'Rider cash-out request', 'Demo Rider: ৳100 via bKash', 'payout', '{\"payout_id\":1}', NULL, '2026-07-31 19:49:03', '2026-07-31 19:49:03'),
(233, 5, 'rider', 'Cash-out requested', '৳100 request submitted for review.', 'payout', '[]', NULL, '2026-07-31 19:49:03', '2026-07-31 19:49:03'),
(234, 5, 'rider', 'Payout paid', 'Your cash-out of ৳100 is paid.', 'payout', '[]', NULL, '2026-07-31 19:49:04', '2026-07-31 19:49:04'),
(235, NULL, 'admin', 'Courier withdrawal request', 'Demo Courier: ৳500 via bKash', 'payout', '{\"withdrawal_id\":2}', NULL, '2026-07-31 19:49:07', '2026-07-31 19:49:07'),
(236, 7, 'courier_agent', 'Withdrawal requested', '৳500 request submitted.', 'payout', '[]', NULL, '2026-07-31 19:49:07', '2026-07-31 19:49:07'),
(237, 7, 'courier_agent', 'Withdrawal paid', 'Your withdrawal of ৳500 is paid.', 'payout', '[]', NULL, '2026-07-31 19:49:08', '2026-07-31 19:49:08'),
(238, NULL, 'admin', 'SOS ALERT', 'Demo Customer triggered sos at E2E Banani', 'sos', '{\"alert_id\":2,\"user_id\":4,\"lat\":null,\"lng\":null}', NULL, '2026-07-31 19:49:18', '2026-07-31 19:49:18'),
(239, 4, 'customer', 'SOS resolved', 'Your emergency alert has been marked resolved by our team.', 'sos', '[]', NULL, '2026-07-31 19:49:19', '2026-07-31 19:49:19'),
(240, NULL, 'admin', 'Early payout request', 'Demo Kitchen: ৳1000 (Bank, fee ৳20)', 'payout', '{\"payout_id\":1}', NULL, '2026-07-31 19:49:49', '2026-07-31 19:49:49'),
(241, 6, 'merchant', 'Payout completed', 'Payout of ৳1000 is now completed.', 'payout', '[]', NULL, '2026-07-31 19:49:50', '2026-07-31 19:49:50'),
(242, NULL, 'admin', 'Courier withdrawal request', 'Demo Courier: ৳500 via bKash', 'payout', '{\"withdrawal_id\":3}', NULL, '2026-07-31 19:49:57', '2026-07-31 19:49:57'),
(243, 7, 'courier_agent', 'Withdrawal requested', '৳500 request submitted.', 'payout', '[]', NULL, '2026-07-31 19:49:57', '2026-07-31 19:49:57'),
(244, 7, 'courier_agent', 'Withdrawal paid', 'Your withdrawal of ৳500 is paid.', 'payout', '[]', NULL, '2026-07-31 19:49:58', '2026-07-31 19:49:58'),
(245, NULL, 'admin', 'SOS ALERT', 'Demo Customer triggered sos at E2E Banani', 'sos', '{\"alert_id\":3,\"user_id\":4,\"lat\":null,\"lng\":null}', NULL, '2026-07-31 19:50:08', '2026-07-31 19:50:08'),
(246, 4, 'customer', 'SOS resolved', 'Your emergency alert has been marked resolved by our team.', 'sos', '[]', NULL, '2026-07-31 19:50:09', '2026-07-31 19:50:09'),
(247, NULL, 'admin', 'Early payout request', 'Demo Kitchen: ৳1000 (Bank, fee ৳20)', 'payout', '{\"payout_id\":2}', NULL, '2026-07-31 19:50:44', '2026-07-31 19:50:44'),
(248, 6, 'merchant', 'Payout completed', 'Payout of ৳1000 is now completed.', 'payout', '[]', NULL, '2026-07-31 19:50:45', '2026-07-31 19:50:45'),
(249, NULL, 'admin', 'Rider cash-out request', 'Demo Rider: ৳100 via bKash', 'payout', '{\"payout_id\":2}', NULL, '2026-07-31 19:50:49', '2026-07-31 19:50:49'),
(250, 5, 'rider', 'Cash-out requested', '৳100 request submitted for review.', 'payout', '[]', NULL, '2026-07-31 19:50:49', '2026-07-31 19:50:49'),
(251, 5, 'rider', 'Payout paid', 'Your cash-out of ৳100 is paid.', 'payout', '[]', NULL, '2026-07-31 19:50:50', '2026-07-31 19:50:50'),
(252, NULL, 'admin', 'Courier withdrawal request', 'Demo Courier: ৳500 via bKash', 'payout', '{\"withdrawal_id\":4}', NULL, '2026-07-31 19:50:53', '2026-07-31 19:50:53'),
(253, 7, 'courier_agent', 'Withdrawal requested', '৳500 request submitted.', 'payout', '[]', NULL, '2026-07-31 19:50:53', '2026-07-31 19:50:53'),
(254, 7, 'courier_agent', 'Withdrawal paid', 'Your withdrawal of ৳500 is paid.', 'payout', '[]', NULL, '2026-07-31 19:50:54', '2026-07-31 19:50:54'),
(255, NULL, 'admin', 'SOS ALERT', 'Demo Customer triggered sos at E2E Banani', 'sos', '{\"alert_id\":4,\"user_id\":4,\"lat\":null,\"lng\":null}', NULL, '2026-07-31 19:51:04', '2026-07-31 19:51:04'),
(256, 4, 'customer', 'SOS resolved', 'Your emergency alert has been marked resolved by our team.', 'sos', '[]', NULL, '2026-07-31 19:51:04', '2026-07-31 19:51:04'),
(257, 4, 'customer', 'Wallet updated', '৳10 was added to your Hill Wallet.', 'wallet', '[]', NULL, '2026-07-31 21:09:57', '2026-07-31 21:09:57'),
(258, 5, 'rider', 'New job offer', 'Ride job ৳63', 'offer', '{\"trip_id\":19}', NULL, '2026-07-31 21:10:01', '2026-07-31 21:10:01'),
(259, 4, 'customer', 'Finding your driver', 'Ride RID-MDPOWI9 — searching nearby bike drivers.', 'ride', '{\"ride_id\":17}', NULL, '2026-07-31 21:10:01', '2026-07-31 21:10:01'),
(260, 4, 'customer', 'Driver assigned', 'Demo Rider is on the way.', 'ride', '{\"ride_id\":17}', NULL, '2026-07-31 21:10:05', '2026-07-31 21:10:05'),
(261, 4, 'customer', 'Ride completed', 'Fare ৳63. Thanks for riding with HillGo!', 'ride', '{\"ride_id\":17}', NULL, '2026-07-31 21:10:10', '2026-07-31 21:10:10'),
(262, 5, 'rider', 'Trip completed', '৳63 earned (net credited to balance).', 'earning', '{\"trip_id\":19}', NULL, '2026-07-31 21:10:10', '2026-07-31 21:10:10'),
(263, 5, 'rider', 'New job offer', 'Ride job ৳74', 'offer', '{\"trip_id\":20}', NULL, '2026-07-31 21:10:14', '2026-07-31 21:10:14'),
(264, 4, 'customer', 'Finding your driver', 'Ride RID-MDSMB84 — searching nearby bike drivers.', 'ride', '{\"ride_id\":18}', NULL, '2026-07-31 21:10:14', '2026-07-31 21:10:14'),
(265, 6, 'merchant', 'New order', 'Order ORD-MDU6105 — ৳250', 'new_order', '{\"order_id\":3}', NULL, '2026-07-31 21:10:22', '2026-07-31 21:10:22'),
(266, 4, 'customer', 'Order placed', 'Your order ORD-MDU6105 was sent to Demo Kitchen.', 'food', '{\"order_id\":3}', NULL, '2026-07-31 21:10:22', '2026-07-31 21:10:22'),
(267, 4, 'customer', 'Order accepted', 'Demo Kitchen is preparing your order.', 'food', '{\"order_id\":3}', NULL, '2026-07-31 21:10:23', '2026-07-31 21:10:23'),
(268, 5, 'rider', 'New job offer', 'Food job ৳30', 'offer', '{\"trip_id\":21}', NULL, '2026-07-31 21:10:24', '2026-07-31 21:10:24'),
(269, 4, 'customer', 'Order ready', 'Your order is packed — assigning a rider now.', 'food', '{\"order_id\":3}', NULL, '2026-07-31 21:10:24', '2026-07-31 21:10:24'),
(270, 4, 'customer', 'Rider assigned', 'Demo Rider will deliver your order.', 'food', '{\"order_id\":3}', NULL, '2026-07-31 21:10:27', '2026-07-31 21:10:27'),
(271, 4, 'customer', 'Order on the way', 'Your food is heading to you now.', 'food', '{\"order_id\":3}', NULL, '2026-07-31 21:10:29', '2026-07-31 21:10:29'),
(272, 4, 'customer', 'Order delivered', 'Enjoy your meal! Rate your experience.', 'food', '{\"order_id\":3}', NULL, '2026-07-31 21:10:30', '2026-07-31 21:10:30'),
(273, 6, 'merchant', 'Order delivered', 'Order ORD-MDU6105 was delivered.', 'order', '{\"order_id\":3}', NULL, '2026-07-31 21:10:30', '2026-07-31 21:10:30'),
(274, 5, 'rider', 'Trip completed', '৳30 earned (net credited to balance).', 'earning', '{\"trip_id\":21}', NULL, '2026-07-31 21:10:30', '2026-07-31 21:10:30'),
(275, NULL, 'admin', 'Courier bank details changed', 'Demo Courier updated bank details — re-verify.', 'kyc', '[]', NULL, '2026-07-31 21:10:34', '2026-07-31 21:10:34'),
(276, 7, 'courier_agent', 'KYC approved', 'You are verified and can now receive parcel assignments.', 'kyc', '[]', NULL, '2026-07-31 21:10:36', '2026-07-31 21:10:36'),
(277, 7, 'courier_agent', 'New parcel assigned', 'Parcel HG-MDXLUW2: Gulshan Circle 1 → Banani 11', 'parcel_assigned', '{\"parcel_id\":3}', NULL, '2026-07-31 21:10:39', '2026-07-31 21:10:39'),
(278, 4, 'customer', 'Parcel booked', 'Tracking HG-MDXLUW2. Pickup OTP: 3822 · Delivery OTP: 2281 (share with the receiver).', 'parcel', '{\"parcel_id\":3,\"pickup_otp\":\"3822\",\"delivery_otp\":\"2281\"}', NULL, '2026-07-31 21:10:39', '2026-07-31 21:10:39'),
(279, 4, 'customer', 'Parcel picked up', 'Parcel HG-MDXLUW2 was collected by the courier.', 'parcel', '{\"parcel_id\":3}', NULL, '2026-07-31 21:10:43', '2026-07-31 21:10:43'),
(280, 4, 'customer', 'Parcel in transit', 'Parcel HG-MDXLUW2 is on the way.', 'parcel', '{\"parcel_id\":3}', NULL, '2026-07-31 21:10:44', '2026-07-31 21:10:44'),
(281, 4, 'customer', 'Parcel delivered', 'Parcel HG-MDXLUW2 was delivered successfully.', 'parcel', '{\"parcel_id\":3}', NULL, '2026-07-31 21:10:47', '2026-07-31 21:10:47'),
(282, 7, 'courier_agent', 'Delivery complete', '৳110 earned for HG-MDXLUW2.', 'earning', '[]', NULL, '2026-07-31 21:10:47', '2026-07-31 21:10:47'),
(283, NULL, 'admin', 'Early payout request', 'Demo Kitchen: ৳1000 (Bank, fee ৳20)', 'payout', '{\"payout_id\":3}', NULL, '2026-07-31 21:12:10', '2026-07-31 21:12:10'),
(284, 6, 'merchant', 'Payout completed', 'Payout of ৳1000 is now completed.', 'payout', '[]', NULL, '2026-07-31 21:12:11', '2026-07-31 21:12:11'),
(285, NULL, 'admin', 'Rider cash-out request', 'Demo Rider: ৳100 via bKash', 'payout', '{\"payout_id\":3}', NULL, '2026-07-31 21:12:16', '2026-07-31 21:12:16'),
(286, 5, 'rider', 'Cash-out requested', '৳100 request submitted for review.', 'payout', '[]', NULL, '2026-07-31 21:12:16', '2026-07-31 21:12:16'),
(287, 5, 'rider', 'Payout paid', 'Your cash-out of ৳100 is paid.', 'payout', '[]', NULL, '2026-07-31 21:12:18', '2026-07-31 21:12:18'),
(288, NULL, 'admin', 'Courier withdrawal request', 'Demo Courier: ৳500 via bKash', 'payout', '{\"withdrawal_id\":5}', NULL, '2026-07-31 21:12:21', '2026-07-31 21:12:21'),
(289, 7, 'courier_agent', 'Withdrawal requested', '৳500 request submitted.', 'payout', '[]', NULL, '2026-07-31 21:12:21', '2026-07-31 21:12:21'),
(290, 7, 'courier_agent', 'Withdrawal paid', 'Your withdrawal of ৳500 is paid.', 'payout', '[]', NULL, '2026-07-31 21:12:22', '2026-07-31 21:12:22'),
(291, NULL, 'admin', 'SOS ALERT', 'Demo Customer triggered sos at E2E Banani', 'sos', '{\"alert_id\":5,\"user_id\":4,\"lat\":null,\"lng\":null}', NULL, '2026-07-31 21:12:33', '2026-07-31 21:12:33'),
(292, 4, 'customer', 'SOS resolved', 'Your emergency alert has been marked resolved by our team.', 'sos', '[]', NULL, '2026-07-31 21:12:34', '2026-07-31 21:12:34'),
(293, 5, 'rider', 'New job offer', 'Ride job ৳53', 'offer', '{\"trip_id\":22}', NULL, '2026-07-31 21:15:30', '2026-07-31 21:15:30'),
(294, 4, 'customer', 'Finding your driver', 'Ride RID-MFODB63 — searching nearby bike drivers.', 'ride', '{\"ride_id\":19}', NULL, '2026-07-31 21:15:30', '2026-07-31 21:15:30'),
(295, 4, 'customer', 'Wallet updated', '৳1 was added to your Hill Wallet.', 'wallet', '[]', NULL, '2026-07-31 21:15:44', '2026-07-31 21:15:44'),
(296, 5, 'rider', 'New job offer', 'Ride job ৳53', 'offer', '{\"trip_id\":23}', NULL, '2026-07-31 21:20:08', '2026-07-31 21:20:08'),
(297, 4, 'customer', 'Finding your driver', 'Ride RID-MHBXM18 — searching nearby bike drivers.', 'ride', '{\"ride_id\":20}', NULL, '2026-07-31 21:20:08', '2026-07-31 21:20:08'),
(298, 4, 'customer', 'Wallet updated', '৳1 was added to your Hill Wallet.', 'wallet', '[]', NULL, '2026-07-31 21:20:22', '2026-07-31 21:20:22');

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
('hillgo-cache-51a579d9f64b859f0d9d1e4dbe599c60', 'i:2;', 1785532833),
('hillgo-cache-51a579d9f64b859f0d9d1e4dbe599c60:timer', 'i:1785532833;', 1785532833),
('hillgo-cache-6864486a4b174e5881466351ada86418', 'i:2;', 1785532822),
('hillgo-cache-6864486a4b174e5881466351ada86418:timer', 'i:1785532822;', 1785532822),
('hillgo-cache-725980f775056522d850ef39fb80259e', 'i:2;', 1785532831),
('hillgo-cache-725980f775056522d850ef39fb80259e:timer', 'i:1785532831;', 1785532831),
('hillgo-cache-77e8208b275ff0f1bd0298da2b4d9a87', 'i:3;', 1785532829),
('hillgo-cache-77e8208b275ff0f1bd0298da2b4d9a87:timer', 'i:1785532829;', 1785532829),
('hillgo-cache-7ad6d6ead1b97a1e41dd830857e9c7f2', 'i:3;', 1785532824),
('hillgo-cache-7ad6d6ead1b97a1e41dd830857e9c7f2:timer', 'i:1785532824;', 1785532824),
('hillgo-cache-7bfe417ae597c3f160e990f2257eee3d', 'i:1;', 1785532302),
('hillgo-cache-7bfe417ae597c3f160e990f2257eee3d:timer', 'i:1785532301;', 1785532302),
('hillgo-cache-825f54beff5d1c68aae4637bf60f828e', 'i:2;', 1785532884),
('hillgo-cache-825f54beff5d1c68aae4637bf60f828e:timer', 'i:1785532884;', 1785532884),
('hillgo-cache-8dc0217468609300bfc0c490b94e45e8', 'i:1;', 1785532194),
('hillgo-cache-8dc0217468609300bfc0c490b94e45e8:timer', 'i:1785532194;', 1785532194),
('hillgo-cache-9cfcbeb6130fbaca20d6c6ffcbdfc646', 'i:3;', 1785532877),
('hillgo-cache-9cfcbeb6130fbaca20d6c6ffcbdfc646:timer', 'i:1785532877;', 1785532877),
('hillgo-cache-cb154aff09d252f39ccf35fda5451540', 'i:2;', 1785532830),
('hillgo-cache-cb154aff09d252f39ccf35fda5451540:timer', 'i:1785532830;', 1785532830),
('hillgo-cache-ef87b9aec8dcbc281acccb7e596b3805', 'i:1;', 1785532306),
('hillgo-cache-ef87b9aec8dcbc281acccb7e596b3805:timer', 'i:1785532306;', 1785532306),
('hillgo-cache-pricing.courier', 'a:10:{s:10:\"parcelBase\";i:50;s:5:\"perKm\";i:12;s:5:\"perKg\";i:8;s:17:\"expressMultiplier\";d:1.4;s:18:\"priorityMultiplier\";d:1.25;s:8:\"surgeCap\";i:100;s:21:\"platformCommissionPct\";i:12;s:20:\"weeklyGoalDeliveries\";i:50;s:22:\"topPerformerMultiplier\";d:1.2;s:13:\"withdrawalMin\";i:500;}', 1785532849),
('hillgo-cache-pricing.customer', 'a:14:{s:8:\"rideBase\";i:30;s:9:\"ridePerKm\";i:15;s:10:\"ridePerMin\";i:1;s:11:\"rideMinimum\";i:50;s:15:\"foodDeliveryFee\";i:30;s:21:\"freeDeliveryThreshold\";i:300;s:10:\"parcelBase\";i:40;s:11:\"parcelPerKm\";i:12;s:11:\"parcelPerKg\";i:8;s:13:\"parcelMinimum\";i:50;s:19:\"marketplaceDelivery\";i:40;s:18:\"hotelServiceFeePct\";i:5;s:18:\"rentalDriverPerDay\";i:1500;s:21:\"rentalInsurancePerDay\";i:300;}', 1785532842),
('hillgo-cache-pricing.merchant', 'a:6:{s:21:\"platformCommissionPct\";i:15;s:15:\"orderServiceFee\";i:25;s:9:\"taxVatPct\";i:5;s:15:\"settlementCycle\";s:6:\"weekly\";s:17:\"earlyPayoutFeePct\";i:2;s:15:\"minPayoutAmount\";i:1000;}', 1785532388),
('hillgo-cache-pricing.rider', 'a:14:{s:8:\"rideBase\";i:30;s:9:\"ridePerKm\";i:15;s:10:\"ridePerMin\";i:1;s:11:\"rideMinimum\";i:50;s:14:\"bikeMultiplier\";d:0.7;s:13:\"carMultiplier\";i:1;s:12:\"xlMultiplier\";d:1.5;s:10:\"foodJobFee\";i:30;s:10:\"parcelBase\";i:40;s:11:\"parcelPerKm\";i:12;s:11:\"parcelPerKg\";i:8;s:13:\"parcelMinimum\";i:50;s:12:\"defaultSurge\";d:1.8;s:21:\"platformCommissionPct\";i:15;}', 1785532868),
('hillgo-cache-public.districts.v1', 'a:64:{i:0;a:8:{s:2:\"id\";s:16:\"khulna__bagerhat\";s:4:\"name\";s:8:\"Bagerhat\";s:8:\"division\";s:6:\"Khulna\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:1;a:8:{s:2:\"id\";s:21:\"chattogram__bandarban\";s:4:\"name\";s:9:\"Bandarban\";s:8:\"division\";s:10:\"Chattogram\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:2;a:8:{s:2:\"id\";s:17:\"barishal__barguna\";s:4:\"name\";s:7:\"Barguna\";s:8:\"division\";s:8:\"Barishal\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:3;a:8:{s:2:\"id\";s:18:\"barishal__barishal\";s:4:\"name\";s:8:\"Barishal\";s:8:\"division\";s:8:\"Barishal\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:4;a:8:{s:2:\"id\";s:15:\"barishal__bhola\";s:4:\"name\";s:5:\"Bhola\";s:8:\"division\";s:8:\"Barishal\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:5;a:8:{s:2:\"id\";s:16:\"rajshahi__bogura\";s:4:\"name\";s:6:\"Bogura\";s:8:\"division\";s:8:\"Rajshahi\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:6;a:8:{s:2:\"id\";s:24:\"chattogram__brahmanbaria\";s:4:\"name\";s:12:\"Brahmanbaria\";s:8:\"division\";s:10:\"Chattogram\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:7;a:8:{s:2:\"id\";s:20:\"chattogram__chandpur\";s:4:\"name\";s:8:\"Chandpur\";s:8:\"division\";s:10:\"Chattogram\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:8;a:8:{s:2:\"id\";s:25:\"rajshahi__chapainawabganj\";s:4:\"name\";s:15:\"Chapainawabganj\";s:8:\"division\";s:8:\"Rajshahi\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:9;a:8:{s:2:\"id\";s:22:\"chattogram__chattogram\";s:4:\"name\";s:10:\"Chattogram\";s:8:\"division\";s:10:\"Chattogram\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:10;a:8:{s:2:\"id\";s:17:\"khulna__chuadanga\";s:4:\"name\";s:9:\"Chuadanga\";s:8:\"division\";s:6:\"Khulna\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:11;a:8:{s:2:\"id\";s:22:\"chattogram__coxs-bazar\";s:4:\"name\";s:11:\"Cox\'s Bazar\";s:8:\"division\";s:10:\"Chattogram\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:12;a:8:{s:2:\"id\";s:19:\"chattogram__cumilla\";s:4:\"name\";s:7:\"Cumilla\";s:8:\"division\";s:10:\"Chattogram\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:13;a:8:{s:2:\"id\";s:12:\"dhaka__dhaka\";s:4:\"name\";s:5:\"Dhaka\";s:8:\"division\";s:5:\"Dhaka\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:14;a:8:{s:2:\"id\";s:17:\"rangpur__dinajpur\";s:4:\"name\";s:8:\"Dinajpur\";s:8:\"division\";s:7:\"Rangpur\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:15;a:8:{s:2:\"id\";s:15:\"dhaka__faridpur\";s:4:\"name\";s:8:\"Faridpur\";s:8:\"division\";s:5:\"Dhaka\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:16;a:8:{s:2:\"id\";s:16:\"chattogram__feni\";s:4:\"name\";s:4:\"Feni\";s:8:\"division\";s:10:\"Chattogram\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:17;a:8:{s:2:\"id\";s:18:\"rangpur__gaibandha\";s:4:\"name\";s:9:\"Gaibandha\";s:8:\"division\";s:7:\"Rangpur\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:18;a:8:{s:2:\"id\";s:14:\"dhaka__gazipur\";s:4:\"name\";s:7:\"Gazipur\";s:8:\"division\";s:5:\"Dhaka\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:19;a:8:{s:2:\"id\";s:16:\"dhaka__gopalganj\";s:4:\"name\";s:9:\"Gopalganj\";s:8:\"division\";s:5:\"Dhaka\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:20;a:8:{s:2:\"id\";s:16:\"sylhet__habiganj\";s:4:\"name\";s:8:\"Habiganj\";s:8:\"division\";s:6:\"Sylhet\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:21;a:8:{s:2:\"id\";s:20:\"mymensingh__jamalpur\";s:4:\"name\";s:8:\"Jamalpur\";s:8:\"division\";s:10:\"Mymensingh\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:22;a:8:{s:2:\"id\";s:15:\"khulna__jashore\";s:4:\"name\";s:7:\"Jashore\";s:8:\"division\";s:6:\"Khulna\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:23;a:8:{s:2:\"id\";s:20:\"barishal__jhalokathi\";s:4:\"name\";s:10:\"Jhalokathi\";s:8:\"division\";s:8:\"Barishal\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:24;a:8:{s:2:\"id\";s:17:\"khulna__jhenaidah\";s:4:\"name\";s:9:\"Jhenaidah\";s:8:\"division\";s:6:\"Khulna\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:25;a:8:{s:2:\"id\";s:19:\"rajshahi__joypurhat\";s:4:\"name\";s:9:\"Joypurhat\";s:8:\"division\";s:8:\"Rajshahi\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:26;a:8:{s:2:\"id\";s:24:\"chattogram__khagrachhari\";s:4:\"name\";s:12:\"Khagrachhari\";s:8:\"division\";s:10:\"Chattogram\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:27;a:8:{s:2:\"id\";s:14:\"khulna__khulna\";s:4:\"name\";s:6:\"Khulna\";s:8:\"division\";s:6:\"Khulna\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:28;a:8:{s:2:\"id\";s:18:\"dhaka__kishoreganj\";s:4:\"name\";s:11:\"Kishoreganj\";s:8:\"division\";s:5:\"Dhaka\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:29;a:8:{s:2:\"id\";s:17:\"rangpur__kurigram\";s:4:\"name\";s:8:\"Kurigram\";s:8:\"division\";s:7:\"Rangpur\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:30;a:8:{s:2:\"id\";s:15:\"khulna__kushtia\";s:4:\"name\";s:7:\"Kushtia\";s:8:\"division\";s:6:\"Khulna\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:31;a:8:{s:2:\"id\";s:22:\"chattogram__lakshmipur\";s:4:\"name\";s:10:\"Lakshmipur\";s:8:\"division\";s:10:\"Chattogram\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:32;a:8:{s:2:\"id\";s:20:\"rangpur__lalmonirhat\";s:4:\"name\";s:11:\"Lalmonirhat\";s:8:\"division\";s:7:\"Rangpur\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:33;a:8:{s:2:\"id\";s:16:\"dhaka__madaripur\";s:4:\"name\";s:9:\"Madaripur\";s:8:\"division\";s:5:\"Dhaka\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:34;a:8:{s:2:\"id\";s:14:\"khulna__magura\";s:4:\"name\";s:6:\"Magura\";s:8:\"division\";s:6:\"Khulna\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:35;a:8:{s:2:\"id\";s:16:\"dhaka__manikganj\";s:4:\"name\";s:9:\"Manikganj\";s:8:\"division\";s:5:\"Dhaka\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:36;a:8:{s:2:\"id\";s:16:\"khulna__meherpur\";s:4:\"name\";s:8:\"Meherpur\";s:8:\"division\";s:6:\"Khulna\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:37;a:8:{s:2:\"id\";s:19:\"sylhet__moulvibazar\";s:4:\"name\";s:11:\"Moulvibazar\";s:8:\"division\";s:6:\"Sylhet\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:38;a:8:{s:2:\"id\";s:17:\"dhaka__munshiganj\";s:4:\"name\";s:10:\"Munshiganj\";s:8:\"division\";s:5:\"Dhaka\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:39;a:8:{s:2:\"id\";s:22:\"mymensingh__mymensingh\";s:4:\"name\";s:10:\"Mymensingh\";s:8:\"division\";s:10:\"Mymensingh\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:40;a:8:{s:2:\"id\";s:17:\"rajshahi__naogaon\";s:4:\"name\";s:7:\"Naogaon\";s:8:\"division\";s:8:\"Rajshahi\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:41;a:8:{s:2:\"id\";s:14:\"khulna__narail\";s:4:\"name\";s:6:\"Narail\";s:8:\"division\";s:6:\"Khulna\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:42;a:8:{s:2:\"id\";s:18:\"dhaka__narayanganj\";s:4:\"name\";s:11:\"Narayanganj\";s:8:\"division\";s:5:\"Dhaka\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:43;a:8:{s:2:\"id\";s:16:\"dhaka__narsingdi\";s:4:\"name\";s:9:\"Narsingdi\";s:8:\"division\";s:5:\"Dhaka\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:44;a:8:{s:2:\"id\";s:16:\"rajshahi__natore\";s:4:\"name\";s:6:\"Natore\";s:8:\"division\";s:8:\"Rajshahi\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:45;a:8:{s:2:\"id\";s:21:\"mymensingh__netrokona\";s:4:\"name\";s:9:\"Netrokona\";s:8:\"division\";s:10:\"Mymensingh\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:46;a:8:{s:2:\"id\";s:19:\"rangpur__nilphamari\";s:4:\"name\";s:10:\"Nilphamari\";s:8:\"division\";s:7:\"Rangpur\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:47;a:8:{s:2:\"id\";s:20:\"chattogram__noakhali\";s:4:\"name\";s:8:\"Noakhali\";s:8:\"division\";s:10:\"Chattogram\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:48;a:8:{s:2:\"id\";s:15:\"rajshahi__pabna\";s:4:\"name\";s:5:\"Pabna\";s:8:\"division\";s:8:\"Rajshahi\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:49;a:8:{s:2:\"id\";s:19:\"rangpur__panchagarh\";s:4:\"name\";s:10:\"Panchagarh\";s:8:\"division\";s:7:\"Rangpur\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:50;a:8:{s:2:\"id\";s:20:\"barishal__patuakhali\";s:4:\"name\";s:10:\"Patuakhali\";s:8:\"division\";s:8:\"Barishal\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:51;a:8:{s:2:\"id\";s:18:\"barishal__pirojpur\";s:4:\"name\";s:8:\"Pirojpur\";s:8:\"division\";s:8:\"Barishal\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:52;a:8:{s:2:\"id\";s:14:\"dhaka__rajbari\";s:4:\"name\";s:7:\"Rajbari\";s:8:\"division\";s:5:\"Dhaka\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:53;a:8:{s:2:\"id\";s:18:\"rajshahi__rajshahi\";s:4:\"name\";s:8:\"Rajshahi\";s:8:\"division\";s:8:\"Rajshahi\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:54;a:8:{s:2:\"id\";s:21:\"chattogram__rangamati\";s:4:\"name\";s:9:\"Rangamati\";s:8:\"division\";s:10:\"Chattogram\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:55;a:8:{s:2:\"id\";s:16:\"rangpur__rangpur\";s:4:\"name\";s:7:\"Rangpur\";s:8:\"division\";s:7:\"Rangpur\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:56;a:8:{s:2:\"id\";s:16:\"khulna__satkhira\";s:4:\"name\";s:8:\"Satkhira\";s:8:\"division\";s:6:\"Khulna\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:57;a:8:{s:2:\"id\";s:17:\"dhaka__shariatpur\";s:4:\"name\";s:10:\"Shariatpur\";s:8:\"division\";s:5:\"Dhaka\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:58;a:8:{s:2:\"id\";s:19:\"mymensingh__sherpur\";s:4:\"name\";s:7:\"Sherpur\";s:8:\"division\";s:10:\"Mymensingh\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:59;a:8:{s:2:\"id\";s:19:\"rajshahi__sirajganj\";s:4:\"name\";s:9:\"Sirajganj\";s:8:\"division\";s:8:\"Rajshahi\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:60;a:8:{s:2:\"id\";s:17:\"sylhet__sunamganj\";s:4:\"name\";s:9:\"Sunamganj\";s:8:\"division\";s:6:\"Sylhet\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:61;a:8:{s:2:\"id\";s:14:\"sylhet__sylhet\";s:4:\"name\";s:6:\"Sylhet\";s:8:\"division\";s:6:\"Sylhet\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}i:62;a:8:{s:2:\"id\";s:14:\"dhaka__tangail\";s:4:\"name\";s:7:\"Tangail\";s:8:\"division\";s:5:\"Dhaka\";s:4:\"open\";b:1;s:14:\"allow_customer\";b:1;s:11:\"allow_rider\";b:1;s:14:\"allow_merchant\";b:1;s:13:\"allow_courier\";b:1;}i:63;a:8:{s:2:\"id\";s:19:\"rangpur__thakurgaon\";s:4:\"name\";s:10:\"Thakurgaon\";s:8:\"division\";s:7:\"Rangpur\";s:4:\"open\";b:0;s:14:\"allow_customer\";b:0;s:11:\"allow_rider\";b:0;s:14:\"allow_merchant\";b:0;s:13:\"allow_courier\";b:0;}}', 1785533129);

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
  `nid` text DEFAULT NULL,
  `kyc_status` enum('pending','action_required','uploaded','verified','rejected') NOT NULL DEFAULT 'pending',
  `kyc_submitted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `courier_profiles`
--

INSERT INTO `courier_profiles` (`id`, `user_id`, `code`, `vehicle_type`, `vehicle_name`, `plate`, `rating`, `deliveries_count`, `verified`, `bank_verified`, `bank_last4`, `online`, `lat`, `lng`, `last_location_at`, `balance`, `nid`, `kyc_status`, `kyc_submitted_at`, `created_at`, `updated_at`) VALUES
(1, 7, 'CG-FJZ1TG3', 'Motorbike', 'Demo Bike', 'DHAKA-DEMO-04', 0.00, 3, 1, 1, '4242', 1, NULL, NULL, NULL, 100.00, NULL, 'verified', NULL, '2026-07-31 03:42:06', '2026-07-31 21:12:22');

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

--
-- Dumping data for table `courier_withdrawals`
--

INSERT INTO `courier_withdrawals` (`id`, `code`, `courier_id`, `amount`, `method`, `bank_last4`, `status`, `created_at`, `updated_at`) VALUES
(1, 'WD-LKH9HO3', 7, 500.00, 'bKash', '4242', 'paid', '2026-07-31 19:48:10', '2026-07-31 19:48:11'),
(2, 'WD-LKTI0M5', 7, 500.00, 'bKash', '4242', 'paid', '2026-07-31 19:49:07', '2026-07-31 19:49:08'),
(3, 'WD-LL45806', 7, 500.00, 'bKash', '4242', 'paid', '2026-07-31 19:49:57', '2026-07-31 19:49:58'),
(4, 'WD-LLG3L86', 7, 500.00, 'bKash', '4242', 'paid', '2026-07-31 19:50:53', '2026-07-31 19:50:54'),
(5, 'WD-MEJSZE1', 7, 500.00, 'bKash', '4242', 'paid', '2026-07-31 21:12:21', '2026-07-31 21:12:22');

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
(1, 4, 'HG-FJYVSF0', 'Bronze', 532.00, 44, 3, 0.00, '2026-07-31 03:42:05', '2026-07-31 21:20:22');

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
  `updated_by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `districts`
--

INSERT INTO `districts` (`id`, `division_id`, `name`, `status`, `opened_at`, `allow_customer`, `allow_rider`, `allow_merchant`, `allow_courier`, `note`, `updated_by`, `updated_by_user_id`, `created_at`, `updated_at`) VALUES
('barishal__barguna', 'barishal', 'Barguna', 'closed', NULL, 0, 0, 0, 0, 'catalog-e2e', 'HillGo Super Admin', 1, '2026-07-31 01:56:43', '2026-07-31 21:15:43'),
('barishal__barishal', 'barishal', 'Barishal', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('barishal__bhola', 'barishal', 'Bhola', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('barishal__jhalokathi', 'barishal', 'Jhalokathi', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('barishal__patuakhali', 'barishal', 'Patuakhali', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('barishal__pirojpur', 'barishal', 'Pirojpur', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__bandarban', 'chattogram', 'Bandarban', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__brahmanbaria', 'chattogram', 'Brahmanbaria', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('chattogram__chandpur', 'chattogram', 'Chandpur', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('chattogram__chattogram', 'chattogram', 'Chattogram', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('chattogram__coxs-bazar', 'chattogram', 'Cox\'s Bazar', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('chattogram__cumilla', 'chattogram', 'Cumilla', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('chattogram__feni', 'chattogram', 'Feni', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('chattogram__khagrachhari', 'chattogram', 'Khagrachhari', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('chattogram__lakshmipur', 'chattogram', 'Lakshmipur', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('chattogram__noakhali', 'chattogram', 'Noakhali', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('chattogram__rangamati', 'chattogram', 'Rangamati', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__dhaka', 'dhaka', 'Dhaka', 'open', '2026-07-31 18:47:48', 1, 1, 1, 1, 'E2E attribution check 21:09:51', 'HillGo Super Admin', 1, '2026-07-31 01:56:43', '2026-07-31 21:09:53'),
('dhaka__faridpur', 'dhaka', 'Faridpur', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('dhaka__gazipur', 'dhaka', 'Gazipur', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('dhaka__gopalganj', 'dhaka', 'Gopalganj', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('dhaka__kishoreganj', 'dhaka', 'Kishoreganj', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('dhaka__madaripur', 'dhaka', 'Madaripur', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('dhaka__manikganj', 'dhaka', 'Manikganj', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('dhaka__munshiganj', 'dhaka', 'Munshiganj', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('dhaka__narayanganj', 'dhaka', 'Narayanganj', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('dhaka__narsingdi', 'dhaka', 'Narsingdi', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('dhaka__rajbari', 'dhaka', 'Rajbari', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('dhaka__shariatpur', 'dhaka', 'Shariatpur', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('dhaka__tangail', 'dhaka', 'Tangail', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('khulna__bagerhat', 'khulna', 'Bagerhat', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('khulna__chuadanga', 'khulna', 'Chuadanga', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('khulna__jashore', 'khulna', 'Jashore', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('khulna__jhenaidah', 'khulna', 'Jhenaidah', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('khulna__khulna', 'khulna', 'Khulna', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('khulna__kushtia', 'khulna', 'Kushtia', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('khulna__magura', 'khulna', 'Magura', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('khulna__meherpur', 'khulna', 'Meherpur', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('khulna__narail', 'khulna', 'Narail', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('khulna__satkhira', 'khulna', 'Satkhira', 'open', '2026-07-31 18:47:49', 1, 1, 1, 1, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 18:47:49'),
('mymensingh__jamalpur', 'mymensingh', 'Jamalpur', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('mymensingh__mymensingh', 'mymensingh', 'Mymensingh', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('mymensingh__netrokona', 'mymensingh', 'Netrokona', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('mymensingh__sherpur', 'mymensingh', 'Sherpur', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__bogura', 'rajshahi', 'Bogura', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__chapainawabganj', 'rajshahi', 'Chapainawabganj', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__joypurhat', 'rajshahi', 'Joypurhat', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__naogaon', 'rajshahi', 'Naogaon', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__natore', 'rajshahi', 'Natore', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__pabna', 'rajshahi', 'Pabna', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__rajshahi', 'rajshahi', 'Rajshahi', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rajshahi__sirajganj', 'rajshahi', 'Sirajganj', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__dinajpur', 'rangpur', 'Dinajpur', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__gaibandha', 'rangpur', 'Gaibandha', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__kurigram', 'rangpur', 'Kurigram', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__lalmonirhat', 'rangpur', 'Lalmonirhat', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__nilphamari', 'rangpur', 'Nilphamari', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__panchagarh', 'rangpur', 'Panchagarh', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__rangpur', 'rangpur', 'Rangpur', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('rangpur__thakurgaon', 'rangpur', 'Thakurgaon', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('sylhet__habiganj', 'sylhet', 'Habiganj', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('sylhet__moulvibazar', 'sylhet', 'Moulvibazar', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('sylhet__sunamganj', 'sylhet', 'Sunamganj', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43'),
('sylhet__sylhet', 'sylhet', 'Sylhet', 'closed', NULL, 0, 0, 0, 0, '', 'Seeder', NULL, '2026-07-31 01:56:43', '2026-07-31 01:56:43');

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
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
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
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `loyalty_rewards`
--

INSERT INTO `loyalty_rewards` (`id`, `title`, `description`, `points`, `type`, `active`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'Delivery voucher', '৳50 off any delivery', 500, 'voucher', 1, '2026-07-31 01:56:44', '2026-07-31 01:56:44', NULL),
(2, 'Free delivery pass', 'One free delivery', 800, 'voucher', 1, '2026-07-31 01:56:44', '2026-07-31 01:56:44', NULL),
(3, 'Marketplace coupon', '৳100 marketplace coupon', 1200, 'voucher', 1, '2026-07-31 01:56:44', '2026-07-31 01:56:44', NULL),
(4, 'Priority support', '30 days priority support', 1500, 'entitlement', 1, '2026-07-31 01:56:44', '2026-07-31 01:56:44', NULL);

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
(1, 1, 6, 'Demo Kitchen', 'HillGo demo merchant store', 'Demo Merchant', 'Restaurant & Cafe', NULL, '+8801710000003', 'merchant@demo.hillgo.app', 'Gulshan 1, Dhaka', 'Dhaka', 'dhaka__dhaka', NULL, NULL, NULL, NULL, 'approved', '2026-07-31 03:42:05', '2026-07-31 18:47:53');

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

--
-- Dumping data for table `merchant_payouts`
--

INSERT INTO `merchant_payouts` (`id`, `code`, `store_id`, `amount`, `method`, `status`, `early_request`, `fee`, `created_at`, `updated_at`) VALUES
(1, 'PAY-LL2IJW7', 1, 1000.00, 'Bank', 'completed', 1, 20.00, '2026-07-31 19:49:49', '2026-07-31 19:49:50'),
(2, 'PAY-LLE4P19', 1, 1000.00, 'Bank', 'completed', 1, 20.00, '2026-07-31 19:50:44', '2026-07-31 19:50:45'),
(3, 'PAY-MEHG7K0', 1, 1000.00, 'Bank', 'completed', 1, 20.00, '2026-07-31 21:12:10', '2026-07-31 21:12:11');

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
(11, '2026_07_31_120000_make_users_email_nullable', 2),
(12, '2026_08_01_000001_security_compliance_fixes', 3),
(13, '2026_08_01_010000_add_hot_path_indexes', 4);

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
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `code`, `store_id`, `customer_id`, `channel`, `priority`, `scheduled_for`, `status`, `subtotal`, `service_fee`, `tax`, `delivery_fee`, `discount`, `total`, `payment_method`, `delivery_address`, `customer_note`, `promo_code`, `delivered_at`, `rating`, `district_id`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'ORD-LIFHMF9', 1, 4, 'food', 'standard', NULL, 'delivered', 220.00, 0.00, 0.00, 30.00, 0.00, 250.00, 'cash', 'E2E Test Address, Gulshan', NULL, NULL, '2026-07-31 19:42:33', NULL, 'dhaka__dhaka', '2026-07-31 19:42:26', '2026-07-31 19:42:33', NULL),
(2, 'ORD-LJPQVE2', 1, 4, 'food', 'standard', NULL, 'delivered', 220.00, 0.00, 0.00, 30.00, 0.00, 250.00, 'cash', 'E2E Test Address, Gulshan', NULL, NULL, '2026-07-31 19:46:09', NULL, 'dhaka__dhaka', '2026-07-31 19:46:02', '2026-07-31 19:46:09', NULL),
(3, 'ORD-MDU6105', 1, 4, 'food', 'standard', NULL, 'delivered', 220.00, 0.00, 0.00, 30.00, 0.00, 250.00, 'cash', 'E2E Test Address, Gulshan', NULL, NULL, '2026-07-31 21:10:30', NULL, 'dhaka__dhaka', '2026-07-31 21:10:21', '2026-07-31 21:10:30', NULL);

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

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `name`, `qty`, `price`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo Biryani', 1, 220.00, NULL, '2026-07-31 19:42:26', '2026-07-31 19:42:26'),
(2, 2, 1, 'Demo Biryani', 1, 220.00, NULL, '2026-07-31 19:46:02', '2026-07-31 19:46:02'),
(3, 3, 1, 'Demo Biryani', 1, 220.00, NULL, '2026-07-31 21:10:21', '2026-07-31 21:10:21');

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
(4, '+8801710000002', 'rider', 'login', '$2y$12$jqSwKkncug3hQpYwQULidOIpQ7YsupHlO8oMfN.Yo0p5l2cU1Dt/G', 0, '2026-07-31 04:03:30', NULL, '2026-07-31 03:58:30', '2026-07-31 03:58:30'),
(7, '+8801710000001', 'customer', 'login', '$2y$12$M1hI35fxmijlTl/iCU6r8uWfC/JIVo7RWs8D2PtCimwhi.QKAck4y', 0, '2026-07-31 21:15:52', NULL, '2026-07-31 21:10:52', '2026-07-31 21:10:52');

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
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `parcels`
--

INSERT INTO `parcels` (`id`, `code`, `customer_id`, `type`, `priority`, `fulfillment_channel`, `courier_id`, `rider_id`, `sender_name`, `sender_phone`, `pickup_address`, `pickup_lat`, `pickup_lng`, `receiver_name`, `receiver_phone`, `drop_address`, `drop_lat`, `drop_lng`, `weight_kg`, `distance_km`, `fare`, `earnings`, `surge_bonus`, `status`, `pickup_otp_hash`, `delivery_otp_hash`, `fail_reason`, `fragile`, `notes`, `payment_method`, `picked_up_at`, `delivered_at`, `district_id`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'HG-LIIE3R7', 4, 'Box', 'standard', 'courier', 7, NULL, 'Demo Customer', '+8801710000001', 'Gulshan Circle 1', NULL, NULL, 'Receiver', '+8801710000099', 'Banani 11', NULL, NULL, 1.50, 4.00, 100.00, 110.00, 0.00, 'delivered', '$2y$12$JsWntc/jWMTHhZsSxrZEce.xDUd8cF.o8CcdoxuYj2W3fVBkOofMq', '$2y$12$eZGvrlONYkILH4fWO6.mZ.v73IVU/RluoKBVoeEYE3jXu9iw/.T4K', NULL, 0, NULL, 'cash', '2026-07-31 19:42:45', '2026-07-31 19:42:50', 'dhaka__dhaka', '2026-07-31 19:42:42', '2026-07-31 19:42:50', NULL),
(2, 'HG-LJSRKS8', 4, 'Box', 'standard', 'courier', 7, NULL, 'Demo Customer', '+8801710000001', 'Gulshan Circle 1', NULL, NULL, 'Receiver', '+8801710000099', 'Banani 11', NULL, NULL, 1.50, 4.00, 100.00, 110.00, 0.00, 'delivered', '$2y$12$GHT2zsCrAXSD.e368bvEP.zNf.LohFOrKIvoYp.4estFTkEL1vb7C', '$2y$12$6oYikJp2bpc/dAjfV2axpesb5.cGDX2lcqHfoeBIuHUUwcCkppsyu', NULL, 0, NULL, 'cash', '2026-07-31 19:46:21', '2026-07-31 19:46:25', 'dhaka__dhaka', '2026-07-31 19:46:18', '2026-07-31 19:46:25', NULL),
(3, 'HG-MDXLUW2', 4, 'Box', 'standard', 'courier', 7, NULL, 'Demo Customer', '+8801710000001', 'Gulshan Circle 1', NULL, NULL, 'Receiver', '+8801710000099', 'Banani 11', NULL, NULL, 1.50, 4.00, 100.00, 110.00, 0.00, 'delivered', '$2y$12$drUScAsvANBrb3SSWIKNrOmzqVc0eCaC6lViw1WSJKXvgPH4ijjoG', '$2y$12$LKzStVBFZBsTXhjHJqquOePBYMfyvcCT8wNiNlvlk.mR5xUu2bHDe', NULL, 0, NULL, 'cash', '2026-07-31 21:10:43', '2026-07-31 21:10:47', 'dhaka__dhaka', '2026-07-31 21:10:39', '2026-07-31 21:10:47', NULL);

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

--
-- Dumping data for table `parcel_otp_logs`
--

INSERT INTO `parcel_otp_logs` (`id`, `parcel_id`, `stage`, `success`, `by_user_id`, `created_at`, `updated_at`) VALUES
(1, 1, 'pickup', 1, 7, '2026-07-31 19:42:45', '2026-07-31 19:42:45'),
(2, 1, 'delivery', 1, 7, '2026-07-31 19:42:50', '2026-07-31 19:42:50'),
(3, 2, 'pickup', 1, 7, '2026-07-31 19:46:21', '2026-07-31 19:46:21'),
(4, 2, 'delivery', 1, 7, '2026-07-31 19:46:25', '2026-07-31 19:46:25'),
(5, 3, 'pickup', 1, 7, '2026-07-31 21:10:43', '2026-07-31 21:10:43'),
(6, 3, 'delivery', 1, 7, '2026-07-31 21:10:47', '2026-07-31 21:10:47');

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
(28, 'App\\Models\\User', 5, 'rider', '6a861309090aee2d0498059e87871e0ebfeeff0f33e1eb42b2a977c67e811cf7', '[\"*\"]', '2026-07-31 10:32:35', NULL, '2026-07-31 10:32:35', '2026-07-31 10:32:35'),
(29, 'App\\Models\\User', 1, 'admin', 'ad4345e031b679c3c1ae0d21d93db2fd2f8b84f95b1dad31fa2a2c9c94f37359', '[\"*\"]', '2026-07-31 19:42:38', NULL, '2026-07-31 19:41:09', '2026-07-31 19:42:38'),
(30, 'App\\Models\\User', 4, 'customer', '56dcdbebaf5ee66dabfc0b932456507b2da380d2c470e9b5bd77e92b6147d90e', '[\"*\"]', '2026-07-31 19:42:39', NULL, '2026-07-31 19:41:12', '2026-07-31 19:42:39'),
(31, 'App\\Models\\User', 5, 'rider', '4932637754a2cae864e286d5d4ae3ff267c1cc97f86e9275eaf5638e4acb4a44', '[\"*\"]', '2026-07-31 19:42:33', NULL, '2026-07-31 19:41:14', '2026-07-31 19:42:33'),
(32, 'App\\Models\\User', 6, 'merchant', '4c969e4a5714e76b0e90b9ea5ae0687c5d76246cd7dee1c0dbea150b147d1203', '[\"*\"]', '2026-07-31 19:42:35', NULL, '2026-07-31 19:41:16', '2026-07-31 19:42:35'),
(33, 'App\\Models\\User', 7, 'courier_agent', 'c3ecc78deedcb0cdd7ecac8335cf4ef6859ddbf0bc94b9e674a4c3e4a088094a', '[\"*\"]', '2026-07-31 19:42:51', NULL, '2026-07-31 19:41:18', '2026-07-31 19:42:51'),
(34, 'App\\Models\\User', 1, 'admin', '80d8aab94c481bc1c82e076c78719c15fa8105c339d7f3283488137e73203c90', '[\"*\"]', '2026-07-31 19:43:27', NULL, '2026-07-31 19:43:26', '2026-07-31 19:43:27'),
(35, 'App\\Models\\User', 1, 'admin', '9eb5c7509cffd959838139eedfac63262c77663fb1b8ae3801ad9459738b6fe7', '[\"*\"]', '2026-07-31 19:46:15', NULL, '2026-07-31 19:44:44', '2026-07-31 19:46:15'),
(36, 'App\\Models\\User', 4, 'customer', 'c9fb9da46f584bba788f7b58963e83a66c8eb772293c5b4255bd0bc0fc2827b7', '[\"*\"]', '2026-07-31 19:46:16', NULL, '2026-07-31 19:44:46', '2026-07-31 19:46:16'),
(37, 'App\\Models\\User', 5, 'rider', 'db145ad4792e3532cf5891f19dddd898ab26c1a51f9986b137f28727e373f8ad', '[\"*\"]', '2026-07-31 19:46:09', NULL, '2026-07-31 19:44:48', '2026-07-31 19:46:09'),
(38, 'App\\Models\\User', 6, 'merchant', 'e917d156747274ff707c0045b6599e1f5e794ee77fa3f2349c788331a8937337', '[\"*\"]', '2026-07-31 19:46:12', NULL, '2026-07-31 19:44:50', '2026-07-31 19:46:12'),
(39, 'App\\Models\\User', 7, 'courier_agent', '1672a293d194aa92f66ef00ffc070d9346be471ee9ca3e26f7f6f0584cee3eb8', '[\"*\"]', '2026-07-31 19:46:26', NULL, '2026-07-31 19:44:52', '2026-07-31 19:46:26'),
(40, 'App\\Models\\User', 1, 'admin', 'a1fc0ebc5b2b436a648a61f6d5188ef67ca50feb48e21993fe8b2f7124397ff2', '[\"*\"]', '2026-07-31 19:48:22', NULL, '2026-07-31 19:47:52', '2026-07-31 19:48:22'),
(41, 'App\\Models\\User', 6, 'merchant', 'b26ced5f41597204700de1c70ed78d58d86e6a64463f8699f9803beb240e894d', '[\"*\"]', '2026-07-31 19:48:19', NULL, '2026-07-31 19:47:54', '2026-07-31 19:48:19'),
(42, 'App\\Models\\User', 5, 'rider', '463a7ca376d5e471d4a93f1083ca307a729152b55f2dedbe461bc07170f1ff66', '[\"*\"]', '2026-07-31 19:48:08', NULL, '2026-07-31 19:47:57', '2026-07-31 19:48:08'),
(43, 'App\\Models\\User', 4, 'customer', '5eb103af0b77eceeded671fd67f617fdb3adb545400af4a49cb4fe5df4419de9', '[\"*\"]', '2026-07-31 19:48:20', NULL, '2026-07-31 19:47:59', '2026-07-31 19:48:20'),
(44, 'App\\Models\\User', 7, 'courier_agent', 'd8a9b907e9ee491797b68e48feddfc75264eeaa6e61591072d14d4125edd8eed', '[\"*\"]', '2026-07-31 19:48:20', NULL, '2026-07-31 19:48:01', '2026-07-31 19:48:20'),
(45, 'App\\Models\\User', 1, 'admin', '169ff048fc5607f1fcc5be361cf862648acec63b9ed86491a4a1ee71763164f4', '[\"*\"]', '2026-07-31 19:49:19', NULL, '2026-07-31 19:48:49', '2026-07-31 19:49:19'),
(46, 'App\\Models\\User', 6, 'merchant', '62419b1f7d97e6f40df867e99cbdf06b366ffd2b95cf1ed2ff98d376bc0dbec8', '[\"*\"]', '2026-07-31 19:49:16', NULL, '2026-07-31 19:48:51', '2026-07-31 19:49:16'),
(47, 'App\\Models\\User', 5, 'rider', 'd41ea01895fe45e236f6c8424d3b6ff90c1ab39594c178dc677654b3ec88f9e1', '[\"*\"]', '2026-07-31 19:49:05', NULL, '2026-07-31 19:48:52', '2026-07-31 19:49:05'),
(48, 'App\\Models\\User', 4, 'customer', '4e12a37e5fa866b40cd81a16e71ed5ebc5501e09194e756c7e0c70000fdd252b', '[\"*\"]', '2026-07-31 19:49:18', NULL, '2026-07-31 19:48:55', '2026-07-31 19:49:18'),
(49, 'App\\Models\\User', 7, 'courier_agent', '4a878b890e4539658d6080e0f82bed7e4f68e46e521d026f8062f66525895e16', '[\"*\"]', '2026-07-31 19:49:17', NULL, '2026-07-31 19:48:57', '2026-07-31 19:49:17'),
(50, 'App\\Models\\User', 1, 'admin', 'b36cd9a4bd8109bae53b80659c6a84256d059a1acb17adb9ac13ad77611a8c8f', '[\"*\"]', '2026-07-31 19:50:09', NULL, '2026-07-31 19:49:37', '2026-07-31 19:50:09'),
(51, 'App\\Models\\User', 6, 'merchant', '538b6d97202bcd4b06cd121d0a1229d5bb92331e2d5eb5ca4bcec425a3786a6e', '[\"*\"]', '2026-07-31 19:50:06', NULL, '2026-07-31 19:49:39', '2026-07-31 19:50:06'),
(52, 'App\\Models\\User', 5, 'rider', '29f07020f9136f8e32c0604cb323343ff539b31dde11dfd48c2ab6f44a5f4429', '[\"*\"]', '2026-07-31 19:49:55', NULL, '2026-07-31 19:49:41', '2026-07-31 19:49:55'),
(53, 'App\\Models\\User', 4, 'customer', '924cc2066fca315696b25b0c862f6dbf65c10ea9d39426d9a26af7ade2cfe2ce', '[\"*\"]', '2026-07-31 19:50:08', NULL, '2026-07-31 19:49:43', '2026-07-31 19:50:08'),
(54, 'App\\Models\\User', 7, 'courier_agent', 'a329744c5b7d9caa265bbadcbe7228bb0b7926c9739407891bcf49d9fae5117b', '[\"*\"]', '2026-07-31 19:50:07', NULL, '2026-07-31 19:49:45', '2026-07-31 19:50:07'),
(55, 'App\\Models\\User', 1, 'admin', 'd12495f7f3fbe121a0ccb8be743dd5f9bc7600b68c279999817bc83d235e5d99', '[\"*\"]', '2026-07-31 19:51:04', NULL, '2026-07-31 19:50:31', '2026-07-31 19:51:04'),
(56, 'App\\Models\\User', 6, 'merchant', 'e12784a2db20fe224196a78eb09085bc3a3ea815244d271d4d16bcb298524c55', '[\"*\"]', '2026-07-31 19:51:01', NULL, '2026-07-31 19:50:33', '2026-07-31 19:51:01'),
(57, 'App\\Models\\User', 5, 'rider', '6749ca7ad41c779d6de6098f84a4b62b08c9f565a9a06056a8992974898f34ec', '[\"*\"]', '2026-07-31 19:50:51', NULL, '2026-07-31 19:50:35', '2026-07-31 19:50:51'),
(58, 'App\\Models\\User', 4, 'customer', '81b7bc21ab1943f5f81ca4642b7db7f5e7197cea9475abf7fd0ddab3085412c1', '[\"*\"]', '2026-07-31 19:51:03', NULL, '2026-07-31 19:50:37', '2026-07-31 19:51:03'),
(59, 'App\\Models\\User', 7, 'courier_agent', '2abf5a57bd25289010550e64fe72d8f321d651e37b3be99951afd27f112b4ba0', '[\"*\"]', '2026-07-31 19:51:02', NULL, '2026-07-31 19:50:39', '2026-07-31 19:51:02'),
(60, 'App\\Models\\User', 1, 'admin', 'c1e2674e2cb4f03eac04ae469af72fa12c1bbaaef9d90b8e66d732f5ffcf2771', '[\"*\"]', '2026-07-31 21:10:36', NULL, '2026-07-31 21:08:56', '2026-07-31 21:10:36'),
(61, 'App\\Models\\User', 4, 'customer', '7280f25623ec2a894cdb941e00391306984851d24e709874eb042070f2defa01', '[\"*\"]', '2026-07-31 21:10:37', NULL, '2026-07-31 21:08:58', '2026-07-31 21:10:37'),
(62, 'App\\Models\\User', 5, 'rider', 'ca111e4e649eb2334310c7292f16c5a611f83a5ca332ca13034f6d87a3245925', '[\"*\"]', '2026-07-31 21:10:30', NULL, '2026-07-31 21:09:00', '2026-07-31 21:10:30'),
(63, 'App\\Models\\User', 6, 'merchant', 'a7667aa78fec9367cebd92859bc203548d539eb0ef75d1b443c4e0f3fc8991e1', '[\"*\"]', '2026-07-31 21:10:33', NULL, '2026-07-31 21:09:03', '2026-07-31 21:10:33'),
(64, 'App\\Models\\User', 7, 'courier_agent', '9d1296519314d3a6093c5471a7c9ca2185b3989e880c4cfc99181ddd69d142ae', '[\"*\"]', '2026-07-31 21:10:49', NULL, '2026-07-31 21:09:05', '2026-07-31 21:10:49'),
(65, 'App\\Models\\User', 1, 'admin', '8a5ed8c320600f9db4e4ad183916696543ee5773493ce99709a3abd2f4bf3344', '[\"*\"]', '2026-07-31 21:12:34', NULL, '2026-07-31 21:11:56', '2026-07-31 21:12:34'),
(66, 'App\\Models\\User', 6, 'merchant', '360a9b3e552a67e191d33ba6ff8b64b42169f597fea810e42656d1aec9fbc17d', '[\"*\"]', '2026-07-31 21:12:31', NULL, '2026-07-31 21:11:58', '2026-07-31 21:12:31'),
(67, 'App\\Models\\User', 5, 'rider', '9122ddf0023ccb2e366e56afc44feb6ecc16c80d6edacb0028da97accc5a5ae2', '[\"*\"]', '2026-07-31 21:12:19', NULL, '2026-07-31 21:12:00', '2026-07-31 21:12:19'),
(68, 'App\\Models\\User', 4, 'customer', '1e102f5dd79c2866804b0cfd2ecc0fbe079c5298bced90fa1eaf3c5c75091e65', '[\"*\"]', '2026-07-31 21:12:33', NULL, '2026-07-31 21:12:03', '2026-07-31 21:12:33'),
(69, 'App\\Models\\User', 7, 'courier_agent', '3782e3d057829b719699834e91cca6ccec2348e192cee3e9091eddd0894417d1', '[\"*\"]', '2026-07-31 21:12:32', NULL, '2026-07-31 21:12:05', '2026-07-31 21:12:32'),
(70, 'App\\Models\\User', 1, 'admin', 'f15e3afe0fc4a1fdb0d0dc4e8b1dc4962e5e961df99a029b289135b30d92af1d', '[\"*\"]', '2026-07-31 21:13:34', NULL, '2026-07-31 21:12:59', '2026-07-31 21:13:34'),
(71, 'App\\Models\\User', 4, 'customer', '624a5515428d7c4010c2c41e9cc34ac900135990b06dec9d114643fab96a215c', '[\"*\"]', '2026-07-31 21:13:42', NULL, '2026-07-31 21:13:02', '2026-07-31 21:13:42'),
(72, 'App\\Models\\User', 5, 'rider', 'c860590eafbde6c723da9287c98fa81f4925de336a7ab7f3e0b8e60d2c479239', '[\"*\"]', '2026-07-31 21:13:11', NULL, '2026-07-31 21:13:04', '2026-07-31 21:13:11'),
(73, 'App\\Models\\User', 6, 'merchant', 'd46aa32cc5bee0fb5e86fdc8addbc662f624799b0536fe868276017d4310462d', '[\"*\"]', '2026-07-31 21:13:41', NULL, '2026-07-31 21:13:06', '2026-07-31 21:13:41'),
(74, 'App\\Models\\User', 7, 'courier_agent', 'd81baa25feaf3715a69c1229e18a4be926e9f30a645caf8192d6eb30f74aa6c2', '[\"*\"]', NULL, NULL, '2026-07-31 21:13:09', '2026-07-31 21:13:09'),
(75, 'App\\Models\\User', 4, 'customer', '326f1fb3fe0e8016a6e56d938b4cb9cb08559af9a425b82baf1d65248a19eec2', '[\"*\"]', NULL, NULL, '2026-07-31 21:13:39', '2026-07-31 21:13:39'),
(76, 'App\\Models\\User', 1, 'admin', 'ccf92fb5b2d5f629a2ef1185107787b2ba8055e5e219e03c130bcd253b558d3a', '[\"*\"]', '2026-07-31 21:15:45', NULL, '2026-07-31 21:15:11', '2026-07-31 21:15:45'),
(77, 'App\\Models\\User', 4, 'customer', '51e486f1f5a9c53029878ce2e9a1d8b7c14177bb9c6c507d35644fd531449291', '[\"*\"]', '2026-07-31 21:15:53', NULL, '2026-07-31 21:15:13', '2026-07-31 21:15:53'),
(78, 'App\\Models\\User', 5, 'rider', '344a97f59aa5368a05f37da65a05ed86549fea7081ed8332c0a88ee2933d968a', '[\"*\"]', '2026-07-31 21:15:22', NULL, '2026-07-31 21:15:16', '2026-07-31 21:15:22'),
(79, 'App\\Models\\User', 6, 'merchant', '1511d0d42d14a64b508bf5f251c5ba1fb07757f9d9eaecec1dbbf591993f7e25', '[\"*\"]', '2026-07-31 21:15:52', NULL, '2026-07-31 21:15:18', '2026-07-31 21:15:52'),
(80, 'App\\Models\\User', 7, 'courier_agent', 'ffef343a76c894fd8b3a27c3015f49bca9884bad5960ff4189e699cd2b6d83b6', '[\"*\"]', NULL, NULL, '2026-07-31 21:15:20', '2026-07-31 21:15:20'),
(81, 'App\\Models\\User', 4, 'customer', '48340ad0f3ca04dcc24393fda066dd6524adeb87c64f653de573d83a23d0c78f', '[\"*\"]', NULL, NULL, '2026-07-31 21:15:49', '2026-07-31 21:15:49'),
(82, 'App\\Models\\User', 1, 'admin', '1cef9a88093bae5adce7f67d596e7c9ffed9cf04b649305bb9f863ab1962e591', '[\"*\"]', NULL, NULL, '2026-07-31 21:16:34', '2026-07-31 21:16:34'),
(83, 'App\\Models\\User', 1, 'admin', '19b44b43118a6592a97ae6d67dd5d498610ca59b363bb0c00b17c311dadf533a', '[\"*\"]', NULL, NULL, '2026-07-31 21:16:40', '2026-07-31 21:16:40'),
(84, 'App\\Models\\User', 4, 'customer', '126a7fe8ee2775ef67faa34b6e124aa7ba042e19c0e66dca6dd3031e6aee4d24', '[\"*\"]', NULL, NULL, '2026-07-31 21:16:43', '2026-07-31 21:16:43'),
(85, 'App\\Models\\User', 5, 'rider', 'fa9882aa10ee8fab72fb34fedb754502324690c419046a695bdf995a7cdf2785', '[\"*\"]', NULL, NULL, '2026-07-31 21:16:46', '2026-07-31 21:16:46'),
(86, 'App\\Models\\User', 6, 'merchant', 'b27ef9895edc444bfb520ec8371df52ff6da461e103bb23f70b7c63dd6ac8188', '[\"*\"]', NULL, NULL, '2026-07-31 21:16:49', '2026-07-31 21:16:49'),
(87, 'App\\Models\\User', 7, 'courier_agent', '58016afb1c7990ad5e076233f5accf0f8d07b79dcd346905addc39604a669e25', '[\"*\"]', NULL, NULL, '2026-07-31 21:16:52', '2026-07-31 21:16:52'),
(88, 'App\\Models\\User', 4, 'customer', '13bee1ac36497e0e227822888a1574970b8752d8e7cb7e1c2c0aeeb891403cb0', '[\"*\"]', NULL, NULL, '2026-07-31 21:16:56', '2026-07-31 21:16:56'),
(89, 'App\\Models\\User', 1, 'admin', 'efdeb637e37e66411eeedd75d1cb9eaa9921f8d6be277deeef1078cfe0cd92e1', '[\"*\"]', '2026-07-31 21:18:40', NULL, '2026-07-31 21:18:16', '2026-07-31 21:18:40'),
(90, 'App\\Models\\User', 4, 'customer', '635975d6c2b79a66c2422d17e482e814aefeebdc1612552c63a1d6e0c3e7b616', '[\"*\"]', '2026-07-31 21:18:48', NULL, '2026-07-31 21:18:21', '2026-07-31 21:18:48'),
(91, 'App\\Models\\User', 5, 'rider', '65750cd1fec96c146d3fc1b2714d612acda59bd9bcf1a1ef35a0ca251feb7d61', '[\"*\"]', '2026-07-31 21:18:49', NULL, '2026-07-31 21:18:23', '2026-07-31 21:18:49'),
(92, 'App\\Models\\User', 6, 'merchant', '933a0e4af116d099817ca3a038aa7bee158655b95ae2a90457839b4de874ceec', '[\"*\"]', '2026-07-31 21:18:50', NULL, '2026-07-31 21:18:26', '2026-07-31 21:18:50'),
(93, 'App\\Models\\User', 7, 'courier_agent', '02ae4d01d3b76ed2fe913434b278ca3cc1166e83fae31bdc747f97d23fc64108', '[\"*\"]', '2026-07-31 21:18:52', NULL, '2026-07-31 21:18:28', '2026-07-31 21:18:52'),
(94, 'App\\Models\\User', 1, 'admin', 'c0eafe30ba4dd9baf5e19186610cc3eb9ac06087876219033771fea8b56f7512', '[\"*\"]', '2026-07-31 21:19:42', NULL, '2026-07-31 21:19:25', '2026-07-31 21:19:42'),
(95, 'App\\Models\\User', 4, 'customer', '92d1b3f61876aab80528049a33a3abcd09d4b3deed91e8055640d3dcf37fe64e', '[\"*\"]', '2026-07-31 21:19:46', NULL, '2026-07-31 21:19:29', '2026-07-31 21:19:46'),
(96, 'App\\Models\\User', 5, 'rider', '72c238df7617966fa205537550293579b6283250b0e6b5259a70f04cfb01aef9', '[\"*\"]', '2026-07-31 21:19:46', NULL, '2026-07-31 21:19:31', '2026-07-31 21:19:46'),
(97, 'App\\Models\\User', 6, 'merchant', '6d068b517835ae595b4589124b07c1f16d69da2ecbdba0abf162ba0f5b47cd82', '[\"*\"]', '2026-07-31 21:19:47', NULL, '2026-07-31 21:19:32', '2026-07-31 21:19:47'),
(98, 'App\\Models\\User', 7, 'courier_agent', 'fcd71d266fddb82e5de10425b6cf2debb7bab5cfce253f8874423295a3242aad', '[\"*\"]', '2026-07-31 21:19:49', NULL, '2026-07-31 21:19:33', '2026-07-31 21:19:49'),
(99, 'App\\Models\\User', 1, 'admin', '57cb1bb18b81f08f5aa8545b4953ab33b7774a91d3531e31c86c2dbaa2908e9f', '[\"*\"]', '2026-07-31 21:20:23', NULL, '2026-07-31 21:19:50', '2026-07-31 21:20:23'),
(100, 'App\\Models\\User', 4, 'customer', '6b17b9ecc4929b54482677e6ee120f123c31189cf6690dcc2f693efd76c3629f', '[\"*\"]', '2026-07-31 21:20:31', NULL, '2026-07-31 21:19:51', '2026-07-31 21:20:31'),
(101, 'App\\Models\\User', 5, 'rider', '568863e09a87453422f35d0117772c60c39bcaec7743ac4e36897c78df8ce15e', '[\"*\"]', '2026-07-31 21:20:00', NULL, '2026-07-31 21:19:53', '2026-07-31 21:20:00'),
(102, 'App\\Models\\User', 6, 'merchant', '176fd90174e64a32c73376d9d75f3f824944d5a4c067782078835b00521837cb', '[\"*\"]', '2026-07-31 21:20:30', NULL, '2026-07-31 21:19:55', '2026-07-31 21:20:30'),
(103, 'App\\Models\\User', 7, 'courier_agent', '7e5b647971578b2d8a48461c1110b2981e449af27142e8ae699a93967cd1edf1', '[\"*\"]', NULL, NULL, '2026-07-31 21:19:58', '2026-07-31 21:19:58'),
(104, 'App\\Models\\User', 4, 'customer', '9c0621d15dafe376f920db9beaee8e00c6c5c6da36d7a1067e25a98ac2127638', '[\"*\"]', NULL, NULL, '2026-07-31 21:20:28', '2026-07-31 21:20:28');

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
  `by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pricing_audits`
--

INSERT INTO `pricing_audits` (`id`, `panel`, `field`, `old_value`, `new_value`, `by`, `by_user_id`, `created_at`, `updated_at`) VALUES
(1, 'customer', 'rideBase', '30', '30.01', 'HillGo Super Admin', 1, '2026-07-31 19:42:06', '2026-07-31 19:42:06'),
(2, 'customer', 'rideBase', '30.01', '30', 'HillGo Super Admin', 1, '2026-07-31 19:42:08', '2026-07-31 19:42:08'),
(3, 'customer', 'rideBase', '30', '30.01', 'HillGo Super Admin', 1, '2026-07-31 19:45:38', '2026-07-31 19:45:38'),
(4, 'customer', 'rideBase', '30.01', '30', 'HillGo Super Admin', 1, '2026-07-31 19:45:39', '2026-07-31 19:45:39'),
(5, 'customer', 'rideBase', '30', '30.01', 'HillGo Super Admin', 1, '2026-07-31 21:09:55', '2026-07-31 21:09:55'),
(6, 'customer', 'rideBase', '30.01', '30', 'HillGo Super Admin', 1, '2026-07-31 21:09:56', '2026-07-31 21:09:56');

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
(1, 'customer', '{\"rideBase\":30,\"ridePerKm\":15,\"ridePerMin\":1,\"rideMinimum\":50,\"foodDeliveryFee\":30,\"freeDeliveryThreshold\":300,\"parcelBase\":40,\"parcelPerKm\":12,\"parcelPerKg\":8,\"parcelMinimum\":50,\"marketplaceDelivery\":40,\"hotelServiceFeePct\":5,\"rentalDriverPerDay\":1500,\"rentalInsurancePerDay\":300}', '2026-07-31 01:56:43', '2026-07-31 21:09:56'),
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
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `store_id`, `category_id`, `name`, `description`, `price`, `sku`, `stock`, `low_stock_alert`, `track_stock`, `images`, `status`, `marketplace_category`, `rating`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 1, 'Demo Biryani', 'Signature demo dish for cross-app testing', 220.00, NULL, 100, 5, 0, '[\"https:\\/\\/images.unsplash.com\\/photo-1563379091339-03b21ab4a4f8?w=600&h=400&fit=crop\"]', 'active', NULL, 0.00, '2026-07-31 18:47:53', '2026-07-31 18:47:53', NULL),
(2, 1, 1, 'Demo Soft Drink', 'Cold drink add-on', 40.00, NULL, 200, 5, 0, '[\"https:\\/\\/images.unsplash.com\\/photo-1622483767028-3f66f32aef97?w=600&h=400&fit=crop\"]', 'active', NULL, 0.00, '2026-07-31 18:47:53', '2026-07-31 18:47:53', NULL);

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

--
-- Dumping data for table `product_categories`
--

INSERT INTO `product_categories` (`id`, `store_id`, `name`, `icon`, `color`, `is_visible`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 1, 'Mains', NULL, NULL, 1, 0, '2026-07-31 18:47:53', '2026-07-31 18:47:53');

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
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
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

--
-- Dumping data for table `rider_payouts`
--

INSERT INTO `rider_payouts` (`id`, `code`, `rider_id`, `amount`, `method`, `period_from`, `period_to`, `ref`, `tips`, `surge`, `deductions`, `note`, `status`, `source`, `paid_at`, `created_at`, `updated_at`) VALUES
(1, 'HG-PY-LKSLG18', 5, 100.00, 'bKash', NULL, NULL, '', 0.00, 0.00, 0.00, '', 'paid', 'cash_out', '2026-07-31 19:49:04', '2026-07-31 19:49:03', '2026-07-31 19:49:04'),
(2, 'HG-PY-LLF8CS9', 5, 100.00, 'bKash', NULL, NULL, '', 0.00, 0.00, 0.00, '', 'paid', 'cash_out', '2026-07-31 19:50:50', '2026-07-31 19:50:49', '2026-07-31 19:50:50'),
(3, 'HG-PY-MEISJO3', 5, 100.00, 'bKash', NULL, NULL, '', 0.00, 0.00, 0.00, '', 'paid', 'cash_out', '2026-07-31 21:12:18', '2026-07-31 21:12:16', '2026-07-31 21:12:18');

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
  `nid` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rider_profiles`
--

INSERT INTO `rider_profiles` (`id`, `user_id`, `code`, `vehicle_type`, `vehicle_make`, `vehicle_model`, `vehicle_year`, `plate`, `vehicle_photo`, `rating`, `rating_count`, `online`, `lat`, `lng`, `last_location_at`, `online_since`, `online_seconds_today`, `balance`, `payout_method`, `kyc_status`, `kyc_priority`, `kyc_flagged`, `kyc_submitted_at`, `legal_name`, `home_address`, `dob`, `nid`, `created_at`, `updated_at`) VALUES
(1, 2, 'HG-RD-EZ5QLM1', 'car', 'Toyota', 'Axio', '2020', 'DHK-1234', NULL, 0.00, 0, 0, NULL, NULL, NULL, NULL, 0, 0.00, 'bKash', 'pending', 0, 0, NULL, 'Smoke Test Rider', 'House 1, Road 2, Gulshan', '1995-05-10', 'eyJpdiI6IkNqNHZPZmZwK2NqblB2dm5kTFJmZVE9PSIsInZhbHVlIjoiaVFoYkFTVE1OUTRkM0JXRzhBK2Zmdz09IiwibWFjIjoiN2Y5OGViZDE2OGNmZThkNmZkZDgyYjY0NGQwZDhhMjhhNzU2NzdhNTQ4OTQ1ZDY0ZmMzYTlmYTY3ZWE0ZjRlYyIsInRhZyI6IiJ9', '2026-07-31 02:43:50', '2026-07-31 19:42:52'),
(2, 3, 'HG-RD-EZ9M149', NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0, 0, NULL, NULL, NULL, NULL, 0, 0.00, 'bKash', 'pending', 0, 0, NULL, NULL, NULL, NULL, NULL, '2026-07-31 02:44:08', '2026-07-31 02:44:08'),
(3, 5, 'HG-RD-FJYXT84', 'bike', 'Honda', 'CB', NULL, 'DHAKA-DEMO-02', NULL, 0.00, 0, 1, NULL, NULL, NULL, '2026-07-31 21:09:11', 179, 0.00, 'bKash', 'verified', 0, 0, NULL, 'Demo Rider', NULL, NULL, NULL, '2026-07-31 03:42:05', '2026-07-31 21:12:17');

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
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rides`
--

INSERT INTO `rides` (`id`, `code`, `customer_id`, `rider_id`, `vehicle_type`, `pickup`, `drop`, `pickup_lat`, `pickup_lng`, `drop_lat`, `drop_lng`, `distance_km`, `duration_min`, `fare`, `surge`, `status`, `payment_method`, `rating`, `rating_comment`, `cancel_reason`, `completed_at`, `district_id`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'RID-FKWJSD4', 4, NULL, 'bike', 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 'Mymensingh, Mymensingh Sadar Upazila, Mymensingh District, Mymensingh Division, 2200, Bangladesh', 24.9454341, 90.6011677, 24.7482129, 90.4099158, 35.07, 41, 418.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled while searching', NULL, 'dhaka__dhaka', '2026-07-31 03:44:42', '2026-07-31 03:45:47', NULL),
(2, 'RID-FLLHWC7', 4, NULL, 'bike', 'Hazrat Shahjalal International Airport, Airport Road, MODC Mess Road, Barontek, Manikdi, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Uttara, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1231, Bangladesh', 23.8431441, 90.4053032, 23.8693275, 90.3926893, 3.84, 5, 65.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled while searching', NULL, 'dhaka__dhaka', '2026-07-31 03:46:38', '2026-07-31 03:54:44', NULL),
(3, 'RID-FOICS20', 4, 5, 'bike', 'Hazrat Shahjalal International Airport, Airport Road, MODC Mess Road, Barontek, Manikdi, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Uttara, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1231, Bangladesh', 23.8431441, 90.4053032, 23.8693275, 90.3926893, 3.84, 5, 65.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'pre-bot cleanup', NULL, 'dhaka__dhaka', '2026-07-31 03:54:47', '2026-07-31 10:26:16', NULL),
(4, 'RID-FOTMK62', 4, NULL, 'bike', 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 'Dhaka District, Dhaka Division, Bangladesh', 24.9447390, 90.6015203, 23.7804927, 90.3582974, 155.05, 130, 1740.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled while searching', NULL, 'dhaka__dhaka', '2026-07-31 03:55:40', '2026-07-31 03:59:05', NULL),
(5, 'RID-FPF0ID0', 4, NULL, 'bike', 'Gulshan 1, Dhaka', 'Banani, Dhaka', 23.7808000, 90.4142000, 23.7936000, 90.4066000, 3.20, 12, 63.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'pre-bot cleanup', NULL, 'dhaka__dhaka', '2026-07-31 03:57:20', '2026-07-31 10:19:12', NULL),
(6, 'RID-FQ1XIG2', 4, NULL, 'bike', 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 'Dhaka District, Dhaka Division, Bangladesh', 24.9447390, 90.6015203, 23.7804927, 90.3582974, 155.05, 130, 1740.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled while searching', NULL, 'dhaka__dhaka', '2026-07-31 03:59:07', '2026-07-31 03:59:35', NULL),
(7, 'RID-FVA3OI9', 4, NULL, 'bike', 'Dhaka, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8103000, 90.4125000, 23.8316678, 90.4248321, 4.13, 8, 70.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled while searching', NULL, 'dhaka__dhaka', '2026-07-31 04:13:45', '2026-07-31 10:23:54', NULL),
(8, 'RID-FYXH5R4', 4, NULL, 'bike', 'Dhaka, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8103000, 90.4125000, 23.8316678, 90.4248321, 4.13, 8, 70.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'pre-bot cleanup', NULL, 'dhaka__dhaka', '2026-07-31 10:23:58', '2026-07-31 10:23:58', NULL),
(9, 'RID-FZR54D0', 4, NULL, 'bike', 'Gulshan 1, Dhaka', 'Banani 11, Dhaka', 23.7808875, 90.4169271, 23.7937000, 90.4066000, 4.20, 12, 74.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'pre-bot cleanup', NULL, 'dhaka__dhaka', '2026-07-31 10:26:16', '2026-07-31 10:26:16', NULL),
(10, 'RID-G0EJB50', 4, 5, 'bike', 'BOT-PICKUP-493685 Gulshan 1, Dhaka', 'Banani 11, Dhaka', 23.7808875, 90.4169271, 23.7937000, 90.4066000, 4.20, 12, 74.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'E2E cleanup', NULL, 'dhaka__dhaka', '2026-07-31 10:28:05', '2026-07-31 10:28:05', NULL),
(11, 'RID-G13CEV3', 4, 5, 'bike', 'Gulshan, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.7921765, 90.4155528, 23.8316678, 90.4248321, 7.40, 9, 105.00, 1.00, 'completed', 'cash', NULL, NULL, NULL, '2026-07-31 19:42:19', 'dhaka__dhaka', '2026-07-31 10:30:01', '2026-07-31 19:42:19', NULL),
(12, 'RID-G2B0D72', 4, NULL, 'bike', 'Gulshan, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.7921765, 90.4155528, 23.8316678, 90.4248321, 7.40, 9, 105.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled while searching', NULL, 'dhaka__dhaka', '2026-07-31 10:33:25', '2026-07-31 10:33:40', NULL),
(13, 'RID-G2SUMX7', 4, 5, 'bike', 'Dhaka-Mymensingh Highway, Purbo Arichpur, Cherag Ali, Tongi, Gazipur Sadar Upazila, Gazipur District, Dhaka Division, 1712, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8999712, 90.3990639, 23.8316678, 90.4248321, 9.25, 8, 124.00, 1.00, 'completed', 'cash', NULL, NULL, NULL, '2026-07-31 10:39:01', 'dhaka__dhaka', '2026-07-31 10:34:48', '2026-07-31 10:39:01', NULL),
(14, 'RID-G4NX2Z8', 4, 5, 'bike', 'Dhaka, Bangladesh', 'Cox\'s Bazar District, Chattogram Division, Bangladesh', 23.8103000, 90.4125000, 21.4420039, 91.9812464, 392.71, 294, 4351.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'Cancelled by customer', NULL, 'dhaka__dhaka', '2026-07-31 10:40:01', '2026-07-31 10:40:19', NULL),
(15, 'RID-LJLT9S6', 4, 5, 'bike', 'Gulshan 1', 'Banani', 23.7808000, 90.4142000, 23.7936000, 90.4066000, 3.20, 12, 63.00, 1.00, 'completed', 'cash', 5, 'E2E', NULL, '2026-07-31 19:45:52', 'dhaka__dhaka', '2026-07-31 19:45:43', '2026-07-31 19:45:54', NULL),
(16, 'RID-LJOGXV1', 4, NULL, 'bike', 'Uttara', 'Airport', NULL, NULL, NULL, NULL, 4.00, 15, 74.00, 1.00, 'cancelled', 'wallet', NULL, NULL, 'E2E cancel', NULL, 'dhaka__dhaka', '2026-07-31 19:45:56', '2026-07-31 19:45:58', NULL),
(17, 'RID-MDPOWI9', 4, 5, 'bike', 'Gulshan 1', 'Banani', 23.7808000, 90.4142000, 23.7936000, 90.4066000, 3.20, 12, 63.00, 1.00, 'completed', 'cash', 5, 'E2E', NULL, '2026-07-31 21:10:09', 'dhaka__dhaka', '2026-07-31 21:10:00', '2026-07-31 21:10:12', NULL),
(18, 'RID-MDSMB84', 4, NULL, 'bike', 'Uttara', 'Airport', NULL, NULL, NULL, NULL, 4.00, 15, 74.00, 1.00, 'cancelled', 'wallet', NULL, NULL, 'E2E cancel', NULL, 'dhaka__dhaka', '2026-07-31 21:10:14', '2026-07-31 21:10:17', NULL),
(19, 'RID-MFODB63', 4, NULL, 'bike', 'Gulshan 1', 'Banani', 23.7808000, 90.4142000, 23.7936000, 90.4066000, 2.19, 12, 52.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'catalog e2e', NULL, 'dhaka__dhaka', '2026-07-31 21:15:30', '2026-07-31 21:15:31', NULL),
(20, 'RID-MHBXM18', 4, NULL, 'bike', 'Gulshan 1', 'Banani', 23.7808000, 90.4142000, 23.7936000, 90.4066000, 2.19, 12, 52.00, 1.00, 'cancelled', 'cash', NULL, NULL, 'catalog e2e', NULL, 'dhaka__dhaka', '2026-07-31 21:20:08', '2026-07-31 21:20:09', NULL);

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
('iPUu7QwksmAeDE3ULftBq08yKgr8ILNqGuBEOeQ3', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Cursor/3.2.16 Chrome/142.0.7444.265 Electron/39.8.1 Safari/537.36', 'eyJfdG9rZW4iOiJOQVlYNTVXaWMyYk9xTk5DcE1aa01rZnEzOHFVd21CbHZhMDZPQ2VUIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1785523833),
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
  `resolved_by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sos_alerts`
--

INSERT INTO `sos_alerts` (`id`, `user_id`, `type`, `location_label`, `lat`, `lng`, `status`, `resolved_at`, `resolved_by`, `resolved_by_user_id`, `created_at`, `updated_at`) VALUES
(1, 4, 'sos', 'E2E Banani', NULL, NULL, 'resolved', '2026-07-31 19:48:22', 'HillGo Super Admin', 1, '2026-07-31 19:48:21', '2026-07-31 19:48:22'),
(2, 4, 'sos', 'E2E Banani', NULL, NULL, 'resolved', '2026-07-31 19:49:19', 'HillGo Super Admin', 1, '2026-07-31 19:49:18', '2026-07-31 19:49:19'),
(3, 4, 'sos', 'E2E Banani', NULL, NULL, 'resolved', '2026-07-31 19:50:09', 'HillGo Super Admin', 1, '2026-07-31 19:50:08', '2026-07-31 19:50:09'),
(4, 4, 'sos', 'E2E Banani', NULL, NULL, 'resolved', '2026-07-31 19:51:04', 'HillGo Super Admin', 1, '2026-07-31 19:51:04', '2026-07-31 19:51:04'),
(5, 4, 'sos', 'E2E Banani', NULL, NULL, 'resolved', '2026-07-31 21:12:34', 'HillGo Super Admin', 1, '2026-07-31 21:12:33', '2026-07-31 21:12:34');

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
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `stores`
--

INSERT INTO `stores` (`id`, `code`, `user_id`, `name`, `owner_name`, `category`, `subcategories`, `description`, `specialties`, `bio`, `address`, `city`, `district_id`, `zip`, `lat`, `lng`, `is_open`, `accepting_orders`, `status`, `rating`, `rating_count`, `hours`, `banner`, `logo`, `profile_strength`, `balance`, `free_delivery`, `eta_label`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'HG-MRT-FJYZRX7', 6, 'Demo Kitchen', 'Demo Merchant', 'Restaurant & Cafe', NULL, 'HillGo demo merchant store', NULL, NULL, 'Gulshan 1, Dhaka', 'Dhaka', 'dhaka__dhaka', NULL, NULL, NULL, 1, 1, 'active', 0.00, 0, NULL, 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&h=400&fit=crop', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=200&h=200&fit=crop', 80, 0.00, 0, '25-35 min', '2026-07-31 03:42:05', '2026-07-31 21:12:11', NULL);

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
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `trips`
--

INSERT INTO `trips` (`id`, `code`, `type`, `rider_id`, `customer_id`, `ref_type`, `ref_id`, `pickup_name`, `pickup_address`, `pickup_lat`, `pickup_lng`, `drop_name`, `drop_address`, `drop_lat`, `drop_lng`, `distance_km`, `duration_min`, `earning`, `tip`, `payment_method`, `cod_amount`, `surge`, `vehicle_required`, `weight_kg`, `package_label`, `status`, `offered_at`, `offer_expires_at`, `declined_rider_ids`, `accepted_at`, `completed_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'HG-6A6C6E8A5E136', 'ride', NULL, 4, 'rides', 1, 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 24.9454341, 90.6011677, 'Mymensingh, Mymensingh Sadar Upazila, Mymensingh District, Mymensingh Division, 2200, Bangladesh', 'Mymensingh, Mymensingh Sadar Upazila, Mymensingh District, Mymensingh Division, 2200, Bangladesh', 24.7482129, 90.4099158, 35.07, 41, 418.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', NULL, NULL, '[5]', NULL, NULL, '2026-07-31 03:44:42', '2026-07-31 03:45:47', NULL),
(2, 'HG-6A6C6EFEBA868', 'ride', 5, 4, 'rides', 2, 'Hazrat Shahjalal International Airport, Airport Road, MODC Mess Road, Barontek, Manikdi, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Hazrat Shahjalal International Airport, Airport Road, MODC Mess Road, Barontek, Manikdi, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8431441, 90.4053032, 'Uttara, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1231, Bangladesh', 'Uttara, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1231, Bangladesh', 23.8693275, 90.3926893, 3.84, 5, 65.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 03:54:32', '2026-07-31 03:55:02', '[]', NULL, NULL, '2026-07-31 03:46:38', '2026-07-31 03:54:44', NULL),
(3, 'HG-6A6C70E80910F', 'ride', 5, 4, 'rides', 3, 'Hazrat Shahjalal International Airport, Airport Road, MODC Mess Road, Barontek, Manikdi, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Hazrat Shahjalal International Airport, Airport Road, MODC Mess Road, Barontek, Manikdi, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8431441, 90.4053032, 'Uttara, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1231, Bangladesh', 'Uttara, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1231, Bangladesh', 23.8693275, 90.3926893, 3.84, 5, 65.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 10:26:16', '2026-07-31 10:27:16', '[]', '2026-07-31 10:26:16', NULL, '2026-07-31 03:54:48', '2026-07-31 10:26:16', NULL),
(4, 'HG-6A6C711CA1302', 'ride', 5, 4, 'rides', 4, 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 24.9447390, 90.6015203, 'Dhaka District, Dhaka Division, Bangladesh', 'Dhaka District, Dhaka Division, Bangladesh', 23.7804927, 90.3582974, 155.05, 130, 1740.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 03:59:00', '2026-07-31 03:59:30', '[]', NULL, NULL, '2026-07-31 03:55:40', '2026-07-31 03:59:05', NULL),
(5, 'HG-6A6C71805DB44', 'ride', 5, 4, 'rides', 5, 'Gulshan 1, Dhaka', 'Gulshan 1, Dhaka', 23.7808000, 90.4142000, 'Banani, Dhaka', 'Banani, Dhaka', 23.7936000, 90.4066000, 3.20, 12, 63.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 19:42:13', '2026-07-31 19:43:13', '[]', NULL, NULL, '2026-07-31 03:57:20', '2026-07-31 19:42:13', NULL),
(6, 'HG-6A6C71EB46453', 'ride', 5, 4, 'rides', 6, 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 'Purbadhala, Netrokona District, Mymensingh Division, Bangladesh', 24.9447390, 90.6015203, 'Dhaka District, Dhaka Division, Bangladesh', 'Dhaka District, Dhaka Division, Bangladesh', 23.7804927, 90.3582974, 155.05, 130, 1740.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 03:59:07', '2026-07-31 03:59:37', '[]', NULL, NULL, '2026-07-31 03:59:07', '2026-07-31 03:59:35', NULL),
(7, 'HG-6A6C7559359D2', 'ride', 5, 4, 'rides', 7, 'Dhaka, Bangladesh', 'Dhaka, Bangladesh', 23.8103000, 90.4125000, 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8316678, 90.4248321, 4.13, 8, 70.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 10:22:54', '2026-07-31 10:23:54', '[]', NULL, NULL, '2026-07-31 04:13:45', '2026-07-31 10:23:54', NULL),
(8, 'HG-6A6C77BE273BD', 'ride', 5, 4, 'rides', 8, 'Dhaka, Bangladesh', 'Dhaka, Bangladesh', 23.8103000, 90.4125000, 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8316678, 90.4248321, 4.13, 8, 70.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 19:42:13', '2026-07-31 19:43:13', '[]', NULL, NULL, '2026-07-31 10:23:58', '2026-07-31 19:42:13', NULL),
(9, 'HG-6A6C7848885B5', 'ride', 5, 4, 'rides', 9, 'Gulshan 1, Dhaka', 'Gulshan 1, Dhaka', 23.7808875, 90.4169271, 'Banani 11, Dhaka', 'Banani 11, Dhaka', 23.7937000, 90.4066000, 4.20, 12, 74.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 19:42:13', '2026-07-31 19:43:13', '[]', NULL, NULL, '2026-07-31 10:26:16', '2026-07-31 19:42:13', NULL),
(10, 'HG-6A6C78B5AB5E4', 'ride', 5, 4, 'rides', 10, 'BOT-PICKUP-493685 Gulshan 1, Dhaka', 'BOT-PICKUP-493685 Gulshan 1, Dhaka', 23.7808875, 90.4169271, 'Banani 11, Dhaka', 'Banani 11, Dhaka', 23.7937000, 90.4066000, 4.20, 12, 74.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 10:28:05', '2026-07-31 10:29:05', '[]', '2026-07-31 10:28:05', NULL, '2026-07-31 10:28:05', '2026-07-31 10:32:03', NULL),
(11, 'HG-6A6C79296FCF4', 'ride', 5, 4, 'rides', 11, 'Gulshan, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, Bangladesh', 'Gulshan, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, Bangladesh', 23.7921765, 90.4155528, 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8316678, 90.4248321, 7.40, 9, 105.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'completed', '2026-07-31 19:42:14', '2026-07-31 19:43:14', '[]', '2026-07-31 19:42:15', '2026-07-31 19:42:19', '2026-07-31 10:30:01', '2026-07-31 19:42:19', NULL),
(12, 'HG-6A6C79F53845C', 'ride', 5, 4, 'rides', 12, 'Gulshan, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, Bangladesh', 'Gulshan, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, Bangladesh', 23.7921765, 90.4155528, 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8316678, 90.4248321, 7.40, 9, 105.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 10:33:25', '2026-07-31 10:34:25', '[]', NULL, NULL, '2026-07-31 10:33:25', '2026-07-31 10:33:40', NULL),
(13, 'HG-6A6C7A4864E6F', 'ride', 5, 4, 'rides', 13, 'Dhaka-Mymensingh Highway, Purbo Arichpur, Cherag Ali, Tongi, Gazipur Sadar Upazila, Gazipur District, Dhaka Division, 1712, Bangladesh', 'Dhaka-Mymensingh Highway, Purbo Arichpur, Cherag Ali, Tongi, Gazipur Sadar Upazila, Gazipur District, Dhaka Division, 1712, Bangladesh', 23.8999712, 90.3990639, 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 'Khilkhet, Dhaka, Dhaka Metropolitan, Dhaka District, Dhaka Division, 1229, Bangladesh', 23.8316678, 90.4248321, 9.25, 8, 124.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'completed', '2026-07-31 10:34:48', '2026-07-31 10:35:48', '[]', '2026-07-31 10:34:56', '2026-07-31 10:39:01', '2026-07-31 10:34:48', '2026-07-31 10:39:01', NULL),
(14, 'HG-6A6C7B8151925', 'ride', 5, 4, 'rides', 14, 'Dhaka, Bangladesh', 'Dhaka, Bangladesh', 23.8103000, 90.4125000, 'Cox\'s Bazar District, Chattogram Division, Bangladesh', 'Cox\'s Bazar District, Chattogram Division, Bangladesh', 21.4420039, 91.9812464, 392.71, 294, 4351.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 10:40:01', '2026-07-31 10:41:01', '[]', '2026-07-31 10:40:11', NULL, '2026-07-31 10:40:01', '2026-07-31 10:40:19', NULL),
(15, 'HG-6A6CFAA4A40B3', 'food', 5, 4, 'orders', 1, 'Demo Kitchen', 'Gulshan 1, Dhaka', NULL, NULL, 'Customer', 'E2E Test Address, Gulshan', NULL, NULL, 0.00, 0, 30.00, 0.00, 'cash', 250.00, 1.00, NULL, NULL, NULL, 'completed', '2026-07-31 19:42:28', '2026-07-31 19:43:28', '[]', '2026-07-31 19:42:30', '2026-07-31 19:42:33', '2026-07-31 19:42:28', '2026-07-31 19:42:33', NULL),
(16, 'HG-6A6CFB6811A6E', 'ride', 5, 4, 'rides', 15, 'Gulshan 1', 'Gulshan 1', 23.7808000, 90.4142000, 'Banani', 'Banani', 23.7936000, 90.4066000, 3.20, 12, 63.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'completed', '2026-07-31 19:45:44', '2026-07-31 19:46:44', '[]', '2026-07-31 19:45:48', '2026-07-31 19:45:52', '2026-07-31 19:45:44', '2026-07-31 19:45:52', NULL),
(17, 'HG-6A6CFB7476A3F', 'ride', 5, 4, 'rides', 16, 'Uttara', 'Uttara', NULL, NULL, 'Airport', 'Airport', NULL, NULL, 4.00, 15, 74.00, 0.00, 'digital', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 19:45:56', '2026-07-31 19:46:56', '[]', NULL, NULL, '2026-07-31 19:45:56', '2026-07-31 19:45:58', NULL),
(18, 'HG-6A6CFB7C85C62', 'food', 5, 4, 'orders', 2, 'Demo Kitchen', 'Gulshan 1, Dhaka', NULL, NULL, 'Customer', 'E2E Test Address, Gulshan', NULL, NULL, 0.00, 0, 30.00, 0.00, 'cash', 250.00, 1.00, NULL, NULL, NULL, 'completed', '2026-07-31 19:46:04', '2026-07-31 19:47:04', '[]', '2026-07-31 19:46:06', '2026-07-31 19:46:09', '2026-07-31 19:46:04', '2026-07-31 19:46:09', NULL),
(19, 'HG-6A6D0F2909947', 'ride', 5, 4, 'rides', 17, 'Gulshan 1', 'Gulshan 1', 23.7808000, 90.4142000, 'Banani', 'Banani', 23.7936000, 90.4066000, 3.20, 12, 63.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'completed', '2026-07-31 21:10:01', '2026-07-31 21:11:01', '[]', '2026-07-31 21:10:05', '2026-07-31 21:10:09', '2026-07-31 21:10:01', '2026-07-31 21:10:09', NULL),
(20, 'HG-6A6D0F36BBA8C', 'ride', 5, 4, 'rides', 18, 'Uttara', 'Uttara', NULL, NULL, 'Airport', 'Airport', NULL, NULL, 4.00, 15, 74.00, 0.00, 'digital', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 21:10:14', '2026-07-31 21:11:14', '[]', NULL, NULL, '2026-07-31 21:10:14', '2026-07-31 21:10:17', NULL),
(21, 'HG-6A6D0F405773A', 'food', 5, 4, 'orders', 3, 'Demo Kitchen', 'Gulshan 1, Dhaka', NULL, NULL, 'Customer', 'E2E Test Address, Gulshan', NULL, NULL, 0.00, 0, 30.00, 0.00, 'cash', 250.00, 1.00, NULL, NULL, NULL, 'completed', '2026-07-31 21:10:24', '2026-07-31 21:11:24', '[]', '2026-07-31 21:10:26', '2026-07-31 21:10:30', '2026-07-31 21:10:24', '2026-07-31 21:10:30', NULL),
(22, 'HG-6A6D1072BBB45', 'ride', 5, 4, 'rides', 19, 'Gulshan 1', 'Gulshan 1', 23.7808000, 90.4142000, 'Banani', 'Banani', 23.7936000, 90.4066000, 2.19, 12, 53.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 21:15:30', '2026-07-31 21:16:30', '[]', NULL, NULL, '2026-07-31 21:15:30', '2026-07-31 21:15:31', NULL),
(23, 'HG-6A6D1188A31EB', 'ride', 5, 4, 'rides', 20, 'Gulshan 1', 'Gulshan 1', 23.7808000, 90.4142000, 'Banani', 'Banani', 23.7936000, 90.4066000, 2.19, 12, 53.00, 0.00, 'cash', 0.00, 1.00, 'bike', NULL, NULL, 'cancelled', '2026-07-31 21:20:08', '2026-07-31 21:21:08', '[]', NULL, NULL, '2026-07-31 21:20:08', '2026-07-31 21:20:09', NULL);

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
  `prefs` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`prefs`)),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `role`, `name`, `email`, `phone`, `email_verified_at`, `password`, `status`, `district_id`, `remember_token`, `created_at`, `updated_at`, `avatar`, `language`, `prefs`, `deleted_at`) VALUES
(1, 'super_admin', 'HillGo Super Admin', 'admin@hillgo.app', NULL, NULL, '$2y$12$alfVmPcJ64YT7n.MK7zhlulsS0Ba8l68EF3n8mMGHhBJ3UQwVwaRS', 'active', NULL, NULL, '2026-07-31 01:56:44', '2026-07-31 18:47:50', NULL, 'en', NULL, NULL),
(2, 'rider', 'Smoke Test Rider', NULL, '+8801116439445', NULL, '$2y$12$nGIS/9CJ1FKA5HSmwCqNSe88rygufusMF0e9rWujGzsTA/AwBByW.', 'onboarding', 'khulna__bagerhat', NULL, '2026-07-31 02:43:50', '2026-07-31 02:43:50', NULL, 'en', NULL, NULL),
(3, 'rider', 'Presence Test', NULL, '+8801721109255', NULL, '$2y$12$epQSZ6EB2TElw4KZyPYx5.EGcSOdl3B3Vi9c3VOzNIf5GQeSjplRu', 'onboarding', NULL, NULL, '2026-07-31 02:44:08', '2026-07-31 02:44:08', NULL, 'en', NULL, NULL),
(4, 'customer', 'Demo Customer', 'customer@demo.hillgo.app', '+8801710000001', NULL, '$2y$12$/e91Oda0ZPXCppxOGDAzyOo6skZIwxn3t2AQy.xB3GsGi4sCWOvnq', 'active', 'dhaka__dhaka', NULL, '2026-07-31 03:42:05', '2026-07-31 21:10:50', NULL, 'en', NULL, NULL),
(5, 'rider', 'Demo Rider', 'rider@demo.hillgo.app', '+8801710000002', NULL, '$2y$12$8kR48czBR25/cFmTsClTJ.ZJxzNMjvCcvBmzsbC4Ph/hz6r4lE8Tu', 'active', 'dhaka__dhaka', NULL, '2026-07-31 03:42:05', '2026-07-31 18:47:52', NULL, 'en', NULL, NULL),
(6, 'merchant', 'Demo Merchant', 'merchant@demo.hillgo.app', '+8801710000003', NULL, '$2y$12$Lf7THYcr4.FHJRmJyHl2z.rRhTS1JDbsf6.WK9mQF74q.6XW3hwLe', 'active', 'dhaka__dhaka', NULL, '2026-07-31 03:42:05', '2026-07-31 18:47:53', NULL, 'en', NULL, NULL),
(7, 'courier_agent', 'Demo Courier', 'courier@demo.hillgo.app', '+8801710000004', NULL, '$2y$12$1Yb/IAP8MQ6UajeW26qcXeX.MpqNFIjC/MZV3w99fDKbNInW0jscO', 'active', 'dhaka__dhaka', NULL, '2026-07-31 03:42:06', '2026-07-31 18:47:55', NULL, 'en', NULL, NULL);

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
-- Dumping data for table `wallet_transactions`
--

INSERT INTO `wallet_transactions` (`id`, `user_id`, `title`, `amount`, `direction`, `ref_type`, `ref_id`, `note`, `balance_after`, `created_at`, `updated_at`) VALUES
(1, 4, 'Admin wallet credit', 10.00, 'credit', 'admin_adjust', NULL, 'E2E credit', 510.00, '2026-07-31 19:42:09', '2026-07-31 19:42:09'),
(2, 5, 'Trip HG-6A6C79296FCF4 earnings', 89.25, 'credit', 'trip', 11, 'Net of 15% commission', 89.25, '2026-07-31 19:42:19', '2026-07-31 19:42:19'),
(3, 6, 'Order ORD-LIFHMF9 settled', 187.00, 'credit', 'order', 1, 'Net of ৳33 commission', 187.00, '2026-07-31 19:42:33', '2026-07-31 19:42:33'),
(4, 5, 'Trip HG-6A6CFAA4A40B3 earnings', 25.50, 'credit', 'trip', 15, 'Net of 15% commission', 25.50, '2026-07-31 19:42:33', '2026-07-31 19:42:33'),
(5, 7, 'Parcel HG-LIIE3R7 earnings', 96.80, 'credit', 'parcel', 1, 'Net of 12% commission', 96.80, '2026-07-31 19:42:50', '2026-07-31 19:42:50'),
(6, 4, 'Admin wallet credit', 10.00, 'credit', 'admin_adjust', NULL, 'E2E credit', 520.00, '2026-07-31 19:45:40', '2026-07-31 19:45:40'),
(7, 5, 'Trip HG-6A6CFB6811A6E earnings', 53.55, 'credit', 'trip', 16, 'Net of 15% commission', 168.30, '2026-07-31 19:45:52', '2026-07-31 19:45:52'),
(8, 4, 'Ride RID-LJOGXV1', 74.00, 'debit', 'ride', 16, '', 446.00, '2026-07-31 19:45:56', '2026-07-31 19:45:56'),
(9, 4, 'Refund ride RID-LJOGXV1', 74.00, 'credit', 'ride', 16, '', 520.00, '2026-07-31 19:45:58', '2026-07-31 19:45:58'),
(10, 6, 'Order ORD-LJPQVE2 settled', 187.00, 'credit', 'order', 2, 'Net of ৳33 commission', 374.00, '2026-07-31 19:46:10', '2026-07-31 19:46:10'),
(11, 5, 'Trip HG-6A6CFB7C85C62 earnings', 25.50, 'credit', 'trip', 18, 'Net of 15% commission', 193.80, '2026-07-31 19:46:10', '2026-07-31 19:46:10'),
(12, 7, 'Parcel HG-LJSRKS8 earnings', 96.80, 'credit', 'parcel', 2, 'Net of 12% commission', 193.60, '2026-07-31 19:46:25', '2026-07-31 19:46:25'),
(13, 7, 'E2E top-up', 406.40, 'credit', 'admin_adjust', NULL, '', 600.00, '2026-07-31 19:48:02', '2026-07-31 19:48:02'),
(14, 7, 'Withdrawal WD-LKH9HO3 (bKash)', 500.00, 'debit', 'withdrawal', 1, '', 100.00, '2026-07-31 19:48:11', '2026-07-31 19:48:11'),
(15, 7, 'E2E top-up', 500.00, 'credit', 'admin_adjust', NULL, '', 600.00, '2026-07-31 19:48:58', '2026-07-31 19:48:58'),
(16, 5, 'Payout HG-PY-LKSLG18 (bKash)', 100.00, 'debit', 'payout', 1, '', 93.80, '2026-07-31 19:49:04', '2026-07-31 19:49:04'),
(17, 7, 'Withdrawal WD-LKTI0M5 (bKash)', 500.00, 'debit', 'withdrawal', 2, '', 100.00, '2026-07-31 19:49:08', '2026-07-31 19:49:08'),
(18, 7, 'E2E top-up', 500.00, 'credit', 'admin_adjust', NULL, '', 600.00, '2026-07-31 19:49:46', '2026-07-31 19:49:46'),
(19, 6, 'E2E store top-up', 626.00, 'credit', 'admin_adjust', NULL, '', 1000.00, '2026-07-31 19:49:47', '2026-07-31 19:49:47'),
(20, 6, 'Payout PAY-LL2IJW7 (Bank)', 1000.00, 'debit', 'merchant_payout', 1, 'Early payout fee ৳20', 0.00, '2026-07-31 19:49:50', '2026-07-31 19:49:50'),
(21, 7, 'Withdrawal WD-LL45806 (bKash)', 500.00, 'debit', 'withdrawal', 3, '', 100.00, '2026-07-31 19:49:58', '2026-07-31 19:49:58'),
(22, 7, 'E2E top-up', 500.00, 'credit', 'admin_adjust', NULL, '', 600.00, '2026-07-31 19:50:41', '2026-07-31 19:50:41'),
(23, 6, 'E2E store top-up', 1000.00, 'credit', 'admin_adjust', NULL, '', 1000.00, '2026-07-31 19:50:42', '2026-07-31 19:50:42'),
(24, 6, 'Payout PAY-LLE4P19 (Bank)', 1000.00, 'debit', 'merchant_payout', 2, 'Early payout fee ৳20', 0.00, '2026-07-31 19:50:45', '2026-07-31 19:50:45'),
(25, 5, 'E2E rider top-up', 6.20, 'credit', 'admin_adjust', NULL, '', 100.00, '2026-07-31 19:50:47', '2026-07-31 19:50:47'),
(26, 5, 'Payout HG-PY-LLF8CS9 (bKash)', 100.00, 'debit', 'payout', 2, '', 0.00, '2026-07-31 19:50:50', '2026-07-31 19:50:50'),
(27, 7, 'Withdrawal WD-LLG3L86 (bKash)', 500.00, 'debit', 'withdrawal', 4, '', 100.00, '2026-07-31 19:50:54', '2026-07-31 19:50:54'),
(28, 4, 'Admin wallet credit', 10.00, 'credit', 'admin_adjust', NULL, 'E2E credit', 530.00, '2026-07-31 21:09:57', '2026-07-31 21:09:57'),
(29, 5, 'Trip HG-6A6D0F2909947 earnings', 53.55, 'credit', 'trip', 19, 'Net of 15% commission', 53.55, '2026-07-31 21:10:10', '2026-07-31 21:10:10'),
(30, 4, 'Ride RID-MDSMB84', 74.00, 'debit', 'ride', 18, '', 456.00, '2026-07-31 21:10:14', '2026-07-31 21:10:14'),
(31, 4, 'Refund ride RID-MDSMB84', 74.00, 'credit', 'ride', 18, '', 530.00, '2026-07-31 21:10:17', '2026-07-31 21:10:17'),
(32, 6, 'Order ORD-MDU6105 settled', 187.00, 'credit', 'order', 3, 'Net of ৳33 commission', 187.00, '2026-07-31 21:10:30', '2026-07-31 21:10:30'),
(33, 5, 'Trip HG-6A6D0F405773A earnings', 25.50, 'credit', 'trip', 21, 'Net of 15% commission', 79.05, '2026-07-31 21:10:30', '2026-07-31 21:10:30'),
(34, 7, 'Parcel HG-MDXLUW2 earnings', 96.80, 'credit', 'parcel', 3, 'Net of 12% commission', 196.80, '2026-07-31 21:10:47', '2026-07-31 21:10:47'),
(35, 7, 'E2E top-up', 403.20, 'credit', 'admin_adjust', NULL, '', 600.00, '2026-07-31 21:12:06', '2026-07-31 21:12:06'),
(36, 6, 'E2E store top-up', 813.00, 'credit', 'admin_adjust', NULL, '', 1000.00, '2026-07-31 21:12:08', '2026-07-31 21:12:08'),
(37, 6, 'Payout PAY-MEHG7K0 (Bank)', 1000.00, 'debit', 'merchant_payout', 3, 'Early payout fee ৳20', 0.00, '2026-07-31 21:12:11', '2026-07-31 21:12:11'),
(38, 5, 'E2E rider top-up', 20.95, 'credit', 'admin_adjust', NULL, '', 100.00, '2026-07-31 21:12:14', '2026-07-31 21:12:14'),
(39, 5, 'Payout HG-PY-MEISJO3 (bKash)', 100.00, 'debit', 'payout', 3, '', 0.00, '2026-07-31 21:12:17', '2026-07-31 21:12:17'),
(40, 7, 'Withdrawal WD-MEJSZE1 (bKash)', 500.00, 'debit', 'withdrawal', 5, '', 100.00, '2026-07-31 21:12:22', '2026-07-31 21:12:22'),
(41, 4, 'Admin wallet credit', 1.00, 'credit', 'admin_adjust', NULL, 'catalog-e2e-audit', 531.00, '2026-07-31 21:15:44', '2026-07-31 21:15:44'),
(42, 4, 'Admin wallet credit', 1.00, 'credit', 'admin_adjust', NULL, 'catalog-e2e-audit', 532.00, '2026-07-31 21:20:22', '2026-07-31 21:20:22');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `activity_logs_created_at_index` (`created_at`),
  ADD KEY `activity_logs_by_user_id_foreign` (`by_user_id`);

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
  ADD UNIQUE KEY `courier_profiles_code_unique` (`code`),
  ADD KEY `courier_profiles_online_verified_index` (`online`,`verified`),
  ADD KEY `courier_profiles_kyc_status_index` (`kyc_status`);

--
-- Indexes for table `courier_withdrawals`
--
ALTER TABLE `courier_withdrawals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `courier_withdrawals_code_unique` (`code`),
  ADD KEY `courier_withdrawals_courier_id_foreign` (`courier_id`),
  ADD KEY `courier_withdrawals_courier_status_index` (`courier_id`,`status`),
  ADD KEY `courier_withdrawals_status_index` (`status`);

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
  ADD KEY `districts_division_id_status_index` (`division_id`,`status`),
  ADD KEY `districts_updated_by_user_id_foreign` (`updated_by_user_id`);

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
  ADD KEY `merchant_payouts_store_id_foreign` (`store_id`),
  ADD KEY `merchant_payouts_store_status_index` (`store_id`,`status`),
  ADD KEY `merchant_payouts_status_index` (`status`);

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
  ADD KEY `orders_customer_id_channel_index` (`customer_id`,`channel`),
  ADD KEY `orders_channel_created_index` (`channel`,`created_at`),
  ADD KEY `orders_status_created_index` (`status`,`created_at`);

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
  ADD KEY `otp_codes_phone_role_purpose_index` (`phone`,`role`,`purpose`),
  ADD KEY `otp_codes_expires_at_index` (`expires_at`);

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
  ADD KEY `pricing_audits_panel_created_at_index` (`panel`,`created_at`),
  ADD KEY `pricing_audits_by_user_id_foreign` (`by_user_id`);

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
  ADD KEY `rider_payouts_rider_id_foreign` (`rider_id`),
  ADD KEY `rider_payouts_rider_status_index` (`rider_id`,`status`),
  ADD KEY `rider_payouts_status_index` (`status`);

--
-- Indexes for table `rider_profiles`
--
ALTER TABLE `rider_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rider_profiles_user_id_unique` (`user_id`),
  ADD UNIQUE KEY `rider_profiles_code_unique` (`code`),
  ADD KEY `rider_profiles_online_vehicle_type_index` (`online`,`vehicle_type`),
  ADD KEY `rider_profiles_kyc_queue_index` (`kyc_status`,`kyc_submitted_at`);

--
-- Indexes for table `rides`
--
ALTER TABLE `rides`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rides_code_unique` (`code`),
  ADD KEY `rides_rider_id_foreign` (`rider_id`),
  ADD KEY `rides_district_id_foreign` (`district_id`),
  ADD KEY `rides_status_created_at_index` (`status`,`created_at`),
  ADD KEY `rides_customer_id_index` (`customer_id`),
  ADD KEY `rides_customer_status_index` (`customer_id`,`status`);

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
  ADD KEY `sos_alerts_status_created_at_index` (`status`,`created_at`),
  ADD KEY `sos_alerts_resolved_by_user_id_foreign` (`resolved_by_user_id`);

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
  ADD KEY `trips_status_offer_expires_at_index` (`status`,`offer_expires_at`),
  ADD KEY `trips_rider_status_completed_index` (`rider_id`,`status`,`completed_at`),
  ADD KEY `trips_status_completed_index` (`status`,`completed_at`);

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
  ADD KEY `wallet_transactions_user_id_created_at_index` (`user_id`,`created_at`),
  ADD KEY `wallet_transactions_ref_index` (`ref_type`,`ref_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT for table `addresses`
--
ALTER TABLE `addresses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `app_notifications`
--
ALTER TABLE `app_notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=299;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `newsletter_subscribers`
--
ALTER TABLE `newsletter_subscribers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `otp_codes`
--
ALTER TABLE `otp_codes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `parcels`
--
ALTER TABLE `parcels`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `parcel_otp_logs`
--
ALTER TABLE `parcel_otp_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=105;

--
-- AUTO_INCREMENT for table `pricing_audits`
--
ALTER TABLE `pricing_audits`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `pricing_settings`
--
ALTER TABLE `pricing_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `product_categories`
--
ALTER TABLE `product_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `rider_profiles`
--
ALTER TABLE `rider_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `rides`
--
ALTER TABLE `rides`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `sos_alerts`
--
ALTER TABLE `sos_alerts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD CONSTRAINT `activity_logs_by_user_id_foreign` FOREIGN KEY (`by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

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
  ADD CONSTRAINT `courier_withdrawals_courier_id_foreign` FOREIGN KEY (`courier_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `customer_profiles`
--
ALTER TABLE `customer_profiles`
  ADD CONSTRAINT `customer_profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `districts`
--
ALTER TABLE `districts`
  ADD CONSTRAINT `districts_division_id_foreign` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `districts_updated_by_user_id_foreign` FOREIGN KEY (`updated_by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `hotel_bookings`
--
ALTER TABLE `hotel_bookings`
  ADD CONSTRAINT `hotel_bookings_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `hotel_bookings_hotel_id_foreign` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`);

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
  ADD CONSTRAINT `loyalty_redemptions_reward_id_foreign` FOREIGN KEY (`reward_id`) REFERENCES `loyalty_rewards` (`id`),
  ADD CONSTRAINT `loyalty_redemptions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

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
  ADD CONSTRAINT `merchant_payouts_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `orders_district_id_foreign` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `orders_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`);

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
-- Constraints for table `pricing_audits`
--
ALTER TABLE `pricing_audits`
  ADD CONSTRAINT `pricing_audits_by_user_id_foreign` FOREIGN KEY (`by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

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
  ADD CONSTRAINT `rental_bookings_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `rental_bookings_vehicle_id_foreign` FOREIGN KEY (`vehicle_id`) REFERENCES `rental_vehicles` (`id`);

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
  ADD CONSTRAINT `rider_payouts_rider_id_foreign` FOREIGN KEY (`rider_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `rider_profiles`
--
ALTER TABLE `rider_profiles`
  ADD CONSTRAINT `rider_profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `rides`
--
ALTER TABLE `rides`
  ADD CONSTRAINT `rides_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `rides_district_id_foreign` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `rides_rider_id_foreign` FOREIGN KEY (`rider_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `sos_alerts`
--
ALTER TABLE `sos_alerts`
  ADD CONSTRAINT `sos_alerts_resolved_by_user_id_foreign` FOREIGN KEY (`resolved_by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
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
  ADD CONSTRAINT `wallet_transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
