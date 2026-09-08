-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 08-09-2026 a las 10:44:22
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `swift_invoice_db`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_buscar_facturas` (IN `tipoBusqueda` VARCHAR(20), IN `valorBusqueda` VARCHAR(100))   BEGIN

    SELECT 
        i.id, 
        i.invoice_number, 
        i.invoice_date, 
        i.created_at, 
        s.total, 
        s.client_type,

        CASE 
            WHEN s.client_type = 'person'
                THEN CONCAT(c.last_name, ' ', c.first_name)

            WHEN s.client_type = 'company'
                THEN co.business_name

            ELSE 'Desconocido'
        END AS client_name

    FROM invoices i

    JOIN sales s 
        ON i.sale_id = s.id

    LEFT JOIN clients c 
        ON s.client_type = 'person' 
        AND s.client_id = c.id

    LEFT JOIN companies co 
        ON s.client_type = 'company' 
        AND s.client_id = co.id

    WHERE
        (
            tipoBusqueda = 'folio'
            AND i.invoice_number LIKE CONCAT('%', valorBusqueda, '%')
        )

        OR

        (
            tipoBusqueda = 'fecha'
            AND DATE(i.invoice_date) = valorBusqueda
        )

    ORDER BY i.invoice_date DESC;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `audit_log`
--

CREATE TABLE `audit_log` (
  `id_audit` int(11) NOT NULL,
  `table_name` varchar(100) DEFAULT NULL,
  `action_type` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `record_id` int(11) DEFAULT NULL,
  `old_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_data`)),
  `new_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_data`)),
  `modified_by` varchar(100) DEFAULT NULL,
  `modification_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `audit_log`
--

INSERT INTO `audit_log` (`id_audit`, `table_name`, `action_type`, `record_id`, `old_data`, `new_data`, `modified_by`, `modification_date`) VALUES
(1, 'clients', 'UPDATE', 4, '{\"first_name\": \"ABRAHAM\", \"last_name\": \"ESTRADA\", \"mother_last_name\": \"SOLANO\", \"phone\": \"6631236878\", \"email\": \"aleluyo@gmail.com\", \"rfc\": \"ESSA04102911\", \"address\": \"BLVD ALBERTO LIMON PADILLA S/N MESA DE OTAY\", \"tax_regime_id\": null}', '{\"first_name\": \"ABRAHAM\", \"last_name\": \"ESTRADA\", \"mother_last_name\": \"OSORIO\", \"phone\": \"6641236878\", \"email\": \"aleluyo@gmail.com\", \"rfc\": \"ESSA04102911\", \"address\": \"BLVD ALBERTO LIMON PADILLA S/N MESA DE OTAY\", \"tax_regime_id\": 4}', NULL, '2026-04-29 18:02:01'),
(2, 'clients', 'UPDATE', 2, '{\"first_name\": \"PANFILOMENO\", \"last_name\": \"MOMICHIS\", \"mother_last_name\": \"INSANO\", \"phone\": \"6624560923\", \"email\": \"momichiscorjjp@gmail.com\", \"rfc\": \"MOM123124215\", \"address\": \"AV DEL PARQUE S/N MESA DE OTAY, 22430, TIJUANA, BC, MEXICO.\", \"tax_regime_id\": null}', '{\"first_name\": \"FILOMENO\", \"last_name\": \"MONICH\", \"mother_last_name\": \"INSAN\", \"phone\": \"6624560923\", \"email\": \"momichiscorjjp@gmail.com\", \"rfc\": \"MOM123124215\", \"address\": \"AV DEL PARQUE S/N MESA DE OTAY, 22430, TIJUANA, BC, MEXICO.\", \"tax_regime_id\": 3}', NULL, '2026-04-29 19:44:53'),
(3, 'clients', 'INSERT', 7, NULL, '{\"first_name\": \"BETO\", \"last_name\": \"CUEVAS\", \"mother_last_name\": \"FONSECA\", \"phone\": \"6645251422\", \"email\": \"cubeto.17@outlook.com\", \"rfc\": \"CUFB911206LK2\", \"address\": \"CALLE DE LAS FLORES # 71\", \"tax_regime_id\": 10}', NULL, '2026-04-29 20:11:47'),
(4, 'clients', 'UPDATE', 7, '{\"first_name\": \"BETO\", \"last_name\": \"CUEVAS\", \"mother_last_name\": \"FONSECA\", \"phone\": \"6645251422\", \"email\": \"cubeto.17@outlook.com\", \"rfc\": \"CUFB911206LK2\", \"address\": \"CALLE DE LAS FLORES # 71\", \"tax_regime_id\": 10}', '{\"first_name\": \"BETO\", \"last_name\": \"CUEVAS\", \"mother_last_name\": \"FONSECA\", \"phone\": \"6645251422\", \"email\": \"cubeto.17@msn.com\", \"rfc\": \"CUFB911206LK2\", \"address\": \"CALLE DE LAS FLORES # 71\", \"tax_regime_id\": 10}', NULL, '2026-04-29 20:12:06'),
(5, 'clients', 'DELETE', 6, '{\"first_name\": \"MARIA LUISA\", \"last_name\": \"PEREZ\", \"mother_last_name\": \"LEAL\", \"phone\": \"6641202151\", \"email\": \"M.Luisa@gmail.com\", \"rfc\": \"PELM781220HM9\", \"address\": \"BLVD. INSURGENTES SUR #182\", \"tax_regime_id\": 6}', NULL, 'Infinity', '2026-04-29 20:12:35'),
(6, 'clients', 'DELETE', 7, '{\"first_name\": \"BETO\", \"last_name\": \"CUEVAS\", \"mother_last_name\": \"FONSECA\", \"phone\": \"6645251422\", \"email\": \"cubeto.17@msn.com\", \"rfc\": \"CUFB911206LK2\", \"address\": \"CALLE DE LAS FLORES # 71\", \"tax_regime_id\": 10}', NULL, 'Infinity', '2026-04-29 20:13:58'),
(7, 'clients', 'INSERT', 8, NULL, '{\"first_name\": \"MARIA LUISA\", \"last_name\": \"PEREZ\", \"mother_last_name\": \"LEAL\", \"phone\": \"6373760377\", \"email\": \"mogar94634@bitflirt.com\", \"rfc\": \"PELL770416HQR\", \"address\": \"CALLE DE LOS OLIVOS #12\", \"tax_regime_id\": 6}', 'Infinity', '2026-04-29 20:20:04'),
(8, 'clients', 'UPDATE', 8, '{\"first_name\": \"MARIA LUISA\", \"last_name\": \"PEREZ\", \"mother_last_name\": \"LEAL\", \"phone\": \"6373760377\", \"email\": \"mogar94634@bitflirt.com\", \"rfc\": \"PELL770416HQR\", \"address\": \"CALLE DE LOS OLIVOS #12\", \"tax_regime_id\": 6}', '{\"first_name\": \"MARIA LUISA\", \"last_name\": \"PEREZ\", \"mother_last_name\": \"LEAL\", \"phone\": \"6373760344\", \"email\": \"mogar94634@bitflirt.com\", \"rfc\": \"PELL770416HQR\", \"address\": \"CALLE DE LOS OLIVOS #12\", \"tax_regime_id\": 6}', 'Infinity', '2026-04-29 20:21:24'),
(9, 'sales', 'UPDATE', 42, '{\"client_id\": 5, \"sale_date\": \"2026-04-29\", \"subtotal\": 5070.00, \"tax_percentage\": 16.00, \"tax_amount\": 811.20, \"total\": 5881.20, \"client_type\": \"person\"}', '{\"client_id\": 5, \"sale_date\": \"2026-04-29\", \"subtotal\": 125070.00, \"tax_percentage\": 16.00, \"tax_amount\": 20011.20, \"total\": 145081.20, \"client_type\": \"person\"}', 'Infinity', '2026-04-29 20:40:23'),
(10, 'sales', 'UPDATE', 42, '{\"client_id\": 5, \"client_name\": \"LOS MUÑECOS SOPE\", \"sale_date\": \"2026-04-29\", \"subtotal\": 125070.00, \"tax_percentage\": 16.00, \"tax_amount\": 20011.20, \"total\": 145081.20, \"client_type\": \"person\"}', '{\"client_id\": 5, \"client_name\": \"LOS MUÑECOS SOPE\", \"sale_date\": \"2026-04-29\", \"subtotal\": 125630.00, \"tax_percentage\": 16.00, \"tax_amount\": 20011.20, \"total\": 145641.20, \"client_type\": \"person\"}', 'Infinity', '2026-04-29 20:46:45'),
(11, 'sales', 'DELETE', 42, '{\"client_id\": 5, \"client_name\": \"LOS MUÑECOS SOPE\", \"sale_date\": \"2026-04-29\", \"subtotal\": 125630.00, \"tax_percentage\": 16.00, \"tax_amount\": 20011.20, \"total\": 145641.20, \"client_type\": \"person\"}', NULL, 'Infinity', '2026-04-29 20:47:15'),
(12, 'clients', 'INSERT', 10, NULL, '{\"first_name\": \"CARLOS\", \"last_name\": \"MARIN\", \"mother_last_name\": \"CABALLERO\", \"phone\": \"6611352587\", \"email\": \"menostrece@dolofan.com\", \"rfc\": \"MACC980403452\", \"address\": \"CALLE DE LAS ACACIAS #2351\", \"tax_regime_id\": 3, \"tax_regime_name\": \"Régimen de Incorporación Fiscal\"}', 'root', '2026-04-29 21:30:09'),
(13, 'clients', 'UPDATE', 10, '{\"first_name\": \"CARLOS\", \"last_name\": \"MARIN\", \"mother_last_name\": \"CABALLERO\", \"phone\": \"6611352587\", \"email\": \"menostrece@dolofan.com\", \"rfc\": \"MACC980403452\", \"address\": \"CALLE DE LAS ACACIAS #2351\", \"tax_regime_id\": 3, \"tax_regime_name\": \"Régimen de Incorporación Fiscal\"}', '{\"first_name\": \"CARLOS\", \"last_name\": \"MARIN\", \"mother_last_name\": \"CABALLERO\", \"phone\": \"6611352597\", \"email\": \"menostrece@dolofan.com\", \"rfc\": \"MACC980403452\", \"address\": \"CALLE DE LAS ACACIAS #2351\", \"tax_regime_id\": 3, \"tax_regime_name\": \"Régimen de Incorporación Fiscal\"}', 'root', '2026-04-29 21:30:45'),
(14, 'sales', 'INSERT', 43, NULL, '{\"client_id\": 10, \"client_name\": \"CARLOS MARIN\", \"sale_date\": \"2026-04-29\", \"subtotal\": 4800.00, \"tax_percentage\": 16.00, \"tax_amount\": 768.00, \"total\": 5568.00, \"client_type\": \"person\"}', 'root', '2026-04-29 21:32:19'),
(15, 'sale_details', 'INSERT', 113, NULL, '{\"sale_id\": 43, \"product_id\": 1, \"product_name\": \"Servicios médicos (consultas)\", \"quantity\": 6, \"unit_price\": 500.00, \"subtotal\": 3000.00, \"tax_rate\": 16.00}', 'root', '2026-04-29 21:32:19'),
(16, 'sale_details', 'INSERT', 114, NULL, '{\"sale_id\": 43, \"product_id\": 25, \"product_name\": \"Servicios de veterinaria\", \"quantity\": 3, \"unit_price\": 600.00, \"subtotal\": 1800.00, \"tax_rate\": 16.00}', 'root', '2026-04-29 21:32:19'),
(17, 'sales', 'INSERT', 44, NULL, '{\"client_id\": 8, \"client_name\": \"MARIA LUISA PEREZ\", \"sale_date\": \"2026-04-30\", \"subtotal\": 75783.50, \"tax_percentage\": 16.00, \"tax_amount\": 0.00, \"total\": 75783.50, \"client_type\": \"person\"}', 'root', '2026-04-29 23:20:21'),
(18, 'sale_details', 'INSERT', 115, NULL, '{\"sale_id\": 44, \"product_id\": 31, \"product_name\": \"Impresoras\", \"quantity\": 1, \"unit_price\": 2500.00, \"subtotal\": 2500.00, \"tax_rate\": 0.00}', 'root', '2026-04-29 23:20:21'),
(19, 'sale_details', 'INSERT', 116, NULL, '{\"sale_id\": 44, \"product_id\": 40, \"product_name\": \"Muebles de oficina\", \"quantity\": 1, \"unit_price\": 3500.00, \"subtotal\": 3500.00, \"tax_rate\": 0.00}', 'root', '2026-04-29 23:20:21'),
(20, 'sale_details', 'INSERT', 117, NULL, '{\"sale_id\": 44, \"product_id\": 26, \"product_name\": \"Gasolina\", \"quantity\": 1, \"unit_price\": 23.50, \"subtotal\": 23.50, \"tax_rate\": 0.00}', 'root', '2026-04-29 23:20:21'),
(21, 'sale_details', 'INSERT', 118, NULL, '{\"sale_id\": 44, \"product_id\": 24, \"product_name\": \"Consultas de medicina general\", \"quantity\": 1, \"unit_price\": 500.00, \"subtotal\": 500.00, \"tax_rate\": 0.00}', 'root', '2026-04-29 23:20:21'),
(22, 'sale_details', 'INSERT', 119, NULL, '{\"sale_id\": 44, \"product_id\": 39, \"product_name\": \"Jabón líquido\", \"quantity\": 1, \"unit_price\": 70.00, \"subtotal\": 70.00, \"tax_rate\": 0.00}', 'root', '2026-04-29 23:20:21'),
(23, 'sale_details', 'INSERT', 120, NULL, '{\"sale_id\": 44, \"product_id\": 35, \"product_name\": \"Carpetas y archivadores\", \"quantity\": 1, \"unit_price\": 90.00, \"subtotal\": 90.00, \"tax_rate\": 0.00}', 'root', '2026-04-29 23:20:21'),
(24, 'sale_details', 'INSERT', 121, NULL, '{\"sale_id\": 44, \"product_id\": 11, \"product_name\": \"Servicios médicos (consultas)\", \"quantity\": 1, \"unit_price\": 500.00, \"subtotal\": 500.00, \"tax_rate\": 0.00}', 'root', '2026-04-29 23:20:21'),
(25, 'sale_details', 'INSERT', 122, NULL, '{\"sale_id\": 44, \"product_id\": 30, \"product_name\": \"Tablets\", \"quantity\": 1, \"unit_price\": 8000.00, \"subtotal\": 8000.00, \"tax_rate\": 0.00}', 'root', '2026-04-29 23:20:21'),
(26, 'sale_details', 'INSERT', 123, NULL, '{\"sale_id\": 44, \"product_id\": 2, \"product_name\": \"Exámenes médicos laborales\", \"quantity\": 1, \"unit_price\": 600.00, \"subtotal\": 600.00, \"tax_rate\": 0.00}', 'root', '2026-04-29 23:20:21'),
(27, 'sale_details', 'INSERT', 124, NULL, '{\"sale_id\": 44, \"product_id\": 29, \"product_name\": \"Computadoras portátiles\", \"quantity\": 4, \"unit_price\": 15000.00, \"subtotal\": 60000.00, \"tax_rate\": 0.00}', 'root', '2026-04-29 23:20:21');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `business_types`
--

CREATE TABLE `business_types` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `business_types`
--

INSERT INTO `business_types` (`id`, `name`) VALUES
(1, 'S.A. de C.V.'),
(2, 'S. de R.L.'),
(3, 'S. de R.L. de C.V.'),
(4, 'S.C.'),
(5, 'A.C.'),
(6, 'S.N.C.'),
(7, 'S.A.P.I. de C.V.'),
(8, 'S.A.'),
(9, 'S.R.L.'),
(10, 'Cooperativa');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clients`
--

CREATE TABLE `clients` (
  `id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `mother_last_name` varchar(50) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `rfc` varchar(13) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `tax_regime_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `clients`
--

INSERT INTO `clients` (`id`, `first_name`, `last_name`, `mother_last_name`, `phone`, `email`, `rfc`, `address`, `tax_regime_id`, `created_at`) VALUES
(2, 'FILOMENO', 'MONICH', 'INSAN', '6624560923', 'momichiscorjjp@gmail.com', 'MOM123124215', 'AV DEL PARQUE S/N MESA DE OTAY, 22430, TIJUANA, BC, MEXICO.', 3, '2025-05-10 10:54:57'),
(3, 'JUAN ANTONIO', 'TORRES', 'VASQUEZ', '6641234567', 'jtorres@gmail.com', 'JAM123124213', 'COL LAS TORRES, 22476. TIJUANA, BAJA CALIFORNIA.', NULL, '2025-05-11 12:20:52'),
(4, 'ABRAHAM', 'ESTRADA', 'OSORIO', '6641236878', 'aleluyo@gmail.com', 'ESSA04102911', 'BLVD ALBERTO LIMON PADILLA S/N MESA DE OTAY', 4, '2025-05-13 21:11:12'),
(5, 'LOS MUÑECOS', 'SOPE', 'FLAUTA', '6641259941', 'losmunequitos@outlook.com', 'MULO000812H77', 'CALZADA TECNOLOGICO #1024', 2, '2026-04-24 02:41:34'),
(8, 'MARIA LUISA', 'PEREZ', 'LEAL', '6373760344', 'mogar94634@bitflirt.com', 'PELL770416HQR', 'CALLE DE LOS OLIVOS #12', 6, '2026-04-29 20:20:04'),
(10, 'CARLOS', 'MARIN', 'CABALLERO', '6611352597', 'menostrece@dolofan.com', 'MACC980403452', 'CALLE DE LAS ACACIAS #2351', 3, '2026-04-29 21:30:09');

--
-- Disparadores `clients`
--
DELIMITER $$
CREATE TRIGGER `trg_clients_delete` AFTER DELETE ON `clients` FOR EACH ROW BEGIN

    DECLARE regimen_nombre VARCHAR(255);

    SELECT name
    INTO regimen_nombre
    FROM tax_regimes
    WHERE id = OLD.tax_regime_id
    LIMIT 1;

    INSERT INTO audit_log (
        table_name,
        action_type,
        record_id,
        old_data,
        modified_by
    )
    VALUES (
        'clients',
        'DELETE',
        OLD.id,

        JSON_OBJECT(
            'first_name', OLD.first_name,
            'last_name', OLD.last_name,
            'mother_last_name', OLD.mother_last_name,
            'phone', OLD.phone,
            'email', OLD.email,
            'rfc', OLD.rfc,
            'address', OLD.address,
            'tax_regime_id', OLD.tax_regime_id,
            'tax_regime_name', regimen_nombre
        ),

        (
            SELECT username
            FROM current_audit_user
            ORDER BY id DESC
            LIMIT 1
        )
    );

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_clients_insert` AFTER INSERT ON `clients` FOR EACH ROW BEGIN

    DECLARE regimen_nombre VARCHAR(255);

    SELECT name
    INTO regimen_nombre
    FROM tax_regimes
    WHERE id = NEW.tax_regime_id
    LIMIT 1;

    INSERT INTO audit_log (
        table_name,
        action_type,
        record_id,
        new_data,
        modified_by
    )
    VALUES (
        'clients',
        'INSERT',
        NEW.id,

        JSON_OBJECT(
            'first_name', NEW.first_name,
            'last_name', NEW.last_name,
            'mother_last_name', NEW.mother_last_name,
            'phone', NEW.phone,
            'email', NEW.email,
            'rfc', NEW.rfc,
            'address', NEW.address,
            'tax_regime_id', NEW.tax_regime_id,
            'tax_regime_name', regimen_nombre
        ),

        (
            SELECT username
            FROM current_audit_user
            ORDER BY id DESC
            LIMIT 1
        )
    );

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_clients_update` AFTER UPDATE ON `clients` FOR EACH ROW BEGIN

    DECLARE regimen_old VARCHAR(255);
    DECLARE regimen_new VARCHAR(255);

    SELECT name
    INTO regimen_old
    FROM tax_regimes
    WHERE id = OLD.tax_regime_id
    LIMIT 1;

    SELECT name
    INTO regimen_new
    FROM tax_regimes
    WHERE id = NEW.tax_regime_id
    LIMIT 1;

    INSERT INTO audit_log (
        table_name,
        action_type,
        record_id,
        old_data,
        new_data,
        modified_by
    )
    VALUES (
        'clients',
        'UPDATE',
        NEW.id,

        JSON_OBJECT(
            'first_name', OLD.first_name,
            'last_name', OLD.last_name,
            'mother_last_name', OLD.mother_last_name,
            'phone', OLD.phone,
            'email', OLD.email,
            'rfc', OLD.rfc,
            'address', OLD.address,
            'tax_regime_id', OLD.tax_regime_id,
            'tax_regime_name', regimen_old
        ),

        JSON_OBJECT(
            'first_name', NEW.first_name,
            'last_name', NEW.last_name,
            'mother_last_name', NEW.mother_last_name,
            'phone', NEW.phone,
            'email', NEW.email,
            'rfc', NEW.rfc,
            'address', NEW.address,
            'tax_regime_id', NEW.tax_regime_id,
            'tax_regime_name', regimen_new
        ),

        (
            SELECT username
            FROM current_audit_user
            ORDER BY id DESC
            LIMIT 1
        )
    );

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `companies`
--

CREATE TABLE `companies` (
  `id` int(11) NOT NULL,
  `business_name` varchar(100) NOT NULL,
  `rfc` varchar(13) NOT NULL,
  `fiscal_address` text NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `legal_representative` varchar(100) DEFAULT NULL,
  `logo_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `business_type_id` int(11) DEFAULT NULL,
  `tax_regime_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `companies`
--

INSERT INTO `companies` (`id`, `business_name`, `rfc`, `fiscal_address`, `phone`, `email`, `legal_representative`, `logo_path`, `created_at`, `business_type_id`, `tax_regime_id`) VALUES
(2, 'EVASION DE IMPUESTOS', 'DIDD12345677', 'AV DEL PARQUE S/N MESA DE OTAY', '6631236878', 'insanos@gmail.com', 'OMAR DIDDY', NULL, '2025-05-18 19:32:48', 1, 9),
(3, 'EVASION DE IMPUESTOS', 'DIDD12345677', 'AV DEL PARQUE MESA DE OTAY', '6631236878', 'aleluyo@gmail.com', 'OMAR DIDDY', NULL, '2025-05-18 19:34:42', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `current_audit_user`
--

CREATE TABLE `current_audit_user` (
  `id` int(11) NOT NULL,
  `username` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `current_audit_user`
--

INSERT INTO `current_audit_user` (`id`, `username`, `created_at`) VALUES
(1, 'Infinity', '2026-04-29 20:12:35'),
(2, 'Infinity', '2026-04-29 20:13:58'),
(3, 'Infinity', '2026-04-29 20:40:23'),
(4, 'Infinity', '2026-04-29 20:46:45'),
(5, 'Infinity', '2026-04-29 20:47:15'),
(6, 'root', '2026-04-29 21:28:53'),
(7, 'root', '2026-04-29 21:30:09'),
(8, 'root', '2026-04-29 21:30:45'),
(9, 'root', '2026-04-29 21:32:19'),
(10, 'root', '2026-04-29 23:20:21');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `invoices`
--

CREATE TABLE `invoices` (
  `id` int(11) NOT NULL,
  `sale_id` int(11) NOT NULL,
  `invoice_number` varchar(20) NOT NULL,
  `invoice_date` date NOT NULL,
  `pdf_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `invoices`
--

INSERT INTO `invoices` (`id`, `sale_id`, `invoice_number`, `invoice_date`, `pdf_path`, `created_at`) VALUES
(1, 36, 'F001-0001', '2025-05-20', NULL, '2025-05-21 03:14:55'),
(2, 4, 'F001-0002', '2025-05-20', NULL, '2025-05-21 03:15:01'),
(3, 30, 'F001-0003', '2025-05-20', NULL, '2025-05-21 03:15:04'),
(4, 35, 'F001-0004', '2025-05-20', NULL, '2025-05-21 03:15:07'),
(5, 37, 'F001-0005', '2025-05-22', NULL, '2025-05-23 01:06:47'),
(6, 38, 'F001-0006', '2025-05-22', NULL, '2025-05-23 01:38:26'),
(7, 39, 'F001-0007', '2025-05-22', NULL, '2025-05-23 01:39:03'),
(8, 40, 'F001-0008', '2026-04-23', NULL, '2026-04-24 02:47:02'),
(9, 43, 'F001-0009', '2026-04-29', NULL, '2026-04-29 21:34:04');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `type` enum('Producto','Servicio') NOT NULL DEFAULT 'Producto',
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `products`
--

INSERT INTO `products` (`id`, `name`, `description`, `type`, `price`, `created_at`) VALUES
(1, 'Servicios médicos (consultas) 1', 'Servicios médicos (consultas 1)', 'Servicio', 500.00, '2025-05-10 11:15:06'),
(2, 'Exámenes médicos laborales', 'Exámenes médicos laborales', 'Servicio', 600.00, '2025-05-10 11:15:06'),
(3, 'Servicios de diseño gráfico', 'Servicios de diseño gráfico', 'Servicio', 1200.00, '2025-05-10 11:15:06'),
(4, 'Servicios de fotografía comercial', 'Servicios de fotografía comercial', 'Servicio', 1100.00, '2025-05-10 11:15:06'),
(5, 'Servicios de instalación eléctrica', 'Servicios de instalación eléctrica', 'Servicio', 1500.00, '2025-05-10 11:15:06'),
(6, 'Servicios de mantenimiento de edificios', 'Servicios de mantenimiento de edificios', 'Servicio', 1300.00, '2025-05-10 11:15:06'),
(7, 'Servicios educativos y capacitación', 'Servicios educativos y capacitación', 'Servicio', 1000.00, '2025-05-10 11:15:06'),
(8, 'Servicios de imprenta comercial', 'Servicios de imprenta comercial', 'Servicio', 950.00, '2025-05-10 11:15:06'),
(9, 'Servicios de reclutamiento de personal', 'Servicios de reclutamiento de personal', 'Servicio', 1400.00, '2025-05-10 11:15:06'),
(10, 'Servicios de plomería', 'Servicios de plomería', 'Servicio', 800.00, '2025-05-10 11:15:06'),
(11, 'Servicios médicos (consultas)', 'Servicios médicos (consultas)', 'Servicio', 500.00, '2025-05-10 11:15:07'),
(12, 'Exámenes médicos laborales', 'Exámenes médicos laborales', 'Servicio', 600.00, '2025-05-10 11:15:07'),
(13, 'Servicios de diseño gráfico', 'Servicios de diseño gráfico', 'Servicio', 1200.00, '2025-05-10 11:15:07'),
(14, 'Servicios de fotografía comercial', 'Servicios de fotografía comercial', 'Servicio', 1100.00, '2025-05-10 11:15:07'),
(15, 'Servicios de instalación eléctrica', 'Servicios de instalación eléctrica', 'Servicio', 1500.00, '2025-05-10 11:15:07'),
(16, 'Servicios de mantenimiento de edificios', 'Servicios de mantenimiento de edificios', 'Servicio', 1300.00, '2025-05-10 11:15:07'),
(17, 'Servicios educativos y capacitación', 'Servicios educativos y capacitación', 'Servicio', 1000.00, '2025-05-10 11:15:07'),
(18, 'Servicios de imprenta comercial', 'Servicios de imprenta comercial', 'Servicio', 950.00, '2025-05-10 11:15:07'),
(19, 'Servicios de reclutamiento de personal', 'Servicios de reclutamiento de personal', 'Servicio', 1400.00, '2025-05-10 11:15:07'),
(20, 'Servicios de plomería', 'Servicios de plomería', 'Servicio', 800.00, '2025-05-10 11:15:07'),
(21, 'Servicios de carpintería', 'Servicios de carpintería', 'Servicio', 900.00, '2025-05-10 11:15:07'),
(22, 'Servicios de auditoría contable', 'Servicios de auditoría contable', 'Servicio', 2100.00, '2025-05-10 11:15:07'),
(23, 'Servicios de odontología', 'Servicios de odontología', 'Servicio', 700.00, '2025-05-10 11:15:07'),
(24, 'Consultas de medicina general', 'Consultas de medicina general', 'Servicio', 500.00, '2025-05-10 11:15:07'),
(25, 'Servicios de veterinaria', 'Servicios de veterinaria', 'Servicio', 600.00, '2025-05-10 11:15:07'),
(26, 'Gasolina', 'Gasolina', 'Producto', 23.50, '2025-05-10 11:15:07'),
(27, 'Diesel', 'Diesel', 'Producto', 24.00, '2025-05-10 11:15:07'),
(28, 'Accesorios de computadoras', 'Accesorios de computadoras (cables, adaptadores)', 'Producto', 350.00, '2025-05-10 11:15:07'),
(29, 'Computadoras portátiles', 'Computadoras portátiles', 'Producto', 15000.00, '2025-05-10 11:15:07'),
(30, 'Tablets', 'Tablets', 'Producto', 8000.00, '2025-05-10 11:15:07'),
(31, 'Impresoras', 'Impresoras', 'Producto', 2500.00, '2025-05-10 11:15:07'),
(32, 'Baterías', 'Baterías', 'Producto', 300.00, '2025-05-10 11:15:07'),
(33, 'Papel para impresión', 'Papel para impresión', 'Producto', 120.00, '2025-05-10 11:15:07'),
(34, 'Tóner para impresora', 'Tóner para impresora', 'Producto', 800.00, '2025-05-10 11:15:07'),
(35, 'Carpetas y archivadores', 'Carpetas y archivadores', 'Producto', 90.00, '2025-05-10 11:15:07'),
(36, 'Plumas', 'Plumas', 'Producto', 15.00, '2025-05-10 11:15:07'),
(37, 'Cuadernos', 'Cuadernos', 'Producto', 40.00, '2025-05-10 11:15:07'),
(38, 'Productos de limpieza multiusos', 'Productos de limpieza multiusos', 'Producto', 100.00, '2025-05-10 11:15:07'),
(39, 'Jabón líquido', 'Jabón líquido', 'Producto', 70.00, '2025-05-10 11:15:07'),
(40, 'Muebles de oficina', 'Muebles de oficina (escritorios, sillas)', 'Producto', 3500.00, '2025-05-10 11:15:07');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sales`
--

CREATE TABLE `sales` (
  `id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `sale_date` date NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `tax_percentage` decimal(5,2) NOT NULL,
  `tax_amount` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `client_type` enum('person','company') NOT NULL DEFAULT 'person'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sales`
--

INSERT INTO `sales` (`id`, `client_id`, `sale_date`, `subtotal`, `tax_percentage`, `tax_amount`, `total`, `created_at`, `client_type`) VALUES
(4, 2, '2025-05-11', 430.00, 16.00, 68.80, 498.80, '2025-05-12 04:46:22', 'person'),
(30, 2, '2025-05-11', 120.00, 16.00, 19.20, 139.20, '2025-05-12 11:46:51', 'person'),
(35, 3, '2025-05-13', 3100.00, 16.00, 496.00, 3596.00, '2025-05-13 21:09:06', 'person'),
(36, 2, '2025-05-19', 24.00, 16.00, 0.24, 24.24, '2025-05-19 21:39:10', 'person'),
(37, 2, '2025-05-23', 2800.00, 16.00, 280.00, 3080.00, '2025-05-23 01:06:39', 'company'),
(38, 3, '2025-05-23', 624.00, 16.00, 124.80, 748.80, '2025-05-23 01:19:00', 'person'),
(39, 4, '2025-05-23', 600.00, 16.00, 180.00, 780.00, '2025-05-23 01:38:58', 'person'),
(40, 5, '2026-04-24', 9375.00, 16.00, 1500.00, 10875.00, '2026-04-24 02:45:28', 'person'),
(43, 10, '2026-04-29', 4800.00, 16.00, 768.00, 5568.00, '2026-04-29 21:32:19', 'person'),
(44, 8, '2026-04-30', 75783.50, 16.00, 0.00, 75783.50, '2026-04-29 23:20:21', 'person');

--
-- Disparadores `sales`
--
DELIMITER $$
CREATE TRIGGER `trg_sales_delete` AFTER DELETE ON `sales` FOR EACH ROW BEGIN

    DECLARE cliente_nombre VARCHAR(255);

    SELECT CONCAT(first_name, ' ', last_name)
    INTO cliente_nombre
    FROM clients
    WHERE id = OLD.client_id
    LIMIT 1;

    INSERT INTO audit_log (
        table_name,
        action_type,
        record_id,
        old_data,
        modified_by
    )
    VALUES (
        'sales',
        'DELETE',
        OLD.id,

        JSON_OBJECT(
            'client_id', OLD.client_id,
            'client_name', cliente_nombre,
            'sale_date', OLD.sale_date,
            'subtotal', OLD.subtotal,
            'tax_percentage', OLD.tax_percentage,
            'tax_amount', OLD.tax_amount,
            'total', OLD.total,
            'client_type', OLD.client_type
        ),

        (
            SELECT username
            FROM current_audit_user
            ORDER BY id DESC
            LIMIT 1
        )
    );

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_sales_insert` AFTER INSERT ON `sales` FOR EACH ROW BEGIN

    DECLARE cliente_nombre VARCHAR(255);

    SELECT CONCAT(first_name, ' ', last_name)
    INTO cliente_nombre
    FROM clients
    WHERE id = NEW.client_id
    LIMIT 1;

    INSERT INTO audit_log (
        table_name,
        action_type,
        record_id,
        new_data,
        modified_by
    )
    VALUES (
        'sales',
        'INSERT',
        NEW.id,

        JSON_OBJECT(
            'client_id', NEW.client_id,
            'client_name', cliente_nombre,
            'sale_date', NEW.sale_date,
            'subtotal', NEW.subtotal,
            'tax_percentage', NEW.tax_percentage,
            'tax_amount', NEW.tax_amount,
            'total', NEW.total,
            'client_type', NEW.client_type
        ),

        (
            SELECT username
            FROM current_audit_user
            ORDER BY id DESC
            LIMIT 1
        )
    );

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_sales_update` AFTER UPDATE ON `sales` FOR EACH ROW BEGIN

    DECLARE cliente_nombre_old VARCHAR(255);
    DECLARE cliente_nombre_new VARCHAR(255);

    SELECT CONCAT(first_name, ' ', last_name)
    INTO cliente_nombre_old
    FROM clients
    WHERE id = OLD.client_id
    LIMIT 1;

    SELECT CONCAT(first_name, ' ', last_name)
    INTO cliente_nombre_new
    FROM clients
    WHERE id = NEW.client_id
    LIMIT 1;

    INSERT INTO audit_log (
        table_name,
        action_type,
        record_id,
        old_data,
        new_data,
        modified_by
    )
    VALUES (
        'sales',
        'UPDATE',
        NEW.id,

        JSON_OBJECT(
            'client_id', OLD.client_id,
            'client_name', cliente_nombre_old,
            'sale_date', OLD.sale_date,
            'subtotal', OLD.subtotal,
            'tax_percentage', OLD.tax_percentage,
            'tax_amount', OLD.tax_amount,
            'total', OLD.total,
            'client_type', OLD.client_type
        ),

        JSON_OBJECT(
            'client_id', NEW.client_id,
            'client_name', cliente_nombre_new,
            'sale_date', NEW.sale_date,
            'subtotal', NEW.subtotal,
            'tax_percentage', NEW.tax_percentage,
            'tax_amount', NEW.tax_amount,
            'total', NEW.total,
            'client_type', NEW.client_type
        ),

        (
            SELECT username
            FROM current_audit_user
            ORDER BY id DESC
            LIMIT 1
        )
    );

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sale_details`
--

CREATE TABLE `sale_details` (
  `id` int(11) NOT NULL,
  `sale_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `tax_rate` decimal(4,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sale_details`
--

INSERT INTO `sale_details` (`id`, `sale_id`, `product_id`, `quantity`, `unit_price`, `tax_rate`, `subtotal`) VALUES
(62, 4, 39, 1, 70.00, 0.00, 70.00),
(63, 4, 33, 1, 120.00, 0.00, 120.00),
(64, 4, 33, 2, 120.00, 0.00, 240.00),
(65, 30, 33, 1, 120.00, 0.00, 120.00),
(73, 35, 32, 2, 300.00, 0.00, 600.00),
(74, 35, 31, 1, 2500.00, 0.00, 2500.00),
(75, 36, 27, 1, 24.00, 1.00, 24.00),
(76, 37, 23, 4, 700.00, 10.00, 2800.00),
(78, 38, 27, 1, 24.00, 20.00, 24.00),
(79, 38, 12, 1, 600.00, 20.00, 600.00),
(80, 39, 12, 1, 600.00, 30.00, 600.00),
(85, 40, 39, 15, 300.00, 0.00, 4500.00),
(86, 40, 37, 10, 65.00, 0.00, 650.00),
(87, 40, 32, 25, 25.00, 0.00, 625.00),
(88, 40, 31, 8, 450.00, 0.00, 3600.00),
(113, 43, 1, 6, 500.00, 16.00, 3000.00),
(114, 43, 25, 3, 600.00, 16.00, 1800.00),
(115, 44, 31, 1, 2500.00, 0.00, 2500.00),
(116, 44, 40, 1, 3500.00, 0.00, 3500.00),
(117, 44, 26, 1, 23.50, 0.00, 23.50),
(118, 44, 24, 1, 500.00, 0.00, 500.00),
(119, 44, 39, 1, 70.00, 0.00, 70.00),
(120, 44, 35, 1, 90.00, 0.00, 90.00),
(121, 44, 11, 1, 500.00, 0.00, 500.00),
(122, 44, 30, 1, 8000.00, 0.00, 8000.00),
(123, 44, 2, 1, 600.00, 0.00, 600.00),
(124, 44, 29, 4, 15000.00, 0.00, 60000.00);

--
-- Disparadores `sale_details`
--
DELIMITER $$
CREATE TRIGGER `trg_sale_details_delete` AFTER DELETE ON `sale_details` FOR EACH ROW BEGIN

    DECLARE producto_nombre VARCHAR(255);

    SELECT name
    INTO producto_nombre
    FROM products
    WHERE id = OLD.product_id
    LIMIT 1;

    INSERT INTO audit_log (
        table_name,
        action_type,
        record_id,
        old_data,
        modified_by
    )
    VALUES (
        'sale_details',
        'DELETE',
        OLD.id,

        JSON_OBJECT(
            'sale_id', OLD.sale_id,
            'product_id', OLD.product_id,
            'product_name', producto_nombre,
            'quantity', OLD.quantity,
            'unit_price', OLD.unit_price,
            'subtotal', OLD.subtotal,
            'tax_rate', OLD.tax_rate
        ),

        (
            SELECT username
            FROM current_audit_user
            ORDER BY id DESC
            LIMIT 1
        )
    );

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_sale_details_insert` AFTER INSERT ON `sale_details` FOR EACH ROW BEGIN

    DECLARE producto_nombre VARCHAR(255);

    SELECT name
    INTO producto_nombre
    FROM products
    WHERE id = NEW.product_id
    LIMIT 1;

    INSERT INTO audit_log (
        table_name,
        action_type,
        record_id,
        new_data,
        modified_by
    )
    VALUES (
        'sale_details',
        'INSERT',
        NEW.id,

        JSON_OBJECT(
            'sale_id', NEW.sale_id,
            'product_id', NEW.product_id,
            'product_name', producto_nombre,
            'quantity', NEW.quantity,
            'unit_price', NEW.unit_price,
            'subtotal', NEW.subtotal,
            'tax_rate', NEW.tax_rate
        ),

        (
            SELECT username
            FROM current_audit_user
            ORDER BY id DESC
            LIMIT 1
        )
    );

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_sale_details_update` AFTER UPDATE ON `sale_details` FOR EACH ROW BEGIN

    DECLARE producto_old VARCHAR(255);
    DECLARE producto_new VARCHAR(255);

    SELECT name
    INTO producto_old
    FROM products
    WHERE id = OLD.product_id
    LIMIT 1;

    SELECT name
    INTO producto_new
    FROM products
    WHERE id = NEW.product_id
    LIMIT 1;

    INSERT INTO audit_log (
        table_name,
        action_type,
        record_id,
        old_data,
        new_data,
        modified_by
    )
    VALUES (
        'sale_details',
        'UPDATE',
        NEW.id,

        JSON_OBJECT(
            'sale_id', OLD.sale_id,
            'product_id', OLD.product_id,
            'product_name', producto_old,
            'quantity', OLD.quantity,
            'unit_price', OLD.unit_price,
            'subtotal', OLD.subtotal,
            'tax_rate', OLD.tax_rate
        ),

        JSON_OBJECT(
            'sale_id', NEW.sale_id,
            'product_id', NEW.product_id,
            'product_name', producto_new,
            'quantity', NEW.quantity,
            'unit_price', NEW.unit_price,
            'subtotal', NEW.subtotal,
            'tax_rate', NEW.tax_rate
        ),

        (
            SELECT username
            FROM current_audit_user
            ORDER BY id DESC
            LIMIT 1
        )
    );

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tax_regimes`
--

CREATE TABLE `tax_regimes` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tax_regimes`
--

INSERT INTO `tax_regimes` (`id`, `name`) VALUES
(1, 'General de Ley Personas Morales'),
(2, 'Régimen Simplificado de Confianza'),
(3, 'Régimen de Incorporación Fiscal'),
(4, 'Régimen de Actividades Empresariales y Profesionales'),
(5, 'Régimen de Sueldos y Salarios'),
(6, 'Régimen de Arrendamiento'),
(7, 'Régimen de Personas Morales con Fines no Lucrativos'),
(8, 'Régimen de Enajenación de Bienes'),
(9, 'Régimen de Dividendos'),
(10, 'Régimen de Plataformas Digitales');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `first_name`, `last_name`, `phone`, `email`, `created_at`) VALUES
(3, 'admin', '$2y$10$s1Xs.yQ5SXvgnBh0oX7w3e/M4pvRt9ufsCXTQ2mMoeIeoVu6Tg.pW', 'Admin', 'Invoice', '6631234567', 'l22211924@tectijuana.edu.mx', '2025-05-10 10:46:59'),
(4, 'jesus', '$2y$10$nH3qFu286z1OreJ5z9SgkOWR6D5qPwpK9Lyt5SqjEAH7H9UasE4Te', 'jesus', 'triana', '6641234567', 'jesus@gmail.com', '2025-05-11 11:49:53'),
(5, 'ladoblep', '$2y$10$gfRkLreaITxY9zI56O08JOg5YrLZZ6XgabcyYTOHhUGIRWvCErjLW', 'Peso', 'Pluma', '6641234567', 'pesopluma@gmail.com', '2025-05-11 12:26:08'),
(6, 'Infinity', '$2y$10$/l9DGMuqlW4Vf5MDJBt9sOH6IKCvgtIZZO/jaT9csuWimJGA8yV4u', 'ISBAC', 'CHAVEZ', '6611245500', 'isvac350@hotmail.com', '2026-02-09 18:46:17'),
(7, 'root', '$2y$10$8zK53sNt9gwgd5/E2AR2gOE8IKGU7qeWTsboJ1JtZFuv5xlDYES1e', 'JAKE', 'SMITH', '6611312541', 'user.root@master.net', '2026-04-29 21:22:17');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`id_audit`);

--
-- Indices de la tabla `business_types`
--
ALTER TABLE `business_types`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_email` (`email`),
  ADD UNIQUE KEY `unique_rfc` (`rfc`);

--
-- Indices de la tabla `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_business_type` (`business_type_id`),
  ADD KEY `fk_tax_regime` (`tax_regime_id`);

--
-- Indices de la tabla `current_audit_user`
--
ALTER TABLE `current_audit_user`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `invoice_number` (`invoice_number`),
  ADD KEY `sale_id` (`sale_id`);

--
-- Indices de la tabla `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `sales`
--
ALTER TABLE `sales`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `sale_details`
--
ALTER TABLE `sale_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sale_id` (`sale_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indices de la tabla `tax_regimes`
--
ALTER TABLE `tax_regimes`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `id_audit` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT de la tabla `business_types`
--
ALTER TABLE `business_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `clients`
--
ALTER TABLE `clients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `companies`
--
ALTER TABLE `companies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `current_audit_user`
--
ALTER TABLE `current_audit_user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `invoices`
--
ALTER TABLE `invoices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT de la tabla `sales`
--
ALTER TABLE `sales`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT de la tabla `sale_details`
--
ALTER TABLE `sale_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT de la tabla `tax_regimes`
--
ALTER TABLE `tax_regimes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `companies`
--
ALTER TABLE `companies`
  ADD CONSTRAINT `fk_business_type` FOREIGN KEY (`business_type_id`) REFERENCES `business_types` (`id`),
  ADD CONSTRAINT `fk_tax_regime` FOREIGN KEY (`tax_regime_id`) REFERENCES `tax_regimes` (`id`);

--
-- Filtros para la tabla `invoices`
--
ALTER TABLE `invoices`
  ADD CONSTRAINT `invoices_ibfk_1` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`);

--
-- Filtros para la tabla `sale_details`
--
ALTER TABLE `sale_details`
  ADD CONSTRAINT `sale_details_ibfk_1` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`),
  ADD CONSTRAINT `sale_details_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
