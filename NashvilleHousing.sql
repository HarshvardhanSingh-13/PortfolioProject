SELECT *
FROM Portfolio..NashvilleHousing

-- Populate Property Address Data

SELECT PropertyAddress
FROM Portfolio..NashvilleHousing


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN  Portfolio..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


-- Breaking Out Address into Indivisual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS Address, 
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

FROM Portfolio..NashvilleHousing

ALTER TABLE FROM Portfolio..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Portfolio..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE FROM Portfolio..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Portfolio..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM Portfolio..NashvilleHousing


SELECT OWNERSPLITSADDRESS
FROM Portfolio..NashvilleHousing


-- Breaking Out Owner Address into Address, City, State


SELECT OwnerAddress
FROM Portfolio..NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM Portfolio..NashvilleHousing


ALTER TABLE Portfolio..NashvilleHousing
ADD OWNERSPLITSADDRESS NVARCHAR(500);

UPDATE Portfolio..NashvilleHousing
SET 
OWNERSPLITSADDRESS = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE Portfolio..NashvilleHousing
ADD OWNERSPLITCITY NVARCHAR(255);

UPDATE Portfolio..NashvilleHousing
SET 
OWNERSPLITCITY = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE Portfolio..NashvilleHousing
ADD OWNERSPLITSTATE NVARCHAR(255)

UPDATE Portfolio..NashvilleHousing
SET
OWNERSPLITSTATE = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM Portfolio..NashvilleHousing



-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
    ,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
          WHEN SoldAsVacant = 'N' THEN 'No'
          ELSE SoldAsVacant
          END
FROM Portfolio..NashvilleHousing


UPDATE Portfolio..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
          WHEN SoldAsVacant = 'N' THEN 'No'
          ELSE SoldAsVacant
          END



-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID,
                     PropertyAddress,
                     SalePrice,
                     SaleDate,
                     LegalReference
                     ORDER BY
                        UniqueID
    ) row_num
FROM Portfolio..NashvilleHousing
-- ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-- Deleting Unused Columns


SELECT *
FROM Portfolio..NashvilleHousing


ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress

ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN SaleDate


