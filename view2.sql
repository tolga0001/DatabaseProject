SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[lawyersSuccessRate]
AS
SELECT 
    E1.Name + ' ' + E1.LastName AS LawyerFullName,
    CAST(COUNT(resolved.CaseNo) * 1.0 / NULLIF(COUNT(DISTINCT allCases.CaseNo), 0) AS DECIMAL(10, 2)) AS SuccessRate,
    ISNULL(E2.Name + ' ' + E2.LastName,'') AS ManagerFullName
FROM 
    Lawyer AS L
LEFT JOIN 
    AssosiatedLawyer AS AL ON AL.LawyerNo = L.LawyerNo
LEFT JOIN  
    (SELECT CaseNo
     FROM [Case] AS C
     WHERE C.isresolved = 1) AS resolved ON resolved.CaseNo = AL.CaseNo
LEFT JOIN  
    (SELECT CaseNo
     FROM [Case] AS C) AS allCases ON allCases.CaseNo = AL.CaseNo
     LEFT JOIN 
    Employee AS E1 ON L.Ssn = E1.Ssn
 LEFT JOIN
      Manager as M on L.ManagerNo = M.ManagerNo
 LEFT JOIN 
    Employee AS E2 ON M.Ssn = E2.Ssn
GROUP BY 
    E1.Name, E1.LastName, E2.Name,E2.LastName
GO
