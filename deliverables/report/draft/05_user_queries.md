### 5. `05_user_queries.sql` (User Queries — Multi-Table Joins, Grouping & Filtering)

Implements 2 user-defined analytical queries demonstrating multi-table `INNER JOIN`, `WHERE` filtering, `GROUP BY`, `HAVING`, and `ORDER BY`, together with their corresponding Relational Algebra expressions and MySQL Workbench execution results.

---

#### Query 5.1: High-Salary Employee Workload by Department
*Retrieves employees earning at least 15,000,000 VND who are assigned to project tasks, summarizing their assigned task count and total logged hours.*

* **Problem Statement:** List employees with `Salary >= 15,000,000` VND who are assigned to tasks, displaying their department, salary, total assigned tasks, and total logged hours. Keep only employees with total logged hours greater than `0`, sorted by total logged hours descending.
* **Relational Algebra Expression:**

  1. *Filter high-salary employees (`WHERE`):*

  $$E_{\text{high}} \leftarrow \sigma_{\text{Salary} \ge 15000000}(\text{EMPLOYEE})$$

  2. *Join with department and task assignment tables (`INNER JOIN`):*

  $$J_1 \leftarrow (E_{\text{high}} \bowtie_{\text{DeptID}} \text{DEPARTMENT}) \bowtie_{\text{EmpID}} \text{WORKS\_ON\_TASK}$$

  3. *Group by employee and aggregate task count & logged hours (`GROUP BY`):*

  $$G_1 \leftarrow {}_{\text{EmpID, FirstName, LastName, DeptName, Salary}}\mathcal{F}_{\text{COUNT(TaskID)} \to \text{TotalTasks},\; \text{SUM(HoursLogged)} \to \text{TotalHoursLogged}}(J_1)$$

  4. *Keep only employees with positive logged hours (`HAVING`):*

  $$H_1 \leftarrow \sigma_{\text{TotalHoursLogged} > 0}(G_1)$$

  5. *Project output columns and sort descending (`SELECT`, `ORDER BY`):*

  $$\text{Result}_{5.1} \leftarrow \tau_{\text{TotalHoursLogged} \downarrow}\Big(\pi_{\text{EmpID, FullName, DeptName, Salary, TotalTasks, TotalHoursLogged}}(H_1)\Big)$$

* **SQL Code:**

```sql
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
```

* **Execution Result:**

> **[INSERT SCREENSHOT: MySQL Workbench Result Grid for Query 5.1]**

---

#### Query 5.2: Project & Job Site Count by Client
*Aggregates non-cancelled high-budget projects by client and counts their active job sites.*

* **Problem Statement:** Retrieve all non-cancelled projects with `EstimatedBudget > 30,000,000,000` VND, together with the client name and total number of job sites. Keep only projects that have at least `1` job site, sorted by `EstimatedBudget` descending.
* **Relational Algebra Expression:**

  1. *Filter non-cancelled projects with budget over 30 billion (`WHERE`):*

  $$P_{\text{high}} \leftarrow \sigma_{\text{Status} \neq \text{'Cancelled'} \land \text{EstimatedBudget} > 30000000000}(\text{PROJECT})$$

  2. *Join with client and project site tables (`INNER JOIN`):*

  $$J_2 \leftarrow (P_{\text{high}} \bowtie_{\text{ClientID}} \text{CLIENT}) \bowtie_{\text{ProjectID}} \text{PROJECT\_SITE}$$

  3. *Group by project and count job sites (`GROUP BY`):*

  $$G_2 \leftarrow {}_{\text{ProjectID, ProjectName, Status, ClientName, EstimatedBudget}}\mathcal{F}_{\text{COUNT(SiteID)} \to \text{TotalSites}}(J_2)$$

  4. *Keep only projects with at least 1 site (`HAVING`):*

  $$H_2 \leftarrow \sigma_{\text{TotalSites} \ge 1}(G_2)$$

  5. *Project output columns and sort by budget descending (`SELECT`, `ORDER BY`):*

  $$\text{Result}_{5.2} \leftarrow \tau_{\text{EstimatedBudget} \downarrow}\Big(\pi_{\text{ProjectID, ProjectName, Status, ClientName, EstimatedBudget, TotalSites}}(H_2)\Big)$$

* **SQL Code:**

```sql
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
```

* **Execution Result:**

> **[INSERT SCREENSHOT: MySQL Workbench Result Grid for Query 5.2]**

---

*The complete SQL script (`05_user_queries.sql`) is attached in `deliverables/sql/`.*
