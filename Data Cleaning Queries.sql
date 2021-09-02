
-- CLEANING HOUSING DATA IN SQL SERVER WITH QUERIES

SELECT * 
FROM PortfolioProject..NashvilleHousing

-- STANDARDIZE DATE FORMAT 

SELECT SaleDateConverted, CONVERT(DATE, SALEDATE)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SALEDATE)

ALTER TABLE NASHVILLEHOUSING
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SALEDATE)

-- POPULATE PROPERTY ADDRESS DATA 

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A 
JOIN PortfolioProject..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A 
JOIN PortfolioProject..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

-- SEPERATING THE ADDRESS INTO SEPERATE COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',', PROPERTYADDRESS)-1) AS ADDRESS
, SUBSTRING(PROPERTYADDRESS, CHARINDEX(',', PROPERTYADDRESS)+1, LEN(PROPERTYADDRESS)) AS ADDRESS
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PROPERTYSPLITADDRESS NVARCHAR(255);

UPDATE NashvilleHousing
SET PROPERTYSPLITADDRESS = SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',', PROPERTYADDRESS)-1)

ALTER TABLE NashvilleHousing
ADD PROPERTYSPLITCITY NVARCHAR(255);

UPDATE NashvilleHousing
SET PROPERTYSPLITCITY = SUBSTRING(PROPERTYADDRESS, CHARINDEX(',', PROPERTYADDRESS)+1, LEN(PROPERTYADDRESS))

SELECT *
FROM PortfolioProject..NashvilleHousing

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject..NashvilleHousing

-- CHANGING Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- REMOVING DUPLICATE DATA 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

Select *
From PortfolioProject..NashvilleHousing

-- DELETE UNUSED COLUMNS 

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate