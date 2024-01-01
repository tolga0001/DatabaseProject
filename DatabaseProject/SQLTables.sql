USE master
GO

CREATE DATABASE LawFirm
GO

USE LawFirm
GO

-- TABLES

CREATE TABLE Employee (
    Ssn NVARCHAR(12) PRIMARY KEY,
    [Name] NVARCHAR (50) NOT NULL,
    [LastName]  NVARCHAR (50) NOT NULL,
);

CREATE TABLE EmployeePhoneContact(
 PhoneId NVARCHAR(10) PRIMARY KEY,
 SSN NVARCHAR(12),
 PhoneNumber NVARCHAR(20) NOT NULL,
 FOREIGN KEY (Ssn) REFERENCES Employee (SSN)
)

Create Table EmployeeEmailContact(
  EmailId int PRIMARY KEY,
  SSN NVARCHAR(12),
  Email NVARCHAR(20) NOT NULL,
  FOREIGN KEY (SSN) REFERENCES Employee (SSN)

)
CREATE TABLE Representative(
    RepresentativeNo int IDENTITY(200,1) PRIMARY KEY,
    SSN NVARCHAR(12),
 FOREIGN KEY (SSN) REFERENCES Employee(SSN)
    
)

CREATE TABLE Account(
   AccountId int Primary KEY,
   IBAN  NVARCHAR(30) UNIQUE NOT NULL,
   BankName NVARCHAR(20) NOT NULL
)
CREATE TABLE Manager(
    ManagerNo int IDENTITY(500,5) PRIMARY KEY,
    Ssn NVARCHAR(12),
     FOREIGN KEY (SSN) REFERENCES Employee(SSN)
)
CREATE TABLE Lawyer(
    LawyerNo int IDENTITY(1,1) PRIMARY KEY,
    Ssn NVARCHAR(12),
    FOREIGN KEY (SSN) REFERENCES Employee(SSN),
    AccountId int,
    ManagerNo int,
     FOREIGN KEY (AccountId) REFERENCES Account(AccountId),
     FOREIGN KEY (ManagerNo) REFERENCES Manager(ManagerNo)
)
CREATE TABLE Client(
   CustomerNo int PRIMARY KEY,
)
CREATE TABLE PersonClient(
    Ssn NVARCHAR(12) Primary KEY,
    [FirstName] NVARCHAR(20),
    [SurName] NVARCHAR(30),
	CustomerNo int,
	FOREIGN KEY (CustomerNo) REFERENCES Client(CustomerNo)
)
CREATE TABLE CompanyClient(
    Companyname NVARCHAR(50) PRIMARY KEY,
	CustomerNo int,
	FOREIGN KEY (CustomerNo) REFERENCES Client(CustomerNo)
)
CREATE TABLE CompanyAddress(
   Street VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    PostalCode VARCHAR(20),
    CompanyName NVARCHAR(50),
FOREIGN KEY (CompanyName) REFERENCES CompanyClient(CompanyName)
)


CREATE TABLE ClientPhoneContact(
      PhoneId NVARCHAR(10) PRIMARY KEY,
	  PhoneNumber NVARCHAR(20) NOT NULL,
      CustomerNo int,
      FOREIGN KEY (customerNo) REFERENCES Client(customerNo)
)
CREATE TABLE ClientEmailContact(
      EmailNo int PRIMARY KEY,
	  Email NVARCHAR(20) NOT NULL,
      CustomerNo int,
      FOREIGN KEY (customerNo) REFERENCES Client(customerNo)
)


CREATE TABLE Payment(
PaymentId int PRIMARY KEY,
ReceiverNo int,
SenderNo int,
TotalDebt DECIMAL(10, 2),
LeftAmountOfDebt DECIMAL(10, 2),
FirstDateOfPayment DATE CHECK (FirstDateOfPayment <= DATEADD(MONTH, 6, GETDATE())),
--This makes sure new payments are started at most 6 months later than today
LastDateOfPayment AS (DATEADD(MONTH, 6, FirstDateOfPayment)),
--Client should pay the debt at most in 6 months
IsResolved AS (CASE WHEN LeftAmountOfDebt <= 0 THEN 1 ELSE 0 END),
FOREIGN KEY (ReceiverNo) REFERENCES Lawyer(LawyerNo),
FOREIGN KEY (SenderNo) REFERENCES Client(customerNo)
)

CREATE TABLE [Transaction](
TransactionAmount DECIMAL(10, 2),
PaymentId int,
CustomerNo int,
FOREIGN KEY (PaymentId) REFERENCES Payment(PaymentId),
FOREIGN KEY (CustomerNo) REFERENCES Client(CustomerNo)
)

CREATE TABLE Trial(
TrialNo int PRIMARY KEY,
TrialType NVARCHAR(50),
Alias NVARCHAR(30),
TrialDate date,
isCaseResolved BIT DEFAULT 0,
)

CREATE TABLE [Case](
    CaseNo int PRIMARY KEY,
    CaseType NVARCHAR(30),
	Alias NVARCHAR(30),
	IsResolved bit DEFAULT 0
    
)
CREATE TABLE RelevancyPeriod(
    StartDate DATE,
    EndDate DATE,
     CaseNo int,
     FOREIGN KEY (CaseNo) REFERENCES [CASE](CaseNo) 

)
CREATE TABLE AssosiatedCustomer(
  CustomerNo int,
  CaseNo int,
  FOREIGN KEY (customerNo) REFERENCES Client(CustomerNo),
  FOREIGN KEY (caseNo) REFERENCES [Case](CaseNo)
)
CREATE TABLE AssosiatedLawyer(
  LawyerNo int,
  CaseNo int,
  FOREIGN KEY (LawyerNo) REFERENCES Lawyer(LawyerNo),
  FOREIGN KEY (caseNo) REFERENCES [Case](caseNo)
)

CREATE TABLE RepresentativeAtCourt(
	RepresentativeNo int,
	TrialNo int
	FOREIGN KEY (RepresentativeNo) REFERENCES Representative(RepresentativeNo),
	FOREIGN KEY (TrialNo) REFERENCES Trial(TrialNo)
)

CREATE TABLE AssociatedCase(
	TrialNo int,
	CaseNo int
	FOREIGN KEY (CaseNo) REFERENCES [Case](CaseNo),
	FOREIGN KEY (TrialNo) REFERENCES Trial(TrialNo)
)

-- INDECES 

CREATE UNIQUE INDEX index_IBAN
ON Account(IBAN)

CREATE INDEX index_Transactions
ON [Transaction](PaymentId)

CREATE INDEX index_PaymentDate
ON Payment(FirstDateOfPayment, LastDateOfPayment)

CREATE INDEX index_TrialDate
ON Trial(TrialDate)