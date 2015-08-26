/*
MergeItems.sql

Merges serial and non-serial Items with identical description and price.
*/
use hyperpawndata
go
begin try

IF OBJECT_ID('#A') IS NOT NULL
  DROP TABLE #A
--   items that can be merged and target ID.
SELECT L.CustomerId, LI.ItemDescription, LI.Amount, I.ItemTypeId, I.ItemSubTypeId,
                 S.Make, S.Model, S.SerialNumber,
                 MIN(I.ItemId) TargetItemId, COUNT(1) [Count]
INTO #A
          FROM      Pawn             L
          JOIN      PawnItem         LI ON LI.FirstPawnId = L.FirstPawnId
          JOIN      Item             I  ON LI.ItemId = I.ItemId
          JOIN      ItemSubType      U  ON I.ItemSubTypeId = U.ItemSubTypeId AND I.ItemTypeId = U.ItemTypeId
          LEFT JOIN ItemSerial       S  ON I.ItemId = S.ItemId
          WHERE I.ItemTypeId <> 2
          GROUP BY L.CustomerId, LI.ItemDescription, LI.Amount, I.ItemTypeId, I.ItemSubTypeId,
                 S.Make, S.Model, S.SerialNumber
          HAVING COUNT(1) > 1


-- All items and itemid
SELECT I.ItemId, L.CustomerId, LI.ItemDescription, LI.Amount, I.ItemTypeId, I.ItemSubTypeId,
                 S.Make, S.Model, S.SerialNumber
INTO #B
FROM      Pawn             L
JOIN      PawnItem         LI ON LI.FirstPawnId = L.FirstPawnId
JOIN      Item             I  ON LI.ItemId = I.ItemId
JOIN      ItemSubType      U  ON I.ItemSubTypeId = U.ItemSubTypeId AND I.ItemTypeId = U.ItemTypeId
LEFT JOIN ItemSerial       S  ON I.ItemId = S.ItemId
WHERE I.ItemTypeId <> 2


IF OBJECT_ID('#T') IS NOT NULL
  DROP TABLE #T

create table #t (ItemId INT NOT NULL PRIMARY KEY CLUSTERED, TargetItemId INT NOT NULL)

-- find items to remap and clear
insert into #t
SELECT B.ItemId, M.TargetItemId
FROM     #B B
JOIN     #A M ON B.CustomerId = M.CustomerId
                                AND B.ItemDescription = M.ItemDescription
                                AND ISNULL(B.Make        ,'') = ISNULL(M.Make        ,'')
                                AND ISNULL(B.Model       ,'') = ISNULL(M.Model       ,'')
                                AND ISNULL(B.SerialNumber,'') = ISNULL(M.SerialNumber,'')
                                AND B.Amount = M.Amount 
                                AND B.ItemTypeId = M.ItemTypeId
                                AND B.ItemSubTypeId = M.ItemSubTypeId
WHERE B.ItemId <> M.TargetItemId
GROUP BY B.ItemId, M.TargetItemId
--ORDER BY M.TargetItemId

RAISERROR('starting transaction',0,1) WITH NOWAIT

--remap and clear
BEGIN TRAN

update pawnitem
set itemid = t.targetitemid
from pawnitem r
join #t t on r.itemid = t.itemid

delete r
from itemnonserial r
join #t t on r.itemid = t.itemid

delete r
from itemserial r
join #t t on r.itemid = t.itemid

delete r
from item r
join #t t on r.itemid = t.itemid

commit tran
end try
begin catch
if @@trancount > 0
rollback
print 'rolled back'
end catch
