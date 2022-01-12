
select * from USFastFood..FastFoodRestaurants

--1. split full address into address, city, state
select full_address
		, TRIM(SUBSTRING(full_address, 1, CHARINDEX(',', full_address) - 1 )) as Address
		, TRIM(PARSENAME(REPLACE(full_address,',','.'), 2 )) as  City
		, RIGHT(full_address, 2) as State
from USFastFood..FastFoodRestaurants


--Create new columns and add each of split parts of full address to them
alter table USFastFood..FastFoodrestaurants
	add Address nvarchar(255)
		, City nvarchar(255)
		, State nvarchar(255) ;

UPDATE USFastFood..FastFoodRestaurants
SET Address = TRIM(SUBSTRING(full_address, 1, CHARINDEX(',', full_address) - 1 ))
	, City = TRIM(PARSENAME(REPLACE(full_address,',','.'), 2 ))
	, State = RIGHT(full_address, 2) ;

--=========================================================-

--2. Remove duplicate rows
select * 
		,ROW_NUMBER() over(partition by
			Address
			, City
			, State
			, latitude
			, longitude					-- partition by things that a row have same data
			ORDER BY [order]) as row_num -- order by unique col
from USFastFood..FastFoodRestaurants

--put it in CTE and filter row_num > 1 to find duplicate rows
WITH CTE_RowNum AS(
select * 
		,ROW_NUMBER() over(partition by
			Address
			, City
			, State
			, latitude
			, longitude
			ORDER BY [order]) as row_num
from USFastFood..FastFoodRestaurants
)
select * 
from CTE_RowNum
where row_num > 1

--Deleted duplicate rows
WITH CTE_RowNum AS (
select * 
		,ROW_NUMBER() over(partition by
			Address
			, City
			, State
			, latitude
			, longitude
			ORDER BY [order]) as row_num
from USFastFood..FastFoodRestaurants
)
DELETE 
from CTE_RowNum
where row_num > 1

--=========================================================-

--3. Populate postal code

ALTER table FastFoodRestaurants
	ALTER column postalCode nvarchar(30) null;

ALTER table Zip_Code
	ALTER column postalCode nvarchar(30) null;
 
select *
from USFastFood..FastFoodRestaurants
where postalCode is null
--postal code is missing in some rows


--JOIN 2 tables
select f.*, f.postalCode, z.postalCode
from USFastFood..FastFoodRestaurants as f
JOIN USFastFood..Zip_Code as z
ON f.State = z.state
	and f.city = z.city
	and f.Address = z.address
where f.postalCode is null


UPDATE f
SET f.postalCode = ISNULL(f.postalCode, z.postalCode)
from USFastFood..FastFoodRestaurants as f
JOIN USFastFood..Zip_Code as z
ON f.State = z.state
	and f.city = z.city
	and f.Address = z.address
where f.postalCode is null

--another method is to use COALESCE
UPDATE f
SET f.postalCode = COALESCE(f.postalCode, z.postalCode)
from USFastFood..FastFoodRestaurants as f
JOIN USFastFood..Zip_Code as z
ON f.State = z.state
	and f.city = z.city
	and f.Address = z.address
where f.postalCode is null

--=========================================================-

--4. CASE statements

select distinct(name), count(name) as Name_count
from USFastFood..FastFoodRestaurants
group by name
order by name, Name_count DESC

select distinct(name), count(name) as Name_count
from USFastFood..FastFoodRestaurants
where name like '%Donald%' 
	or name like '%Donuts%'
group by name
order by name, Name_count DESC
-- McDonald's and Dunkin' Donuts have inconsistent data.

select name,
CASE WHEN name = 'Dunkin Donuts' THEN 'Dunkin'' Donuts'
	 WHEN name = 'Mc Donalds' THEN 'McDonald''s'
	 WHEN name = 'McDonalds' THEN 'McDonald''s'
	 WHEN name = 'McDonald''s of Rolesville' THEN 'McDonald''s'
	 WHEN name = 'Mcdonalds Whitehouse' THEN 'McDonald''s'
	 WHEN name = 'McDonalds''s' THEN 'McDonald''s'
	 WHEN name = 'The Arch at McDonald''s Campus Office Building' THEN 'McDonald''s'
	 ELSE name
END as NewName
from USFastFood..FastFoodRestaurants
where name like '%Donald%' 
	or name like '%Donuts%'
order by name

--Update the table
UPDATE USFastFood..FastFoodRestaurants
SET name = 
CASE WHEN name = 'Dunkin Donuts' THEN 'Dunkin'' Donuts'
	 WHEN name = 'Mc Donalds' THEN 'McDonald''s'
	 WHEN name = 'McDonalds' THEN 'McDonald''s'
	 WHEN name = 'McDonald''s of Rolesville' THEN 'McDonald''s'
	 WHEN name = 'Mcdonalds Whitehouse' THEN 'McDonald''s'
	 WHEN name = 'McDonalds''s' THEN 'McDonald''s'
	 WHEN name = 'The Arch at McDonald''s Campus Office Building' THEN 'McDonald''s'
	ELSE name
END 
from USFastFood..FastFoodRestaurants
where name is null

--=========================================================-

--5. drop unnecessary colums

select * from USFastFood..FastFoodRestaurants

alter table USFastFood..FastFoodRestaurants
drop column full_address






	
