SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO
