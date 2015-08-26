create view PurchaseHistory as
select
 p.PurchaseId, convert(varchar(10),PurchaseDate,121) PurchaseDate--, emp.Initials
--,CustomerId, 
,c.Last+', '+ c.first Name, convert(varchar(10),c.DateOfBirth,121) DOB,
       LI.Amount,
	   case when F.ItemId is null then 
       LI.ItemDescription 
	   else
	   
       'LogNum:'+cast(E.FirearmLogReferenceId as varchar(100))+', '+
       COALESCE(S.Make   ,G.Make        ) +', '+
       COALESCE(S.Model   ,G.Model      ) +', '+
       COALESCE(S.SerialNumber ,G.SerialNumber  ) +', '+
       G.Caliber+', '+
       G.Action+', '+
       F.BarrelLength end  as Description

from Purchase p
join Employee emp on p.CreatedBy = emp.EmployeeId
join Party c on p.CustomerId = c.PartyId
JOIN      HyperPawnData.dbo.PurchaseItem      LI ON p.PurchaseId = li.PurchaseId
JOIN      HyperPawnData.dbo.Item          I  ON LI.ItemId = I.ItemId
JOIN      HyperPawnData.dbo.ItemSubType   U  ON I.ItemSubTypeId = U.ItemSubTypeId AND I.ItemTypeId = U.ItemTypeId
LEFT JOIN HyperPawnData.dbo.ItemNonSerial N  ON LI.ItemId = N.ItemId
LEFT JOIN HyperPawnData.dbo.ItemSerial    S  ON LI.ItemId = S.ItemId
LEFT JOIN HyperPawnData.dbo.ItemFirearm   F  ON LI.ItemId = F.ItemId
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
where PurchaseDate > getdate() - 730
--order by p.PurchaseId desc