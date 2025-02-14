# Wolrd Life Expectancy Project (Data Cleaning)

-- Select all data from the world_life_expectancy table to inspect the raw data
SELECT * 
FROM world_life_expectancy;


-- Identify duplicate rows by concatenating Country and Year, and count occurrences
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY  Country, Year, CONCAT(Country, Year) 
HAVING COUNT(CONCAT(Country, Year)) > 1
;


-- Use a subquery with ROW_NUMBER() to identify duplicate rows based on Country and Year
SELECT *
FROM (
 SELECT Row_ID,
 CONCAT(Country,Year),
 ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
 FROM world_life_expectancy
) AS Row_table
WHERE Row_Num > 1
;
 
-- Delete duplicate rows identified in the previous step 
DELETE FROM world_life_expectancy
WHERE
 Row_ID IN (
 SELECT Row_ID
 FROM (
 SELECT Row_ID,
 CONCAT(Country,Year),
 ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
 FROM world_life_expectancy
) AS Row_table
WHERE Row_Num > 1
)
;


-- Disable safe update mode to allow updates without a key column in WHERE clause
SET sql_safe_updates = 0;


-- Select rows where the Status column is empty
SELECT * 
FROM world_life_expectancy
WHERE Status = ''
;

-- Select distinct non-empty Status values to understand the possible values
SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> ''
;

-- Select distinct countries where the Status is 'Developing'
SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;

-- Update rows with empty Status to 'Developing' based on the Status of the same country in other rows
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
 ON t1.Country = t2.Country
 SET t1.Status = 'Developing'
 WHERE t1.Status = ''
 AND t2.Status <> ''
 AND t2.Status = 'Developing'
 ;
 
 
 
 -- Update rows with empty Status to 'Developed' based on the Status of the same country in other rows
 UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
 ON t1.Country = t2.Country
 SET t1.Status = 'Developed'
 WHERE t1.Status = ''
 AND t2.Status <> ''
 AND t2.Status = 'Developed'
 ;
 
 
 -- Select rows where the Life expectancy column is empty
 SELECT *
 FROM world_life_expectancy
 WHERE `Life expectancy` = ''
 ;
 

 
 -- Calculate the average Life expectancy for rows with missing values based on the previous and next year's data
 SELECT t1.Country, t1.Year, t1.`Life expectancy`,
 t2.Country,t2.Year,t2.`Life expectancy`,
 t3.Country,t3.Year,t3.`Life expectancy`,
 ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
 FROM world_life_expectancy t1
 JOIN world_life_expectancy t2
 ON t1.Country = t2.Country
 AND t1.Year = t2.Year - 1
 JOIN world_life_expectancy t3
 ON t1.Country = t3.Country
  AND t1.Year = t3.Year + 1
  WHERE t1.`Life expectancy` = ''
  ;
 
 -- Update the Life expectancy column with the calculated average for rows with missing values
 UPDATE world_life_expectancy t1
 JOIN world_life_expectancy t2
 ON t1.Country = t2.Country
 AND t1.Year = t2.Year - 1
 JOIN world_life_expectancy t3
 ON t1.Country = t3.Country
  AND t1.Year = t3.Year + 1
 SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
 WHERE t1.`Life expectancy` = ''
 ;
 
 
 -- Select all data to inspect the cleaned dataset
 SELECT *
 FROM world_life_expectancy
 ;

 
 
 #Wolrd Life Expectancy Project (Exploratory Data Analysis)
 
 -- Select all data to start the exploratory analysis
 SELECT * 
FROM world_life_expectancy;


-- Calculate the increase in life expectancy over 15 years for each country
 SELECT Country,
 MIN(`Life expectancy`),
 MAX(`Life expectancy`),
 ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increse_Over_15_Years
 FROM world_life_expectancy
 GROUP BY Country
 HAVING MIN(`Life expectancy`) <> 0
 AND MAX(`Life expectancy`) <> 0
 ORDER BY Life_Increse_Over_15_Years DESC
 ;
 
 -- Calculate the average life expectancy per year
SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
 WHERE `Life expectancy` <> 0
 AND `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year;

-- Calculate the average life expectancy and GDP per country
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0 
AND GDP > 0
ORDER BY GDP DESC
;



-- Compare life expectancy between countries with high and low GDP
SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) HIGH_GDP_COUNT,
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) HIGH_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) LOW_GDP_COUNT,
AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) LOW_GDP_Life_Expectancy
FROM world_life_expectancy
;

-- Select all data for further analysis
SELECT *
FROM world_life_expectancy
;

-- Calculate the average life expectancy by status (Developed vs Developing)
SELECT Status, ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;

-- Count the number of distinct countries by status
SELECT Status, COUNT(DISTINCT Country)
FROM world_life_expectancy
GROUP BY Status
;

-- Calculate the average life expectancy and BMI per country
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0 
AND BMI > 0
ORDER BY BMI ASC
;


1. The analysis reveals that GDP and development status significantly impact life expectancy, with developed and high-GDP countries showing higher life expectancy.  
2. Life expectancy has increased globally over the years, but disparities remain between developed and developing nations.  
3. BMI correlates with life expectancy, indicating healthier lifestyles contribute to longer lives.  
4. The dataset was cleaned by removing duplicates, imputing missing values, and ensuring consistency for accurate analysis.  
5. Targeted interventions in healthcare, economic growth, and healthy lifestyles are essential to bridge the life expectancy gap, especially in developing countries.