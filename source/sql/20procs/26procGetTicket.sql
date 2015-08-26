USE HyperPawn
GO

IF OBJECT_ID('GetTicket') IS NOT NULL
  DROP PROC GetTicket
GO

CREATE PROC GetTicket
@PawnId INT
WITH ENCRYPTION
AS
SET NOCOUNT ON

DECLARE @Amount MONEY
SELECT @Amount = SUM(LI.Amount)
 FROM     HyperPawnData.dbo.Pawn        L
 JOIN     HyperPawnData.dbo.PawnItem    LI ON LI.FirstPawnId = L.FirstPawnId
 WHERE    L.PawnId = @PawnId


SELECT L.*,
'$'+CONVERT(VARCHAR(MAX),                                                                                              L.Amount) AmountFinanced,
'$'+CONVERT(VARCHAR(MAX), (R.FirearmFee * GunCount) + R.StorageFee + R.PreparationAmount + (R.MonthlyInterestAmount * 1)                     ) FinanceCharge,
 '$'+CONVERT(VARCHAR(MAX), (R.FirearmFee * GunCount) + R.StorageFee + R.PreparationAmount + (R.MonthlyInterestAmount * 1)        + L.Amount) TotalofPayments,
     CONVERT(VARCHAR(MAX),CAST(((R.FirearmFee * GunCount) + R.StorageFee + R.PreparationAmount + (R.MonthlyInterestAmount * 3)) * 4.0 / L.Amount * 100 AS MONEY))+'%'  APR,
 '$'+CONVERT(VARCHAR(MAX),                                                         (R.MonthlyInterestAmount * 3)                     ) Interest90,
 '$'+CONVERT(VARCHAR(MAX),                             R.PreparationAmount                                                   ) DocumentPreperationFee,
 '$'+CONVERT(VARCHAR(MAX), R.StorageFee			                                                                                       ) StorageFee,
     CASE WHEN (R.FirearmFee * GunCount) > 0 THEN '$'+CONVERT(VARCHAR(MAX), (R.FirearmFee * GunCount)) ELSE '' END                                               FirearmFee,
 '$'+CONVERT(VARCHAR(MAX), (R.FirearmFee * GunCount) + R.StorageFee + R.PreparationAmount )                                           PreparationAndStorageFee,
 '$'+CONVERT(VARCHAR(max), (R.FirearmFee * GunCount) + R.StorageFee + R.PreparationAmount + (R.MonthlyInterestAmount * 3)        ) TotalFinanceCharge,
     CONVERT(VARCHAR(MAX), PawnDate,1)                                                                                               Date1Start,
     CONVERT(VARCHAR(MAX), DATEADD(day,30,PawnDate),1)                                                                                            Date1End,
 '$'+CONVERT(VARCHAR(MAX), (R.FirearmFee * GunCount) + R.StorageFee + R.PreparationAmount +  R.MonthlyInterestAmount             + L.Amount) Total30,
     CONVERT(VARCHAR(MAX), DATEADD(day,30,PawnDate),1)                                                                                            Date2Start,
     CONVERT(VARCHAR(MAX), DATEADD(day,60,PawnDate),1)                                                                                            Date2End,
 '$'+CONVERT(VARCHAR(MAX), (R.FirearmFee * GunCount) + R.StorageFee + R.PreparationAmount + (R.MonthlyInterestAmount * 2)        + L.Amount) Total60,
     CONVERT(VARCHAR(MAX), DATEADD(day,60,PawnDate),1)                                                                                            Date3Start,
     CONVERT(VARCHAR(MAX), DATEADD(day,90,PawnDate),1)                                                                                            Date3End,
 '$'+CONVERT(VARCHAR(MAX), (R.FirearmFee * GunCount) + R.StorageFee + R.PreparationAmount + (R.MonthlyInterestAmount * 3)        + L.Amount) Total90,
 '$'+CONVERT(VARCHAR(MAX),                                                          R.MonthlyInterestAmount                          ) MonthlyInterestAmount
FROM
(SELECT   L.PawnId,
          CASE WHEN L.PawnId <> L.FirstPawnId THEN L.FirstPawnId ELSE NULL END FirstPawnId,
          L.PawnDate,
          F.PawnDate FirstPawnDate,
          L.Location,
          CASE WHEN L.PawnId <> L.FirstPawnId THEN 'Paid Interest' ELSE '' END InterestIndicator,
          L.CustomerId,
          C.Last + ', '+ C.First CustName,
          C.Street + ', ' + C.City + ', ' + C.State + ' ' + C.Zip Address,
          CONVERT(VARCHAR(MAX), C.DateOfBirth,1) DateOfBirth,
          PT.Name+'/'+ISNULL(C.IdState,'') IdState,
          C.IdNumber,
          C.Street,
          C.City,
          C.State,
          C.Zip,
          C.Sex,
          C.Race,
          C.Height,
          C.Weight,
          C.Hair,
          C.Eyes,
          dbo.FnItemDescriptionTicket(L.FirstPawnId) ItemDescriptionTicket,
          dbo.FnItemDescriptionTicket(L.FirstPawnId) ItemDescriptionPolice,
          E.Initials EmployeeInitials,
          SUM(LI.Amount) Amount,
          MAX(LI.FirearmLogReferenceId) MaxFirearmLogReferenceId,
          SUM(CASE WHEN I.ItemTypeId = 2 THEN 1 ELSE 0 END) GunCount
 FROM     HyperPawnData.dbo.Pawn        L
 JOIN     HyperPawnData.dbo.Pawn        F  ON L.FirstPawnId = F.PawnId
 JOIN     HyperPawnData.dbo.Party       C  ON L.CustomerId = C.PartyId
 JOIN     HyperPawnData.dbo.PartyIdType PT ON C.IdTypeId = PT.PartyIdTypeId
 JOIN     HyperPawnData.dbo.PawnItem    LI ON LI.FirstPawnId = L.FirstPawnId
 JOIN     HyperPawnData.dbo.Item        I  ON LI.ItemId = I.ItemId
 JOIN     HyperPawnData.dbo.Employee    E  ON L.CreatedBy = E.EmployeeId
 WHERE    L.PawnId = @PawnId
 GROUP BY L.PawnId,
          L.FirstPawnId,
          L.PawnDate,
          F.PawnDate,
          L.Location,
          L.CustomerId,
          C.Last,
          C.First,
          C.Middle,
          C.Street,
          C.City,
          C.State,
          C.Zip,
          C.DateOfBirth,
          C.IdNumber,
          PT.Name+'/'+ISNULL(C.IdState,''),
          C.Street,
          C.City,
          C.State,
          C.Zip,
          C.Sex,
          C.Race,
          C.Height,
          C.Weight,
          C.Hair,
          E.Initials,
          C.Eyes) L
JOIN HyperPawn.dbo.fn_PawnFees_WA(@Amount) R ON 1=1

GO

/*
GetTicket
@PawnId = 139772
*/

IF OBJECT_ID('PrintingGetJewelryLabel') IS NOT NULL
  DROP PROC PrintingGetJewelryLabel
GO

CREATE PROC PrintingGetJewelryLabel
@Type   CHAR(1),
@Id INT
WITH ENCRYPTION
AS
  SET NOCOUNT ON
  
  IF @Type = 'P'
    SELECT   C.Last, P.PawnDate, P.PawnId, SUM(LI.Amount) Amount, dbo.FnItemDescriptionTicket(P.FirstPawnId) Description
    FROM     HyperPawnData.dbo.Pawn        P
    JOIN     HyperPawnData.dbo.Party       C  ON P.CustomerId  = C.PartyId
    JOIN     HyperPawnData.dbo.PawnItem    LI ON P.FirstPawnId = LI.FirstPawnId
    JOIN     HyperPawnData.dbo.Item        I  ON LI.ItemId     = I.ItemId
    JOIN     HyperPawnData.dbo.ItemSubType S  ON I.ItemSubTypeId = S.ItemSubTypeId AND S.ItemTypeId = I.ItemTypeId
    WHERE    P.PawnId = @Id
    GROUP BY C.Last, P.PawnDate, P.PawnId, P.FirstPawnId
    HAVING   MAX(CASE WHEN I.ItemTypeId = 1 THEN 1 ELSE 0 END) = 1
GO

--EXEC GetLabel 66365

