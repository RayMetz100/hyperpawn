USE HyperPawnData
GO

IF OBJECT_ID('PawnFees_WA_Storage') IS NOT NULL
  DROP TABLE PawnFees_WA_Storage
GO

CREATE TABLE PawnFees_WA_Storage (
  FeeName SYSNAME NOT NULL PRIMARY KEY CLUSTERED,
  Amount  MONEY   NOT NULL)
GO

INSERT INTO PawnFees_WA_Storage VALUES  ('Item'   ,5.00)
                                       ,('Firearm',5.00);

IF OBJECT_ID('PawnFees_WA_Interest') IS NOT NULL
  DROP TABLE PawnFees_WA_Interest
GO


CREATE TABLE PawnFees_WA_Interest (
  AmountStart     MONEY        NOT NULL PRIMARY KEY CLUSTERED,
  AmountEnd       MONEY        NOT NULL,
  MonthlyInterestAmount  MONEY        NULL,
  MonthlyInterestPercent DECIMAL(9,7) NULL)
GO

INSERT INTO PawnFees_WA_Interest VALUES  (   .0001,              9.9999,1   ,NULL),
                                         ( 10     ,             19.9999,1.25,NULL),
                                         ( 20     ,             24.9999,1.5 ,NULL),
                                         ( 25     ,             34.9999,1.75,NULL),
                                         ( 35     ,             39.9999,2   ,NULL),
                                         ( 40     ,             49.9999,2.25,NULL),
                                         ( 50     ,             59.9999,2.50,NULL),
                                         ( 60     ,             69.9999,2.75,NULL),
                                         ( 70     ,             79.9999,3   ,NULL),
                                         ( 80     ,             89.9999,3.25,NULL),
                                         ( 90     ,             99.9999,3.5 ,NULL),
                                         (100     ,922337203685477.5807,NULL,.035 )


IF OBJECT_ID('PawnFees_WA_Preparation') IS NOT NULL
  DROP TABLE PawnFees_WA_Preparation
GO


CREATE TABLE PawnFees_WA_Preparation (
  AmountStart       MONEY NOT NULL PRIMARY KEY CLUSTERED,
  AmountEnd         MONEY NOT NULL,
  PreparationAmount MONEY NOT NULL)

INSERT INTO PawnFees_WA_Preparation VALUES  (    .0001,              4.99  , 1.5 ),
                                            (   5     ,              9.99  , 3   ),
                                            (  10     ,             14.99  , 4   ),
                                            (  15     ,             19.99  , 4.5 ),
                                            (  20     ,             24.99  , 5   ),
                                            (  25     ,             29.99  , 5.5 ),
                                            (  30     ,             34.99  , 6   ),
                                            (  35     ,             39.99  , 6.5 ),
                                            (  40     ,             44.99  , 7   ),
                                            (  45     ,             49.99  , 7.5 ),
                                            (  50     ,             54.99  , 7.5 ),
                                            (  55     ,             59.99  , 8.25),
                                            (  60     ,             64.99  , 9   ),
                                            (  65     ,             69.99  , 9.5 ),
                                            (  70     ,             74.99  ,10   ),
                                            (  75     ,             79.99  ,10.5 ),
                                            (  80     ,             84.99  ,11   ),
                                            (  85     ,             89.99  ,11.5 ),
                                            (  90     ,             94.99  ,12   ),
                                            (  95     ,             99.99  ,12.5 ),
                                            ( 100     ,            104.99  ,13   ),
                                            ( 105     ,            109.99  ,13.25),
                                            ( 110     ,            114.99  ,13.75),
                                            ( 115     ,            119.99  ,14.25),
                                            ( 120     ,            124.99  ,14.5 ),
                                            ( 125     ,            129.99  ,14.75),
                                            ( 130     ,            149.99  ,15.50),
                                            ( 150     ,            174.99  ,15.75),
                                            ( 175     ,            199.99  ,17   ),
                                            ( 200     ,            224.99  ,20   ),
                                            ( 225     ,            249.99  ,22   ),
                                            ( 250     ,            274.99  ,24   ),
                                            ( 275     ,            299.99  ,25   ),
                                            ( 300     ,            324.99  ,26   ),
                                            ( 325     ,            349.99  ,27   ),
                                            ( 350     ,            374.99  ,28   ),
                                            ( 375     ,            399.99  ,29   ),
                                            ( 400     ,            424.99  ,30   ),
                                            ( 425     ,            449.99  ,31   ),
                                            ( 450     ,            474.99  ,32   ),
                                            ( 475     ,            499.99  ,33   ),
                                            ( 500     ,            524.99  ,29   ),
                                            ( 525     ,            549.99  ,39   ),
                                            ( 550     ,            599.99  ,40   ),
                                            ( 600     ,            699.99  ,41   ),
                                            ( 700     ,            799.99  ,46   ),
                                            ( 800     ,            899.99  ,51   ),
                                            ( 900     ,            999.99  ,56   ),
                                            (1000     ,           1499.99  ,75   ),
                                            (1500     ,           1999.99  ,81   ),
                                            (2000     ,           2499.99  ,86   ),
                                            (2500     ,           2999.99  ,91   ),
                                            (3000     ,           3499.99  ,96   ),
                                            (3500     ,           3999.99  ,101  ),
                                            (4000     ,           4499.99  ,106  ),
                                            (4500     ,922337203685477.5807,111  )

GO


USE HyperPawn
GO

IF OBJECT_ID('fn_PawnFees_WA') IS NOT NULL
  DROP FUNCTION dbo.fn_PawnFees_WA
GO

CREATE FUNCTION dbo.fn_PawnFees_WA
(@PawnAmount MONEY)
RETURNS TABLE
AS
RETURN
  SELECT
   ISNULL(MAX(MonthlyInterestAmount),CAST(0 AS MONEY)) MonthlyInterestAmount
  ,ISNULL(MAX(PreparationAmount)    ,CAST(0 AS MONEY)) PreparationAmount
  ,MAX(S .Amount)                                      StorageFee
  ,MAX(SF.Amount)                                      FirearmFee
  FROM (SELECT
         CAST(ISNULL(MonthlyInterestAmount,@PawnAmount * MonthlyInterestPercent) AS MONEY) MonthlyInterestAmount
        ,CAST(NULL AS MONEY)                                                               PreparationAmount
        FROM   HyperPawnData.dbo.PawnFees_WA_Interest
        WHERE  @PawnAmount BETWEEN AmountStart AND AmountEnd
        UNION ALL 
        SELECT
		 CAST(NULL AS MONEY)                                             MonthlyInterestAmount
		,PreparationAmount                                               PreparationAmount
        FROM   HyperPawnData.dbo.PawnFees_WA_Preparation P
        WHERE  @PawnAmount BETWEEN AmountStart AND AmountEnd) I
  JOIN HyperPawnData.dbo.PawnFees_WA_Storage S  ON S .FeeName = 'Item'
  JOIN HyperPawnData.dbo.PawnFees_WA_Storage SF ON SF.FeeName = 'Firearm'
GO


IF OBJECT_ID('TaxyGetPawnFees_WA_Interest') IS NOT NULL
  DROP PROC TaxyGetPawnFees_WA_Interest
GO
CREATE PROCEDURE TaxyGetPawnFees_WA_Interest
AS
  SELECT AmountStart, AmountEnd, ISNULL(MonthlyInterestAmount,0) MonthlyInterestAmount, ISNULL(MonthlyInterestPercent,0) MonthlyInterestPercent
  FROM   HyperPawnData.dbo.PawnFees_WA_Interest
GO

IF OBJECT_ID('TaxyGetPawnFees_WA_Preparation') IS NOT NULL
  DROP PROC TaxyGetPawnFees_WA_Preparation
GO
CREATE PROCEDURE TaxyGetPawnFees_WA_Preparation
AS
  SELECT AmountStart, AmountEnd, PreparationAmount
  FROM   HyperPawnData.dbo.PawnFees_WA_Preparation
GO


IF OBJECT_ID('TaxyGetPawnFees_WA_Storage') IS NOT NULL
  DROP PROC TaxyGetPawnFees_WA_Storage
GO
CREATE PROCEDURE TaxyGetPawnFees_WA_Storage
AS
  SELECT I.Amount as Item, F.Amount as Firearm
  FROM   HyperPawnData.dbo.PawnFees_WA_Storage I
  JOIN   HyperPawnData.dbo.PawnFees_WA_Storage F ON F.FeeName = 'Firearm'
  WHERE  I.FeeName = 'Item'
GO
