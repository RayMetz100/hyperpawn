use HyperPawn
go

if object_id('PartySearch') is not null
  DROP PROCEDURE PartySearch

GO
CREATE PROCEDURE PartySearch
@PawnToCustomerId INT OUT,
@Last  nvarchar(40),
@First nvarchar(40)
WITH ENCRYPTION
AS
SET NOCOUNT ON
BEGIN TRY

IF @PawnToCustomerId > 0
  BEGIN
    SELECT @PawnToCustomerId = CustomerId FROM HyperPawnData.dbo.Pawn WHERE PawnId = @PawnToCustomerId
    RETURN 0
  END
SELECT TOP 200 
  c.PartyId, Last, First, IDNumber, City, DateOfBirth, 
  SUM(CASE WHEN p.PawnStatusId = 'A' THEN 1 ELSE 0 END) ActivePawns,
  SUM(CASE WHEN p.CustomerId IS NOT NULL THEN 1 ELSE 0 END) TotalPawns
FROM      HyperPawnData.dbo.Party c
LEFT JOIN HyperPawnData.dbo.Pawn  p on c.PartyId = p.CustomerId
WHERE 
      Last     LIKE ISNULL(@Last,  Last)
  AND First    LIKE ISNULL(@First, First)
GROUP BY c.PartyId, Last, First, IDNumber, City, DateOfBirth
ORDER BY Last, First, IDNumber

	RETURN 0

END TRY
BEGIN CATCH

IF @@TRANCOUNT <> 0
  ROLLBACK TRAN

RETURN 1

END CATCH
GO

if object_id('PartySearchById') is not null
  DROP PROCEDURE PartySearchById

GO
CREATE PROCEDURE PartySearchById
@IDNumber nvarchar(40)
WITH ENCRYPTION
AS
SET NOCOUNT ON
BEGIN TRY

SELECT TOP 1
  c.PartyId, Last, First, IDNumber, City, DateOfBirth, 
  SUM(CASE WHEN p.PawnStatusId = 'A' THEN 1 ELSE 0 END) ActivePawns,
  SUM(CASE WHEN p.CustomerId IS NOT NULL THEN 1 ELSE 0 END) TotalPawns
FROM      HyperPawnData.dbo.Party c
LEFT JOIN HyperPawnData.dbo.Pawn  p on c.PartyId = p.CustomerId
WHERE 
      IDNumber = @IDNumber
GROUP BY c.PartyId, Last, First, IDNumber, City, DateOfBirth
ORDER BY Last, First, IDNumber

	RETURN 0

END TRY
BEGIN CATCH

IF @@TRANCOUNT <> 0
  ROLLBACK TRAN

RETURN 1

END CATCH
GO

if object_id('PartyGetDetails') is not null
  DROP PROCEDURE PartyGetDetails

GO
CREATE PROCEDURE PartyGetDetails
@PartyId  int          = NULL,
@IDNumber nvarchar(30) = NULL,
@IdTypeId int          = NULL, 
@IdState  CHAR(2)      = NULL
WITH ENCRYPTION
AS
SET NOCOUNT ON
BEGIN TRY

DECLARE @RowCount  INT
DECLARE @ItemsAvailable INT
DECLARE @errormessage NVARCHAR(MAX)

IF @PartyId > 0
  BEGIN
    SET @ItemsAvailable = 0

    SELECT   @ItemsAvailable = COUNT(1)
    FROM     HyperPawnData.dbo.Party C
    JOIN     HyperPawnData.dbo.Pawn       P  ON P.CustomerId = C.PartyId
    JOIN     HyperPawnData.dbo.PawnItem   LI ON LI.FirstPawnId = P.FirstPawnId
    WHERE        P.PawnStatusId = 'P' -- 'Picked Up'
             AND C.PartyId = @PartyId
             
    SELECT
      P.PartyId, P.IDNumber, P.IdExpiration, IdIssued, DateOfBirth, 
      P.Last, P.First, P.Middle, 
      Street, City, State, Zip, 
      Sex, P.Height, P.Weight, Eyes, Race, Hair, 
      Phone, Email, P.Note, @ItemsAvailable ItemsAvailable, IntegrationId
    INTO #PT
    FROM HyperPawnData.dbo.Party P
    WHERE     P.PartyId = @PartyId

    SELECT @RowCount = @@RowCount

    IF @RowCount = 1
      BEGIN
        SELECT * FROM #PT
        RAISERROR('1 customer found, success',0,1) WITH NOWAIT
        GOTO Success
      END

    IF @RowCount = 0
        RAISERROR('customer not found, fail',11,1) WITH NOWAIT

    IF @RowCount > 1
        RAISERROR('more than one customer found, fail',11,1) WITH NOWAIT
  END
ELSE
  BEGIN
    SET @ItemsAvailable = 0

    SELECT   @ItemsAvailable = COUNT(1)
    FROM     HyperPawnData.dbo.Party C
    JOIN     HyperPawnData.dbo.Pawn       P  ON P.CustomerId = C.PartyId
    JOIN     HyperPawnData.dbo.PawnItem   LI ON LI.FirstPawnId = P.FirstPawnId
    WHERE        P.PawnStatusId = 'P' -- Picked Up
             AND @IDNumber = IDNumber
             AND @IdTypeId = IdTypeId
             AND @IdState  = IdState
             
    SELECT
      P.PartyId, P.IDNumber, P.IdExpiration, IdIssued, DateOfBirth, 
      P.Last, P.First, P.Middle, 
      Street, City, State, Zip, 
      Sex, P.Height, P.Weight, Eyes, Race, Hair, 
      Phone, Email, P.Note, @ItemsAvailable ItemsAvailable, IntegrationId
    INTO #IT
    FROM HyperPawnData.dbo.Party P
    WHERE        @IDNumber = IDNumber
             AND @IdTypeId = IdTypeId
             AND @IdState  = IdState

    SELECT @RowCount = @@RowCount

    IF @RowCount = 1
      BEGIN
        SELECT * FROM #IT
        RAISERROR('ID, 1 customer found, success',0,1) WITH NOWAIT
        GOTO Success
      END

    IF @RowCount = 0
        RAISERROR('ID, customer not found, fail',11,1) WITH NOWAIT

    IF @RowCount > 1
        RAISERROR('ID, more than one customer found, fail',11,1) WITH NOWAIT
  END

RAISERROR('Both Inputs Failed',11,1) WITH NOWAIT

Success:


END TRY
BEGIN CATCH
  IF @@TRANCOUNT <> 0
    ROLLBACK TRAN

  SET @errormessage = ERROR_MESSAGE()
  RAISERROR(@errormessage,11,1) WITH NOWAIT
END CATCH
GO

/*
usp_SearchCustomers 'smith', '%'

CustomerGetAll null, 'SMITHDL32604'
*/

if object_id('PartyUpsert') is not null
  DROP PROCEDURE PartyUpsert

GO

CREATE PROCEDURE PartyUpsert
  @PartyId INT OUTPUT,
  @EmployeeId         SMALLINT,
  @IdTypeId           TINYINT,
  @IdState            CHAR(2) = NULL,
  @IDNumber           nvarchar(30),
  @IdIssued           DATETIME = NULL,
  @IdExpiration       DATETIME = NULL,
  @DateOfBirth        DATETIME = NULL, 
  @Last               nvarchar(40),
  @First              nvarchar(40) = NULL,
  @Middle             nvarchar(40) = NULL,
  @Street             nvarchar(60),
  @City               nvarchar(40),
  @State              char(2),
  @Zip                varchar(10),
  @Sex                varchar(1) = NULL,
  @Eyes               varchar(3) = NULL,
  @Weight             varchar(3) = NULL,
  @Height             nvarchar(5) = NULL,
  @Race               varchar(3) = NULL,
  @Hair               varchar(3) = NULL,
  @Phone              varchar(15) = NULL,
  @Email              nvarchar(40) = NULL,
  @Note               nvarchar(max) = NULL
WITH ENCRYPTION
AS
SET NOCOUNT ON
DECLARE @Rowcount INT

-- If @PartyId is sent, only try finding customer on that alone.
-- If @PartyId is not sent, try finding customer by IDNumber.
IF EXISTS(SELECT 'EXISTS'
          FROM   HyperPawnData.dbo.Party
          WHERE  PartyId = @PartyId)
    BEGIN
      UPDATE HyperPawnData.dbo.Party
      SET Modified     = GETDATE(),
          ModifiedBy   = @EmployeeId,
          IdTypeId     = @IdTypeId, 
          IdState      = @IdState, 
          IdIssued     = @IdIssued, 
          IdExpiration = @IdExpiration,
          IDNumber     = @IDNumber, 
          DateOfBirth  = @DateOfBirth, 
          Last         = @Last, 
          First        = @First, 
          Middle       = @Middle, 
          Street       = @Street, 
          City         = @City, 
          State        = @State, 
          Zip          = @Zip, 
          Sex          = @Sex, 
          Height       = @Height, 
          Weight       = @Weight, 
          Eyes         = @Eyes, 
          Race         = @Race, 
          Hair         = @Hair, 
          Phone        = @Phone, 
          Email        = @Email, 
          Note         = @Note
      WHERE PartyId = @PartyId
      RETURN 0
    END
  ELSE -- Failed to find Customerid
    BEGIN
      IF @PartyId <> 0
        RETURN 1 -- Failed to find Customerid
    END


SELECT @PartyId = PartyId
FROM   HyperPawnData.dbo.Party
WHERE      IDNumber = @IDNumber
       AND IdTypeId = @IdTypeId
       AND ISNULL(IdState,'')  = ISNULL(@IdState,'')
SELECT @Rowcount = @@rowcount

IF @RowCount = 1 -- Found a customer based on IDNumber, type, and state
    BEGIN
      UPDATE HyperPawnData.dbo.Party
      SET Modified     = GETDATE(),
          ModifiedBy   = @EmployeeId,
          IdTypeId     = @IdTypeId, 
          IdState      = @IdState, 
          IdIssued     = @IdIssued, 
          IdExpiration = @IdExpiration,
          IDNumber     = @IDNumber, 
          DateOfBirth  = @DateOfBirth, 
          Last         = @Last, 
          First        = @First, 
          Middle       = @Middle, 
          Street       = @Street, 
          City         = @City, 
          State        = @State, 
          Zip          = @Zip, 
          Sex          = @Sex, 
          Height       = @Height, 
          Weight       = @Weight, 
          Eyes         = @Eyes, 
          Race         = @Race, 
          Hair         = @Hair, 
          Phone        = @Phone, 
          Email        = @Email, 
          Note         = @Note
      WHERE PartyId = @PartyId
      RETURN 0 --updated
    END
  ELSE -- Couldn't find existing customer based on number type and state.  Create new one.
    BEGIN
      INSERT INTO HyperPawnData.dbo.Party
        (CreatedBy,ModifiedBy,
         IdTypeId, IdState, IdIssued, IdExpiration,
         IDNumber, DateOfBirth, 
         Last, First, Middle, 
         Street, City, State, Zip, 
         Sex, Height, Weight, Eyes, Race, Hair, 
         Phone, Email, Note)
      VALUES
        (@EmployeeId,@EmployeeId,
         @IdTypeId, @IdState, @IdIssued, @IdExpiration,
         @IDNumber, @DateOfBirth, 
         @Last, @First, @Middle, 
         @Street, @City, @State, @Zip, 
         @Sex, @Height, @Weight, @Eyes, @Race, @Hair, 
         @Phone, @Email, @Note)
      SET @PartyId = @@identity
      PRINT @PartyId
      RETURN 0 -- Inserted
    END
GO

/*
declare @PartyId int
declare @rc int
exec @rc = PartyUpsert
@PartyId = @PartyId,
  @EmployeeId = 1,
   @IdTypeId = 1, --@IdTypeState = 'wa', --@IdIssued, @IdExpiration,
   @IDNumber = 'buzzbuzzzddf', @DateOfBirth = '6/6/1966', 
   @Last = 'mertz', @First = 'jpd',-- @Middle, 
   @Street = '123 main', @City = 'evt', @State = 'wa', @Zip = '98825'
--   @Sex, @Height, @Weight, @Eyes, @Race, @Hair, 
  -- @Phone, @Email, @Note
  select @rc, @PartyId
  
 
select * from Party
where Partyid = 4467
CustomerGetAll
select * from loan

*/