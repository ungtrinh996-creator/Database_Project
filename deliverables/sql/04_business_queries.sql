-- =============================================================================
-- DATABASE DESIGN TERM PROJECT (PHASE 3) - E24-Class 5, Group 5
-- Topic: Multi-Project Construction Enterprise Database System (A34Build)
-- Target DBMS: MySQL 8.0+ (Storage Engine: InnoDB, Charset: utf8mb4)
-- File 04: Business Applications, Analytical Queries & Management Reports
-- =============================================================================

USE A34Build_DB;

-- =============================================================================
-- PART 1: OPERATIONAL & COMPLIANCE QUERIES (SECTION 5.3)
-- =============================================================================

-- Query 1.1: Heavy Equipment Availability Checker
-- Find machinery by category that is currently 'Available' or not deployed in the next 14 days.
SELECT 
    e.EquipmentID,
    e.EquipmentName,
    e.Category,
    e.Capacity,
    e.HourlyRate,
    e.Status AS CurrentStatus,
    COALESCE(MAX(ed.DeploymentEndDate), 'Never Deployed') AS LastDeploymentEndDate
FROM EQUIPMENT e
LEFT JOIN EQUIPMENT_DEPLOYMENT ed ON e.EquipmentID = ed.EquipmentID
WHERE e.Status NOT IN ('Decommissioned', 'Under-Maintenance')
  AND e.EquipmentID NOT IN (
      SELECT EquipmentID
      FROM EQUIPMENT_DEPLOYMENT
      WHERE DeploymentEndDate >= CURDATE()
        AND DeploymentStartDate <= DATE_ADD(CURDATE(), INTERVAL 14 DAY)
  )
GROUP BY e.EquipmentID, e.EquipmentName, e.Category, e.Capacity, e.HourlyRate, e.Status
ORDER BY e.HourlyRate DESC;

-- Query 1.2: Site Inventory Safety Stock Deficit Alert
-- Check materials whose current stock on site is below or near the minimum safety stock.
SELECT 
    ps.SiteID,
    ps.SiteName,
    p.ProjectName,
    m.MaterialID,
    m.MaterialName,
    m.Unit,
    si.CurrentStockQuantity,
    si.MinStock,
    si.ReorderQuantity,
    (si.MinStock - si.CurrentStockQuantity) AS DeficitQuantity,
    ROUND((si.CurrentStockQuantity / NULLIF(si.MinStock, 0)) * 100, 2) AS StockSufficiencyRatioPct,
    CASE 
        WHEN si.CurrentStockQuantity <= (si.MinStock * 0.5) THEN 'CRITICAL: Stockout Imminent'
        WHEN si.CurrentStockQuantity <= si.MinStock THEN 'WARNING: Below Min Safety Stock'
        ELSE 'NORMAL: Adequate'
    END AS ReplenishmentStatus
FROM SITE_INVENTORY si
JOIN PROJECT_SITE ps ON si.SiteID = ps.SiteID
JOIN PROJECT p ON ps.ProjectID = p.ProjectID
JOIN MATERIAL m ON si.MaterialID = m.MaterialID
WHERE si.CurrentStockQuantity <= (si.MinStock * 1.5)
ORDER BY StockSufficiencyRatioPct ASC;

-- Query 1.3: Recursive Reporting Hierarchy (CTEs)
-- Look up the complete management reporting chain of an employee up to the General Director.
WITH RECURSIVE EmployeeHierarchy AS (
    -- Anchor member: Target employee (e.g., EMP010 - Crane Operator)
    SELECT 
        EmpID,
        FirstName,
        LastName,
        JobTitle,
        SupervisorID,
        1 AS HierarchyLevel,
        CAST(CONCAT(FirstName, ' ', LastName) AS CHAR(500)) AS ManagementPath
    FROM EMPLOYEE
    WHERE EmpID = 'EMP010'

    UNION ALL

    -- Recursive member: Traverse up to the supervisor
    SELECT 
        m.EmpID,
        m.FirstName,
        m.LastName,
        m.JobTitle,
        m.SupervisorID,
        eh.HierarchyLevel + 1,
        CONCAT(eh.ManagementPath, ' -> ', m.FirstName, ' ', m.LastName)
    FROM EMPLOYEE m
    INNER JOIN EmployeeHierarchy eh ON eh.SupervisorID = m.EmpID
)
SELECT 
    HierarchyLevel,
    EmpID,
    CONCAT(FirstName, ' ', LastName) AS EmployeeName,
    JobTitle,
    SupervisorID,
    ManagementPath
FROM EmployeeHierarchy
ORDER BY HierarchyLevel ASC;

-- Query 1.4: Active Subcontractors & Retained Warranty Balances
-- Calculate financial commitments and warranty retention hold amounts per subcontractor.
SELECT 
    s.SubcontractorID,
    s.SubcontractorName,
    s.Specialization,
    sc.ContractAgreementNo,
    p.ProjectName,
    sc.ContractValue,
    sc.WarrantyHoldRate,
    ROUND((sc.ContractValue * sc.WarrantyHoldRate / 100.0), 2) AS WarrantyRetainedAmount,
    ROUND(sc.ContractValue - (sc.ContractValue * sc.WarrantyHoldRate / 100.0), 2) AS NetPayableAmount,
    sc.StartDate,
    sc.EndDate,
    DATEDIFF(sc.EndDate, CURDATE()) AS DaysRemaining
FROM SUBCONTRACT sc
JOIN SUBCONTRACTOR s ON sc.SubcontractorID = s.SubcontractorID
JOIN PROJECT p ON sc.ProjectID = p.ProjectID
WHERE sc.EndDate >= CURDATE()
ORDER BY sc.ContractValue DESC;

-- =============================================================================
-- PART 2: STRATEGIC EXECUTIVE & MANAGEMENT REPORTS (SECTION 5.4)
-- =============================================================================

-- Report 2.1: Multi-Dimensional Project Cost vs. Budget Variance Report
-- Aggregates budget breakdown and compares with actual costs (Labor, Machinery, Materials, Subcontracts).
WITH LaborCost AS (
    SELECT 
        t.ProjectID,
        COALESCE(SUM(w.HoursLogged * (e.Salary / 160.0)), 0) AS TotalLaborCost
    FROM TASK t
    JOIN WORKS_ON_TASK w ON t.TaskID = w.TaskID
    JOIN EMPLOYEE e ON w.EmpID = e.EmpID
    GROUP BY t.ProjectID
),
EquipmentCost AS (
    SELECT 
        ps.ProjectID,
        COALESCE(SUM(ed.OperatingHours * eq.HourlyRate), 0) AS TotalEquipmentCost
    FROM PROJECT_SITE ps
    JOIN EQUIPMENT_DEPLOYMENT ed ON ps.SiteID = ed.SiteID
    JOIN EQUIPMENT eq ON ed.EquipmentID = eq.EquipmentID
    GROUP BY ps.ProjectID
),
MaterialCost AS (
    SELECT 
        t.ProjectID,
        COALESCE(SUM(mu.UsedQuantity * m.StandardPrice), 0) AS TotalMaterialCost
    FROM TASK t
    JOIN MATERIAL_USAGE mu ON t.TaskID = mu.TaskID
    JOIN MATERIAL m ON mu.MaterialID = m.MaterialID
    GROUP BY t.ProjectID
),
SubcontractCost AS (
    SELECT 
        ProjectID,
        COALESCE(SUM(ContractValue), 0) AS TotalSubcontractCost
    FROM SUBCONTRACT
    GROUP BY ProjectID
)
SELECT 
    p.ProjectID,
    p.ProjectName,
    p.Status,
    p.EstimatedBudget,
    p.ActualCost AS GeneralLedgerActualCost,
    ROUND(COALESCE(lc.TotalLaborCost, 0), 2) AS CalculatedLaborCost,
    ROUND(COALESCE(ec.TotalEquipmentCost, 0), 2) AS CalculatedEquipmentCost,
    ROUND(COALESCE(mc.TotalMaterialCost, 0), 2) AS CalculatedMaterialCost,
    ROUND(COALESCE(sc.TotalSubcontractCost, 0), 2) AS CommittedSubcontractCost,
    ROUND(
        COALESCE(lc.TotalLaborCost, 0) + 
        COALESCE(ec.TotalEquipmentCost, 0) + 
        COALESCE(mc.TotalMaterialCost, 0) + 
        COALESCE(sc.TotalSubcontractCost, 0), 2
    ) AS TotalProjectCommittedCost,
    ROUND(
        p.EstimatedBudget - (
            COALESCE(lc.TotalLaborCost, 0) + 
            COALESCE(ec.TotalEquipmentCost, 0) + 
            COALESCE(mc.TotalMaterialCost, 0) + 
            COALESCE(sc.TotalSubcontractCost, 0)
        ), 2
    ) AS RemainingBudgetVariance,
    ROUND(
        ((COALESCE(lc.TotalLaborCost, 0) + COALESCE(ec.TotalEquipmentCost, 0) + 
          COALESCE(mc.TotalMaterialCost, 0) + COALESCE(sc.TotalSubcontractCost, 0)) / NULLIF(p.EstimatedBudget, 0)) * 100, 2
    ) AS BudgetBurnRatePct
FROM PROJECT p
LEFT JOIN LaborCost lc ON p.ProjectID = lc.ProjectID
LEFT JOIN EquipmentCost ec ON p.ProjectID = ec.ProjectID
LEFT JOIN MaterialCost mc ON p.ProjectID = mc.ProjectID
LEFT JOIN SubcontractCost sc ON p.ProjectID = sc.ProjectID
ORDER BY p.EstimatedBudget DESC;

-- Report 2.2: Earned Value Analysis (EVM) Project Health Performance Report
-- Computes Planned Value (PV), Earned Value (EV), Actual Cost (AC), CPI, and SPI.
SELECT 
    p.ProjectID,
    p.ProjectName,
    SUM(pp.PhaseBudget) AS PlannedValue_PV,
    ROUND(SUM(pp.PhaseBudget * (pp.ProgressPercentage / 100.0)), 2) AS EarnedValue_EV,
    p.ActualCost AS ActualCost_AC,
    -- Cost Variance (CV = EV - AC)
    ROUND(SUM(pp.PhaseBudget * (pp.ProgressPercentage / 100.0)) - p.ActualCost, 2) AS CostVariance_CV,
    -- Schedule Variance (SV = EV - PV)
    ROUND(SUM(pp.PhaseBudget * (pp.ProgressPercentage / 100.0)) - SUM(pp.PhaseBudget), 2) AS ScheduleVariance_SV,
    -- Cost Performance Index (CPI = EV / AC)
    ROUND(SUM(pp.PhaseBudget * (pp.ProgressPercentage / 100.0)) / NULLIF(p.ActualCost, 0), 3) AS CostPerformanceIndex_CPI,
    -- Schedule Performance Index (SPI = EV / PV)
    ROUND(SUM(pp.PhaseBudget * (pp.ProgressPercentage / 100.0)) / NULLIF(SUM(pp.PhaseBudget), 0), 3) AS SchedulePerformanceIndex_SPI,
    -- Project Health Status
    CASE 
        WHEN (SUM(pp.PhaseBudget * (pp.ProgressPercentage / 100.0)) / NULLIF(p.ActualCost, 0)) >= 1.0
         AND (SUM(pp.PhaseBudget * (pp.ProgressPercentage / 100.0)) / NULLIF(SUM(pp.PhaseBudget), 0)) >= 1.0 
        THEN 'EXCELLENT: Ahead of Schedule & Under Budget'
        WHEN (SUM(pp.PhaseBudget * (pp.ProgressPercentage / 100.0)) / NULLIF(p.ActualCost, 0)) >= 0.90 
        THEN 'FAIR: Minor Variance Within Tolerance'
        ELSE 'ALERT: Cost Overrun or Significant Delay'
    END AS ProjectHealthStatus
FROM PROJECT p
JOIN PROJECT_PHASE pp ON p.ProjectID = pp.ProjectID
WHERE p.Status = 'Active'
GROUP BY p.ProjectID, p.ProjectName, p.ActualCost;

-- Report 2.3: Comprehensive Site Safety & Incident Audit Report
-- Summarizes safety audit scores, open corrective actions, and lost-time injuries.
SELECT 
    ps.SiteID,
    ps.SiteName,
    p.ProjectName,
    COUNT(DISTINCT si.InspectionID) AS TotalInspectionsConducted,
    ROUND(AVG(si.OverallScore), 2) AS AverageSafetyAuditScore,
    COUNT(DISTINCT CASE WHEN si.InspectionResult = 'Pass' THEN si.InspectionID END) AS PassedAudits,
    COUNT(DISTINCT CASE WHEN si.InspectionResult IN ('Conditional-Pass', 'Fail') THEN si.InspectionID END) AS AuditsWithDeficiencies,
    COUNT(DISTINCT ir.IncidentID) AS TotalIncidentsRecorded,
    COALESCE(SUM(ir.LostDays), 0) AS TotalLostDaysFromInjuries,
    CASE 
        WHEN COALESCE(SUM(ir.LostDays), 0) = 0 AND AVG(si.OverallScore) >= 90.0 THEN 'EXEMPLARY: Gold Standard Site'
        WHEN AVG(si.OverallScore) >= 75.0 THEN 'ACCEPTABLE: Standard Site Monitoring'
        ELSE 'HIGH RISK: Immediate Safety Intervention Required'
    END AS SiteRiskProfile
FROM PROJECT_SITE ps
JOIN PROJECT p ON ps.ProjectID = p.ProjectID
LEFT JOIN SAFETY_INSPECTION si ON ps.SiteID = si.SiteID
LEFT JOIN INCIDENT_REPORT ir ON ps.SiteID = ir.SiteID
GROUP BY ps.SiteID, ps.SiteName, p.ProjectName;

-- Report 2.4: Heavy Machinery Fleet Utilization & Maintenance Cost Ratio
-- Evaluates machine productivity (run hours vs maintenance expense).
SELECT 
    e.EquipmentID,
    e.EquipmentName,
    e.Category,
    e.HourlyRate,
    e.TotalRunHours,
    ROUND(e.TotalRunHours * e.HourlyRate, 2) AS LifetimeGrossRevenueGenerated,
    COUNT(mr.RecordNumber) AS TotalMaintenanceSessions,
    COALESCE(SUM(mr.Cost), 0.00) AS TotalMaintenanceCostSpent,
    ROUND(
        (COALESCE(SUM(mr.Cost), 0.00) / NULLIF(e.TotalRunHours * e.HourlyRate, 0)) * 100, 2
    ) AS MaintenanceCostToRevenueRatioPct
FROM EQUIPMENT e
LEFT JOIN MAINTENANCE_RECORD mr ON e.EquipmentID = mr.EquipmentID
GROUP BY e.EquipmentID, e.EquipmentName, e.Category, e.HourlyRate, e.TotalRunHours
ORDER BY LifetimeGrossRevenueGenerated DESC;

-- =============================================================================
-- PART 3: PROOF OF TRIGGER ENFORCEMENT & VERIFICATION
-- =============================================================================

-- Verification Query 3.1: Verify Rule 8 Emergency Dispatch Trigger Execution
-- Confirms that when INC-2024-02 was created, the trigger automatically identified
-- the employee's dependent and logged an urgent emergency message!
SELECT 
    l.LogID,
    l.IncidentID,
    l.InvolvedEmpID,
    CONCAT(e.FirstName, ' ', e.LastName) AS InjuredEmployee,
    l.EmergencyContactName,
    l.Relationship,
    l.ContactPhone,
    l.DispatchedAt,
    l.MessageSubject,
    l.MessageBody,
    l.NotificationStatus
FROM EMERGENCY_DISPATCH_LOG l
JOIN EMPLOYEE e ON l.InvolvedEmpID = e.EmpID;
