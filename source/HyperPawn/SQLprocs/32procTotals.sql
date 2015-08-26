USE HyperPawn
GO

IF OBJECT_ID('TotalsGetTaxTotals','P') IS NOT NULL
  DROP PROCEDURE TotalsGetTaxTotals
GO

CREATE PROCEDURE TotalsGetTaxTotals
@StartDate DATETIME,
@EndDate   DATETIME, -- user will type date to end on (sproc will return data for that end date)
--@DailyDetail BIT = 0,
@PawnDetail BIT = 0
AS
SET NOCOUNT ON
SELECT   P.PawnStatusId Status, P.PawnId Id, P.PawnDate PawnOrPurchDate, P.PawnStatusDate StatusDate, SUM(I.Amount) Amount, 
          CASE WHEN P.PawnStatusId IN('P','R') AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN ISNULL(P.InterestReceived,0) END InterestReceived,
          CASE 
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'New Loan + Redeemed Loans'
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.FirstPawnId = P.PawnId AND P.FirstPawnId = P.PawnId THEN 'New Loan'
               WHEN P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Redeemed Loans + Interest Income' 
               WHEN P.PawnStatusId = 'F'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Floored Inv'
               WHEN P.PawnStatusId = 'R'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Interest Income'
          END ReportedAs, 
          P.FirstPawnId
INTO     #Period
FROM     HyperPawnData.dbo.Pawn       P
--JOIN     HyperPawnData.dbo.PawnStatus S ON P.PawnStatusId = S.PawnStatusId
JOIN     HyperPawnData.dbo.PawnItem   I ON P.FirstPawnId = I.FirstPawnId
WHERE       ((P.PawnDate     >= @StartDate AND P.PawnDate       < DATEADD(DD,1,@EndDate)) AND P.PawnId = P.FirstPawnId)
         OR P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate)
GROUP BY P.PawnId, P.PawnDate, P.PawnStatusId, P.PawnStatusId, P.PawnStatusDate, P.FirstPawnId, P.InterestReceived
UNION
SELECT   'U', P.PurchaseId, P.PurchaseDate, '', SUM(I.Amount) Amount,NULL,
        'Purchased Items' ReportedAs, NULL
FROM     HyperPawnData.dbo.Purchase     P
JOIN     HyperPawnData.dbo.PurchaseItem I ON P.PurchaseId = I.PurchaseId
WHERE    P.PurchaseDate >= @StartDate AND P.PurchaseDate < DATEADD(DD,1,@EndDate)
GROUP BY P.PurchaseId, P.PurchaseDate
--UNION
--SELECT 'C1', TransactionId, SUM(Amount)-- , TransactionTypeId, AccountId
--FROM HyperPawnData.dbo.TransactionLog
--GROUP BY TransactionTypeId, AccountId
ORDER BY 2


IF @PawnDetail = 1
   SELECT * FROM #Period

SELECT @StartDate StartDate, @EndDate EndDate, 1 Ord, 'New Loans' TaxLine, ISNULL(SUM(Amount),0) Amount
FROM #Period
WHERE Status <> 'U'      AND PawnOrPurchDate >= @StartDate AND PawnOrPurchDate < DATEADD(DD,1,@EndDate) AND ReportedAs = 'New Loan'
UNION
SELECT @StartDate          , @EndDate        , 2,     'Redeemed Loans',   ISNULL(SUM(Amount),0)
FROM #Period
WHERE Status = 'P'       AND StatusDate      >= @StartDate AND StatusDate      < DATEADD(DD,1,@EndDate)
UNION
SELECT @StartDate          , @EndDate        , 3,     'Floored Inv',      ISNULL(SUM(Amount),0)
FROM #Period
WHERE Status = 'F'       AND StatusDate      >= @StartDate AND StatusDate      < DATEADD(DD,1,@EndDate)
UNION
SELECT @StartDate          , @EndDate        , 4,     'Purchased Items',  ISNULL(SUM(Amount),0)
FROM #Period
WHERE Status = 'U'
UNION
SELECT @StartDate          , @EndDate        , 5,     'Interest Income',  ISNULL(SUM(InterestReceived),0)
FROM #Period
WHERE Status IN('P','R') AND StatusDate      >= @StartDate AND StatusDate < DATEADD(DD,1,@EndDate)
ORDER BY 1,3

GO

/*
EXEC TotalsGetTaxTotals '10/05/2009','10/05/2009'--, @PawnDetail = 1
*/

IF OBJECT_ID('TotalsGetDayDetail','P') IS NOT NULL
  DROP PROCEDURE TotalsGetDayDetail
GO

CREATE PROCEDURE TotalsGetDayDetail
  @StartDate DATETIME2,
  @EndDate   DATETIME2
AS
  SET NOCOUNT ON
  
  -- Pawns
  SELECT 'Pawns' Type, P.PawnId Id, P.PawnDate, C.Last Name, dbo.FnItemDescriptionTicket(P.FirstPawnId) Description, 
         SUM(I.Amount) Amount, SUM(P.InterestReceived) Interest, SUM(I.Amount) + ISNULL(SUM(P.InterestReceived),0) Total, 
         P.Location, S.PawnStatus CurrentStatus, CASE WHEN P.PawnStatusDate IS NULL THEN P.PawnDate ELSE P.PawnStatusDate END StatusDate, E.Initials Employee
  FROM   HyperPawnData.dbo.Pawn       P
  JOIN   HyperPawnData.dbo.Employee   E ON P.CreatedBy = E.EmployeeId
  JOIN   HyperPawnData.dbo.PawnStatus S ON P.PawnStatusId = S.PawnStatusId
  JOIN   HyperPawnData.dbo.Party      C ON P.CustomerId = C.PartyId
  JOIN   HyperPawnData.dbo.PawnItem   I ON P.FirstPawnId = I.FirstPawnId
  WHERE      P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DAY,1,@EndDate)
         AND P.Created >= @StartDate AND P.Created < DATEADD(DAY,1,@EndDate)
         AND P.FirstPawnId = P.PawnId
  GROUP BY P.PawnId, P.PawnDate, C.Last, P.FirstPawnId, S.PawnStatus, P.PawnStatusDate, P.Location, E.Initials
  UNION ALL
  -- Renewed
  SELECT 'Renewed' Type, P.PawnId Id, P.PawnDate, C.Last Name, dbo.FnItemDescriptionTicket(P.FirstPawnId) Description, 
         SUM(I.Amount) Amount, SUM(P.InterestReceived) Interest, SUM(I.Amount) + SUM(P.InterestReceived) Total, 
         P.Location, S.PawnStatus CurrentStatus, P.PawnStatusDate StatusDate, E.Initials Employee
  FROM   HyperPawnData.dbo.Pawn       P
  JOIN   HyperPawnData.dbo.Employee   E ON P.ModifiedBy = E.EmployeeId
  JOIN   HyperPawnData.dbo.PawnStatus S ON P.PawnStatusId = S.PawnStatusId
  JOIN   HyperPawnData.dbo.Party      C ON P.CustomerId = C.PartyId
  JOIN   HyperPawnData.dbo.PawnItem   I ON P.FirstPawnId = I.FirstPawnId
  
  WHERE  P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DAY,1,@EndDate) AND P.PawnStatusId = 'R'
  GROUP BY P.PawnId, P.PawnDate, C.Last, P.FirstPawnId, S.PawnStatus, P.PawnStatusDate, P.Location, E.Initials
  UNION ALL  
  -- PickedUp
  SELECT 'PickedUp' Type, P.PawnId Id, P.PawnDate, C.Last Name, dbo.FnItemDescriptionTicket(P.FirstPawnId) Description, 
         SUM(I.Amount) Amount, SUM(P.InterestReceived) Interest, SUM(I.Amount) + SUM(P.InterestReceived) Total, 
         P.Location, S.PawnStatus CurrentStatus, P.PawnStatusDate StatusDate, E.Initials Employee
  FROM   HyperPawnData.dbo.Pawn       P
  JOIN   HyperPawnData.dbo.Employee   E ON P.ModifiedBy = E.EmployeeId
  JOIN   HyperPawnData.dbo.PawnStatus S ON P.PawnStatusId = S.PawnStatusId
  JOIN   HyperPawnData.dbo.Party      C ON P.CustomerId = C.PartyId
  JOIN   HyperPawnData.dbo.PawnItem   I ON P.FirstPawnId = I.FirstPawnId
  WHERE  P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DAY,1,@EndDate) AND P.PawnStatusId = 'P'
  GROUP BY P.PawnId, P.PawnDate, C.Last, P.FirstPawnId, S.PawnStatus, P.PawnStatusDate, P.Location, E.Initials
  UNION ALL
  --Sales
  SELECT C.AccountTransactionTaxCategoryName, AccountTransactionId, TransactionDate, NULL,NULL,Amount,NULL,NULL,A.AccountName, NULL,GETDATE(),NULL
  FROM HyperPawnData.dbo.AccountTransaction T
  JOIN HyperPawnData.dbo.AccountTransactionTaxCategory C ON T.AccountTransactionTaxCategoryId = C.AccountTransactionTaxCategoryId
  JOIN HyperPawnData.dbo.Account A ON T.AccountId = A.AccountId
  WHERE T.TransactionDate >= @StartDate AND T.TransactionDate < DATEADD(DD,1,@EndDate)
  ORDER BY Type, PawnId

GO

--TotalsGetDayDetail '10/5/2009','10/5/2009'

IF OBJECT_ID('TotalsGetAmountLoanedOut','P') IS NOT NULL
  DROP PROCEDURE TotalsGetAmountLoanedOut
GO

CREATE PROCEDURE TotalsGetAmountLoanedOut
@AmountLoanedOut MONEY OUT
AS
  SELECT @AmountLoanedOut = ISNULL(SUM(LI.Amount),0)
  FROM   HyperPawnData.dbo.Pawn     L
  JOIN   HyperPawnData.dbo.PawnItem LI ON L.FirstPawnId = LI.FirstPawnId
  WHERE  L.PawnStatusId = 'A'  
GO
