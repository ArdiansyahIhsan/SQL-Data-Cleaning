--Import dataset

CREATE TABLE NashvilleHousing (
    UniqueID SERIAL PRIMARY KEY,
    ParcelID VARCHAR(50),
    LandUse VARCHAR(100),
    PropertyAddress VARCHAR(255),
    SaleDate DATE,
    SalePrice NUMERIC(15,2),
    LegalReference VARCHAR(100),
    SoldAsVacant VARCHAR(10),
    OwnerName VARCHAR(150),
    OwnerAddress VARCHAR(255),
    Acreage FLOAT,
    TaxDistrict VARCHAR(100),
    LandValue NUMERIC(15,2),
    BuildingValue NUMERIC(15,2),
    TotalValue NUMERIC(15,2),
    YearBuilt INT,
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
);

ALTER TABLE nashvillehousing
ALTER COLUMN Acreage TYPE VARCHAR(50),
ALTER COLUMN TaxDistrict TYPE VARCHAR(50),
ALTER COLUMN LandValue TYPE VARCHAR(50),
ALTER COLUMN BuildingValue TYPE VARCHAR(50),
ALTER COLUMN TotalValue TYPE VARCHAR(50),
ALTER COLUMN YearBuilt TYPE VARCHAR(50),
ALTER COLUMN Bedrooms TYPE VARCHAR(50),
ALTER COLUMN FullBath TYPE VARCHAR(50),
ALTER COLUMN HalfBath TYPE VARCHAR(50);
---------------------------------------------------------------------------------

--Populate Property Address data
select * from nashvillehousing

Select
	*
from
	nashvillehousing
-- Where propertyaddress IS NULL
Order By Parcelid

Select
	a.parcelid,
	a.propertyaddress,
	b.parcelid,
	b.propertyaddress,
	Coalesce(a.propertyaddress,b.propertyaddress)
From 
	nashvillehousing as a
Join nashvillehousing as b
	ON a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
Where a.propertyaddress IS NULL

Update nashvillehousing as a
Set propertyaddress = Coalesce(a.propertyaddress,b.propertyaddress)
From 
	nashvillehousing as b
Where
	a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
	AND a.propertyaddress IS NULL
------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Column (Address, City, State)
Select
	propertysplitaddress,
	PropertySplitCity
From nashvillehousing

Select
	Substring(propertyaddress From 1 For STRPOS(propertyaddress, ',') -1) As Address,
	Substring(propertyaddress From STRPOS(propertyaddress, ',') +1) As Address
From
	nashvillehousing

Alter Table nashvillehousing
Add PropertySplitAddress VARCHAR(255)

Update nashvillehousing
Set PropertySplitAddress = Substring(propertyaddress From 1 For STRPOS(propertyaddress, ',') -1)

Alter Table nashvillehousing
Add PropertySplitCity VARCHAR(255)

Update nashvillehousing
Set PropertySplitCity = Substring(propertyaddress From STRPOS(propertyaddress, ',') +1)


Select
	SPLIT_PART(Owneraddress, ',', 1) As Address,
	SPLIT_PART(Owneraddress, ',', 2) As City,
	SPLIT_PART(Owneraddress, ',', 3) As State
From
	nashvillehousing

Alter Table nashvillehousing
Add OwnerSplitAddress VARCHAR(255)

Update nashvillehousing
Set OwnerSplitAddress = SPLIT_PART(Owneraddress, ',', 1)

Alter Table nashvillehousing
Add OwnerSplitCity VARCHAR(255)

Update nashvillehousing
Set OwnerSplitCity = SPLIT_PART(Owneraddress, ',', 2)

Alter Table nashvillehousing
Add OwnerSplitState VARCHAR(255)

Update nashvillehousing
Set OwnerSplitState = SPLIT_PART(Owneraddress, ',', 3)

Select
	ParcelID,
	OwnerSplitAddress,
	OwnerSplitCity,
	OwnerSplitState
From
	nashvillehousing
Order BY parcelId

--------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select *
From
	nashvillehousing

Select 
	Distinct(soldasvacant),
	Count(soldasvacant)
From
	nashvillehousing
Group By soldasvacant
Order BY 2

Select
	SoldAsVacant,
	Case When SoldAsVacant = 'N' Then 'No'
		 When SoldAsVacant = 'Y' Then 'Yes'
		 Else SoldAsVacant
	END
From
	nashvillehousing

Update nashvillehousing
Set SoldAsVacant = Case When SoldAsVacant = 'N' Then 'No'
						When SoldAsVacant = 'Y' Then 'Yes'
						Else SoldAsVacant
				   END
				   
----------------------------------------------------------------------------------------------

-- Remove Duplicates
With RowNumCTE As(
Select 
	*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 	UniqueID
	) As row_num
From 
	nashvillehousing
)
Select *
From RowNumCTE
Where 
	row_num > 1

	
With RowNumCTE As(
Select 
	UniqueID,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 	UniqueID
	) As row_num
From 
	nashvillehousing
)
DELETE
From nashvillehousing
Where 
	UniqueID IN (
	Select UniqueID From RowNumCTE Where row_num > 1
	);

-------------------------------------------------------------------------------------------

--Delete Unused Column
Select *
From
	nashvillehousing

Alter Table nashvillehousing
DROP COLUMN PropertyAddress,
DROP COLUMN Owneraddress,
DROP COLUMN TaxDistrict

---------------------------------------------------------------------------------------------






