select * from account
select * from transactiontype
select * from dbo.TransactionLog



SELECT TransactionTypeId, AccountId, SUM(Amount) 
FROM TransactionLog
GROUP BY TransactionTypeId, AccountId

delete AccountTransaction


-- Cash sale in
INSERT INTO AccountTransaction (TransactionDate, AccountTransactionTaxCategoryId, AccountId, Amount)
VALUES (GETDATE(),1,1,100)
-- layaway payment in
INSERT INTO AccountTransaction (TransactionDate, AccountTransactionTaxCategoryId, AccountId, Amount)
VALUES (GETDATE(),2,1,125)
-- payroll out
INSERT INTO AccountTransaction (TransactionDate, AccountTransactionTaxCategoryId, AccountId, Amount)
VALUES (GETDATE(),3,1,-80)
-- misc out
INSERT INTO AccountTransaction (TransactionDate, AccountTransactionTaxCategoryId, AccountId, Amount)
VALUES (GETDATE(),4,1,-5)
-- lunch out
INSERT INTO AccountTransaction (TransactionDate, AccountTransactionTaxCategoryId, AccountId, Amount)
VALUES (GETDATE(),5,1,-26.52)

-- Credit Card
--credit sale in
INSERT INTO AccountTransaction (TransactionDate, AccountTransactionTaxCategoryId, AccountId, Amount)
VALUES (GETDATE(),1,2,212.50)

-- layaway payment in
INSERT INTO AccountTransaction (TransactionDate, AccountTransactionTaxCategoryId, AccountId, Amount)
VALUES (GETDATE(),2,2,50)


update AccountTransaction set TransactionDate = '2009/11/07'