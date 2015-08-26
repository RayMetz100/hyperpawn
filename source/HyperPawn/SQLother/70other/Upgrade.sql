use hyperpawndata
go


INSERT INTO PawnStatus VALUES  ('V','Void')
go
alter table pawn add 
  PawnStatusEmployee  smallint      NULL CONSTRAINT FK_Pawn_PawnStatusEmployee FOREIGN KEY REFERENCES Employee(EmployeeId)
go
update Pawn
set PawnStatusEmployee = ModifiedBy
go
alter table pawn alter column PawnStatusEmployee  smallint NOT NULL
go

update Pawn
set PawnStatusDate = Created
where PawnStatusDate is null and PawnStatusId = 'A'
go

update Pawn
set PawnStatusDate = Modified
where PawnStatusDate is null and PawnStatusId = 'F'
go
update Pawn
set PawnStatusDate = Modified
where PawnStatusDate is null and PawnStatusId = 'R'
go

alter table pawn alter column  PawnStatusDate      datetime2     NOT NULL
go

--select p.FirstPawnId, Amount, ItemDescription, ItemTypeName
--from PawnItem p 
--join Item i on p.ItemId = i.ItemId
--join itemtype t on i.ItemTypeId = t.ItemTypeId
--where ISNULL(amount,0)<=0
--order by ItemTypeName


delete p
from PawnItem p
join Item i on p.ItemId = i.ItemId
join itemtype t on i.ItemTypeId = t.ItemTypeId
where amount = 0 
