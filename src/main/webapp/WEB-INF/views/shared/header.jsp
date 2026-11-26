<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.pageTitle != null ? param.pageTitle : "Quản Lý Nhà Trọ - Admin"}</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --sidebar-width: 260px;
            --primary-color: #2563eb;
            --sidebar-bg: #0f172a;
            --bg-body: #f8fafc;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: var(--bg-body);
            color: #334155;
            min-height: 100vh;
        }
        /* Layout Structure */
        #wrapper {
            display: flex;
            min-height: 100vh;
        }
        #sidebar-wrapper {
            width: var(--sidebar-width);
            min-height: 100vh;
            background-color: var(--sidebar-bg);
            flex-shrink: 0;
            transition: all 0.25s ease;
        }
        #page-content-wrapper {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            min-width: 0;
        }
        .main-header {
            height: 64px;
            background: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            padding: 0 1.5rem;
        }
        .main-content {
            padding: 1.75rem 2rem;
            flex-grow: 1;
        }
        /* Sidebar styling */
        .sidebar-brand {
            height: 64px;
            display: flex;
            align-items: center;
            padding: 0 1.5rem;
            color: #ffffff;
            font-size: 1.15rem;
            font-weight: 700;
            letter-spacing: -0.025em;
            border-bottom: 1px solid #1e293b;
        }
        .sidebar-menu {
            list-style: none;
            padding: 1rem 0.75rem;
            margin: 0;
        }
        .sidebar-item {
            margin-bottom: 0.35rem;
        }
        .sidebar-link {
            display: flex;
            align-items: center;
            padding: 0.7rem 1rem;
            color: #94a3b8;
            text-decoration: none;
            border-radius: 0.5rem;
            font-weight: 500;
            font-size: 0.925rem;
            transition: all 0.2s ease;
        }
        .sidebar-link i {
            font-size: 1.15rem;
            margin-right: 0.85rem;
        }
        .sidebar-link:hover {
            color: #ffffff;
            background-color: #1e293b;
        }
        .sidebar-link.active {
            color: #ffffff;
            background-color: var(--primary-color);
            box-shadow: 0 4px 6px -1px rgba(37, 99, 235, 0.2);
        }
        /* Custom Cards & UI Components */
        .card-custom {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 0.75rem;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05);
            transition: box-shadow 0.2s ease;
        }
        .card-custom:hover {
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.07);
        }
        .table-custom thead th {
            background-color: #f8fafc;
            color: #64748b;
            font-weight: 600;
            font-size: 0.825rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            border-bottom: 1px solid #e2e8f0;
            padding: 0.85rem 1rem;
        }
        .table-custom tbody td {
            padding: 0.95rem 1rem;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
        }
        .badge-status {
            padding: 0.35rem 0.75rem;
            font-weight: 600;
            font-size: 0.785rem;
            border-radius: 9999px;
        }
    </style>
</head>
<body>
<div id="wrapper">


