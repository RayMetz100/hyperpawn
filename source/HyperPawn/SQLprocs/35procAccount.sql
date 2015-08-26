USE HyperPawn
GO

IF OBJECT_ID('TaxyGetAccounts') IS NOT NULL
  DROP PROCEDURE TaxyGetAccounts
GO

CREATE PROCEDURE TaxyGetAccounts
AS

SELECT *
FROM HyperPawnData.dbo.Account
GO



IF OBJECT_ID('TaxyGetAccountTransactionTaxCategories') IS NOT NULL
  DROP PROCEDURE TaxyGetAccountTransactionTaxCategories
GO

CREATE PROCEDURE TaxyGetAccountTransactionTaxCategories
AS

SELECT *
FROM HyperPawnData.dbo.AccountTransactionTaxCategory
GO


IF OBJECT_ID('AccountTransactionsGet') IS NOT NULL
  DROP PROCEDURE AccountTransactionsGet
GO

CREATE PROCEDURE AccountTransactionsGet
  @StartDate DATETIME,
  @EndDate   DATETIME -- user will type date to end on (sproc will return data for that end date)
AS


SELECT AccountTransactionId, TransactionDate, AccountId, AccountTransactionTaxCategoryId, Amount
FROM HyperPawnData.dbo.AccountTransaction L
WHERE L.TransactionDate >= @StartDate AND L.TransactionDate < DATEADD(DD,1,@EndDate)

GO

--TaxyGetAccountTransactions '10/5/2009','10/5/2009'


IF OBJECT_ID('AccountTransactionsSave') IS NOT NULL
  DROP PROCEDURE AccountTransactionsSave
GO

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'AccountTransactionType')
  DROP TYPE dbo.AccountTransactionType
GO

CREATE TYPE dbo.AccountTransactionType AS TABLE
 (AccountTransactionId            INT,
  TransactionDate                 DATETIME2, 
  AccountId                       SMALLINT, 
  AccountTransactionTaxCategoryId TINYINT, 
  Amount                          MONEY)
GO

CREATE PROCEDURE AccountTransactionsSave
  (@tvpAccountTransactions dbo.AccountTransactionType READONLY)
AS

UPDATE D
SET TransactionDate                 = I.TransactionDate,
    AccountId                       = I.AccountId,
    AccountTransactionTaxCategoryId = I.AccountTransactionTaxCategoryId,
    Amount                          = I.Amount
FROM @tvpAccountTransactions              I
JOIN HyperPawnData.dbo.AccountTransaction D ON I.AccountTransactionId = D.AccountTransactionId

INSERT INTO HyperPawnData.dbo.AccountTransaction 
		(TransactionDate, AccountTransactionTaxCategoryId, AccountId, Amount)
SELECT   TransactionDate, AccountTransactionTaxCategoryId, AccountId, Amount
FROM	 @tvpAccountTransactions I
WHERE    I.AccountTransactionId IS NULL


GO
