-- CLeaning Data in SQL Queries

Select *
From PortfolioProject.dbo.NashvilleHousing

-- ------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date,Saledate)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,Saledate)

-- Populate Property Address

Select PropertyAddress 
FROM PortfolioProject.dbo.NashvilleHousing

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b 
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b 
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking Out Address into Induvidual Columns (Address,City,State)

Select PropertyAddress 
FROM PortfolioProject.dbo.NashvilleHousing

Select substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address ,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET  PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)


Update NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))


Select OwnerAddress 
FROM PortfolioProject.dbo.NashvilleHousing
where OwnerAddress is not null;

Select 
PARSENAME(Replace(OwnerAddress,',' , '.'),3),
PARSENAME(Replace(OwnerAddress,',' , '.'),2),
PARSENAME(Replace(OwnerAddress,',' , '.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET  OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',' , '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255) 

Update NashvilleHousing
SET  OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',' , '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255) 

Update NashvilleHousing
SET  OwnerSplitState = PARSENAME(Replace(OwnerAddress,',' , '.'),1)



-- Change Y and N to Yes and No in "Sold as vacant" field

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant ,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant ='N' THEN 'No'
	 Else SoldAsVacant
	 END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant ='N' THEN 'No'
	 Else SoldAsVacant
	 END


-- Remove Duplicates

WITH RowNumCTE AS(
Select * , 
ROW_NUMBER() OVER ( 
Partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
Order by UniqueID) as row_num
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select* from RowNumCTE
where row_num > 1 

-- Delete Unused Columns

Alter table NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict , PropertyAddress 

Alter table NashvilleHousing
DROP COLUMN Saledate








