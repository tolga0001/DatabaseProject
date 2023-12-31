-- VIEWS

USE LawFirm
GO

-- 1
-- Returns table showing clients debt and their cases.
CREATE OR ALTER VIEW v_UnpaidAmount
	AS
	SELECT cl.CustomerNo, ac.CaseNo, p.TotalDebt
	FROM Client cl
	inner join AssosiatedCustomer ac on ac.CustomerNo = cl.CustomerNo
	inner join Payment p on p.SenderNo = cl.CustomerNo
	
SELECT * FROM v_UnpaidAmount;

-- 2
-- 