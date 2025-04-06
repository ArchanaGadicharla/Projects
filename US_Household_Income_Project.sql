
#US_HOUSEHOLD_INCOME DATA CLEANING.


-- View all records in the us_household_income table
SELECT *
FROM us_household_income;

-- View all records in the us_household_income_statistics table
SELECT *
FROM us_household_income_statistics;

-- Rename incorrectly encoded column name to 'id' in the statistics table
ALTER TABLE us_household_income_statistics
 RENAME COLUMN ` ï»¿id` TO `id`;

-- Count the number of rows (records) in each table
SELECT COUNT(id)
FROM us_household_income;

-- Count the number of rows (records) in each table
SELECT COUNT(id)
FROM us_household_income_statistics;

-- Check for duplicate IDs in the household_income table
SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id
HAVING COUNT(id) > 1;


-- Enable safe updates (though here it's turned off afterward)
SET sql_safe_updates = 1; 
SET sql_safe_updates = 0; 


-- Remove duplicate rows by keeping only the first occurrence based on ID
DELETE FROM us_household_income
WHERE row_id IN (
    SELECT row_id
    FROM (
        SELECT id,
               row_id,
               ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
        FROM us_household_income
    ) AS duplicates
    WHERE row_num > 1
);
     

-- Check for duplicate IDs in the statistics table
SELECT id, COUNT(id)
FROM us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1;

-- Recheck all IDs for validation
SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id;

-- List all unique state names to check for inconsistencies or typos
SELECT DISTINCT State_Name
FROM us_project.us_household_income
ORDER BY 1;

-- Turn off SQL safe updates (needed for direct UPDATEs)
SET sql_safe_updates = 0; 

-- Fix typo: 'georia' → 'Georgia'
UPDATE us_project.us_household_income  
SET State_Name = 'Georgia'  
WHERE State_Name = 'georia';

-- Fix typo: 'alabama' → 'Alabama'
UPDATE us_project.us_household_income  
SET State_Name = 'Alabama'  
WHERE State_Name = 'alabama';

-- Find rows where 'Place' is blank to identify missing data
SELECT *
FROM us_household_income
WHERE place = '';

-- Fill in missing place name for a specific county and city
UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont';

-- Count different values in the 'Type' column (check for typos)
SELECT Type, COUNT(Type)
FROM us_project.us_household_income
GROUP BY Type;

-- Fix typo: 'Borouugh' → 'Borough
UPDATE us_project.us_household_income
SET Type = 'Borough'
WHERE Type = 'Borouugh';

-- Check rows where AWATER = 0 (could indicate missing or invalid data)
SELECT ALAND, AWATER
FROM us_project.us_household_income
WHERE AWATER = 0 ;

-- Check rows where ALAND = 0
SELECT ALAND, AWATER
FROM us_project.us_household_income
WHERE ALAND = 0 ;


#US HOUSEHOLD INCOME EXPLORATORY DATA ANALYSIS

-- Preview all data from  table before analysis
SELECT *
FROM us_household_income;

-- Preview all data from both tables before analysis
SELECT *
FROM us_household_income_statistics;

-- Top 10 states by total land area (ALAND)
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_household_income
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10; 

-- Top 10 states by total water area (AWATER)
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_household_income
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10;


-- Join both tables on id to prepare for combined analysis
SELECT *
FROM us_household_income u
INNER JOIN us_household_income_statistics us
ON u.id = us.id
;


-- Select relevant fields and remove rows where Mean income = 0
SELECT u.State_Name, County, Type, `Primary`, Mean, Median
FROM us_household_income u
INNER JOIN us_household_income_statistics us
ON u.id = us.id
WHERE Mean <> 0;

-- Calculate average Mean and Median income by State
SELECT u.State_Name, ROUND(AVG(Mean),2) ,ROUND(AVG(Median),2)
FROM us_household_income u
INNER JOIN us_household_income_statistics us
 ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 2 DESC
LIMIT 5;


-- Average median income by city (sorted by average mean income for more insight)
SELECT u.State_Name, City, ROUND(AVG(MEDIAN),1)
FROM us_household_income u
JOIN us_household_income_statistics us
 ON u.id = us.id
 GROUP BY State_Name, City
 ORDER BY ROUND(AVG(MEAN),1) DESC;
 
 
 -- Data Cleaning
#Renamed malformed column ï»¿id to id in us_household_income_statistics.
# Removed duplicate records in us_household_income using ROW_NUMBER() function.
# Corrected spelling errors in State_Name (e.g., georia → Georgia, alabama → Alabama).
# Fixed typo in Type column (Borouugh → Borough).
# Identified and filled missing Place entries based on County and City.
# Checked and flagged entries where ALAND or AWATER was 0 (possible data issues).

