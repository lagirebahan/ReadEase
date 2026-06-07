-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 07, 2026 at 11:07 AM
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
-- Database: `readease`
--

-- --------------------------------------------------------

--
-- Table structure for table `folders`
--

CREATE TABLE `folders` (
  `folder_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `folders`
--

INSERT INTO `folders` (`folder_id`, `user_id`, `name`, `created_at`) VALUES
(3, 2, 'Work', '2026-06-07 15:50:18'),
(4, 3, 'Work', '2026-06-07 15:50:18'),
(5, 1, 'Test Group again', '2026-06-07 15:50:18'),
(6, 1, 'test folder creation', '2026-06-07 15:58:22');

-- --------------------------------------------------------

--
-- Table structure for table `notes`
--

CREATE TABLE `notes` (
  `note_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL DEFAULT 'Untitled',
  `image_path` varchar(255) NOT NULL DEFAULT '',
  `extracted_text` text DEFAULT NULL,
  `is_pinned` tinyint(4) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `folder_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notes`
--

INSERT INTO `notes` (`note_id`, `user_id`, `title`, `image_path`, `extracted_text`, `is_pinned`, `created_at`, `updated_at`, `folder_id`) VALUES
(1, 1, 'test note', '/uploads/1780816829843.png', 'Lorem Ipsum\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed\neiusmod tempor incidunt ut labore et dolore magna aliqua. Ut\nenim ad minim veniam, quis nostrud exercitation ullamco\nlaboris nisi ut aliquid ex ea commodi consequat. Quis aute iure\nreprehenderit in voluptate velit esse cillum dolore eu fugiat\nnulla pariatur. Excepteur sint obcaecat cupiditat non proident,\nsunt in culpa qui officia deserunt mollit anim id est laborum.\n', 0, '2026-06-07 14:20:30', '2026-06-07 14:44:18', NULL),
(2, 1, 'Custom Text', '/uploads/1780816873289.png', 'CUSTOM TEXT\nTHIS TEXT OPTION WILL ALLOW YOU TO PROVIDE US WITH A UNIQUE TEXT OF\nYOUR OWN. WORK WITH YOUR FUTURE SPOUSE AND/OR OFFICIANT TO SUBMIT\nYOUR VERY OWN TEXT (AS A WORD DOCUMENT) TO BE USED ON YOUR KETUBAH. WE\nWILL PREPARE THE TEXT IN WHICHEVER LANGUAGE(S) YOU PREPARE FOR US.\nTHIS TEXT OPTION WILL ALLOW YOU TO PROVIDE US WITH A UNIQUE TEXT OF\nYOUR OWN. WORK WITH YOUR FUTURE SPOUSE AND/OR OFFICIANT TO SUBMIT\nYOUR VERY OWN TEXT (AS A WORD DOCUMENT) TO BE USED ON YOUR KETUBAH. WE\nWILL PREPARE THE TEXT IN WHICHEVER LANGUAGE(S) YOU PREPARE FOR US.\nTHIS TEXT OPTION WILL ALLOW YOU TO PROVIDE US WITH A UNIQUE TEXT OF\nYOUR OWN. WORK WITH YOUR FUTURE SPOUSE AND/OR OFFICIANT TO SUBMIT\nYOUR VERY OWN TEXT (AS A WORD DOCUMENT) TO BE USED ON YOUR KETUBAH. WE\nWILL PREPARE THE TEXT IN WHICHEVER LANGUAGE(S) YOU PREPARE FOR US.\nTHIS TEXT OPTION WILL ALLOW YOU TO PROVIDE US WITH A UNIQUE TEXT OF\nYOUR OWN. WORK WITH YOUR FUTURE SPOUSE AND/OR OFFICIANT TO SUBMIT\nYOUR VERY OWN TEXT (AS A WORD DOCUMENT) TO BE USED ON YOUR KETUBAH. WE\nWILL PREPARE THE TEXT IN WHICHEVER LANGUAGE(S) YOU PREPARE FOR US.\nTHIS TEXT OPTION WILL ALLOW YOU TO PROVIDE US WITH A UNIQUE TEXT OF\nYOUR OWN. WORK WITH YOUR FUTURE SPOUSE AND/OR OFFICIANT TO SUBMIT\nYOUR VERY OWN TEXT (AS A WORD DOCUMENT) TO BE USED ON YOUR KETUBAH. WE\nWILL PREPARE THE TEXT IN WHICHEVER LANGUAGE(S) YOU PREPARE FOR US.\n', 1, '2026-06-07 14:21:15', '2026-06-07 14:35:49', NULL),
(3, 1, 'Test new note widget', '', 'test no image', 0, '2026-06-07 14:34:47', '2026-06-07 14:43:40', NULL),
(4, 2, 'Test Note Title Modified', '', 'Hello World OCR text', 1, '2026-06-07 14:41:05', '2026-06-07 15:50:18', 3),
(5, 3, 'Test Note Title Modified', '', 'Hello World OCR text', 1, '2026-06-07 14:41:27', '2026-06-07 15:50:18', 4),
(6, 1, 'MonTiss', '/uploads/1780818329392.png', 'p\nMONTISS\n~ goftness in Every Sheet\nMONTISS terbuat dari serat pulp myrni alam\npilihan untuk memberikan Anda tisy berkyalitas\ntinggi. Bahan baku pilihan ini menjadikan tisy\nMontiss halus dan lembut. Montiss dikemas\nmenarik, praktis dibawa ke mana-mana, cocok\nuntuk Anda dan keluarga.\nMONTISS is produced from selected natural\nvirgin pulp to provide a high quality tissue for\nyou. The natural virgin pulp gives Montiss a\nSmooth and soft texture. With beautiful\nPackaging, Montiss is convenient to bring and\nJUst a perfect choice for you and your family:\n', 1, '2026-06-07 14:45:30', '2026-06-07 15:50:18', 5),
(7, 1, 'Pokemon Card', '/uploads/1780818878277.png', 'Lihat 3 kartu dari bawah Deck sendiri, lalu tukar\nurutan kartu sesukanya dan kembalikan ke atas Deck.\n', 0, '2026-06-07 14:54:38', '2026-06-07 14:55:05', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `password`, `created_at`) VALUES
(1, 'Test User', 'test@testuser.com', '$2b$10$MilwM7Q6NrZ4gKlCrZAzquS0nG53MvtWM4ZeRZYDe9arQ8NtwtZAW', '2026-06-07 14:15:00'),
(2, 'testuser_put', 'testuser_put@example.com', '$2b$10$2bD9kYEjLXCWgkpC7I7wMuP67VdbFlpi4qHejPwfot9lLuVoyAEH.', '2026-06-07 14:41:05'),
(3, 'testuser_1780818087448', 'testuser_1780818087448@example.com', '$2b$10$FJc2lozYRNe8MxU1Ye2xmebormw12U6SOzgf9UBrv258JfzvV9uVG', '2026-06-07 14:41:27');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `folders`
--
ALTER TABLE `folders`
  ADD PRIMARY KEY (`folder_id`),
  ADD UNIQUE KEY `user_folder_unique` (`user_id`,`name`);

--
-- Indexes for table `notes`
--
ALTER TABLE `notes`
  ADD PRIMARY KEY (`note_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `fk_notes_folder` (`folder_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `folders`
--
ALTER TABLE `folders`
  MODIFY `folder_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `notes`
--
ALTER TABLE `notes`
  MODIFY `note_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `folders`
--
ALTER TABLE `folders`
  ADD CONSTRAINT `folders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `notes`
--
ALTER TABLE `notes`
  ADD CONSTRAINT `fk_notes_folder` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `notes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
