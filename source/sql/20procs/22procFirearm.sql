use HyperPawn
GO


IF OBJECT_ID('FirearmPawnPickup') IS NOT NULL
  DROP PROC FirearmPawnPickup
GO
CREATE PROC FirearmPawnPickup
  @FirearmLogReferenceId INT,
  @EmployeeId            SMALLINT,
  @DispositionDate       DATETIME2    ,
  @DispositionName       NVARCHAR(200),
  @DispositionAddress    NVARCHAR(200)
WITH ENCRYPTION
AS
  SET NOCOUNT ON
      INSERT INTO HyperPawnData.dbo.FirearmsAcquisitionAndDispositionEntry
      (CreatedBy,
       FirearmLogReferenceId,
      [manufacturer and importer],
      [model]                                 ,
      [serial number]                         ,
      [type]                                  ,
      [caliber or guage]                      ,
      [Receipt date]                          ,
      [Receipt name]                          ,
      [Receipt address or license number]     ,
      [Disposition date of sale or other]     ,
      [Disposition name]                      ,
      [Disposition address or license number]
      )
      SELECT @EmployeeId           ,
             @FirearmLogReferenceId,
             [manufacturer and importer]                 ,
             [model]                ,
             [serial number]               ,
             [type]                 ,
             [caliber or guage]              ,
             [Receipt date]          ,
             [Receipt name]          ,
             [Receipt address or license number]       ,
             @DispositionDate      ,
             @DispositionName      ,
             @DispositionAddress
     FROM HyperPawnData.dbo.FirearmsAcquisitionAndDispositionEntry E
     JOIN (SELECT Max(Id) Id
           FROM   HyperPawnData.dbo.FirearmsAcquisitionAndDispositionEntry
           WHERE  FirearmLogReferenceId = @FirearmLogReferenceId
           ) L ON E.Id = L.Id
GO

IF OBJECT_ID('FirearmAppendLogEntry') IS NOT NULL
  DROP PROC FirearmAppendLogEntry
GO
CREATE PROC FirearmAppendLogEntry
  @FirearmLogReferenceId INT,
  @EmployeeId            SMALLINT,
  @Make                  NVARCHAR(50),
  @Model                 NVARCHAR(50),
  @Serial                NVARCHAR(50),
  @Type                  NVARCHAR(30),
  @Caliber               NVARCHAR(30),
  @ReceiptDate           DATETIME2    ,
  @ReceiptName           NVARCHAR(200),
  @ReceiptAddress        NVARCHAR(200),
  @DispositionDate       DATETIME2    ,
  @DispositionName       NVARCHAR(200),
  @DispositionAddress    NVARCHAR(200)
WITH ENCRYPTION
AS
  SET NOCOUNT ON
      INSERT INTO HyperPawnData.dbo.FirearmsAcquisitionAndDispositionEntry
      (CreatedBy,
       FirearmLogReferenceId,
      [manufacturer and importer],
      [model]                                 ,
      [serial number]                         ,
      [type]                                  ,
      [caliber or guage]                      ,
      [Receipt date]                          ,
      [Receipt name]                          ,
      [Receipt address or license number]     ,
      [Disposition date of sale or other]     ,
      [Disposition name]                      ,
      [Disposition address or license number]
      )
      SELECT @EmployeeId           ,
             @FirearmLogReferenceId,
             @Make                 ,
             @Model                ,
             @Serial               ,
             @Type                 ,
             @Caliber              ,
             @ReceiptDate          ,
             @ReceiptName          ,
             @ReceiptAddress       ,
             @DispositionDate      ,
             @DispositionName      ,
             @DispositionAddress
GO


IF OBJECT_ID('FirearmGetLog') IS NOT NULL
  DROP PROC FirearmGetLog
GO
CREATE PROC FirearmGetLog
  @Top             INT, 
  @All             BIT           = 0,
  @LogNumber       INT           = NULL,
  @ReceiptName     NVARCHAR(200) = NULL,
  @DispositionName NVARCHAR(200) = NULL,
  @SerialNumber    NVARCHAR(50) = NULL
WITH ENCRYPTION
AS
  SET NOCOUNT ON
  
  DECLARE @t TABLE (Id INT NOT NULL PRIMARY KEY CLUSTERED)
  
  IF @All = 0
  BEGIN
    INSERT INTO @t
    SELECT  TOP (@Top) MAX(Id) Id
          FROM     HyperPawnData.dbo.FirearmsAcquisitionAndDispositionEntry
          WHERE FirearmLogReferenceId = CASE WHEN @LogNumber       IS NOT NULL THEN @LogNumber               ELSE FirearmLogReferenceId END
            AND [Receipt name]     LIKE CASE WHEN @ReceiptName     IS NOT NULL THEN '%'+@ReceiptName+'%'     ELSE [Receipt name] END
            AND ISNULL([Disposition name],'') LIKE CASE WHEN @DispositionName IS NOT NULL THEN ISNULL('%'+@DispositionName+'%','') ELSE ISNULL([Disposition name],'') END
            AND [serial number]    LIKE CASE WHEN @SerialNumber    IS NOT NULL THEN '%'+@SerialNumber+'%'    ELSE [serial number] END
          GROUP BY FirearmLogReferenceId
          ORDER BY FirearmLogReferenceId DESC
    
    
    SELECT
       E.Id,
       E.FirearmLogReferenceId, 
       E.CreatedOn, 
       E.CreatedBy,
       [manufacturer and importer]             ,
       [model]                                 ,
       [serial number]                         ,
       [type]                                  ,
       [caliber or guage]                      ,
    
       [Receipt date]                          ,
       [Receipt name]                          ,
       [Receipt address or license number]     ,
    
       [Disposition date of sale or other]     ,
       [Disposition name]                      ,
       [Disposition address or license number] ,
       CAST(LI.FirstPawnId AS NVARCHAR(20)) FirstPawnId,
       L.Location,
       S.PawnStatus,
       CONVERT(NVARCHAR(20), L.PawnStatusDate, 101) PawnStatusDate
    FROM      HyperPawnData.dbo.FirearmsAcquisitionAndDispositionEntry E
    JOIN      @t                           I  ON E.Id = I.Id
    LEFT JOIN HyperPawnData.dbo.PawnItem   LI ON E.FirearmLogReferenceId = LI.FirearmLogReferenceId
    LEFT JOIN HyperPawnData.dbo.Pawn       L  ON LI.FirstPawnId = L.PawnId
    LEFT JOIN HyperPawnData.dbo.PawnStatus S  ON L.PawnStatusId = S.PawnStatusId
    ORDER BY FirearmLogReferenceId DESC
  END
  
  IF @All = 1
    BEGIN
      SELECT TOP (@Top)
       Id,
       FirearmLogReferenceId, 
       CreatedOn, 
       CreatedBy,
       [manufacturer and importer]             ,
       [model]                                 ,
       [serial number]                         ,
       [type]                                  ,
       [caliber or guage]                      ,
    
       [Receipt date]                          ,
       [Receipt name]                          ,
       [Receipt address or license number]     ,
    
       [Disposition date of sale or other]     ,
       [Disposition name]                      ,
       [Disposition address or license number] 

    FROM HyperPawnData.dbo.FirearmsAcquisitionAndDispositionEntry E
          WHERE FirearmLogReferenceId = CASE WHEN @LogNumber       IS NOT NULL THEN @LogNumber               ELSE FirearmLogReferenceId END
            AND [Receipt name]     LIKE CASE WHEN @ReceiptName     IS NOT NULL THEN '%'+@ReceiptName+'%'     ELSE [Receipt name] END
            AND [Disposition name] LIKE CASE WHEN @DispositionName IS NOT NULL THEN '%'+@DispositionName+'%' ELSE [Disposition name] END
            AND [serial number]    LIKE CASE WHEN @SerialNumber    IS NOT NULL THEN '%'+@SerialNumber+'%'    ELSE [serial number] END
    ORDER BY FirearmLogReferenceId DESC, CreatedOn DESC
  END
GO


IF OBJECT_ID('FirearmAddLogEntry') IS NOT NULL
  DROP PROC FirearmAddLogEntry
GO
CREATE PROC FirearmAddLogEntry
  @FirearmLogReferenceId INT OUT,
  @EmployeeId            SMALLINT,
  @Make                  NVARCHAR(50),
  @Model                 NVARCHAR(50),
  @Serial                NVARCHAR(50),
  @Type                  NVARCHAR(30),
  @Caliber               NVARCHAR(30),
  @ReceiptDate           DATETIME2,
  @ReceiptName           NVARCHAR(200),
  @ReceiptAddress        NVARCHAR(200),
  @DispositionDate       DATETIME2     = NULL,
  @DispositionName       NVARCHAR(200) = NULL,
  @DispositionAddress    NVARCHAR(200) = NULL
WITH ENCRYPTION
AS
  SET NOCOUNT ON
  
  DECLARE @Msg VARCHAR(255)
  
  BEGIN TRY
    BEGIN TRANSACTION
    
      SELECT @FirearmLogReferenceId = MAX(FirearmLogReferenceId) + 1
      FROM HyperPawnData.dbo.FirearmLogReference
      
      IF @FirearmLogReferenceId IS NULL
		SET @FirearmLogReferenceId = 1
      
      INSERT INTO HyperPawnData.dbo.FirearmLogReference
      (FirearmLogReferenceId)
      SELECT @FirearmLogReferenceId
      

    SET @MSG = 'middle' + cast(@FirearmLogReferenceId as nvarchar(max))
    RAISERROR(@Msg, 0,1) WITH NOWAIT
      
      INSERT INTO HyperPawnData.dbo.FirearmsAcquisitionAndDispositionEntry
      (CreatedBy,
       FirearmLogReferenceId,
      [manufacturer and importer],
      [model]                                 ,
      [serial number]                         ,
      [type]                                  ,
      [caliber or guage]                      ,
      [Receipt date]                          ,
      [Receipt name]                          ,
      [Receipt address or license number]     ,
      [Disposition date of sale or other]     ,
      [Disposition name]                      ,
      [Disposition address or license number]
      )
      SELECT @EmployeeId           ,
             @FirearmLogReferenceId,
             @Make                 ,
             @Model                ,
             @Serial               ,
             @Type                 ,
             @Caliber              ,
             @ReceiptDate          ,
             @ReceiptName          ,
             @ReceiptAddress       ,
             @DispositionDate      ,
             @DispositionName      ,
             @DispositionAddress
    COMMIT TRAN
    RETURN 0
  END TRY
  BEGIN CATCH
      SELECT 
      
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() as ErrorState,
        ERROR_PROCEDURE() as ErrorProcedure,
        ERROR_LINE() as ErrorLine,
        ERROR_MESSAGE() as ErrorMessage;
  
      PRINT 'Rolling Back'
      ROLLBACK TRAN
      RAISERROR('FirearmAddLogEntry Proc Failed',17,1)
  END CATCH
  
GO
