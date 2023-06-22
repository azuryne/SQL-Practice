-- Data Cleaning in MySQL 

-----------------------------------------------------------------------------------------------------
-- Visualize and describe the data 

SELECT *
FROM HousingData.nashville;

DESCRIBE HousingData.nashville;

-----------------------------------------------------------------------------------------------------
-- Standardize the date format 
 
ALTER TABLE HousingData.nashville
ADD SaleDateConverted DATE;

UPDATE HousingData.nashville
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%Y-%m-%d');

-----------------------------------------------------------------------------------------------------
-- Populate the property address data 

UPDATE HousingData.nashville
SET PropertyAddress = NULL
WHERE PropertyAddress = '';

SELECT PropertyAddress
FROM HousingData.nashville
WHERE PropertyAddress IS NULL;

SELECT *
FROM HousingData.nashville
ORDER BY ParcelID; 			-- To check for duplicate ParcelID since ParcelID must match the Property Address

ALTER TABLE HousingData.nashville
CHANGE UniqueID UniqueID INT;

SELECT add_1.ParcelID, add_1.PropertyAddress, add_2.ParcelID, add_2.PropertyAddress, IFNULL(add_1.PropertyAddress, add_2.PropertyAddress)
FROM HousingData.nashville add_1
JOIN HousingData.nashville add_2
	ON add_1.ParcelID = add_2.ParcelID
AND add_1.uniqueID <> add_2.uniqueID
WHERE add_1.PropertyAddress IS NULL;			-- Search for related rows in add_2 with different UniqueID but same ParcelID. 
												-- If row exist, sets the PropertyAddress of the add_1 which is NULL to the related rows in	add_2 
                                                
                                                
UPDATE HousingData.nashville a1
SET PropertyAddress = IFNULL(a1.PropertyAddress, b1.PropertyAddress)
WHERE a1.PropertyAddress IS NULL
AND EXISTS (
    SELECT 1
    FROM HousingData.nashville b1
    WHERE a1.ParcelID = b1.ParcelID
    AND a1.uniqueID <> b1.uniqueID
);

-----------------------------------------------------------------------------------------------------
-- Separate Address by Address, City, State (for PropertyAddress field)

SELECT PropertyAddress
FROM HousingData.nashville;

SELECT
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Adress,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City
FROM HousingData.nashville;										-- Separate and see first if it's works 

ALTER TABLE HousingData.nashville
ADD Property_Address Nvarchar(255);

UPDATE HousingData.nashville
SET Property_Address = SUBSTRING_INDEX(PropertyAddress, ',', 1);

ALTER TABLE HousingData.nashville
ADD Property_City Nvarchar(255);

UPDATE HousingData.nashville
SET Property_City = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

SELECT *
FROM HousingData.nashville;

-----------------------------------------------------------------------------------------------------
-- Separate Address by Address, City, State (for OwnerAddress field)


UPDATE HousingData.nashville
SET OwnerAddress = NULL
WHERE OwnerAddress = '';

SELECT
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', ','), ',', 1) AS Address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', ','), ',', 2), ',', -1) AS City,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM HousingData.nashville;								-- Separate and see first if it's works 


ALTER TABLE HousingData.nashville
ADD Owner_Address Nvarchar(255);
UPDATE HousingData.nashville
SET Owner_Address = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', ','), ',', 1);

ALTER TABLE HousingData.nashville
ADD Owner_City Nvarchar(255);
UPDATE HousingData.nashville
SET Owner_City = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', ','), ',', 2), ',', -1);

ALTER TABLE HousingData.nashville
ADD Owner_State Nvarchar(255);
UPDATE HousingData.nashville
SET Owner_State = SUBSTRING_INDEX(OwnerAddress, ',', -1);

-----------------------------------------------------------------------------------------------------
-- Change Y and N as YES and NO in 'sold as vacant' field

SELECT distinct(SoldAsVacant), count(SoldAsVacant)
FROM HousingData.nashville
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant;

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
	END
FROM HousingData.nashville;

UPDATE HousingData.nashville
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
	END;

SELECT distinct(SoldAsVacant), count(SoldAsVacant)
FROM HousingData.nashville
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant;

-----------------------------------------------------------------------------------------------------
-- Remove Duplicates 

WITH RowNumCTE AS (
SELECT *, 
	row_number() OVER (
    PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
					LandUse
				) row_num
FROM HousingData.nashville
)
SELECT *
FROM RowNumCTE
Where row_num > 1
ORDER BY PropertyAddress;  -- check for duplicate first 

DELETE FROM HousingData.nashville
WHERE (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference) IN (
  SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
  FROM HousingData.nashville
  GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
  HAVING COUNT(*) > 1
);

-----------------------------------------------------------------------------------------------------
-- Delete Unused Column 

SELECT *
FROM HousingData.nashville;

ALTER TABLE HousingData.nashville
DROP COLUMN OwnerAddress;

ALTER TABLE HousingData.nashville
DROP COLUMN TaxDistrict;

ALTER TABLE HousingData.nashville
DROP COLUMN PropertyAddress;