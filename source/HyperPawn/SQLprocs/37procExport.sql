/*
EXEC HyperPawn..ReportDailyTotals @StartDate = '5/4/2011', @EndDate = '5/4/2011'
*/
USE HyperPawn
GO

IF OBJECT_ID('ReportDailyTotals') IS NOT NULL
	DROP PROCEDURE ReportDailyTotals
GO

CREATE PROCEDURE ReportDailyTotals
	@StartDate DATETIME,
	@EndDate DATETIME
AS

DECLARE @NewLoan TABLE
(Id INT IDENTITY(1,1),
NewLoan MONEY)

INSERT INTO @NewLoan (NewLoan)
SELECT  -- P.PawnStatusId Status, 
		--P.PawnId Id, 
		--P.PawnDate PawnOrPurchDate, P.PawnStatusDate StatusDate, 
		SUM(I.Amount) NewLoan 
        /*  CASE WHEN P.PawnStatusId IN('P','R') AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN ISNULL(P.InterestReceived,0) END InterestReceived,
          CASE 
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'New Loan + Redeemed Loans'
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.FirstPawnId = P.PawnId AND P.FirstPawnId = P.PawnId THEN 'New Loan'
               WHEN P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Redeemed Loans + Interest Income' 
               WHEN P.PawnStatusId = 'F'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Floored Inv'
               WHEN P.PawnStatusId = 'R'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Interest Income'
          END ReportedAs, 
          P.FirstPawnId */
FROM     HyperPawnData.dbo.Pawn       P
--JOIN     HyperPawnData.dbo.PawnStatus S ON P.PawnStatusId = S.PawnStatusId
JOIN     HyperPawnData.dbo.PawnItem   I ON P.FirstPawnId = I.FirstPawnId
WHERE    (   ((P.PawnDate     >= @StartDate AND P.PawnDate       < DATEADD(DD,1,@EndDate)) AND P.PawnId = P.FirstPawnId)
         OR P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate))
         AND CASE 
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'New Loan + Redeemed Loans'
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.FirstPawnId = P.PawnId AND P.FirstPawnId = P.PawnId THEN 'New Loan'
               WHEN P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Redeemed Loans + Interest Income' 
               WHEN P.PawnStatusId = 'F'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Floored Inv'
               WHEN P.PawnStatusId = 'R'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Interest Income'
          END = 'New Loan'
--GROUP BY P.PawnId, P.PawnDate, P.PawnStatusId, P.PawnStatusId, P.PawnStatusDate, P.FirstPawnId, P.InterestReceived
GROUP BY P.PawnId
ORDER BY SUM(I.Amount) DESC


DECLARE @Redeem TABLE
(Id INT IDENTITY(1,1),
RedeemPrincipal MONEY,
RedeemInterest MONEY)

INSERT INTO @Redeem (RedeemPrincipal, RedeemInterest)

SELECT  -- P.PawnStatusId Status, 
		--P.PawnId Id, 
		--P.PawnDate PawnOrPurchDate, P.PawnStatusDate StatusDate, 
		SUM(I.Amount) RedeemedPrincipal,
        CASE WHEN P.PawnStatusId IN('P','R') AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN ISNULL(P.InterestReceived,0) END InterestPaid
        /*  CASE 
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'New Loan + Redeemed Loans'
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.FirstPawnId = P.PawnId AND P.FirstPawnId = P.PawnId THEN 'New Loan'
               WHEN P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Redeemed Loans + Interest Income' 
               WHEN P.PawnStatusId = 'F'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Floored Inv'
               WHEN P.PawnStatusId = 'R'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Interest Income'
          END ReportedAs, 
          P.FirstPawnId */
FROM     HyperPawnData.dbo.Pawn       P
--JOIN     HyperPawnData.dbo.PawnStatus S ON P.PawnStatusId = S.PawnStatusId
JOIN     HyperPawnData.dbo.PawnItem   I ON P.FirstPawnId = I.FirstPawnId
WHERE    (   ((P.PawnDate     >= @StartDate AND P.PawnDate       < DATEADD(DD,1,@EndDate)) AND P.PawnId = P.FirstPawnId)
         OR P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate))
         AND CASE 
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'New Loan + Redeemed Loans'
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.FirstPawnId = P.PawnId AND P.FirstPawnId = P.PawnId THEN 'New Loan'
               WHEN P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Redeemed Loans + Interest Income' 
               WHEN P.PawnStatusId = 'F'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Floored Inv'
               WHEN P.PawnStatusId = 'R'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Interest Income'
          END = 'Redeemed Loans + Interest Income'
GROUP BY P.PawnId, P.PawnDate, P.PawnStatusId, P.PawnStatusId, P.PawnStatusDate, P.FirstPawnId, P.InterestReceived
ORDER BY SUM(I.Amount) DESC, 
        CASE WHEN P.PawnStatusId IN('P','R') AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN ISNULL(P.InterestReceived,0) END DESC


DECLARE @Rewrite TABLE
(Id INT IDENTITY(1,1),
RewriteInterest MONEY)

INSERT INTO @Rewrite (RewriteInterest)

SELECT  -- P.PawnStatusId Status, 
		--P.PawnId Id, 
		--P.PawnDate PawnOrPurchDate, P.PawnStatusDate StatusDate, 
		--SUM(I.Amount) RedeemedPrincipal,
        CASE WHEN P.PawnStatusId IN('P','R') AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN ISNULL(P.InterestReceived,0) END RewriteInterest
        /*  CASE 
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'New Loan + Redeemed Loans'
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.FirstPawnId = P.PawnId AND P.FirstPawnId = P.PawnId THEN 'New Loan'
               WHEN P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Redeemed Loans + Interest Income' 
               WHEN P.PawnStatusId = 'F'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Floored Inv'
               WHEN P.PawnStatusId = 'R'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Interest Income'
          END ReportedAs, 
          P.FirstPawnId */
FROM     HyperPawnData.dbo.Pawn       P
--JOIN     HyperPawnData.dbo.PawnStatus S ON P.PawnStatusId = S.PawnStatusId
JOIN     HyperPawnData.dbo.PawnItem   I ON P.FirstPawnId = I.FirstPawnId
WHERE    (   ((P.PawnDate     >= @StartDate AND P.PawnDate       < DATEADD(DD,1,@EndDate)) AND P.PawnId = P.FirstPawnId)
         OR P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate))
         AND CASE 
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'New Loan + Redeemed Loans'
               WHEN P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DD,1,@EndDate) AND P.FirstPawnId = P.PawnId AND P.FirstPawnId = P.PawnId THEN 'New Loan'
               WHEN P.PawnStatusId = 'P' AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Redeemed Loans + Interest Income' 
               WHEN P.PawnStatusId = 'F'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Floored Inv'
               WHEN P.PawnStatusId = 'R'  AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN 'Interest Income'
          END = 'Interest Income'
GROUP BY P.PawnId, P.PawnDate, P.PawnStatusId, P.PawnStatusId, P.PawnStatusDate, P.FirstPawnId, P.InterestReceived
ORDER BY         CASE WHEN P.PawnStatusId IN('P','R') AND P.PawnStatusDate >= @StartDate AND P.PawnStatusDate < DATEADD(DD,1,@EndDate) THEN ISNULL(P.InterestReceived,0) END DESC


SELECT ISNULL(W.Id, I.Id) Id, I.NewLoan, NULL, I.RedeemPrincipal, I.RedeemInterest, W.RewriteInterest
FROM @Rewrite W
FULL OUTER JOIN (
SELECT ISNULL(N.Id, D.Id) Id, N.NewLoan, D.RedeemPrincipal, D.RedeemInterest
FROM @NewLoan N
FULL OUTER JOIN @Redeem D ON N.Id = D.Id
) I ON W.Id = I.Id

GO

/*
CREATE PROCEDURE Test747
AS
SELECT 1 a, 2 b, 3 c, 4 d
union all
select null, 5, 6, null


exec Test747

*/