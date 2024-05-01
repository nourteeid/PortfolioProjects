/* Cleaning Data in SQL */ 

SELECT *
FROM NashvilleHousing

-- Change sale date
SELECT SaleDate, CONVERT(Date,SaleDate) 
FROM NashvilleHousing

Update NashvilleHousing 
SET SaleDate = CONVERT(Date,SaleDate)

SELECT SaleDate
FROM NashvilleHousing


-- Populate property Address 
--SELECT  PropertyAddress, OwnerAddress, ParcelID
--FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT N1.ParcelID, N1.PropertyAddress, N2.ParcelID, N2.PropertyAddress, ISNULL(N1.PropertyAddress, N2.PropertyAddress) 
FROM NashvilleHousing N1 JOIN NashvilleHousing N2
ON N1.ParcelID = N2.ParcelID
AND N1.[UniqueID ] <> N2.[UniqueID ]
WHERE N1.PropertyAddress IS NULL 

UPDATE N1
SET PropertyAddress = ISNULL(N1.PropertyAddress, N2.PropertyAddress) 
FROM NashvilleHousing N1 JOIN NashvilleHousing N2
ON N1.ParcelID = N2.ParcelID
AND N1.[UniqueID ] <> N2.[UniqueID ]
WHERE N1.PropertyAddress IS NULL 

-- Breaking out address into individual columns
SELECT PropertyAddress
FROM NashvilleHousing


SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address ,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyFixedAddress Nvarchar(255); 

UPDATE NashvilleHousing
SET PropertyFixedAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyFixedCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyFixedCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM NashvilleHousing

-- Cleaning and Transforming OwnerAddress
SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) ,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) --Parsename only detects periods 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerAddressState Nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerAddressState =  PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

ALTER TABLE NashvilleHousing
ADD OwnerAddressCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressCity= PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerAddressStreet Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressStreet=  PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


-- Change Y N into Yes No into Yes No in SoldAsVacant 
 SELECT DISTINCT(SoldAsVacant)
 FROM NashvilleHousing

 SELECT SoldAsVacant,
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


-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *, ROW_NUMBER()
OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID) AS Row_Num
FROM NashvilleHousing 
)

DELETE
From RowNumCTE
WHERE ROW_NUM > 1




-- Remove unused columns

Select * From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,PropertyAddress, TaxDistrict 

