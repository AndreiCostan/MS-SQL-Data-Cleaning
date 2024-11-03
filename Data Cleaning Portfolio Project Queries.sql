/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM MSSQLPortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM MSSQLPortfolioProject..NashvilleHousing

UPDATE MSSQLPortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- If it doesn't Update properly

ALTER TABLE MSSQLPortfolioProject..NashvilleHousing
ADD SaleDateConverted Date

UPDATE MSSQLPortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM MSSQLPortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM MSSQLPortfolioProject..NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM MSSQLPortfolioProject..NashvilleHousing a
JOIN MSSQLPortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM MSSQLPortfolioProject..NashvilleHousing a
JOIN MSSQLPortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- Property Address Split
SELECT PropertyAddress
FROM MSSQLPortfolioProject..NashvilleHousing

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM MSSQLPortfolioProject..NashvilleHousing

ALTER TABLE MSSQLPortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE MSSQLPortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE MSSQLPortfolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE MSSQLPortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM MSSQLPortfolioProject..NashvilleHousing


-- Owner Address Split
SELECT OwnerAddress
FROM MSSQLPortfolioProject..NashvilleHousing

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) ,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) ,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM MSSQLPortfolioProject..NashvilleHousing

ALTER TABLE MSSQLPortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE MSSQLPortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE MSSQLPortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE MSSQLPortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE MSSQLPortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE MSSQLPortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM MSSQLPortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM MSSQLPortfolioProject..NashvilleHousing

UPDATE MSSQLPortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
				   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
	) row_num
FROM MSSQLPortfolioProject..NashvilleHousing
-- ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
	) row_num
FROM MSSQLPortfolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM MSSQLPortfolioProject..NashvilleHousing

ALTER TABLE MSSQLPortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
