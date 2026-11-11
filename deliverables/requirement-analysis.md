# Database Design Term Project (Phase 2)
## Part 1: Requirement Analysis
- **Topic:** Database system for a construction company with multiple projects
- **Course:** Database [E24-Class 5]
- **Team:** 5
- **Members:**
  - Lê Anh Minh (B24DCCE180)
  - Ứng Trọng Trình (B24DCCE271)
  - Nguyễn Đinh Anh Quân (B24DCCE222)
- **Instructor:** Dr. Nguyen Dinh Hoa (`hoand@ptit.edu.vn`)

---

## 1. Company background and scenario

### 1.1 Overview
A34Build is a general contractor handling civil infrastructure, commercial buildings, and industrial facilities. The company runs multiple active projects at the same time across different sites. Each project has fixed deadlines, strict budgets, and safety requirements. Daily work involves field engineers, site managers, equipment operators, heavy machinery, specialized subcontractors, and tons of building materials.

The company currently relies on spreadsheets and paper logs. This causes scheduling delays, budget overruns, inventory loss at job sites, and slow cost tracking. The goal is to build a centralized relational database to manage projects, staff, equipment, materials, subcontracts, and site safety.

### 1.2 Main business operations
The database covers seven main operational areas:
1. **Projects:** Client contracts, job sites, phases, and task schedules.
2. **Workforce:** Job roles, reporting hierarchy, certifications, and task assignments.
3. **Equipment:** Owned and rented machinery, site deployments, run hours, and maintenance logs.
4. **Materials:** Suppliers, purchase orders, site deliveries, and stock levels.
5. **Subcontractors:** Trade specialties, contract agreements, and safety ratings.
6. **Project costs:** Budget tracking against spending on labor, equipment, materials, and subcontracts.
7. **Safety:** Safety audits, inspection scores, and incident reports.

---

## 2. Data requirements

### 2.1 Entity sets

#### Strong entity sets
1. `DEPARTMENT`: Company departments (Civil Engineering, Heavy Fleet, Procurement, Safety, Finance).
2. `EMPLOYEE`: Full-time and field staff (engineers, managers, operators, inspectors).
3. `CLIENT`: Public agencies and private developers that hire the company.
4. `PROJECT`: Construction contracts with defined budgets and delivery schedules.
5. `PROJECT_SITE`: Physical work locations for a project.
6. `TASK`: Work packages within a project phase assigned to workers.
7. `EQUIPMENT`: Heavy machinery and vehicles.
8. `SUPPLIER`: Vendors supplying raw materials and parts.
9. `MATERIAL`: Standard catalog items (cement, rebar, gravel, pipes).
10. `PURCHASE_ORDER`: Purchase orders sent to suppliers.
11. `SUBCONTRACTOR`: Outside contractors hired for specialized trades.
12. `SAFETY_INSPECTION`: Periodic site safety audits.
13. `INCIDENT_REPORT`: Logs of workplace accidents, equipment damage, or near-misses.

#### Weak entity sets
1. `DEPENDENT`: Family members of an employee for benefits and emergency contact.
   - Identifying entity: `EMPLOYEE`
   - Identifying relationship: `HAS_DEPENDENT`
   - Partial key: `DependentName`
2. `PROJECT_PHASE`: Stages within a project (Foundation, Structure, Finishing).
   - Identifying entity: `PROJECT`
   - Identifying relationship: `CONSISTS_OF_PHASES`
   - Partial key: `PhaseNumber`
3. `PO_ITEM`: Individual line items on a purchase order.
   - Identifying entity: `PURCHASE_ORDER`
   - Identifying relationship: `CONTAINS_ITEM`
   - Partial key: `LineNumber`
4. `MAINTENANCE_RECORD`: Service and repair logs for a machine.
   - Identifying entity: `EQUIPMENT`
   - Identifying relationship: `HAS_MAINTENANCE`
   - Partial key: `RecordNumber`

---

### 2.2 Attributes

#### Strong entity sets

##### 1. `DEPARTMENT`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `DeptID` | Primary Key | Unique department code (e.g., D01) |
| `DeptName` | Simple | Department name |
| `OfficeLocation` | Simple | Office room or floor |
| `Budget` | Simple | Annual operating budget |

##### 2. `EMPLOYEE`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `EmpID` | Primary Key | Unique employee identifier |
| `Name` | Composite | Composed of `FirstName`, `MiddleName`, `LastName` |
| `Address` | Composite | Composed of `Street`, `Ward`, `District`, `City` |
| `DOB` | Simple | Date of birth |
| `Age` | Derived | Current date minus date of birth |
| `HireDate` | Simple | Employment start date |
| `Salary` | Simple | Monthly base salary |
| `JobTitle` | Simple | Job title (Site Engineer, Crane Operator) |
| `Email` | Candidate Key | Unique company email |
| `PhoneNumber` | Multi-valued | Contact phone numbers |
| `Certifications` | Multi-valued | Licenses and certificates (OSHA, Crane Class A) |

##### 3. `CLIENT`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `ClientID` | Primary Key | Unique client identifier |
| `ClientName` | Simple | Organization or company name |
| `ClientType` | Simple | Sector (Government, Commercial, Residential, Industrial) |
| `ContactPerson` | Simple | Primary contact person |
| `ContactEmail` | Simple | Email address |
| `ContactPhone` | Multi-valued | Contact phone numbers |
| `TaxCode` | Candidate Key | Business tax code |

##### 4. `PROJECT`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `ProjectID` | Primary Key | Project code (e.g., PRJ-2026-001) |
| `ProjectName` | Simple | Project name |
| `StartDate` | Simple | Planned start date |
| `PlannedEndDate` | Simple | Contractual deadline |
| `ActualEndDate` | Simple | Real completion date (null if ongoing) |
| `ProjectDuration` | Derived | Elapsed days from StartDate to ActualEndDate or today |
| `EstimatedBudget` | Simple | Contract budget limit |
| `ActualCost` | Derived | Total cost of labor, equipment, materials, and subcontracts |
| `Status` | Simple | Planned, In-Progress, Suspended, Completed |

##### 5. `PROJECT_SITE`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `SiteID` | Primary Key | Unique site identifier |
| `SiteName` | Simple | Site name or sector |
| `LocationCoordinates` | Composite | Composed of `Latitude`, `Longitude` |
| `Address` | Composite | Composed of `StreetAddress`, `District`, `City_Province` |
| `EnvironmentalPermit` | Simple | Environmental permit number |
| `SiteStatus` | Simple | Operating state (Preparation, Active, Handed_Over) |

##### 6. `TASK`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `TaskID` | Primary Key | Unique task identifier |
| `TaskName` | Simple | Task name (Pour pile B12) |
| `EstimatedHours` | Simple | Estimated work hours |
| `ActualHours` | Derived | Sum of worker hours logged on this task |
| `ScheduledStartDate` | Simple | Scheduled start date |
| `ScheduledEndDate` | Simple | Scheduled end date |
| `ActualEndDate` | Simple | Actual completion date (null if ongoing) |
| `PriorityLevel` | Simple | Low, Medium, High, Urgent |
| `TaskStatus` | Simple | Execution state (Pending, In_Progress, Completed, Blocked) |

##### 7. `EQUIPMENT`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `EquipmentID` | Primary Key | Unique asset code |
| `Model` | Simple | Make and model (CAT 320D) |
| `SerialNumber` | Candidate Key | Manufacturer serial number |
| `Category` | Simple | Excavator, Crane, Truck, Paver, Mixer |
| `Ownership` | Simple | Owned or Rented |
| `HourlyRate` | Simple | Cost per operating hour |
| `CurrentStatus` | Simple | Available, Deployed, Under-Maintenance, Retired |
| `TotalRunHours` | Derived | Total operating hours across all jobs |

##### 8. `SUPPLIER`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `SupplierID` | Primary Key | Unique vendor identifier |
| `CompanyName` | Simple | Registered company name |
| `TaxCode` | Candidate Key | Official business tax ID |
| `ContactEmail` | Simple | Sales email |
| `ContactPhone` | Multi-valued | Contact phone numbers |
| `SupplyCategories` | Multi-valued | Product lines (Steel, Cement, Lumber) |
| `CreditRating` | Simple | Rating grade (A, B, C) |

##### 9. `MATERIAL`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `MaterialID` | Primary Key | Unique material SKU |
| `MaterialName` | Simple | Material name (Portland Cement PCB40) |
| `Category` | Simple | Material classification (Steel, Cement, Aggregate, Piping, Electrical) |
| `StandardUnit` | Simple | Unit of measurement (Ton, m3, Bag, Piece) |
| `UnitPrice` | Simple | Reference price per unit |
| `MinStock` | Simple | Minimum safety stock count |

##### 10. `PURCHASE_ORDER`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `PO_ID` | Primary Key | Unique PO number |
| `OrderDate` | Simple | Date order was placed |
| `ExpectedDeliveryDate` | Simple | Promised arrival date |
| `DeliveryStatus` | Simple | Issued, Partial_Delivery, Fulfilled, Cancelled |
| `TotalPOAmount` | Derived | Sum of line subtotals |

##### 11. `SUBCONTRACTOR`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `SubcontractorID` | Primary Key | Unique subcontractor identifier |
| `CompanyName` | Simple | Registered company name |
| `TaxCode` | Candidate Key | Official business tax ID |
| `ContactEmail` | Simple | Official contact email |
| `ContactPhone` | Simple | Primary dispatch phone number |
| `TradeSpecialty` | Simple | Specialized trade (Piling, Electrical, HVAC, Facade) |
| `LicenseNumber` | Candidate Key | Trade license number |
| `SafetyRatingScore` | Simple | Safety score (0.0 to 10.0) |

##### 12. `SAFETY_INSPECTION`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `InspectionID` | Primary Key | Unique inspection log ID |
| `InspectionDate` | Simple | Date of inspection |
| `InspectionType` | Simple | Audit type (Routine, Unannounced, Pre-Operation) |
| `InspectionScope` | Simple | Inspected area or structure (e.g., Tower crane, Scaffold level 4) |
| `OverallScore` | Simple | Evaluation score (0 to 100) |
| `InspectionResult` | Simple | Audit conclusion (Passed, Conditional_Pass, Failed) |
| `ViolationNoted` | Simple | Safety issues found |
| `FixDeadline` | Simple | Deadline to fix issues (null if passed) |

##### 13. `INCIDENT_REPORT`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `IncidentID` | Primary Key | Unique incident case ID |
| `IncidentTimestamp` | Simple | Date and time of incident |
| `IncidentType` | Simple | Event category (Fall, Electrical, Equipment_Collision, Falling_Object) |
| `IncidentLevel` | Simple | Impact classification (Warning, Minor, Serious, Fatal) |
| `DamageDescription` | Simple | Injury or equipment damage details |
| `LostDays` | Simple | Work days lost due to injury |
| `Solution` | Simple | Immediate remedial or preventive action taken |

#### Weak entity sets

##### 1. `DEPENDENT`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `DependentName` | Partial Key | Full name of dependent |
| `Gender` | Simple | Gender (M, F, Other) |
| `BirthDate` | Simple | Date of birth |
| `Relationship` | Simple | Relationship to employee (Spouse, Child, Parent) |
| `ContactPhone` | Simple | Emergency contact phone number |
| `IsEmergencyContact` | Simple | Primary emergency contact flag (true or false) |

##### 2. `PROJECT_PHASE`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `PhaseNumber` | Partial Key | Phase sequence number (1, 2, 3...) |
| `PhaseTitle` | Simple | Phase title (Excavation, Structure) |
| `StartDate` | Simple | Scheduled start date for this phase |
| `TargetCompletionDate` | Simple | Target completion date for phase |
| `PhaseBudget` | Simple | Budget allocated to this phase |
| `PhaseStatus` | Simple | Pending, Active, Under-Inspection, Accepted |

##### 3. `PO_ITEM`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `LineNumber` | Partial Key | Line item number (1, 2, 3...) |
| `QuantityOrdered` | Simple | Quantity purchased |
| `AgreedUnitPrice` | Simple | Negotiated unit price |
| `ItemSubtotal` | Derived | QuantityOrdered multiplied by AgreedUnitPrice |

##### 4. `MAINTENANCE_RECORD`
| Attribute | Type | Description |
| :--- | :--- | :--- |
| `RecordNumber` | Partial Key | Service record counter |
| `ServiceDate` | Simple | Date of service |
| `MaintenanceType` | Simple | Service type (Oil Change, Inspection, Hydraulic Repair, Overhaul) |
| `Cost` | Simple | Repair and parts cost |
| `ServiceVendor` | Simple | Workshop name or external vendor |

---

## 3. Relationships and constraints

### 3.1 Relationships

#### 1. `DEPARTMENT_HEAD` (`EMPLOYEE` to `DEPARTMENT`)
- Binary 1:1
- Participation: `DEPARTMENT` is total (every department has one manager); `EMPLOYEE` is partial (only some employees are managers).
- Rule: An employee manages at most one department.

#### 2. `WORKS_IN_DEPARTMENT` (`DEPARTMENT` to `EMPLOYEE`)
- Binary 1:N
- Participation: `EMPLOYEE` is total (every employee must belong to one department); `DEPARTMENT` is total (every department has at least one employee).
- Rule: An employee belongs to exactly one department.

#### 3. `SUPERVISES` (`EMPLOYEE` to `EMPLOYEE`)
- Unary (recursive) 1:N
- Participation: Both roles are partial (not all employees supervise, and the top director has no supervisor).
- Rule: An employee has at most one direct supervisor.

#### 4. `HAS_DEPENDENT` (`EMPLOYEE` to `DEPENDENT`)
- Identifying 1:N
- Participation: `EMPLOYEE` is partial; `DEPENDENT` is total (a dependent must belong to an employee).

#### 5. `COMMISSIONS` (`CLIENT` to `PROJECT`)
- Binary 1:N
- Participation: `CLIENT` is partial; `PROJECT` is total (each project must have a client).

#### 6. `DEPARTMENT_SPONSORS_PROJECT` (`DEPARTMENT` to `PROJECT`)
- Binary 1:N
- Participation: `DEPARTMENT` is partial; `PROJECT` is total (each project is assigned to a managing department).

#### 7. `DIRECTS_PROJECT` (`EMPLOYEE` to `PROJECT`)
- Binary 1:1
- Participation: `PROJECT` is total (every project has one site director); `EMPLOYEE` is partial.
- Rule: An employee directs at most one active project at a time.

#### 8. `HAS_SITES` (`PROJECT` to `PROJECT_SITE`)
- Binary 1:N
- Participation: `PROJECT` is total (every project has at least one site); `PROJECT_SITE` is total.

#### 9. `CONSISTS_OF_PHASES` (`PROJECT` to `PROJECT_PHASE`)
- Identifying 1:N
- Participation: `PROJECT` is total; `PROJECT_PHASE` is total.

#### 10. `CONTAINS_TASKS` (`PROJECT_PHASE` to `TASK`)
- Binary 1:N
- Participation: `PROJECT_PHASE` is total; `TASK` is total.

#### 11. `PRECEDES` (`TASK` to `TASK`)
- Unary (recursive) M:N
- Participation: Both roles are partial.
- Rule: Defines task order on the project schedule (for example, Foundation must finish before Framing starts).

#### 12. `WORKS_ON_TASK` (`EMPLOYEE` to `TASK`)
- Binary M:N
- Attributes: `AssignedDate`, `RoleOnTask`, `HoursLogged`
- Participation: `EMPLOYEE` is partial; `TASK` is total (a task needs at least one assigned worker).

#### 13. `EQUIPMENT_DEPLOYMENT` (`EQUIPMENT` to `PROJECT_SITE`)
- Binary M:N
- Attributes: `DeploymentStartDate`, `DeploymentEndDate`, `HoursOperated`
- Participation: Both `EQUIPMENT` and `PROJECT_SITE` are partial.
- Aggregation: Each deployment is treated as a higher-level entity so it can take part in `OPERATES` (relationship 26), which records the operator.

#### 14. `HAS_MAINTENANCE` (`EQUIPMENT` to `MAINTENANCE_RECORD`)
- Identifying 1:N
- Participation: `EQUIPMENT` is partial; `MAINTENANCE_RECORD` is total.

#### 15. `ISSUES_PO` (`PROJECT` to `PURCHASE_ORDER`)
- Binary 1:N
- Participation: `PROJECT` is partial; `PURCHASE_ORDER` is total.

#### 16. `SUPPLIES_PO` (`SUPPLIER` to `PURCHASE_ORDER`)
- Binary 1:N
- Participation: `SUPPLIER` is partial; `PURCHASE_ORDER` is total.

#### 17. `CONTAINS_ITEM` (`PURCHASE_ORDER` to `PO_ITEM`)
- Identifying 1:N
- Participation: `PURCHASE_ORDER` is total; `PO_ITEM` is total.

#### 18. `ITEM_REFERENCES_MATERIAL` (`PO_ITEM` to `MATERIAL`)
- Binary N:1
- Participation: `PO_ITEM` is total; `MATERIAL` is partial.

#### 19. `SITE_INVENTORY` (`PROJECT_SITE` to `MATERIAL`)
- Binary M:N
- Attributes: `CurrentStockQuantity`, `SafetyReorderQuantity`, `LastStocktakeDate`
- Participation: Both are partial.

#### 20. `DELIVERY_DISPATCH` (`SUPPLIER` x `MATERIAL` x `PROJECT_SITE`)
- Ternary relationship (M:N:P)
- Attributes: `DeliveryCode`, `DeliveryDate`, `DeliveredQuantity`
- Meaning: A supplier delivers a specific material to a project site against an approved purchase order on a given date.
- Aggregation: Each delivery is treated as a higher-level entity so it can take part in `RECEIVES_DELIVERY` (relationship 27) and `FULFILLS_PO` (relationship 28), which record the receiving employee and the purchase order.

#### 21. `ENGAGES_SUBCONTRACTOR` (`PROJECT` to `SUBCONTRACTOR`)
- Binary M:N
- Attributes: `ContractAgreementNo`, `ScopeDescription`, `ContractValue`, `WarrantyHoldRate`, `StartDate`, `CompletionDate`
- Participation: Both are partial.

#### 22. `HAS_INSPECTION` (`PROJECT_SITE` to `SAFETY_INSPECTION`)
- Binary 1:N
- Participation: `SAFETY_INSPECTION` is total (each inspection is carried out at exactly one site); `PROJECT_SITE` is partial.

#### 23. `LOGS_INCIDENT` (`PROJECT_SITE` to `INCIDENT_REPORT`)
- Binary 1:N
- Participation: `PROJECT_SITE` is partial; `INCIDENT_REPORT` is total (each incident happens at a site).

#### 24. `INVOLVES_EMPLOYEE` (`EMPLOYEE` to `INCIDENT_REPORT`)
- Binary 1:N
- Participation: `EMPLOYEE` is partial; `INCIDENT_REPORT` is partial (an incident may involve an injured worker, or may solely involve property/equipment damage).
- Rule: An incident report references at most one primary affected employee.

#### 25. `MATERIAL_USAGE` (`TASK` x `MATERIAL` x `PROJECT_SITE`)
- Ternary relationship (N:M:P)
- Attributes: `QuantityUsed`, `UsageDate`
- Meaning: A task consumes a quantity of a material taken from the stock of a specific project site on a given date. The site is part of the relationship because stock is tracked per site (`SITE_INVENTORY`).

#### 26. `OPERATES` (`EMPLOYEE` to `EQUIPMENT_DEPLOYMENT`)
- Binary 1:N between `EMPLOYEE` and the aggregation of `EQUIPMENT_DEPLOYMENT`
- Participation: Both sides are partial.
- Rule: A deployment has at most one operator; an employee may operate many deployments over time. Replaces the former `OperatorID` attribute.

#### 27. `RECEIVES_DELIVERY` (`EMPLOYEE` to `DELIVERY_DISPATCH`)
- Binary 1:N between `EMPLOYEE` and the aggregation of `DELIVERY_DISPATCH`
- Participation: `DELIVERY_DISPATCH` is total (every delivery is received by one employee); `EMPLOYEE` is partial.
- Replaces the former `ReceiverEmployeeID` attribute.

#### 28. `FULFILLS_PO` (`PURCHASE_ORDER` to `DELIVERY_DISPATCH`)
- Binary 1:N between `PURCHASE_ORDER` and the aggregation of `DELIVERY_DISPATCH`
- Participation: `DELIVERY_DISPATCH` is total (every delivery is made against one purchase order); `PURCHASE_ORDER` is partial.
- Replaces the former `PO_ID` attribute.

#### 29. `DAMAGES_EQUIPMENT` (`EQUIPMENT` to `INCIDENT_REPORT`)
- Binary 1:N
- Participation: Both sides are partial (an incident may involve no equipment, and most equipment never appears in an incident).
- Rule: An incident report references at most one primary damaged machine.

#### 30. `PERFORMS_INSPECTION` (`EMPLOYEE` to `SAFETY_INSPECTION`)
- Binary 1:N
- Participation: `SAFETY_INSPECTION` is total (each inspection records its inspector); `EMPLOYEE` is partial.

---

## 4. Business rules

### 4.1 Domain constraints
- Amounts must be positive (> 0): `Salary`, `Budget`, `PhaseBudget`, `ContractValue`, `UnitPrice`, `AgreedUnitPrice`, `Cost`, `HourlyRate`.
- Quantities and hours must be non-negative (>= 0): `QuantityOrdered`, `DeliveredQuantity`, `CurrentStockQuantity`, `QuantityUsed`, `MinStock`, `EstimatedHours`, `ActualHours`, `HoursLogged`, `HoursOperated`, `LostDays`.
- Status and classification fields use fixed values:
  - `PROJECT.Status`: Planned, In-Progress, Suspended, Completed
  - `PROJECT_SITE.SiteStatus`: Preparation, Active, Handed_Over
  - `PROJECT_PHASE.PhaseStatus`: Pending, Active, Under-Inspection, Accepted
  - `TASK.PriorityLevel`: Low, Medium, High, Urgent
  - `TASK.TaskStatus`: Pending, In_Progress, Completed, Blocked
  - `EQUIPMENT.Ownership`: Owned, Rented
  - `EQUIPMENT.CurrentStatus`: Available, Deployed, Under-Maintenance, Retired
  - `PURCHASE_ORDER.DeliveryStatus`: Issued, Partial_Delivery, Fulfilled, Cancelled
  - `SAFETY_INSPECTION.InspectionResult`: Passed, Conditional_Pass, Failed
  - `INCIDENT_REPORT.IncidentLevel`: Warning, Minor, Serious, Fatal
  - `INCIDENT_REPORT.IncidentType`: Fall, Electrical, Equipment_Collision, Falling_Object

### 4.2 Date and time rules
- End dates cannot be earlier than start dates (`StartDate <= PlannedEndDate`, `StartDate <= ActualEndDate`).
- Workers must be at least 18 years old (`CurrentDate - DOB >= 18` and `HireDate >= DOB + 18`).
- Task start and end dates must fall within the dates of the parent project phase.

### 4.3 Rules not modeled in ERD
These rules cannot be shown with ER notation and will be enforced through triggers, check constraints, or application logic:
1. **Phase budget limit:** The sum of all phase budgets in a project cannot exceed the project's estimated budget.
2. **No overlapping machine bookings:** A piece of equipment cannot be scheduled at two different sites during overlapping dates.
3. **Operator licensing:** An employee assigned to run heavy equipment must have the required license listed in their certifications (checked on the `OPERATES` relationship).
4. **Daily work limit:** A worker cannot log more than 12 hours total across all tasks in a single day.
5. **No circular task dependencies:** The `PRECEDES` relationship between tasks must not create cycles.
6. **Stock limit on consumption:** Tasks cannot consume more material than the current stock recorded at that site (checked on the `MATERIAL_USAGE` relationship against `SITE_INVENTORY`).
7. **Single project limit for directors:** An employee can be the director of only one active project at a time.
8. **Accident emergency notification:** When an incident involves an employee, the system must trigger a notification looking up their emergency contact in `DEPENDENT` where `IsEmergencyContact = true`.
9. **Delivery consistency:** The supplier and material of a `DELIVERY_DISPATCH` must match the supplier of the referenced purchase order and a material listed in one of its `PO_ITEM` lines (checked on the `FULFILLS_PO` relationship).
10. **Department head bootstrap:** `DEPARTMENT_HEAD` is total on the department side while `WORKS_IN_DEPARTMENT` is total on the employee side. When loading data, insert the department with its head empty (or use a deferred constraint), insert the employee, then assign the head.

---

## 5. Database applications

### 5.1 Data loading
- Import the standard material catalog with units and benchmark prices.
- Add new employees, job titles, and verified licenses.
- Set up new project contracts, site locations, and milestone schedules.
- Register newly purchased or rented machinery with serial numbers.

### 5.2 Updates
- Log daily worker hours on specific tasks.
- Record material deliveries arriving at a site and update on-site inventory counts.
- Deduct materials used during daily work from site inventory.
- Update equipment operating hours and switch status to maintenance when service intervals arrive.
- Mark project phases as completed after inspection sign-off.
- Log site safety audit scores and incident reports.

### 5.3 Queries
- Find heavy equipment by category that is available and not booked for the next two weeks.
- Check which materials at a specific site have dropped below their minimum safety stock (`MinStock`).
- List urgent tasks that are past their scheduled end date.
- Look up the reporting chain of an employee up to the general director.
- View active subcontractors on a project with their contracted amounts and remaining warranty hold balances (`WarrantyHoldRate`).

### 5.4 Reports
- **Cost vs. budget variance:** Compares the initial project budget against total spending on labor, equipment, materials, and subcontracts.
- **Earned value analysis:** Computes Planned Value (PV), Earned Value (EV), Actual Cost (AC), Cost Performance Index (CPI), and Schedule Performance Index (SPI).
- **Site safety report:** Summarizes audit scores, open safety issues, lost work days (`LostDays`), and total injury-free hours per site.
- **Subcontractor scorecard:** Ranks subcontractors by delivery speed, work quality, and safety compliance.
- **Fleet utilization report:** Shows machine run hours (`TotalRunHours`) against idle hours and hourly rate costs (`HourlyRate`).

---

## 6. ERD description

The conceptual design is drawn in Chen notation with cardinality ratios and is stored in `erd.drawio` (seven pages).

### 6.1 Diagram pages

| Page | Content |
| :--- | :--- |
| Overview | All 17 entity sets and 30 relationship sets, no attributes, colour-coded by module |
| Organization | `DEPARTMENT`, `EMPLOYEE`, `DEPENDENT` |
| Projects | `CLIENT`, `PROJECT`, `PROJECT_SITE`, `PROJECT_PHASE`, `TASK` |
| Equipment | `EQUIPMENT`, `MAINTENANCE_RECORD`, aggregation of `EQUIPMENT_DEPLOYMENT` |
| Materials & Procurement | `SUPPLIER`, `MATERIAL`, `PURCHASE_ORDER`, `PO_ITEM`, aggregation of `DELIVERY_DISPATCH` |
| Subcontracting | `SUBCONTRACTOR` |
| Safety | `SAFETY_INSPECTION`, `INCIDENT_REPORT` |

Project costs have no entity of their own: `ActualCost` is a derived attribute of `PROJECT` (page Projects).

### 6.2 Notation

| Concept | Symbol |
| :--- | :--- |
| Strong / weak entity | Rectangle / double rectangle |
| Relationship / identifying relationship | Diamond / double diamond |
| Primary key / partial key | Solid underline / dashed underline |
| Candidate key | Oval with suffix `[CK]` |
| Multi-valued attribute | Double oval |
| Derived attribute | Dashed oval |
| Composite attribute | Oval linked to child ovals |
| Total / partial participation | Double line / single line |
| Cardinality | Labels `1`, `N`, `M`, `P` next to the relationship diamond |
| Recursive relationship | Two lines to the same entity with role labels |
| Aggregation | Dashed box around a relationship set (on the Equipment and Materials & Procurement pages also its participating entities); other relationships attach to the box |
| Relationship attribute | Oval attached to the diamond |

### 6.3 Entities repeated on other pages

An entity shown outside its owning page is drawn as a normal rectangle with only its key attribute and a `(see <page name>)` note.

| Entity | Defined on | Repeated on |
| :--- | :--- | :--- |
| `EMPLOYEE` | Organization | Projects, Equipment, Materials & Procurement, Safety |
| `DEPARTMENT` | Organization | Projects |
| `PROJECT` | Projects | Materials & Procurement, Subcontracting |
| `PROJECT_SITE` | Projects | Equipment, Materials & Procurement, Safety |
| `TASK` | Projects | Materials & Procurement |
| `EQUIPMENT` | Equipment | Safety |

### 6.4 Constraints not shown in the ERD

See §4.3 (rules 1 to 10).
