-- Data Cleaning --

Select * 
From PortfolioProject..NashvilleHousing

--Standardize Date Format
Select Saledate, CONVERT(Date, SaleDate) --Removed time part from the SaleDate
From PortfolioProject.dbo.NashvilleHousing

--Update PortfolioProject..NashvilleHousing
--Set SaleDate=CONVERT(Date, Saledate)

--Created New Column and Updated Saledate
Alter Table PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

--Populating Null values in Property Address 
Select *
From PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is NULL
order by ParcelID
--29 rows have null values in PropertyAddress

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a join
PortfolioProject.dbo.NashvilleHousing b 
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
-- Joined the table on itself to match misssing addresses based on ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IsNull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a join
PortfolioProject.dbo.NashvilleHousing b 
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
-- when a.PropertyAddress is null, put in there: b.PropertyAddress

--finally, Updating the rows 
Update a
Set PropertyAddress = Isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a join
	PortfolioProject.dbo.NashvilleHousing b 
	on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Address into Inividual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address1, --gives substring from postition 1 till (postition of ',')-1
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as AddressCity --gives substring from postition(postition of ',')+1 
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity  Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--Splitting Owner Addresses using ParseName
Select
ParseName(Replace(OwnerAddress,',','.'), 3),
ParseName(Replace(OwnerAddress,',','.'), 2),
ParseName(Replace(OwnerAddress,',','.'), 1)
from PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress=ParseName(Replace(OwnerAddress,',','.'), 3)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitCity  Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity= ParseName(Replace(OwnerAddress,',','.'), 2)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitState = ParseName(Replace(OwnerAddress,',','.'), 1)

Select *
from PortfolioProject.dbo.NashvilleHousing

--Editing values in SoldAsVacant column. Some are populated as 'Y' instead of a 'Yes'.
--Making it uniform
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order By 2

Select SoldAsVacant, CASE when SoldAsVacant='Y' Then 'Yes'
						  when SoldAsVacant='N' Then 'No'
						  Else SoldAsVacant
						  END
 from PortfolioProject.dbo.NashvilleHousing

 Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = CASE when SoldAsVacant='Y' Then 'Yes'
						  when SoldAsVacant='N' Then 'No'
						  Else SoldAsVacant
						  END

--Remove Duplicates
--Write CTE
-- look for records that have the same ParcelID,PropertyAddress,SalePrice, SaleDate, LegalReference
WITH RowNumCTE As(
Select *, 
	Row_Number() Over (Partition by ParcelID,PropertySplitAddress,
	SalePrice, SaleDateConverted, LegalReference Order BY UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
from RowNumCTE
where row_num>1
order by PropertySplitAddress
--104 duplicate records are found
--Deleting these 104 records
WITH RowNumCTE As(
Select *, 
	Row_Number() Over (Partition by ParcelID,PropertySplitAddress,
	SalePrice, SaleDateConverted, LegalReference Order BY UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Delete
from RowNumCTE
where row_num>1
--order by PropertyAddress

--Delete Unused Columns
Alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress
Alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate

Select *
from PortfolioProject.dbo.NashvilleHousing
