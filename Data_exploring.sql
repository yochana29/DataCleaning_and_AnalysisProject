-- Select all records from the layoffs staging table
SELECT * 
FROM layoffs_staging2;

-- Get the maximum total laid off and percentage laid off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Select companies where the percentage laid off is 100% and order by funds raised
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Summarize total laid off by company and order by total laid off
SELECT company, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Get the minimum and maximum dates from the dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Summarize total laid off by industry and order by total laid off
SELECT industry, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Select all records from the layoffs staging table again
SELECT * 
FROM layoffs_staging2;

-- Summarize total laid off by year and order by year descending
SELECT YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Summarize total laid off by stage and order by total laid off
SELECT stage, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Summarize percentage laid off by company and order by total percentage laid off
SELECT 
    company, SUM(percentage_laid_off)
FROM
    layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Summarize total laid off by month
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC;

-- Calculate rolling total of laid off employees by month
WITH rolling_total AS
(
    SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `month`
    ORDER BY 1 ASC
)
SELECT `month`, total_off, SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM rolling_total;

-- Summarize percentage laid off by company again
SELECT 
    company, SUM(percentage_laid_off)
FROM
    layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Summarize total laid off by company and year
SELECT 
    company, YEAR(`date`), SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Get the top 5 companies by total laid off per year
WITH company_year(company, years, total_laid_off) AS
(
    SELECT company, YEAR(`date`), SUM(total_laid_off)
    FROM
        layoffs_staging2
    GROUP BY company, YEAR(`date`)
), company_year_rank AS
(
    SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
    FROM company_year
    WHERE years IS NOT NULL
)
SELECT * 
FROM company_year_rank
WHERE ranking <= 5;
