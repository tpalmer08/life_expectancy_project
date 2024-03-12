-- Data Cleaning Using MySQL

-- With this dataset, there is no column with unique values
-- Due to this, we  must use below code to create new row with unique values
-- This allows us to determine if there are any duplicate rows and their row number.

Select *
From (select Row_ID,
concat(Country, Year),
Row_Number() OVER ( Partition By concat(Country, Year)) as row_num
From worldlifeexpectancy) as row_table
Where row_num > 1
;

-- Now we simply delete those rows

Delete From worldlifeexpectancy
WHERE Row_ID IN (
			Select Row_ID
			From (select Row_ID,
			concat(Country, Year),
			Row_Number() OVER ( Partition By concat(Country, Year)) as row_num
			From worldlifeexpectancy) as row_table
			Where row_num > 1)
;

-- Next will be populating blank data in the status field. There are only 2 values so I used code below

-- First "Developing"
update worldlifeexpectancy t1
join worldlifeexpectancy t2
	on t1.Country = t2.Country
Set t1.Status = 'Developing'
Where t1.Status = ''
And t2.Status <> ''
And t2.Status = 'Developing'
;

--  Next "Developed"
update worldlifeexpectancy t1
join worldlifeexpectancy t2
	on t1.Country = t2.Country
Set t1.Status = 'Developed'
Where t1.Status = ''
And t2.Status <> ''
And t2.Status = 'Developed'
;

-- The last thing I'm doing is populate missing info in the life expectancy field. Normally I would not do this if there was a lot of missing fields
-- However, since only 2 fields are missing I used the average of year before and after to fill in the missing info.

-- First code to find the average

SELECT t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3. `Life expectancy`)/2,1)
FROM worldlifeexpectancy t1
JOIN worldlifeexpectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN worldlifeexpectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

-- Finally updating info

UPDATE worldlifeexpectancy t1
JOIN worldlifeexpectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN worldlifeexpectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3. `Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''
;

-- Exploratory Data Analysis (EDA) us MySQL

-- First I will Show Max, Min and difference of Life Expectancy Per Country
Select country, min(`Life expectancy`) As Min_Life_Expectancy,
max(`Life expectancy`) As Max_Life_Expectancy,
Round(max(`Life expectancy`) - min(`Life expectancy`), 1) As Increase
FROM worldlifeexpectancy
Group By Country
Order By Increase DESC
;

-- **** Further cleaning. In first query I noticed 0's in the data. To remove these I ran the following****
Delete From worldlifeexpectancy
WHERE Row_ID IN (
	select Row_ID
    From(select row_id, country
	FROM worldlifeexpectancy
	where `Life expectancy` = 0)as no_info)
    ;
    -- --------------------------------------------------------------------------------------
    
 -- Next I pull aveage Life Expectancy by yer
Select Year, Round(AVG(`Life expectancy`), 1) As Avg_Life_Expectancy
FROM worldlifeexpectancy
Group By Year 
Order By year ASC
;

-- Next I pull average BMI vs Life Expectancy
Select Country, 
Round(AVG(BMI), 2) As Avg_BMI, 
Round(AVG(`Life expectancy`), 1) As Avg_Life_Expectancy
FROM worldlifeexpectancy
Group By Country 
Order By Avg_BMI ASC
;

-- Last one will be Country status and Life Expectancy
Select Status, 
Round(AVG(`Life expectancy`), 1) As Avg_Life_Expectancy
FROM worldlifeexpectancy
Group By Status 
Order By Avg_Life_Expectancy ASC
;

-- This is the end of the exploration, there are several more that can be done but for now i'll stick with these
-- Next I'll create some visuals! 