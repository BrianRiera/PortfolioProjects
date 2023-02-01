/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioP..NashvilleHousing


-- Standardise Date Format

SELECT SaleDateConverted, CONVERT(DATE,Saledate)
FROM PortfolioP..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address data

SELECT *
FROM PortfolioP..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioP..NashvilleHousing a
JOIN PortfolioP..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioP..NashvilleHousing a
JOIN PortfolioP..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioP..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) 


-- Easier Method
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),  3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),  2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),  1)
FROM PortfolioP..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  32)



ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  1)

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldasVacant)
FROM PortfolioP..NashvilleHousing
GROUP BY SoldAsVacant
ORDER by 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	   WHEN SoldAsVacant ='N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioP..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	   WHEN SoldAsVacant ='N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicates

WITH RowNUMCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

FROM PortfolioP..NashvilleHousing
--ORDER BY ParcelID
)
--DELETE
--FROM RowNUMCTE
--WHERE row_num >1



SELECT *
FROM RowNUMCTE
WHERE row_num >1
ORDER BY PropertyAddress

--Delete Unused Columns

SELECT *
FROM PortfolioP..NashvilleHousing

ALTER TABLE PortfolioP..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate