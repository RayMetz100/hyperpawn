use HyperPawn
go
IF OBJECT_ID('PawnItemInsert') IS NOT NULL
  DROP PROC PawnItemInsert
GO

CREATE PROC PawnItemInsert
  @PawnId          INT,
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
    
      IF @ItemId = 0 --new item
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
        
      UPDATE HyperPawnData.dbo.PawnItem
      SET Modified              = SYSDATETIME(),
          ModifiedBy            = @EmployeeId,
          Amount                = @Amount,
          ItemDescription       = @ItemDescription--,
          --ItemDisplayOrder = @DisplayOrder
      WHERE FirstPawnId = @PawnId AND ItemId = @ItemId
      SELECT @rowcount = @@rowcount
      
      
      -- new item
      IF @rowcount = 0 
        INSERT INTO HyperPawnData.dbo.PawnItem     (CreatedBy,   ModifiedBy,  FirstPawnId,  ItemId,  Amount,  ItemDescription,  FirearmLogReferenceId)--, ItemDisplayOrder)
          VALUES                                   (@EmployeeId, @EmployeeId, @PawnId,     @ItemId, @Amount, @ItemDescription, @FirearmLogReferenceId)--,    @DisplayOrder)
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

/*

      UPDATE PawnItem
      SET ModifiedBy       = 0,
          Amount           = 10,
          ItemDescription  = 'lkjhl',
          GunLogNumber     = null--,
          --ItemDisplayOrder = @DisplayOrder
      WHERE PawnId = 1397741 AND ItemId = 79436

DECLARE @RC INT
EXEC @RC = PawnItemInsert
@PawnId     = 139774,
@ItemId = 79436,
@EmployeeId = 1,
@ItemTypeId = 6,
@ItemSubTypeId = 0,
--@DisplayOrder = 0,
@Amount = 10,
@ItemDescription = 'sadfa'
PRINT @RC
*/

--IF OBJECT_ID('FnItemDescriptionTicket') IS NOT NULL
--  DROP FUNCTION dbo.FnItemDescriptionTicket
--GO

--CREATE FUNCTION dbo.FnItemDescriptionTicket
--(
--@PawnId INT
--)
--RETURNS VARCHAR(MAX)
--AS
--  BEGIN
--    DECLARE @items VARCHAR(MAX)

--    SET @items = ''

--    SELECT @items = @items + 
--                Y.ItemTypeName + ',' +
--                U.ItemSubTypeName+': '+
--                CASE 
--                  WHEN N.ItemId IS NOT NULL THEN ISNULL(LI.ItemDescription,'') 
--                  WHEN S.ItemId IS NOT NULL THEN '' + S.Make + ' ' + S.Model + ' Serial:' + S.SerialNumber + ', ' + ISNULL(LI.ItemDescription,'')
--                  WHEN F.ItemId IS NOT NULL THEN '' + F.Make + ' ' + F.Model + ' Serial:' + F.SerialNumber + 
--                                                 ' Cal: ' + F.Caliber + ' Action: ' +F.Action + ' Length: ' + F.BarrelLength +
--                                                 ', ' + ISNULL(LI.ItemDescription,'')
--                END +
--                CHAR(13)+CHAR(10)
--      FROM      HyperPawnData.dbo.PawnItem LI
--      JOIN      HyperPawnData.dbo.Item             I  ON LI.ItemId = I.ItemId
--      JOIN      HyperPawnData.dbo.ItemType         Y  ON I.ItemTypeId = Y.ItemTypeId
--      JOIN      HyperPawnData.dbo.ItemSubType      U  ON I.ItemSubTypeId = U.ItemSubTypeId AND I.ItemTypeId = U.ItemTypeId
--      LEFT JOIN HyperPawnData.dbo.ItemNonSerial    N  ON LI.ItemId = N.ItemId
--      LEFT JOIN HyperPawnData.dbo.ItemSerial       S  ON LI.ItemId = S.ItemId
--      LEFT JOIN HyperPawnData.dbo.ItemFirearm      F  ON LI.ItemId = F.ItemId

--      WHERE PawnId = @PawnId
      
--      SET @items = LEFT(@items,LEN(@items)-2)

--    RETURN @items
--  END
--GO

IF OBJECT_ID('FnItemDescriptionTicket') IS NOT NULL
  DROP FUNCTION dbo.FnItemDescriptionTicket
GO

CREATE FUNCTION dbo.FnItemDescriptionTicket
(
@PawnId INT
)
RETURNS VARCHAR(MAX)
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
                  WHEN F.ItemId IS NOT NULL THEN '' + L.Make + ' ' + L.Model + ' Serial:' + L.SerialNumber + 
                                                 ' Cal: ' + L.Caliber + ' Action: ' +L.Action + ' Length: ' + F.BarrelLength +
                                                 ', ' + ISNULL(LI.ItemDescription,'')
                END +
                CHAR(13)+CHAR(10)
      FROM      HyperPawnData.dbo.PawnItem LI
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
                 )                                 L  ON E.MaxId = L.Id
      WHERE LI.FirstPawnId = @PawnId
      
      SET @items = LEFT(@items,LEN(@items)-2)

    RETURN @items
  END
GO

--select dbo.FnItemDescriptionPolice(1206)


IF OBJECT_ID('TaxyGetItemSubTypes') IS NOT NULL
  DROP PROC TaxyGetItemSubTypes
GO

CREATE PROC TaxyGetItemSubTypes
AS
SELECT ItemTypeId, ItemSubTypeId, DisplayOrder, ItemSubTypeName, ItemTableId
FROM   HyperPawnData.dbo.ItemSubType
GO

IF OBJECT_ID('TaxyGetItemTypes') IS NOT NULL
  DROP PROC TaxyGetItemTypes
GO

CREATE PROC TaxyGetItemTypes
AS
SELECT ItemTypeId, DisplayOrder, ItemTypeName
FROM   HyperPawnData.dbo.ItemType
ORDER BY DisplayOrder
GO

IF OBJECT_ID('PartyGetItems') IS NOT NULL
  DROP PROC PartyGetItems
GO

CREATE PROCEDURE PartyGetItems -- PartyGetItems 24
@PartyId INT
AS
SELECT
  I.ItemId, --P.CustomerId,
  I.ItemTypeId,
  I.ItemSubTypeId,
  U.ItemTableId,
  LI.Amount,
  LI.ItemDescription,
  ISNULL(S.Make,        L.Make)         Make,
  ISNULL(S.Model,       L.Model)        Model,
  ISNULL(S.SerialNumber,L.SerialNumber) SerialNumber,
  L.Caliber,
  L.Action,
  F.BarrelLength,
  MAX(P.PawnDate) MaxPawnDate
FROM      HyperPawnData.dbo.Pawn          P
JOIN      HyperPawnData.dbo.PawnItem      LI ON LI.FirstPawnId = P.FirstPawnId
JOIN      HyperPawnData.dbo.Item          I  ON LI.ItemId = I.ItemId
JOIN      HyperPawnData.dbo.ItemType      Y  ON I.ItemTypeId = Y.ItemTypeId
JOIN      HyperPawnData.dbo.ItemSubType   U  ON I.ItemSubTypeId = U.ItemSubTypeId AND I.ItemTypeId = U.ItemTypeId
LEFT JOIN HyperPawnData.dbo.ItemNonSerial N  ON LI.ItemId = N.ItemId
LEFT JOIN HyperPawnData.dbo.ItemSerial    S  ON LI.ItemId = S.ItemId
LEFT JOIN HyperPawnData.dbo.ItemFirearm   F  ON LI.ItemId = F.ItemId
      LEFT JOIN (SELECT D.FirearmLogReferenceId,
                 D.[manufacturer and importer] Make,
                 D.[model]                     Model,
                 D.[serial number]             SerialNumber,
                 D.[type]                      Action,
                 D.[caliber or guage]          Caliber
                 FROM   HyperPawnData.dbo.FirearmsAcquisitionAndDispositionEntry D
                 JOIN   (SELECT FirearmLogReferenceId, MAX(Id) MaxId
                         FROM HyperPawnData.dbo.FirearmsAcquisitionAndDispositionEntry
                         GROUP BY FirearmLogReferenceId
                         ) M ON D.FirearmLogReferenceId = M.FirearmLogReferenceId AND D.Id = M.MaxId
                 ) L ON LI.FirearmLogReferenceId = L.FirearmLogReferenceId
WHERE     P.PawnStatusId = 'P' -- Redeemed
      AND P.CustomerId = @PartyId
GROUP BY I.ItemId, --P.CustomerId,
  I.ItemTypeId,
  I.ItemSubTypeId,
  U.ItemTableId,
  LI.ItemDescription,
  LI.Amount,
  ISNULL(S.Make,        L.Make),
  ISNULL(S.Model,       L.Model),
  ISNULL(S.SerialNumber,L.SerialNumber),
  L.Caliber,
  L.Action,
  F.BarrelLength
ORDER BY MAX(P.PawnId) DESC
GO



-- partygetitems 24
