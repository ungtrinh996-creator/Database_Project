# Database Design Term Project (Phase 3)
## Task 1: Functional Dependencies, Candidate Keys & Normalization Analysis (3NF)

- **Topic:** Database System for a Multi-Project Construction Enterprise (A34Build)
- **Course:** Database Systems [E24-Class 5]
- **Team:** 5
- **Members:**
  - Lê Anh Minh (B24DCCE180)
  - Ứng Trọng Trình (B24DCCE271)
  - Nguyễn Đinh Anh Quân (B24DCCE222)
- **Instructor:** Dr. Nguyen Dinh Hoa (`hoand@ptit.edu.vn`)
- **Textbook Reference:** *Fundamentals of Database Systems*, 6th Edition (R. Elmasri & S. B. Navathe, Chapter 14)

---

## 1. Overview & Normalization Summary

This section audits the 29 relational schemas mapped from the Phase 2 ERD to ensure 3NF compliance (Elmasri & Navathe, Ch. 14).

### Key Findings
* **27 schemas** satisfy 3NF directly.
* **2 schemas** contained structural design defects from initial ERD mapping and were corrected:

| Table | Initial Defect (Phase 2) | Violation | 3NF Correction (Phase 3) |
| :--- | :--- | :---: | :--- |
| **16. `EQUIPMENT_DEPLOYMENT`** | $\text{SiteID}$ was in the PK: $(\underline{\text{EquipmentID}}, \underline{\text{SiteID}}, \underline{\text{DeploymentStartDate}})$, but $\{\text{EquipmentID}, \text{DeploymentStartDate}\} \to \text{SiteID}$. | **2NF**<br>(Partial Key Dependency) | Moved $\text{SiteID}$ out of PK into a non-prime FK. Minimal PK: $(\underline{\text{EquipmentID}}, \underline{\text{DeploymentStartDate}})$. |
| **24. `DELIVERY_DISPATCH`** | Contained both $\text{PO\_ID}$ and $\text{SupplierID}$, where $\text{PO\_ID} \to \text{SupplierID}$ via `PURCHASE_ORDER`. | **3NF**<br>(Transitive Dependency:<br>$\text{DeliveryCode} \to \text{PO\_ID} \to \text{SupplierID}$) | Removed $\text{SupplierID}$. Vendor is resolved via FK $\text{PO\_ID} \to \text{PURCHASE\_ORDER}$. |

---

## 2. Detailed Normalization Analysis for All 29 Schemas

Each table is evaluated using a uniform template: Relational Schema, Functional Dependencies ($F$), Candidate Keys, Attribute Classification, and Normal Form Verification (1NF $\to$ 2NF $\to$ 3NF).

---

### Subsystem 1: Organization & Human Resources

#### 1. Table: `DEPARTMENT`
* **Relational Schema:** $\text{DEPARTMENT}(\underline{\text{DeptID}}, \text{DeptName}, \text{OfficeLocation}, \text{Budget}, \text{HeadEmpID})$
* **Functional Dependencies ($F_1$):**
  * $FD_{1.1}: \text{DeptID} \to \{\text{DeptName, OfficeLocation, Budget, HeadEmpID}\}$ (Department ID uniquely identifies the department).
  * $FD_{1.2}: \text{DeptName} \to \{\text{DeptID, OfficeLocation, Budget, HeadEmpID}\}$ (Department name is unique enterprise-wide).
  * $FD_{1.3}: \text{HeadEmpID} \to \{\text{DeptID, DeptName, OfficeLocation, Budget}\}$ (An employee heads at most one department).
* **Candidate Keys & Attributes:**
  * **Candidate Keys:** $CK_1 = \{\text{DeptID}\}$ (PK), $CK_2 = \{\text{DeptName}\}$ (AK), $CK_3 = \{\text{HeadEmpID}\}$ (AK).
  * **Prime Attributes:** `DeptID`, `DeptName`, `HeadEmpID`.
  * **Non-Prime Attributes:** `OfficeLocation`, `Budget`.
* **Normal Form Evaluation:**
  * **1NF:** Satisfied (atomic domains).
  * **2NF:** Satisfied (all candidate keys are single attributes; no partial dependencies possible).
  * **3NF:** Satisfied (all determinants are superkeys; no transitive dependencies of non-prime attributes).
* **Conclusion:** **Achieves 3NF**.

---

#### 2. Table: `EMPLOYEE`
* **Relational Schema:** $\text{EMPLOYEE}(\underline{\text{EmpID}}, \text{FirstName}, \text{MiddleName}, \text{LastName}, \text{Street}, \text{Ward}, \text{District}, \text{City}, \text{DOB}, \text{HireDate}, \text{Salary}, \text{JobTitle}, \text{Email}, \text{DeptID}, \text{SupervisorID})$
* **Functional Dependencies ($F_2$):**
  * $FD_{2.1}: \text{EmpID} \to \{\text{FirstName, MiddleName, LastName, Street, Ward, District, City, DOB, HireDate, Salary, JobTitle, Email, DeptID, SupervisorID}\}$ (Employee ID uniquely identifies the employee).
  * $FD_{2.2}: \text{Email} \to \{\text{EmpID, FirstName, MiddleName, LastName, Street, Ward, District, City, DOB, HireDate, Salary, JobTitle, DeptID, SupervisorID}\}$ (Corporate email is unique).
* **Candidate Keys & Attributes:**
  * **Candidate Keys:** $CK_1 = \{\text{EmpID}\}$ (PK), $CK_2 = \{\text{Email}\}$ (AK).
  * **Prime Attributes:** `EmpID`, `Email`.
  * **Non-Prime Attributes:** `FirstName, MiddleName, LastName, Street, Ward, District, City, DOB, HireDate, Salary, JobTitle, DeptID, SupervisorID`.
* **Normal Form Evaluation:**
  * **1NF:** Satisfied (composite name and address attributes decomposed into atomic columns; multivalued attributes separated).
  * **2NF:** Satisfied (candidate keys are single attributes; no partial dependencies).
  * **3NF:** Satisfied (all determinants are superkeys; no transitive dependencies).
* **Conclusion:** **Achieves 3NF**.

---

#### 3. Table: `EMPLOYEE_PHONE`
* **Relational Schema:** $\text{EMPLOYEE\_PHONE}(\underline{\text{EmpID}}, \underline{\text{PhoneNumber}})$
* **Functional Dependencies ($F_3$):** Trivial dependencies only ($\{\text{EmpID, PhoneNumber}\} \to \{\text{EmpID, PhoneNumber}\}$).
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{EmpID, PhoneNumber}\}$ (PK).
  * **Prime Attributes:** `EmpID`, `PhoneNumber`.
  * **Non-Prime Attributes:** $\emptyset$ (None).
* **Normal Form Evaluation:**
  * **1NF:** Satisfied (single atomic phone number per tuple).
  * **2NF / 3NF:** Trivially satisfied (all attributes are prime).
* **Conclusion:** **Achieves 3NF**.

---

#### 4. Table: `EMPLOYEE_CERTIFICATION`
* **Relational Schema:** $\text{EMPLOYEE\_CERTIFICATION}(\underline{\text{EmpID}}, \underline{\text{Certification}})$
* **Functional Dependencies ($F_4$):** Trivial dependencies only.
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{EmpID, Certification}\}$ (PK).
  * **Prime Attributes:** `EmpID`, `Certification`.
  * **Non-Prime Attributes:** $\emptyset$ (None).
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Trivially satisfied (all attributes are prime).
* **Conclusion:** **Achieves 3NF**.

---

#### 5. Table: `DEPENDENT`
* **Relational Schema:** $\text{DEPENDENT}(\underline{\text{EmpID}}, \underline{\text{DependentName}}, \text{Gender}, \text{BirthDate}, \text{Relationship}, \text{ContactPhone}, \text{IsEmergencyContact})$
* **Functional Dependencies ($F_5$):**
  * $FD_{5.1}: \{\text{EmpID, DependentName}\} \to \{\text{Gender, BirthDate, Relationship, ContactPhone, IsEmergencyContact}\}$ (Weak entity identified by employee and partial key).
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{EmpID, DependentName}\}$ (PK).
  * **Prime Attributes:** `EmpID`, `DependentName`.
  * **Non-Prime Attributes:** `Gender, BirthDate, Relationship, ContactPhone, IsEmergencyContact`.
* **Normal Form Evaluation:**
  * **1NF:** Satisfied (atomic domains).
  * **2NF:** Satisfied (neither `EmpID` alone nor `DependentName` alone determines dependent attributes; no partial dependency).
  * **3NF:** Satisfied (determinant is the candidate key; no transitive dependencies).
* **Conclusion:** **Achieves 3NF**.

---

### Subsystem 2: Project Management & Work Breakdown Structure (WBS)

#### 6. Table: `CLIENT`
* **Relational Schema:** $\text{CLIENT}(\underline{\text{ClientID}}, \text{ClientName}, \text{ClientType}, \text{ContactPerson}, \text{ContactEmail}, \text{TaxCode})$
* **Functional Dependencies ($F_6$):**
  * $FD_{6.1}: \text{ClientID} \to \{\text{ClientName, ClientType, ContactPerson, ContactEmail, TaxCode}\}$
  * $FD_{6.2}: \text{TaxCode} \to \{\text{ClientID, ClientName, ClientType, ContactPerson, ContactEmail}\}$ (Corporate tax code is unique).
* **Candidate Keys & Attributes:**
  * **Candidate Keys:** $CK_1 = \{\text{ClientID}\}$ (PK), $CK_2 = \{\text{TaxCode}\}$ (AK).
  * **Prime Attributes:** `ClientID`, `TaxCode`.
  * **Non-Prime Attributes:** `ClientName, ClientType, ContactPerson, ContactEmail`.
* **Normal Form Evaluation:**
  * **1NF / 2NF:** Satisfied (single-attribute keys; no partial dependencies).
  * **3NF:** Satisfied (all determinants are superkeys).
* **Conclusion:** **Achieves 3NF**.

---

#### 7. Table: `CLIENT_PHONE`
* **Relational Schema:** $\text{CLIENT\_PHONE}(\underline{\text{ClientID}}, \underline{\text{ContactPhone}})$
* **Functional Dependencies ($F_7$):** Trivial dependencies only.
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{ClientID, ContactPhone}\}$ (PK).
  * **Prime Attributes:** `ClientID`, `ContactPhone`.
  * **Non-Prime Attributes:** $\emptyset$ (None).
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Trivially satisfied (all attributes are prime).
* **Conclusion:** **Achieves 3NF**.

---

#### 8. Table: `PROJECT`
* **Relational Schema:** $\text{PROJECT}(\underline{\text{ProjectID}}, \text{ProjectName}, \text{StartDate}, \text{PlannedEndDate}, \text{ActualEndDate}, \text{EstimatedBudget}, \text{Status}, \text{ClientID}, \text{DeptID}, \text{DirectorEmpID})$
* **Functional Dependencies ($F_8$):**
  * $FD_{8.1}: \text{ProjectID} \to \{\text{ProjectName, StartDate, PlannedEndDate, ActualEndDate, EstimatedBudget, Status, ClientID, DeptID, DirectorEmpID}\}$
  * $FD_{8.2}: \text{ProjectName} \to \{\text{ProjectID, StartDate, PlannedEndDate, ActualEndDate, EstimatedBudget, Status, ClientID, DeptID, DirectorEmpID}\}$ (Contract title is unique).
* **Candidate Keys & Attributes:**
  * **Candidate Keys:** $CK_1 = \{\text{ProjectID}\}$ (PK), $CK_2 = \{\text{ProjectName}\}$ (AK).
  * **Prime Attributes:** `ProjectID`, `ProjectName`.
  * **Non-Prime Attributes:** `StartDate, PlannedEndDate, ActualEndDate, EstimatedBudget, Status, ClientID, DeptID, DirectorEmpID`.
* **Normal Form Evaluation:**
  * **1NF / 2NF:** Satisfied (single-attribute keys; no partial dependencies).
  * **3NF:** Satisfied (all determinants are superkeys; foreign keys reference external entities without creating intra-table transitive dependencies).
* **Conclusion:** **Achieves 3NF**.

---

#### 9. Table: `PROJECT_SITE`
* **Relational Schema:** $\text{PROJECT\_SITE}(\underline{\text{SiteID}}, \text{ProjectID}, \text{SiteName}, \text{Latitude}, \text{Longitude}, \text{StreetAddress}, \text{District}, \text{City\_Province}, \text{EnvironmentalPermit}, \text{SiteStatus})$
* **Functional Dependencies ($F_9$):**
  * $FD_{9.1}: \text{SiteID} \to \{\text{ProjectID, SiteName, Latitude, Longitude, StreetAddress, District, City_Province, EnvironmentalPermit, SiteStatus}\}$
  * $FD_{9.2}: \{\text{ProjectID, SiteName}\} \to \{\text{SiteID, Latitude, Longitude, StreetAddress, District, City_Province, EnvironmentalPermit, SiteStatus}\}$ (Site name is unique per project).
  * $FD_{9.3}: \{\text{Latitude, Longitude}\} \to \{\text{SiteID, ProjectID, SiteName, StreetAddress, District, City_Province, EnvironmentalPermit, SiteStatus}\}$ (Geographic coordinates identify a site).
* **Candidate Keys & Attributes:**
  * **Candidate Keys:** $CK_1 = \{\text{SiteID}\}$ (PK), $CK_2 = \{\text{ProjectID, SiteName}\}$ (AK), $CK_3 = \{\text{Latitude, Longitude}\}$ (AK).
  * **Prime Attributes:** `SiteID`, `ProjectID`, `SiteName`, `Latitude`, `Longitude`.
  * **Non-Prime Attributes:** `StreetAddress, District, City_Province, EnvironmentalPermit, SiteStatus`.
* **Normal Form Evaluation:**
  * **1NF:** Satisfied (atomic fields).
  * **2NF:** Satisfied (for composite keys $CK_2$ and $CK_3$, no proper subset determines any non-prime attribute).
  * **3NF:** Satisfied (all determinants are superkeys).
* **Conclusion:** **Achieves 3NF**.

---

#### 10. Table: `PROJECT_PHASE`
* **Relational Schema:** $\text{PROJECT\_PHASE}(\underline{\text{ProjectID}}, \underline{\text{PhaseNumber}}, \text{PhaseTitle}, \text{StartDate}, \text{TargetCompletionDate}, \text{PhaseBudget}, \text{PhaseStatus})$
* **Functional Dependencies ($F_{10}$):**
  * $FD_{10.1}: \{\text{ProjectID, PhaseNumber}\} \to \{\text{PhaseTitle, StartDate, TargetCompletionDate, PhaseBudget, PhaseStatus}\}$
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{ProjectID, PhaseNumber}\}$ (PK).
  * **Prime Attributes:** `ProjectID`, `PhaseNumber`.
  * **Non-Prime Attributes:** `PhaseTitle, StartDate, TargetCompletionDate, PhaseBudget, PhaseStatus`.
* **Normal Form Evaluation:**
  * **1NF:** Satisfied.
  * **2NF:** Satisfied (full functional dependency on composite key; neither `ProjectID` nor `PhaseNumber` alone determines phase attributes).
  * **3NF:** Satisfied (determinant is the candidate key).
* **Conclusion:** **Achieves 3NF**.

---

#### 11. Table: `TASK`
* **Relational Schema:** $\text{TASK}(\underline{\text{TaskID}}, \text{TaskName}, \text{EstimatedHours}, \text{ScheduledStartDate}, \text{ScheduledEndDate}, \text{ActualEndDate}, \text{PriorityLevel}, \text{TaskStatus}, \text{ProjectID}, \text{PhaseNumber})$
* **Functional Dependencies ($F_{11}$):**
  * $FD_{11.1}: \text{TaskID} \to \{\text{TaskName, EstimatedHours, ScheduledStartDate, ScheduledEndDate, ActualEndDate, PriorityLevel, TaskStatus, ProjectID, PhaseNumber}\}$
  * $FD_{11.2}: \{\text{ProjectID, PhaseNumber, TaskName}\} \to \{\text{TaskID, EstimatedHours, ScheduledStartDate, ScheduledEndDate, ActualEndDate, PriorityLevel, TaskStatus}\}$
* **Candidate Keys & Attributes:**
  * **Candidate Keys:** $CK_1 = \{\text{TaskID}\}$ (PK), $CK_2 = \{\text{ProjectID, PhaseNumber, TaskName}\}$ (AK).
  * **Prime Attributes:** `TaskID`, `ProjectID`, `PhaseNumber`, `TaskName`.
  * **Non-Prime Attributes:** `EstimatedHours, ScheduledStartDate, ScheduledEndDate, ActualEndDate, PriorityLevel, TaskStatus`.
* **Normal Form Evaluation:**
  * **1NF / 2NF:** Satisfied (no partial dependencies on either candidate key).
  * **3NF:** Satisfied (all determinants are superkeys; composite foreign key `(ProjectID, PhaseNumber)` does not determine other non-prime attributes).
* **Conclusion:** **Achieves 3NF**.

---

#### 12. Table: `PRECEDES`
* **Relational Schema:** $\text{PRECEDES}(\underline{\text{PredecessorTaskID}}, \underline{\text{SuccessorTaskID}})$
* **Functional Dependencies ($F_{12}$):** Trivial dependencies only.
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{PredecessorTaskID, SuccessorTaskID}\}$ (PK).
  * **Prime Attributes:** `PredecessorTaskID`, `SuccessorTaskID`.
  * **Non-Prime Attributes:** $\emptyset$ (None).
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Trivially satisfied (all attributes are prime).
* **Conclusion:** **Achieves 3NF**.

---

#### 13. Table: `WORKS_ON_TASK`
* **Relational Schema:** $\text{WORKS\_ON\_TASK}(\underline{\text{EmpID}}, \underline{\text{TaskID}}, \text{AssignedDate}, \text{RoleOnTask}, \text{HoursLogged})$
* **Functional Dependencies ($F_{13}$):**
  * $FD_{13.1}: \{\text{EmpID, TaskID}\} \to \{\text{AssignedDate, RoleOnTask, HoursLogged}\}$
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{EmpID, TaskID}\}$ (PK).
  * **Prime Attributes:** `EmpID`, `TaskID`.
  * **Non-Prime Attributes:** `AssignedDate, RoleOnTask, HoursLogged`.
* **Normal Form Evaluation:**
  * **1NF:** Satisfied.
  * **2NF:** Satisfied (full functional dependency; neither `EmpID` nor `TaskID` alone determines logged hours).
  * **3NF:** Satisfied (determinant is the candidate key).
* **Conclusion:** **Achieves 3NF**.

---

### Subsystem 3: Heavy Machinery & Fleet Maintenance

#### 14. Table: `EQUIPMENT`
* **Relational Schema:** $\text{EQUIPMENT}(\underline{\text{EquipmentID}}, \text{Model}, \text{SerialNumber}, \text{Category}, \text{Ownership}, \text{HourlyRate}, \text{CurrentStatus})$
* **Functional Dependencies ($F_{14}$):**
  * $FD_{14.1}: \text{EquipmentID} \to \{\text{Model, SerialNumber, Category, Ownership, HourlyRate, CurrentStatus}\}$
  * $FD_{14.2}: \text{SerialNumber} \to \{\text{EquipmentID, Model, Category, Ownership, HourlyRate, CurrentStatus}\}$ (Manufacturer chassis/VIN is unique).
* **Candidate Keys & Attributes:**
  * **Candidate Keys:** $CK_1 = \{\text{EquipmentID}\}$ (PK), $CK_2 = \{\text{SerialNumber}\}$ (AK).
  * **Prime Attributes:** `EquipmentID`, `SerialNumber`.
  * **Non-Prime Attributes:** `Model, Category, Ownership, HourlyRate, CurrentStatus`.
* **Normal Form Evaluation:**
  * **1NF / 2NF:** Satisfied (single-attribute keys; no partial dependencies).
  * **3NF:** Satisfied (all determinants are superkeys).
* **Conclusion:** **Achieves 3NF**.

---

#### 15. Table: `MAINTENANCE_RECORD`
* **Relational Schema:** $\text{MAINTENANCE\_RECORD}(\underline{\text{EquipmentID}}, \underline{\text{RecordNumber}}, \text{ServiceDate}, \text{MaintenanceType}, \text{Cost}, \text{ServiceVendor})$
* **Functional Dependencies ($F_{15}$):**
  * $FD_{15.1}: \{\text{EquipmentID, RecordNumber}\} \to \{\text{ServiceDate, MaintenanceType, Cost, ServiceVendor}\}$
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{EquipmentID, RecordNumber}\}$ (PK).
  * **Prime Attributes:** `EquipmentID`, `RecordNumber`.
  * **Non-Prime Attributes:** `ServiceDate, MaintenanceType, Cost, ServiceVendor`.
* **Normal Form Evaluation:**
  * **1NF / 2NF:** Satisfied (full functional dependency on composite key).
  * **3NF:** Satisfied (determinant is the candidate key).
* **Conclusion:** **Achieves 3NF**.

---

#### 16. Table: `EQUIPMENT_DEPLOYMENT` (2NF Partial Key Resolution)

**1. Phase 2 Initial Design & Conflict Analysis:**
* **Initial Relational Schema:** $\text{EQUIPMENT\_DEPLOYMENT}(\underline{\text{EquipmentID}}, \underline{\text{SiteID}}, \underline{\text{DeploymentStartDate}}, \text{DeploymentEndDate}, \text{HoursOperated}, \text{OperatorEmpID})$
* **Initial Key & Functional Dependencies:**
  * Initial Composite Key: $\{\text{EquipmentID, SiteID, DeploymentStartDate}\}$
  * Logistics Dependency ($FD_{16.1}$): $\{\text{EquipmentID, DeploymentStartDate}\} \to \{\text{SiteID, DeploymentEndDate, HoursOperated, OperatorEmpID}\}$ *(A machine operates at exactly one site per start date)*.
* **Conflict & 2NF Violation:**
  * **Violation Analysis:** In $FD_{16.1}$, the attribute $\text{SiteID}$ is functionally determined by $\{\text{EquipmentID, DeploymentStartDate}\}$, which is a **proper subset** of the initial 3-part key.
  * **Conflict:** This constitutes a **Partial Key Dependency**, directly violating **2NF**. The initial key is non-minimal and redundant.

**2. Conflict Resolution & Normalized Design (3NF Certified):**
* **Resolution Strategy:** Remove $\text{SiteID}$ from the composite primary key and retain it as a non-prime foreign key referencing `PROJECT_SITE`. The primary key is minimized to strictly $\{\text{EquipmentID}, \text{DeploymentStartDate}\}$, eliminating the partial key dependency and restoring 2NF/3NF compliance without losing the job site relationship.
* **Normalized Relational Schema:** $\text{EQUIPMENT\_DEPLOYMENT}(\underline{\text{EquipmentID}}, \underline{\text{DeploymentStartDate}}, \text{SiteID}, \text{DeploymentEndDate}, \text{HoursOperated}, \text{OperatorEmpID})$
* **Normalized Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{EquipmentID, DeploymentStartDate}\}$ (Minimal PK).
  * **Prime Attributes:** `EquipmentID`, `DeploymentStartDate`.
  * **Non-Prime Attributes:** `SiteID, DeploymentEndDate, HoursOperated, OperatorEmpID`.
* **Normal Form Evaluation:**
  * **1NF / 2NF:** Satisfied (all non-prime attributes depend fully on the complete 2-attribute minimal key; partial dependency eliminated).
  * **3NF:** Satisfied (the sole determinant is a superkey; no transitive dependencies).
* **Conclusion:** **Achieves 3NF**.

---

### Subsystem 4: Procurement, Materials & Site Inventory

#### 17. Table: `SUPPLIER`
* **Relational Schema:** $\text{SUPPLIER}(\underline{\text{SupplierID}}, \text{CompanyName}, \text{TaxCode}, \text{ContactEmail}, \text{CreditRating})$
* **Functional Dependencies ($F_{17}$):**
  * $FD_{17.1}: \text{SupplierID} \to \{\text{CompanyName, TaxCode, ContactEmail, CreditRating}\}$
  * $FD_{17.2}: \text{TaxCode} \to \{\text{SupplierID, CompanyName, ContactEmail, CreditRating}\}$ (Tax code is unique).
* **Candidate Keys & Attributes:**
  * **Candidate Keys:** $CK_1 = \{\text{SupplierID}\}$ (PK), $CK_2 = \{\text{TaxCode}\}$ (AK).
  * **Prime Attributes:** `SupplierID`, `TaxCode`.
  * **Non-Prime Attributes:** `CompanyName, ContactEmail, CreditRating`.
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Satisfied (single-attribute keys; determinants are superkeys).
* **Conclusion:** **Achieves 3NF**.

---

#### 18. Table: `SUPPLIER_PHONE`
* **Relational Schema:** $\text{SUPPLIER\_PHONE}(\underline{\text{SupplierID}}, \underline{\text{ContactPhone}})$
* **Functional Dependencies ($F_{18}$):** Trivial dependencies only.
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{SupplierID, ContactPhone}\}$ (PK).
  * **Prime Attributes:** `SupplierID`, `ContactPhone`.
  * **Non-Prime Attributes:** $\emptyset$ (None).
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Trivially satisfied (all attributes are prime).
* **Conclusion:** **Achieves 3NF**.

---

#### 19. Table: `SUPPLIER_CATEGORY`
* **Relational Schema:** $\text{SUPPLIER\_CATEGORY}(\underline{\text{SupplierID}}, \underline{\text{SupplyCategory}})$
* **Functional Dependencies ($F_{19}$):** Trivial dependencies only.
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{SupplierID, SupplyCategory}\}$ (PK).
  * **Prime Attributes:** `SupplierID`, `SupplyCategory`.
  * **Non-Prime Attributes:** $\emptyset$ (None).
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Trivially satisfied (all attributes are prime).
* **Conclusion:** **Achieves 3NF**.

---

#### 20. Table: `MATERIAL`
* **Relational Schema:** $\text{MATERIAL}(\underline{\text{MaterialID}}, \text{MaterialName}, \text{Category}, \text{StandardUnit}, \text{UnitPrice}, \text{MinStock})$
* **Functional Dependencies ($F_{20}$):**
  * $FD_{20.1}: \text{MaterialID} \to \{\text{MaterialName, Category, StandardUnit, UnitPrice, MinStock}\}$
  * $FD_{20.2}: \text{MaterialName} \to \{\text{MaterialID, Category, StandardUnit, UnitPrice, MinStock}\}$ (Standard catalog name is unique).
* **Candidate Keys & Attributes:**
  * **Candidate Keys:** $CK_1 = \{\text{MaterialID}\}$ (PK), $CK_2 = \{\text{MaterialName}\}$ (AK).
  * **Prime Attributes:** `MaterialID`, `MaterialName`.
  * **Non-Prime Attributes:** `Category, StandardUnit, UnitPrice, MinStock`.
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Satisfied (single-attribute keys; determinants are superkeys).
* **Conclusion:** **Achieves 3NF**.

---

#### 21. Table: `PURCHASE_ORDER`
* **Relational Schema:** $\text{PURCHASE\_ORDER}(\underline{\text{PO\_ID}}, \text{OrderDate}, \text{ExpectedDeliveryDate}, \text{DeliveryStatus}, \text{ProjectID}, \text{SupplierID})$
* **Functional Dependencies ($F_{21}$):**
  * $FD_{21.1}: \text{PO\_ID} \to \{\text{OrderDate, ExpectedDeliveryDate, DeliveryStatus, ProjectID, SupplierID}\}$
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{PO\_ID}\}$ (PK).
  * **Prime Attributes:** `PO_ID`.
  * **Non-Prime Attributes:** `OrderDate, ExpectedDeliveryDate, DeliveryStatus, ProjectID, SupplierID`.
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Satisfied (single-attribute key; determinant is a superkey).
* **Conclusion:** **Achieves 3NF**.

---

#### 22. Table: `PO_ITEM`
* **Relational Schema:** $\text{PO\_ITEM}(\underline{\text{PO\_ID}}, \underline{\text{LineNumber}}, \text{QuantityOrdered}, \text{AgreedUnitPrice}, \text{MaterialID})$
* **Functional Dependencies ($F_{22}$):**
  * $FD_{22.1}: \{\text{PO\_ID, LineNumber}\} \to \{\text{QuantityOrdered, AgreedUnitPrice, MaterialID}\}$
  * $FD_{22.2}: \{\text{PO\_ID, MaterialID}\} \to \{\text{LineNumber, QuantityOrdered, AgreedUnitPrice}\}$ (A material appears once per purchase order).
* **Candidate Keys & Attributes:**
  * **Candidate Keys:** $CK_1 = \{\text{PO\_ID, LineNumber}\}$ (PK), $CK_2 = \{\text{PO\_ID, MaterialID}\}$ (AK).
  * **Prime Attributes:** `PO_ID`, `LineNumber`, `MaterialID`.
  * **Non-Prime Attributes:** `QuantityOrdered`, `AgreedUnitPrice`.
* **Normal Form Evaluation:**
  * **1NF:** Satisfied.
  * **2NF:** Satisfied (full functional dependency; neither `PO_ID` nor `LineNumber` alone determines quantity or price).
  * **3NF:** Satisfied (determinants are candidate keys. `AgreedUnitPrice` is contract-locked and does not depend on `MaterialID`, precluding transitive dependency).
* **Conclusion:** **Achieves 3NF**.

---

#### 23. Table: `SITE_INVENTORY`
* **Relational Schema:** $\text{SITE\_INVENTORY}(\underline{\text{SiteID}}, \underline{\text{MaterialID}}, \text{CurrentStockQuantity}, \text{SafetyReorderQuantity}, \text{LastStocktakeDate})$
* **Functional Dependencies ($F_{23}$):**
  * $FD_{23.1}: \{\text{SiteID, MaterialID}\} \to \{\text{CurrentStockQuantity, SafetyReorderQuantity, LastStocktakeDate}\}$
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{SiteID, MaterialID}\}$ (PK).
  * **Prime Attributes:** `SiteID`, `MaterialID`.
  * **Non-Prime Attributes:** `CurrentStockQuantity, SafetyReorderQuantity, LastStocktakeDate`.
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Satisfied (full functional dependency; determinant is candidate key).
* **Conclusion:** **Achieves 3NF**.

---

#### 24. Table: `DELIVERY_DISPATCH` (3NF Transitive Dependency Resolution)

**1. Phase 2 Initial Design & Conflict Analysis:**
* **Initial Relational Schema:** $\text{DELIVERY\_DISPATCH}(\underline{\text{DeliveryCode}}, \text{SupplierID}, \text{MaterialID}, \text{SiteID}, \text{DeliveryDate}, \text{DeliveredQuantity}, \text{ReceivedByEmpID}, \text{PO\_ID})$
* **Initial Key & Functional Dependencies:**
  * Initial Candidate Key: $\{\text{DeliveryCode}\}$
  * $FD_{24.1}: \text{DeliveryCode} \to \{\text{SupplierID, MaterialID, SiteID, DeliveryDate, DeliveredQuantity, ReceivedByEmpID, PO\_ID}\}$
  * $FD_{24.2}: \text{PO\_ID} \to \text{SupplierID}$ *(Each purchase order is issued to exactly one supplier in `PURCHASE_ORDER`)*.
* **Conflict & 3NF Violation:**
  * **Violation Analysis:** In $FD_{24.2}$, $\text{PO\_ID}$ is **NOT a superkey** of `DELIVERY_DISPATCH` (a purchase order may be fulfilled across multiple delivery batches), and $\text{SupplierID}$ is a **non-prime attribute**.
  * **Conflict:** This induces a **Transitive Dependency**:
     $$\text{DeliveryCode} \to \text{PO\_ID} \to \text{SupplierID}$$
     violating **3NF**.
  * **Business Anomalies:** Data redundancy (vendor ID duplicated across PO and delivery records); update anomaly (reassigning a PO vendor creates inconsistency in dispatch history).

**2. Conflict Resolution & Normalized Design (3NF Certified):**
* **Resolution Strategy:** Eliminate $\text{SupplierID}$ from `DELIVERY_DISPATCH`. Because $\text{PO\_ID} \to \text{SupplierID}$ is fully maintained in `PURCHASE_ORDER`, vendor information is retrieved losslessly by joining on the foreign key $\text{PO\_ID}$, completely resolving the transitive dependency and eliminating update anomalies.
* **Normalized Relational Schema:** $\text{DELIVERY\_DISPATCH}(\underline{\text{DeliveryCode}}, \text{MaterialID}, \text{SiteID}, \text{DeliveryDate}, \text{DeliveredQuantity}, \text{ReceivedByEmpID}, \text{PO\_ID})$
* **Normalized Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{DeliveryCode}\}$ (PK).
  * **Prime Attributes:** `DeliveryCode`.
  * **Non-Prime Attributes:** `MaterialID, SiteID, DeliveryDate, DeliveredQuantity, ReceivedByEmpID, PO_ID`.
* **Normal Form Evaluation:**
  * **1NF / 2NF:** Satisfied (single-attribute candidate key).
  * **3NF:** Satisfied (projecting out $\text{SupplierID}$ eliminates the transitive dependency; supplier identity is preserved without loss via foreign key $\text{PO\_ID} \to \text{PURCHASE\_ORDER}$).
* **Conclusion:** **Achieves 3NF**.

---

#### 25. Table: `MATERIAL_USAGE`
* **Relational Schema:** $\text{MATERIAL\_USAGE}(\underline{\text{TaskID}}, \underline{\text{MaterialID}}, \underline{\text{SiteID}}, \underline{\text{UsageDate}}, \text{QuantityUsed})$
* **Functional Dependencies ($F_{25}$):**
  * $FD_{25.1}: \{\text{TaskID, MaterialID, SiteID, UsageDate}\} \to \{\text{QuantityUsed}\}$
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{TaskID, MaterialID, SiteID, UsageDate}\}$ (PK).
  * **Prime Attributes:** `TaskID`, `MaterialID`, `SiteID`, `UsageDate`.
  * **Non-Prime Attributes:** `QuantityUsed`.
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Satisfied (full functional dependency on 4-part key; determinant is candidate key).
* **Conclusion:** **Achieves 3NF**.

---

### Subsystem 5: Trade Subcontractors

#### 26. Table: `SUBCONTRACTOR`
* **Relational Schema:** $\text{SUBCONTRACTOR}(\underline{\text{SubcontractorID}}, \text{CompanyName}, \text{TaxCode}, \text{ContactEmail}, \text{ContactPhone}, \text{TradeSpecialty}, \text{LicenseNumber}, \text{SafetyRatingScore})$
* **Functional Dependencies ($F_{26}$):**
  * $FD_{26.1}: \text{SubcontractorID} \to \{\text{CompanyName, TaxCode, ContactEmail, ContactPhone, TradeSpecialty, LicenseNumber, SafetyRatingScore}\}$
  * $FD_{26.2}: \text{TaxCode} \to \{\text{SubcontractorID, CompanyName, ContactEmail, ContactPhone, TradeSpecialty, LicenseNumber, SafetyRatingScore}\}$
  * $FD_{26.3}: \text{LicenseNumber} \to \{\text{SubcontractorID, CompanyName, TaxCode, ContactEmail, ContactPhone, TradeSpecialty, SafetyRatingScore}\}$ (Trade license is unique).
* **Candidate Keys & Attributes:**
  * **Candidate Keys:** $CK_1 = \{\text{SubcontractorID}\}$ (PK), $CK_2 = \{\text{TaxCode}\}$ (AK), $CK_3 = \{\text{LicenseNumber}\}$ (AK).
  * **Prime Attributes:** `SubcontractorID`, `TaxCode`, `LicenseNumber`.
  * **Non-Prime Attributes:** `CompanyName, ContactEmail, ContactPhone, TradeSpecialty, SafetyRatingScore`.
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Satisfied (all determinants are superkeys).
* **Conclusion:** **Achieves 3NF**.

---

#### 27. Table: `SUBCONTRACT`
* **Relational Schema:** $\text{SUBCONTRACT}(\underline{\text{ContractAgreementNo}}, \text{ProjectID}, \text{SubcontractorID}, \text{ScopeDescription}, \text{ContractValue}, \text{WarrantyHoldRate}, \text{StartDate}, \text{CompletionDate})$
* **Functional Dependencies ($F_{27}$):**
  * $FD_{27.1}: \text{ContractAgreementNo} \to \{\text{ProjectID, SubcontractorID, ScopeDescription, ContractValue, WarrantyHoldRate, StartDate, CompletionDate}\}$
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{ContractAgreementNo}\}$ (PK).
  * **Prime Attributes:** `ContractAgreementNo`.
  * **Non-Prime Attributes:** `ProjectID, SubcontractorID, ScopeDescription, ContractValue, WarrantyHoldRate, StartDate, CompletionDate`.
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Satisfied (single-attribute key; determinant is superkey).
* **Conclusion:** **Achieves 3NF**.

---

### Subsystem 6: Health, Safety & Environment (HSE)

#### 28. Table: `SAFETY_INSPECTION`
* **Relational Schema:** $\text{SAFETY\_INSPECTION}(\underline{\text{InspectionID}}, \text{InspectionDate}, \text{InspectionType}, \text{InspectionScope}, \text{OverallScore}, \text{InspectionResult}, \text{ViolationNoted}, \text{FixDeadline}, \text{SiteID}, \text{InspectorEmpID})$
* **Functional Dependencies ($F_{28}$):**
  * $FD_{28.1}: \text{InspectionID} \to \{\text{InspectionDate, InspectionType, InspectionScope, OverallScore, InspectionResult, ViolationNoted, FixDeadline, SiteID, InspectorEmpID}\}$
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{InspectionID}\}$ (PK).
  * **Prime Attributes:** `InspectionID`.
  * **Non-Prime Attributes:** `InspectionDate, InspectionType, InspectionScope, OverallScore, InspectionResult, ViolationNoted, FixDeadline, SiteID, InspectorEmpID`.
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Satisfied (single-attribute key; determinant is superkey).
* **Conclusion:** **Achieves 3NF**.

---

#### 29. Table: `INCIDENT_REPORT`
* **Relational Schema:** $\text{INCIDENT\_REPORT}(\underline{\text{IncidentID}}, \text{IncidentTimestamp}, \text{IncidentType}, \text{IncidentLevel}, \text{DamageDescription}, \text{LostDays}, \text{Solution}, \text{SiteID}, \text{InvolvedEmpID}, \text{DamagedEquipmentID})$
* **Functional Dependencies ($F_{29}$):**
  * $FD_{29.1}: \text{IncidentID} \to \{\text{IncidentTimestamp, IncidentType, IncidentLevel, DamageDescription, LostDays, Solution, SiteID, InvolvedEmpID, DamagedEquipmentID}\}$
* **Candidate Keys & Attributes:**
  * **Candidate Key:** $CK = \{\text{IncidentID}\}$ (PK).
  * **Prime Attributes:** `IncidentID`.
  * **Non-Prime Attributes:** `IncidentTimestamp, IncidentType, IncidentLevel, DamageDescription, LostDays, Solution, SiteID, InvolvedEmpID, DamagedEquipmentID`.
* **Normal Form Evaluation:**
  * **1NF / 2NF / 3NF:** Satisfied (single-attribute key; determinant is superkey).
* **Conclusion:** **Achieves 3NF**.

---

## 3. Master Summary of 3NF Normalized Relational Schemas

The following master reference table summarizes the normalization results, candidate keys, and foreign keys across all 29 normalized relations:

| No. | Relational Schema Name | Primary Key (PK) | Alternate Candidate Keys (AK) | Foreign Keys (FK) & Referencing Targets | Normal Form |
| :---: | :--- | :--- | :--- | :--- | :---: |
| **1** | `DEPARTMENT` | `DeptID` | `DeptName`, `HeadEmpID` | `HeadEmpID` $\to$ `EMPLOYEE(EmpID)` | **3NF** |
| **2** | `EMPLOYEE` | `EmpID` | `Email` | `DeptID` $\to$ `DEPARTMENT`, `SupervisorID` $\to$ `EMPLOYEE` | **3NF** |
| **3** | `EMPLOYEE_PHONE` | `(EmpID, PhoneNumber)` | *None* | `EmpID` $\to$ `EMPLOYEE` | **3NF** |
| **4** | `EMPLOYEE_CERTIFICATION` | `(EmpID, Certification)` | *None* | `EmpID` $\to$ `EMPLOYEE` | **3NF** |
| **5** | `DEPENDENT` | `(EmpID, DependentName)` | *None* | `EmpID` $\to$ `EMPLOYEE` | **3NF** |
| **6** | `CLIENT` | `ClientID` | `TaxCode` | *None* | **3NF** |
| **7** | `CLIENT_PHONE` | `(ClientID, ContactPhone)` | *None* | `ClientID` $\to$ `CLIENT` | **3NF** |
| **8** | `PROJECT` | `ProjectID` | `ProjectName` | `ClientID` $\to$ `CLIENT`, `DeptID` $\to$ `DEPARTMENT`, `DirectorEmpID` $\to$ `EMPLOYEE` | **3NF** |
| **9** | `PROJECT_SITE` | `SiteID` | `(ProjectID, SiteName)`, `(Latitude, Longitude)` | `ProjectID` $\to$ `PROJECT` | **3NF** |
| **10** | `PROJECT_PHASE` | `(ProjectID, PhaseNumber)` | *None* | `ProjectID` $\to$ `PROJECT` | **3NF** |
| **11** | `TASK` | `TaskID` | `(ProjectID, PhaseNumber, TaskName)` | `(ProjectID, PhaseNumber)` $\to$ `PROJECT_PHASE` | **3NF** |
| **12** | `PRECEDES` | `(PredecessorTaskID, SuccessorTaskID)` | *None* | `PredecessorTaskID` $\to$ `TASK`, `SuccessorTaskID` $\to$ `TASK` | **3NF** |
| **13** | `WORKS_ON_TASK` | `(EmpID, TaskID)` | *None* | `EmpID` $\to$ `EMPLOYEE`, `TaskID` $\to$ `TASK` | **3NF** |
| **14** | `EQUIPMENT` | `EquipmentID` | `SerialNumber` | *None* | **3NF** |
| **15** | `MAINTENANCE_RECORD` | `(EquipmentID, RecordNumber)` | *None* | `EquipmentID` $\to$ `EQUIPMENT` | **3NF** |
| **16** | `EQUIPMENT_DEPLOYMENT` | `(EquipmentID, DeploymentStartDate)` | *None* | `EquipmentID` $\to$ `EQUIPMENT`, `SiteID` $\to$ `PROJECT_SITE`, `OperatorEmpID` $\to$ `EMPLOYEE` | **3NF** |
| **17** | `SUPPLIER` | `SupplierID` | `TaxCode` | *None* | **3NF** |
| **18** | `SUPPLIER_PHONE` | `(SupplierID, ContactPhone)` | *None* | `SupplierID` $\to$ `SUPPLIER` | **3NF** |
| **19** | `SUPPLIER_CATEGORY` | `(SupplierID, SupplyCategory)` | *None* | `SupplierID` $\to$ `SUPPLIER` | **3NF** |
| **20** | `MATERIAL` | `MaterialID` | `MaterialName` | *None* | **3NF** |
| **21** | `PURCHASE_ORDER` | `PO_ID` | *None* | `ProjectID` $\to$ `PROJECT`, `SupplierID` $\to$ `SUPPLIER` | **3NF** |
| **22** | `PO_ITEM` | `(PO_ID, LineNumber)` | `(PO_ID, MaterialID)` | `PO_ID` $\to$ `PURCHASE_ORDER`, `MaterialID` $\to$ `MATERIAL` | **3NF** |
| **23** | `SITE_INVENTORY` | `(SiteID, MaterialID)` | *None* | `SiteID` $\to$ `PROJECT_SITE`, `MaterialID` $\to$ `MATERIAL` | **3NF** |
| **24** | `DELIVERY_DISPATCH` | `DeliveryCode` | *None* | `MaterialID` $\to$ `MATERIAL`, `SiteID` $\to$ `PROJECT_SITE`, `ReceivedByEmpID` $\to$ `EMPLOYEE`, `PO_ID` $\to$ `PURCHASE_ORDER` | **3NF** |
| **25** | `MATERIAL_USAGE` | `(TaskID, MaterialID, SiteID, UsageDate)` | *None* | `TaskID` $\to$ `TASK`, `(SiteID, MaterialID)` $\to$ `SITE_INVENTORY` | **3NF** |
| **26** | `SUBCONTRACTOR` | `SubcontractorID` | `TaxCode`, `LicenseNumber` | *None* | **3NF** |
| **27** | `SUBCONTRACT` | `ContractAgreementNo` | *None* | `ProjectID` $\to$ `PROJECT`, `SubcontractorID` $\to$ `SUBCONTRACTOR` | **3NF** |
| **28** | `SAFETY_INSPECTION` | `InspectionID` | *None* | `SiteID` $\to$ `PROJECT_SITE`, `InspectorEmpID` $\to$ `EMPLOYEE` | **3NF** |
| **29** | `INCIDENT_REPORT` | `IncidentID` | *None* | `SiteID` $\to$ `PROJECT_SITE`, `InvolvedEmpID` $\to$ `EMPLOYEE`, `DamagedEquipmentID` $\to$ `EQUIPMENT` | **3NF** |
