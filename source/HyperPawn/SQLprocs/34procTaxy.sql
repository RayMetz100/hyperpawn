USE HyperPawn
GO

IF OBJECT_ID('TaxyGetPawnStatus') IS NOT NULL
  DROP PROC TaxyGetPawnStatus
GO
CREATE PROCEDURE TaxyGetPawnStatus
AS
SELECT PawnStatusId, PawnStatus, PawnStatusId PawnStatusChar
FROM HyperPawnData.dbo.PawnStatus
GO


IF OBJECT_ID('TaxyGetEmployees') IS NOT NULL
  DROP PROC TaxyGetEmployees
GO
CREATE PROCEDURE TaxyGetEmployees
AS
  SELECT EmployeeId, Initials, Last, First, Middle
  FROM   HyperPawnData.dbo.Employee
  WHERE  Inactive = 0
GO


IF OBJECT_ID('TaxyGetCities') IS NOT NULL
  DROP PROC TaxyGetCities
GO
CREATE PROCEDURE TaxyGetCities
@Top TINYINT
AS
SELECT TOP (@Top)
         ROW_NUMBER() OVER (ORDER BY COUNT(1) desc) AS Id,
         City Value,
         COUNT(1) [Count]
FROM     HyperPawnData.dbo.Party
WHERE    ISNULL(City,'') <> ''
GROUP BY City
ORDER BY COUNT(1) desc
GO

-- TaxyGetCities 12

IF OBJECT_ID('TaxyGetGunType') IS NOT NULL
  DROP PROC TaxyGetGunType
GO
CREATE PROCEDURE TaxyGetGunType
@Top TINYINT
AS
SELECT TOP (@Top)
         ROW_NUMBER() OVER (ORDER BY COUNT(1) DESC) AS Id,
         type Value,
         COUNT(1) [Count]
FROM     HyperPawnData.dbo.FirearmsAcquisitionAndDispositionEntry
WHERE    ISNULL(type,'') <> ''
GROUP BY type
ORDER BY COUNT(1) DESC
GO

-- TaxyGetGunType 9

IF OBJECT_ID('TaxyGetRace') IS NOT NULL
  DROP PROC TaxyGetRace
GO
CREATE PROCEDURE TaxyGetRace
@Top TINYINT
AS
SELECT TOP (@Top)
         ROW_NUMBER() OVER (ORDER BY COUNT(1) desc) AS Id,
         Race Value,
         COUNT(1) [Count]
FROM     HyperPawnData.dbo.Party
WHERE    ISNULL(Race,'') <> ''
GROUP BY Race
ORDER BY COUNT(1) desc
GO

-- TaxyGetRace 5

IF OBJECT_ID('TaxyGetHair') IS NOT NULL
  DROP PROC TaxyGetHair
GO
CREATE PROCEDURE TaxyGetHair
@Top TINYINT
AS
SELECT TOP (@Top)
         ROW_NUMBER() OVER (ORDER BY COUNT(1) desc) AS Id,
         Hair Value,
         COUNT(1) [Count]
FROM     HyperPawnData.dbo.Party
WHERE    ISNULL(Hair,'') <> ''
GROUP BY Hair
ORDER BY COUNT(1) desc
GO

-- TaxyGetHair 6
IF OBJECT_ID('TaxyGetEyes') IS NOT NULL
  DROP PROC TaxyGetEyes
GO
CREATE PROCEDURE TaxyGetEyes
@Top TINYINT
AS
SELECT TOP (@Top)
         ROW_NUMBER() OVER (ORDER BY COUNT(1) desc) AS Id,
         Eyes Value,
         COUNT(1) [Count]
FROM     HyperPawnData.dbo.Party
WHERE    ISNULL(Eyes,'') <> ''
GROUP BY Eyes
ORDER BY COUNT(1) desc
GO
-- TaxyGetEyes 6

