-- =============================================================================
-- DATABASE DESIGN TERM PROJECT (PHASE 3) - E24-Class 5, Group 5
-- Topic: Multi-Project Construction Enterprise Database System (A34Build)
-- Target DBMS: MySQL 8.0+ (Storage Engine: InnoDB, Charset: utf8mb4)
-- File 03: Data Manipulation Language (DML) - Realistic Sample Data Population
-- =============================================================================

USE A34Build_DB;

-- Disable FK checks temporarily for bulk load, then re-enable
SET FOREIGN_KEY_CHECKS = 0;

-- Clean existing data in reverse dependency order
TRUNCATE TABLE EMERGENCY_DISPATCH_LOG;
TRUNCATE TABLE INCIDENT_REPORT;
TRUNCATE TABLE SAFETY_INSPECTION;
TRUNCATE TABLE SUBCONTRACT;
TRUNCATE TABLE SUBCONTRACTOR;
TRUNCATE TABLE MATERIAL_USAGE;
TRUNCATE TABLE DELIVERY_DISPATCH;
TRUNCATE TABLE SITE_INVENTORY;
TRUNCATE TABLE PO_ITEM;
TRUNCATE TABLE PURCHASE_ORDER;
TRUNCATE TABLE MATERIAL;
TRUNCATE TABLE SUPPLIER_CATEGORY;
TRUNCATE TABLE SUPPLIER_PHONE;
TRUNCATE TABLE SUPPLIER;
TRUNCATE TABLE EQUIPMENT_DEPLOYMENT;
TRUNCATE TABLE MAINTENANCE_RECORD;
TRUNCATE TABLE EQUIPMENT;
TRUNCATE TABLE WORKS_ON_TASK;
TRUNCATE TABLE PRECEDES;
TRUNCATE TABLE TASK;
TRUNCATE TABLE PROJECT_PHASE;
TRUNCATE TABLE PROJECT_SITE;
TRUNCATE TABLE PROJECT;
TRUNCATE TABLE CLIENT_PHONE;
TRUNCATE TABLE CLIENT;
TRUNCATE TABLE DEPENDENT;
TRUNCATE TABLE EMPLOYEE_CERTIFICATION;
TRUNCATE TABLE EMPLOYEE_PHONE;
TRUNCATE TABLE EMPLOYEE;
TRUNCATE TABLE DEPARTMENT;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- 1. SUBSYSTEM 1: ORGANIZATION & HUMAN RESOURCES
-- =============================================================================

-- 1.1 Insert DEPARTMENT (HeadEmpID initially NULL to resolve circular FK)
INSERT INTO DEPARTMENT (DeptID, DeptName, OfficeLocation, Budget, HeadEmpID) VALUES
('DEP01', 'Executive Board', 'Building A, Floor 10, Hanoi HQ', 5000000000.00, NULL),
('DEP02', 'Project Engineering', 'Building A, Floor 8, Hanoi HQ', 12000000000.00, NULL),
('DEP03', 'Site Operations & Construction', 'Building B, Floor 3, Hanoi HQ', 25000000000.00, NULL),
('DEP04', 'Procurement & Supply Chain', 'Building B, Floor 2, Hanoi HQ', 8000000000.00, NULL),
('DEP05', 'HSE & Quality Assurance', 'Building A, Floor 5, Hanoi HQ', 4500000000.00, NULL);

-- 1.2 Insert EMPLOYEE
INSERT INTO EMPLOYEE (EmpID, FirstName, MiddleName, LastName, Street, Ward, District, City, DOB, HireDate, Salary, JobTitle, Email, DeptID, SupervisorID) VALUES
('EMP001', 'Minh', 'Anh', 'Le', '102 Nguyen Trai', 'Thuong Dinh', 'Thanh Xuan', 'Hanoi', '1980-04-15', '2012-03-01', 85000000.00, 'General Director', 'minh.le@a34build.vn', 'DEP01', NULL),
('EMP002', 'Trinh', 'Trong', 'Ung', '45 Tran Phu', 'Van Quan', 'Ha Dong', 'Hanoi', '1984-08-20', '2014-06-15', 55000000.00, 'Chief Technical Officer', 'trinh.ung@a34build.vn', 'DEP02', 'EMP001'),
('EMP003', 'Quan', 'Anh', 'Nguyen', '88 Hoang Quoc Viet', 'Nghia Do', 'Cau Giay', 'Hanoi', '1986-11-10', '2015-09-01', 48000000.00, 'Senior Project Director', 'quan.nguyen@a34build.vn', 'DEP03', 'EMP001'),
('EMP004', 'Hai', 'Dang', 'Nguyen', '12 Chua Boc', 'Quang Trung', 'Dong Da', 'Hanoi', '1985-02-18', '2016-01-10', 45000000.00, 'Project Director - Infrastructure', 'hai.nguyen@a34build.vn', 'DEP03', 'EMP001'),
('EMP005', 'Hoa', 'Thi', 'Pham', '73 Kim Ma', 'Ngoc Khanh', 'Ba Dinh', 'Hanoi', '1989-07-25', '2017-04-01', 38000000.00, 'Project Director - Residential', 'hoa.pham@a34build.vn', 'DEP03', 'EMP001'),
('EMP006', 'Dung', 'Van', 'Tran', '19 Le Van Luong', 'Nhan Chinh', 'Thanh Xuan', 'Hanoi', '1990-03-12', '2018-05-20', 32000000.00, 'Procurement Manager', 'dung.tran@a34build.vn', 'DEP04', 'EMP001'),
('EMP007', 'Tuan', 'Anh', 'Hoang', '56 Pham Van Dong', 'Mai Dich', 'Cau Giay', 'Hanoi', '1991-09-05', '2018-08-15', 30000000.00, 'HSE Director', 'tuan.hoang@a34build.vn', 'DEP05', 'EMP001'),
('EMP008', 'Nam', 'Hoang', 'Vu', '34 Dai Co Viet', 'Le Dai Hanh', 'Hai Ba Trung', 'Hanoi', '1992-12-01', '2019-02-01', 25000000.00, 'Site Lead Engineer', 'nam.vu@a34build.vn', 'DEP03', 'EMP003'),
('EMP009', 'Son', 'Tung', 'Do', '82 Bach Mai', 'Bach Mai', 'Hai Ba Trung', 'Hanoi', '1993-05-14', '2019-07-10', 24000000.00, 'Structural Engineer', 'son.do@a34build.vn', 'DEP02', 'EMP002'),
('EMP010', 'Bao', 'Quoc', 'Dinh', '67 Nguyen Xi', 'Phuong 26', 'Binh Thanh', 'HCMC', '1988-10-30', '2020-01-15', 22000000.00, 'Master Heavy Crane Operator', 'bao.dinh@a34build.vn', 'DEP03', 'EMP008'),
('EMP011', 'Khang', 'Huu', 'Ngo', '15 Vo Van Kiet', 'An Hai Bac', 'Son Tra', 'Da Nang', '1994-01-22', '2020-03-01', 20000000.00, 'Excavator & Earthwork Operator', 'khang.ngo@a34build.vn', 'DEP03', 'EMP008'),
('EMP012', 'Thang', 'Duc', 'Bui', '92 Truong Chinh', 'Khuong Mai', 'Thanh Xuan', 'Hanoi', '1995-06-18', '2021-04-12', 18000000.00, 'Site Safety Inspector', 'thang.bui@a34build.vn', 'DEP05', 'EMP007'),
('EMP013', 'Long', 'Thanh', 'Phan', '28 Lang Ha', 'Thanh Cong', 'Ba Dinh', 'Hanoi', '1996-08-09', '2021-09-01', 16000000.00, 'Warehouse & Inventory Officer', 'long.phan@a34build.vn', 'DEP04', 'EMP006'),
('EMP014', 'Huy', 'Quang', 'Mai', '144 Xuan Thuy', 'Dich Vong Hau', 'Cau Giay', 'Hanoi', '1997-11-28', '2022-02-15', 14000000.00, 'Site Electrician', 'huy.mai@a34build.vn', 'DEP03', 'EMP008'),
('EMP015', 'Tung', 'Van', 'Doan', '39 Giai Phong', 'Dong Tam', 'Hai Ba Trung', 'Hanoi', '1998-04-03', '2022-06-01', 13500000.00, 'Construction Technician', 'tung.doan@a34build.vn', 'DEP03', 'EMP008');

-- Update Department Heads now that employees exist
UPDATE DEPARTMENT SET HeadEmpID = 'EMP001' WHERE DeptID = 'DEP01';
UPDATE DEPARTMENT SET HeadEmpID = 'EMP002' WHERE DeptID = 'DEP02';
UPDATE DEPARTMENT SET HeadEmpID = 'EMP003' WHERE DeptID = 'DEP03';
UPDATE DEPARTMENT SET HeadEmpID = 'EMP006' WHERE DeptID = 'DEP04';
UPDATE DEPARTMENT SET HeadEmpID = 'EMP007' WHERE DeptID = 'DEP05';

-- 1.3 Insert EMPLOYEE_PHONE
INSERT INTO EMPLOYEE_PHONE (EmpID, PhoneNumber) VALUES
('EMP001', '0912345678'), ('EMP001', '0987654321'),
('EMP002', '0903112233'),
('EMP003', '0918445566'), ('EMP003', '0945998877'),
('EMP004', '0932223344'),
('EMP005', '0988776655'),
('EMP006', '0977665544'),
('EMP007', '0966554433'),
('EMP008', '0944332211'),
('EMP009', '0933221100'),
('EMP010', '0911998877'),
('EMP011', '0922887766'),
('EMP012', '0933776655'),
('EMP013', '0944665544'),
('EMP014', '0955554433'),
('EMP015', '0966443322');

-- 1.4 Insert EMPLOYEE_CERTIFICATION
INSERT INTO EMPLOYEE_CERTIFICATION (EmpID, Certification) VALUES
('EMP001', 'Professional Civil Engineer Class 1'),
('EMP001', 'Project Management Professional (PMP)'),
('EMP002', 'Chartered Structural Engineer Class 1'),
('EMP002', 'Advanced BIM Project Manager'),
('EMP003', 'National Construction Chief Director Class 1'),
('EMP004', 'Highway and Bridge Master Engineer'),
('EMP005', 'High-Rise Construction Director Class 2'),
('EMP007', 'NEBOSH International Diploma in HSE'),
('EMP007', 'ISO 45001 Lead Auditor'),
('EMP008', 'Site Construction Supervision Certificate'),
('EMP010', 'Heavy Crane Operator Class A'),
('EMP010', 'Tower Crane Certified Specialist'),
('EMP011', 'Excavator Safety License Class A'),
('EMP011', 'Earthmoving Machinery Operator'),
('EMP012', 'Occupational Safety and Health Inspector Card Type 2'),
('EMP014', 'High Voltage Industrial Electrician Level 4');

-- 1.5 Insert DEPENDENT
INSERT INTO DEPENDENT (EmpID, DependentName, Relationship, Gender, DOB, IsEmergencyContact) VALUES
('EMP001', 'Thu Huong Nguyen', 'Spouse', 'Female', '1982-06-14', TRUE),
('EMP001', 'Minh Khoi Le', 'Child', 'Male', '2010-09-02', FALSE),
('EMP003', 'Lan Anh Tran', 'Spouse', 'Female', '1988-12-05', TRUE),
('EMP007', 'Phuong Thao Vu', 'Spouse', 'Female', '1993-03-21', TRUE),
('EMP008', 'Hoang Nam Vu Jr.', 'Child', 'Male', '2020-07-15', FALSE),
('EMP008', 'Ngoc Mai Le', 'Spouse', 'Female', '1994-08-19', TRUE),
('EMP010', 'Thi Tuyet Mai', 'Spouse', 'Female', '1990-04-11', TRUE),
('EMP011', 'Thi Kim Chi Phan', 'Spouse', 'Female', '1995-10-08', TRUE),
('EMP015', 'Van Sang Doan', 'Parent', 'Male', '1965-02-14', TRUE);

-- =============================================================================
-- 2. SUBSYSTEM 2: CLIENT & PROJECT MANAGEMENT
-- =============================================================================

-- 2.1 Insert CLIENT
INSERT INTO CLIENT (ClientID, ClientName, TaxCode, RepresentativeName, Email, Street, Ward, District, City) VALUES
('CLI01', 'Vingroup Real Estate Holdings JSC', '0101245486', 'Pham Nhat Vuong', 'investor@vingroup.net', '7 Bang Lang 1, Vinhomes Riverside', 'Viet Hung', 'Long Bien', 'Hanoi'),
('CLI02', 'Masterise Homes Development Corp', '0309852147', 'Jason Turnbull', 'contact@masterise.com.vn', '179 Xa Lo Ha Noi', 'Thao Dien', 'Thu Duc', 'HCMC'),
('CLI03', 'Sun Group Infrastructure Investment', '0400789654', 'Dang Minh Truong', 'bidding@sungroup.com.vn', 'Sun Home, Da Nang High Tech', 'Hoa Vang', 'Hoa Vang', 'Da Nang'),
('CLI04', 'PTIT National Education Infrastructure', '0101987654', 'Vu Van San', 'facilities@ptit.edu.vn', 'Kilometer 10, Nguyen Trai', 'Mo Lao', 'Ha Dong', 'Hanoi');

-- 2.2 Insert CLIENT_PHONE
INSERT INTO CLIENT_PHONE (ClientID, ContactPhone) VALUES
('CLI01', '02439749999'), ('CLI01', '02439748888'),
('CLI02', '02839159159'),
('CLI03', '02363899899'),
('CLI04', '02438545678');

-- 2.3 Insert PROJECT
-- PRJ001 directed by EMP003 (Active)
-- PRJ002 directed by EMP004 (Active)
-- PRJ003 directed by EMP005 (Planning)
-- PRJ004 directed by EMP003 (Completed past project - respects Rule 7!)
INSERT INTO PROJECT (ProjectID, ProjectName, ContractNumber, EstimatedBudget, ActualCost, StartDate, ScheduledEndDate, ActualEndDate, Status, ClientID, DeptID, DirectorEmpID) VALUES
('PRJ001', 'Landmark A34 Twin Towers Complex', 'HD-2023-A34-01', 180000000000.00, 115000000000.00, '2023-03-01', '2025-06-30', NULL, 'Active', 'CLI01', 'DEP03', 'EMP003'),
('PRJ002', 'Coastal Highway Bridge Overpass', 'HD-2023-INFRA-08', 95000000000.00, 48000000000.00, '2023-08-15', '2025-02-28', NULL, 'Active', 'CLI03', 'DEP03', 'EMP004'),
('PRJ003', 'PTIT Smart Digital Technology Center', 'HD-2024-EDU-12', 45000000000.00, 2000000000.00, '2024-10-01', '2026-04-30', NULL, 'Planning', 'CLI04', 'DEP03', 'EMP005'),
('PRJ004', 'Masterise Riverside Luxury Villas', 'HD-2021-RES-05', 75000000000.00, 73500000000.00, '2021-02-01', '2022-12-15', '2022-12-20', 'Completed', 'CLI02', 'DEP03', 'EMP003');

-- 2.4 Insert PROJECT_SITE
INSERT INTO PROJECT_SITE (SiteID, SiteName, Street, Ward, District, City, Latitude, Longitude, ProjectID) VALUES
('SITE01', 'Landmark North Tower Base Site', 'Zone C, Me Tri Extended', 'Me Tri', 'Nam Tu Liem', 'Hanoi', 21.01234500, 105.78912300, 'PRJ001'),
('SITE02', 'Landmark South Commercial Podium', 'Zone D, Me Tri Extended', 'Me Tri', 'Nam Tu Liem', 'Hanoi', 21.01356700, 105.79045600, 'PRJ001'),
('SITE03', 'Coastal Bridge Pier Pier-14 to Pier-22', 'Nguyen Tat Thanh Coastal Highway', 'Hoa Hiep Nam', 'Lien Chieu', 'Da Nang', 16.08945600, 108.15678900, 'PRJ002'),
('SITE04', 'PTIT Campus Innovation Site', 'KM10 Nguyen Trai Road', 'Mo Lao', 'Ha Dong', 'Hanoi', 20.98012300, 105.78765400, 'PRJ003');

-- 2.5 Insert PROJECT_PHASE
-- Total phase budgets strictly respect Rule 1: Sum(PhaseBudget) <= EstimatedBudget!
-- PRJ001 (180B budget): 35B + 80B + 50B = 165B <= 180B
-- PRJ002 (95B budget): 25B + 45B + 20B = 90B <= 95B
INSERT INTO PROJECT_PHASE (ProjectID, PhaseNumber, PhaseName, PhaseBudget, StartDate, ScheduledEndDate, ActualEndDate, Status, ProgressPercentage) VALUES
('PRJ001', 1, 'Site Clearance, Excavation & Deep Piling', 35000000000.00, '2023-03-01', '2023-09-30', '2023-09-28', 'Completed', 100.00),
('PRJ001', 2, 'Basement Diaphragm Walls & Superstructure', 80000000000.00, '2023-10-01', '2024-11-30', NULL, 'In-Progress', 78.50),
('PRJ001', 3, 'Architectural Facade & MEP Installation', 50000000000.00, '2024-12-01', '2025-06-30', NULL, 'Pending', 0.00),
('PRJ002', 1, 'Subsea Soil Investigation & Pier Foundation', 25000000000.00, '2023-08-15', '2024-03-31', '2024-04-05', 'Completed', 100.00),
('PRJ002', 2, 'Pre-stressed Concrete Girder Launching', 45000000000.00, '2024-04-10', '2024-12-31', NULL, 'In-Progress', 62.00),
('PRJ002', 3, 'Deck Asphalt Paving & Traffic Signalling', 20000000000.00, '2025-01-01', '2025-02-28', NULL, 'Pending', 0.00),
('PRJ003', 1, 'Geotechnical Survey & Architectural Design', 5000000000.00, '2024-10-01', '2024-12-31', NULL, 'In-Progress', 35.00);

-- 2.6 Insert TASK
INSERT INTO TASK (TaskID, TaskName, Description, EstimatedCost, ActualCost, StartDate, EndDate, Status, ProjectID, PhaseNumber) VALUES
('TSK101', 'Diaphragm Wall Barrette Trenching', 'Excavate slurry wall perimeter down to -32m', 15000000000.00, 14800000000.00, '2023-10-05', '2024-01-15', 'Completed', 'PRJ001', 2),
('TSK102', 'Basement Level B3 Concrete Pouring', 'Cast mass foundation concrete block with chilling pipe', 22000000000.00, 21500000000.00, '2024-01-20', '2024-04-30', 'Completed', 'PRJ001', 2),
('TSK103', 'Tower 1 Core Wall Concrete Climbing Formwork', 'Construct hydraulic self-climbing core wall floors 1 to 25', 28000000000.00, 24000000000.00, '2024-05-05', '2024-11-20', 'In-Progress', 'PRJ001', 2),
('TSK104', 'Tower 2 Floor Slab Post-Tensioning', 'Post-tension tendon prestressing on composite slabs', 15000000000.00, 9500000000.00, '2024-07-01', '2024-11-25', 'In-Progress', 'PRJ001', 2),
('TSK201', 'Cast-in-Place Bored Piles Pier 16-18', 'Drilling bored piles diameter 1.5m deep into sea bedrock', 18000000000.00, 17800000000.00, '2024-04-15', '2024-07-30', 'Completed', 'PRJ002', 2),
('TSK202', 'Precast Segment Cantilever Erection', 'Assemble segmental box girders using launching gantry', 22000000000.00, 14200000000.00, '2024-08-01', '2024-12-15', 'In-Progress', 'PRJ002', 2);

-- 2.7 Insert PRECEDES (Predecessor -> Successor clean DAG)
INSERT INTO PRECEDES (PredecessorTaskID, SuccessorTaskID) VALUES
('TSK101', 'TSK102'),
('TSK102', 'TSK103'),
('TSK102', 'TSK104'),
('TSK201', 'TSK202');

-- 2.8 Insert WORKS_ON_TASK (Daily work hours <= 12 hours)
INSERT INTO WORKS_ON_TASK (EmpID, TaskID, HoursLogged, RoleDescription, AssignedDate) VALUES
('EMP008', 'TSK103', 8.00, 'Senior Site Coordination & QC', '2024-10-15'),
('EMP009', 'TSK103', 7.50, 'Structural Formwork Inspection', '2024-10-15'),
('EMP010', 'TSK103', 8.50, 'Tower Crane Lifting Operations', '2024-10-15'),
('EMP014', 'TSK103', 6.00, 'Climbing System Electrical Wiring', '2024-10-15'),
('EMP015', 'TSK103', 8.00, 'Rebar Lashing and Vibrating', '2024-10-15'),
('EMP008', 'TSK104', 3.50, 'Post-Tension Inspection', '2024-10-16'),
('EMP010', 'TSK104', 8.00, 'Material Hoisting to Podium', '2024-10-16'),
('EMP011', 'TSK202', 8.00, 'Gantry Support Relocation', '2024-10-16');

-- =============================================================================
-- 3. SUBSYSTEM 3: HEAVY MACHINERY & EQUIPMENT
-- =============================================================================

-- 3.1 Insert EQUIPMENT
INSERT INTO EQUIPMENT (EquipmentID, SerialNumber, EquipmentName, Category, Capacity, HourlyRate, Status, TotalRunHours) VALUES
('EQP001', 'SN-POTAIN-MD345-01', 'Potain Top-Slewing Tower Crane MD 345', 'Tower Crane', '12 Tons', 1850000.00, 'Deployed', 2140.50),
('EQP002', 'SN-LIEBHERR-LR1300', 'Liebherr Crawler Crane LR 1300', 'Heavy Crane', '300 Tons', 3500000.00, 'Available', 1420.00),
('EQP003', 'SN-CAT-336D-9821', 'Caterpillar Hydraulic Excavator 336D', 'Excavator', '2.5 m3', 950000.00, 'Deployed', 3850.00),
('EQP004', 'SN-PUTZ-BSF47-09', 'Putzmeister Truck-Mounted Concrete Pump 47Z', 'Concrete Pump', '160 m3/h', 1400000.00, 'Available', 1650.00),
('EQP005', 'SN-DYNAPAC-CC6200', 'Dynapac Double Drum Asphalt Roller CC6200', 'Asphalt Roller', '12.5 Tons', 750000.00, 'Under-Maintenance', 2890.00);

-- 3.2 Insert MAINTENANCE_RECORD
INSERT INTO MAINTENANCE_RECORD (EquipmentID, RecordNumber, MaintenanceDate, MaintenanceType, Description, Cost, PerformedBy) VALUES
('EQP001', 1, '2024-03-10', 'Routine', 'Wire rope tensile inspection, lubrication of slewing ring', 15000000.00, 'Potain Vietnam Technical Services'),
('EQP001', 2, '2024-08-15', 'Preventive', 'Replacement of hoist brake pads and anemometer calibration', 28000000.00, 'Potain Vietnam Technical Services'),
('EQP003', 1, '2024-05-20', 'Routine', 'Hydraulic fluid filter change and track tensioning', 12000000.00, 'Phu Thai Cat Technical Team'),
('EQP005', 1, '2024-10-25', 'Corrective', 'Vibratory drum bearing overhaul and engine turbo replacement', 45000000.00, 'Dynapac Certified Workshop');

-- 3.3 Insert EQUIPMENT_DEPLOYMENT
-- Non-overlapping dates, operators hold valid certifications matching equipment Category!
INSERT INTO EQUIPMENT_DEPLOYMENT (EquipmentID, DeploymentStartDate, DeploymentEndDate, OperatingHours, SiteID, OperatorEmpID) VALUES
('EQP001', '2024-01-10', '2024-06-30', 980.00, 'SITE01', 'EMP010'),
('EQP001', '2024-07-01', '2024-12-31', 720.00, 'SITE01', 'EMP010'),
('EQP003', '2024-04-15', '2024-11-15', 850.00, 'SITE03', 'EMP011');

-- =============================================================================
-- 4. SUBSYSTEM 4: PROCUREMENT, INVENTORY & MATERIALS
-- =============================================================================

-- 4.1 Insert SUPPLIER
INSERT INTO SUPPLIER (SupplierID, SupplierName, TaxCode, Email, Street, Ward, District, City) VALUES
('SUP01', 'Hoa Phat Steel Joint Stock Corporation', '0900189284', 'sales.rebar@hoaphat.com.vn', '66 Nguyen Du', 'Nguyen Du', 'Hai Ba Trung', 'Hanoi'),
('SUP02', 'Vicem Ha Tien Cement Joint Stock Company', '0300481234', 'orders@vicemhatien.com.vn', '216 Nguyen Thi Minh Khai', 'Vo Thi Sau', 'District 3', 'HCMC'),
('SUP03', 'Binh Duong Concrete & Quarry Corp', '3700234567', 'commercial@bdconcrete.vn', 'KM 18 Binh Duong Boulevard', 'Thuan Giao', 'Thuan An', 'Binh Duong'),
('SUP04', 'Vinh Tuong Saint-Gobain Drywall Co.', '0302564890', 'contractor@vinhtuong.com', 'Floor 9, SOFIC Tower', 'An Loi Dong', 'Thu Duc', 'HCMC');

-- 4.2 Insert SUPPLIER_PHONE
INSERT INTO SUPPLIER_PHONE (SupplierID, ContactPhone) VALUES
('SUP01', '02436282011'), ('SUP01', '02436282012'),
('SUP02', '02839301234'),
('SUP03', '02743825555'),
('SUP04', '02838279999');

-- 4.3 Insert SUPPLIER_CATEGORY
INSERT INTO SUPPLIER_CATEGORY (SupplierID, SupplyCategory) VALUES
('SUP01', 'Reinforcing Steel Rebar'),
('SUP01', 'Structural Steel H-Beams'),
('SUP02', 'Portland Cement PCB40'),
('SUP02', 'Slag Blended Cement'),
('SUP03', 'Ready-Mix Concrete Grade M350-M600'),
('SUP03', 'Crushed Aggregate & Sand'),
('SUP04', 'Ceiling and Drywall Partitions');

-- 4.4 Insert MATERIAL
INSERT INTO MATERIAL (MaterialID, MaterialName, Unit, StandardPrice) VALUES
('MAT001', 'Reinforcing Steel Rebar CB400-V D25', 'Ton', 16500000.00),
('MAT002', 'High-Tensile Prestressing Strand 15.2mm', 'Ton', 24000000.00),
('MAT003', 'Portland Blended Cement PCB40 Bulk', 'Ton', 1650000.00),
('MAT004', 'Ready-Mix Mass Concrete Grade M450', 'm3', 1450000.00),
('MAT005', 'High-Strength River Sand (Washed)', 'm3', 380000.00),
('MAT006', 'Crushed Granite Stone 1x2cm', 'm3', 420000.00);

-- 4.5 Insert PURCHASE_ORDER
INSERT INTO PURCHASE_ORDER (PO_ID, OrderDate, TotalAmount, Status, ProjectID, SupplierID) VALUES
('PO2024-001', '2024-02-15', 4950000000.00, 'Received', 'PRJ001', 'SUP01'),
('PO2024-002', '2024-03-10', 2900000000.00, 'Received', 'PRJ001', 'SUP03'),
('PO2024-003', '2024-05-18', 2400000000.00, 'Received', 'PRJ002', 'SUP01'),
('PO2024-004', '2024-08-20', 825000000.00, 'Shipped', 'PRJ001', 'SUP02');

-- 4.6 Insert PO_ITEM
INSERT INTO PO_ITEM (PO_ID, LineNumber, OrderQuantity, UnitPrice, MaterialID) VALUES
('PO2024-001', 1, 300.00, 16500000.00, 'MAT001'),
('PO2024-002', 1, 2000.00, 1450000.00, 'MAT004'),
('PO2024-003', 1, 100.00, 24000000.00, 'MAT002'),
('PO2024-004', 1, 500.00, 1650000.00, 'MAT003');

-- 4.7 Insert SITE_INVENTORY
INSERT INTO SITE_INVENTORY (SiteID, MaterialID, CurrentStockQuantity, MinStock, ReorderQuantity) VALUES
('SITE01', 'MAT001', 145.00, 40.00, 150.00),
('SITE01', 'MAT004', 450.00, 100.00, 500.00),
('SITE01', 'MAT003', 18.00, 40.00, 100.00),
('SITE03', 'MAT002', 12.00, 80.00, 100.00),
('SITE03', 'MAT005', 110.00, 80.00, 300.00);

-- 4.8 Insert DELIVERY_DISPATCH (Supplier resolved via PO_ID)
INSERT INTO DELIVERY_DISPATCH (DeliveryCode, DeliveryDate, DeliveredQuantity, Status, MaterialID, SiteID, ReceivedByEmpID, PO_ID) VALUES
('DEL-2024-0101', '2024-02-22', 150.00, 'Received', 'MAT001', 'SITE01', 'EMP013', 'PO2024-001'),
('DEL-2024-0102', '2024-02-28', 150.00, 'Received', 'MAT001', 'SITE01', 'EMP013', 'PO2024-001'),
('DEL-2024-0205', '2024-03-15', 1000.00, 'Received', 'MAT004', 'SITE01', 'EMP013', 'PO2024-002'),
('DEL-2024-0312', '2024-05-25', 60.00, 'Received', 'MAT002', 'SITE03', 'EMP008', 'PO2024-003');

-- 4.9 Insert MATERIAL_USAGE (Respects available stock in inventory!)
INSERT INTO MATERIAL_USAGE (TaskID, MaterialID, SiteID, UsageDate, UsedQuantity) VALUES
('TSK103', 'MAT001', 'SITE01', '2024-10-10', 25.00),
('TSK103', 'MAT004', 'SITE01', '2024-10-12', 120.00),
('TSK104', 'MAT001', 'SITE01', '2024-10-14', 18.00),
('TSK202', 'MAT002', 'SITE03', '2024-10-15', 12.00);

-- =============================================================================
-- 5. SUBSYSTEM 5: SUBCONTRACTORS & SITE SAFETY ASSURANCE
-- =============================================================================

-- 5.1 Insert SUBCONTRACTOR
INSERT INTO SUBCONTRACTOR (SubcontractorID, SubcontractorName, TaxCode, Specialization, ContactPerson, ContactPhone, ContactEmail, LicenseNumber) VALUES
('SUB01', 'Coteccons Mechanical & Electrical Corp', '0303888999', 'MEP High-Rise Systems', 'Nguyen Van Hung', '0903889900', 'bidding@coteccons-mep.vn', 'LIC-BXD-MEP-001'),
('SUB02', 'Delta Geotechnical & Underground Specialist', '0101777888', 'Diaphragm Wall & Deep Piling', 'Tran Nhat Nam', '0912777888', 'contact@delta-underground.vn', 'LIC-BXD-GEO-042'),
('SUB03', 'Hoa Binh Prestressing Technology JSC', '0302666555', 'Post-Tensioning & Bridge Girders', 'Le Hoang Quan', '0988666555', 'tech@hoabinh-pt.vn', 'LIC-BXD-STR-108');

-- 5.2 Insert SUBCONTRACT
INSERT INTO SUBCONTRACT (ContractAgreementNo, ScopeOfWork, ContractValue, StartDate, EndDate, WarrantyHoldRate, ProjectID, SubcontractorID) VALUES
('HD-SUB-2023-01', 'Design and Execution of Deep Diaphragm Wall & Barrette Piles', 26000000000.00, '2023-03-15', '2023-09-20', 5.00, 'PRJ001', 'SUB02'),
('HD-SUB-2024-04', 'Supply & Tensioning of Unbonded Post-Tension Slabs B1 to Floor 20', 14000000000.00, '2024-05-01', DATE_ADD(CURDATE(), INTERVAL 45 DAY), 5.00, 'PRJ001', 'SUB03'),
('HD-SUB-2024-08', 'Cantilever Segmental Bridge Post-Tensioning and Cable Stay Works', 18500000000.00, '2024-06-01', DATE_ADD(CURDATE(), INTERVAL 120 DAY), 7.50, 'PRJ002', 'SUB03');

-- 5.3 Insert SAFETY_INSPECTION
INSERT INTO SAFETY_INSPECTION (InspectionID, InspectionDate, InspectionType, InspectionScope, OverallScore, InspectionResult, ViolationNoted, FixDeadline, SiteID, InspectorEmpID) VALUES
('INS-2024-01', '2024-08-10', 'Monthly', 'Fall Protection and Tower Crane Wire Rope Integrity', 92.50, 'Pass', 'Minor: 2 workers lacked safety harness lanyard tie-off at height 12m', '2024-08-12', 'SITE01', 'EMP007'),
('INS-2024-02', '2024-09-15', 'Weekly', 'Electrical Safety and Temporary Distribution Boards', 78.00, 'Conditional-Pass', 'Sub-panel distribution box lacked rubber weatherproofing sealing', '2024-09-18', 'SITE01', 'EMP012'),
('INS-2024-03', '2024-10-02', 'Surprise', 'Scaffolding Tie-Backs and Marine Working Platforms', 88.00, 'Pass', 'Adequate life vests and life buoys deployed along pier foundation', NULL, 'SITE03', 'EMP012');

-- 5.4 Insert INCIDENT_REPORT
-- Note: Level-2 incident with InvolvedEmpID EMP010 will trigger automated emergency dispatch log (Rule 8)!
INSERT INTO INCIDENT_REPORT (IncidentID, IncidentTimestamp, IncidentType, IncidentLevel, DamageDescription, LostDays, Solution, SiteID, InvolvedEmpID, DamagedEquipmentID) VALUES
('INC-2024-01', '2024-07-12 14:30:00', 'Near-Miss', 'Level-1', 'Small wooden wedge dropped from Floor 15 into safety netting, zero casualty', 0, 'Reinforced debris catchment perimeter netting and issued warning', 'SITE01', NULL, NULL),
('INC-2024-02', '2024-09-22 10:15:00', 'Minor-Injury', 'Level-2', 'Operator hand sprain during heavy hook stabilization in high gust wind', 3, 'Administered first aid at clinic, mandated 3-day medical leave, tightened wind speed threshold', 'SITE01', 'EMP010', 'EQP001');
