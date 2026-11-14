# Database Systems Term Project — Phase 3 Report
## Normalization & Physical Database Implementation (A34Build)

- **Topic:** Database System for a Multi-Project Construction Enterprise (**A34Build**)
- **Course:** Database Systems [E24-Class 5]
- **Team:** Group 5
- **Members:**
  - Lê Anh Minh (`B24DCCE180`)
  - Ứng Trọng Trình (`B24DCCE271`)
  - Nguyễn Đinh Anh Quân (`B24DCCE222`)
- **Instructor:** Dr. Nguyen Dinh Hoa (`hoand@ptit.edu.vn`)
- **Submission Date:** November 14, 2026

---

## 1. Introduction & Final Relational Schema

This Phase 3 report completes the **logical normalization (3NF)** and **physical implementation** of the **A34Build** enterprise database system on **MySQL 8.0+**, building upon the Conceptual Design (ERD) and Relational Schema Mapping established in Phase 2.

The system covers **6 core operational subsystems** across **29 normalized tables** (plus 1 automated audit log table, `EMERGENCY_DISPATCH_LOG`, for safety alerting):
1. **Organization & Human Resources (HR):** `DEPARTMENT`, `EMPLOYEE`, `EMPLOYEE_PHONE`, `EMPLOYEE_CERTIFICATION`, `DEPENDENT`
2. **Project Management & WBS:** `CLIENT`, `CLIENT_PHONE`, `PROJECT`, `PROJECT_SITE`, `PROJECT_PHASE`, `TASK`, `PRECEDES`, `WORKS_ON_TASK`
3. **Heavy Machinery & Fleet Maintenance:** `EQUIPMENT`, `MAINTENANCE_RECORD`, `EQUIPMENT_DEPLOYMENT`
4. **Procurement, Materials & Site Inventory:** `SUPPLIER`, `SUPPLIER_PHONE`, `MATERIAL`, `PURCHASE_ORDER`, `PO_ITEM`, `SITE_INVENTORY`, `DELIVERY_DISPATCH`, `MATERIAL_USAGE`
5. **Trade Subcontractors:** `SUBCONTRACTOR`, `SUBCONTRACT`
6. **Health, Safety & Environment (HSE):** `SAFETY_INSPECTION`, `INCIDENT_REPORT`, `EMERGENCY_DISPATCH_LOG` (trigger audit table)

---

## 2. Functional Dependencies & Normalization (3NF)

> **[NOTE FOR WORD EXPORT]:** Paste the full 29-table Functional Dependencies, Candidate Keys, and 1NF $\to$ 2NF $\to$ 3NF analysis from `docs/Phase 3/Phase3.1.md` (Sections 2 & 3) into this section, or keep the summary below followed by the detailed tables.

### 2.1 Overview & Key Normalization Findings

All 29 relational schemas mapped from the Phase 2 ERD were audited against 1NF, 2NF, and 3NF criteria (Elmasri & Navathe, *Fundamentals of Database Systems*, 6th ed., Chapter 14):
- **27 schemas** satisfy **3NF** directly without structural modification.
- **2 schemas** exhibited normal form violations from initial ERD mapping and were decomposed/corrected:

| Table | Initial Defect (Phase 2) | Violation | 3NF Correction (Phase 3) |
| :--- | :--- | :---: | :--- |
| **`EQUIPMENT_DEPLOYMENT`** | `SiteID` was included in the composite PK `(EquipmentID, SiteID, DeploymentStartDate)`, even though `{EquipmentID, DeploymentStartDate} -> SiteID`. | **2NF** (Partial Key Dependency) | Moved `SiteID` out of the PK into a non-prime FK. Minimal PK: `(EquipmentID, DeploymentStartDate)`. |
| **`DELIVERY_DISPATCH`** | Stored both `PO_ID` and `SupplierID`, creating a transitive dependency `DeliveryCode -> PO_ID -> SupplierID` via `PURCHASE_ORDER`. | **3NF** (Transitive Dependency) | Removed `SupplierID` from `DELIVERY_DISPATCH`. Vendor is resolved via FK `PO_ID -> PURCHASE_ORDER`. |

*(Insert detailed FD & Candidate Key tables from `docs/Phase 3/Phase3.1.md` here.)*

---

## 3. Physical Database Design & Implementation Details

### 3.1 DBMS Selection & Configuration
We selected **MySQL Community Server 8.0.46** (with **MySQL Workbench 8.0**) for physical implementation based on the following technical requirements:
- **InnoDB Storage Engine:** Enforces ACID transactions and strict referential integrity (`FOREIGN KEY` with `ON UPDATE CASCADE`, `ON DELETE RESTRICT / CASCADE / SET NULL`).
- **Native `CHECK` Constraints:** Supported in MySQL 8.0.16+ for domain validation (e.g., `Salary > 0`, `HoursLogged BETWEEN 0 AND 24`, `ScheduledEndDate >= StartDate`).
- **Recursive Common Table Expressions (`WITH RECURSIVE`):** Required for both hierarchical employee reporting queries and Directed Acyclic Graph (DAG) cycle detection on `PRECEDES`.
- **Triggers (`SIGNAL SQLSTATE '45000'`):** Enables enforcement of complex cross-table business rules that cannot be expressed on a static ERD.
- **Character Set:** `utf8mb4` with `utf8mb4_unicode_ci` collation for full Vietnamese and multilingual text support.

### 3.2 Database Scripts Organization (`deliverables/sql/`)

1. **`01_schema_ddl.sql` (DDL — 29 Core Tables & Indexes):**
   - Creates `A34Build_DB` and all 29 normalized 3NF tables.
   - Resolves the circular foreign key between `DEPARTMENT.HeadEmpID` and `EMPLOYEE.DeptID` using a deferred `ALTER TABLE DEPARTMENT ADD CONSTRAINT FK_DEPARTMENT_HeadEmpID ...` statement.
   - Adds performance indexes on frequently joined/filtered foreign keys (`IDX_EMPLOYEE_DeptID`, `IDX_PROJECT_ClientID`, `IDX_INCIDENT_REPORT_Site`, etc.).
2. **`02_triggers_procedures.sql` (8 Business Rule Triggers):**
   - Creates `EMERGENCY_DISPATCH_LOG` and registers triggers enforcing all **8 complex business rules** identified in Phase 2:
     - **Rule 1:** Total `PhaseBudget` cannot exceed `PROJECT.EstimatedBudget`.
     - **Rule 2:** No overlapping `EQUIPMENT_DEPLOYMENT` date intervals for the same machine.
     - **Rule 3:** Equipment operator must hold a valid certification matching the equipment category.
     - **Rule 4:** Worker logged hours cannot exceed 12.00 hours per calendar day.
     - **Rule 5:** `PRECEDES` task dependencies must form a DAG (no self-loops or cycles, checked via `WITH RECURSIVE`).
     - **Rule 6:** Material usage cannot exceed `SITE_INVENTORY.CurrentStockQuantity` (automatically deducts stock).
     - **Rule 7:** Delivered quantity for a PO line item cannot exceed ordered quantity.
     - **Rule 8:** `Level-2` to `Level-4` incidents automatically look up the injured employee's `DEPENDENT` and log an emergency dispatch notification in `EMERGENCY_DISPATCH_LOG`.
3. **`03_sample_data_dml.sql` (Realistic Sample Data):**
   - Populates all 29 tables with realistic Vietnamese construction project data (projects in Hanoi, Da Nang, and Ho Chi Minh City; 12+ employees, equipment fleet, POs, site inventory, subcontractors, safety inspections, and incident reports).
4. **`04_business_queries.sql` (Operational & Analytical Queries):**
   - Implements 9 queries/reports covering operational checks, recursive hierarchy, cost/budget variance, Earned Value Management (EVM), safety & incident audit, fleet utilization, and trigger verification.

---

## 4. Proofs of Implementation

### 4.1 Schema Creation & Reverse-Engineered Physical ERD

> **[INSERT SCREENSHOT 1: MySQL Workbench `Schemas` panel showing `a34build_db` and the 30 tables (`29 core + EMERGENCY_DISPATCH_LOG`), plus the green Action Output confirming `01_schema_ddl.sql` executed with 0 errors.]**

*Figure 4.1: Successful creation of `A34Build_DB` and all normalized tables in MySQL Workbench 8.0.*

> **[INSERT SCREENSHOT 2: Reverse-Engineered Physical ERD generated via `Database -> Reverse Engineer...` in MySQL Workbench.]**

*Figure 4.2: Reverse-engineered physical schema diagram verifying all primary keys and foreign key relationships.*

---

### 4.2 Sample Data Population

Sample queries verifying realistic data population across core tables:

```sql
USE A34Build_DB;
SELECT EmpID, FirstName, LastName, JobTitle, Salary, DeptID FROM EMPLOYEE LIMIT 10;
SELECT ProjectID, ProjectName, EstimatedBudget, ActualCost, Status FROM PROJECT;
```

> **[INSERT SCREENSHOT 3: Result Grid of `SELECT * FROM EMPLOYEE LIMIT 10;` and `SELECT * FROM PROJECT;`.]**

*Figure 4.3: Verification of sample data populated in `EMPLOYEE` and `PROJECT`.*

---

### 4.3 Proof of Business Rule & Trigger Enforcement

#### A. Blocking Invalid Operations (Trigger Rejection Test Cases)

1. **Rule 1 Test (Budget Overrun Prevention):**
```sql
INSERT INTO PROJECT_PHASE (ProjectID, PhaseNumber, PhaseName, PhaseBudget, StartDate, ScheduledEndDate, Status)
VALUES ('PRJ001', 4, 'Test Invalid Phase Budget Overrun', 30000000000.00, '2025-07-01', '2025-09-30', 'Pending');
-- Expected Error 45000: Rule 1 Violation: Total PhaseBudget cannot exceed Project EstimatedBudget.
```

2. **Rule 5 Test (DAG Cycle Prevention on `PRECEDES`):**
```sql
INSERT INTO PRECEDES (PredecessorTaskID, SuccessorTaskID) VALUES ('TSK103', 'TSK101');
-- Expected Error 45000: Rule 5 Violation: Circular dependency detected in task precedence (Violates DAG).
```

> **[INSERT SCREENSHOT 4: Red error output in MySQL Workbench showing `SQLSTATE 45000` blocking the invalid `INSERT` statement(s).]**

*Figure 4.4: Trigger enforcement rejecting business rule violations (`SQLSTATE '45000'`).*

#### B. Automated Emergency Dispatch (Rule 8 — Verification Query 3.1)

When `INC-2024-02` (`Level-2` injury involving `EMP010`) was inserted into `INCIDENT_REPORT`, the `AFTER INSERT` trigger automatically queried `DEPENDENT` and generated an emergency alert in `EMERGENCY_DISPATCH_LOG`:

> **[INSERT SCREENSHOT 5: Result Grid of Verification Query 3.1 (`SELECT ... FROM EMERGENCY_DISPATCH_LOG JOIN EMPLOYEE ...`).]**

*Figure 4.5: Automated emergency dispatch log generated by the Rule 8 trigger.*

---

### 4.4 Business & Analytical Queries Execution

1. **Query 1.2 — Site Inventory Safety Stock Deficit Alert:** Identifies materials at project sites where `CurrentStockQuantity <= MinStock`.
   > **[INSERT SCREENSHOT 6: Result Grid of Query 1.2.]**

2. **Query 1.3 — Recursive Reporting Hierarchy (`WITH RECURSIVE` CTE):** Displays the full multi-level organizational reporting tree from top management down to site staff.
   > **[INSERT SCREENSHOT 7: Result Grid of Query 1.3.]**

3. **Report 2.1 — Multi-Dimensional Project Cost vs. Budget Variance:** Aggregates phase budgets and actual costs per project to flag budget overruns/savings.
   > **[INSERT SCREENSHOT 8: Result Grid of Report 2.1.]**

4. **Report 2.2 — Earned Value Analysis (EVM) Project Health:** Computes Planned Value (PV), Earned Value (EV), Actual Cost (AC), CPI, and SPI.
   > **[INSERT SCREENSHOT 9: Result Grid of Report 2.2.]**

5. **Report 2.3 — Comprehensive Site Safety & Incident Audit Report:** Summarizes safety inspection scores, passed/deficient audits, recorded incidents, and lost injury days per site.
   > **[INSERT SCREENSHOT 10: Result Grid of Report 2.3.]**

---

## 5. Conclusion

In Phase 3, the **A34Build** database was rigorously verified against 1NF, 2NF, and 3NF—eliminating partial and transitive dependencies in `EQUIPMENT_DEPLOYMENT` and `DELIVERY_DISPATCH`—and deployed on **MySQL 8.0**. All 29 core tables, 8 complex business rule triggers, realistic sample datasets, and analytical queries executed successfully, demonstrating complete structural integrity and operational readiness.
