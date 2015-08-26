USE HyperPawn
GO

IF OBJECT_ID('PawnDelete') IS NOT NULL
  DROP PROC PawnDelete
GO
CREATE PROCEDURE PawnDelete
@PawnId int
WITH ENCRYPTION
AS
  set nocount on

  delete HyperPawnData.dbo.PawnItem
  where FirstPawnId = @PawnId

  Delete HyperPawnData.dbo.Pawn
  where PawnId = @PawnId

  DELETE n
  FROM HyperPawnData.dbo.Item i
  JOIN HyperPawnData.dbo.ItemNonSerial n on i.ItemId = n.ItemId
  WHERE NOT EXISTS(SELECT 1 FROM HyperPawnData.dbo.PawnItem x WHERE x.ItemId = i.ItemId)
  
  DELETE s
  FROM HyperPawnData.dbo.Item i
  JOIN HyperPawnData.dbo.ItemSerial s on i.ItemId = s.ItemId
  WHERE NOT EXISTS(SELECT 1 FROM HyperPawnData.dbo.PawnItem x WHERE x.ItemId = i.ItemId)
  
  DELETE f
  FROM HyperPawnData.dbo.Item i
  JOIN HyperPawnData.dbo.ItemFirearm f on i.ItemId = f.ItemId
  WHERE NOT EXISTS(SELECT 1 FROM HyperPawnData.dbo.PawnItem x WHERE x.ItemId = i.ItemId)
  
  DELETE i
  FROM HyperPawnData.dbo.Item i
  WHERE NOT EXISTS(SELECT 1 FROM HyperPawnData.dbo.PawnItem x WHERE x.ItemId = i.ItemId)

GO


IF OBJECT_ID('PawnAssign') IS NOT NULL
  DROP PROC PawnAssign
GO
CREATE PROCEDURE PawnAssign
@EmployeeId SMALLINT,
@CustomerId INT,
@PawnId INT OUT,
@PawnNote NVARCHAR(1000)
WITH ENCRYPTION
AS
  set nocount on

  BEGIN TRY
    BEGIN TRAN

    SELECT @PawnId = MAX(PawnId) + 1
    FROM HyperPawnData.dbo.Pawn
    
    IF @PawnId IS NULL
      SET @PawnId = 1

    INSERT INTO HyperPawnData.dbo.Pawn ( PawnId,   FirstPawnId,   CreatedBy,   ModifiedBy, PawnDate,   CustomerId,   PawnStatusId,      Note, PawnStatusDate, PawnStatusEmployee)
    VALUES                             (@PawnId,       @PawnId, @EmployeeId,  @EmployeeId, GETDATE(), @CustomerId,   'A'         , @PawnNote, GETDATE(),      @EmployeeId)

    COMMIT TRAN
        
    RETURN 0
  END TRY

  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK TRANSACTION;
    SELECT ERROR_MESSAGE()
    RETURN 1 -- Failure
  END CATCH

GO


IF OBJECT_ID('PawnSave') IS NOT NULL
  DROP PROC PawnSave
GO

CREATE PROC PawnSave
@PawnId           INT OUT,
@FirstPawnId      INT,
@PawnDate         datetime,
@EmployeeId       SMALLINT,
@CustomerId       INT,
@Location         NVARCHAR(30) = NULL,
@PawnStatusId     CHAR(1),
@PawnStatusDate   DATETIME = NULL,
@InterestReceived MONEY = NULL,
@ItemsXml         XML,
@PawnNote         NVARCHAR(1000) = NULL
WITH ENCRYPTION
AS
  SET NOCOUNT ON
  DECLARE @msg VARCHAR(255)
  DECLARE @rc INT
 
 
  IF @PawnStatusId <> 'A' AND (@PawnStatusDate IS NULL)
    BEGIN
      RAISERROR('Inactive Pawns require Pawn Status Date!',11,1)
      RETURN 1
    END
  
  BEGIN TRY
    BEGIN TRANSACTION
      
  IF @PawnStatusDate IS NULL
    SET @PawnStatusDate = SYSDATETIME()
    
      IF (@PawnId IS NULL)
        BEGIN
          EXEC PawnAssign @EmployeeId, @CustomerId, @PawnId OUT, @PawnNote
          SET @FirstPawnId = @PawnId
        END
      ELSE
        BEGIN
          UPDATE HyperPawnData.dbo.Pawn
            SET FirstPawnId      = @FirstPawnId,
                Modified         = GETDATE(),
                ModifiedBy       = @EmployeeId,
                PawnDate         = @PawnDate,
                CustomerId       = @CustomerId,
                Location         = @Location,
                PawnStatusId     = @PawnStatusId,
                PawnStatusDate   = @PawnStatusDate,
                InterestReceived = @InterestReceived,
                Note             = @PawnNote
          WHERE PawnId = @PawnId
          SELECT @rc = @@rowcount
          IF @rc = 0
            INSERT INTO HyperPawnData.dbo.Pawn
                   ( PawnId, FirstPawnId,   CreatedBy,  ModifiedBy,  PawnDate,  CustomerId,  Location,  PawnStatusId,  PawnStatusDate,  InterestReceived,      Note, PawnStatusEmployee)
            VALUES (@PawnId,@FirstPawnId, @EmployeeId, @EmployeeId, @PawnDate, @CustomerId, @Location, @PawnStatusId, @PawnStatusDate, @InterestReceived, @PawnNote, @EmployeeId)
          ELSE
            DELETE    p
            FROM      HyperPawnData.dbo.PawnItem p
            LEFT JOIN @ItemsXml.nodes('ArrayOfItem/Item') itm(i) ON p.ItemId = i.value('@ItemId','INT')
            WHERE     p.FirstPawnId = @PawnId AND i.value('@ItemId','INT') IS NULL
        END
        
      DECLARE
        @ItemId          INT,
        @ItemTypeId      TINYINT,
        @ItemSubTypeId   TINYINT,
        @ItemTableId     TINYINT,
        
        --@DisplayOrder    TINYINT,
        @Amount          MONEY,
        @Description     NVARCHAR(MAX),
        @GunLogNumber    INT,

        @Make            NVARCHAR(50),
        @Model           NVARCHAR(50),
        @Serial          NVARCHAR(50),

        @Caliber         NVARCHAR(30),
        @Action          NVARCHAR(30),
        @Barrel          NVARCHAR(10),
        
        @ReceiptDate     DATETIME2,
        @ReceiptName     NVARCHAR(200),
        @ReceiptAddress  NVARCHAR(200)
        
        SELECT 
          @ReceiptName    = Last + ', '+ ISNULL(First,'')+' '+ ISNULL(Middle,''),
          @ReceiptAddress = Street + ' ' + City + ' ' + State + ' ' + Zip
        FROM HyperPawnData.dbo.Party
        WHERE PartyId = @CustomerId
                
        SELECT @ReceiptDate = SYSDATETIME()

      DECLARE items_cursor CURSOR
      FOR        
        SELECT
               i.value('@ItemId','INT') AS ItemId,
               i.value('@ItemTypeId','TINYINT') AS ItemTypeId,
               i.value('@ItemSubTypeId','TINYINT') AS ItemSubTypeId,
               i.value('@ItemTableId','TINYINT') AS ItemTableId,
               
               --i.value('@DisplayOrder','TINYINT') AS DisplayOrder,
               i.value('@Amount','MONEY') AS Amount,
               i.value('@Description','NVARCHAR(MAX)') AS Description,
               i.value('@GunLogNumber','INT') AS GunLogNumber,

               i.value('@Make','NVARCHAR(50)') AS Make,
               i.value('@Model','NVARCHAR(50)') AS Model,
               i.value('@Serial','NVARCHAR(50)') AS Serial,

               i.value('@Caliber','NVARCHAR(50)') AS Caliber,
               i.value('@Action','NVARCHAR(50)') AS Action,
               i.value('@Barrel','NVARCHAR(50)') AS Barrel
        FROM   @ItemsXml.nodes('ArrayOfItem/Item') itm(i)
        
  OPEN items_cursor
  FETCH NEXT FROM items_cursor
  INTO @ItemId,
       @ItemTypeId,
       @ItemSubTypeId,
       @ItemTableId,
       
       --@DisplayOrder,
       @Amount,
       @Description,
       @GunLogNumber,
       
       @Make,
       @Model,
       @Serial,

       @Caliber,
       @Action,
       @Barrel

  IF @@FETCH_STATUS <> 0 
      RAISERROR('Pawns must have at least one item!',11,1)

  WHILE @@FETCH_STATUS = 0
  BEGIN

    EXEC @rc = PawnItemInsert
      @PawnId  = @PawnId,
      @EmployeeId      = @EmployeeId,
      
      @ItemId          = @ItemId,
      @ItemTypeId      = @ItemTypeId,
      @ItemSubTypeId   = @ItemSubTypeId,
      
      --@DisplayOrder    = @DisplayOrder,
      @Amount          = @Amount,
      @ItemDescription = @Description,
      @GunLogNumber    = @GunLogNumber,
      
      @Make            = @Make,
      @Model           = @Model,
      @SerialNumber    = @Serial,
      
      @Caliber         = @Caliber,
      @Action          = @Action,
      @BarrelLength    = @Barrel,
      
      @ReceiptDate     = @ReceiptDate,
      @ReceiptName     = @ReceiptName,
      @ReceiptAddress  = @ReceiptAddress
      
      
    IF @rc <> 0
      RAISERROR('Pawn Item Not Inserted!',11,1)
      
    FETCH NEXT FROM items_cursor
    INTO @ItemId,
         @ItemTypeId,
         @ItemSubTypeId,
         @ItemTableId,
         
         --@DisplayOrder,
         @Amount,
         @Description,
         @GunLogNumber,
         
         @Make,
         @Model,
         @Serial,

         @Caliber,
         @Action,
       @Barrel
  END

  CLOSE items_cursor
  DEALLOCATE items_cursor

  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK TRANSACTION;
    SET @Msg = 'PawnSave Error: ' + ERROR_MESSAGE()
    RAISERROR(@msg,11,1) WITH NOWAIT
    RETURN 1 -- Failure
  END CATCH
  IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;
  RETURN 0 -- Success
GO


IF OBJECT_ID('GetInterest') IS NOT NULL
  DROP PROC GetInterest
GO

--CREATE PROC GetInterest
--	@PawnAmount money, 
--	@IsFirearm char(1) = 'N', 
--	@PawnDate datetime = NULL, 
--	@PawnId int = NULL
--WITH ENCRYPTION
--AS
--	SET NOCOUNT ON
--	DECLARE @StorageFee                money = 3
--	DECLARE @FirearmFee                money = 0
--	DECLARE @DocumentPreperationAmount money
--	DECLARE @MonthlyInterestAmount     money
--	DECLARE @RowCount                  int
--	Declare @Return                    int

--	IF @IsFirearm = 'Y'
--	  SET @FirearmFee = 3

--	SELECT @DocumentPreperationAmount = DocumentPreperationAmount,
--		   @MonthlyInterestAmount     = MonthlyInterestAmount
--	FROM   InterestWA
--	WHERE  PawnAmount                 = @PawnAmount

--	SELECT @RowCount = @@RowCount

--	IF @RowCount <> 1
--	  BEGIN
--		RAISERROR('Pawn Amount not found',0,1) WITH NOWAIT
--		RETURN 1
--	  END


--	IF @PawnDate IS NULL
--	  SET @PawnDate = GETDATE()

--	SELECT 
--	  CONVERT(varchar(MAX),@PawnDate,1)                                                                          DateMade,
--	  CONVERT(char(5),GETDATE(),14)                                                                              TimeMade,
--	  @PawnId                                                                                                    PawnId,
	  
	  
	  
--																									 @PawnAmount AmountFinanced,
--	  @FirearmFee + @StorageFee + @DocumentPreperationAmount + (@MonthlyInterestAmount * 3)                      FinanceCharge,
--	  @FirearmFee + @StorageFee + @DocumentPreperationAmount + (@MonthlyInterestAmount * 3)        + @PawnAmount TotalofPayments,
--	 (@FirearmFee + @StorageFee + @DocumentPreperationAmount + (@MonthlyInterestAmount * 3)) * 4.0 / @PawnAmount APR,
--															   (@MonthlyInterestAmount * 3)                      Interest90,
--	  @DocumentPreperationAmount                                                                                 DocumentPreperationFee,
--	  @StorageFee			                                                                                     StorageFee,
--	  CASE WHEN @FirearmFee = 0 THEN null ELSE @FirearmFee END                                                   FirearmFee,
--	  @FirearmFee + @StorageFee + @DocumentPreperationAmount + (@MonthlyInterestAmount * 3)        + @PawnAmount TotalFinanceCharge,
--	  CONVERT(varchar(MAX),@PawnDate,1)                                                                          Date1Start,
--	  CONVERT(varchar(MAX),@PawnDate+30,1)                                                                       Date1End,
--	  @FirearmFee + @StorageFee + @DocumentPreperationAmount +  @MonthlyInterestAmount             + @PawnAmount Total30,
--	  CONVERT(varchar(MAX),@PawnDate+30,1)                                                                       Date2Start,
--	  CONVERT(varchar(MAX),@PawnDate+60,1)                                                                       Date2End,
--	  @FirearmFee + @StorageFee + @DocumentPreperationAmount + (@MonthlyInterestAmount * 2)        + @PawnAmount Total60,
--	  CONVERT(varchar(MAX),@PawnDate+60,1)                                                                       Date3Start,
--	  CONVERT(varchar(MAX),@PawnDate+90,1)                                                                       Date3End,
--	  @FirearmFee + @StorageFee + @DocumentPreperationAmount + (@MonthlyInterestAmount * 3)        + @PawnAmount Total90,
--																@MonthlyInterestAmount                           MonthlyInterestAmount

--	  RETURN 0

--GO


--PawnGetDetails 1222

IF OBJECT_ID('PawnGetDetails') IS NOT NULL
  DROP PROC PawnGetDetails
GO
CREATE PROCEDURE PawnGetDetails
@PawnId int
WITH ENCRYPTION
AS
set nocount on
-- Get Pawn
SELECT   L.PawnId      PawnId,
         L.PawnDate, 
         L.FirstPawnId,
         F.PawnDate FirstPawnDate,
         L.Created,
         L.CreatedBy, 
         L.Modified, 
         L.ModifiedBy, 
         L.CustomerId,
         L.Location,
         L.PawnStatusId,
         L.PawnStatusDate,
         L.InterestReceived,
         SUM(LI.Amount) Amount,
         L.Note
FROM     HyperPawnData.dbo.Pawn     L
JOIN     HyperPawnData.dbo.PawnItem LI ON LI.FirstPawnId = L.FirstPawnId
JOIN     HyperPawnData.dbo.Pawn     F  ON L.FirstPawnId = F.PawnId
WHERE    L.PawnId = @PawnId
GROUP BY L.PawnId,
         L.FirstPawnId,
         F.PawnDate,
         L.Created,
         L.CreatedBy, 
         L.Modified, 
         L.ModifiedBy, 
         L.PawnDate, 
         L.CustomerId,
         L.Location,
         L.PawnStatusId,
         L.PawnStatusDate,
         L.InterestReceived,
         L.Note

-- Get Items
SELECT I.ItemId,
       I.ItemTypeId,
       I.ItemSubTypeId,
       U.ItemTableId,
       
       --LI.ItemDisplayOrder DisplayOrder,
       LI.Amount,
       LI.ItemDescription Description,
       E.FirearmLogReferenceId GunLogNumber,
       
       COALESCE(                   S.Make   ,G.Make        ) Make,
       COALESCE(                   S.Model   ,G.Model      ) Model,
       COALESCE(                   S.SerialNumber ,G.SerialNumber  ) Serial,
       
       G.Caliber,
       G.Action,
       F.BarrelLength Barrel
FROM      HyperPawnData.dbo.Pawn          L
JOIN      HyperPawnData.dbo.PawnItem      LI ON LI.FirstPawnId = L.FirstPawnId
JOIN      HyperPawnData.dbo.Item          I  ON LI.ItemId = I.ItemId
JOIN      HyperPawnData.dbo.ItemSubType   U  ON I.ItemSubTypeId = U.ItemSubTypeId AND I.ItemTypeId = U.ItemTypeId
LEFT JOIN HyperPawnData.dbo.ItemNonSerial N  ON LI.ItemId = N.ItemId
LEFT JOIN HyperPawnData.dbo.ItemSerial    S  ON LI.ItemId = S.ItemId
LEFT JOIN HyperPawnData.dbo.ItemFirearm   F  ON LI.ItemId = F.ItemId
      LEFT JOIN (SELECT   FirearmLogReferenceId, MAX(Id) MaxId
                 FROM     HyperPawnData.dbo.FirearmsAcquisitionAndDispositionEntry
                 GROUP BY FirearmLogReferenceId
                 )                                 E  ON LI.FirearmLogReferenceId = E.FirearmLogReferenceId
      LEFT JOIN (SELECT    Id,
                           [manufacturer and importer] Make,
                           [model]                     Model,
                           [serial number]             SerialNumber,
                           [type]                      Action,
                           [caliber or guage]          Caliber
                 FROM      HyperPawnData.dbo.FirearmsAcquisitionAndDispositionEntry
                 )                                 G  ON E.MaxId = G.Id
WHERE     L.PawnId = @PawnId
GO

-- PawnGet 1223

IF OBJECT_ID('PawnGet') IS NOT NULL
  DROP PROC PawnGet
GO
CREATE PROCEDURE PawnGet
@PartyId INT,
@Top INT,
@ShowAll BIT
WITH ENCRYPTION
AS
  SET NOCOUNT ON
  SELECT TOP (@Top)
            L.PawnId,
            L.PawnDate, 
            L.FirstPawnId,
            F.PawnDate FirstPawnDate,
            C.IDNumber,
            dbo.FnItemDescriptionTicket(L.FirstPawnId) ItemDescriptionTicket,
            SUM(LI.Amount) Amount,
            SUM(CASE WHEN I.ItemTypeId = 2 THEN 1 ELSE 0 END) NumberOfFirearms,
            L.Location,
            L.PawnStatusId,
            L.PawnStatusDate,
            L.CustomerId PartyId,
            L.Modified,
            L.Note
  FROM      HyperPawnData.dbo.Pawn       L
  JOIN      HyperPawnData.dbo.Pawn       F  ON L.FirstPawnId  = F.PawnId
  JOIN      HyperPawnData.dbo.Party      C  ON L.CustomerId   = C.PartyId
  JOIN      HyperPawnData.dbo.PawnStatus S  ON L.PawnStatusId = S.PawnStatusId
  JOIN      HyperPawnData.dbo.PawnItem   LI ON LI.FirstPawnId = L.FirstPawnId
  JOIN      HyperPawnData.dbo.Item       I  ON LI.ItemId      = I.ItemId
  WHERE         L.CustomerId   = CASE WHEN @PartyId = 0 THEN L.CustomerId   ELSE @PartyId END
            AND L.PawnStatusId = CASE WHEN @ShowAll = 1 THEN L.PawnStatusId ELSE 'A' END
  GROUP BY  L.PawnId,
            L.PawnDate, 
            L.FirstPawnId,
            F.PawnDate,
            C.IDNumber,
            L.Location,
            L.PawnStatusId,
            L.PawnStatusDate,
            L.CustomerId,
            L.Modified,
            L.Note
  ORDER BY  L.PawnId DESC

GO

-- PawnGet @PartyId = 39

IF OBJECT_ID('PawnRedeem') IS NOT NULL
  DROP PROC PawnRedeem
GO
CREATE PROCEDURE PawnRedeem
@PawnId     INT,
@EmployeeId TINYINT,
@InterestReceived MONEY
WITH ENCRYPTION
AS
SET NOCOUNT ON
DECLARE @FirearmLogReferenceId INT,
        @DispositionDate       DATETIME2    ,
        @DispositionName       NVARCHAR(200),
        @DispositionAddress    NVARCHAR(200),
        @rowcount              INT
            
BEGIN TRY
  BEGIN TRANSACTION
    UPDATE HyperPawnData.dbo.Pawn
    SET PawnStatusId   = 'P', -- Picked Up
        PawnStatusDate = GETDATE(),
        Modified       = GETDATE(),
        ModifiedBy     = @EmployeeId,
        InterestReceived = @InterestReceived
    WHERE PawnId = @PawnId
    
    SET @DispositionDate = SYSDATETIME()

    SELECT @FirearmLogReferenceId = LI.FirearmLogReferenceId,
           @DispositionName    = P.Last + ', '+ ISNULL(P.First,'')+' '+ ISNULL(P.Middle,''),
           @DispositionAddress = P.Street + ' ' + P.City + ' ' + P.State + ' ' + P.Zip
    FROM   HyperPawnData.dbo.Pawn     L
    JOIN   HyperPawnData.dbo.PawnItem LI ON LI.FirstPawnId = L.FirstPawnId
    JOIN   HyperPawnData.dbo.Party    P  ON L.CustomerId = P.PartyId
    WHERE      L.PawnId = @PawnId
           AND LI.FirearmLogReferenceId IS NOT NULL
           
    SELECT @rowcount = @@rowcount
    
    IF @rowcount = 1
      EXEC FirearmPawnPickup
        @FirearmLogReferenceId = @FirearmLogReferenceId,
        @EmployeeId            = @EmployeeId           ,
        @DispositionDate       = @DispositionDate      ,
        @DispositionName       = @DispositionName      ,
        @DispositionAddress    = @DispositionAddress
  COMMIT TRANSACTION
END TRY
BEGIN CATCH
  ROLLBACK
END CATCH  
GO

IF OBJECT_ID('PawnFloor') IS NOT NULL
  DROP PROC PawnFloor
GO
CREATE PROCEDURE PawnFloor
@PawnId INT,
@EmployeeId TINYINT
WITH ENCRYPTION
AS
  UPDATE HyperPawnData.dbo.Pawn
  SET PawnStatusId = 'F', PawnStatusDate = SYSDATETIME(), ModifiedBy = @EmployeeId
  WHERE PawnId = @PawnId AND PawnStatusId = 'A'
GO

-- PawnFloor 162454, 1

IF OBJECT_ID('PawnRenew') IS NOT NULL
  DROP PROC PawnRenew
GO
CREATE PROCEDURE PawnRenew
@RenewingPawnId   INT,
@NewPawnId        INT OUT,
@EmployeeId       TINYINT,
@RenewDate        DATETIME,
@InterestReceived MONEY
WITH ENCRYPTION
AS
SET NOCOUNT ON
DECLARE @msg VARCHAR(255)
DECLARE @OldPawnDate DATETIME

  BEGIN TRY
    BEGIN TRANSACTION
      
      SELECT @OldPawnDate = PawnDate
      FROM   HyperPawnData.dbo.Pawn
      WHERE  PawnId = @RenewingPawnId
      
      IF @RenewDate <= @OldPawnDate
        RAISERROR('Renew Date may not be the same or less than Pawn date!',11,1) WITH NOWAIT
      
      IF (@RenewDate > @OldPawnDate + 180) AND (@RenewDate > DATEADD(day,1,SYSDATETIME()))
        RAISERROR('Pawns may not be renewed more than 6 months in the future!',11,1) WITH NOWAIT
      
      UPDATE HyperPawnData.dbo.Pawn
      SET PawnStatusId     = 'R', -- Renewed
          PawnStatusDate   = GETDATE(),
          InterestReceived = @InterestReceived,
          Modified         = GETDATE(),
          ModifiedBy       = @EmployeeId
      WHERE PawnId = @RenewingPawnId
      
      SELECT @NewPawnId = MAX(PawnId) + 1
      FROM HyperPawnData.dbo.Pawn
      
      INSERT INTO HyperPawnData.dbo.Pawn
      (PawnId,    FirstPawnId, CreatedBy,   ModifiedBy,  PawnDate,   CustomerId, Location, PawnStatusId, PawnStatusEmployee, PawnStatusDate)
      SELECT
      @NewPawnId, FirstPawnId, @EmployeeId, @EmployeeId, @RenewDate, CustomerId, Location, 'A',          @EmployeeId,        GETDATE()
      FROM HyperPawnData.dbo.Pawn
      WHERE PawnId = @RenewingPawnId
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK TRANSACTION;
    SET @msg = 'PawnRenew Error: ' + ERROR_MESSAGE()
    RAISERROR(@msg,11,1) WITH NOWAIT
  END CATCH
  IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;
  RETURN 0 -- Success
GO

-- EXEC PawnRenew 1222,1,'9/6/1966'
--select * from Pawn


IF OBJECT_ID('PawnGetPutAwayItems') IS NOT NULL
  DROP PROC PawnGetPutAwayItems
GO
CREATE PROCEDURE PawnGetPutAwayItems
WITH ENCRYPTION
AS
  SET NOCOUNT ON
  SELECT L.PawnId, L.PawnDate, C.Last, dbo.FnItemDescriptionTicket(L.FirstPawnId) Item, G.FirearmLogReferenceId
  FROM HyperPawnData.dbo.Pawn L
  JOIN HyperPawnData.dbo.Party C ON L.CustomerId = C.PartyId
  JOIN HyperPawnData.dbo.PawnItem G ON L.FirstPawnId = G.FirstPawnId
  WHERE Location IS NULL
        AND L.PawnDate > DATEADD(d,-2,SYSDATETIME())
        AND L.PawnStatusId = 'A'
GO

IF OBJECT_ID('PawnUpdateLocation') IS NOT NULL
  DROP PROC PawnUpdateLocation
GO
CREATE PROCEDURE PawnUpdateLocation
@EmployeeId TINYINT,
@PawnId     INT,
@Location   VARCHAR(50)
WITH ENCRYPTION
AS
  SET NOCOUNT ON
  
  UPDATE HyperPawnData.dbo.Pawn
  SET    Location   = @Location,
         Modified   = SYSDATETIME(),
         ModifiedBy = @EmployeeId
  WHERE  PawnId = @PawnId
  
  
GO


IF OBJECT_ID('PawnGetFloorList') IS NOT NULL
  DROP PROC PawnGetFloorList
GO
CREATE PROCEDURE PawnGetFloorList
@ItemTypeId TINYINT = NULL
WITH ENCRYPTION
AS

DECLARE @ItemType TABLE (ItemTypeId TINYINT NOT NULL PRIMARY KEY CLUSTERED)

IF @ItemTypeId IS NULL
BEGIN
INSERT INTO @ItemType
SELECT ItemTypeId
FROM HyperPawnData.dbo.ItemType
GOTO SelectIt
END

IF @ItemTypeId = 88 -- not jewlery or gun.
BEGIN
INSERT INTO @ItemType
SELECT ItemTypeId
FROM HyperPawnData.dbo.ItemType
WHERE ItemTypeId NOT IN (1,2)
GOTO SelectIt
END

IF @ItemTypeId IS NOT NULL
BEGIN
INSERT INTO @ItemType
SELECT @ItemTypeId
GOTO SelectIt
END

SelectIt:
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
                      
           H.Active,
           H.PaidInt,
           H.PickedUp,
           H.Floored,
           DATEDIFF(MONTH, P.PawnDate, DATEADD(DAY,-90,SYSDATETIME())) MonthsBehind,
           
           
           dbo.FnItemDescriptionTicket(P.FirstPawnId)                  Description, 
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
  JOIN     @ItemType                    F ON T.ItemTypeId = F.ItemTypeId
  WHERE        P.PawnStatusId = 'A' AND P.PawnDate < DATEADD(DAY, -90, SYSDATETIME())
  GROUP BY P.PawnId, P.PawnDate, C.Last, C.First, P.FirstPawnId, S.PawnStatus, P.PawnStatusDate, P.Location, E.Initials,
           C.Note, P.Note, O.PawnDate, C.PartyId, H.Active, H.PaidInt, H.PickedUp, H.Floored
  ORDER BY C.Last, C.First, C.PartyId, P.PawnId
GO


--exec PawnGetFloorList 2


