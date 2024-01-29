SELECT *
from carResale

alter table carResale
drop column registered_year



--Create new registered_year column

Alter table carResale
add registeredYear INT

Update carResale
Set registeredYear=
SubString(full_name, 1, 4) 



--Resale price to integer value
Alter table carResale
add resalePriceCorrected Float

Update carResale
Set resalePriceCorrected =
Case When resale_price Like '%Lakh' Then Cast(SubString(resale_price, 2, LEN(resale_price)-5) as float)*100000
	 When resale_price Like '%Crore' Then Cast(SubString(resale_price, 2, LEN(resale_price)-6) as float)*10000000
	 Else cast (Replace(SubString(resale_price, 3, LEN(resale_price)-2), ',','') as Float)
	 End
from carResale

Alter table carResale
drop column resale_price



--Remove cc from engine_capacity
Alter table carResale
add engineCapacityCorrected INT

Update carResale
Set engineCapacityCorrected =
Cast(SubString(engine_capacity, 1, LEN(engine_capacity)-3) as INT)
from carResale

Alter table carResale
drop column engine_capacity



--remove duplicates

--Find duplicates
Select full_name, kms_driven, registeredYear, resalePriceCorrected,engineCapacityCorrected, Count(*)
from carResale
Group by full_name, kms_driven, registeredYear, resalePriceCorrected, engineCapacityCorrected
Having Count(*)>1;

--Did not delete all the duplicates
Delete from carResale 
where F1 in(
Select a.F1
from carResale a
join carResale b
	on a.full_name=b.full_name
	and a.kms_driven=b.kms_driven
	and a.registeredYear=b.registeredYear
	and a.resalePriceCorrected=b.resalePriceCorrected
	and a.engineCapacityCorrected=b.engineCapacityCorrected
where a.F1<b.F1
)

--Deleted all the duplicates
Delete from carResale
where F1 in (
Select F1
From (
	Select F1,
	ROW_NUMBER() Over(Partition By full_name, kms_driven, registeredYear, resalePriceCorrected, engineCapacityCorrected Order by F1) As rownum
	From carResale
	) As sub
	Where rownum>1
)

