CREATE DATABASE QuanlyNhatro;
GO

USE QuanlyNhatro
-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Invoices;
DROP TABLE IF EXISTS MaintenanceTickets;
DROP TABLE IF EXISTS Contracts;
DROP TABLE IF EXISTS RoomImages;
DROP TABLE IF EXISTS Rooms;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS ServiceRates;

-- 1. Users
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL DEFAULT 'CUSTOMER',
    is_active BIT NOT NULL DEFAULT 1
);

-- 2. Rooms
CREATE TABLE Rooms (
    room_id INT IDENTITY(1,1) PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL UNIQUE,
    base_price DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    max_occupants INT DEFAULT 2,
    amenities NVARCHAR(MAX),
    description NVARCHAR(MAX),
    is_active BIT NOT NULL DEFAULT 1
);

-- 3. RoomImages
CREATE TABLE RoomImages (
    image_id INT IDENTITY(1,1) PRIMARY KEY,
    room_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    region NVARCHAR(100) NOT NULL DEFAULT N'Khu A - Tầng 1',
    created_date DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_RoomImages_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(room_id) ON DELETE CASCADE
);

-- 4. Contracts
CREATE TABLE Contracts (
    contract_id INT IDENTITY(1,1) PRIMARY KEY,
    room_id INT NOT NULL,
    user_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    deposit_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    actual_end_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT FK_Contracts_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    CONSTRAINT FK_Contracts_Users FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 5. ServiceRates
CREATE TABLE ServiceRates (
    rate_id INT IDENTITY(1,1) PRIMARY KEY,
    electricity_per_kwh DECIMAL(10,2) NOT NULL,
    water_per_m3 DECIMAL(10,2) NOT NULL,
    internet_fee DECIMAL(10,2) NOT NULL,
    trash_fee DECIMAL(10,2) NOT NULL
);

-- 6. Invoices
CREATE TABLE Invoices (
    invoice_id INT IDENTITY(1,1) PRIMARY KEY,
    contract_id INT NOT NULL,
    billing_month INT NOT NULL,
    billing_year INT NOT NULL,
    old_elec INT NOT NULL,
    new_elec INT NOT NULL,
    old_water INT NOT NULL,
    new_water INT NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'UNPAID',
    CONSTRAINT FK_Invoices_Contracts FOREIGN KEY (contract_id) REFERENCES Contracts(contract_id)
);

-- 7. Transactions
CREATE TABLE Transactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    CONSTRAINT FK_Transactions_Invoices FOREIGN KEY (invoice_id) REFERENCES Invoices(invoice_id)
);

-- 8. MaintenanceTickets
CREATE TABLE MaintenanceTickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    room_id INT NOT NULL,
    user_id INT NOT NULL,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    created_date DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_MaintenanceTickets_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    CONSTRAINT FK_MaintenanceTickets_Users FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

IF NOT EXISTS (SELECT * FROM ServiceRates)
BEGIN
    INSERT INTO ServiceRates (electricity_per_kwh, water_per_m3, internet_fee, trash_fee)
    VALUES (3500.00, 25000.00, 100000.00, 50000.00);
END
-- 2. Thêm Tài khoản mẫu (Admin & Khách thuê)
IF NOT EXISTS (SELECT * FROM Users WHERE username = 'admin')
BEGIN
    INSERT INTO Users (username, password, full_name, phone, role, is_active)
    VALUES 
    ('admin', '123456', N'Chủ Nhà Trọ', '0901234567', 'ADMIN', 1),
    ('khach1', '123456', N'Nguyễn Văn An', '0912345678', 'CUSTOMER', 1),
    ('khach2', '123456', N'Trần Thị Bình', '0987654321', 'CUSTOMER', 1),
    ('khach3', '123456', N'Lê Hoàng Cường', '0933445566', 'CUSTOMER', 1),
    ('khach4', '123456', N'Phạm Minh Dung', '0977889900', 'CUSTOMER', 1);
END

-- 3. Thêm Phòng trọ mẫu
IF NOT EXISTS (SELECT * FROM Rooms WHERE room_number = 'P101')
BEGIN
    INSERT INTO Rooms (room_number, base_price, status, max_occupants, amenities, description, is_active)
    VALUES 
    ('P101', 3200000, 'AVAILABLE', 2, N'Máy lạnh, Gác lửng, Wifi', N'Phòng tầng 1, thoáng mát, giờ giấc tự do', 1),
    ('P102', 3500000, 'OCCUPIED', 2, N'Máy lạnh, Tủ lạnh, Gác lửng', N'Phòng góc nhiều ánh sáng tự nhiên', 1),
    ('P201', 4000000, 'OCCUPIED', 3, N'Full nội thất, Ban công, Máy giặt', N'Phòng tầng 2 có ban công riêng', 1),
    ('P202', 3800000, 'AVAILABLE', 2, N'Máy lạnh, Nóng lạnh, Kệ bếp, Wifi', N'Phòng tầng 2 yên tĩnh, phù hợp nhân viên văn phòng', 1),
    ('P301', 4500000, 'OCCUPIED', 3, N'Full nội thất, Ban công rộng, Smart TV', N'Phòng studio cao cấp tầng 3, view thoáng', 1);
END

-- 3b. Thêm Hình ảnh phòng mẫu (RoomImages)
IF NOT EXISTS (SELECT * FROM RoomImages)
BEGIN
    INSERT INTO RoomImages (room_id, image_url, region, created_date)
    VALUES
    (1, 'uploads/rooms/room-101-main.jpg', N'Khu A - Tầng 1', DATEADD(HOUR, -2, GETDATE())),
    (1, 'uploads/rooms/room-101-sub.jpg', N'Khu A - Tầng 1', DATEADD(DAY, -10, GETDATE())),
    (2, 'uploads/rooms/room-102-main.jpg', N'Khu A - Tầng 1', DATEADD(HOUR, -6, GETDATE())),
    (3, 'uploads/rooms/room-201-main.jpg', N'Khu A - Tầng 2', DATEADD(DAY, -1, GETDATE())),
    (3, 'uploads/rooms/room-studio-balcony.jpg', N'Khu Studio Cao Cấp', DATEADD(HOUR, -1, GETDATE())),
    (4, 'uploads/rooms/room-202-main.jpg', N'Khu A - Tầng 2', DATEADD(DAY, -5, GETDATE())),
    (5, 'uploads/rooms/room-301-main.jpg', N'Khu B - Tầng 3', DATEADD(HOUR, -3, GETDATE())),
    (5, 'uploads/rooms/room-301-kitchen.jpg', N'Khu B - Tầng 3', DATEADD(DAY, -12, GETDATE()));
END

-- 4. Thêm Hợp đồng mẫu
IF NOT EXISTS (SELECT * FROM Contracts WHERE status = 'ACTIVE')
BEGIN
    INSERT INTO Contracts (room_id, user_id, start_date, end_date, deposit_amount, status)
    VALUES 
    (2, 2, '2026-01-01', '2026-12-31', 3500000, 'ACTIVE'),
    (3, 3, '2026-03-01', '2027-02-28', 4000000, 'ACTIVE');
END

-- 5. Thêm Hóa đơn mẫu (Invoices)
IF NOT EXISTS (SELECT * FROM Invoices)
BEGIN
    INSERT INTO Invoices (contract_id, billing_month, billing_year, old_elec, new_elec, old_water, new_water, total_amount, payment_status)
    VALUES
    (1, 9, 2026, 100, 160, 10, 14, 3960000, 'PAID'),
    (1, 10, 2026, 160, 230, 14, 19, 4020000, 'PAID'),
    (1, 11, 2026, 230, 295, 19, 23, 3977500, 'UNPAID');
END

-- 6. Thêm Giao dịch thanh toán mẫu (Transactions)
IF NOT EXISTS (SELECT * FROM Transactions)
BEGIN
    INSERT INTO Transactions (invoice_id, payment_method, amount, transaction_date, status)
    VALUES
    (1, 'VIETQR', 3960000, '2026-09-28 14:20:00', 'SUCCESS'),
    (2, 'CASH', 4020000, '2026-10-29 09:15:00', 'SUCCESS');
END

-- 7. Thêm Phiếu báo hỏng mẫu (MaintenanceTickets)
IF NOT EXISTS (SELECT * FROM MaintenanceTickets)
BEGIN
    INSERT INTO MaintenanceTickets (room_id, user_id, title, description, priority, status, created_date)
    VALUES
    (2, 2, N'Máy lạnh chảy nước dàn lạnh', N'Máy lạnh Panasonic trong phòng P102 bị nhỏ nước xuống sàn khi bật dưới 25 độ.', 'MEDIUM', 'IN_PROGRESS', '2026-11-15 08:30:00'),
    (2, 2, N'Bóng đèn nhà vệ sinh bị chập chờn', N'Bóng đèn LED trong nhà vệ sinh lúc sáng lúc tắt, nhờ chủ trọ thay giúp.', 'LOW', 'RESOLVED', '2026-10-20 19:00:00'),
    (3, 3, N'Rò rỉ vòi nước bồn rửa chén', N'Cổ vòi nước bồn rửa bị rỉ nước liên tục, cần thợ siết lại van hoặc thay ron.', 'HIGH', 'OPEN', '2026-11-18 10:45:00');
END
GO