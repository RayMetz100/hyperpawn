USE HyperPawn
GO

IF OBJECT_ID('PurchaseDelete') IS NOT NULL
  DROP PROC PurchaseDelete
GO
CREATE PROCEDURE PurchaseDelete
@PurchaseId int
WITH ENCRYPTION
AS
  set nocount on

  delete HyperPawnData.dbo.PurchaseItem
  where PurchaseId = @PurchaseId

  Delete HyperPawnData.dbo.Purchase
  where PurchaseId = @PurchaseId

  DELETE n
  FROM HyperPawnData.dbo.Item i
  JOIN HyperPawnData.dbo.ItemNonSerial n on i.ItemId = n.ItemId
  WHERE NOT EXISTS(SELECT 1 FROM PurchaseItem x WHERE x.ItemId = i.ItemId)
  
  DELETE s
  FROM HyperPawnData.dbo.Item i
  JOIN HyperPawnData.dbo.ItemSerial s on i.ItemId = s.ItemId
  WHERE NOT EXISTS(SELECT 1 FROM PurchaseItem x WHERE x.ItemId = i.ItemId)
  
  DELETE f
  FROM HyperPawnData.dbo.Item i
  JOIN HyperPawnData.dbo.ItemFirearm f on i.ItemId = f.ItemId
  WHERE NOT EXISTS(SELECT 1 FROM PurchaseItem x WHERE x.ItemId = i.ItemId)
  
  DELETE i
  FROM HyperPawnData.dbo.Item i
  WHERE NOT EXISTS(SELECT 1 FROM PurchaseItem x WHERE x.ItemId = i.ItemId)

GO


IF OBJECT_ID('PurchaseAssign') IS NOT NULL
  DROP PROC PurchaseAssign
GO
CREATE PROCEDURE PurchaseAssign
@EmployeeId SMALLINT,
@CustomerId INT,
@PurchaseId INT OUT
WITH ENCRYPTION
AS
  set nocount on

  BEGIN TRY
    BEGIN TRAN

    SELECT @PurchaseId = MAX(PurchaseId) + 1
    FROM HyperPawnData.dbo.Purchase
    
    IF @PurchaseId IS NULL
      SET @PurchaseId = 1

    INSERT INTO HyperPawnData.dbo.Purchase ( PurchaseId,    CreatedBy,   ModifiedBy, PurchaseDate,   CustomerId)
    VALUES               (@PurchaseId,    @EmployeeId,  @EmployeeId, GETDATE(), @CustomerId)

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


IF OBJECT_ID('PurchaseItemInsert') IS NOT NULL
  DROP PROC PurchaseItemInsert
GO

CREATE PROC PurchaseItemInsert
  @PurchaseId      INT,
  @EmployeeId      SMALLINT,
  @ItemId          INT,
  @ItemTypeId      TINYINT,
  @ItemSubTypeId   TINYINT,
  --@DisplayOrder    TINYINT,
  @Amount          MONEY,
  @ItemDescription NVARCHAR(MAX) = NULL,
  @Make            NVARCHAR(50)  = NULL,
  @Model           NVARCHAR(50)  = NULL,
  @SerialNumber    NVARCHAR(50)  = NULL,
  @Caliber         NVARCHAR(30)  = NULL,
  @Action          NVARCHAR(30)  = NULL,
  @BarrelLength    NVARCHAR(10)  = NULL,
  @GunLogNumber    INT           = NULL,
  @ReceiptDate     DATETIME2     = NULL,
  @ReceiptName     NVARCHAR(200) = NULL,
  @ReceiptAddress  NVARCHAR(200) = NULL
  WITH ENCRYPTION
AS
  SET NOCOUNT ON
  DECLARE @ItemDetailInsertCount INT
  DECLARE @ItemTableId TINYINT
  DECLARE @msg VARCHAR(255)
  DECLARE @rowcount INT
  DECLARE @FirearmLogReferenceId INT
  DECLARE @OrigItemId INT

  SELECT @ItemTableId = ItemTableId
  FROM   HyperPawnData.dbo.ItemSubType
  WHERE       ItemSubTypeId = @ItemSubTypeId
         AND  ItemTypeId    = @ItemTypeId
  
  SET @OrigItemId = @ItemId
  
  BEGIN TRY
    BEGIN TRANSACTION
    
      IF @ItemId = 0
        BEGIN
          INSERT INTO HyperPawnData.dbo.Item     (CreatedBy,    ModifiedBy,  ItemTypeId,  ItemSubTypeId)
                    VALUES     (@EmployeeId, @EmployeeId, @ItemTypeId, @ItemSubTypeId)
          SELECT @ItemId = @@identity
          IF @ItemTableId = 1
            BEGIN
              INSERT INTO HyperPawnData.dbo.ItemNonSerial ( ItemId)
                      VALUES            (@ItemId)
              SET @ItemDetailInsertCount = @@rowcount
            END        
          IF @ItemTableId = 2
            BEGIN
              INSERT INTO HyperPawnData.dbo.ItemSerial    ( ItemId,  Make,  Model,  SerialNumber)
                      VALUES            (@ItemId, @Make, @Model, @SerialNumber)
              SET @ItemDetailInsertCount = @@rowcount
            END        
          IF @ItemTableId = 3 -- new gun
            BEGIN
              INSERT INTO HyperPawnData.dbo.ItemFirearm   ( ItemId, BarrelLength)
                      VALUES            (@ItemId, @BarrelLength)
              SET @ItemDetailInsertCount = @@rowcount
              
              EXEC FirearmAddLogEntry
                @FirearmLogReferenceId = @FirearmLogReferenceId OUT,
                @EmployeeId     = @EmployeeId,
                @Make           = @Make,
                @Model          = @Model,
                @Serial         = @SerialNumber,
                @Type           = @Action,
                @Caliber        = @Caliber,
                @ReceiptDate    = @ReceiptDate,
                @ReceiptName    = @ReceiptName,
                @ReceiptAddress = @ReceiptAddress
                   
            END
          IF @ItemDetailInsertCount <> 1
            RAISERROR('Item Detail Not Inserted!',11,1)
        END

      -- Update existing Item
      IF @OrigItemId <> 0 AND @ItemTableId = 2
        UPDATE HyperPawnData.dbo.ItemSerial
        SET    Make = @Make,  Model = @Model,  SerialNumber = @SerialNumber
        WHERE  ItemId = @ItemId
        
      IF @OrigItemId <> 0 AND @ItemTableId = 3 -- returning gun
        BEGIN
          UPDATE HyperPawnData.dbo.ItemFirearm
          SET    BarrelLength = @BarrelLength
          WHERE  ItemId = @ItemId
          
          IF @GunLogNumber = 0
            EXEC FirearmAddLogEntry
                @FirearmLogReferenceId = @FirearmLogReferenceId OUT,
                @EmployeeId     = @EmployeeId,
                @Make           = @Make,
                @Model          = @Model,
                @Serial         = @SerialNumber,
                @Type           = @Action,
                @Caliber        = @Caliber,
                @ReceiptDate    = @ReceiptDate,
                @ReceiptName    = @ReceiptName,
                @ReceiptAddress = @ReceiptAddress
        END

      UPDATE HyperPawnData.dbo.PurchaseItem
      SET Modified              = SYSDATETIME(),
          ModifiedBy            = @EmployeeId,
          Amount                = @Amount,
          ItemDescription       = @ItemDescription--,
          --ItemDisplayOrder = @DisplayOrder
      WHERE PurchaseId = @PurchaseId AND ItemId = @ItemId
      SELECT @rowcount = @@rowcount
      
      
      -- new item
      IF @rowcount = 0
        INSERT INTO HyperPawnData.dbo.PurchaseItem (CreatedBy,   ModifiedBy,  PurchaseId,   ItemId,  Amount,  ItemDescription,  FirearmLogReferenceId)--, ItemDisplayOrder)
          VALUES                                   (@EmployeeId, @EmployeeId, @PurchaseId, @ItemId, @Amount, @ItemDescription, @FirearmLogReferenceId)--, @DisplayOrder)
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK TRANSACTION;
    SET @msg = 'PawnItemInsert Error:' + ERROR_MESSAGE()
    RAISERROR(@msg,11,1)
    RETURN 1 -- Failure
  END CATCH
  IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;
  RETURN 0 -- Success
GO



IF OBJECT_ID('PurchaseSave') IS NOT NULL
  DROP PROC PurchaseSave
GO

CREATE PROC PurchaseSave
@PurchaseId          INT OUT,
@PurchaseDate        datetime,
@EmployeeId      SMALLINT,
@CustomerId      INT,
@Location        NVARCHAR(30)  = NULL,
@ItemsXml        XML
WITH ENCRYPTION
AS
  SET NOCOUNT ON
  DECLARE @msg VARCHAR(255)
  DECLARE @rc INT
 
  BEGIN TRY
    BEGIN TRANSACTION
      
      IF (@PurchaseId IS NULL)
        BEGIN
          EXEC PurchaseAssign @EmployeeId, @CustomerId, @PurchaseId OUT
        END
      ELSE
        BEGIN
          UPDATE HyperPawnData.dbo.Purchase
            SET Modified         = GETDATE(),
                ModifiedBy       = @EmployeeId,
                PurchaseDate     = @PurchaseDate,
                CustomerId       = @CustomerId,
                Location         = @Location
          WHERE PurchaseId = @PurchaseId
          SELECT @rc = @@rowcount
          IF @rc = 0
            INSERT INTO HyperPawnData.dbo.Purchase
                   ( PurchaseId,   CreatedBy,  ModifiedBy,  PurchaseDate,  CustomerId,  Location)
            VALUES (@PurchaseId, @EmployeeId, @EmployeeId, @PurchaseDate, @CustomerId, @Location)
          ELSE
            DELETE    p
            FROM      HyperPawnData.dbo.PurchaseItem p
            LEFT JOIN @ItemsXml.nodes('ArrayOfItem/Item') itm(i) ON p.ItemId = i.value('@ItemId','INT')
            WHERE     p.PurchaseId = @PurchaseId AND i.value('@ItemId','INT') IS NULL
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
        RAISERROR('Purchases must have at least one item!',11,1)

    WHILE @@FETCH_STATUS = 0
    BEGIN

      EXEC @rc = PurchaseItemInsert
        @PurchaseId  = @PurchaseId,
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
        RAISERROR('Purchase Item Not Inserted!',11,1)
        
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
    SET @Msg = 'PurchaseSave Error: ' + ERROR_MESSAGE()
    RAISERROR(@msg,11,1) WITH NOWAIT
    RETURN 1 -- Failure
  END CATCH
  IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;
  RETURN 0 -- Success
GO


IF OBJECT_ID('PurchaseGetDetails') IS NOT NULL
  DROP PROC PurchaseGetDetails
GO
CREATE PROCEDURE PurchaseGetDetails
@PurchaseId int
WITH ENCRYPTION
AS
set nocount on
-- Get Purchase
SELECT   L.PurchaseId      PurchaseId,
         L.Created,
         L.CreatedBy, 
         L.Modified, 
         L.ModifiedBy, 
         L.PurchaseDate PurchaseDate, 
         L.CustomerId,
         L.Location,
         SUM(LI.Amount) Amount
FROM     HyperPawnData.dbo.Purchase     L
JOIN     HyperPawnData.dbo.PurchaseItem LI ON LI.PurchaseId = L.PurchaseId
WHERE    L.PurchaseId = @PurchaseId
GROUP BY L.PurchaseId,
         L.Created,
         L.CreatedBy, 
         L.Modified, 
         L.ModifiedBy, 
         L.PurchaseDate, 
         L.CustomerId,
         L.Location

-- Get Items
SELECT I.ItemId,
       I.ItemTypeId,
       I.ItemSubTypeId,
       U.ItemTableId,
       
       --LI.ItemDisplayOrder DisplayOrder,
       LI.Amount,
       LI.ItemDescription Description,
       LI.FirearmLogReferenceId,
       
       COALESCE(                   S.Make,            G.Make           ) Make,
       COALESCE(                   S.Model,           G.Model          ) Model,
       COALESCE(                   S.SerialNumber,    G.SerialNumber   ) Serial,
       
       G.Caliber,
       G.Action,
       F.BarrelLength Barrel
FROM      HyperPawnData.dbo.Purchase     L
JOIN      HyperPawnData.dbo.PurchaseItem LI ON LI.PurchaseId = L.PurchaseId
JOIN      HyperPawnData.dbo.Item             I  ON LI.ItemId = I.ItemId
JOIN      HyperPawnData.dbo.ItemSubType      U  ON I.ItemSubTypeId = U.ItemSubTypeId AND I.ItemTypeId = U.ItemTypeId
LEFT JOIN HyperPawnData.dbo.ItemNonSerial    N  ON LI.ItemId = N.ItemId
LEFT JOIN HyperPawnData.dbo.ItemSerial       S  ON LI.ItemId = S.ItemId
LEFT JOIN HyperPawnData.dbo.ItemFirearm      F  ON LI.ItemId = F.ItemId
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
WHERE     L.PurchaseId = @PurchaseId
GO

-- PurchaseGet 1223

IF OBJECT_ID('PurchaseGet') IS NOT NULL
  DROP PROC PurchaseGet
GO
CREATE PROCEDURE PurchaseGet
@PartyId INT,
@Top INT,
@ShowAll BIT
WITH ENCRYPTION
AS
  SET NOCOUNT ON
  SELECT TOP (@Top)
            L.PurchaseId PurchaseId,
            L.PurchaseDate PurchaseDate, 
            C.IDNumber,
            dbo.FnItemDescriptionTicket(L.PurchaseId) ItemDescriptionTicket,
            SUM(LI.Amount) Amount,
            SUM(CASE WHEN I.ItemTypeId = 2 THEN 1 ELSE 0 END) NumberOfFirearms,
            L.Location,
            L.CustomerId PartyId,
            L.Modified
  FROM      HyperPawnData.dbo.Purchase     L
  JOIN      HyperPawnData.dbo.Party C  ON L.CustomerId      = C.PartyId
  JOIN      HyperPawnData.dbo.PurchaseItem LI ON LI.PurchaseId = L.PurchaseId
  JOIN      HyperPawnData.dbo.Item             I  ON LI.ItemId         = I.ItemId
  WHERE         L.CustomerId   = CASE WHEN @PartyId = 0 THEN L.CustomerId   ELSE @PartyId END
  GROUP BY  L.PurchaseId,
            L.PurchaseDate, 
            C.IDNumber,
            L.Location,
            L.CustomerId,
            L.Modified
  ORDER BY  L.Modified DESC, L.PurchaseId DESC
GO



IF OBJECT_ID('PurchaseGetTicket') IS NOT NULL
  DROP PROC PurchaseGetTicket
GO

CREATE PROC PurchaseGetTicket
@PurchaseId INT
WITH ENCRYPTION
AS
SET NOCOUNT ON

DECLARE @StorageFee MONEY
SET @StorageFee = 3

DECLARE @GunFee MONEY
SET @GunFee = 3

SELECT   L.PurchaseId,
          L.CustomerId,
          L.PurchaseDate,
          C.Last + ', '+ C.First + ' '+ISNULL(C.Middle,'') CustName,
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
          dbo.FnPurchaseItemDescription(L.PurchaseId) FnPurchaseItemDescription,
          E.Initials EmployeeInitials,
          SUM(LI.Amount) Amount,
          SUM(CASE WHEN I.ItemTypeId = 2 THEN 1 ELSE 0 END) GunCount
 FROM     HyperPawnData.dbo.Purchase     L
 JOIN     HyperPawnData.dbo.Party        C  ON L.CustomerId = C.PartyId
 JOIN     HyperPawnData.dbo.PartyIdType  PT ON C.IdTypeId = PT.PartyIdTypeId
 JOIN     HyperPawnData.dbo.PurchaseItem LI ON LI.PurchaseId = L.PurchaseId
 JOIN     HyperPawnData.dbo.Item         I  ON LI.ItemId = I.ItemId
 JOIN     HyperPawnData.dbo.Employee     E  ON L.CreatedBy = E.EmployeeId
 WHERE    L.PurchaseId = @PurchaseId
 GROUP BY L.PurchaseId,
          L.CustomerId,
          L.PurchaseDate,
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
          C.Eyes
GO

/*
GetTicket
@LoanNumber = 1206
*/



IF OBJECT_ID('FnPurchaseItemDescription') IS NOT NULL
  DROP FUNCTION dbo.FnPurchaseItemDescription
GO

CREATE FUNCTION dbo.FnPurchaseItemDescription 
(
@PurchaseId INT
)
RETURNS VARCHAR(MAX)
WITH ENCRYPTION
AS
  BEGIN
    DECLARE @items VARCHAR(MAX)

    SET @items = ''

    SELECT @items = @items + 
                Y.ItemTypeName + ',' +
                U.ItemSubTypeName+
                ISNULL(' (#'+CAST(LI.FirearmLogReferenceId AS VARCHAR(20))+')','')+': '+
                CASE 
                  WHEN N.ItemId IS NOT NULL THEN ISNULL(LI.ItemDescription,'') 
                  WHEN S.ItemId IS NOT NULL THEN '' + S.Make + ' ' + S.Model + ' Serial:' + S.SerialNumber + ', ' + ISNULL(LI.ItemDescription,'')
                  WHEN F.ItemId IS NOT NULL THEN '' + G.Make + ' ' + G.Model + ' Serial:' + G.SerialNumber + 
                                                 ' Cal: ' + G.Caliber + ' Action: ' +G.Action + ' Length: ' + F.BarrelLength +
                                                 ', ' + ISNULL(LI.ItemDescription,'')
                END +
                CHAR(13)+CHAR(10)
      FROM      HyperPawnData.dbo.PurchaseItem LI
      JOIN      HyperPawnData.dbo.Item             I  ON LI.ItemId = I.ItemId
      JOIN      HyperPawnData.dbo.ItemType         Y  ON I.ItemTypeId = Y.ItemTypeId
      JOIN      HyperPawnData.dbo.ItemSubType      U  ON I.ItemSubTypeId = U.ItemSubTypeId AND I.ItemTypeId = U.ItemTypeId
      LEFT JOIN HyperPawnData.dbo.ItemNonSerial    N  ON LI.ItemId = N.ItemId
      LEFT JOIN HyperPawnData.dbo.ItemSerial       S  ON LI.ItemId = S.ItemId
      LEFT JOIN HyperPawnData.dbo.ItemFirearm      F  ON LI.ItemId = F.ItemId
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

      WHERE PurchaseId = @PurchaseId
      
      SET @items = LEFT(@items,LEN(@items)-2)

    RETURN @items
  END
GO


--purchasegetticket 1

