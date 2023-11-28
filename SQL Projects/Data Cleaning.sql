/*

Cleaning Data in SQL Queries

*/

Select * 
from PortfolioProject..NashVille

-- Standardize Date Format

Select SaleDate2, convert(date, SaleDate) 
from PortfolioProject..NashVille

Update PortfolioProject..NashVille
Set SaleDate = convert(date, SaleDate)

--If UPDATE function doesn't work properly

-- Add a new column to the table
ALTER TABLE PortfolioProject..Nashville
ADD SaleDate2 DATE;

-- Update the values in the new column based on the SaleDate column
UPDATE Nashville
SET SaleDate2 = CONVERT(DATE, SaleDate);

--Deleting a column 

Alter table PortfolioProject..Nashville
drop column SaleDateConverted


-- Populate Property Address data (Imputation)

Select * 
from PortfolioProject..NashVille
order by ParcelID


Select Nash1.ParcelID, Nash1.PropertyAddress, Nash2.ParcelID, Nash2.PropertyAddress, ISNULL(Nash1.PropertyAddress,Nash2.PropertyAddress)
From PortfolioProject.dbo.Nashville Nash1
JOIN PortfolioProject.dbo.Nashville Nash2
    on Nash1.ParcelID = Nash2.ParcelID
    AND Nash1.[UniqueID ] <> Nash2.[UniqueID ]
Where Nash1.PropertyAddress is null

Update Nash1
Set PropertyAddress = ISNULL(Nash1.PropertyAddress,Nash2.PropertyAddress)
From PortfolioProject.dbo.Nashville Nash1
JOIN PortfolioProject.dbo.Nashville Nash2
    on Nash1.ParcelID = Nash2.ParcelID
    AND Nash1.[UniqueID ] <> Nash2.[UniqueID ]
Where Nash1.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

 Select
 SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
 from PortfolioProject..NashVille

  Select
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as city
 from PortfolioProject..NashVille

 ALTER TABLE PortfolioProject..NashVille
 ADD Adress Nvarchar(255);

 Update PortfolioProject..NashVille
 SET Adress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


 ALTER TABLE PortfolioProject..NashVille
 ADD City Nvarchar(255);

  Update PortfolioProject..NashVille
 SET City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select 
PARSENAME(Replace(OwnerAddress,',','.'),1)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),3)
from PortfolioProject..NashVille
--where OwnerAddress is not null

ALTER TABLE PortfolioProject..NashVille
ADD OwnerSplitAddress NvarChar(255);

update PortfolioProject..NashVille
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject..NashVille
ADD OwnerSplitCity NvarChar(255);

update PortfolioProject..NashVille
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..NashVille
ADD OwnerSplitState NvarChar(255);

update PortfolioProject..NashVille
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)


Select * 
from PortfolioProject..NashVille

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashVille
Group by SoldAsVacant
order by 2


Select SoldAsVacant 
, Case When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
from PortfolioProject..NashVille

Update PortfolioProject..NashVille
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End

-- Remove Duplicates

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

From PortfolioProject.dbo.Nashville
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--Deleting unnecessary columns


Alter Table PortfolioProject..NashVille
Drop Column SaleDate, PropertyAddress, OwnerAddress



Select *
From PortfolioProject.dbo.Nashville