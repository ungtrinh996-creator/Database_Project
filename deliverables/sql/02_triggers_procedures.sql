-- =============================================================================
-- DATABASE DESIGN TERM PROJECT (PHASE 3) - E24-Class 5, Group 5
-- Topic: Multi-Project Construction Enterprise Database System (A34Build)
-- Target DBMS: MySQL 8.0+ (Storage Engine: InnoDB, Charset: utf8mb4)
-- File 02: Triggers, Stored Procedures & Business Rule Enforcement
-- =============================================================================

USE A34Build_DB;

-- Support table for Rule 8: Emergency Notification Audit Log
CREATE TABLE IF NOT EXISTS EMERGENCY_DISPATCH_LOG (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    IncidentID VARCHAR(20) NOT NULL,
    InvolvedEmpID VARCHAR(10) NOT NULL,
    EmergencyContactName VARCHAR(100) NOT NULL,
    Relationship VARCHAR(50) NOT NULL,
    ContactPhone VARCHAR(20) NOT NULL,
    DispatchedAt DATETIME NOT NULL,
    MessageSubject VARCHAR(255) NOT NULL,
    MessageBody TEXT NOT NULL,
    NotificationStatus ENUM('Queued', 'Sent', 'Failed') NOT NULL DEFAULT 'Sent',
    CONSTRAINT FK_DISPATCH_Incident FOREIGN KEY (IncidentID) 
        REFERENCES INCIDENT_REPORT (IncidentID) ON DELETE CASCADE,
    CONSTRAINT FK_DISPATCH_Emp FOREIGN KEY (InvolvedEmpID) 
        REFERENCES EMPLOYEE (EmpID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELIMITER //

-- =============================================================================
-- BUSINESS RULE 1: Phase Budget Accumulation Constraint
-- Sum of all Phase budgets within a project must NOT exceed EstimatedBudget.
-- =============================================================================
DROP TRIGGER IF EXISTS TRG_CHECK_PHASE_BUDGET_INSERT //
CREATE TRIGGER TRG_CHECK_PHASE_BUDGET_INSERT
BEFORE INSERT ON PROJECT_PHASE
FOR EACH ROW
BEGIN
    DECLARE v_project_budget DECIMAL(15,2);
    DECLARE v_current_phases_total DECIMAL(15,2);

    SELECT EstimatedBudget INTO v_project_budget
    FROM PROJECT
    WHERE ProjectID = NEW.ProjectID;

    SELECT COALESCE(SUM(PhaseBudget), 0.00) INTO v_current_phases_total
    FROM PROJECT_PHASE
    WHERE ProjectID = NEW.ProjectID;

    IF (v_current_phases_total + NEW.PhaseBudget) > v_project_budget THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 1 Violation: Total PhaseBudget cannot exceed Project EstimatedBudget.';
    END IF;
END //

DROP TRIGGER IF EXISTS TRG_CHECK_PHASE_BUDGET_UPDATE //
CREATE TRIGGER TRG_CHECK_PHASE_BUDGET_UPDATE
BEFORE UPDATE ON PROJECT_PHASE
FOR EACH ROW
BEGIN
    DECLARE v_project_budget DECIMAL(15,2);
    DECLARE v_other_phases_total DECIMAL(15,2);

    SELECT EstimatedBudget INTO v_project_budget
    FROM PROJECT
    WHERE ProjectID = NEW.ProjectID;

    SELECT COALESCE(SUM(PhaseBudget), 0.00) INTO v_other_phases_total
    FROM PROJECT_PHASE
    WHERE ProjectID = NEW.ProjectID
      AND PhaseNumber <> OLD.PhaseNumber;

    IF (v_other_phases_total + NEW.PhaseBudget) > v_project_budget THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 1 Violation: Total PhaseBudget cannot exceed Project EstimatedBudget.';
    END IF;
END //

-- =============================================================================
-- BUSINESS RULE 2: Machinery Schedule Non-Overlapping Constraint
-- A piece of equipment cannot have overlapping deployment dates across sites.
-- =============================================================================
DROP TRIGGER IF EXISTS TRG_CHECK_EQUIPMENT_OVERLAP_INSERT //
CREATE TRIGGER TRG_CHECK_EQUIPMENT_OVERLAP_INSERT
BEFORE INSERT ON EQUIPMENT_DEPLOYMENT
FOR EACH ROW
BEGIN
    DECLARE v_overlap_count INT;

    SELECT COUNT(*) INTO v_overlap_count
    FROM EQUIPMENT_DEPLOYMENT
    WHERE EquipmentID = NEW.EquipmentID
      AND (NEW.DeploymentStartDate <= DeploymentEndDate)
      AND (NEW.DeploymentEndDate >= DeploymentStartDate);

    IF v_overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 2 Violation: Equipment deployment interval overlaps with an existing deployment.';
    END IF;
END //

DROP TRIGGER IF EXISTS TRG_CHECK_EQUIPMENT_OVERLAP_UPDATE //
CREATE TRIGGER TRG_CHECK_EQUIPMENT_OVERLAP_UPDATE
BEFORE UPDATE ON EQUIPMENT_DEPLOYMENT
FOR EACH ROW
BEGIN
    DECLARE v_overlap_count INT;

    SELECT COUNT(*) INTO v_overlap_count
    FROM EQUIPMENT_DEPLOYMENT
    WHERE EquipmentID = NEW.EquipmentID
      AND DeploymentStartDate <> OLD.DeploymentStartDate
      AND (NEW.DeploymentStartDate <= DeploymentEndDate)
      AND (NEW.DeploymentEndDate >= DeploymentStartDate);

    IF v_overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 2 Violation: Equipment deployment interval overlaps with an existing deployment.';
    END IF;
END //

-- =============================================================================
-- BUSINESS RULE 3: Equipment Operator Certification Rule
-- Operator assigned to heavy equipment must hold appropriate certification.
-- =============================================================================
DROP TRIGGER IF EXISTS TRG_CHECK_OPERATOR_CERT_INSERT //
CREATE TRIGGER TRG_CHECK_OPERATOR_CERT_INSERT
BEFORE INSERT ON EQUIPMENT_DEPLOYMENT
FOR EACH ROW
BEGIN
    DECLARE v_cert_count INT;
    DECLARE v_equip_category VARCHAR(100);

    SELECT Category INTO v_equip_category
    FROM EQUIPMENT
    WHERE EquipmentID = NEW.EquipmentID;

    SELECT COUNT(*) INTO v_cert_count
    FROM EMPLOYEE_CERTIFICATION
    WHERE EmpID = NEW.OperatorEmpID
      AND (Certification LIKE CONCAT('%', v_equip_category, '%') 
           OR Certification LIKE '%Heavy Equipment%' 
           OR Certification LIKE '%Master Operator%');

    IF v_cert_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 3 Violation: Assigned operator lacks valid certification for this equipment category.';
    END IF;
END //

DROP TRIGGER IF EXISTS TRG_CHECK_OPERATOR_CERT_UPDATE //
CREATE TRIGGER TRG_CHECK_OPERATOR_CERT_UPDATE
BEFORE UPDATE ON EQUIPMENT_DEPLOYMENT
FOR EACH ROW
BEGIN
    DECLARE v_cert_count INT;
    DECLARE v_equip_category VARCHAR(100);

    SELECT Category INTO v_equip_category
    FROM EQUIPMENT
    WHERE EquipmentID = NEW.EquipmentID;

    SELECT COUNT(*) INTO v_cert_count
    FROM EMPLOYEE_CERTIFICATION
    WHERE EmpID = NEW.OperatorEmpID
      AND (Certification LIKE CONCAT('%', v_equip_category, '%') 
           OR Certification LIKE '%Heavy Equipment%' 
           OR Certification LIKE '%Master Operator%');

    IF v_cert_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 3 Violation: Assigned operator lacks valid certification for this equipment category.';
    END IF;
END //

-- =============================================================================
-- BUSINESS RULE 4: Maximum Daily Working Hour Limit (<= 12 Hours per Calendar Day)
-- =============================================================================
DROP TRIGGER IF EXISTS TRG_CHECK_DAILY_HOURS_INSERT //
CREATE TRIGGER TRG_CHECK_DAILY_HOURS_INSERT
BEFORE INSERT ON WORKS_ON_TASK
FOR EACH ROW
BEGIN
    DECLARE v_daily_total DECIMAL(5,2);

    SELECT COALESCE(SUM(HoursLogged), 0.00) INTO v_daily_total
    FROM WORKS_ON_TASK
    WHERE EmpID = NEW.EmpID
      AND AssignedDate = NEW.AssignedDate;

    IF (v_daily_total + NEW.HoursLogged) > 12.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 4 Violation: Worker logged hours exceed statutory limit of 12 hours per calendar day.';
    END IF;
END //

DROP TRIGGER IF EXISTS TRG_CHECK_DAILY_HOURS_UPDATE //
CREATE TRIGGER TRG_CHECK_DAILY_HOURS_UPDATE
BEFORE UPDATE ON WORKS_ON_TASK
FOR EACH ROW
BEGIN
    DECLARE v_other_hours DECIMAL(5,2);

    SELECT COALESCE(SUM(HoursLogged), 0.00) INTO v_other_hours
    FROM WORKS_ON_TASK
    WHERE EmpID = NEW.EmpID
      AND AssignedDate = NEW.AssignedDate
      AND TaskID <> OLD.TaskID;

    IF (v_other_hours + NEW.HoursLogged) > 12.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 4 Violation: Worker logged hours exceed statutory limit of 12 hours per calendar day.';
    END IF;
END //

-- =============================================================================
-- BUSINESS RULE 5: Acyclic Dependency Constraint (DAG on PRECEDES)
-- Prevents circular dependency loops (e.g., T1 -> T2 -> T3 -> T1).
-- =============================================================================
DROP TRIGGER IF EXISTS TRG_CHECK_PRECEDES_DAG //
CREATE TRIGGER TRG_CHECK_PRECEDES_DAG
BEFORE INSERT ON PRECEDES
FOR EACH ROW
BEGIN
    DECLARE v_cycle_detected INT DEFAULT 0;

    -- Self-loop check is already partially enforced, but verify
    IF NEW.PredecessorTaskID = NEW.SuccessorTaskID THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 5 Violation: Self-loop precedence is strictly prohibited.';
    END IF;

    -- Check if a path already exists from SuccessorTaskID to PredecessorTaskID
    -- Using CTE recursion in MySQL 8.0+
    WITH RECURSIVE PrecedenceChain AS (
        SELECT SuccessorTaskID AS CurrentTask
        FROM PRECEDES
        WHERE PredecessorTaskID = NEW.SuccessorTaskID
        
        UNION ALL
        
        SELECT p.SuccessorTaskID
        FROM PRECEDES p
        INNER JOIN PrecedenceChain pc ON p.PredecessorTaskID = pc.CurrentTask
    )
    SELECT COUNT(*) INTO v_cycle_detected
    FROM PrecedenceChain
    WHERE CurrentTask = NEW.PredecessorTaskID;

    IF v_cycle_detected > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 5 Violation: Circular dependency detected in task precedence (Violates DAG).';
    END IF;
END //

-- =============================================================================
-- BUSINESS RULE 6: Material Stock Overdraft Prevention & Inventory Auto-Deduction
-- =============================================================================
DROP TRIGGER IF EXISTS TRG_CHECK_MATERIAL_STOCK_INSERT //
CREATE TRIGGER TRG_CHECK_MATERIAL_STOCK_INSERT
BEFORE INSERT ON MATERIAL_USAGE
FOR EACH ROW
BEGIN
    DECLARE v_available_stock DECIMAL(12,2);

    SELECT CurrentStockQuantity INTO v_available_stock
    FROM SITE_INVENTORY
    WHERE SiteID = NEW.SiteID
      AND MaterialID = NEW.MaterialID;

    IF v_available_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 6 Violation: Material is not registered in site inventory.';
    ELSEIF v_available_stock < NEW.UsedQuantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rule 6 Violation: Material usage quantity exceeds current on-site stock quantity.';
    END IF;
END //

DROP TRIGGER IF EXISTS TRG_DEDUCT_MATERIAL_STOCK_AFTER_INSERT //
CREATE TRIGGER TRG_DEDUCT_MATERIAL_STOCK_AFTER_INSERT
AFTER INSERT ON MATERIAL_USAGE
FOR EACH ROW
BEGIN
    UPDATE SITE_INVENTORY
    SET CurrentStockQuantity = CurrentStockQuantity - NEW.UsedQuantity
    WHERE SiteID = NEW.SiteID
      AND MaterialID = NEW.MaterialID;
END //

-- Auto-replenish stock when delivery dispatch arrives
DROP TRIGGER IF EXISTS TRG_ADD_STOCK_ON_DELIVERY //
CREATE TRIGGER TRG_ADD_STOCK_ON_DELIVERY
AFTER INSERT ON DELIVERY_DISPATCH
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Received' THEN
        -- Insert or Update inventory record
        INSERT INTO SITE_INVENTORY (SiteID, MaterialID, CurrentStockQuantity, MinStock, ReorderQuantity)
        VALUES (NEW.SiteID, NEW.MaterialID, NEW.DeliveredQuantity, 50.00, 200.00)
        ON DUPLICATE KEY UPDATE CurrentStockQuantity = CurrentStockQuantity + NEW.DeliveredQuantity;
    END IF;
END //

-- =============================================================================
-- BUSINESS RULE 7: Single Active Project Limit for Site Directors
-- An employee can direct at most one project with Status = 'Active'.
-- =============================================================================
DROP TRIGGER IF EXISTS TRG_CHECK_DIRECTOR_ACTIVE_PROJECT_INSERT //
CREATE TRIGGER TRG_CHECK_DIRECTOR_ACTIVE_PROJECT_INSERT
BEFORE INSERT ON PROJECT
FOR EACH ROW
BEGIN
    DECLARE v_active_projects INT;

    IF NEW.Status = 'Active' THEN
        SELECT COUNT(*) INTO v_active_projects
        FROM PROJECT
        WHERE DirectorEmpID = NEW.DirectorEmpID
          AND Status = 'Active';

        IF v_active_projects > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Rule 7 Violation: Site director is already managing an active project.';
        END IF;
    END IF;
END //

DROP TRIGGER IF EXISTS TRG_CHECK_DIRECTOR_ACTIVE_PROJECT_UPDATE //
CREATE TRIGGER TRG_CHECK_DIRECTOR_ACTIVE_PROJECT_UPDATE
BEFORE UPDATE ON PROJECT
FOR EACH ROW
BEGIN
    DECLARE v_active_projects INT;

    IF NEW.Status = 'Active' THEN
        SELECT COUNT(*) INTO v_active_projects
        FROM PROJECT
        WHERE DirectorEmpID = NEW.DirectorEmpID
          AND Status = 'Active'
          AND ProjectID <> OLD.ProjectID;

        IF v_active_projects > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Rule 7 Violation: Site director is already managing an active project.';
        END IF;
    END IF;
END //

-- =============================================================================
-- BUSINESS RULE 8: Automated Emergency Contact Notification on Incident
-- Finds dependent where IsEmergencyContact = TRUE and dispatches an alert.
-- =============================================================================
DROP TRIGGER IF EXISTS TRG_DISPATCH_EMERGENCY_ALERT //
CREATE TRIGGER TRG_DISPATCH_EMERGENCY_ALERT
AFTER INSERT ON INCIDENT_REPORT
FOR EACH ROW
BEGIN
    DECLARE v_contact_name VARCHAR(100);
    DECLARE v_relationship VARCHAR(50);
    DECLARE v_contact_phone VARCHAR(20);
    DECLARE v_emp_name VARCHAR(150);

    IF NEW.InvolvedEmpID IS NOT NULL AND NEW.IncidentLevel IN ('Level-2', 'Level-3', 'Level-4') THEN
        -- Get Employee Name
        SELECT CONCAT(FirstName, ' ', LastName) INTO v_emp_name
        FROM EMPLOYEE
        WHERE EmpID = NEW.InvolvedEmpID;

        -- Find Emergency Dependent
        SELECT d.DependentName, d.Relationship, COALESCE(ep.PhoneNumber, 'No Phone on Record')
        INTO v_contact_name, v_relationship, v_contact_phone
        FROM DEPENDENT d
        LEFT JOIN EMPLOYEE_PHONE ep ON ep.EmpID = d.EmpID
        WHERE d.EmpID = NEW.InvolvedEmpID
          AND d.IsEmergencyContact = TRUE
        LIMIT 1;

        -- If found, record into emergency dispatch log
        IF v_contact_name IS NOT NULL THEN
            INSERT INTO EMERGENCY_DISPATCH_LOG (
                IncidentID,
                InvolvedEmpID,
                EmergencyContactName,
                Relationship,
                ContactPhone,
                DispatchedAt,
                MessageSubject,
                MessageBody,
                NotificationStatus
            )
            VALUES (
                NEW.IncidentID,
                NEW.InvolvedEmpID,
                v_contact_name,
                v_relationship,
                v_contact_phone,
                NOW(),
                CONCAT('[URGENT] Safety Incident Notification for ', v_emp_name),
                CONCAT('Alert: Employee ', v_emp_name, ' was involved in incident ', NEW.IncidentID,
                       ' (Level: ', NEW.IncidentLevel, ', Type: ', NEW.IncidentType, ') at Site ', NEW.SiteID,
                       '. Description: ', NEW.DamageDescription),
                'Sent'
            );
        END IF;
    END IF;
END //

DELIMITER ;
