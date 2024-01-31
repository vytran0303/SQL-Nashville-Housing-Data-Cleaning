-- The dataset including information of housing data in Nashville, TN. I used PostgreSQL to cleaning the dataset to make it easier for later using
-- Deliverables:
-- 1. Standardize Date Format: 
-- 2. Populate PropertyAddress Data
-- 3. Breaking out PropertyAddress into Individual Columns (Address, City)
-- 4. Breaking out OwnerAdress into Individual Columns (Street, City, State)
-- 5. Remove Duplicates
-- 6. Change Y and N to Yes and No in SoldAsVacant
-- 7. Delete Unused Columns


-- Standardize Date Format: ALTER TABLE, ALTER COLUMN

ALTER TABLE housing
ALTER COLUMN saledate TYPE date
USING saledate::date;

-- Populate PropertyAddress Data: UPDATE TABLE, COALESCE(), SELF-JOIN

UPDATE housing
SET propertyaddress = COALESCE(h1.propertyaddress, h2.propertyaddress)
FROM housing h1
JOIN housing h2
ON h1.parcelid = h2.parcelid
and h1.uniqueid <> h2.uniqueid
WHERE h1.propertyaddress is null
and housing.uniqueid = h1.uniqueid;


-- Breaking out PropertyAddress into Individual Columns (Address, City): ALTER TABLE, ADD COLUMN, UPDATE TABLE, TRIM(), SUBSTRING


ALTER TABLE housing
ADD PropertySplitAddress VARCHAR(100);

UPDATE housing
SET PropertySplitAddress = TRIM(SUBSTRING(propertyaddress from 0 for position (',' IN propertyaddress)));

ALTER TABLE housing
ADD PropertySplitCity VARCHAR(100);

UPDATE housing
SET PropertySplitCity = TRIM(SUBSTRING(propertyaddress FROM POSITION (',' IN propertyaddress)+1 FOR CHAR_LENGTH(propertyaddress)));


-- Breaking OwnerAddress Into Columns (Address, City, State): ALTER TABLE, ADD COLUMN, UPDATE TABLE, TRIM(), SPLIT_PART()



ALTER TABLE housing
ADD OwnerSplitAddress VARCHAR(100);

UPDATE housing
SET OwnerSplitAddress = trim(split_part(owneraddress, ',', 1));

ALTER TABLE housing
ADD OwnerSplitCity VARCHAR(100);

UPDATE housing
SET OwnerSplitCity = trim(split_part(owneraddress, ',', 2));

ALTER TABLE housing
ADD OwnerSplitState VARCHAR(100);

UPDATE housing
SET OwnerSplitState = trim(split_part(owneraddress, ',', 3));

-- Remove Duplicates: DELETE COLUMN, CTE, WINDOW FUNCTION (ROW_NUMBER())


WITH cte AS (
SELECT *,
row_number() over(
		partition by
					parcelid,
					landuse,
					propertyaddress,
					saledate,
					saleprice,
					legalreference) AS rownum
from housing)


DELETE FROM housing
USING cte
WHERE housing.uniqueid = cte.uniqueid 
 AND cte.rownum > 1;
 
-- Change Y and N to Yes and No in SoldAsVacant: UPDATE TABLE, CASE...WHEN, CASE WHEN ... THEN ... ELSE ... END

UPDATE housing
SET soldasvacant = case when soldasvacant = 'Y' then 'Yes'
	 					when soldasvacant = 'N' then 'No'
						else soldasvacant end

-- Delete Unused Columns: ALTER TABLE, DROP COLUMN


ALTER TABLE housing
DROP COLUMN propertyaddress, 
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict;







