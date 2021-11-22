Select *
From PortfolioProject_SQLDE1..NashvilleHousing

-- Standardize Date Format
-- Convert SaleDate into standardize date format (Methode 1)
Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject_SQLDE1..NashvilleHousing

-- Convert SaleDate into standardize date format (Methode 2)
Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Convert SaleDate into standardize date format (Methode 3)
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
From PortfolioProject_SQLDE1..NashvilleHousing


-- Populate property address

Select *
From PortfolioProject_SQLDE1..NashvilleHousing
Where PropertyAddress is NULL
Order by ParcelID

-- ISNULL populates the address missing
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, B.PropertyAddress)
From PortfolioProject_SQLDE1..NashvilleHousing a
Join PortfolioProject_SQLDE1..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, B.PropertyAddress)
From PortfolioProject_SQLDE1..NashvilleHousing a
Join PortfolioProject_SQLDE1..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject_SQLDE1..NashvilleHousing
--Where PropertyAddress is NULL
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject_SQLDE1..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject_SQLDE1..NashvilleHousing

-- Simpler way (without using substring)

Select OwnerAddress
From PortfolioProject_SQLDE1..NashvilleHousing

SELECT 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) as Address -- Parsename only recognises '.' so we replace ',' by '.'
, PARSENAME(Replace(OwnerAddress, ',', '.'), 2) as City -- Parsename works backwords
, PARSENAME(Replace(OwnerAddress, ',', '.'), 1) as State
From PortfolioProject_SQLDE1..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject_SQLDE1..NashvilleHousing


-- Change Y and N to Yes and No in 'Sold as vacant' field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject_SQLDE1..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
From PortfolioProject_SQLDE1..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
From PortfolioProject_SQLDE1..NashvilleHousing

-- Remove duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
From PortfolioProject_SQLDE1..NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1

--Select *
--From RowNumCTE
--Where row_num > 1


-- Delete Unused Columns

Select *
From PortfolioProject_SQLDE1..NashvilleHousing

Alter Table PortfolioProject_SQLDE1..NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject_SQLDE1..NashvilleHousing
Drop column SaleDate
