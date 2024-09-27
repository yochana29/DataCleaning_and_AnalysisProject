-- DATA CLEANING PROJECT
-- Step 1: View the original data
SELECT *
FROM layoffs;

-- Cleaning Steps:
-- 1.REMOVE DUPLICATES
-- 2. STANDARDISE THE DATA
-- 3. NULL VALUES  OR BLANK VALUES
-- 4. REMOVE ANY COLUMNS

-- Create a staging table to hold the data for cleaning

CREATE TABLE layoffs_staging
LIKE layoffs;

-- Check the structure of the staging table

SELECT *
FROM layoffs_staging;

-- Insert all records from the original table into the staging table

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Removing duplicates using a Common Table Expression (CTE)

SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, 
        percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoffs_staging;
    
    WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, 
                     percentage_laid_off, `date`, stage, country, 
                     funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
)

-- Select records that are duplicates (row_num > 1)

SELECT *
FROM duplicate_cte
WHERE row_num>1;

-- Example query to check records for a specific company (optional)

SELECT *
FROM layoffs_staging
WHERE company = "Casper";

WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, 
                     percentage_laid_off, `date`, stage, country, 
                     funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
)

-- Delete duplicate records from the staging table, keeping only one instance

DELETE
FROM duplicate_cte
WHERE row_num>1;

-- Create a new staging table for cleaned data with an additional row_num column

CREATE TABLE `layoffS_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num`  INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Check if there are any remaining duplicates in the new staging table (should be none)

SELECT *
FROM layoffs_staging2
where row_num>1;

-- Insert cleaned data into the new staging table with row numbers for duplicates

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, 
`date`, stage, country,funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Delete any remaining duplicates in the new staging table based on row numbers

DELETE
FROM layoffs_staging2
WHERE row_num > 1; 

-- View the cleaned data in the new staging table

SELECT *
FROM layoffs_staging2;

-- STANDARDIZING DATA

-- Remove leading and trailing whitespaces from company names

SELECT company,TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry names that start with "crypto"

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE "crypto%";

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE "crypto%";

-- Remove trailing periods from country names and check distinct values

SELECT DISTINCT country,TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
order by 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE "United States%";

-- Convert date strings to DATE format using STR_TO_DATE function

SELECT `date`,
STR_TO_DATE (`date`,'%m/%d/%Y') 
from layoffs_staging2 ;

update layoffs_staging2
set `date` = STR_TO_DATE (`date`,'%m/%d/%Y');

-- Alter the date column to ensure it is stored as a DATE type in the database

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- REMOVING NULL VALUES

-- Identify rows where both total_laid_off and percentage_laid_off are NULL 

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Update empty strings in the industry column to NULL values for consistency 

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

-- Check for any remaining NULL or empty values in the industry column 

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry='';

-- Example query to check records for a specific company 

SELECT *
FROM layoffs_staging2
WHERE company='Airbnb';

-- Fill in missing industries based on other records with the same company and location 

SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	on t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

 UPDATE layoffs_staging2 t1
 JOIN layoffs_staging2 t2
	on t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;
 
 -- View the updated data after filling in missing values 
 
 SELECT * 
 FROM layoffs_staging2;
 
-- Removing Rows

-- Identify rows where both total_laid_off and percentage_laid_off are still NULL 
 
 SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
 
 -- Delete rows where both total_laid_off and percentage_laid_off are NULL 

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- View the final cleaned data in the staging table 

 SELECT *
FROM layoffs_staging2;

-- Drop the row_num column as it is no longer needed after cleaning  
 
 ALTER TABLE layoffs_staging2
 DROP COLUMN row_num;
 
 -- END of Cleaning 
 
 
 