USE HyperPawn

IF OBJECT_ID('LeadsOnlineGet') IS NOT NULL
  DROP PROCEDURE LeadsOnlineGet
GO

CREATE PROCEDURE LeadsOnlineGet
--@StoreId   INT,
@StartDate DATETIME2,
@EndDate   DATETIME2
AS
  SET NOCOUNT ON
  DECLARE @xml XML

  DECLARE @Store TABLE(
    --StoreId          INT NOT NULL PRIMARY KEY CLUSTERED,
    CompanyName      NVARCHAR(100),
    StoreName        NVARCHAR(100),
    Address1         NVARCHAR(50),
    Address2         NVARCHAR(50),
    City             NVARCHAR(50),
    [State/Province] NVARCHAR(50),
    [Zip/PostalCode] NVARCHAR(30),
    Country          NVARCHAR(40),
    Phone            NVARCHAR(50),
    Fax              NVARCHAR(50),
    Email            NVARCHAR(80),
    Contact          NVARCHAR(50))

  INSERT INTO @Store
  SELECT
    CompanyName,
  StoreName,
  Address1,
  Address2,
  City,
  [State/Province],
  [Zip/PostalCode],
  Country,
  Phone,
  Fax,
  Email,
  Contact
  FROM HyperPawnData.dbo.Store
  WHERE StoreId = 1

  SET @xml =
    (SELECT 
    ( SELECT *
      FROM @Store
      FOR XML PATH('store_info'), TYPE),
     (SELECT O.*,
     (
     SELECT *
     FROM (
     SELECT 
          '2'            ticket_type, 
          LI.FirstPawnId ticket_number,
          I.ItemId           'article_number',
          CASE
            WHEN I.ItemTypeId = 2 THEN 'Cal:' + G.Caliber + ', Action:' + G.Action + ', Barrel:' + F.BarrelLength + ', ' + ISNULL(LI.ItemDescription,'')
            ELSE                  LI.ItemDescription
          END                'description', 
          LI.Amount          'amount',
          COALESCE(S.Make,         G.Make)         'make',
          COALESCE(S.Model,        G.Model)        'model',
          COALESCE(S.SerialNumber, G.SerialNumber) 'serial_number',
          'pawn'             'status',
          CASE 
            WHEN I.ItemTypeId = 2 THEN 2 -- Firearm
            WHEN I.ItemTypeId = 1 THEN 1 -- Jewelry
            ELSE                       0 -- Other
          END  'article_type'
        FROM      HyperPawnData.dbo.PawnItem LI
        JOIN      HyperPawnData.dbo.Item I ON LI.ItemId = I.ItemId
        LEFT JOIN HyperPawnData.dbo.ItemNonSerial N ON I.ItemId = N.ItemId
        LEFT JOIN HyperPawnData.dbo.ItemSerial    S ON I.ItemId = S.ItemId
        LEFT JOIN HyperPawnData.dbo.ItemFirearm   F ON I.ItemId = F.ItemId
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
      UNION ALL
      SELECT 
          '1'           ticket_type, 
          LI.PurchaseId ticket_number,
          I.ItemId           'article_number',
          CASE
            WHEN I.ItemTypeId = 2 THEN 'Cal:' + G.Caliber + ', Action:' + G.Action + ', Barrel:' + F.BarrelLength + ', ' + ISNULL(LI.ItemDescription,'')
            ELSE                  LI.ItemDescription
          END                'description', 
          LI.Amount          'amount',
          COALESCE(S.Make,         G.Make)         'make',
          COALESCE(S.Model,        G.Model)        'model',
          COALESCE(S.SerialNumber, G.SerialNumber) 'serial_number',
          'pawn'             'status',
          CASE 
            WHEN I.ItemTypeId = 2 THEN 2 -- Firearm
            WHEN I.ItemTypeId = 1 THEN 1 -- Jewelry
            ELSE                       0 -- Other
          END  'article_type'
        FROM      HyperPawnData.dbo.PurchaseItem LI
        JOIN      HyperPawnData.dbo.Item I ON LI.ItemId = I.ItemId
        LEFT JOIN HyperPawnData.dbo.ItemNonSerial N ON I.ItemId = N.ItemId
        LEFT JOIN HyperPawnData.dbo.ItemSerial    S ON I.ItemId = S.ItemId
        LEFT JOIN HyperPawnData.dbo.ItemFirearm   F ON I.ItemId = F.ItemId
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
        )I2           
        WHERE I2.ticket_type = O.ticket_type AND I2.ticket_number = O.ticket_number
        FOR XML PATH ('article'), TYPE
       ) 'articles'
     FROM 
     (SELECT
      '2'            ticket_type, 
      /*
      0 = Unknown
      1 = Buy
      2 = Pawn
      3 = Trade
      4 = Check Cashed
      */
      PawnId        ticket_number , 
      PawnDate      enter_date, 
      e.Initials    employee, 
      DATEADD(day,90,PawnDate) redeem_by,
      --''            'owner/name', 
      C.First       'owner/fname', 
      C.Last        'owner/lname',
      C.Street      'owner/address1', 
      --''            'owner/address2', 
      C.City 'owner/city', 
      C.State 'owner/state', 
      C.Zip 'owner/postal_code', 
      --'' 'owner/phone', 
      'WADL' 'owner/id_type', 
      C.IdNumber 'owner/id_number', 
      --'' 'owner/id_type2', 
      --'' 'owner/id_number2',
      C.DateOfBirth 'owner/dob',
      C.Weight 'owner/weight',
      C.Height 'owner/height',
      C.Eyes 'owner/eye_color',
      C.Hair 'owner/hair_color',
      C.Race 'owner/race',
      C.Sex 'owner/sex'
      FROM   HyperPawnData.dbo.Pawn     P
      JOIN   HyperPawnData.dbo.Party    C ON P.CustomerId = C.PartyId
      JOIN   HyperPawnData.dbo.Employee E ON P.createdBy = E.employeeId
      WHERE  P.PawnDate >= @StartDate AND P.PawnDate < DATEADD(DAY,1,@EndDate) AND P.PawnId = P.FirstPawnId
      UNION ALL
      SELECT '1'            ticket_type, 
      /*
      0 = Unknown
      1 = Buy
      2 = Pawn
      3 = Trade
      4 = Check Cashed
      */
      PurchaseId        ticket_number , 
      PurchaseDate      enter_date, 
      e.Initials    employee, 
      ''            redeem_by,
      --''            'owner/name', 
      C.First       'owner/fname', 
      C.Last        'owner/lname',
      C.Street      'owner/address1', 
      --''            'owner/address2', 
      C.City 'owner/city', 
      C.State 'owner/state', 
      C.Zip 'owner/postal_code', 
      --'' 'owner/phone', 
      'WADL' 'owner/id_type', 
      C.IdNumber 'owner/id_number', 
      --'' 'owner/id_type2', 
      --'' 'owner/id_number2',
      C.DateOfBirth 'owner/dob',
      C.Weight 'owner/weight',
      C.Height 'owner/height',
      C.Eyes 'owner/eye_color',
      C.Hair 'owner/hair_color',
      C.Race 'owner/race',
      C.Sex 'owner/sex'
      FROM   HyperPawnData.dbo.Purchase     P
      JOIN   HyperPawnData.dbo.Party    C ON P.CustomerId = C.PartyId
      JOIN   HyperPawnData.dbo.Employee E ON P.createdBy = E.employeeId
      WHERE  P.PurchaseDate >= @StartDate AND P.PurchaseDate < DATEADD(DAY,1,@EndDate)
      ) O
      ORDER BY ticket_type, ticket_number
      FOR XML PATH ('ticket'), root ('tickets'),TYPE)
    FOR XML PATH('root')
  )
SELECT @xml
GO

/*
EXEC LeadsOnlineGet '2009-03-16','3/16/2009'
*/