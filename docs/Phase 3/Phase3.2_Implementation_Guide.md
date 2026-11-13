# Hướng Dẫn Thực Thi Phase 3: Physical Database Design & Implementation (MySQL 8.0+)

- **Môn học:** Hệ cơ sở dữ liệu [E24-Class 5] - Nhóm 5
- **Đề tài:** Hệ thống CSDL Doanh nghiệp Xây dựng Đa dự án (**A34Build**)
- **Giảng viên hướng dẫn:** TS. Nguyễn Đình Hoà (`hoand@ptit.edu.vn`)

---

## 1. Cấu trúc Bộ Mã Nguồn SQL (`deliverables/sql/`)

Toàn bộ mã nguồn cài đặt CSDL đã được xây dựng chuẩn mực theo thiết kế 3NF, lưu trữ tại thư mục `deliverables/sql/`:

| Tên File | Chức năng chính | Ghi chú kỹ thuật |
| :--- | :--- | :--- |
| **[01_schema_ddl.sql](file:///T:/UNI/CSDL%20(database)/TermProject/deliverables/sql/01_schema_ddl.sql)** | Khởi tạo CSDL `A34Build_DB` và 29 bảng 3NF. | Hỗ trợ đầy đủ PK, FK, UNIQUE, CHECK constraints, Engine=InnoDB, UTF-8. Xử lý phụ thuộc vòng `DEPARTMENT` $\leftrightarrow$ `EMPLOYEE`. |
| **[02_triggers_procedures.sql](file:///T:/UNI/CSDL%20(database)/TermProject/deliverables/sql/02_triggers_procedures.sql)** | Cài đặt **8 quy tắc nghiệp vụ phức tạp** không thể vẽ trên ERD. | Dùng `BEFORE INSERT/UPDATE`, `SIGNAL SQLSTATE '45000'`, kiểm tra đồ thị DAG không chu trình bằng CTE đệ quy. |
| **[03_sample_data_dml.sql](file:///T:/UNI/CSDL%20(database)/TermProject/deliverables/sql/03_sample_data_dml.sql)** | Nạp dữ liệu mẫu phong phú, thực tế cho toàn bộ 29 bảng. | Dữ liệu gắn liền ngữ cảnh thực tế Việt Nam (Hà Nội, Đà Nẵng, TP.HCM), đảm bảo tính toàn vẹn nghiệp vụ. |
| **[04_business_queries.sql](file:///T:/UNI/CSDL%20(database)/TermProject/deliverables/sql/04_business_queries.sql)** | Các câu truy vấn vận hành và báo cáo quản trị nâng cao. | Tính toán chi phí dự án (Cost vs Budget), Earned Value Management (EVM), phân cấp nhân sự (CTE đệ quy), an toàn công trường. |

---

## 2. Thứ tự Thực thi trên MySQL (Workbench / DBeaver / Command Line)

### Cách 1: Chạy trên MySQL Workbench hoặc DBeaver
Mở lần lượt từng file theo đúng thứ tự:
1. **Mở và chạy `01_schema_ddl.sql`:** Tạo toàn bộ cấu trúc database và 29 bảng (ấn tổ hợp phím `Ctrl + Shift + Enter` để chạy toàn bộ).
2. **Mở và chạy `02_triggers_procedures.sql`:** Đăng ký toàn bộ Trigger bảo vệ nghiệp vụ.
3. **Mở và chạy `03_sample_data_dml.sql`:** Nạp dữ liệu mẫu vào 29 bảng.
4. **Mở và chạy `04_business_queries.sql`:** Chạy từng khối câu lệnh truy vấn để kiểm tra kết quả và chụp màn hình báo cáo.

### Cách 2: Chạy trực tiếp từ Terminal / PowerShell
```powershell
# Chuyển vào thư mục deliverables/sql
cd "T:\UNI\CSDL (database)\TermProject\deliverables\sql"

# Thực thi lần lượt 4 file bằng tài khoản root của MySQL
mysql -u root -p < 01_schema_ddl.sql
mysql -u root -p < 02_triggers_procedures.sql
mysql -u root -p < 03_sample_data_dml.sql
mysql -u root -p < 04_business_queries.sql
```

---

## 3. Bộ Test Case Chứng minh 8 Triggers Hoạt động (Dùng Chụp Ảnh Minh Chứng)

Để đạt điểm tối đa ở mục **Proofs of Implementation**, bạn có thể chạy các câu lệnh cố tình vi phạm sau đây để chứng minh Trigger lập tức chặn đứng dữ liệu sai:

### Test Case 1: Chặn vượt ngân sách dự án (Rule 1)
```sql
-- Thử thêm một Phase mới vào PRJ001 với ngân sách 30 tỷ (sẽ làm tổng Phase vượt 180 tỷ)
INSERT INTO PROJECT_PHASE (ProjectID, PhaseNumber, PhaseName, PhaseBudget, StartDate, ScheduledEndDate, Status)
VALUES ('PRJ001', 4, 'Test Invalid Phase Budget Overrun', 30000000000.00, '2025-07-01', '2025-09-30', 'Pending');
-- KẾT QUẢ MONG ĐỢI: Lỗi 45000: Rule 1 Violation: Total PhaseBudget cannot exceed Project EstimatedBudget.
```

### Test Case 2: Chặn trùng lịch máy móc (Rule 2)
```sql
-- Thử xếp lịch cho Cần cẩu tháp EQP001 hoạt động trùng vào tháng 3/2024
INSERT INTO EQUIPMENT_DEPLOYMENT (EquipmentID, DeploymentStartDate, DeploymentEndDate, OperatingHours, SiteID, OperatorEmpID)
VALUES ('EQP001', '2024-03-01', '2024-03-15', 50.00, 'SITE02', 'EMP010');
-- KẾT QUẢ MONG ĐỢI: Lỗi 45000: Rule 2 Violation: Equipment deployment interval overlaps with an existing deployment.
```

### Test Case 3: Chặn công nhân làm việc quá 12 giờ/ngày (Rule 4)
```sql
-- Công nhân EMP008 đã làm 8 giờ ngày 2024-10-15, thử ghi nhận thêm 5 giờ nữa (Tổng 13h > 12h)
INSERT INTO WORKS_ON_TASK (EmpID, TaskID, HoursLogged, RoleDescription, AssignedDate)
VALUES ('EMP008', 'TSK104', 5.00, 'Overtime Work', '2024-10-15');
-- KẾT QUẢ MONG ĐỢI: Lỗi 45000: Rule 4 Violation: Worker logged hours exceed statutory limit of 12 hours per calendar day.
```

### Test Case 4: Chặn chu trình công việc vi phạm DAG (Rule 5)
```sql
-- Hiện có: TSK101 -> TSK102 -> TSK103. Thử tạo ngược TSK103 -> TSK101
INSERT INTO PRECEDES (PredecessorTaskID, SuccessorTaskID)
VALUES ('TSK103', 'TSK101');
-- KẾT QUẢ MONG ĐỢI: Lỗi 45000: Rule 5 Violation: Circular dependency detected in task precedence (Violates DAG).
```

### Test Case 5: Tự động gửi cảnh báo khẩn cấp khi có sự cố (Rule 8)
```sql
-- Kiểm tra bảng log cảnh báo khẩn cấp đã được tự động sinh ra khi ghi nhận tai nạn
SELECT * FROM EMERGENCY_DISPATCH_LOG;
-- KẾT QUẢ MONG ĐỢI: Hiện 1 dòng thông báo gửi khẩn cấp cho vợ của nhân viên lái cẩu EMP010.
```

---

## 4. Danh sách Ảnh chụp Màn hình (Screenshots) Cần Chuẩn bị cho Báo Cáo

1. **Ảnh 1: Cấu trúc 29 Bảng trong CSDL** (Cây thư mục Schema của MySQL Workbench hoặc DBeaver sau khi chạy `01_schema_ddl.sql`).
2. **Ảnh 2: Sơ đồ Reverse Engineer ERD** (Vào MySQL Workbench $\to$ Database $\to$ Reverse Engineer để tự động xuất ra sơ đồ vật lý).
3. **Ảnh 3: Dữ liệu mẫu nạp thành công** (Chụp lệnh `SELECT * FROM EMPLOYEE LIMIT 10;`, `SELECT * FROM PROJECT;`, `SELECT * FROM EQUIPMENT;`).
4. **Ảnh 4: Trigger bắt lỗi thành công** (Chụp màn hình thông báo lỗi màu đỏ khi chạy 1 trong các Test Case ở Mục 3).
5. **Ảnh 5: Kết quả Báo cáo EVM (Earned Value Analysis)** (Chụp bảng kết quả của Query 2.2 trong `04_business_queries.sql`).
6. **Ảnh 6: Kết quả Báo cáo Cost vs Budget Variance** (Chụp bảng kết quả của Query 2.1).
7. **Ảnh 7: Cây phân cấp nhân sự đệ quy** (Chụp kết quả Query 1.3).
