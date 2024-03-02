
-- CLEANING DATA IN SQL

select *
from NashvilleHousing

-- STANDARDIZE DATE FORMAT

select SaleDatetoConverted, CONVERT(Date, SaleDate)
from NashvilleHousing

alter table NashvilleHousing
add SaleDatetoConverted Date;

update nashvillehousing
set SaleDatetoConverted = CONVERT(Date, SaleDate)


--POPULATE PROPERTY ADDRESS DATA and REMOVING NULLS

select* --PropertyAddress
from nashvilleHousing
--where PropertyAddress is null
order by ParcelID

select PropertyAddress
from nashvilleHousing
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- BREAKING THE ADDRESS TO INDIVIDUAL COLUMNS (ADDRESS< CITY, CODE)


select PropertyAddress
from nashvilleHousing
--where PropertyAddress is null


--CHARINDEX looks for a positionn which is a number. not a string
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as State
from NashvilleHousing

alter table NashvilleHousing
add PropertySplittAddress Nvarchar(255);

update nashvillehousing
set PropertySplittAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

alter table NashvilleHousing
add PropertySplittCity Nvarchar(255);

update nashvillehousing
set PropertySplittCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))


select *
from NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update nashvillehousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update nashvillehousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update nashvillehousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from NashvilleHousing


--CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		else SoldAsVacant
		end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		else SoldAsVacant
		end


-- REMOVE DUPLICATES

WITH RowNumCTE as (
SELECT*,
	ROW_NUMBER() OVER (
	PARTITION by ParcelID,
				propertyAddress,
				salePrice,
				saleDate,
				legalReference
				ORDER by
					uniqueID
				) row_num
from NashvilleHousing
--order by ParcelID
)
select*
from RowNumCTE
where row_num > 1
order by PropertyAddress


-- DELETE UNUSED COLUMNS

select *
from NashvilleHousing

ALTER TABLE NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, TaxDistrict 

ALTER TABLE NashvilleHousing
Drop Column SaleDate
