USE HyperPawn
GO

IF OBJECT_ID('ReportSearchItems') IS NOT NULL
  DROP PROCEDURE ReportSearchItems
GO

CREATE PROCEDURE ReportSearchItems
  @SearchString VARCHAR(255),
  @PawnStatusId CHAR(1) = NULL
  WITH ENCRYPTION
AS
SET NOCOUNT ON

SELECT @SearchString = '%'+@SearchString+'%'

      SELECT    TOP(50)
        'Pawns' Type, P.PawnId Id, P.PawnDate, C.Last Name, dbo.FnItemDescriptionTicket(P.FirstPawnId) Description, 
         SUM(LI.Amount) Amount, P.Location, S.PawnStatus CurrentStatus, 
         CASE WHEN P.PawnStatusDate IS NULL THEN P.PawnDate ELSE P.PawnStatusDate END StatusDate, 
         E.Initials Employee
      FROM      HyperPawnData.dbo.Pawn             P
      JOIN      HyperPawnData.dbo.Employee         E  ON P.CreatedBy = E.EmployeeId
      JOIN      HyperPawnData.dbo.PawnStatus       S  ON P.PawnStatusId = S.PawnStatusId
      JOIN      HyperPawnData.dbo.Party            C  ON P.CustomerId = C.PartyId
      JOIN      HyperPawnData.dbo.PawnItem         LI ON P.FirstPawnId = LI.FirstPawnId
      JOIN      HyperPawnData.dbo.Item             I  ON LI.ItemId = I.ItemId
      JOIN      HyperPawnData.dbo.ItemType         Y  ON I.ItemTypeId = Y.ItemTypeId
      JOIN      HyperPawnData.dbo.ItemSubType      U  ON I.ItemSubTypeId = U.ItemSubTypeId AND I.ItemTypeId = U.ItemTypeId
      LEFT JOIN HyperPawnData.dbo.ItemNonSerial    N  ON LI.ItemId = N.ItemId
      LEFT JOIN HyperPawnData.dbo.ItemSerial       SI ON LI.ItemId = SI.ItemId
      LEFT JOIN HyperPawnData.dbo.ItemFirearm      F  ON LI.ItemId = F.ItemId
      WHERE         I.ItemTypeId <> 2
                AND ISNULL(LI.ItemDescription,'') + ISNULL(SI.Make,'') + ISNULL(SI.Model,'') 
                     + ISNULL(SI.SerialNumber,'') LIKE @SearchString
                AND CASE WHEN @PawnStatusId IS NULL THEN P.PawnStatusId ELSE @PawnStatusId END = P.PawnStatusId
      GROUP BY P.PawnId, P.PawnDate, C.Last, P.FirstPawnId, S.PawnStatus, P.PawnStatusDate, P.Location, E.Initials
      ORDER BY  P.PawnDate DESC
GO


-- ReportSearchItems 'spide'

IF OBJECT_ID('GetFloorReport') IS NOT NULL
  DROP PROCEDURE GetFloorReport
GO

CREATE PROCEDURE GetFloorReport
@PawnIds XML
WITH ENCRYPTION
AS
  DECLARE @t TABLE (PawnId INT NOT NULL PRIMARY KEY CLUSTERED)
  INSERT INTO @t
  SELECT i.value('@PawnId','INT') AS ItemId
  FROM   @PawnIds.nodes('root/row') itm(i)

  SELECT 'Pawn' Type, 
           CASE WHEN P.PawnStatusDate IS NULL THEN P.PawnDate ELSE P.PawnStatusDate END StatusDate, 
           S.PawnStatus                                                CurrentStatus, 
           P.PawnId                                                    Id, 
           P.PawnDate                                                  PawnDate,
           P.FirstPawnId                                               FirstPawnId,
           O.PawnDate                                                  FirstPawnDate, 
           C.Last+', '+C.First                                         Name, 
           SUM(I.Amount)                                               Amount, 
           
           E.Initials                                                  Employee,
           
           P.Location                                                  Location,
                      
           H.Active, H.PaidInt, H.PickedUp, H.Floored,
           DATEDIFF(MONTH, P.PawnDate, DATEADD(DAY,-90,SYSDATETIME())) MonthsBehind,
           
           
           dbo.FnItemDescriptionTicket(P.FirstPawnId)                  Description, 
           C.Note                                                      CustomerNote, 
           P.Note                                                      PawnNote
  FROM     HyperPawnData.dbo.Pawn       P
  JOIN     @t                           Z ON P.PawnId = Z.PawnId
  JOIN     HyperPawnData.dbo.Employee   E ON P.CreatedBy = E.EmployeeId
  JOIN     HyperPawnData.dbo.PawnStatus S ON P.PawnStatusId = S.PawnStatusId
  JOIN     HyperPawnData.dbo.Party      C ON P.CustomerId = C.PartyId
  JOIN     HyperPawnData.dbo.PawnItem   I ON P.FirstPawnId = I.FirstPawnId
  JOIN     HyperPawnData.dbo.Item       T ON I.ItemId      = T.ItemId
  JOIN     (SELECT   CustomerId,
                     SUM(CASE WHEN PawnStatusId = 'A' THEN 1 ELSE 0 END)       Active,
                     SUM(CASE WHEN PawnStatusId = 'R' THEN 1 ELSE 0 END)       PaidInt,
                     SUM(CASE WHEN PawnStatusId = 'P' THEN 1 ELSE 0 END)       PickedUp,
                     SUM(CASE WHEN PawnStatusId = 'F' THEN 1 ELSE 0 END)       Floored
            FROM     HyperPawnData.dbo.Pawn
            GROUP BY CustomerId) H ON P.CustomerId = H.CustomerId
  JOIN     HyperPawnData.dbo.Pawn       O ON P.FirstPawnId = O.PawnId
  WHERE        P.PawnStatusId = 'A' AND P.PawnDate < DATEADD(DAY, -90, SYSDATETIME())
  GROUP BY P.PawnId, P.PawnDate, C.Last, C.First, P.FirstPawnId, S.PawnStatus, P.PawnStatusDate, P.Location, E.Initials,
           C.Note, P.Note, O.PawnDate, C.PartyId, H.Active, H.PaidInt, H.PickedUp, H.Floored
  ORDER BY C.Last, C.First, C.PartyId, P.PawnId
GO


IF OBJECT_ID('ReportFloorGetLatestDays') IS NOT NULL
  DROP PROCEDURE ReportFloorGetLatestDays
GO

CREATE PROCEDURE ReportFloorGetLatestDays
@Num INT
WITH ENCRYPTION
AS
SELECT   TOP (@Num)
           --P.PawnStatusDate,
           CAST(
           CAST(DATEPART(year ,P.PawnStatusDate) AS VARCHAR(100)) + '/' +
           CAST(DATEPART(month,P.PawnStatusDate) AS VARCHAR(100)) + '/' +
           CAST(DATEPART(day  ,P.PawnStatusDate) AS VARCHAR(100))
           AS DATETIME) PawnStatusDay
           ,COUNT(1)         'Count'
  FROM     HyperPawnData.dbo.Pawn       P
  WHERE    P.PawnStatusId = 'F'
  GROUP BY CAST(
           CAST(DATEPART(year ,P.PawnStatusDate) AS VARCHAR(100)) + '/' +
           CAST(DATEPART(month,P.PawnStatusDate) AS VARCHAR(100)) + '/' +
           CAST(DATEPART(day  ,P.PawnStatusDate) AS VARCHAR(100))
           AS DATETIME)
  ORDER BY CAST(
           CAST(DATEPART(year ,P.PawnStatusDate) AS VARCHAR(100)) + '/' +
           CAST(DATEPART(month,P.PawnStatusDate) AS VARCHAR(100)) + '/' +
           CAST(DATEPART(day  ,P.PawnStatusDate) AS VARCHAR(100))
           AS DATETIME) DESC
GO

/*
ReportFloorGetLatestDays
*/

IF OBJECT_ID('ReportLocationGetCounts') IS NOT NULL
  DROP PROCEDURE ReportLocationGetCounts
GO

CREATE PROCEDURE ReportLocationGetCounts
@Num INT
WITH ENCRYPTION
AS
SELECT   TOP (@Num)
           --P.PawnStatusDate,
           P.Location
           ,COUNT(1)         'Count'
  FROM     HyperPawnData.dbo.Pawn       P
  WHERE    P.PawnStatusId = 'A'
  GROUP BY P.Location
  ORDER BY P.Location
GO

/*
ReportLocationGetCounts
*/

/*
DECLARE @Pawns XML
SET @Pawns = '
<root><row PawnId="160781"/><row PawnId="153902"/></root>
'
EXEC GetFloorReport @Pawns
*/


IF OBJECT_ID('ChrisReportGetFlooredPawns') IS NOT NULL
  DROP PROCEDURE ChrisReportGetFlooredPawns
GO

CREATE PROCEDURE ChrisReportGetFlooredPawns
@FlooredDay DATETIME
WITH ENCRYPTION
AS
  SELECT
           P.FirstPawnId                                               FirstPawnId,
           O.PawnDate                                                  FirstPawnDate, 
           P.PawnId                                                    Id, 
           P.PawnDate                                                  PawnDate,
           P.Location                                                  Location,
           dbo.FnItemDescriptionTicket(P.FirstPawnId)                  Description, 
           C.Last+', '+C.First                                         Name, 
           SUM(I.Amount)                                               Amount, 
           S.PawnStatus                                                CurrentStatus, 
           CASE WHEN P.PawnStatusDate IS NULL THEN P.PawnDate ELSE P.PawnStatusDate END StatusDate, 
           E.Initials                                                  Employee,
           H.Active,
           H.PaidInt,
           H.PickedUp,
           H.Floored,
           DATEDIFF(MONTH, P.PawnDate, DATEADD(DAY,-90,SYSDATETIME())) MonthsBehind,
           
           
           C.Note                                                      CustomerNote, 
           P.Note                                                      PawnNote
  FROM     HyperPawnData.dbo.Pawn       P
  JOIN     HyperPawnData.dbo.Employee   E ON P.CreatedBy = E.EmployeeId
  JOIN     HyperPawnData.dbo.PawnStatus S ON P.PawnStatusId = S.PawnStatusId
  JOIN     HyperPawnData.dbo.Party      C ON P.CustomerId = C.PartyId
  JOIN     HyperPawnData.dbo.PawnItem   I ON P.FirstPawnId = I.FirstPawnId
  JOIN     HyperPawnData.dbo.Item       T ON I.ItemId      = T.ItemId
  JOIN     HyperPawnData.dbo.Pawn       O ON P.FirstPawnId = O.PawnId
  JOIN     (SELECT   CustomerId,
                     SUM(CASE WHEN PawnStatusId = 'A' THEN 1 ELSE 0 END)       Active,
                     SUM(CASE WHEN PawnStatusId = 'R' THEN 1 ELSE 0 END)       PaidInt,
                     SUM(CASE WHEN PawnStatusId = 'P' THEN 1 ELSE 0 END)       PickedUp,
                     SUM(CASE WHEN PawnStatusId = 'F' THEN 1 ELSE 0 END)       Floored
            FROM     HyperPawnData.dbo.Pawn
            GROUP BY CustomerId) H ON P.CustomerId = H.CustomerId
  WHERE        P.PawnStatusDate >=  @FlooredDay
           AND P.PawnStatusDate <   @FlooredDay + 1
           AND P.PawnStatusId = 'F'
  GROUP BY P.PawnId, P.PawnDate, C.Last, C.First, P.FirstPawnId, S.PawnStatus, P.PawnStatusDate, P.Location, E.Initials,
           C.Note, P.Note, O.PawnDate, C.PartyId, H.Active, H.PaidInt, H.PickedUp, H.Floored
  ORDER BY C.Last, C.First, C.PartyId, P.PawnId
GO




IF OBJECT_ID('ChrisReportGetPawnsByLocation') IS NOT NULL
  DROP PROCEDURE ChrisReportGetPawnsByLocation
GO

CREATE PROCEDURE ChrisReportGetPawnsByLocation
@StartLocation VARCHAR(100),
@EndLocation   VARCHAR(100)
WITH ENCRYPTION
AS
  SELECT
           P.FirstPawnId                                               FirstPawnId,
           O.PawnDate                                                  FirstPawnDate, 
           P.PawnId                                                    Id, 
           P.PawnDate                                                  PawnDate,
           P.Location                                                  Location,
           dbo.FnItemDescriptionTicket(P.FirstPawnId)                  Description, 
           C.Last+', '+C.First                                         Name, 
           SUM(I.Amount)                                               Amount, 
           S.PawnStatus                                                CurrentStatus, 
           CASE WHEN P.PawnStatusDate IS NULL THEN P.PawnDate ELSE P.PawnStatusDate END StatusDate, 
           E.Initials                                                  Employee,
           H.Active,
           H.PaidInt,
           H.PickedUp,
           H.Floored,
           DATEDIFF(MONTH, P.PawnDate, DATEADD(DAY,-90,SYSDATETIME())) MonthsBehind,
           
           
           C.Note                                                      CustomerNote, 
           P.Note                                                      PawnNote
  FROM     HyperPawnData.dbo.Pawn       P
  JOIN     HyperPawnData.dbo.Employee   E ON P.CreatedBy = E.EmployeeId
  JOIN     HyperPawnData.dbo.PawnStatus S ON P.PawnStatusId = S.PawnStatusId
  JOIN     HyperPawnData.dbo.Party      C ON P.CustomerId = C.PartyId
  JOIN     HyperPawnData.dbo.PawnItem   I ON P.FirstPawnId = I.FirstPawnId
  JOIN     HyperPawnData.dbo.Item       T ON I.ItemId      = T.ItemId
  JOIN     HyperPawnData.dbo.Pawn       O ON P.FirstPawnId = O.PawnId
  JOIN     (SELECT   CustomerId,
                     SUM(CASE WHEN PawnStatusId = 'A' THEN 1 ELSE 0 END)       Active,
                     SUM(CASE WHEN PawnStatusId = 'R' THEN 1 ELSE 0 END)       PaidInt,
                     SUM(CASE WHEN PawnStatusId = 'P' THEN 1 ELSE 0 END)       PickedUp,
                     SUM(CASE WHEN PawnStatusId = 'F' THEN 1 ELSE 0 END)       Floored
            FROM     HyperPawnData.dbo.Pawn
            GROUP BY CustomerId) H ON P.CustomerId = H.CustomerId
  WHERE        P.Location >=  @StartLocation
           AND P.Location <=  @EndLocation
           AND P.PawnStatusId = 'F'
  GROUP BY P.PawnId, P.PawnDate, C.Last, C.First, P.FirstPawnId, S.PawnStatus, P.PawnStatusDate, P.Location, E.Initials,
           C.Note, P.Note, O.PawnDate, C.PartyId, H.Active, H.PaidInt, H.PickedUp, H.Floored
  ORDER BY C.Last, C.First, C.PartyId, P.PawnId
GO

