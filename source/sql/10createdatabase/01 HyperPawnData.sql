use master
go
if exists(select 1 from sys.databases where name = 'HyperPawnData')
  drop database HyperPawnData

CREATE DATABASE [HyperPawnData] ON  PRIMARY 
( NAME = N'HyperPawnData',     FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\HyperPawnData.mdf'     , 
  SIZE = 50MB , MAXSIZE = 1GB , FILEGROWTH = 10MB )
 LOG ON 
( NAME = N'HyperPawnData_log', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\HyperPawnData_log.ldf' , 
  SIZE = 25MB , MAXSIZE = 1GB , FILEGROWTH = 5MB  )
GO


use HyperPawnData
GO

--CREATE TABLE Parameter (
--  ParameterId
--  Name  
--  Value 

CREATE TABLE Store (
  StoreId          INT NOT NULL CONSTRAINT PK_Store PRIMARY KEY CLUSTERED,
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
  
  INSERT INTO Store
SELECT 1 store_id,
      'Jerry'' Jewelry and Loan' company_name,
      'Jerry'' Jewelry and Loan' name,
      '19811 Highway 99' address1,
      '' address2,
      'Lynnwood' city,
      'Washington' state,
      '98036' postal_code,
      'USA' county,
      '425-776-6003' phone,
      '' fax,
      'RayMetz100@hotmail.com' email,
      'Ray Metz' contact_name
      
/*
drop table CustomerOrVendor
drop table CustomerOrVendorIdType
drop table Employee
*/
if object_id('Employee') is null
create table Employee (
  EmployeeId smallint     not null identity(1,1) CONSTRAINT PK_Employee primary key clustered,
  Initials   CHAR(3)      not null,
  Last       nvarchar(40) not null,
  First      nvarchar(40) null,
  Middle     nvarchar(40) null,
  Inactive   BIT          NOT NULL,
  CONSTRAINT UK_Employee_Initials UNIQUE (Initials)
  )



if object_id('PartyIdType') is null
create table PartyIdType (
  PartyIdTypeId tinyint not null identity(1,1) CONSTRAINT PK_PartyIdType primary key clustered,
  Name nvarchar(100) not null,
  [Description] nvarchar(max),
  CONSTRAINT UK_PartyIdType_Name UNIQUE (Name)
  )
insert PartyIdType (Name, Description)
                     values ('State', null),
                            ('SS', null)


if object_id('Party') is null
create table Party (
  PartyId int not null identity(1,1) CONSTRAINT PK_Party primary key clustered,
  Created      datetime2      not null CONSTRAINT DF_Party_Created default(SYSDATETIME()),
  CreatedBy    smallint      not null CONSTRAINT FK_Party_CreatedBy foreign key references Employee(EmployeeId),
  Modified     datetime2      not null CONSTRAINT DF_Party_Modified default(SYSDATETIME()),
  ModifiedBy   smallint      not null CONSTRAINT FK_Party_ModifiedBy foreign key references Employee(EmployeeId),
  IntegrationBatch nvarchar(20) null,
  IntegrationId    nvarchar(20) null,
  IdTypeId     tinyint       not null CONSTRAINT FK_Party_IdTypeId foreign key references PartyIdType(PartyIdTypeId),
  IdState      CHAR(2)       null,
  IdIssued     datetime2      null,
  IdExpiration datetime2      null,
  IdNumber     nvarchar(30)  not null,
  DateOfBirth  datetime2      null,
  Last         nvarchar(40)  not null,
  First        nvarchar(40)  null,
  Middle       nvarchar(40)  null,
  Street       nvarchar(60)  not null,
  City         nvarchar(40)  not null,
  State        char(2)       not null,
  Zip          varchar(10)   not null,
  Sex          varchar(1)    null,
  Eyes         varchar(3)    null,
  Weight       varchar(3)    null,
  Height       nvarchar(5)   null,
  Race         nvarchar(5)    null,
  Hair         varchar(5)    null,
  Phone        varchar(15)   null,
  Email        nvarchar(40)  null,
  Note         nvarchar(max) null,
  CONSTRAINT UK_Party_IdNumber UNIQUE (IdNumber, IdTypeId, IdState),
--  CONSTRAINT UK_Party_Integration UNIQUE (IntegrationBatch, IntegrationId),
  )
go
/*
DROP TABLE ItemNonSerial
--DROP TABLE PawnPurchaseItem
DROP TABLE PawnPurchaseItem
DROP TABLE Item
DROP TABLE ItemType
DROP TABLE PawnPurchase
*/

CREATE TABLE Purchase(
  PurchaseId          INT           NOT NULL CONSTRAINT PK_Purchase            PRIMARY KEY CLUSTERED,
  Created             datetime2     NOT NULL CONSTRAINT DF_Purchase_Created    DEFAULT                (SYSDATETIME()),
  CreatedBy           smallint      NOT NULL CONSTRAINT FK_Purchase_CreatedBy  FOREIGN KEY REFERENCES Employee(EmployeeId),
  Modified            datetime2     NOT NULL CONSTRAINT DF_Purchase_Modified   DEFAULT                (SYSDATETIME()),
  ModifiedBy          smallint      NOT NULL CONSTRAINT FK_Purchase_ModifiedBy FOREIGN KEY REFERENCES Employee(EmployeeId),
  PurchaseDate        datetime2     NOT NULL,
  CustomerId          int           NOT NULL CONSTRAINT FK_Purchase_PartyId FOREIGN KEY REFERENCES Party(PartyId),
  Location            nvarchar(30)  NULL,
  )

CREATE TABLE PawnStatus(
PawnStatusId CHAR(1) NOT NULL CONSTRAINT PK_PawnStatus PRIMARY KEY CLUSTERED,
PawnStatus   VARCHAR(20) NOT NULL,
)
INSERT INTO PawnStatus VALUES('A','Active'),
                             ('P','Picked Up'),
                             ('R','Renewed'),
                             ('F','Floored'),
                             ('V','Void')                       
              
CREATE TABLE Pawn(
  PawnId              INT           NOT NULL CONSTRAINT PK_Pawn                    PRIMARY KEY CLUSTERED,
  PawnDate            datetime2     NOT NULL,
  FirstPawnId         INT           NOT NULL CONSTRAINT FK_PawnId                  FOREIGN KEY REFERENCES Pawn(PawnId),
  Created             datetime2     NOT NULL CONSTRAINT DF_Pawn_Created            DEFAULT                (SYSDATETIME()),
  CreatedBy           smallint      NOT NULL CONSTRAINT FK_Pawn_CreatedBy          FOREIGN KEY REFERENCES Employee(EmployeeId),
  Modified            datetime2     NOT NULL CONSTRAINT DF_Pawn_Modified           DEFAULT                (SYSDATETIME()),
  ModifiedBy          smallint      NOT NULL CONSTRAINT FK_Pawn_ModifiedBy         FOREIGN KEY REFERENCES Employee(EmployeeId),
  CustomerId          INT           NOT NULL CONSTRAINT FK_Pawn_PartyId            FOREIGN KEY REFERENCES Party(PartyId),
  PawnStatusId        CHAR(1)       NOT NULL CONSTRAINT FK_Pawn_PawnStatusId       FOREIGN KEY REFERENCES PawnStatus(PawnStatusId),
  PawnStatusDate      datetime2     NOT NULL,
  PawnStatusEmployee  smallint      NOT NULL CONSTRAINT FK_Pawn_PawnStatusEmployee FOREIGN KEY REFERENCES Employee(EmployeeId),
  Location            nvarchar(45)  NULL,
  InterestReceived    MONEY         NULL,
  Note                nvarchar(max) NULL,
  )
--greatly increases PartySearch proc performance.
CREATE NONCLUSTERED INDEX IX_PAWN_STATUS ON PAWN (CustomerId) INCLUDE (PawnStatusId)

CREATE TABLE FirearmLogReference (
  FirearmLogReferenceId                   INT          NOT NULL CONSTRAINT PK_FirearmLogReference PRIMARY KEY CLUSTERED,
  AlternateNumber                         INT          NULL ,
  AlternateText                           NVARCHAR(50) NULL ,
  )

CREATE TABLE FirearmsAcquisitionAndDispositionEntry (
  Id                                      INT           NOT NULL IDENTITY(1,1) CONSTRAINT PK_FirearmsAcquisitionAndDispositionEntry           PRIMARY KEY CLUSTERED,
  CreatedOn                               DATETIME2     NOT NULL CONSTRAINT DF_FirearmsAcquisitionAndDispositionRecord_CreatedOn              default(SYSDATETIME()),
  CreatedBy                               SMALLINT      NOT NULL CONSTRAINT FK_FirearmsAcquisitionAndDispositionRecord_CreatedBy              foreign key references Employee(EmployeeId),
  FirearmLogReferenceId                   INT           NOT NULL CONSTRAINT FK_FirearmsAcquisitionAndDispositionRecord_FirearmLogReferenceId  FOREIGN KEY REFERENCES FirearmLogReference(FirearmLogReferenceId),
  
  [manufacturer and importer]             NVARCHAR(50)  NOT NULL,
  [model]                                 NVARCHAR(50)  NOT NULL,
  [serial number]                         NVARCHAR(50)  NOT NULL,
  [type]                                  NVARCHAR(30)  NOT NULL,
  [caliber or guage]                      NVARCHAR(30)  NOT NULL,
  
  [Receipt date]                          DATETIME2     NOT NULL,
  [Receipt name]                          NVARCHAR(200) NOT NULL,
  [Receipt address or license number]     NVARCHAR(200) NOT NULL,
  
  [Disposition date of sale or other]     DATETIME2     NULL,
  [Disposition name]                      NVARCHAR(200) NULL,
  [Disposition address or license number] NVARCHAR(200) NULL,
  )
--DROP INDEX FirearmsAcquisitionAndDispositionEntry.IX_FirearmsAcquisitionAndDispositionEntry_FirearmLogReferenceId
CREATE INDEX IX_FirearmsAcquisitionAndDispositionEntry_FirearmLogReferenceId ON FirearmsAcquisitionAndDispositionEntry (FirearmLogReferenceId)


CREATE TABLE ItemType(
ItemTypeId   TINYINT       NOT NULL CONSTRAINT PK_ItemType PRIMARY KEY CLUSTERED,
ItemTypeName NVARCHAR(30)  NOT NULL,
DisplayOrder TINYINT       NOT NULL,
CONSTRAINT UK_ItemType_ItemTypeName UNIQUE (ItemTypeName),
CONSTRAINT UK_ItemType_DisplayOrder UNIQUE (DisplayOrder),
)
INSERT INTO ItemType VALUES (1,'Jewelry',   10),
                            (2,'Firearm',   20),
                            (3,'Tool'   ,   30),
                            (4,'Electronic',40),
                            (5,'Music',     50),
                            (6,'Game',      60),
                            (7,'Sporting',  70),
                            (8,'Other',     80),
                            (9,'Native',    90)
                            
CREATE TABLE ItemTable(
ItemTableId   TINYINT      NOT NULL CONSTRAINT PK_ItemTable PRIMARY KEY CLUSTERED,
ItemTableName NVARCHAR(30) NOT NULL,
CONSTRAINT UK_ItemTable_ItemTableName UNIQUE (ItemTableName)
)
INSERT INTO ItemTable VALUES(1,'ItemNonSerial'),
                            (2,'ItemSerial'),
                            (3,'ItemFirearm')

CREATE TABLE ItemSubType(
ItemTypeId      TINYINT      NOT NULL CONSTRAINT FK_ItemSubType_ItemTypeId FOREIGN KEY REFERENCES ItemType (ItemTypeId),
ItemSubTypeId   TINYINT      NOT NULL,
ItemTableId     TINYINT      NOT NULL CONSTRAINT FK_ItemSubType_ItemTableId FOREIGN KEY REFERENCES ItemTable(ItemTableId),
ItemSubTypeName NVARCHAR(20) NOT NULL,
DisplayOrder    TINYINT      NOT NULL,
CONSTRAINT PK_ItemSubType  PRIMARY KEY CLUSTERED(ItemTypeId,ItemSubTypeId),
CONSTRAINT UK_ItemSubType_ItemSubTypeName UNIQUE (ItemTypeId,ItemSubTypeName),
CONSTRAINT UK_ItemSubType_DisplayOrder    UNIQUE (ItemTypeId,DisplayOrder)
)
INSERT INTO ItemSubType VALUES
                              (1,0,1,'Misc'    , 0),
                              (1,1,1,'Ring'    , 10),
                              (1,2,1,'Necklace', 20),
                              (1,3,1,'Pendant' , 30),
                              
                              (2,0,3,'Other'  , 0),
                              (2,1,3,'Rifle'  , 10),
                              (2,2,3,'Shotgun', 20),
                              (2,3,3,'Handgun', 30),
                              
                              (3,0,1,'Other'     , 0),
                              (3,1,2,'Saw'       , 10),
                              (3,2,2,'Drill'     , 20),
                              (3,3,2,'Chopsaw'   , 30),
                              (3,4,2,'Compressor', 40),
                              (3,5,1,'Handtools' , 50),
                              (3,6,2,'Chainsaw'  , 60),
                              (3,7,2,'Generator' , 70),
                              
                              (4,0,1,'Other'     , 0),
                              (4,1,2,'TV'        , 10),
                              (4,2,2,'Stereo'    , 20),
                              (4,3,2,'Speakers'  , 30),
                              (4,4,2,'MP3 Player', 40),
                              (4,5,1,'DVDs'      , 50),
                              
                              (5,0,1,'Other'      , 0),
                              (5,1,2,'Acc Guitar' , 10),
                              (5,2,2,'Elec Guitar', 20),
                              (5,3,2,'Bass Guitar', 30),
                              (5,4,2,'Horn'       , 40),
                              (5,5,2,'Amp'        , 50),
                              (5,6,2,'Pedal'      , 60),
                              
                              (6,0,1,'Other'            ,0),
                              (6,1,1,'Game Disks'       ,10),
                              (6,2,2,'Video Game System',20),
                              
                              (7,0,1,'Other',0),
                              (7,1,1,'Small',10),
                              (7,2,1,'Large',20),
                              
                              (8,0,1,'Other',0),
                              
                              (9,0,1,'Other',0),
                              (9,1,1,'Drum',10),
                              (9,2,1,'Jacket',20),
                              (9,3,1,'Small',30),
                              (9,4,1,'Large',40)


CREATE TABLE Item(
  ItemId              INT           NOT NULL IDENTITY(1,1) CONSTRAINT PK_Item PRIMARY KEY CLUSTERED,
  Created             datetime2      not null CONSTRAINT DF_Item_Created default(SYSDATETIME()),
  CreatedBy           smallint      not null CONSTRAINT FK_Item_CreatedBy foreign key references Employee(EmployeeId),
  Modified            datetime2      not null CONSTRAINT DF_Item_Modified default(SYSDATETIME()),
  ModifiedBy          smallint      not null CONSTRAINT FK_Item_ModifiedBy foreign key references Employee(EmployeeId),
  ItemTypeId          TINYINT       NOT NULL,
  ItemSubTypeId       TINYINT       NOT NULL,
  CONSTRAINT FK_Item_ItemSubType FOREIGN KEY (ItemTypeId,ItemSubTypeId)  REFERENCES ItemSubType(ItemTypeId,ItemSubTypeId)
  )

CREATE TABLE PawnItem(
  FirstPawnId           INT           NOT NULL CONSTRAINT FK_PawnItem_PawnId FOREIGN KEY REFERENCES Pawn(PawnId),
  ItemId                INT           NOT NULL CONSTRAINT FK_PawnItem_ItemId FOREIGN KEY REFERENCES Item(ItemId),
  --ItemDisplayOrder    TINYINT       NOT NULL,
  Created               datetime2      not null CONSTRAINT DF_PawnItem_Created default(SYSDATETIME()),
  CreatedBy             smallint      not null CONSTRAINT FK_PawnItem_CreatedBy foreign key references Employee(EmployeeId),
  Modified              datetime2      not null CONSTRAINT DF_PawnItem_Modified default(SYSDATETIME()),
  ModifiedBy            smallint      not null CONSTRAINT FK_PawnItem_ModifiedBy foreign key references Employee(EmployeeId),
  ItemDescription       NVARCHAR(MAX) NULL,
  Amount                money         not null,
  FirearmLogReferenceId INT           NULL     CONSTRAINT FK_PawnItem_FirearmLogReferenceId FOREIGN KEY REFERENCES FirearmLogReference(FirearmLogReferenceId),
  CONSTRAINT PK_PawnItem PRIMARY KEY CLUSTERED (FirstPawnId,ItemId),
  --CONSTRAINT UK_PawnItem_ItemDisplayOrder UNIQUE (PawnId,ItemDisplayOrder)
  )

CREATE TABLE PurchaseItem(
  PurchaseId          INT           NOT NULL CONSTRAINT FK_PurchaseItem_PurchaseId FOREIGN KEY REFERENCES Purchase(PurchaseId),
  ItemId              INT           NOT NULL CONSTRAINT FK_PurchaseItem_ItemId FOREIGN KEY REFERENCES Item(ItemId),
  --ItemDisplayOrder    TINYINT       NOT NULL,
  Created             datetime2      not null CONSTRAINT DF_PurchaseItem_Created default(SYSDATETIME()),
  CreatedBy           smallint      not null CONSTRAINT FK_PurchaseItem_CreatedBy foreign key references Employee(EmployeeId),
  Modified            datetime2      not null CONSTRAINT DF_PurchaseItem_Modified default(SYSDATETIME()),
  ModifiedBy          smallint      not null CONSTRAINT FK_PurchaseItem_ModifiedBy foreign key references Employee(EmployeeId),
  ItemDescription     NVARCHAR(MAX) NULL,
  Amount              money         not null,
  FirearmLogReferenceId INT           NULL     CONSTRAINT FK_PurchaseItem_FirearmLogReferenceId FOREIGN KEY REFERENCES FirearmLogReference(FirearmLogReferenceId),
  CONSTRAINT PK_PurchaseItem PRIMARY KEY CLUSTERED (PurchaseId,ItemId),
  --CONSTRAINT UK_PurchaseItem_ItemDisplayOrder UNIQUE (PurchaseId,ItemDisplayOrder)
  )

CREATE TABLE ItemNonSerial(
ItemId          INT           NOT NULL CONSTRAINT PK_ItemNonSerial PRIMARY KEY CLUSTERED CONSTRAINT FK_ItemNonSerial_ItemId FOREIGN KEY REFERENCES Item(ItemId))

CREATE TABLE ItemSerial(
ItemId          INT           NOT NULL CONSTRAINT PK_ItemSerial PRIMARY KEY CLUSTERED CONSTRAINT FK_ItemSerial_ItemId FOREIGN KEY REFERENCES Item(ItemId),
Make            NVARCHAR(50)  NOT NULL,
Model           NVARCHAR(50)  NOT NULL,
SerialNumber    NVARCHAR(50)  NOT NULL)

CREATE TABLE ItemFirearm(
ItemId          INT           NOT NULL CONSTRAINT PK_ItemFirearm PRIMARY KEY CLUSTERED CONSTRAINT FK_ItemFirearm_ItemId FOREIGN KEY REFERENCES Item(ItemId),
BarrelLength    NVARCHAR(10)  NULL,
)

CREATE TABLE Account(
AccountId SMALLINT        NOT NULL IDENTITY(1,1) CONSTRAINT PK_Account PRIMARY KEY CLUSTERED,
AccountName NVARCHAR(100) NOT NULL CONSTRAINT UK_AccountName UNIQUE,
)

INSERT INTO Account (AccountName)
VALUES ('Cash'),('CreditCard')

CREATE TABLE AccountTransactionTaxCategory(
AccountTransactionTaxCategoryId   SMALLINT       NOT NULL IDENTITY(1,1) CONSTRAINT PK_AccountTransactionTaxCategory PRIMARY KEY CLUSTERED,
AccountTransactionTaxCategoryName NVARCHAR(100) NOT NULL CONSTRAINT UK_AccountTransactionTaxCategoryName UNIQUE,
)

INSERT INTO AccountTransactionTaxCategory (AccountTransactionTaxCategoryName)
VALUES ('Sale'), ('Layaway'), ('Payroll'), ('Misc'), ('Lunch')

CREATE TABLE AccountTransaction(
AccountTransactionId            INT       NOT NULL IDENTITY(1,1) CONSTRAINT PK_AccountTransaction PRIMARY KEY CLUSTERED,
TransactionDate                 DATETIME2 NOT NULL CONSTRAINT DF_TransactionLog_TransactionDate               DEFAULT (GETDATE()),
AccountId                       SMALLINT  NOT NULL CONSTRAINT FK_TransactionLog_AccountId                     FOREIGN KEY REFERENCES Account(AccountId), -- Cash, CreditCard
AccountTransactionTaxCategoryId SMALLINT  NOT NULL CONSTRAINT FK_TransactionLog_AccountTransactionTaxCategory FOREIGN KEY REFERENCES AccountTransactionTaxCategory(AccountTransactionTaxCategoryId), -- Sale, Layaway, Payroll, Misc, Lunch
Amount                          MONEY     NOT NULL,
)

GO



--DROP TABLE Setting

CREATE TABLE Setting(
	[Key]	NVARCHAR(100) NOT NULL CONSTRAINT PK_Setting PRIMARY KEY CLUSTERED,
	Value	NVARCHAR(100) NULL,
	EncryptedValue VARBINARY(128) NULL
	)
GO
