
-- Cleaning Data in SQL Queries

select * from NashvilleHousing


--Standardize Date Format
select SaleDate,cast(SaleDate as Date)
from NashvilleHousing

update NashvilleHousing
set SaleDate = cast(SaleDate as Date)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = cast(SaleDate as Date)

--- Populate Property Address data
select *
from NashvilleHousing
---where PropertyAddress is null
order by ParceLID


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,Isnull(a.PropertyAddress,b.PropertyAddress) from 
NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID and a.uniqueid <> b.uniqueid
where a.PropertyAddress is null

Update a
set PropertyAddress = Isnull(a.PropertyAddress,b.PropertyAddress)
from 
NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID and a.uniqueid <> b.uniqueid
where a.PropertyAddress is null
-------------------------------------------------------------------
-- Breaking out Address Into individual Columns ( Address, City, State )
select PropertyAddress
from NashvilleHousing
---where PropertyAddress is null
--order by ParceLID
select PropertyAddress,
Substring(PropertyAddress,1,Charindex(',',PropertyAddress)-1) AS Address,
Substring(PropertyAddress,Charindex(',',PropertyAddress)+1,len(PropertyAddress))
from NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(225);

update NashvilleHousing
set PropertySplitAddress= Substring(PropertyAddress,1,Charindex(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(225);

update NashvilleHousing
set PropertySplitCity = Substring(PropertyAddress,Charindex(',',PropertyAddress)+1,len(PropertyAddress))

select ownerAddress from NashvilleHousing

select  
Parsename(replace(ownerAddress,',','.'),3),
Parsename(replace(ownerAddress,',','.'),2),
Parsename(replace(ownerAddress,',','.'),1)
from NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(225);

update NashvilleHousing
set OwnerSplitAddress= Parsename(replace(ownerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(225);

update NashvilleHousing
set OwnerSplitCity =Parsename(replace(ownerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(225);

update NashvilleHousing
set OwnerSplitState =Parsename(replace(ownerAddress,',','.'),1)

select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	end
from NashvilleHousing
update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	end
select distinct SoldAsVacant from NashvilleHousing

----------------------------------------------------------------------\
--Remove Duplicates
With newtb as (
select *,
	Row_number () Over (
	Partition  by   ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by UniqueID ) row_num
from NashvilleHousing) 
--where row_num = '2' 
select * from newtb 
where row_num > 1
Delete
from newtb 
where row_num > 1
----order by PropertyAddress
select * from newtb 
where row_num > 1