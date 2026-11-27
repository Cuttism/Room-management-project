CREATE DATABASE QuanlyNhatro;
GO

USE QuanlyNhatro;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Invoices;
DROP TABLE IF EXISTS MaintenanceTickets;
DROP TABLE IF EXISTS Contracts;
DROP TABLE IF EXISTS RoomImages;
DROP TABLE IF EXISTS Rooms;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS ServiceRates;
GO

-- 1. Users
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL DEFAULT 'CUSTOMER',
    is_active BIT NOT NULL DEFAULT 1,
    CONSTRAINT CHK_Users_Role CHECK (role IN ('ADMIN', 'CUSTOMER'))
);
CREATE UNIQUE INDEX UQ_Users_Phone ON Users(phone) WHERE phone IS NOT NULL AND phone <> '';

-- 2. Rooms
CREATE TABLE Rooms (
    room_id INT IDENTITY(1,1) PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL UNIQUE,
    base_price DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    max_occupants INT DEFAULT 2,
    amenities NVARCHAR(MAX),
    description NVARCHAR(MAX),
    is_active BIT NOT NULL DEFAULT 1,
    CONSTRAINT CHK_Rooms_Price CHECK (base_price > 0),
    CONSTRAINT CHK_Rooms_Occupants CHECK (max_occupants BETWEEN 1 AND 20),
    CONSTRAINT CHK_Rooms_Status CHECK (status IN ('AVAILABLE', 'OCCUPIED', 'MAINTENANCE'))
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
    CONSTRAINT FK_Contracts_Users FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT CHK_Contracts_Dates CHECK (end_date > start_date),
    CONSTRAINT CHK_Contracts_Deposit CHECK (deposit_amount >= 0),
    CONSTRAINT CHK_Contracts_Status CHECK (status IN ('ACTIVE', 'TERMINATED'))
);
CREATE UNIQUE INDEX UQ_Contracts_ActiveRoom ON Contracts(room_id) WHERE status = 'ACTIVE';

-- 5. ServiceRates
CREATE TABLE ServiceRates (
    rate_id INT IDENTITY(1,1) PRIMARY KEY,
    electricity_per_kwh DECIMAL(10,2) NOT NULL,
    water_per_m3 DECIMAL(10,2) NOT NULL,
    internet_fee DECIMAL(10,2) NOT NULL,
    trash_fee DECIMAL(10,2) NOT NULL,
    CONSTRAINT CHK_ServiceRates_NonNegative CHECK (electricity_per_kwh >= 0 AND water_per_m3 >= 0 AND internet_fee >= 0 AND trash_fee >= 0)
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
    CONSTRAINT FK_Invoices_Contracts FOREIGN KEY (contract_id) REFERENCES Contracts(contract_id),
    CONSTRAINT UQ_Invoices_Period UNIQUE (contract_id, billing_month, billing_year),
    CONSTRAINT CHK_Invoices_MonthYear CHECK (billing_month BETWEEN 1 AND 12 AND billing_year >= 2000),
    CONSTRAINT CHK_Invoices_Readings CHECK (old_elec >= 0 AND new_elec >= old_elec AND old_water >= 0 AND new_water >= old_water),
    CONSTRAINT CHK_Invoices_Total CHECK (total_amount >= 0),
    CONSTRAINT CHK_Invoices_Status CHECK (payment_status IN ('UNPAID', 'PENDING', 'PAID'))
);

-- 7. Transactions
CREATE TABLE Transactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    CONSTRAINT FK_Transactions_Invoices FOREIGN KEY (invoice_id) REFERENCES Invoices(invoice_id),
    CONSTRAINT CHK_Transactions_Amount CHECK (amount >= 0),
    CONSTRAINT CHK_Transactions_Status CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED'))
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
    CONSTRAINT FK_MaintenanceTickets_Users FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT CHK_Tickets_Priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH')),
    CONSTRAINT CHK_Tickets_Status CHECK (status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CANCELLED'))
);
GO

-- ============================================================
-- SEED DATA (13 Users, 14 Rooms, 12 Contracts, 36 Invoices, 32 Transactions, 8 Tickets)
-- ============================================================

-- 1. Đơn giá dịch vụ
INSERT INTO ServiceRates (electricity_per_kwh, water_per_m3, internet_fee, trash_fee)
VALUES (3500.00, 25000.00, 100000.00, 50000.00);

-- 2. Tài khoản Admin & 12 Khách thuê (Mật khẩu mặc định: 123456 đã mã hóa PBKDF2-HMAC-SHA256)
INSERT INTO Users (email, password, full_name, phone, role, is_active) VALUES
('admin@nhatro.com',    'pbkdf2$65536$jes8UcCw38VeGkDFWpYA0Q==$HBboQgfOGP24N/Tjy81kyqKGBtoiUVG8kKcMKugZI2I=', N'Chủ Nhà Trọ',       '0901234567', 'ADMIN',    1),
('an.nguyen@gmail.com', 'pbkdf2$65536$jes8UcCw38VeGkDFWpYA0Q==$HBboQgfOGP24N/Tjy81kyqKGBtoiUVG8kKcMKugZI2I=', N'Nguyễn Văn An',     '0912345678', 'CUSTOMER', 1),
('binh.tran@gmail.com', 'pbkdf2$65536$jes8UcCw38VeGkDFWpYA0Q==$HBboQgfOGP24N/Tjy81kyqKGBtoiUVG8kKcMKugZI2I=', N'Trần Thị Bình',     '0987654321', 'CUSTOMER', 1),
('cuong.le@gmail.com',  'pbkdf2$65536$jes8UcCw38VeGkDFWpYA0Q==$HBboQgfOGP24N/Tjy81kyqKGBtoiUVG8kKcMKugZI2I=', N'Lê Hoàng Cường',    '0933445566', 'CUSTOMER', 1),
('dung.pham@gmail.com', 'pbkdf2$65536$jes8UcCw38VeGkDFWpYA0Q==$HBboQgfOGP24N/Tjy81kyqKGBtoiUVG8kKcMKugZI2I=', N'Phạm Minh Dung',    '0977889900', 'CUSTOMER', 1),
('hoanh@gmail.com',     'pbkdf2$65536$jes8UcCw38VeGkDFWpYA0Q==$HBboQgfOGP24N/Tjy81kyqKGBtoiUVG8kKcMKugZI2I=', N'Nguyễn Hoàng Hoa',  '0202040502', 'CUSTOMER', 1),
('hieu.vo@gmail.com',   'pbkdf2$65536$jes8UcCw38VeGkDFWpYA0Q==$HBboQgfOGP24N/Tjy81kyqKGBtoiUVG8kKcMKugZI2I=', N'Võ Minh Hiếu',      '0914223344', 'CUSTOMER', 1),
('lan.dang@gmail.com',  'pbkdf2$65536$jes8UcCw38VeGkDFWpYA0Q==$HBboQgfOGP24N/Tjy81kyqKGBtoiUVG8kKcMKugZI2I=', N'Đặng Ngọc Lan',     '0915334455', 'CUSTOMER', 1),
('khanh.bui@gmail.com', 'pbkdf2$65536$jes8UcCw38VeGkDFWpYA0Q==$HBboQgfOGP24N/Tjy81kyqKGBtoiUVG8kKcMKugZI2I=', N'Bùi Quốc Khánh',    '0916445566', 'CUSTOMER', 1),
('mai.do@gmail.com',    'pbkdf2$65536$jes8UcCw38VeGkDFWpYA0Q==$HBboQgfOGP24N/Tjy81kyqKGBtoiUVG8kKcMKugZI2I=', N'Đỗ Tuyết Mai',      '0917556677', 'CUSTOMER', 1),
('nam.ho@gmail.com',    'pbkdf2$65536$jes8UcCw38VeGkDFWpYA0Q==$HBboQgfOGP24N/Tjy81kyqKGBtoiUVG8kKcMKugZI2I=', N'Hồ Hải Nam',        '0918667788', 'CUSTOMER', 1),
('thao.ly@gmail.com',   'pbkdf2$65536$jes8UcCw38VeGkDFWpYA0Q==$HBboQgfOGP24N/Tjy81kyqKGBtoiUVG8kKcMKugZI2I=', N'Lý Thanh Thảo',     '0919778899', 'CUSTOMER', 1),
('tuan.ngo@gmail.com',  'pbkdf2$65536$jes8UcCw38VeGkDFWpYA0Q==$HBboQgfOGP24N/Tjy81kyqKGBtoiUVG8kKcMKugZI2I=', N'Ngô Anh Tuấn',      '0921889900', 'CUSTOMER', 1);

-- 3. Danh sách 14 Phòng trọ (11 phòng OCCUPIED đang có hợp đồng ACTIVE, 3 phòng AVAILABLE)
INSERT INTO Rooms (room_number, base_price, status, max_occupants, amenities, description, is_active) VALUES
('P101', 3200000, 'AVAILABLE', 2, N'Máy lạnh, Gác lửng, Wifi',                        N'Phòng tầng 1, thoáng mát, giờ giấc tự do', 1),
('P102', 3500000, 'OCCUPIED',  2, N'Máy lạnh, Tủ lạnh, Gác lửng',                     N'Phòng góc nhiều ánh sáng tự nhiên', 1),
('P103', 3300000, 'OCCUPIED',  2, N'Máy lạnh, Gác lửng, Nóng lạnh, Wifi',             N'Phòng tầng 1 thoáng mát, gần khu để xe', 1),
('P104', 3400000, 'OCCUPIED',  2, N'Máy lạnh, Tủ lạnh, Gác lửng, Wifi',               N'Phòng tầng 1 có cửa sổ lớn đón gió tự nhiên', 1),
('P201', 4000000, 'OCCUPIED',  3, N'Full nội thất, Ban công, Máy giặt',               N'Phòng tầng 2 có ban công riêng', 1),
('P202', 3800000, 'OCCUPIED',  2, N'Máy lạnh, Nóng lạnh, Kệ bếp, Wifi',               N'Phòng tầng 2 yên tĩnh, phù hợp nhân viên văn phòng', 1),
('P203', 3900000, 'OCCUPIED',  2, N'Máy lạnh, Nóng lạnh, Kệ bếp, Ban công',           N'Phòng tầng 2 có kệ bếp nấu ăn riêng và ban công phơi đồ', 1),
('P204', 4100000, 'OCCUPIED',  3, N'Máy lạnh, Tủ lạnh, Máy giặt, Ban công',           N'Phòng góc tầng 2 rộng rãi, đầy đủ nội thất cơ bản', 1),
('P301', 4500000, 'OCCUPIED',  3, N'Full nội thất, Ban công rộng, Smart TV',          N'Phòng studio cao cấp tầng 3, view thoáng', 1),
('P302', 4300000, 'OCCUPIED',  3, N'Full nội thất, Giường nệm, Tủ quần áo, Ban công', N'Phòng tầng 3 yên tĩnh, view nhìn ra công viên nội khu', 1),
('P303', 4600000, 'OCCUPIED',  3, N'Full nội thất, Smart TV, Tủ lạnh, Máy giặt riêng',N'Phòng Studio tầng 3 thiết kế hiện đại, nội thất cao cấp', 1),
('P304', 4400000, 'AVAILABLE', 3, N'Full nội thất, Ban công, Kệ bếp, Máy lạnh',       N'Phòng tầng 3 mới sơn sửa, sẵn sàng dọn vào ở ngay', 1),
('P401', 5000000, 'OCCUPIED',  4, N'Studio Penthouse, Ban công sân thượng, Full NT',  N'Phòng Penthouse tầng 4 diện tích lớn, sân thượng thoáng đãng', 1),
('P402', 4800000, 'AVAILABLE', 3, N'Full nội thất, Ban công rộng, Bếp từ, Máy giặt',  N'Phòng Studio cao cấp tầng 4, ánh sáng tự nhiên cả ngày', 1);

-- 4. Hình ảnh cho toàn bộ 14 phòng
INSERT INTO RoomImages (room_id, image_url, region, created_date) VALUES
(1,  'uploads/rooms/room-101-main.jpg',       N'Khu A - Tầng 1',     DATEADD(HOUR, -2, GETDATE())),
(1,  'uploads/rooms/room-101-sub.jpg',        N'Khu A - Tầng 1',     DATEADD(DAY, -10, GETDATE())),
(2,  'uploads/rooms/room-102-main.jpg',       N'Khu A - Tầng 1',     DATEADD(HOUR, -6, GETDATE())),
(3,  'uploads/rooms/room-101-main.jpg',       N'Khu A - Tầng 1',     DATEADD(DAY, -2, GETDATE())),
(4,  'uploads/rooms/room-102-main.jpg',       N'Khu A - Tầng 1',     DATEADD(DAY, -3, GETDATE())),
(5,  'uploads/rooms/room-201-main.jpg',       N'Khu A - Tầng 2',     DATEADD(DAY, -1, GETDATE())),
(6,  'uploads/rooms/room-202-main.jpg',       N'Khu A - Tầng 2',     DATEADD(DAY, -5, GETDATE())),
(7,  'uploads/rooms/room-201-main.jpg',       N'Khu A - Tầng 2',     DATEADD(DAY, -4, GETDATE())),
(8,  'uploads/rooms/room-202-main.jpg',       N'Khu A - Tầng 2',     DATEADD(DAY, -6, GETDATE())),
(9,  'uploads/rooms/room-301-main.jpg',       N'Khu B - Tầng 3',     DATEADD(HOUR, -3, GETDATE())),
(9,  'uploads/rooms/room-301-kitchen.jpg',    N'Khu B - Tầng 3',     DATEADD(DAY, -12, GETDATE())),
(10, 'uploads/rooms/room-301-main.jpg',       N'Khu B - Tầng 3',     DATEADD(DAY, -7, GETDATE())),
(11, 'uploads/rooms/room-301-kitchen.jpg',    N'Khu B - Tầng 3',     DATEADD(DAY, -8, GETDATE())),
(12, 'uploads/rooms/room-301-main.jpg',       N'Khu B - Tầng 3',     DATEADD(DAY, -2, GETDATE())),
(13, 'uploads/rooms/room-studio-balcony.jpg', N'Khu Studio Cao Cấp', DATEADD(HOUR, -1, GETDATE())),
(14, 'uploads/rooms/room-studio-balcony.jpg', N'Khu Studio Cao Cấp', DATEADD(HOUR, -5, GETDATE()));

-- 5. Danh sách 12 Hợp đồng (11 ACTIVE tương ứng 11 phòng OCCUPIED + 1 TERMINATED cho P101)
INSERT INTO Contracts (room_id, user_id, start_date, end_date, deposit_amount, actual_end_date, status) VALUES
(2,  2,  '2026-01-01', '2026-12-31', 3500000, NULL,         'ACTIVE'),     -- #1: P102 - Nguyễn Văn An
(5,  3,  '2026-03-01', '2027-02-28', 4000000, NULL,         'ACTIVE'),     -- #2: P201 - Trần Thị Bình
(6,  4,  '2026-02-01', '2027-01-31', 3800000, NULL,         'ACTIVE'),     -- #3: P202 - Lê Hoàng Cường
(9,  5,  '2026-02-15', '2027-02-14', 4500000, NULL,         'ACTIVE'),     -- #4: P301 - Phạm Minh Dung
(3,  6,  '2026-03-01', '2027-02-28', 3300000, NULL,         'ACTIVE'),     -- #5: P103 - Nguyễn Hoàng Hoa
(4,  7,  '2026-03-10', '2027-03-09', 3400000, NULL,         'ACTIVE'),     -- #6: P104 - Võ Minh Hiếu
(7,  8,  '2026-04-01', '2027-03-31', 3900000, NULL,         'ACTIVE'),     -- #7: P203 - Đặng Ngọc Lan
(8,  9,  '2026-04-15', '2027-04-14', 4100000, NULL,         'ACTIVE'),     -- #8: P204 - Bùi Quốc Khánh
(10, 10, '2026-05-01', '2027-04-30', 4300000, NULL,         'ACTIVE'),     -- #9: P302 - Đỗ Tuyết Mai
(11, 11, '2026-05-15', '2027-05-14', 4600000, NULL,         'ACTIVE'),     -- #10: P303 - Hồ Hải Nam
(13, 12, '2026-06-01', '2027-05-31', 5000000, NULL,         'ACTIVE'),     -- #11: P401 - Lý Thanh Thảo
(1,  13, '2026-01-01', '2026-12-31', 3200000, '2026-10-31', 'TERMINATED'); -- #12: P101 - Ngô Anh Tuấn (Đã thanh lý)

-- 6. Hóa đơn hàng tháng cho cả 12 Hợp đồng (khớp chính xác chỉ số điện nước liên hoàn & công thức giá phòng + dịch vụ)
INSERT INTO Invoices (contract_id, billing_month, billing_year, old_elec, new_elec, old_water, new_water, total_amount, payment_status) VALUES
-- Contract 1 (P102 - 3,500,000)
(1,  8, 2026,  40, 100,  6, 10, 3960000, 'PAID'),
(1,  9, 2026, 100, 160, 10, 14, 3960000, 'PAID'),
(1, 10, 2026, 160, 230, 14, 19, 4020000, 'PAID'),
(1, 11, 2026, 230, 295, 19, 23, 3977500, 'UNPAID'),
-- Contract 2 (P201 - 4,000,000)
(2,  9, 2026,  50, 120,  8, 12, 4495000, 'PAID'),
(2, 10, 2026, 120, 195, 12, 17, 4537500, 'PAID'),
(2, 11, 2026, 195, 260, 17, 21, 4477500, 'UNPAID'),
-- Contract 3 (P202 - 3,800,000)
(3,  9, 2026,  80, 130,  8, 11, 4200000, 'PAID'),
(3, 10, 2026, 130, 185, 11, 15, 4242500, 'PAID'),
(3, 11, 2026, 185, 240, 15, 19, 4242500, 'PAID'),
-- Contract 4 (P301 - 4,500,000)
(4,  9, 2026, 110, 170, 12, 16, 4960000, 'PAID'),
(4, 10, 2026, 170, 235, 16, 20, 4977500, 'PAID'),
(4, 11, 2026, 235, 295, 20, 24, 4960000, 'PENDING'),
-- Contract 5 (P103 - 3,300,000)
(5,  9, 2026,  60, 105,  5,  8, 3682500, 'PAID'),
(5, 10, 2026, 105, 150,  8, 11, 3682500, 'PAID'),
(5, 11, 2026, 150, 200, 11, 14, 3700000, 'PAID'),
-- Contract 6 (P104 - 3,400,000)
(6,  9, 2026,  45,  90,  6,  9, 3782500, 'PAID'),
(6, 10, 2026,  90, 140,  9, 13, 3825000, 'PAID'),
(6, 11, 2026, 140, 190, 13, 16, 3800000, 'UNPAID'),
-- Contract 7 (P203 - 3,900,000)
(7,  9, 2026,  95, 145, 10, 13, 4300000, 'PAID'),
(7, 10, 2026, 145, 200, 13, 17, 4342500, 'PAID'),
(7, 11, 2026, 200, 255, 17, 21, 4342500, 'PAID'),
-- Contract 8 (P204 - 4,100,000)
(8,  9, 2026,  70, 125,  7, 11, 4542500, 'PAID'),
(8, 10, 2026, 125, 180, 11, 15, 4542500, 'PAID'),
(8, 11, 2026, 180, 230, 15, 19, 4525000, 'PENDING'),
-- Contract 9 (P302 - 4,300,000)
(9,  9, 2026, 100, 160,  9, 13, 4760000, 'PAID'),
(9, 10, 2026, 160, 220, 13, 17, 4760000, 'PAID'),
(9, 11, 2026, 220, 280, 17, 22, 4785000, 'PAID'),
-- Contract 10 (P303 - 4,600,000)
(10, 9, 2026, 120, 185, 11, 15, 5077500, 'PAID'),
(10,10, 2026, 185, 250, 15, 20, 5102500, 'PAID'),
(10,11, 2026, 250, 315, 20, 25, 5102500, 'UNPAID'),
-- Contract 11 (P401 - 5,000,000)
(11, 9, 2026, 150, 220, 14, 19, 5520000, 'PAID'),
(11,10, 2026, 220, 290, 19, 24, 5520000, 'PAID'),
(11,11, 2026, 290, 360, 24, 29, 5520000, 'PAID'),
-- Contract 12 (P101 - 3,200,000 - Đã thanh lý cuối tháng 10/2026)
(12, 9, 2026,  50,  95,  4,  7, 3582500, 'PAID'),
(12,10, 2026,  95, 145,  7, 10, 3600000, 'PAID');

-- 7. Giao dịch thanh toán (Transactions) khớp 1-1 với tất cả Hóa đơn PAID và PENDING
INSERT INTO Transactions (invoice_id, payment_method, amount, transaction_date, status)
SELECT invoice_id,
       CASE
           WHEN contract_id = 12 AND billing_month = 10 THEN 'DEPOSIT_OFFSET'
           WHEN payment_status = 'PENDING' THEN 'VIETQR'
           WHEN invoice_id % 3 = 0 THEN 'CASH'
           ELSE 'VIETQR'
       END,
       total_amount,
       DATEFromParts(billing_year, billing_month, 28),
       CASE WHEN payment_status = 'PAID' THEN 'SUCCESS' ELSE 'PENDING' END
FROM Invoices
WHERE payment_status IN ('PAID', 'PENDING');

-- 8. Phiếu báo hỏng & bảo trì (MaintenanceTickets) khớp với Phòng và Khách đang thuê
INSERT INTO MaintenanceTickets (room_id, user_id, title, description, priority, status, created_date) VALUES
(2,  2,  N'Máy lạnh chảy nước dàn lạnh',       N'Máy lạnh Panasonic trong phòng P102 bị nhỏ nước xuống sàn khi bật dưới 25 độ.', 'MEDIUM', 'IN_PROGRESS', '2026-11-15 08:30:00'),
(2,  2,  N'Bóng đèn nhà vệ sinh bị chập chờn', N'Bóng đèn LED trong nhà vệ sinh lúc sáng lúc tắt, nhờ chủ trọ thay giúp.',      'LOW',    'RESOLVED',    '2026-10-20 19:00:00'),
(5,  3,  N'Rò rỉ vòi nước bồn rửa chén',       N'Cổ vòi nước bồn rửa bị rỉ nước liên tục, cần thợ siết lại van hoặc thay ron.', 'HIGH',   'OPEN',        '2026-11-18 10:45:00'),
(6,  4,  N'Bình nóng lạnh không lên nguồn',    N'Đèn báo bình nóng lạnh Ariston không sáng khi bật công tắc.',                  'HIGH',   'OPEN',        '2026-11-24 09:15:00'),
(9,  5,  N'Khóa cửa ban công bị kẹt',          N'Tay nắm cửa lùa ra ban công tầng 3 bị cứng, khó khóa chốt.',                   'MEDIUM', 'IN_PROGRESS', '2026-11-22 14:20:00'),
(4,  7,  N'Wifi trong phòng sóng yếu',         N'Bộ phát Wifi hành lang tầng 1 chập chờn vào buổi tối.',                        'LOW',    'RESOLVED',    '2026-11-10 20:30:00'),
(8,  9,  N'Ống thoát nước máy giặt bị rỉ',     N'Khớp nối ống xả nước máy giặt ngoài ban công bị tuột nhẹ.',                    'MEDIUM', 'OPEN',        '2026-11-25 17:45:00'),
(13, 12, N'Thay bóng đèn LED bàn bếp',         N'Đèn LED dưới tủ bếp bị cháy 1 bóng, nhờ kỹ thuật thay giúp.',                  'LOW',    'RESOLVED',    '2026-11-12 11:00:00');
GO
