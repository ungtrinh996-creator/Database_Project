# Báo cáo Thiết kế Cơ sở Dữ liệu (Giai đoạn 3)
## Nhiệm vụ 1: Phân tích Phụ thuộc hàm, Khóa ứng viên & Chuẩn hóa CSDL (3NF)

- **Đề tài:** Hệ thống Cơ sở Dữ liệu Doanh nghiệp Xây dựng Đa dự án (A34Build)
- **Học phần:** Cơ sở Dữ liệu [E24-Class 5]
- **Nhóm thực hiện:** Nhóm 5
- **Thành viên:**
  - Lê Anh Minh (B24DCCE180)
  - Ứng Trọng Trình (B24DCCE271)
  - Nguyễn Đinh Anh Quân (B24DCCE222)
- **Giảng viên hướng dẫn:** TS. Nguyễn Đình Hoá (`hoand@ptit.edu.vn`)
- **Tài liệu tham khảo chính:** Giáo trình *Fundamentals of Database Systems*, Tái bản lần thứ 6 (R. Elmasri & S. B. Navathe, Chương 14)

---

## 1. Tổng quan & Tóm tắt Quá trình Chuẩn hóa

Phần này rà soát và kiểm định toàn bộ **29 lược đồ quan hệ** được chuyển đổi từ mô hình ERD ở Giai đoạn 2 nhằm đảm bảo đạt Dạng chuẩn 3 (3NF) theo lý thuyết của Elmasri & Navathe (Chương 14).

### Kết quả Cốt lõi
* **27 lược đồ** trực tiếp thỏa mãn chuẩn 3NF, không cần điều chỉnh cấu trúc.
* **2 lược đồ** phát hiện lỗi thiết kế từ bước ánh xạ ERD ban đầu và đã được xử lý chuẩn hóa:

| Bảng | Lỗi Thiết kế Ban đầu (Phase 2) | Dạng vi phạm | Hiệu chỉnh Đạt 3NF (Phase 3) |
| :--- | :--- | :---: | :--- |
| **16. `EQUIPMENT_DEPLOYMENT`** | $\text{SiteID}$ bị đưa vào khóa chính: $(\underline{\text{EquipmentID}}, \underline{\text{SiteID}}, \underline{\text{DeploymentStartDate}})$, trong khi $\{\text{EquipmentID}, \text{DeploymentStartDate}\} \to \text{SiteID}$. | **2NF**<br>(Phụ thuộc từng phần vào khóa) | Đưa $\text{SiteID}$ ra khỏi khóa chính, chuyển thành khóa ngoại. Khóa chính tối thiểu: $(\underline{\text{EquipmentID}}, \underline{\text{DeploymentStartDate}})$. |
| **24. `DELIVERY_DISPATCH`** | Chứa đồng thời cả $\text{PO\_ID}$ và $\text{SupplierID}$, trong khi $\text{PO\_ID} \to \text{SupplierID}$ thông qua bảng `PURCHASE_ORDER`. | **3NF**<br>(Phụ thuộc bắc cầu:<br>$\text{DeliveryCode} \to \text{PO\_ID} \to \text{SupplierID}$) | Loại bỏ cột $\text{SupplierID}$. Thông tin nhà cung cấp được truy xuất qua khóa ngoại $\text{PO\_ID} \to \text{PURCHASE\_ORDER}$. |

---

## 2. Phân tích Chuẩn hóa Chi tiết Toàn bộ 29 Bảng

Mỗi bảng quan hệ được trình bày theo cấu trúc đồng nhất: Lược đồ quan hệ, Tập phụ thuộc hàm ($F$), Khóa ứng viên, Phân loại thuộc tính và Đánh giá từng bước dạng chuẩn (1NF $\to$ 2NF $\to$ 3NF).

---

### Phân hệ 1: Tổ chức & Nhân sự (Organization & Human Resources)

#### 1. Bảng: `DEPARTMENT` (Phòng ban)
* **Lược đồ quan hệ:** $\text{DEPARTMENT}(\underline{\text{DeptID}}, \text{DeptName}, \text{OfficeLocation}, \text{Budget}, \text{HeadEmpID})$
* **Tập phụ thuộc hàm ($F_1$):**
  * $FD_{1.1}: \text{DeptID} \to \{\text{DeptName, OfficeLocation, Budget, HeadEmpID}\}$ (Mã phòng định danh duy nhất thông tin phòng ban).
  * $FD_{1.2}: \text{DeptName} \to \{\text{DeptID, OfficeLocation, Budget, HeadEmpID}\}$ (Tên phòng ban là duy nhất toàn doanh nghiệp).
  * $FD_{1.3}: \text{HeadEmpID} \to \{\text{DeptID, DeptName, OfficeLocation, Budget}\}$ (Mỗi nhân viên chỉ giữ chức trưởng của tối đa 1 phòng ban).
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK_1 = \{\text{DeptID}\}$ (Khóa chính - PK), $CK_2 = \{\text{DeptName}\}$ (Khóa thay thế - AK), $CK_3 = \{\text{HeadEmpID}\}$ (AK).
  * **Thuộc tính khóa (Prime):** `DeptID`, `DeptName`, `HeadEmpID`.
  * **Thuộc tính không khóa (Non-Prime):** `OfficeLocation`, `Budget`.
* **Đánh giá dạng chuẩn:**
  * **1NF:** Thỏa mãn (miền giá trị nguyên tử).
  * **2NF:** Thỏa mãn (các khóa ứng viên đều là khóa đơn 1 thuộc tính; không tồn tại phụ thuộc từng phần).
  * **3NF:** Thỏa mãn (mọi định thức ở vế trái đều là siêu khóa; không có phụ thuộc bắc cầu giữa các thuộc tính không khóa).
* **Kết luận:** **Đạt 3NF**.

---

#### 2. Bảng: `EMPLOYEE` (Nhân viên)
* **Lược đồ quan hệ:** $\text{EMPLOYEE}(\underline{\text{EmpID}}, \text{FirstName}, \text{MiddleName}, \text{LastName}, \text{Street}, \text{Ward}, \text{District}, \text{City}, \text{DOB}, \text{HireDate}, \text{Salary}, \text{JobTitle}, \text{Email}, \text{DeptID}, \text{SupervisorID})$
* **Tập phụ thuộc hàm ($F_2$):**
  * $FD_{2.1}: \text{EmpID} \to \{\text{FirstName, MiddleName, LastName, Street, Ward, District, City, DOB, HireDate, Salary, JobTitle, Email, DeptID, SupervisorID}\}$ (Mã nhân viên xác định toàn bộ thông tin nhân sự).
  * $FD_{2.2}: \text{Email} \to \{\text{EmpID, FirstName, MiddleName, LastName, Street, Ward, District, City, DOB, HireDate, Salary, JobTitle, DeptID, SupervisorID}\}$ (Email công ty là duy nhất).
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK_1 = \{\text{EmpID}\}$ (PK), $CK_2 = \{\text{Email}\}$ (AK).
  * **Thuộc tính khóa:** `EmpID`, `Email`.
  * **Thuộc tính không khóa:** `FirstName, MiddleName, LastName, Street, Ward, District, City, DOB, HireDate, Salary, JobTitle, DeptID, SupervisorID`.
* **Đánh giá dạng chuẩn:**
  * **1NF:** Thỏa mãn (các thuộc tính phức hợp Họ tên và Địa chỉ đã được tách thành các trường nguyên tử; thuộc tính đa trị đã được tách bảng riêng).
  * **2NF:** Thỏa mãn (các khóa đều là đơn thuộc tính; không có phụ thuộc từng phần).
  * **3NF:** Thỏa mãn (mọi định thức đều là siêu khóa; các khóa ngoại tham chiếu ra bảng ngoài không tạo phụ thuộc bắc cầu nội bộ).
* **Kết luận:** **Đạt 3NF**.

---

#### 3. Bảng: `EMPLOYEE_PHONE` (Số điện thoại nhân viên)
* **Lược đồ quan hệ:** $\text{EMPLOYEE\_PHONE}(\underline{\text{EmpID}}, \underline{\text{PhoneNumber}})$
* **Tập phụ thuộc hàm ($F_3$):** Chỉ có các phụ thuộc hàm tầm thường ($\{\text{EmpID, PhoneNumber}\} \to \{\text{EmpID, PhoneNumber}\}$).
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{EmpID, PhoneNumber}\}$ (PK).
  * **Thuộc tính khóa:** `EmpID`, `PhoneNumber`.
  * **Thuộc tính không khóa:** $\emptyset$ (Không có).
* **Đánh giá dạng chuẩn:**
  * **1NF:** Thỏa mãn (mỗi dòng chứa một số điện thoại nguyên tử).
  * **2NF / 3NF:** Thỏa mãn hiển nhiên (toàn bộ thuộc tính đều là thuộc tính khóa).
* **Kết luận:** **Đạt 3NF**.

---

#### 4. Bảng: `EMPLOYEE_CERTIFICATION` (Chứng chỉ chuyên môn nhân viên)
* **Lược đồ quan hệ:** $\text{EMPLOYEE\_CERTIFICATION}(\underline{\text{EmpID}}, \underline{\text{Certification}})$
* **Tập phụ thuộc hàm ($F_4$):** Chỉ có các phụ thuộc hàm tầm thường.
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{EmpID, Certification}\}$ (PK).
  * **Thuộc tính khóa:** `EmpID`, `Certification`.
  * **Thuộc tính không khóa:** $\emptyset$ (Không có).
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn hiển nhiên (tất cả các thuộc tính đều thuộc khóa).
* **Kết luận:** **Đạt 3NF**.

---

#### 5. Bảng: `DEPENDENT` (Người phụ thuộc)
* **Lược đồ quan hệ:** $\text{DEPENDENT}(\underline{\text{EmpID}}, \underline{\text{DependentName}}, \text{Gender}, \text{BirthDate}, \text{Relationship}, \text{ContactPhone}, \text{IsEmergencyContact})$
* **Tập phụ thuộc hàm ($F_5$):**
  * $FD_{5.1}: \{\text{EmpID, DependentName}\} \to \{\text{Gender, BirthDate, Relationship, ContactPhone, IsEmergencyContact}\}$ (Thực thể yếu được định danh bởi nhân viên chủ quản và khóa bộ phận Tên người phụ thuộc).
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{EmpID, DependentName}\}$ (PK).
  * **Thuộc tính khóa:** `EmpID`, `DependentName`.
  * **Thuộc tính không khóa:** `Gender, BirthDate, Relationship, ContactPhone, IsEmergencyContact`.
* **Đánh giá dạng chuẩn:**
  * **1NF:** Thỏa mãn.
  * **2NF:** Thỏa mãn (cả `EmpID` hay `DependentName` đứng riêng lẻ đều không xác định được các thuộc tính còn lại; phụ thuộc hàm là đầy đủ).
  * **3NF:** Thỏa mãn (vế trái là khóa chính; không có phụ thuộc bắc cầu).
* **Kết luận:** **Đạt 3NF**.

---

### Phân hệ 2: Quản lý Dự án & Cấu trúc Phân chia Công việc (WBS)

#### 6. Bảng: `CLIENT` (Chủ đầu tư / Khách hàng)
* **Lược đồ quan hệ:** $\text{CLIENT}(\underline{\text{ClientID}}, \text{ClientName}, \text{ClientType}, \text{ContactPerson}, \text{ContactEmail}, \text{TaxCode})$
* **Tập phụ thuộc hàm ($F_6$):**
  * $FD_{6.1}: \text{ClientID} \to \{\text{ClientName, ClientType, ContactPerson, ContactEmail, TaxCode}\}$
  * $FD_{6.2}: \text{TaxCode} \to \{\text{ClientID, ClientName, ClientType, ContactPerson, ContactEmail}\}$ (Mã số thuế doanh nghiệp là duy nhất).
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK_1 = \{\text{ClientID}\}$ (PK), $CK_2 = \{\text{TaxCode}\}$ (AK).
  * **Thuộc tính khóa:** `ClientID`, `TaxCode`.
  * **Thuộc tính không khóa:** `ClientName, ClientType, ContactPerson, ContactEmail`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF:** Thỏa mãn (các khóa là đơn thuộc tính; không có phụ thuộc từng phần).
  * **3NF:** Thỏa mãn (mọi vế trái đều là siêu khóa).
* **Kết luận:** **Đạt 3NF**.

---

#### 7. Bảng: `CLIENT_PHONE` (Số điện thoại khách hàng)
* **Lược đồ quan hệ:** $\text{CLIENT\_PHONE}(\underline{\text{ClientID}}, \underline{\text{ContactPhone}})$
* **Tập phụ thuộc hàm ($F_7$):** Chỉ có các phụ thuộc hàm tầm thường.
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{ClientID, ContactPhone}\}$ (PK).
  * **Thuộc tính khóa:** `ClientID`, `ContactPhone`.
  * **Thuộc tính không khóa:** $\emptyset$ (Không có).
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn hiển nhiên.
* **Kết luận:** **Đạt 3NF**.

---

#### 8. Bảng: `PROJECT` (Dự án xây dựng)
* **Lược đồ quan hệ:** $\text{PROJECT}(\underline{\text{ProjectID}}, \text{ProjectName}, \text{StartDate}, \text{PlannedEndDate}, \text{ActualEndDate}, \text{EstimatedBudget}, \text{Status}, \text{ClientID}, \text{DeptID}, \text{DirectorEmpID})$
* **Tập phụ thuộc hàm ($F_8$):**
  * $FD_{8.1}: \text{ProjectID} \to \{\text{ProjectName, StartDate, PlannedEndDate, ActualEndDate, EstimatedBudget, Status, ClientID, DeptID, DirectorEmpID}\}$
  * $FD_{8.2}: \text{ProjectName} \to \{\text{ProjectID, StartDate, PlannedEndDate, ActualEndDate, EstimatedBudget, Status, ClientID, DeptID, DirectorEmpID}\}$ (Tên hợp đồng dự án là duy nhất).
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK_1 = \{\text{ProjectID}\}$ (PK), $CK_2 = \{\text{ProjectName}\}$ (AK).
  * **Thuộc tính khóa:** `ProjectID`, `ProjectName`.
  * **Thuộc tính không khóa:** `StartDate, PlannedEndDate, ActualEndDate, EstimatedBudget, Status, ClientID, DeptID, DirectorEmpID`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF:** Thỏa mãn (khóa đơn thuộc tính).
  * **3NF:** Thỏa mãn (định thức là siêu khóa; các khóa ngoại không gây phụ thuộc bắc cầu trong bảng).
* **Kết luận:** **Đạt 3NF**.

---

#### 9. Bảng: `PROJECT_SITE` (Công trường dự án)
* **Lược đồ quan hệ:** $\text{PROJECT\_SITE}(\underline{\text{SiteID}}, \text{ProjectID}, \text{SiteName}, \text{Latitude}, \text{Longitude}, \text{StreetAddress}, \text{District}, \text{City\_Province}, \text{EnvironmentalPermit}, \text{SiteStatus})$
* **Tập phụ thuộc hàm ($F_9$):**
  * $FD_{9.1}: \text{SiteID} \to \{\text{ProjectID, SiteName, Latitude, Longitude, StreetAddress, District, City_Province, EnvironmentalPermit, SiteStatus}\}$
  * $FD_{9.2}: \{\text{ProjectID, SiteName}\} \to \{\text{SiteID, Latitude, Longitude, StreetAddress, District, City_Province, EnvironmentalPermit, SiteStatus}\}$ (Tên công trường là duy nhất trong phạm vi dự án).
  * $FD_{9.3}: \{\text{Latitude, Longitude}\} \to \{\text{SiteID, ProjectID, SiteName, StreetAddress, District, City_Province, EnvironmentalPermit, SiteStatus}\}$ (Tọa độ địa lý xác định duy nhất vị trí).
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK_1 = \{\text{SiteID}\}$ (PK), $CK_2 = \{\text{ProjectID, SiteName}\}$ (AK), $CK_3 = \{\text{Latitude, Longitude}\}$ (AK).
  * **Thuộc tính khóa:** `SiteID`, `ProjectID`, `SiteName`, `Latitude`, `Longitude`.
  * **Thuộc tính không khóa:** `StreetAddress, District, City_Province, EnvironmentalPermit, SiteStatus`.
* **Đánh giá dạng chuẩn:**
  * **1NF:** Thỏa mãn.
  * **2NF:** Thỏa mãn (với các khóa phức hợp $CK_2$ và $CK_3$, không có tập con thực sự nào xác định thuộc tính không khóa).
  * **3NF:** Thỏa mãn (mọi định thức đều là siêu khóa).
* **Kết luận:** **Đạt 3NF**.

---

#### 10. Bảng: `PROJECT_PHASE` (Giai đoạn thi công dự án)
* **Lược đồ quan hệ:** $\text{PROJECT\_PHASE}(\underline{\text{ProjectID}}, \underline{\text{PhaseNumber}}, \text{PhaseTitle}, \text{StartDate}, \text{TargetCompletionDate}, \text{PhaseBudget}, \text{PhaseStatus})$
* **Tập phụ thuộc hàm ($F_{10}$):**
  * $FD_{10.1}: \{\text{ProjectID, PhaseNumber}\} \to \{\text{PhaseTitle, StartDate, TargetCompletionDate, PhaseBudget, PhaseStatus}\}$
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{ProjectID, PhaseNumber}\}$ (PK).
  * **Thuộc tính khóa:** `ProjectID`, `PhaseNumber`.
  * **Thuộc tính không khóa:** `PhaseTitle, StartDate, TargetCompletionDate, PhaseBudget, PhaseStatus`.
* **Đánh giá dạng chuẩn:**
  * **1NF:** Thỏa mãn.
  * **2NF:** Thỏa mãn (phụ thuộc hàm đầy đủ vào khóa phức hợp; `ProjectID` hay `PhaseNumber` đứng riêng lẻ không xác định được thông tin giai đoạn).
  * **3NF:** Thỏa mãn (định thức là khóa ứng viên).
* **Kết luận:** **Đạt 3NF**.

---

#### 11. Bảng: `TASK` (Gói công việc / Tác vụ)
* **Lược đồ quan hệ:** $\text{TASK}(\underline{\text{TaskID}}, \text{TaskName}, \text{EstimatedHours}, \text{ScheduledStartDate}, \text{ScheduledEndDate}, \text{ActualEndDate}, \text{PriorityLevel}, \text{TaskStatus}, \text{ProjectID}, \text{PhaseNumber})$
* **Tập phụ thuộc hàm ($F_{11}$):**
  * $FD_{11.1}: \text{TaskID} \to \{\text{TaskName, EstimatedHours, ScheduledStartDate, ScheduledEndDate, ActualEndDate, PriorityLevel, TaskStatus, ProjectID, PhaseNumber}\}$
  * $FD_{11.2}: \{\text{ProjectID, PhaseNumber, TaskName}\} \to \{\text{TaskID, EstimatedHours, ScheduledStartDate, ScheduledEndDate, ActualEndDate, PriorityLevel, TaskStatus}\}$
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK_1 = \{\text{TaskID}\}$ (PK), $CK_2 = \{\text{ProjectID, PhaseNumber, TaskName}\}$ (AK).
  * **Thuộc tính khóa:** `TaskID`, `ProjectID`, `PhaseNumber`, `TaskName`.
  * **Thuộc tính không khóa:** `EstimatedHours, ScheduledStartDate, ScheduledEndDate, ActualEndDate, PriorityLevel, TaskStatus`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF:** Thỏa mãn (không có phụ thuộc từng phần vào khóa ứng viên nào).
  * **3NF:** Thỏa mãn (mọi định thức đều là siêu khóa; khóa ngoại hợp thành `(ProjectID, PhaseNumber)` không kéo theo phụ thuộc bắc cầu nội bộ).
* **Kết luận:** **Đạt 3NF**.

---

#### 12. Bảng: `PRECEDES` (Thứ tự phụ thuộc công việc)
* **Lược đồ quan hệ:** $\text{PRECEDES}(\underline{\text{PredecessorTaskID}}, \underline{\text{SuccessorTaskID}})$
* **Tập phụ thuộc hàm ($F_{12}$):** Chỉ có các phụ thuộc hàm tầm thường.
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{PredecessorTaskID, SuccessorTaskID}\}$ (PK).
  * **Thuộc tính khóa:** `PredecessorTaskID`, `SuccessorTaskID`.
  * **Thuộc tính không khóa:** $\emptyset$ (Không có).
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn hiển nhiên.
* **Kết luận:** **Đạt 3NF**.

---

#### 13. Bảng: `WORKS_ON_TASK` (Phân công nhân công trên công việc)
* **Lược đồ quan hệ:** $\text{WORKS\_ON\_TASK}(\underline{\text{EmpID}}, \underline{\text{TaskID}}, \text{AssignedDate}, \text{RoleOnTask}, \text{HoursLogged})$
* **Tập phụ thuộc hàm ($F_{13}$):**
  * $FD_{13.1}: \{\text{EmpID, TaskID}\} \to \{\text{AssignedDate, RoleOnTask, HoursLogged}\}$
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{EmpID, TaskID}\}$ (PK).
  * **Thuộc tính khóa:** `EmpID`, `TaskID`.
  * **Thuộc tính không khóa:** `AssignedDate, RoleOnTask, HoursLogged`.
* **Đánh giá dạng chuẩn:**
  * **1NF:** Thỏa mãn.
  * **2NF:** Thỏa mãn (phụ thuộc hàm đầy đủ; `EmpID` hoặc `TaskID` đơn lẻ không xác định số giờ công).
  * **3NF:** Thỏa mãn (định thức là khóa ứng viên).
* **Kết luận:** **Đạt 3NF**.

---

### Phân hệ 3: Cơ giới & Bảo dưỡng Đội xe Thiết bị (Equipment)

#### 14. Bảng: `EQUIPMENT` (Máy móc & Thiết bị cơ giới)
* **Lược đồ quan hệ:** $\text{EQUIPMENT}(\underline{\text{EquipmentID}}, \text{Model}, \text{SerialNumber}, \text{Category}, \text{Ownership}, \text{HourlyRate}, \text{CurrentStatus})$
* **Tập phụ thuộc hàm ($F_{14}$):**
  * $FD_{14.1}: \text{EquipmentID} \to \{\text{Model, SerialNumber, Category, Ownership, HourlyRate, CurrentStatus}\}$
  * $FD_{14.2}: \text{SerialNumber} \to \{\text{EquipmentID, Model, Category, Ownership, HourlyRate, CurrentStatus}\}$ (Số khung / số seri của hãng là duy nhất).
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK_1 = \{\text{EquipmentID}\}$ (PK), $CK_2 = \{\text{SerialNumber}\}$ (AK).
  * **Thuộc tính khóa:** `EquipmentID`, `SerialNumber`.
  * **Thuộc tính không khóa:** `Model, Category, Ownership, HourlyRate, CurrentStatus`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF:** Thỏa mãn (khóa đơn thuộc tính).
  * **3NF:** Thỏa mãn (mọi định thức đều là siêu khóa).
* **Kết luận:** **Đạt 3NF**.

---

#### 15. Bảng: `MAINTENANCE_RECORD` (Nhật ký bảo dưỡng thiết bị)
* **Lược đồ quan hệ:** $\text{MAINTENANCE\_RECORD}(\underline{\text{EquipmentID}}, \underline{\text{RecordNumber}}, \text{ServiceDate}, \text{MaintenanceType}, \text{Cost}, \text{ServiceVendor})$
* **Tập phụ thuộc hàm ($F_{15}$):**
  * $FD_{15.1}: \{\text{EquipmentID, RecordNumber}\} \to \{\text{ServiceDate, MaintenanceType, Cost, ServiceVendor}\}$
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{EquipmentID, RecordNumber}\}$ (PK).
  * **Thuộc tính khóa:** `EquipmentID`, `RecordNumber`.
  * **Thuộc tính không khóa:** `ServiceDate, MaintenanceType, Cost, ServiceVendor`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF:** Thỏa mãn (phụ thuộc hàm đầy đủ vào khóa phức hợp).
  * **3NF:** Thỏa mãn (định thức là khóa ứng viên).
* **Kết luận:** **Đạt 3NF**.

---

#### 16. Bảng: `EQUIPMENT_DEPLOYMENT` (Điều động thiết bị ra công trường)

**1. Thiết kế ban đầu ở Phase 2 & Phát hiện lỗi:**
* **Lược đồ ban đầu:** $\text{EQUIPMENT\_DEPLOYMENT}(\underline{\text{EquipmentID}}, \underline{\text{SiteID}}, \underline{\text{DeploymentStartDate}}, \text{DeploymentEndDate}, \text{HoursOperated}, \text{OperatorEmpID})$
* **Khóa ban đầu & Phụ thuộc hàm thực tế:**
  * Khóa hợp thành ban đầu: $\{\text{EquipmentID, SiteID, DeploymentStartDate}\}$
  * Ràng buộc hậu cần ($FD_{16.1}$): $\{\text{EquipmentID, DeploymentStartDate}\} \to \{\text{SiteID, DeploymentEndDate, HoursOperated, OperatorEmpID}\}$ *(Một thiết bị tại một ngày bắt đầu điều động chỉ có thể ở duy nhất 1 công trường)*.
* **Xung đột & Vi phạm 2NF:**
  * Trong $FD_{16.1}$, thuộc tính $\text{SiteID}$ bị xác định hàm bởi $\{\text{EquipmentID, DeploymentStartDate}\}$, vốn là một **tập con thực sự** của khóa chính 3 thuộc tính ban đầu.
  * Điều này tạo ra hiện tượng **Phụ thuộc từng phần vào khóa (Partial Key Dependency)**, vi phạm trực tiếp **2NF**. Khóa chính ban đầu bị thừa thuộc tính, không đạt tính tối thiểu.

**2. Giải pháp giải quyết xung đột & Lược đồ chuẩn hóa (Đạt chuẩn 3NF):**
* **Giải pháp giải quyết xung đột:** Đưa $\text{SiteID}$ ra khỏi khóa chính và chuyển thành thuộc tính thường (khóa ngoại trỏ về `PROJECT_SITE`). Khóa chính được rút gọn về 2 thuộc tính tối thiểu $\{\text{EquipmentID}, \text{DeploymentStartDate}\}$, triệt tiêu hoàn toàn vi phạm phụ thuộc từng phần mà vẫn bảo toàn liên kết công trường.
* **Lược đồ chuẩn hóa:** $\text{EQUIPMENT\_DEPLOYMENT}(\underline{\text{EquipmentID}}, \underline{\text{DeploymentStartDate}}, \text{SiteID}, \text{DeploymentEndDate}, \text{HoursOperated}, \text{OperatorEmpID})$
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{EquipmentID, DeploymentStartDate}\}$ (PK tối thiểu).
  * **Thuộc tính khóa:** `EquipmentID`, `DeploymentStartDate`.
  * **Thuộc tính không khóa:** `SiteID, DeploymentEndDate, HoursOperated, OperatorEmpID`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF:** Thỏa mãn (tất cả thuộc tính không khóa đều phụ thuộc đầy đủ vào khóa 2 thuộc tính tối thiểu; triệt tiêu hoàn toàn vi phạm phụ thuộc từng phần).
  * **3NF:** Thỏa mãn (định thức duy nhất là siêu khóa; không có phụ thuộc bắc cầu).
* **Kết luận:** **Đạt 3NF**.

---

### Phân hệ 4: Mua sắm, Vật tư & Tồn kho Công trường (Materials & Procurement)

#### 17. Bảng: `SUPPLIER` (Nhà cung cấp vật tư)
* **Lược đồ quan hệ:** $\text{SUPPLIER}(\underline{\text{SupplierID}}, \text{CompanyName}, \text{TaxCode}, \text{ContactEmail}, \text{CreditRating})$
* **Tập phụ thuộc hàm ($F_{17}$):**
  * $FD_{17.1}: \text{SupplierID} \to \{\text{CompanyName, TaxCode, ContactEmail, CreditRating}\}$
  * $FD_{17.2}: \text{TaxCode} \to \{\text{SupplierID, CompanyName, ContactEmail, CreditRating}\}$ (Mã số thuế doanh nghiệp là duy nhất).
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK_1 = \{\text{SupplierID}\}$ (PK), $CK_2 = \{\text{TaxCode}\}$ (AK).
  * **Thuộc tính khóa:** `SupplierID`, `TaxCode`.
  * **Thuộc tính không khóa:** `CompanyName, ContactEmail, CreditRating`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn (khóa đơn thuộc tính; định thức là siêu khóa).
* **Kết luận:** **Đạt 3NF**.

---

#### 18. Bảng: `SUPPLIER_PHONE` (Số điện thoại nhà cung cấp)
* **Lược đồ quan hệ:** $\text{SUPPLIER\_PHONE}(\underline{\text{SupplierID}}, \underline{\text{ContactPhone}})$
* **Tập phụ thuộc hàm ($F_{18}$):** Chỉ có các phụ thuộc hàm tầm thường.
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{SupplierID, ContactPhone}\}$ (PK).
  * **Thuộc tính khóa:** `SupplierID`, `ContactPhone`.
  * **Thuộc tính không khóa:** $\emptyset$ (Không có).
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn hiển nhiên.
* **Kết luận:** **Đạt 3NF**.

---

#### 19. Bảng: `SUPPLIER_CATEGORY` (Ngành hàng của nhà cung cấp)
* **Lược đồ quan hệ:** $\text{SUPPLIER\_CATEGORY}(\underline{\text{SupplierID}}, \underline{\text{SupplyCategory}})$
* **Tập phụ thuộc hàm ($F_{19}$):** Chỉ có các phụ thuộc hàm tầm thường.
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{SupplierID, SupplyCategory}\}$ (PK).
  * **Thuộc tính khóa:** `SupplierID`, `SupplyCategory`.
  * **Thuộc tính không khóa:** $\emptyset$ (Không có).
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn hiển nhiên.
* **Kết luận:** **Đạt 3NF**.

---

#### 20. Bảng: `MATERIAL` (Danh mục vật tư tiêu chuẩn)
* **Lược đồ quan hệ:** $\text{MATERIAL}(\underline{\text{MaterialID}}, \text{MaterialName}, \text{Category}, \text{StandardUnit}, \text{UnitPrice}, \text{MinStock})$
* **Tập phụ thuộc hàm ($F_{20}$):**
  * $FD_{20.1}: \text{MaterialID} \to \{\text{MaterialName, Category, StandardUnit, UnitPrice, MinStock}\}$
  * $FD_{20.2}: \text{MaterialName} \to \{\text{MaterialID, Category, StandardUnit, UnitPrice, MinStock}\}$ (Tên quy cách vật tư là duy nhất trong danh mục).
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK_1 = \{\text{MaterialID}\}$ (PK), $CK_2 = \{\text{MaterialName}\}$ (AK).
  * **Thuộc tính khóa:** `MaterialID`, `MaterialName`.
  * **Thuộc tính không khóa:** `Category, StandardUnit, UnitPrice, MinStock`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn (khóa đơn thuộc tính; định thức là siêu khóa).
* **Kết luận:** **Đạt 3NF**.

---

#### 21. Bảng: `PURCHASE_ORDER` (Đơn đặt hàng mua vật tư)
* **Lược đồ quan hệ:** $\text{PURCHASE\_ORDER}(\underline{\text{PO\_ID}}, \text{OrderDate}, \text{ExpectedDeliveryDate}, \text{DeliveryStatus}, \text{ProjectID}, \text{SupplierID})$
* **Tập phụ thuộc hàm ($F_{21}$):**
  * $FD_{21.1}: \text{PO\_ID} \to \{\text{OrderDate, ExpectedDeliveryDate, DeliveryStatus, ProjectID, SupplierID}\}$
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{PO\_ID}\}$ (PK).
  * **Thuộc tính khóa:** `PO_ID`.
  * **Thuộc tính không khóa:** `OrderDate, ExpectedDeliveryDate, DeliveryStatus, ProjectID, SupplierID`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn (khóa đơn thuộc tính; định thức là siêu khóa).
* **Kết luận:** **Đạt 3NF**.

---

#### 22. Bảng: `PO_ITEM` (Chi tiết dòng đơn đặt hàng)
* **Lược đồ quan hệ:** $\text{PO\_ITEM}(\underline{\text{PO\_ID}}, \underline{\text{LineNumber}}, \text{QuantityOrdered}, \text{AgreedUnitPrice}, \text{MaterialID})$
* **Tập phụ thuộc hàm ($F_{22}$):**
  * $FD_{22.1}: \{\text{PO\_ID, LineNumber}\} \to \{\text{QuantityOrdered, AgreedUnitPrice, MaterialID}\}$
  * $FD_{22.2}: \{\text{PO\_ID, MaterialID}\} \to \{\text{LineNumber, QuantityOrdered, AgreedUnitPrice}\}$ (Một mặt hàng vật tư chỉ xuất hiện một lần trên mỗi đơn hàng).
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK_1 = \{\text{PO\_ID, LineNumber}\}$ (PK), $CK_2 = \{\text{PO\_ID, MaterialID}\}$ (AK).
  * **Thuộc tính khóa:** `PO_ID`, `LineNumber`, `MaterialID`.
  * **Thuộc tính không khóa:** `QuantityOrdered`, `AgreedUnitPrice`.
* **Đánh giá dạng chuẩn:**
  * **1NF:** Thỏa mãn.
  * **2NF:** Thỏa mãn (phụ thuộc hàm đầy đủ vào khóa).
  * **3NF:** Thỏa mãn (các định thức đều là khóa ứng viên; `AgreedUnitPrice` là đơn giá đàm phán chốt riêng cho đơn hàng nên không phụ thuộc vào `MaterialID`, không có phụ thuộc bắc cầu).
* **Kết luận:** **Đạt 3NF**.

---

#### 23. Bảng: `SITE_INVENTORY` (Tồn kho vật tư tại công trường)
* **Lược đồ quan hệ:** $\text{SITE\_INVENTORY}(\underline{\text{SiteID}}, \underline{\text{MaterialID}}, \text{CurrentStockQuantity}, \text{SafetyReorderQuantity}, \text{LastStocktakeDate})$
* **Tập phụ thuộc hàm ($F_{23}$):**
  * $FD_{23.1}: \{\text{SiteID, MaterialID}\} \to \{\text{CurrentStockQuantity, SafetyReorderQuantity, LastStocktakeDate}\}$
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{SiteID, MaterialID}\}$ (PK).
  * **Thuộc tính khóa:** `SiteID`, `MaterialID`.
  * **Thuộc tính không khóa:** `CurrentStockQuantity, SafetyReorderQuantity, LastStocktakeDate`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn (phụ thuộc hàm đầy đủ vào khóa phức hợp; định thức là khóa).
* **Kết luận:** **Đạt 3NF**.

---

#### 24. Bảng: `DELIVERY_DISPATCH` (Phiếu giao nhận vật tư tại công trường)

**1. Thiết kế ban đầu ở Phase 2 & Phát hiện lỗi:**
* **Lược đồ ban đầu:** $\text{DELIVERY\_DISPATCH}(\underline{\text{DeliveryCode}}, \text{SupplierID}, \text{MaterialID}, \text{SiteID}, \text{DeliveryDate}, \text{DeliveredQuantity}, \text{ReceivedByEmpID}, \text{PO\_ID})$
* **Khóa ban đầu & Phụ thuộc hàm:**
  * Khóa ứng viên: $\{\text{DeliveryCode}\}$
  * $FD_{24.1}: \text{DeliveryCode} \to \{\text{SupplierID, MaterialID, SiteID, DeliveryDate, DeliveredQuantity, ReceivedByEmpID, PO\_ID}\}$
  * $FD_{24.2}: \text{PO\_ID} \to \text{SupplierID}$ *(Mỗi đơn đặt hàng chỉ gửi đến đúng một nhà cung cấp theo `PURCHASE_ORDER`)*.
* **Xung đột & Vi phạm 3NF:**
  * Trong $FD_{24.2}$, $\text{PO\_ID}$ **không phải là siêu khóa** của `DELIVERY_DISPATCH` (một đơn hàng có thể được giao thành nhiều đợt), và $\text{SupplierID}$ là **thuộc tính không khóa**.
  * Điều này tạo ra một **Phụ thuộc bắc cầu (Transitive Dependency)**:
    $$\text{DeliveryCode} \to \text{PO\_ID} \to \text{SupplierID}$$
    vi phạm trực tiếp **3NF**.
  * **Hậu quả nghiệp vụ:** Dư thừa dữ liệu (lặp lại mã nhà cung cấp trên từng phiếu giao hàng) và gây dị thường cập nhật (nếu điều chỉnh thông tin nhà cung cấp trên PO sẽ gây bất nhất với phiếu giao).

**2. Giải pháp giải quyết xung đột & Lược đồ chuẩn hóa (Đạt chuẩn 3NF):**
* **Giải pháp giải quyết xung đột:** Loại bỏ thuộc tính $\text{SupplierID}$ khỏi `DELIVERY_DISPATCH`. Vì phụ thuộc $\text{PO\_ID} \to \text{SupplierID}$ đã được bảo toàn ở bảng `PURCHASE_ORDER`, thông tin nhà cung cấp được truy xuất không mất mát thông tin qua khóa ngoại $\text{PO\_ID}$, triệt tiêu hoàn toàn phụ thuộc bắc cầu và loại bỏ dị thường cập nhật.
* **Lược đồ chuẩn hóa:** $\text{DELIVERY\_DISPATCH}(\underline{\text{DeliveryCode}}, \text{MaterialID}, \text{SiteID}, \text{DeliveryDate}, \text{DeliveredQuantity}, \text{ReceivedByEmpID}, \text{PO\_ID})$
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{DeliveryCode}\}$ (PK).
  * **Thuộc tính khóa:** `DeliveryCode`.
  * **Thuộc tính không khóa:** `MaterialID, SiteID, DeliveryDate, DeliveredQuantity, ReceivedByEmpID, PO_ID`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF:** Thỏa mãn (khóa đơn thuộc tính).
  * **3NF:** Thỏa mãn (việc loại bỏ $\text{SupplierID}$ đã triệt tiêu hoàn toàn phụ thuộc bắc cầu; mối quan hệ với nhà cung cấp được bảo toàn không mất mát qua khóa ngoại $\text{PO\_ID} \to \text{PURCHASE\_ORDER}$).
* **Kết luận:** **Đạt 3NF**.

---

#### 25. Bảng: `MATERIAL_USAGE` (Nhật ký tiêu hao vật tư tại công trường)
* **Lược đồ quan hệ:** $\text{MATERIAL\_USAGE}(\underline{\text{TaskID}}, \underline{\text{MaterialID}}, \underline{\text{SiteID}}, \underline{\text{UsageDate}}, \text{QuantityUsed})$
* **Tập phụ thuộc hàm ($F_{25}$):**
  * $FD_{25.1}: \{\text{TaskID, MaterialID, SiteID, UsageDate}\} \to \{\text{QuantityUsed}\}$
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{TaskID, MaterialID, SiteID, UsageDate}\}$ (PK).
  * **Thuộc tính khóa:** `TaskID`, `MaterialID`, `SiteID`, `UsageDate`.
  * **Thuộc tính không khóa:** `QuantityUsed`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn (phụ thuộc hàm đầy đủ vào khóa 4 thành phần; định thức là khóa ứng viên).
* **Kết luận:** **Đạt 3NF**.

---

### Phân hệ 5: Quản lý Nhà thầu phụ (Subcontractors)

#### 26. Bảng: `SUBCONTRACTOR` (Nhà thầu phụ chuyên ngành)
* **Lược đồ quan hệ:** $\text{SUBCONTRACTOR}(\underline{\text{SubcontractorID}}, \text{CompanyName}, \text{TaxCode}, \text{ContactEmail}, \text{ContactPhone}, \text{TradeSpecialty}, \text{LicenseNumber}, \text{SafetyRatingScore})$
* **Tập phụ thuộc hàm ($F_{26}$):**
  * $FD_{26.1}: \text{SubcontractorID} \to \{\text{CompanyName, TaxCode, ContactEmail, ContactPhone, TradeSpecialty, LicenseNumber, SafetyRatingScore}\}$
  * $FD_{26.2}: \text{TaxCode} \to \{\text{SubcontractorID, CompanyName, ContactEmail, ContactPhone, TradeSpecialty, LicenseNumber, SafetyRatingScore}\}$
  * $FD_{26.3}: \text{LicenseNumber} \to \{\text{SubcontractorID, CompanyName, TaxCode, ContactEmail, ContactPhone, TradeSpecialty, SafetyRatingScore}\}$ (Giấy phép thi công chuyên ngành là duy nhất).
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK_1 = \{\text{SubcontractorID}\}$ (PK), $CK_2 = \{\text{TaxCode}\}$ (AK), $CK_3 = \{\text{LicenseNumber}\}$ (AK).
  * **Thuộc tính khóa:** `SubcontractorID`, `TaxCode`, `LicenseNumber`.
  * **Thuộc tính không khóa:** `CompanyName, ContactEmail, ContactPhone, TradeSpecialty, SafetyRatingScore`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn (mọi định thức đều là siêu khóa).
* **Kết luận:** **Đạt 3NF**.

---

#### 27. Bảng: `SUBCONTRACT` (Hợp đồng giao khoán nhà thầu phụ)
* **Lược đồ quan hệ:** $\text{SUBCONTRACT}(\underline{\text{ContractAgreementNo}}, \text{ProjectID}, \text{SubcontractorID}, \text{ScopeDescription}, \text{ContractValue}, \text{WarrantyHoldRate}, \text{StartDate}, \text{CompletionDate})$
* **Tập phụ thuộc hàm ($F_{27}$):**
  * $FD_{27.1}: \text{ContractAgreementNo} \to \{\text{ProjectID, SubcontractorID, ScopeDescription, ContractValue, WarrantyHoldRate, StartDate, CompletionDate}\}$
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{ContractAgreementNo}\}$ (PK).
  * **Thuộc tính khóa:** `ContractAgreementNo`.
  * **Thuộc tính không khóa:** `ProjectID, SubcontractorID, ScopeDescription, ContractValue, WarrantyHoldRate, StartDate, CompletionDate`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn (khóa đơn thuộc tính; định thức là siêu khóa).
* **Kết luận:** **Đạt 3NF**.

---

### Phân hệ 6: An toàn Lao động, Sức khỏe & Môi trường (HSE)

#### 28. Bảng: `SAFETY_INSPECTION` (Kiểm định an toàn công trường)
* **Lược đồ quan hệ:** $\text{SAFETY\_INSPECTION}(\underline{\text{InspectionID}}, \text{InspectionDate}, \text{InspectionType}, \text{InspectionScope}, \text{OverallScore}, \text{InspectionResult}, \text{ViolationNoted}, \text{FixDeadline}, \text{SiteID}, \text{InspectorEmpID})$
* **Tập phụ thuộc hàm ($F_{28}$):**
  * $FD_{28.1}: \text{InspectionID} \to \{\text{InspectionDate, InspectionType, InspectionScope, OverallScore, InspectionResult, ViolationNoted, FixDeadline, SiteID, InspectorEmpID}\}$
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{InspectionID}\}$ (PK).
  * **Thuộc tính khóa:** `InspectionID`.
  * **Thuộc tính không khóa:** `InspectionDate, InspectionType, InspectionScope, OverallScore, InspectionResult, ViolationNoted, FixDeadline, SiteID, InspectorEmpID`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn (khóa đơn thuộc tính; định thức là siêu khóa).
* **Kết luận:** **Đạt 3NF**.

---

#### 29. Bảng: `INCIDENT_REPORT` (Báo cáo sự cố an toàn & tai nạn)
* **Lược đồ quan hệ:** $\text{INCIDENT\_REPORT}(\underline{\text{IncidentID}}, \text{IncidentTimestamp}, \text{IncidentType}, \text{IncidentLevel}, \text{DamageDescription}, \text{LostDays}, \text{Solution}, \text{SiteID}, \text{InvolvedEmpID}, \text{DamagedEquipmentID})$
* **Tập phụ thuộc hàm ($F_{29}$):**
  * $FD_{29.1}: \text{IncidentID} \to \{\text{IncidentTimestamp, IncidentType, IncidentLevel, DamageDescription, LostDays, Solution, SiteID, InvolvedEmpID, DamagedEquipmentID}\}$
* **Khóa ứng viên & Phân loại thuộc tính:**
  * **Khóa ứng viên:** $CK = \{\text{IncidentID}\}$ (PK).
  * **Thuộc tính khóa:** `IncidentID`.
  * **Thuộc tính không khóa:** `IncidentTimestamp, IncidentType, IncidentLevel, DamageDescription, LostDays, Solution, SiteID, InvolvedEmpID, DamagedEquipmentID`.
* **Đánh giá dạng chuẩn:**
  * **1NF / 2NF / 3NF:** Thỏa mãn (khóa đơn thuộc tính; định thức là siêu khóa).
* **Kết luận:** **Đạt 3NF**.

---

## 3. Bảng Tổng hợp Toàn diện 29 Lược đồ Quan hệ Đạt chuẩn 3NF

Bảng tổng hợp dưới đây hệ thống hóa toàn bộ 29 bảng quan hệ của hệ thống sau chuẩn hóa, xác định rõ Khóa chính (PK), Khóa thay thế (AK), Khóa ngoại (FK) kèm bảng tham chiếu và Dạng chuẩn đã đạt được:

| STT | Tên Lược đồ Quan hệ | Khóa chính (PK) | Khóa thay thế (AK) | Khóa ngoại (FK) & Bảng tham chiếu | Dạng chuẩn Đạt được |
| :---: | :--- | :--- | :--- | :--- | :---: |
| **1** | `DEPARTMENT` | `DeptID` | `DeptName`, `HeadEmpID` | `HeadEmpID` $\to$ `EMPLOYEE(EmpID)` | **3NF** |
| **2** | `EMPLOYEE` | `EmpID` | `Email` | `DeptID` $\to$ `DEPARTMENT`, `SupervisorID` $\to$ `EMPLOYEE` | **3NF** |
| **3** | `EMPLOYEE_PHONE` | `(EmpID, PhoneNumber)` | *Không có* | `EmpID` $\to$ `EMPLOYEE` | **3NF** |
| **4** | `EMPLOYEE_CERTIFICATION` | `(EmpID, Certification)` | *Không có* | `EmpID` $\to$ `EMPLOYEE` | **3NF** |
| **5** | `DEPENDENT` | `(EmpID, DependentName)` | *Không có* | `EmpID` $\to$ `EMPLOYEE` | **3NF** |
| **6** | `CLIENT` | `ClientID` | `TaxCode` | *Không có* | **3NF** |
| **7** | `CLIENT_PHONE` | `(ClientID, ContactPhone)` | *Không có* | `ClientID` $\to$ `CLIENT` | **3NF** |
| **8** | `PROJECT` | `ProjectID` | `ProjectName` | `ClientID` $\to$ `CLIENT`, `DeptID` $\to$ `DEPARTMENT`, `DirectorEmpID` $\to$ `EMPLOYEE` | **3NF** |
| **9** | `PROJECT_SITE` | `SiteID` | `(ProjectID, SiteName)`, `(Latitude, Longitude)` | `ProjectID` $\to$ `PROJECT` | **3NF** |
| **10** | `PROJECT_PHASE` | `(ProjectID, PhaseNumber)` | *Không có* | `ProjectID` $\to$ `PROJECT` | **3NF** |
| **11** | `TASK` | `TaskID` | `(ProjectID, PhaseNumber, TaskName)` | `(ProjectID, PhaseNumber)` $\to$ `PROJECT_PHASE` | **3NF** |
| **12** | `PRECEDES` | `(PredecessorTaskID, SuccessorTaskID)` | *Không có* | `PredecessorTaskID` $\to$ `TASK`, `SuccessorTaskID` $\to$ `TASK` | **3NF** |
| **13** | `WORKS_ON_TASK` | `(EmpID, TaskID)` | *Không có* | `EmpID` $\to$ `EMPLOYEE`, `TaskID` $\to$ `TASK` | **3NF** |
| **14** | `EQUIPMENT` | `EquipmentID` | `SerialNumber` | *Không có* | **3NF** |
| **15** | `MAINTENANCE_RECORD` | `(EquipmentID, RecordNumber)` | *Không có* | `EquipmentID` $\to$ `EQUIPMENT` | **3NF** |
| **16** | `EQUIPMENT_DEPLOYMENT` | `(EquipmentID, DeploymentStartDate)` | *Không có* | `EquipmentID` $\to$ `EQUIPMENT`, `SiteID` $\to$ `PROJECT_SITE`, `OperatorEmpID` $\to$ `EMPLOYEE` | **3NF** |
| **17** | `SUPPLIER` | `SupplierID` | `TaxCode` | *Không có* | **3NF** |
| **18** | `SUPPLIER_PHONE` | `(SupplierID, ContactPhone)` | *Không có* | `SupplierID` $\to$ `SUPPLIER` | **3NF** |
| **19** | `SUPPLIER_CATEGORY` | `(SupplierID, SupplyCategory)` | *Không có* | `SupplierID` $\to$ `SUPPLIER` | **3NF** |
| **20** | `MATERIAL` | `MaterialID` | `MaterialName` | *Không có* | **3NF** |
| **21** | `PURCHASE_ORDER` | `PO_ID` | *Không có* | `ProjectID` $\to$ `PROJECT`, `SupplierID` $\to$ `SUPPLIER` | **3NF** |
| **22** | `PO_ITEM` | `(PO_ID, LineNumber)` | `(PO_ID, MaterialID)` | `PO_ID` $\to$ `PURCHASE_ORDER`, `MaterialID` $\to$ `MATERIAL` | **3NF** |
| **23** | `SITE_INVENTORY` | `(SiteID, MaterialID)` | *Không có* | `SiteID` $\to$ `PROJECT_SITE`, `MaterialID` $\to$ `MATERIAL` | **3NF** |
| **24** | `DELIVERY_DISPATCH` | `DeliveryCode` | *Không có* | `MaterialID` $\to$ `MATERIAL`, `SiteID` $\to$ `PROJECT_SITE`, `ReceivedByEmpID` $\to$ `EMPLOYEE`, `PO_ID` $\to$ `PURCHASE_ORDER` | **3NF** |
| **25** | `MATERIAL_USAGE` | `(TaskID, MaterialID, SiteID, UsageDate)` | *Không có* | `TaskID` $\to$ `TASK`, `(SiteID, MaterialID)` $\to$ `SITE_INVENTORY` | **3NF** |
| **26** | `SUBCONTRACTOR` | `SubcontractorID` | `TaxCode`, `LicenseNumber` | *Không có* | **3NF** |
| **27** | `SUBCONTRACT` | `ContractAgreementNo` | *Không có* | `ProjectID` $\to$ `PROJECT`, `SubcontractorID` $\to$ `SUBCONTRACTOR` | **3NF** |
| **28** | `SAFETY_INSPECTION` | `InspectionID` | *Không có* | `SiteID` $\to$ `PROJECT_SITE`, `InspectorEmpID` $\to$ `EMPLOYEE` | **3NF** |
| **29** | `INCIDENT_REPORT` | `IncidentID` | *Không có* | `SiteID` $\to$ `PROJECT_SITE`, `InvolvedEmpID` $\to$ `EMPLOYEE`, `DamagedEquipmentID` $\to$ `EQUIPMENT` | **3NF** |
