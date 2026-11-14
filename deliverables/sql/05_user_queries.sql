-- =============================================================================
-- A34Build Construction Enterprise Database System
-- File 05: User Queries (Multi-Table Joins, Grouping & Filtering)
-- Target DBMS: MySQL 8.0+
-- =============================================================================

USE A34Build_DB;

-- =============================================================================
-- Query 5.1: High-Salary Employee Workload by Department
-- Problem Statement:
--   List employees with Salary >= 15,000,000 VND who are assigned to at least
--   one task, showing their department, salary, number of assigned tasks, and
--   total logged hours. Keep only employees with total logged hours > 0, and
--   sort by total logged hours descending.
-- =============================================================================
SELECT 
    e.EmpID,
    CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
    d.DeptName,
    e.Salary,
    COUNT(w.TaskID) AS TotalTasks,
    SUM(w.HoursLogged) AS TotalHoursLogged
FROM EMPLOYEE e
INNER JOIN DEPARTMENT d ON e.DeptID = d.DeptID
INNER JOIN WORKS_ON_TASK w ON e.EmpID = w.EmpID
WHERE e.Salary >= 15000000
GROUP BY e.EmpID, e.FirstName, e.LastName, d.DeptName, e.Salary
HAVING TotalHoursLogged > 0
ORDER BY TotalHoursLogged DESC;

-- =============================================================================
-- Query 5.2: Active/Planning Projects & Site Count by Client
-- Problem Statement:
--   Retrieve all non-cancelled projects with EstimatedBudget > 30,000,000,000
--   VND along with their client name and total number of job sites. Keep only
--   projects with at least 1 job site, sorted by EstimatedBudget descending.
-- =============================================================================
SELECT 
    p.ProjectID,
    p.ProjectName,
    p.Status,
    c.ClientName,
    p.EstimatedBudget,
    COUNT(ps.SiteID) AS TotalSites
FROM PROJECT p
INNER JOIN CLIENT c ON p.ClientID = c.ClientID
INNER JOIN PROJECT_SITE ps ON p.ProjectID = ps.ProjectID
WHERE p.Status <> 'Cancelled'
  AND p.EstimatedBudget > 30000000000
GROUP BY p.ProjectID, p.ProjectName, p.Status, c.ClientName, p.EstimatedBudget
HAVING TotalSites >= 1
ORDER BY p.EstimatedBudget DESC;
