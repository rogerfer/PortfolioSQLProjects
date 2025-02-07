/*
	Cleaning Data in SQL Queries
*/

SELECT *
FROM PortfolioProject.dbo.[dbo.NashvilleHousing]

----------------------------------------------------------------------------------------

--Standardize Date Format	

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.[dbo.NashvilleHousing]


UPDATE PortfolioProject.dbo.[dbo.NashvilleHousing]
SET SaleDate = CONVERT(Date.SaleDate)

ALTER TABLE PortfolioProject.dbo.[dbo.NashvilleHousing]
Add SaleDateConverted Date;

UPDATE PortfolioProject.dbo.[dbo.NashvilleHousing]
SET SaleDateConverted = CONVERT(Date,SaleDate)

----------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT *
FROM PortfolioProject.dbo.[dbo.NashvilleHousing]
--WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.[dbo.NashvilleHousing] a
JOIN PortfolioProject.dbo.[dbo.NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- aqui fazemos o update para os valores NULL não aparecer na tabela PropertyAddress
--onde depois na querie em cima verificamos entao se não existem valores nulos
--Basicamente os valores NULL na tabela a.PropertyAddress, vão ser preenchidos pelos valores de  b.PropertyAddress, numa outra tabela
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.[dbo.NashvilleHousing] a
JOIN PortfolioProject.dbo.[dbo.NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.[dbo.NashvilleHousing]
--WHERE PropertyAddress is NULL
--ORDER BY ParcelID

---------------------------------------------------------------------
--SUBSTRING
--separar o que existe em PropertyAddress, entre ","
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) As Address
FROM PortfolioProject.dbo.[dbo.NashvilleHousing]



--ao fazer split criamos sempre 2 colunas com o nome Address
--agora vamos criar na mesma, mas um coluna vai se chamar Address e a outra City
--que ao criar essas colunas vao ficar como últimas colunas.
--SUBSTRING(expression, start, length)

ALTER TABLE PortfolioProject.dbo.[dbo.NashvilleHousing]
ADD PropertySplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.[dbo.NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE PortfolioProject.dbo.[dbo.NashvilleHousing]
ADD PropertySplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.[dbo.NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--------------------------------------------------------------------------
--ParseName (mais simples que substring)
--Vamos separar Address, City e State, da coluna OwnerAddress
-- vão ser criadas separadamente, no final da tabela
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject.dbo.[dbo.NashvilleHousing]


ALTER TABLE PortfolioProject.dbo.[dbo.NashvilleHousing]
ADD OwnerSplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.[dbo.NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



ALTER TABLE PortfolioProject.dbo.[dbo.NashvilleHousing]
ADD OwnerSplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.[dbo.NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject.dbo.[dbo.NashvilleHousing]
ADD OwnerSplitState Nvarchar(255)

UPDATE PortfolioProject.dbo.[dbo.NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



SELECT *
FROM PortfolioProject.dbo.[dbo.NashvilleHousing]

--------------------------------------------------------------------------------------------------------------------------------


--Change "Y" and "N", to "Yes" and "No" in column "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.[dbo.NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

--Vamos alterar todas as rows que tenham Y e N

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.[dbo.NashvilleHousing]


UPDATE PortfolioProject.dbo.[dbo.NashvilleHousing]
SET  SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

--Para encontrar os duplicados, usando CTE

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
FROM PortfolioProject.dbo.[dbo.NashvilleHousing]
)
SELECT *     /*DELETE*/
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--------------------------------------------------------------------------------------------------------------------------------


--Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.[dbo.NashvilleHousing]

ALTER TABLE PortfolioProject.dbo.[dbo.NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.[dbo.NashvilleHousing]
DROP COLUMN SaleDate