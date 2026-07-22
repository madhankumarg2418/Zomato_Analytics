select * from zomata;
select * from country;
-- Question 1:
-- Build a Data Model using the given Excel Sheets. Import all the tables into MySQL and create the relationships using Primary Key and Foreign Key.

SELECT RestaurantName,country.Country_Name FROM zomata
INNER JOIN country 
ON zomata.CountryCode = country.countrycode;

-- Question 2:
-- Build a Calendar Table using the Opening Date columns (Year_Opening, Month_Opening, Day_Opening).
-- Add the following columns:
-- • Opening_Date
-- • Year
-- • Month Number
-- • Month Full Name
-- • Quarter (Q1–Q4)
-- • YearMonth (YYYY-MMM)
-- • Weekday Number
-- • Weekday Name
-- • Financial Month (April = FM1, May = FM2, ..., March = FM12)
-- • Financial Quarter (FQ1–FQ4)

SELECT
STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d') AS Opening_Date,

YEAR(STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d')) AS Year,

MONTH(STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d')) AS Month_No,

MONTHNAME(STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d')) AS Month_Name,

CONCAT('Q',QUARTER(STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d'))) AS Quarter,

DATE_FORMAT(STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d'),'%Y-%b') AS YearMonth,

DAYOFWEEK(STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d')) AS Weekday_No,

DAYNAME(STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d')) AS Weekday_Name,

CASE
WHEN MONTH(STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d')) >= 4
THEN CONCAT('FM',MONTH(STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d'))-3)
ELSE CONCAT('FM',MONTH(STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d'))+9)
END AS Financial_Month,

CASE
WHEN MONTH(STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d')) BETWEEN 4 AND 6 THEN 'FQ1'
WHEN MONTH(STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d')) BETWEEN 7 AND 9 THEN 'FQ2'
WHEN MONTH(STR_TO_DATE(CONCAT(year_opening,'-',month_opening,'-',day_opening),'%Y-%m-%d')) BETWEEN 10 AND 12 THEN 'FQ3'
ELSE 'FQ4'
END AS Financial_Quarter

FROM zomata;

-- Question 3:
-- Convert the Average_Cost_for_two column into USD using the Currency table and USD_Rate.

SELECT z.RestaurantName,z.Currency,z.Average_Cost_for_two,c.USD_Rate,
    ROUND(z.Average_Cost_for_two / c.USD_Rate, 2) AS Cost_USD
FROM zomata z JOIN currency c ON z.Currency = c.Currency;

-- Question 4:
-- Find the Number of Restaurants based on City and Country.

SELECT C.COUNTRY_NAME,z.CITY,COUNT(*) RESTAURANTS FROM  zomata z JOIN COUNTRY C ON z.COUNTRYCODE=C.countrycode GROUP BY
C.COUNTRY_NAME, z.CITY ORDER BY  RESTAURANTS desc;

-- Question 5:
-- Find the Number of Restaurants Opening based on Year, Quarter, and Month.
-- year
SELECT YEAR_OPENING,COUNT(*) TOTAL FROM zomata GROUP BY YEAR_OPENING ORDER BY YEAR_OPENING;
-- quarter
SELECT Year_Opening, Month_Opening,Quarter,COUNT(*) AS Restaurant_Count FROM
( SELECT YEAR_OPENING AS Year_Opening, MONTH_OPENING AS Month_Opening, CONCAT('Q-', CEIL(MONTH_OPENING / 3)) AS Quarter
    FROM zomata) AS T GROUP BY Year_Opening,Month_Opening, Quarter
ORDER BY Year_Opening,Month_Opening,Quarter;
-- month
SELECT YEAR_OPENING AS Year_Opening,
   CASE MONTH_OPENING
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS Month_Name,
    COUNT(*) AS Restaurant_Count FROM zomata GROUP BY  YEAR_OPENING, MONTH_OPENING ORDER BY  YEAR_OPENING, MONTH_OPENING;

-- Question 6:
-- Find the Count of Restaurants based on Average Ratings.

SELECT
CASE
        WHEN Rating > 0 AND Rating <= 1 THEN 1
        WHEN Rating > 1 AND Rating <= 2 THEN 2
        WHEN Rating > 2 AND Rating <= 3 THEN 3
        WHEN Rating > 3 AND Rating <= 4 THEN 4
        WHEN Rating > 4 AND Rating <= 5 THEN 5
    END AS Rating_Bucket,
    COUNT(RestaurantID) AS Restaurant_Count FROM zomata WHERE Rating > 0 GROUP BY Rating_Bucket ORDER BY Rating_Bucket;

-- Question 7:
-- Create Price Buckets based on the Average Cost for Two and count the number of restaurants in each bucket.

  SELECT
CASE
WHEN Average_Cost_for_two<=500
THEN '0-500'
WHEN Average_Cost_for_two<=1000
THEN '501-1000'
WHEN Average_Cost_for_two<=2000
THEN '1001-2000'
WHEN Average_Cost_for_two<=3000
THEN '2001-3000'
ELSE
'3000+'
END PRICE_BUCKET,
COUNT(*) TOTAL FROM zomata GROUP BY
CASE
WHEN Average_Cost_for_two<=500
THEN '0-500'
WHEN Average_Cost_for_two<=1000
THEN '501-1000'
WHEN Average_Cost_for_two<=2000
THEN '1001-2000'
WHEN Average_Cost_for_two<=3000
THEN '2001-3000'
ELSE
'3000+'
END
ORDER BY 1;

-- Question 8:
-- Find the Percentage of Restaurants based on Has_Table_booking.

SELECT HAS_TABLE_BOOKING,COUNT(*) RESTAURANTS,CONCAT(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2),'%') AS Percentage
FROM zomata GROUP BY HAS_TABLE_BOOKING;

-- Question 9:
-- Find the Percentage of Restaurants based on Has_Online_delivery.

SELECT HAS_ONLINE_DELIVERY,COUNT(*) RESTAURANTS,CONCAT(ROUND(COUNT(*)*100/SUM(COUNT(*)) OVER(),2),'%') AS PERCENTAGE FROM zomata
GROUP BY HAS_ONLINE_DELIVERY;
