/*
Cleaning Data in SQL
*/

SELECT * FROM NashvilleHousing..NashvilleHousing;


-- Standardizing Sale Date Column
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHousing.dbo.NashvilleHousing

--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDates DATE

UPDATE NashvilleHousing
SET SaleDates = CONVERT(Date,SaleDate)

SELECT SaleDate, SaleDates
FROM NashvilleHousing


--Populate Property Address data
SELECT *	
FROM NashvilleHousing..NashvilleHousing
Order BY ParcelID;

--Checcking null values in PropertyAddress column
SELECT *	
FROM NashvilleHousing..NashvilleHousing
WHERE PropertyAddress is NULL
Order BY ParcelID;

--Using ISNULL to populate a.PropertyAddress from b.PropertyAddress 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL;

--Update Null rows in PropertyAddress column
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;



--Splitting PropertyAddress into indiviual columns (Address, City)
SELECT PropertyAddress	
FROM NashvilleHousing;

SELECT 
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD SplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD SplitCity nvarchar(255);

UPDATE NashvilleHousing
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT SplitAddress, SplitCity
FROM NashvilleHousing

SELECT * FROM NashvilleHousing..NashvilleHousing;

--Splitting OwnerAddress into indiviual columns (Address, City)
SELECT OwnerAddress
FROM NashvilleHousing;

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3) as OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) as OwnerSplitState
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


SELECT * FROM NashvilleHousing..NashvilleHousing;


-- Standardizing the SoldAsVacant column 'Y' & 'N' values.
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as CountSoldAsVacant
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM NashvilleHousing;

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant;



--Removing Duplicates rows

SELECT *
FROM NashvilleHousing;

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order BY
					UniqueID
						) row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY UniqueID; --104 rows


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order BY
					UniqueID
						) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1; --Delete duplicate 104 rows


SELECT *
FROM NashvilleHousing;


--Deleting columns which are not necessary

SELECT *
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate; --As SalesDate column provides needed info.

SELECT *
FROM NashvilleHousing;