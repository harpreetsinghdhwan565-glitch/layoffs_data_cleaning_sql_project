select *
from layoffs
;
--- creation of raw table ---
CREATE TABLE layoffs (
    company VARCHAR(255),
    location VARCHAR(255),
    total_laid_off FLOAT,
    date VARCHAR(50),              
    percentage_laid_off FLOAT,
    industry VARCHAR(100),
    source TEXT,
    stage VARCHAR(100),
    funds_raised FLOAT,
    country VARCHAR(100),
    date_added VARCHAR(50)       
);
--- Adding raw data into the raw table ---
TRUNCATE TABLE layoffs;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/layoffs_yes.csv'
INTO TABLE layoffs
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    company, 
    location, 
    @vtotal_laid_off,       
    `date`, 
    @vpercentage_laid_off,  
    industry, 
    source, 
    stage, 
    @vfunds_raised,         
    country, 
    date_added
)
SET 
    total_laid_off = NULLIF(@vtotal_laid_off, ''),       
    percentage_laid_off = NULLIF(@vpercentage_laid_off, ''), 
    funds_raised = NULLIF(@vfunds_raised, '');           
--- creation of stagnent table ---

with duplicate_cte as (
select *,
row_number() over(partition by company, location,  `date`
 , industry, funds_raised, country, stage 
 order by company) as row_num
 from layoffs
 )
 select *
 from duplicate_cte
where row_num > 1
;

--- creation of new table for removing Removing Duplicate ---

CREATE TABLE `layoffs_1` (
  `company` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `total_laid_off` float DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  `percentage_laid_off` float DEFAULT NULL,
  `industry` varchar(100) DEFAULT NULL,
  `source` text,
  `stage` varchar(100) DEFAULT NULL,
  `funds_raised` float DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `date_added` varchar(50) DEFAULT NULL,
  `row_num`    int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


insert into layoffs_1

with duplicate_cte as (select *,
row_number() over(partition by company, location,  `date`
 , industry, funds_raised, country, stage ,percentage_laid_off, total_laid_off
 order by company) as row_num
 from layoffs
 )
select *
 from duplicate_cte
;

SET SQL_SAFE_UPDATES = 0;
-------------------------------------------------------------------------------------

delete
from layoffs_1
where row_num > 1;

--- creating table ready for edit ---

CREATE TABLE `layoffs_2` (
  `company` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `total_laid_off` float DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  `percentage_laid_off` float DEFAULT NULL,
  `industry` varchar(100) DEFAULT NULL,
  `source` text,
  `stage` varchar(100) DEFAULT NULL,
  `funds_raised` float DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `date_added` varchar(50) DEFAULT NULL,
  `row_num` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


insert into layoffs_2
select *
from layoffs_1
;

--- standardizing data  ---

-- company --
select distinct company, TRIM(leading'&' FROM TRIM(leading'#' FROM company))
from layoffs_2
;


update layoffs_2
SET company = TRIM(both '&' FROM TRIM(both '#' FROM company))
where company like '&%' or company like '#%'
;

select distinct company 
from layoffs_2
;

select distinct company, trim(company)
from layoffs_2
;

update layoffs_2
set company = trim(company)
;

-- industry --

select company, industry
from layoffs_2
where industry is null or industry = ''
group by company, industry
;

select distinct industry, trim(industry) 
from layoffs_2
;

update layoffs_2
set industry = trim(industry)
;

select company, industry
from layoffs_2
where industry is null or industry = ''
group by company, industry;

-- date --

update layoffs_2
set
   `date` = str_to_date(`date`,' %m/%d/%Y'),
    date_added = str_to_date(date_added, '%m/%d/%Y')
;
   
select *
from layoffs_2
;

-- country --

update layoffs_2
Set
    country = trim(country)
;

select distinct country
from layoffs_2
where country like 'u%'
;

update layoffs_2
set country = 'United Arab Emirates'
where country = 'UAE'
;

--- Adjusting null values or blank values


SELECT *
FROM layoffs_2 
where total_laid_off is null
And percentage_laid_off is null
;


DELETE
FROM layoffs_2 
where total_laid_off is null
And percentage_laid_off is null
;

---- deleting column ---

alter table layoffs_2
drop column row_num
;
------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------




