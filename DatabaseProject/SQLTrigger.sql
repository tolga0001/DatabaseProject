-- TRIGGERS

USE LawFirm
GO

-- 1
-- This trigger controls the inserted transaction if there is no payment with
--given ID in transaction, this trigger deletes transaction. If nothing is wrong
--this trigger updates the leftAmountOfDebt in payment table.
CREATE OR ALTER TRIGGER t_InsertTransaction ON [Transaction]
	AFTER INSERT
	AS
	BEGIN
		DECLARE @PaymentID INT;

		SELECT @PaymentID = i.PaymentId FROM inserted i;

		IF NOT EXISTS (SELECT 1 FROM Payment p WHERE p.PaymentId = @PaymentID)
		BEGIN
			print 'There is no payment with ID: ' + CAST(@PaymentID AS nvarchar(5)) + '. Please check transaction parameters.'
			
			DELETE t
			FROM [Transaction] t
			join inserted i ON t.PaymentId = i.PaymentId AND t.CustomerNo = i.CustomerNo

			print 'Transaction  deleted.'

			RETURN
		END

		UPDATE p
		SET p.LeftAmountOfDebt = p.LeftAmountOfDebt - i.TransactionAmount
		FROM Payment p
		join inserted i on p.PaymentId = i.PaymentId

		print 'Transaction is created. Left amount of debt in payment table is updated'
	END

-- 2
-- When a trial is resolved, cases associated with the trial
--are also updated as resolved
CREATE OR ALTER TRIGGER t_TrialIsResolved ON [Trial] 
	AFTER UPDATE
	AS
	BEGIN
		IF((SELECT i.isCaseResolved FROM inserted i) = 1)
		BEGIN
			UPDATE c
			SET c.IsResolved = 1
			FROM inserted i
			inner join AssociatedCase ac on i.TrialNo = ac.TrialNo
			inner join [Case] c on ac.CaseNo = c.CaseNo
		END
	END