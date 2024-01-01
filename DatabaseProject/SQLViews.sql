-- VIEWS

USE LawFirm
GO

-- 1
-- Returns table showing clients debt and their cases.
CREATE OR ALTER VIEW v_UnpaidAmount
AS
   SELECT
        cl.CustomerNo,
        CASE
            WHEN EXISTS (SELECT 1 FROM PersonClient AS PC WHERE PC.CustomerNo = cl.CustomerNo)
            THEN (SELECT CONCAT(PC.FirstName, ' ', PC.SurName)
                  FROM PersonClient AS PC
                  WHERE cl.CustomerNo = PC.CustomerNo)
            ELSE (SELECT CC.CompanyName
                  FROM CompanyClient AS CC
                  WHERE CC.CustomerNo = cl.CustomerNo)
        END AS ClientInfo,
        p.TotalDebt,
        ac.CaseNo
    FROM
        Client cl
        INNER JOIN AssosiatedCustomer ac ON ac.CustomerNo = cl.CustomerNo
        INNER JOIN Payment p ON p.SenderNo = cl.CustomerNo;
		
SELECT * FROM v_UnpaidAmount;

-- 2
CREATE VIEW [dbo].[unresolvedTrialInfos]
AS
SELECT 
   DISTINCT T.TrialDate,
    CASE
        WHEN EXISTS(SELECT 1 FROM PersonClient as PC WHERE PC.customerNo = CL.CustomerNo)
        THEN 
            (SELECT CONCAT(PC.FirstName,' ', PC.SurName)
             FROM PersonClient AS PC 
             WHERE CL.CustomerNo=PC.CustomerNo)
        ELSE
            (SELECT CC.CompanyName
             FROM CompanyClient AS CC 
             WHERE CC.CustomerNo =CL.CustomerNo)
    END AS ClientInfo
   
FROM 
    AssociatedCase AS AC 
INNER JOIN 
    [Case] AS C ON (AC.CaseNo = C.CaseNo AND C.IsResolved=0)
INNER JOIN 
    Trial AS T ON AC.TrialNo = T.TrialNo
INNER JOIN 
    AssosiatedCustomer AS AC2 ON AC2.CaseNo = C.CaseNo
INNER JOIN 
    Client AS CL ON  CL.CustomerNo = AC2.CustomerNo

SELECT * FROM unresolvedTrialInfos;

--3
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
     WHERE C.IsResolved = 1) AS resolved ON resolved.CaseNo = AL.CaseNo
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

SELECT * FROM lawyersSuccessRate;

--4
CREATE VIEW ClientContactSummary AS
SELECT
    ClientType,
    COUNT(DISTINCT C.CustomerNo) AS TotalClients,
    COUNT(DISTINCT CEC.EmailNo) AS TotalEmailContacts,
    COUNT(DISTINCT CPC.PhoneId) AS TotalPhoneContacts
FROM (
    SELECT
        C.CustomerNo,
        CASE
            WHEN EXISTS (SELECT 1 FROM PersonClient AS PC WHERE PC.CustomerNo = C.CustomerNo)
            THEN 'Person'
            ELSE 'Company'
        END AS ClientType
    FROM Client AS C
) AS C
LEFT JOIN PersonClient AS PC ON C.CustomerNo = PC.CustomerNo
LEFT JOIN CompanyClient AS CC ON C.CustomerNo = CC.CustomerNo
LEFT JOIN ClientEmailContact AS CEC ON C.CustomerNo = CEC.CustomerNo
LEFT JOIN ClientPhoneContact AS CPC ON C.CustomerNo = CPC.CustomerNo
GROUP BY ClientType;

SELECT * FROM ClientContactSummary