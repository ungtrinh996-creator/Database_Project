# Database Design Term Project (Phase 2)
## Part 2: Conceptual Design (Entity-Relationship Diagram - ERD)

- **Topic:** Database system for a construction company with multiple projects (A34Build)
- **Course:** Database [E24-Class 5]
- **Team:** 5
- **Members:**
  - Lê Anh Minh (B24DCCE180)
  - Ứng Trọng Trình (B24DCCE271)
  - Nguyễn Đinh Anh Quân (B24DCCE222)
- **Instructor:**Nguyen Dinh Hoa (`hoand@ptit.edu.vn`)
- **Textbook Reference:** *Fundamentals of Database Systems*, 6th Edition (R. Elmasri & S. B. Navathe)

---

## 1. ER Modeling Notational Standards (Elmasri & Navathe)

The conceptual schema follows Chen's classic Entity-Relationship (ER) notation as presented in Chapter 3 of *Fundamentals of Database Systems* (Elmasri & Navathe, 6th Edition):

### 1.1 Graphical Notation Summary
| Schema Element | Visual Shape | Description & Line Style |
| :--- | :--- | :--- |
| **Regular (Strong) Entity** | Single Rectangle | Solid single-line rectangle enclosing the entity name in uppercase |
| **Weak Entity** | Double Rectangle | Concentric double-line rectangle dependent on an identifying entity |
| **Relationship** | Single Diamond | Solid diamond enclosing the relationship name |
| **Identifying Relationship** | Double Diamond | Concentric double-line diamond linking a weak entity to its owner |
| **Simple Attribute** | Single Ellipse (Oval) | Solid oval enclosing attribute name, connected by a line to entity |
| **Primary Key (PK)** | Underlined text inside Oval | Solid underline under the attribute name (`<u>PK</u>`) |
| **Partial Key (Discriminator)** | Dashed underline inside Oval | Dashed underline under attribute name of weak entity |
| **Candidate Key** | Oval with label | Marked with candidate key notation or `(Unique)` |
| **Composite Attribute** | Hierarchical Oval Tree | Parent oval branching into multiple sub-ovals |
| **Multi-valued Attribute** | Double Ellipse | Concentric double-line oval |
| **Derived Attribute** | Dashed Ellipse | Dashed-line oval calculated from other attributes |
| **Total Participation** | Double Line (`==`) | Every entity instance must participate in the relationship |
| **Partial Participation** | Single Line (`--`) | Some entity instances may participate in the relationship |
| **Cardinality Ratio** | Numeric / Letter labels | `1`, `N`, `M`, `P` placed on connecting lines adjacent to entities |

---

## 2. High-Level Master ERD Architecture

The enterprise database of A34Build contains **17 entity types** (13 strong, 4 weak) and **24 relationship types**. To ensure clarity and readability, the complete architecture is organized into **6 cohesive functional subsystems**:

1. **Organization & Human Resources:** `DEPARTMENT`, `EMPLOYEE`, `DEPENDENT`
2. **Project Management & Work Breakdown (WBS):** `CLIENT`, `PROJECT`, `PROJECT_SITE`, `PROJECT_PHASE`, `TASK`
3. **Heavy Equipment & Fleet Maintenance:** `EQUIPMENT`, `MAINTENANCE_RECORD`
4. **Supply Chain, Materials & Site Inventory:** `SUPPLIER`, `MATERIAL`, `PURCHASE_ORDER`, `PO_ITEM`
5. **Trade Subcontractors:** `SUBCONTRACTOR`
6. **Health, Safety & Environment (HSE):** `SAFETY_INSPECTION`, `INCIDENT_REPORT`

```mermaid
flowchart TD
    %% Entities Definition
    subgraph S1["1. Organization & HR"]
        DEPT["DEPARTMENT"]
        EMP["EMPLOYEE"]
        DEP[["DEPENDENT (Weak)"]]
    end

    subgraph S2["2. Projects & WBS"]
        CLIENT["CLIENT"]
        PRJ["PROJECT"]
        SITE["PROJECT_SITE"]
        PHASE[["PROJECT_PHASE (Weak)"]]
        TASK["TASK"]
    end

    subgraph S3["3. Equipment & Fleet"]
        EQUIP["EQUIPMENT"]
        MAINT[["MAINTENANCE_RECORD (Weak)"]]
    end

    subgraph S4["4. Procurement & Inventory"]
        SUPP["SUPPLIER"]
        PO["PURCHASE_ORDER"]
        POITEM[["PO_ITEM (Weak)"]]
        MAT["MATERIAL"]
    end

    subgraph S5["5. Subcontractors"]
        SUBCON["SUBCONTRACTOR"]
    end

    subgraph S6["6. Safety & HSE"]
        INSP["SAFETY_INSPECTION"]
        INC["INCIDENT_REPORT"]
    end

    %% Key Inter-subsystem Relationships
    EMP ---|"1:1 (Directs)"| PRJ
    DEPT ---|"1:N (Sponsors)"| PRJ
    CLIENT ---|"1:N (Commissions)"| PRJ
    PRJ ---|"1:N (Has Sites)"| SITE
    PRJ ---|"M:N (Engages)"| SUBCON
    PRJ ---|"1:N (Issues)"| PO

    EMP ---|"M:N (Works On)"| TASK
    SITE ---|"M:N (Deploys)"| EQUIP
    SITE ---|"M:N (Stocks)"| MAT
    SITE ---|"1:N (Inspects)"| INSP
    SITE ---|"1:N (Logs)"| INC
    EMP ---|"1:N (Involved In)"| INC
    EMP ---|"1:N (Inspects)"| INSP
    
    SUPP ---|"1:N (Supplies)"| PO
    POITEM ---|"N:1 (References)"| MAT
```

> [!NOTE]
> **Architectural Abstraction Note:**
> Sơ đồ kiến trúc mức cao (Mục 2) tập trung phân rã 6 phân hệ (subgraphs) và biểu diễn **15 liên kết cốt lõi liên phân hệ (Inter-subsystem relationships)**. Để giữ cho sơ đồ kiến trúc tổng quan trực quan, rõ ràng và không bị quá tải thị giác, toàn bộ **thuộc tính (attributes)** và **các quan hệ nội bộ trong từng phân hệ (intra-subsystem)** được lược giản tại đây và được đặc tả chi tiết, đầy đủ tại **Mục 3 (Detailed Subsystems)** và **Mục 5 (Master Constraints Matrix)**.

---

## 3. Detailed Subsystem ER Diagrams & Chen Specifications

### 3.1 Subsystem 1: Organization & Human Resources

#### 1. Conceptual Scope
This module handles departmental hierarchies, internal staffing, management oversight, and family benefit / emergency contact records.

#### 2. Detailed Chen Element Mapping
- **`DEPARTMENT` (Strong Entity):**
  - Attributes: `<u>DeptID</u>` (PK), `DeptName`, `OfficeLocation`, `Budget`
- **`EMPLOYEE` (Strong Entity):**
  - Primary Key: `<u>EmpID</u>`
  - Composite Attributes:
    - `Name` $\rightarrow$ (`FirstName`, `MiddleName`, `LastName`)
    - `Address` $\rightarrow$ (`Street`, `Ward`, `District`, `City`)
  - Simple Attributes: `DOB`, `HireDate`, `Salary`, `JobTitle`
  - Candidate Key: `Email` (Unique)
  - Multi-valued Attributes: `PhoneNumber`, `Certifications`
  - Derived Attribute: `Age` (from `CurrentDate - DOB`)
- **`DEPENDENT` (Weak Entity):**
  - Owner Entity: `EMPLOYEE` via identifying relationship `HAS_DEPENDENT`
  - Partial Key: `<u>--DependentName--</u>` (dashed underline)
  - Simple Attributes: `Gender`, `BirthDate`, `Relationship`, `ContactPhone`, `IsEmergencyContact`
- **Relationships:**
  - `DEPARTMENT_HEAD` (1:1): `EMPLOYEE` (Partial) to `DEPARTMENT` (Total)
  - `WORKS_IN_DEPARTMENT` (1:N): `DEPARTMENT` (Total, 1) to `EMPLOYEE` (Total, N)
  - `SUPERVISES` (Unary 1:N): `EMPLOYEE` (Supervisor, 1) to `EMPLOYEE` (Subordinate, N)
  - `HAS_DEPENDENT` (Identifying 1:N): `EMPLOYEE` (Partial, 1) to `DEPENDENT` (Total, N)

#### 3. Visual ER Diagram (Subsystem 1)
```mermaid
flowchart LR
    %% -----------------------------------------------------------
    %% 1. ENTITIES & WEAK ENTITY
    %% -----------------------------------------------------------
    DEPT["DEPARTMENT"]
    EMP["EMPLOYEE"]
    DEP[["DEPENDENT (Weak)"]]

    %% -----------------------------------------------------------
    %% 2. RELATIONSHIPS
    %% -----------------------------------------------------------
    R_HEAD{"DEPARTMENT_HEAD<br/>(1:1)"}
    R_WORK{"WORKS_IN_DEPARTMENT<br/>(1:N)"}
    R_SUP{"SUPERVISES<br/>(Unary 1:N)"}
    R_DEP{{"HAS_DEPENDENT<br/>(Identifying 1:N)"}}

    %% Connecting Lines with Participation & Cardinality
    DEPT == "Total (1)" === R_HEAD
    R_HEAD ---|"Partial (1)"| EMP

    DEPT == "Total (1)" === R_WORK
    R_WORK == "Total (N)" === EMP

    EMP ---|"Supervisor (1)"| R_SUP
    R_SUP ---|"Subordinate (N)"| EMP

    EMP ---|"Partial (1)"| R_DEP
    R_DEP == "Total (N)" === DEP

    %% -----------------------------------------------------------
    %% 3. ATTRIBUTES FOR DEPARTMENT
    %% -----------------------------------------------------------
    DEPT --- D_PK(["<u>DeptID</u> (PK)"])
    DEPT --- D_NAME(["DeptName"])
    DEPT --- D_LOC(["OfficeLocation"])
    DEPT --- D_BUD(["Budget"])

    %% -----------------------------------------------------------
    %% 4. ATTRIBUTES FOR EMPLOYEE
    %% -----------------------------------------------------------
    %% Primary Key & Candidate Key
    EMP --- E_PK(["<u>EmpID</u> (PK)"])
    EMP --- E_EMAIL(["Email (Unique)"])

    %% Simple Attributes
    EMP --- E_DOB(["DOB"])
    EMP --- E_HIRE(["HireDate"])
    EMP --- E_SAL(["Salary"])
    EMP --- E_TITLE(["JobTitle"])

    %% Derived Attribute
    EMP -.- E_AGE(["Age (Derived)"])

    %% Multi-valued Attributes
    EMP --- E_PHONE(["PhoneNumber ((Multi-valued))"])
    EMP --- E_CERT(["Certifications ((Multi-valued))"])

    %% Composite Attribute: Name
    EMP --- E_NAME(["Name (Composite)"])
    E_NAME --- E_FN(["FirstName"])
    E_NAME --- E_MN(["MiddleName"])
    E_NAME --- E_LN(["LastName"])

    %% Composite Attribute: Address
    EMP --- E_ADDR(["Address (Composite)"])
    E_ADDR --- E_ST(["Street"])
    E_ADDR --- E_WD(["Ward"])
    E_ADDR --- E_DT(["District"])
    E_ADDR --- E_CT(["City"])

    %% -----------------------------------------------------------
    %% 5. ATTRIBUTES FOR DEPENDENT (Weak Entity)
    %% -----------------------------------------------------------
    DEP --- DP_PK(["<u>- - DependentName - -</u><br/>(Partial Key)"])
    DEP --- DP_GEN(["Gender"])
    DEP --- DP_DOB(["BirthDate"])
    DEP --- DP_REL(["Relationship"])
    DEP --- DP_PHN(["ContactPhone"])
    DEP --- DP_EMG(["IsEmergencyContact"])
```

> [!TIP]
> **Hướng dẫn & Lưu ý khi vẽ Subsystem 1 trên Draw.io:**
> 1. **Thực thể yếu & Quan hệ định danh:**
>    - `DEPENDENT`: Dùng hình **Double Rectangle** (Hình chữ nhật lồng đôi).
>    - `HAS_DEPENDENT` (trong Mermaid ký hiệu `{{...}}`): Bắt buộc kéo hình **Double Diamond** (Hình thoi lồng đôi) trên Draw.io.
>    - `DependentName`: Dùng hình **Oval**, gạch chân nét đứt `<u>- - DependentName - -</u>` (Partial Key / Discriminator).
> 2. **Thuộc tính suy diễn (Derived Attribute):**
>    - `Age`: Dùng hình **Oval nét đứt (Dashed Ellipse)** và đường nối từ `EMPLOYEE` sang oval cũng là **nét đứt**.
> 3. **Thuộc tính đa trị (Multi-valued Attributes):**
>    - `PhoneNumber` và `Certifications`: Dùng hình **Oval lồng đôi (Double Ellipse)**.
> 4. **Thuộc tính phức hợp (Composite Attributes):**
>    - `Name` và `Address`: Vẽ Oval mẹ nối với `EMPLOYEE`, từ Oval mẹ rẽ nhánh nối ra các Oval con (`FirstName`, `MiddleName`, `LastName` hoặc `Street`, `Ward`, `District`, `City`).
> 5. **Quan hệ đệ quy (Unary Relationship):**
>    - `SUPERVISES`: Vẽ hình thoi đơn, kéo 2 đường nối cùng xuất phát và quay về `EMPLOYEE` với 2 nhãn vai trò: `Supervisor (1)` và `Subordinate (N)`.
> 6. **Ràng buộc tham gia (Participation Constraints):**
>    - Đường từ `DEPARTMENT` đến `DEPARTMENT_HEAD` và `WORKS_IN_DEPARTMENT` là **nét đôi (Double Line / Total Participation)**.
>    - Đường từ `HAS_DEPENDENT` đến `DEPENDENT` là **nét đôi (Total Participation)**. Các đường còn lại là **nét đơn (Partial Participation)**.

---

### 3.2 Subsystem 2: Projects, Work Breakdown Structure (WBS) & Task Execution

#### 1. Conceptual Scope
This core module models contract commissioning, multi-site distributions, chronological project phasing, task dependency networking (CPM), and labor work assignments.

#### 2. Detailed Chen Element Mapping
- **`CLIENT` (Strong Entity):**
  - Attributes: `<u>ClientID</u>` (PK), `ClientName`, `ClientType`, `ContactPerson`, `ContactEmail`, `TaxCode` (Candidate Key), `ContactPhone` (Multi-valued)
- **`PROJECT` (Strong Entity):**
  - Attributes: `<u>ProjectID</u>` (PK), `ProjectName`, `StartDate`, `PlannedEndDate`, `ActualEndDate`, `EstimatedBudget`, `Status`
  - Derived Attributes: `ProjectDuration`, `ActualCost`
- **`PROJECT_SITE` (Strong Entity):**
  - Attributes: `<u>SiteID</u>` (PK), `SiteName`, `EnvironmentalPermit`, `SiteStatus`
  - Composite Attributes:
    - `LocationCoordinates` $\rightarrow$ (`Latitude`, `Longitude`)
    - `Address` $\rightarrow$ (`StreetAddress`, `District`, `City_Province`)
- **`PROJECT_PHASE` (Weak Entity):**
  - Owner Entity: `PROJECT` via identifying relationship `CONSISTS_OF_PHASES`
  - Partial Key: `<u>--PhaseNumber--</u>` (dashed underline)
  - Simple Attributes: `PhaseTitle`, `StartDate`, `TargetCompletionDate`, `PhaseBudget`, `PhaseStatus`
- **`TASK` (Strong Entity):**
  - Attributes: `<u>TaskID</u>` (PK), `TaskName`, `EstimatedHours`, `ScheduledStartDate`, `ScheduledEndDate`, `ActualEndDate`, `PriorityLevel`, `TaskStatus`
  - Derived Attribute: `ActualHours` (sum of logged worker hours)
- **Relationships:**
  - `COMMISSIONS` (1:N): `CLIENT` (Partial, 1) to `PROJECT` (Total, N)
  - `DEPARTMENT_SPONSORS_PROJECT` (1:N): `DEPARTMENT` (Partial, 1) to `PROJECT` (Total, N)
  - `DIRECTS_PROJECT` (1:1): `EMPLOYEE` (Partial, 1) to `PROJECT` (Total, 1)
  - `HAS_SITES` (1:N): `PROJECT` (Total, 1) to `PROJECT_SITE` (Total, N)
  - `CONSISTS_OF_PHASES` (Identifying 1:N): `PROJECT` (Total, 1) to `PROJECT_PHASE` (Total, N)
  - `CONTAINS_TASKS` (1:N): `PROJECT_PHASE` (Total, 1) to `TASK` (Total, N)
  - `PRECEDES` (Unary M:N): `TASK` (Predecessor, M) to `TASK` (Successor, N)
  - `WORKS_ON_TASK` (Binary M:N): `EMPLOYEE` (Partial, M) to `TASK` (Total, N)
    - Relationship Attributes: `AssignedDate`, `RoleOnTask`, `HoursLogged`

#### 3. Visual ER Diagram (Subsystem 2)
```mermaid
flowchart LR
    %% -----------------------------------------------------------
    %% 1. CORE ENTITIES & WEAK ENTITY
    %% -----------------------------------------------------------
    CLIENT["CLIENT"]
    PRJ["PROJECT"]
    SITE["PROJECT_SITE"]
    PHASE[["PROJECT_PHASE (Weak)"]]
    TASK["TASK"]

    %% External Participating Entities from Subsystem 1
    DEPT["DEPARTMENT (from S1)"]
    EMP["EMPLOYEE (from S1)"]

    %% -----------------------------------------------------------
    %% 2. RELATIONSHIPS
    %% -----------------------------------------------------------
    R_COMM{"COMMISSIONS<br/>(1:N)"}
    R_SPON{"DEPARTMENT_SPONSORS_PROJECT<br/>(1:N)"}
    R_DIR{"DIRECTS_PROJECT<br/>(1:1)"}
    R_SITE{"HAS_SITES<br/>(1:N)"}
    R_PHASE{{"CONSISTS_OF_PHASES<br/>(Identifying 1:N)"}}
    R_TSK{"CONTAINS_TASKS<br/>(1:N)"}
    R_PREC{"PRECEDES<br/>(Unary M:N)"}
    R_WORK{"WORKS_ON_TASK<br/>(M:N)"}

    %% -----------------------------------------------------------
    %% 3. CONNECTIONS & PARTICIPATION CONSTRAINTS
    %% -----------------------------------------------------------
    CLIENT ---|"Partial (1)"| R_COMM
    R_COMM == "Total (N)" === PRJ

    DEPT ---|"Partial (1)"| R_SPON
    R_SPON == "Total (N)" === PRJ

    EMP ---|"Partial (1)"| R_DIR
    R_DIR == "Total (1)" === PRJ

    PRJ == "Total (1)" === R_SITE
    R_SITE == "Total (N)" === SITE

    PRJ == "Total (1)" === R_PHASE
    R_PHASE == "Total (N)" === PHASE

    PHASE == "Total (1)" === R_TSK
    R_TSK == "Total (N)" === TASK

    TASK ---|"Predecessor (M)"| R_PREC
    R_PREC ---|"Successor (N)"| TASK

    EMP ---|"Partial (M)"| R_WORK
    R_WORK == "Total (N)" === TASK

    %% -----------------------------------------------------------
    %% 4. ATTRIBUTES FOR CLIENT
    %% -----------------------------------------------------------
    CLIENT --- C_PK(["<u>ClientID</u> (PK)"])
    CLIENT --- C_NAME(["ClientName"])
    CLIENT --- C_TYPE(["ClientType"])
    CLIENT --- C_PERSON(["ContactPerson"])
    CLIENT --- C_EMAIL(["ContactEmail"])
    CLIENT --- C_TAX(["TaxCode (Unique)"])
    CLIENT --- C_PHONE(["ContactPhone ((Multi-valued))"])

    %% -----------------------------------------------------------
    %% 5. ATTRIBUTES FOR PROJECT
    %% -----------------------------------------------------------
    PRJ --- P_PK(["<u>ProjectID</u> (PK)"])
    PRJ --- P_NAME(["ProjectName"])
    PRJ --- P_SDATE(["StartDate"])
    PRJ --- P_PEDATE(["PlannedEndDate"])
    PRJ --- P_AEDATE(["ActualEndDate"])
    PRJ --- P_BUD(["EstimatedBudget"])
    PRJ --- P_STAT(["Status"])
    PRJ -.- P_DUR(["ProjectDuration (Derived)"])
    PRJ -.- P_COST(["ActualCost (Derived)"])

    %% -----------------------------------------------------------
    %% 6. ATTRIBUTES FOR PROJECT_SITE
    %% -----------------------------------------------------------
    SITE --- S_PK(["<u>SiteID</u> (PK)"])
    SITE --- S_NAME(["SiteName"])
    SITE --- S_PERM(["EnvironmentalPermit"])
    SITE --- S_STAT(["SiteStatus"])

    %% Composite Attribute: LocationCoordinates
    SITE --- S_COORD(["LocationCoordinates (Composite)"])
    S_COORD --- S_LAT(["Latitude"])
    S_COORD --- S_LNG(["Longitude"])

    %% Composite Attribute: Address
    SITE --- S_ADDR(["Address (Composite)"])
    S_ADDR --- S_ST(["StreetAddress"])
    S_ADDR --- S_DT(["District"])
    S_ADDR --- S_CP(["City_Province"])

    %% -----------------------------------------------------------
    %% 7. ATTRIBUTES FOR PROJECT_PHASE (Weak Entity)
    %% -----------------------------------------------------------
    PHASE --- PH_PK(["<u>- - PhaseNumber - -</u><br/>(Partial Key)"])
    PHASE --- PH_TITLE(["PhaseTitle"])
    PHASE --- PH_SDATE(["StartDate"])
    PHASE --- PH_TDATE(["TargetCompletionDate"])
    PHASE --- PH_BUD(["PhaseBudget"])
    PHASE --- PH_STAT(["PhaseStatus"])

    %% -----------------------------------------------------------
    %% 8. ATTRIBUTES FOR TASK
    %% -----------------------------------------------------------
    TASK --- T_PK(["<u>TaskID</u> (PK)"])
    TASK --- T_NAME(["TaskName"])
    TASK --- T_EST(["EstimatedHours"])
    TASK -.- T_ACT(["ActualHours (Derived)"])
    TASK --- T_SDATE(["ScheduledStartDate"])
    TASK --- T_SEDATE(["ScheduledEndDate"])
    TASK --- T_AEDATE(["ActualEndDate"])
    TASK --- T_PRIO(["PriorityLevel"])
    TASK --- T_STAT(["TaskStatus"])

    %% -----------------------------------------------------------
    %% 9. ATTRIBUTES FOR RELATIONSHIP WORKS_ON_TASK
    %% -----------------------------------------------------------
    R_WORK --- R_ATTR1(["AssignedDate"])
    R_WORK --- R_ATTR2(["RoleOnTask"])
    R_WORK --- R_ATTR3(["HoursLogged"])
```

> [!TIP]
> **Hướng dẫn & Lưu ý khi vẽ Subsystem 2 trên Draw.io:**
> 1. **Thực thể yếu & Quan hệ định danh:**
>    - `PROJECT_PHASE`: Dùng hình **Double Rectangle** (Hình chữ nhật lồng đôi).
>    - `CONSISTS_OF_PHASES` (trong Mermaid ký hiệu `{{...}}`): Trên Draw.io bắt buộc dùng hình **Double Diamond** (Hình thoi lồng đôi).
>    - `PhaseNumber`: Dùng hình **Oval**, gạch chân nét đứt `<u>- - PhaseNumber - -</u>` (Partial Key / Discriminator).
> 2. **Thuộc tính suy diễn (Derived Attributes):**
>    - `ProjectDuration`, `ActualCost` (của `PROJECT`) và `ActualHours` (của `TASK`): Dùng hình **Oval nét đứt (Dashed Ellipse)** và đường nối từ thực thể sang oval cũng dùng **nét đứt**.
> 3. **Thuộc tính đa trị (Multi-valued Attribute):**
>    - `ContactPhone` của `CLIENT`: Dùng hình **Oval lồng đôi (Double Ellipse)**.
> 4. **Thuộc tính phức hợp (Composite Attributes):**
>    - `LocationCoordinates` và `Address` (của `PROJECT_SITE`): Vẽ Oval mẹ nối với `PROJECT_SITE`, từ Oval mẹ rẽ nhánh nối ra các Oval con (`Latitude`, `Longitude` hoặc `StreetAddress`, `District`, `City_Province`).
> 5. **Thuộc tính của mối quan hệ (Relationship Attributes):**
>    - 3 thuộc tính `AssignedDate`, `RoleOnTask`, `HoursLogged` nối trực tiếp vào hình thoi `WORKS_ON_TASK` (không nối vào Entity).
> 6. **Ràng buộc tham gia (Participation Constraints):**
>    - Dùng **nét đôi (Double Line)** cho các nhánh Total: `PRJ == HAS_SITES == SITE`, `PRJ == CONSISTS_OF_PHASES == PHASE`, `PHASE == CONTAINS_TASKS == TASK`, và nhánh `==` đi vào `PRJ` từ `COMMISSIONS`, `SPONSORS`, `DIRECTS`. Dùng **nét đơn (Single Line)** cho các nhánh Partial.

---

### 3.3 Subsystem 3: Heavy Machinery & Fleet Maintenance

#### 1. Conceptual Scope
This module tracks construction equipment assets, field site deployments with operator assignments, run hour accumulation, and service history.

#### 2. Detailed Chen Element Mapping
- **`EQUIPMENT` (Strong Entity):**
  - Attributes: `<u>EquipmentID</u>` (PK), `Model`, `Category`, `Ownership`, `HourlyRate`, `CurrentStatus`
  - Candidate Key: `SerialNumber` (Unique)
  - Derived Attribute: `TotalRunHours` (cumulative hours across all deployments)
- **`MAINTENANCE_RECORD` (Weak Entity):**
  - Owner Entity: `EQUIPMENT` via identifying relationship `HAS_MAINTENANCE`
  - Partial Key: `<u>--RecordNumber--</u>` (dashed underline)
  - Simple Attributes: `ServiceDate`, `MaintenanceType`, `Cost`, `ServiceVendor`
- **Relationships:**
  - `EQUIPMENT_DEPLOYMENT` (Binary M:N): `EQUIPMENT` (Partial, M) to `PROJECT_SITE` (Partial, N)
    - Relationship Attributes: `DeploymentStartDate`, `DeploymentEndDate`, `HoursOperated`, `OperatorID` (ref `EMPLOYEE`)
  - `HAS_MAINTENANCE` (Identifying 1:N): `EQUIPMENT` (Partial, 1) to `MAINTENANCE_RECORD` (Total, N)

#### 3. Visual ER Diagram (Subsystem 3)
```mermaid
flowchart LR
    %% -----------------------------------------------------------
    %% 1. ENTITIES & WEAK ENTITY
    %% -----------------------------------------------------------
    EQUIP["EQUIPMENT"]
    SITE["PROJECT_SITE (from S2)"]
    MAINT[["MAINTENANCE_RECORD (Weak)"]]

    %% -----------------------------------------------------------
    %% 2. RELATIONSHIPS
    %% -----------------------------------------------------------
    R_DEPLOY{"EQUIPMENT_DEPLOYMENT<br/>(M:N)"}
    R_MAINT{{"HAS_MAINTENANCE<br/>(Identifying 1:N)"}}

    %% Connections & Participation Constraints
    EQUIP ---|"Partial (M)"| R_DEPLOY
    R_DEPLOY ---|"Partial (N)"| SITE

    EQUIP ---|"Partial (1)"| R_MAINT
    R_MAINT == "Total (N)" === MAINT

    %% -----------------------------------------------------------
    %% 3. ATTRIBUTES FOR EQUIPMENT
    %% -----------------------------------------------------------
    EQUIP --- E_PK(["<u>EquipmentID</u> (PK)"])
    EQUIP --- E_SER(["SerialNumber (Unique)"])
    EQUIP --- E_MOD(["Model"])
    EQUIP --- E_CAT(["Category"])
    EQUIP --- E_OWN(["Ownership"])
    EQUIP --- E_RATE(["HourlyRate"])
    EQUIP --- E_STAT(["CurrentStatus"])
    EQUIP -.- E_RUN(["TotalRunHours (Derived)"])

    %% -----------------------------------------------------------
    %% 4. ATTRIBUTES FOR MAINTENANCE_RECORD (Weak Entity)
    %% -----------------------------------------------------------
    MAINT --- M_PK(["<u>- - RecordNumber - -</u><br/>(Partial Key)"])
    MAINT --- M_DATE(["ServiceDate"])
    MAINT --- M_TYPE(["MaintenanceType"])
    MAINT --- M_COST(["Cost"])
    MAINT --- M_VEND(["ServiceVendor"])

    %% -----------------------------------------------------------
    %% 5. ATTRIBUTES FOR RELATIONSHIP EQUIPMENT_DEPLOYMENT
    %% -----------------------------------------------------------
    R_DEPLOY --- D_ATTR1(["DeploymentStartDate"])
    R_DEPLOY --- D_ATTR2(["DeploymentEndDate"])
    R_DEPLOY --- D_ATTR3(["HoursOperated"])
    R_DEPLOY --- D_ATTR4(["OperatorNotes"])
```

> [!TIP]
> **Hướng dẫn & Lưu ý khi vẽ Subsystem 3 trên Draw.io:**
> 1. **Thực thể yếu & Quan hệ định danh:**
>    - `MAINTENANCE_RECORD`: Dùng hình **Double Rectangle** (Hình chữ nhật lồng đôi).
>    - `HAS_MAINTENANCE` (trong Mermaid ký hiệu `{{...}}`): Bắt buộc dùng hình **Double Diamond** (Hình thoi lồng đôi) trên Draw.io.
>    - `RecordNumber`: Dùng hình **Oval**, gạch chân nét đứt `<u>- - RecordNumber - -</u>` (Partial Key / Discriminator).
> 2. **Thuộc tính suy diễn (Derived Attribute):**
>    - `TotalRunHours`: Dùng hình **Oval nét đứt (Dashed Ellipse)** và đường nối từ `EQUIPMENT` sang oval cũng là **nét đứt**.
> 3. **Thuộc tính quan hệ (Relationship Attributes):**
>    - 4 thuộc tính `DeploymentStartDate`, `DeploymentEndDate`, `HoursOperated`, `OperatorNotes` nối trực tiếp vào hình thoi `EQUIPMENT_DEPLOYMENT`.
> 4. **Ràng buộc tham gia (Participation Constraints):**
>    - Đường từ `HAS_MAINTENANCE` đến `MAINTENANCE_RECORD` là **nét đôi (Double Line / Total Participation)**. Các nhánh còn lại là **nét đơn (Partial Participation)**.

---

### 3.4 Subsystem 4: Supply Chain, Procurement & Site Inventory

#### 1. Conceptual Scope
This module models raw material catalogs, vendor procurement orders, line item details, on-site safety inventory tracking, and three-way physical delivery dispatches.

#### 2. Detailed Chen Element Mapping
- **`SUPPLIER` (Strong Entity):**
  - Attributes: `<u>SupplierID</u>` (PK), `CompanyName`, `ContactEmail`, `CreditRating`
  - Candidate Key: `TaxCode` (Unique)
  - Multi-valued Attributes: `ContactPhone`, `SupplyCategories`
- **`MATERIAL` (Strong Entity):**
  - Attributes: `<u>MaterialID</u>` (PK), `MaterialName`, `Category`, `StandardUnit`, `UnitPrice`, `MinStock`
- **`PURCHASE_ORDER` (Strong Entity):**
  - Attributes: `<u>PO_ID</u>` (PK), `OrderDate`, `ExpectedDeliveryDate`, `DeliveryStatus`
  - Derived Attribute: `TotalPOAmount` (sum of line item subtotals)
- **`PO_ITEM` (Weak Entity):**
  - Owner Entity: `PURCHASE_ORDER` via identifying relationship `CONTAINS_ITEM`
  - Partial Key: `<u>--LineNumber--</u>` (dashed underline)
  - Simple Attributes: `QuantityOrdered`, `AgreedUnitPrice`
  - Derived Attribute: `ItemSubtotal` = (`QuantityOrdered` $\times$ `AgreedUnitPrice`)
- **Relationships:**
  - `ISSUES_PO` (1:N): `PROJECT` (Partial, 1) to `PURCHASE_ORDER` (Total, N)
  - `SUPPLIES_PO` (1:N): `SUPPLIER` (Partial, 1) to `PURCHASE_ORDER` (Total, N)
  - `CONTAINS_ITEM` (Identifying 1:N): `PURCHASE_ORDER` (Total, 1) to `PO_ITEM` (Total, N)
  - `ITEM_REFERENCES_MATERIAL` (N:1): `PO_ITEM` (Total, N) to `MATERIAL` (Partial, 1)
  - `SITE_INVENTORY` (Binary M:N): `PROJECT_SITE` (Partial, M) to `MATERIAL` (Partial, N)
    - Relationship Attributes: `CurrentStockQuantity`, `SafetyReorderQuantity`, `LastStocktakeDate`
  - `DELIVERY_DISPATCH` (Ternary M:N:P): `SUPPLIER` (M) $\times$ `MATERIAL` (N) $\times$ `PROJECT_SITE` (P)
    - Relationship Attributes: `DeliveryCode`, `DeliveryDate`, `DeliveredQuantity`, `DeliveryNotes` *(Note: In strict Chen conceptual ERD, foreign keys such as `ReceiverEmployeeID` or `PO_ID` are relational concepts and are not modeled as attributes; they are resolved during Phase 2 Logical Schema conversion).*

#### 3. Visual ER Diagram (Subsystem 4)
```mermaid
flowchart LR
    %% -----------------------------------------------------------
    %% 1. ENTITIES & WEAK ENTITY
    %% -----------------------------------------------------------
    SUPP["SUPPLIER"]
    PO["PURCHASE_ORDER"]
    POITEM[["PO_ITEM (Weak)"]]
    MAT["MATERIAL"]
    SITE["PROJECT_SITE (from S2)"]
    PRJ["PROJECT (from S2)"]

    %% -----------------------------------------------------------
    %% 2. RELATIONSHIPS
    %% -----------------------------------------------------------
    R_ISSUE{"ISSUES_PO<br/>(1:N)"}
    R_SUPP{"SUPPLIES_PO<br/>(1:N)"}
    R_ITEM{{"CONTAINS_ITEM<br/>(Identifying 1:N)"}}
    R_REF{"ITEM_REFERENCES_MATERIAL<br/>(N:1)"}
    R_INV{"SITE_INVENTORY<br/>(M:N)"}
    R_DELIV{"DELIVERY_DISPATCH<br/>(Ternary M:N:P)"}

    %% -----------------------------------------------------------
    %% 3. CONNECTIONS & PARTICIPATION CONSTRAINTS
    %% -----------------------------------------------------------
    PRJ ---|"Partial (1)"| R_ISSUE
    R_ISSUE == "Total (N)" === PO

    SUPP ---|"Partial (1)"| R_SUPP
    R_SUPP == "Total (N)" === PO

    PO == "Total (1)" === R_ITEM
    R_ITEM == "Total (N)" === POITEM

    POITEM == "Total (N)" === R_REF
    R_REF ---|"Partial (1)"| MAT

    SITE ---|"Partial (M)"| R_INV
    R_INV ---|"Partial (N)"| MAT

    SUPP ---|"M"| R_DELIV
    MAT ---|"N"| R_DELIV
    SITE ---|"P"| R_DELIV

    %% -----------------------------------------------------------
    %% 4. ATTRIBUTES FOR SUPPLIER
    %% -----------------------------------------------------------
    SUPP --- SUPP_PK(["<u>SupplierID</u> (PK)"])
    SUPP --- SUPP_NAME(["CompanyName"])
    SUPP --- SUPP_MAIL(["ContactEmail"])
    SUPP --- SUPP_RATE(["CreditRating"])
    SUPP --- SUPP_TAX(["TaxCode (Unique)"])
    SUPP --- SUPP_PHONE(["ContactPhone ((Multi-valued))"])
    SUPP --- SUPP_CAT(["SupplyCategories ((Multi-valued))"])

    %% -----------------------------------------------------------
    %% 5. ATTRIBUTES FOR MATERIAL
    %% -----------------------------------------------------------
    MAT --- MAT_PK(["<u>MaterialID</u> (PK)"])
    MAT --- MAT_NAME(["MaterialName"])
    MAT --- MAT_CAT(["Category"])
    MAT --- MAT_UNIT(["StandardUnit"])
    MAT --- MAT_PRICE(["UnitPrice"])
    MAT --- MAT_MIN(["MinStock"])

    %% -----------------------------------------------------------
    %% 6. ATTRIBUTES FOR PURCHASE_ORDER
    %% -----------------------------------------------------------
    PO --- PO_PK(["<u>PO_ID</u> (PK)"])
    PO --- PO_DATE(["OrderDate"])
    PO --- PO_EDATE(["ExpectedDeliveryDate"])
    PO --- PO_STAT(["DeliveryStatus"])
    PO -.- PO_TOT(["TotalPOAmount (Derived)"])

    %% -----------------------------------------------------------
    %% 7. ATTRIBUTES FOR PO_ITEM (Weak Entity)
    %% -----------------------------------------------------------
    POITEM --- POI_PK(["<u>- - LineNumber - -</u><br/>(Partial Key)"])
    POITEM --- POI_QTY(["QuantityOrdered"])
    POITEM --- POI_PRC(["AgreedUnitPrice"])
    POITEM -.- POI_SUB(["ItemSubtotal (Derived)"])

    %% -----------------------------------------------------------
    %% 8. ATTRIBUTES FOR RELATIONSHIPS
    %% -----------------------------------------------------------
    %% Relationship SITE_INVENTORY
    R_INV --- INV_A1(["CurrentStockQuantity"])
    R_INV --- INV_A2(["SafetyReorderQuantity"])
    R_INV --- INV_A3(["LastStocktakeDate"])

    %% Ternary Relationship DELIVERY_DISPATCH
    R_DELIV --- DEL_A1(["DeliveryCode"])
    R_DELIV --- DEL_A2(["DeliveryDate"])
    R_DELIV --- DEL_A3(["DeliveredQuantity"])
    R_DELIV --- DEL_A4(["DeliveryNotes"])
```

> [!TIP]
> **Hướng dẫn & Lưu ý khi vẽ Subsystem 4 trên Draw.io:**
> 1. **Thực thể yếu & Quan hệ định danh:**
>    - `PO_ITEM`: Dùng hình **Double Rectangle** (Hình chữ nhật lồng đôi).
>    - `CONTAINS_ITEM` (trong Mermaid ký hiệu `{{...}}`): Bắt buộc dùng hình **Double Diamond** (Hình thoi lồng đôi) trên Draw.io.
>    - `LineNumber`: Dùng hình **Oval**, gạch chân nét đứt `<u>- - LineNumber - -</u>` (Partial Key / Discriminator).
> 2. **Quan hệ 3 ngôi (Ternary Relationship - DELIVERY_DISPATCH):**
>    - Kéo 1 hình thoi **DELIVERY_DISPATCH**, vẽ 3 đường nối xuất phát từ 3 thực thể: `SUPPLIER`, `MATERIAL` và `PROJECT_SITE`. Ghi tỉ lệ `M`, `N`, `P` lên từng nhánh.
>    - Nối 4 Oval thuộc tính (`DeliveryCode`, `DeliveryDate`, `DeliveredQuantity`, `DeliveryNotes`) trực tiếp vào hình thoi `DELIVERY_DISPATCH`.
> 3. **Thuộc tính suy diễn (Derived Attributes):**
>    - `TotalPOAmount` (của `PURCHASE_ORDER`) và `ItemSubtotal` (của `PO_ITEM`): Dùng hình **Oval nét đứt (Dashed Ellipse)** và đường nối là **nét đứt**.
> 4. **Thuộc tính đa trị (Multi-valued Attributes):**
>    - `ContactPhone` và `SupplyCategories` của `SUPPLIER`: Dùng hình **Oval lồng đôi (Double Ellipse)**.
> 5. **Ràng buộc tham gia (Participation Constraints):**
>    - Nhánh `==` (Total Participation): `PURCHASE_ORDER` vào `CONTAINS_ITEM`, `PO_ITEM` vào `CONTAINS_ITEM`, `PO_ITEM` vào `ITEM_REFERENCES_MATERIAL`, và `PURCHASE_ORDER` đi từ `ISSUES_PO`, `SUPPLIES_PO`.

---

### 3.5 Subsystem 5: Trade Subcontractors

#### 1. Conceptual Scope
This module handles specialized trade contractors, trade certifications, and contract engagement terms.

#### 2. Detailed Chen Element Mapping
- **`SUBCONTRACTOR` (Strong Entity):**
  - Attributes: `<u>SubcontractorID</u>` (PK), `CompanyName`, `TradeSpecialty`, `ContactEmail`, `ContactPhone`, `SafetyRatingScore`
  - Candidate Keys: `TaxCode` (Unique), `LicenseNumber` (Unique)
- **Relationship:**
  - `ENGAGES_SUBCONTRACTOR` (Binary M:N): `PROJECT` (Partial, M) to `SUBCONTRACTOR` (Partial, N)
    - Relationship Attributes: `ContractAgreementNo`, `ScopeDescription`, `ContractValue`, `WarrantyHoldRate`, `StartDate`, `CompletionDate`

#### 3. Visual ER Diagram (Subsystem 5)
```mermaid
flowchart TB
    %% -----------------------------------------------------------
    %% 1. ENTITIES
    %% -----------------------------------------------------------
    PRJ["PROJECT (from S2)"]
    SUBCON["SUBCONTRACTOR"]

    %% -----------------------------------------------------------
    %% 2. RELATIONSHIPS
    %% -----------------------------------------------------------
    R_ENGAGE{"ENGAGES_SUBCONTRACTOR<br/>(M:N)"}

    %% Connections & Participation Constraints
    PRJ ---|"Partial (M)"| R_ENGAGE
    R_ENGAGE ---|"Partial (N)"| SUBCON

    %% -----------------------------------------------------------
    %% 3. ATTRIBUTES FOR SUBCONTRACTOR
    %% -----------------------------------------------------------
    SUBCON --- SC_PK(["<u>SubcontractorID</u> (PK)"])
    SUBCON --- SC_NAME(["CompanyName"])
    SUBCON --- SC_TAX(["TaxCode (Unique)"])
    SUBCON --- SC_LIC(["LicenseNumber (Unique)"])
    SUBCON --- SC_SPEC(["TradeSpecialty"])
    SUBCON --- SC_MAIL(["ContactEmail"])
    SUBCON --- SC_PHONE(["ContactPhone"])
    SUBCON --- SC_SCORE(["SafetyRatingScore"])

    %% -----------------------------------------------------------
    %% 4. ATTRIBUTES FOR RELATIONSHIP ENGAGES_SUBCONTRACTOR
    %% -----------------------------------------------------------
    R_ENGAGE --- SC_A1(["ContractAgreementNo"])
    R_ENGAGE --- SC_A2(["ScopeDescription"])
    R_ENGAGE --- SC_A3(["ContractValue"])
    R_ENGAGE --- SC_A4(["WarrantyHoldRate"])
    R_ENGAGE --- SC_A5(["StartDate"])
    R_ENGAGE --- SC_A6(["CompletionDate"])
```

> [!TIP]
> **Hướng dẫn & Lưu ý khi vẽ Subsystem 5 trên Draw.io:**
> 1. **Thuộc tính thực thể:**
>    - `SubcontractorID`: Gạch chân nét liền `<u>SubcontractorID</u>` trong hình **Oval** (Primary Key).
>    - `TaxCode` và `LicenseNumber`: Ghi nhãn `(Unique)` hoặc `(Candidate Key)` trong hình **Oval**.
> 2. **Thuộc tính của mối quan hệ M:N:**
>    - 6 thuộc tính hợp đồng (`ContractAgreementNo`, `ScopeDescription`, `ContractValue`, `WarrantyHoldRate`, `StartDate`, `CompletionDate`) phải nối trực tiếp vào hình thoi `ENGAGES_SUBCONTRACTOR`.
> 3. **Ràng buộc tham gia (Participation Constraints):**
>    - Cả 2 phía `PROJECT` và `SUBCONTRACTOR` đều dùng **nét đơn (Partial Participation)** vì một dự án có thể chưa thuê thầu phụ, và một nhà thầu phụ có thể chưa được giao dự án nào.

---

### 3.6 Subsystem 6: Site Safety, Audits & Incident Management

#### 1. Conceptual Scope
This module models site safety compliance audits conducted by certified inspectors, workplace incident logging, affected worker tracing, and emergency contact linkage.

#### 2. Detailed Chen Element Mapping
- **`SAFETY_INSPECTION` (Strong Entity):**
  - Attributes: `<u>InspectionID</u>` (PK), `InspectionDate`, `InspectionType`, `InspectionScope`, `OverallScore`, `InspectionResult`, `ViolationNoted`, `FixDeadline`
- **`INCIDENT_REPORT` (Strong Entity):**
  - Attributes: `<u>IncidentID</u>` (PK), `IncidentTimestamp`, `IncidentType`, `IncidentLevel`, `DamageDescription`, `LostDays`, `Solution`
- **Relationships:**
  - `CONDUCTS_INSPECTION` (Dual 1:N binary structure):
    - `PROJECT_SITE` (Partial, 1) to `SAFETY_INSPECTION` (Total, N) via `INSPECTS_SITE`
    - `EMPLOYEE` (Safety Inspector, Partial, 1) to `SAFETY_INSPECTION` (Total, N) via `CONDUCTS_AUDIT`
  - `LOGS_INCIDENT` (Binary 1:N): `PROJECT_SITE` (Partial, 1) to `INCIDENT_REPORT` (Total, N)
  - `INVOLVES_EMPLOYEE` (Binary 1:N): `EMPLOYEE` (Partial, 1) to `INCIDENT_REPORT` (Partial, N)

#### 3. Visual ER Diagram (Subsystem 6)
```mermaid
flowchart LR
    %% -----------------------------------------------------------
    %% 1. ENTITIES
    %% -----------------------------------------------------------
    SITE["PROJECT_SITE (from S2)"]
    EMP_INS["EMPLOYEE (Safety Inspector - from S1)"]
    EMP_VIC["EMPLOYEE (Involved Worker - from S1)"]
    INSP["SAFETY_INSPECTION"]
    INC["INCIDENT_REPORT"]

    %% -----------------------------------------------------------
    %% 2. RELATIONSHIPS
    %% -----------------------------------------------------------
    R_SITE_INSP{"INSPECTS_SITE<br/>(1:N)"}
    R_EMP_INSP{"CONDUCTS_AUDIT<br/>(1:N)"}
    R_INC{"LOGS_INCIDENT<br/>(1:N)"}
    R_INV{"INVOLVES_EMPLOYEE<br/>(1:N)"}

    %% Inspection Relationships Connections
    SITE ---|"Partial (1)"| R_SITE_INSP
    R_SITE_INSP == "Total (N)" === INSP

    EMP_INS ---|"Inspector (1)"| R_EMP_INSP
    R_EMP_INSP == "Total (N)" === INSP

    %% Incident Relationships Connections
    SITE ---|"Partial (1)"| R_INC
    R_INC == "Total (N)" === INC

    EMP_VIC ---|"Involved Worker (1)"| R_INV
    R_INV ---|"Partial (N)"| INC

    %% -----------------------------------------------------------
    %% 3. ATTRIBUTES FOR SAFETY_INSPECTION
    %% -----------------------------------------------------------
    INSP --- INSP_PK(["<u>InspectionID</u> (PK)"])
    INSP --- INSP_DATE(["InspectionDate"])
    INSP --- INSP_TYPE(["InspectionType"])
    INSP --- INSP_SCOPE(["InspectionScope"])
    INSP --- INSP_SCORE(["OverallScore"])
    INSP --- INSP_RES(["InspectionResult"])
    INSP --- INSP_VIOL(["ViolationNoted"])
    INSP --- INSP_DEAD(["FixDeadline"])

    %% -----------------------------------------------------------
    %% 4. ATTRIBUTES FOR INCIDENT_REPORT
    %% -----------------------------------------------------------
    INC --- INC_PK(["<u>IncidentID</u> (PK)"])
    INC --- INC_TIME(["IncidentTimestamp"])
    INC --- INC_TYPE(["IncidentType"])
    INC --- INC_LVL(["IncidentLevel"])
    INC --- INC_DMG(["DamageDescription"])
    INC --- INC_LOST(["LostDays"])
    INC --- INC_SOL(["Solution"])
```

> [!TIP]
> **Hướng dẫn & Lưu ý khi vẽ Subsystem 6 trên Draw.io:**
> 1. **Mô hình hóa thanh tra an toàn (Dual 1:N):**
>    - Vẽ 2 hình thoi nhị phân riêng biệt: `INSPECTS_SITE` (giữa `PROJECT_SITE` và `SAFETY_INSPECTION`) và `CONDUCTS_AUDIT` (giữa `EMPLOYEE` và `SAFETY_INSPECTION`).
> 2. **Ràng buộc tham gia (Participation Constraints):**
>    - `SAFETY_INSPECTION` bắt buộc phải có công trường và thanh tra viên $\to$ 2 nhánh đi vào `SAFETY_INSPECTION` là **nét đôi (Double Line / Total Participation)**.
>    - `PROJECT_SITE` và `EMPLOYEE` đều là **nét đơn (Partial Participation)** (công trường chưa chắc đã thanh tra, công nhân bình thường không làm thanh tra).
>    - `INCIDENT_REPORT` bắt buộc xảy ra tại một công trường $\to$ nhánh từ `LOGS_INCIDENT` vào `INCIDENT_REPORT` là **nét đôi (Total)**.
>    - Nhánh `INVOLVES_EMPLOYEE` là **nét đơn ở cả 2 đầu** (vì có những sự cố chỉ thiệt hại máy móc/tài sản mà không có người bị thương).

---

## 4. Master ERD Representation (Complete Entity-Relationship Network)

The following diagram connects all 17 entity types across relationships into a unified conceptual schema (Crow's Foot notation):

```mermaid
erDiagram
    DEPARTMENT ||--o| EMPLOYEE : manages
    DEPARTMENT ||--|{ EMPLOYEE : employs
    EMPLOYEE o|--o{ EMPLOYEE : supervises
    EMPLOYEE ||--o{ DEPENDENT : has_dependent
    
    CLIENT ||--o{ PROJECT : commissions
    DEPARTMENT ||--o{ PROJECT : sponsors
    EMPLOYEE ||--o| PROJECT : directs
    PROJECT ||--|{ PROJECT_SITE : has_sites
    PROJECT ||--|{ PROJECT_PHASE : consists_of
    
    PROJECT_PHASE ||--|{ TASK : contains_tasks
    TASK }o--o{ TASK : precedes
    EMPLOYEE }|--o{ TASK : works_on
    
    EQUIPMENT }o--o{ PROJECT_SITE : deployed_to
    EQUIPMENT ||--o{ MAINTENANCE_RECORD : maintains
    
    PROJECT ||--o{ PURCHASE_ORDER : issues
    SUPPLIER ||--o{ PURCHASE_ORDER : supplies
    PURCHASE_ORDER ||--|{ PO_ITEM : contains_items
    PO_ITEM }o--|| MATERIAL : references
    PROJECT_SITE }o--o{ MATERIAL : stocks
    
    PROJECT }o--o{ SUBCONTRACTOR : engages
    
    PROJECT_SITE ||--o{ SAFETY_INSPECTION : inspects
    EMPLOYEE ||--o{ SAFETY_INSPECTION : conducts
    PROJECT_SITE ||--o{ INCIDENT_REPORT : logs
    EMPLOYEE o|--o{ INCIDENT_REPORT : involves
```

> [!IMPORTANT]
> **Ternary Relationship Representation Note (`DELIVERY_DISPATCH`):**
> Cú pháp tiêu chuẩn của Mermaid `erDiagram` chỉ hỗ trợ quan hệ nhị phân (Binary - giữa 2 thực thể). Do đó, mối quan hệ bậc 3 (Ternary M:N:P) `DELIVERY_DISPATCH` giữa `SUPPLIER` $\times$ `MATERIAL` $\times$ `PROJECT_SITE` không thể vẽ trực tiếp trong block `erDiagram` trên mà không làm biến dạng mô hình. Mối quan hệ này được đặc tả chi tiết tại **Phân hệ 4 (Mục 3.4)**, **Bảng ma trận quan hệ (Mục 5, STT 20)** và được vẽ đầy đủ bằng hình thoi 3 nhánh theo chuẩn Chen trên bản vẽ nộp chính thức (Draw.io / Vector PDF).

---

## 5. Master Structural Constraints & Cardinality Matrix

This table summarizes all constraints, cardinalities, participations, and relationship attributes across the entire schema:

| No. | Relationship Name | Participating Entities | Ratio | Participation Constraints | Relationship Attributes |
| :---: | :--- | :--- | :---: | :--- | :--- |
| **1** | `DEPARTMENT_HEAD` | `EMPLOYEE` : `DEPARTMENT` | 1:1 | `DEPT`: Total, `EMP`: Partial | *None* |
| **2** | `WORKS_IN_DEPARTMENT` | `DEPARTMENT` : `EMPLOYEE` | 1:N | `EMP`: Total, `DEPT`: Total | *None* |
| **3** | `SUPERVISES` | `EMPLOYEE` : `EMPLOYEE` | Unary 1:N | Both roles: Partial | *None* |
| **4** | `HAS_DEPENDENT` | `EMPLOYEE` : `DEPENDENT` | Ident. 1:N | `DEP`: Total, `EMP`: Partial | *None* |
| **5** | `COMMISSIONS` | `CLIENT` : `PROJECT` | 1:N | `PRJ`: Total, `CLIENT`: Partial | *None* |
| **6** | `DEPARTMENT_SPONSORS_PROJECT` | `DEPARTMENT` : `PROJECT` | 1:N | `PRJ`: Total, `DEPT`: Partial | *None* |
| **7** | `DIRECTS_PROJECT` | `EMPLOYEE` : `PROJECT` | 1:1 | `PRJ`: Total, `EMP`: Partial | *None* |
| **8** | `HAS_SITES` | `PROJECT` : `PROJECT_SITE` | 1:N | `PRJ`: Total, `SITE`: Total | *None* |
| **9** | `CONSISTS_OF_PHASES` | `PROJECT` : `PROJECT_PHASE` | Ident. 1:N | `PHASE`: Total, `PRJ`: Total | *None* |
| **10** | `CONTAINS_TASKS` | `PROJECT_PHASE` : `TASK` | 1:N | `PHASE`: Total, `TASK`: Total | *None* |
| **11** | `PRECEDES` | `TASK` : `TASK` | Unary M:N | Both roles: Partial | *None* |
| **12** | `WORKS_ON_TASK` | `EMPLOYEE` : `TASK` | M:N | `TASK`: Total, `EMP`: Partial | `AssignedDate`, `RoleOnTask`, `HoursLogged` |
| **13** | `EQUIPMENT_DEPLOYMENT` | `EQUIPMENT` : `PROJECT_SITE` | M:N | Both sides: Partial | `DeploymentStartDate`, `DeploymentEndDate`, `HoursOperated`, `OperatorID` |
| **14** | `HAS_MAINTENANCE` | `EQUIPMENT` : `MAINTENANCE_RECORD` | Ident. 1:N | `RECORD`: Total, `EQUIP`: Partial | *None* |
| **15** | `ISSUES_PO` | `PROJECT` : `PURCHASE_ORDER` | 1:N | `PO`: Total, `PRJ`: Partial | *None* |
| **16** | `SUPPLIES_PO` | `SUPPLIER` : `PURCHASE_ORDER` | 1:N | `PO`: Total, `SUPP`: Partial | *None* |
| **17** | `CONTAINS_ITEM` | `PURCHASE_ORDER` : `PO_ITEM` | Ident. 1:N | `ITEM`: Total, `PO`: Total | *None* |
| **18** | `ITEM_REFERENCES_MATERIAL` | `PO_ITEM` : `MATERIAL` | N:1 | `ITEM`: Total, `MAT`: Partial | *None* |
| **19** | `SITE_INVENTORY` | `PROJECT_SITE` : `MATERIAL` | M:N | Both sides: Partial | `CurrentStockQuantity`, `SafetyReorderQuantity`, `LastStocktakeDate` |
| **20** | `DELIVERY_DISPATCH` | `SUPPLIER` $\times$ `MATERIAL` $\times$ `PROJECT_SITE` | Ternary M:N:P | All 3 sides: Partial | `DeliveryCode`, `DeliveryDate`, `DeliveredQuantity`, `DeliveryNotes` |
| **21** | `ENGAGES_SUBCONTRACTOR` | `PROJECT` : `SUBCONTRACTOR` | M:N | Both sides: Partial | `ContractAgreementNo`, `ScopeDescription`, `ContractValue`, `WarrantyHoldRate`, `StartDate`, `CompletionDate` |
| **22** | `CONDUCTS_INSPECTION` | `PROJECT_SITE` : `SAFETY_INSPECTION` : `EMPLOYEE` | Dual 1:N | `INSP`: Total on both branches | *None* |
| **23** | `LOGS_INCIDENT` | `PROJECT_SITE` : `INCIDENT_REPORT` | 1:N | `INC`: Total, `SITE`: Partial | *None* |
| **24** | `INVOLVES_EMPLOYEE` | `EMPLOYEE` : `INCIDENT_REPORT` | 1:N | Both sides: Partial | *None* |

---

## 6. Business Constraints Not Expressible in ER Notation

Per the instructions of Dr. Hoang Dang Hai, business constraints and integrity rules that cannot be captured graphically through Chen's ER notations are explicitly documented here and will be enforced via SQL triggers, stored procedures, or check constraints in Phase 3:

1. **Phase Budget Accumulation Constraint:**
   - $\sum (\text{PhaseBudget}) \le \text{EstimatedBudget}$ for any given project. ER notation cannot express aggregate inequality constraints across child records.
2. **Machinery Schedule Non-Overlapping Constraint:**
   - A piece of equipment cannot have overlapping `[DeploymentStartDate, DeploymentEndDate]` intervals across two different `PROJECT_SITE`s. ER notation cannot evaluate interval disjointness across M:N relationship instances.
3. **Equipment Operator Certification Rule:**
   - An employee assigned as `OperatorID` on an `EQUIPMENT_DEPLOYMENT` must hold an active certification corresponding to the equipment's `Category` in their multi-valued `Certifications` attribute.
4. **Maximum Daily Working Hour Limit:**
   - A worker cannot log more than 12 hours total ($\sum \text{HoursLogged} \le 12$) across all tasks on any single calendar date.
5. **Acyclic Dependency Constraint (DAG):**
   - The recursive `PRECEDES` relationship on `TASK` must form a Directed Acyclic Graph (DAG) without circular dependency loops ($T_A \to T_B \to \dots \to T_A$).
6. **Material Stock Overdraft Prevention:**
   - Daily material consumption deducted from `SITE_INVENTORY` cannot exceed `CurrentStockQuantity`.
7. **Single Active Project Limit for Site Directors:**
   - Although `DIRECTS_PROJECT` is modeled as 1:1, an employee can direct at most one project whose `Status` is `Active` or `In-Progress` simultaneously.
8. **Emergency Notification Trigger:**
   - When an `INCIDENT_REPORT` is created with `INVOLVES_EMPLOYEE` populated, the system automatically fires a lookup to find the employee's dependent where `IsEmergencyContact = true` to dispatch an urgent notification.

---

## 7. Guidelines for Exporting and Drawing in Draw.io (diagrams.net)

To produce the high-resolution vector diagrams for your final Word/PDF report:

1. Open [draw.io](https://app.diagrams.net/).
2. In the left panel, click **More Shapes** $\rightarrow$ Check **Entity Relation**.
3. Use the shapes strictly adhering to Chen's notation:
   - **Entity:** `Rectangle`
   - **Weak Entity:** `Double Rectangle`
   - **Relationship:** `Rhombus / Diamond`
   - **Identifying Relationship:** `Double Rhombus / Diamond`
   - **Attribute:** `Ellipse`
   - **Primary Key:** `Underline text`
   - **Partial Key:** `Dashed underline text`
   - **Multi-valued Attribute:** `Double Ellipse`
   - **Derived Attribute:** `Dashed Ellipse`
   - **Participation:** Use double lines for Total participation (`Format panel` $\rightarrow$ `Line` $\rightarrow$ `Double`).
4. Recommended export format: **PDF** hoặc **SVG** (vector format ensures zero blurriness when printed or converted to Word).

