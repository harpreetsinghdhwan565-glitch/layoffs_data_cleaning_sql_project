# Tech Layoffs Data Cleaning Project (MySQL)

## 📌 Project Overview
This project focuses on transforming a messy, raw dataset containing global tech layoff records into a structured, clean format optimized for exploratory data analysis (EDA). The data spans multiple countries, industries, and funding stages.

## 🛠️ Tech Stack & Skills Used
* **Database Management System:** MySQL Server 8.0
* **SQL Advanced Concepts:** Common Table Expressions (CTEs), Window Functions (`ROW_NUMBER()`), Data Type Modifications (`STR_TO_DATE`), String Manipulation (`TRIM`), Self-Joins.

## 🔄 Data Cleaning Pipeline & Steps Taken

### 1. Data Staging & Warehousing
* Created a raw table (`layoffs`) and utilized `NULLIF` during data import to handle missing strings and correctly cast empty spaces into database `NULL` values.
* Implemented a multi-stage staging pattern (`layoffs_1` and `layoffs_2`) to safeguard the raw data while transformations were being applied.

### 2. Removing Structural Duplicates
* Used a CTE combined with `ROW_NUMBER() OVER (PARTITION BY ...)` to look across multiple structural columns (Company, Location, Date, Industry, Stage) to identify exact duplicate entries.
* Permanently deleted duplicate records keeping only the unique baseline row.

### 3. Standardization & Text Normalization
* **Company Names:** Cleaned up scraping artifacts by removing leading special characters like `#` and `&` (e.g., converting `#Paid` to `Paid`) and trimming all trailing whitespaces.
* **Country Names:** Standardized regional acronyms (mapped `UAE` to `United Arab Emirates`) and trimmed inconsistent spaces.
* **Date Parsing:** Transformed text date strings (`MM/DD/YYYY`) into MySQL native standard date entries via `STR_TO_DATE`.

### 4. Handling Nulls & Finalizing Schema
* Filtered and dropped useless rows where both critical fields (`total_laid_off` and `percentage_laid_off`) were entirely missing, ensuring every row provides analytical value.
* Dropped metadata helper columns (`row_num`) used during deduplication to optimize production table storage.

## 📂 Repository Structure
* `/data/layoffs_raw.csv`: Uncleaned source dataset.
* `/data/layoffs_cleaned.csv`: Final production-ready dataset exported from MySQL.
* `data_cleaning_pipeline.sql`: The complete, runnable MySQL cleaning script.
