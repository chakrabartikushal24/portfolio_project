--CYCLISTIC DATA ANALYSIS PROJECT

-- data has been downloaded from Divvy Trip data open data source
-- 12 months data from July 2021 to June 2022, imported and combined in a single year data table
-- duplicate file of the year data created and worked upon keeping the original raw data for reference purposes


-- To check the table details for the year data to ensure consistency with data present in the table
sp_help cyclistic_year_data --to check the details of the cyclistic year data table

-- As per the check the data types in the table look correct and will not affect further analysis


SELECT * FROM cyclistic_year_data; -- the complete data table

SELECT COUNT(*) FROM cyclistic_year_data; -- to check the count of the number of rows in the year data table
--Approximately 5.9 million rows in the table

SELECT TOP 20 * FROM cyclistic_year_data; -- for a view of the top 20 rows of the data in order to get a basic understanding


-- checking for duplicates in ride ids to ensure that each row is a unique entry

SELECT ride_id, COUNT(*) as count FROM cyclistic_year_data -- this to identify duplicates in ride ids in the whole data
GROUP BY ride_id
ORDER BY count DESC; 

-- we find that there is only one duplicate in the complete data set hence we will remove the ride id which has a duplicate from the data set
-- the data is very large and hence removing one data point won't be affecting the analysis at all

DELETE FROM cyclistic_year_data
WHERE ride_id = '5.63E+14'

-- to double check that there are no duplicate ride ids in the table anymore, we will run the previous query again to identify the duplicates

-- on another check we have identified that instead of deleting both the rows, we counld have only deleted one
-- we can also use CTE to remove duplicates from a table


-- we also have to check which all coloumns have blank data and the count of the rows having any kind of blank data

SELECT COUNT(*) FROM cyclistic_year_data
WHERE ride_id IS NULL OR rideable_type IS NULL OR started_at IS NULL or ended_at IS NULL OR 
start_station_name IS NULL OR start_station_id IS NULL OR end_station_name IS NULL OR end_station_id IS NULL OR start_lat IS NULL OR
end_lat IS NULL OR start_lng IS NULL or end_lng IS NULL OR member_casual IS NULL;

--the above query gave us the result that about 4.9 mil of the total rows contain NULLs in one or more columns

-- to check blank string data in the table

SELECT COUNT(*) FROM cyclistic_year_data
WHERE ride_id = '' OR rideable_type = '' OR started_at = '' or ended_at = '' OR 
start_station_name = '' OR start_station_id = '' OR end_station_name = '' OR end_station_id = '' OR start_lat = '' OR
end_lat = '' OR start_lng = '' or end_lng = '' OR member_casual = '';

-- the above query again tells us that there are 12.2 mil rows of the total data which contain blank string data in one or more columns
-- this is significant portion of the data that if deleted might skew the results of the analysis significantly
-- the blanks are mostly in start and end station name and id columns which is not very important for our analysis 


--To ensure that there are no blanks in the most important coloums which will be directly used in the analysis

SELECT COUNT(*) FROM cyclistic_year_data
WHERE ride_id = '' OR rideable_type = '' OR started_at = '' or ended_at = '' OR start_lat = '' OR
end_lat = '' OR start_lng = '' or end_lng = '' OR member_casual = '';

-- no blanks in these selected columns of the table



-- To find the ride duration by finding the different between the ending time and starting time

SELECT started_at, ended_at, DATEDIFF(minute,started_at, ended_at) AS duration
FROM cyclistic_year_data

-- we add the same information of the duration to the table we are working with for further analysis

ALTER TABLE cyclistic_year_data
ADD duration DECIMAL;

UPDATE cyclistic_year_data
SET duration = DATEDIFF(minute,started_at, ended_at)

-- to check for data rows having negative duration

SELECT * FROM cyclistic_year_data
WHERE duration < 0

-- this shows us that there are 94 rows having negative duration of the bike ride which is incorrect hence needs to be removed from the table

DELETE FROM cyclistic_year_data
WHERE duration < 0

-- we run the previous query to check again if the data having negative duration values have been removed or not 


-- we also have to analyze the data based on the day of the week so that we can compare the trend between the members and casuals
-- for this we will first have to add the days in each row of the data based on the date of start of the ride

ALTER TABLE cyclistic_year_data
ADD day_of_the_week VARCHAR(10);

UPDATE cyclistic_year_data
SET day_of_the_week = DATENAME(WEEKDAY, started_at)



--LET US START THE ANALYSIS

--first we will check what percentage of our total data are members and how many are casuals

SELECT member_casual, COUNT(member_casual) -- This query gives us the breakdown of total observations for customer type
FROM cyclistic_year_data
GROUP BY member_casual;


-- to calculate the percentage from total observations of casual and member riders in our data

SELECT member_casual, COUNT(*) as customer_type_count, 
COUNT(*)*100.0/ SUM(COUNT(*)) over () AS customer_type_percentage
FROM cyclistic_year_data
GROUP BY member_casual;

-- hence it is observed that 56.64% of the total rides started in the 1 year data is by members and 43.36% is by casual members


-- next we try to find the ride type by each user category

SELECT member_casual, rideable_type, COUNT(*) as ride_type_count,
COUNT(*)*100.0/SUM(COUNT(*)) OVER () as ride_type_percentage
FROM cyclistic_year_data
GROUP BY rideable_type, member_casual
ORDER BY rideable_type, member_casual;


-- We also try to find the same data as above but by the hour of the day

SELECT member_casual, rideable_type, DATEPART(HOUR, started_at) AS time_of_day, COUNT(*) as ride_type_count,
COUNT(*)*100.0/SUM(COUNT(*)) OVER () as ride_type_percentage
FROM cyclistic_year_data
GROUP BY DATEPART(HOUR, started_at), rideable_type, member_casual
ORDER BY DATEPART(HOUR, started_at), rideable_type, member_casual;

--similarly we also try to find the data for each day of the week for the bike type for each user type

SELECT member_casual, rideable_type, day_of_the_week, COUNT(*) as ride_type_count,
COUNT(*)*100.0/SUM(COUNT(*)) OVER () as ride_type_percentage
FROM cyclistic_year_data
GROUP BY day_of_the_week, member_casual, rideable_type
ORDER BY day_of_the_week, member_casual, rideable_type;


-- We also try to check the percentage of rides started on different days of the week for each customer type

SELECT member_casual, day_of_the_week, COUNT(*) as customer_count, --This code helps us to find the percentage of rides initiated by each customer type on different days during the whole year
COUNT(*)*100.0/ SUM(COUNT(*)) over () AS day_ride_percentage
FROM cyclistic_year_data
--WHERE day_of_the_week = 'Sunday'
GROUP BY day_of_the_week, member_casual
ORDER BY day_of_the_week, member_casual;


-- now we want to check the rides initiated during the day by each customer type to find if there is any pattern that can be seen

SELECT member_casual, DATEPART(HOUR,started_at) AS hour_of_the_day, COUNT(*) AS customer_count, -- this code is for grouping the observation count by the hour of the day in order to understand trends
COUNT(*)*100.0/SUM(COUNT(*)) OVER () AS day_ride_percentage
FROM cyclistic_year_data
GROUP BY DATEPART(HOUR,started_at), member_casual
ORDER BY DATEPART(HOUR,started_at), member_casual;


-- we also try to find the number of rides initiated by user types in each month to find seasonal difference if any

SELECT member_casual, DATEPART(MONTH, started_at) AS month, COUNT(*) AS customer_count,
COUNT(*)*100.0/SUM(COUNT(*)) OVER () AS ride_month_percentage
FROM cyclistic_year_data
GROUP BY DATEPART(MONTH, started_at), member_casual
ORDER BY DATEPART(MONTH, started_at), member_casual


-- MAX and MIN ride durations

SELECT member_casual, MAX(duration) as max_duration, MIN(duration) AS min_duration
FROM cyclistic_year_data
GROUP BY member_casual;


-- Now we will check the the average duration of ride by different user type

--First to check the average ride duration and the standard deviation in duration for each user type
SELECT member_casual, AVG(duration) as average_duration, STDEV(duration) AS standard_deviation
FROM cyclistic_year_data
GROUP BY member_casual;



--Next to check average ride duration by user type on different days of the week
SELECT member_casual, day_of_the_week, AVG(duration) as average_duration
FROM cyclistic_year_data
GROUP BY day_of_the_week, member_casual
ORDER BY day_of_the_week, member_casual;



--We also check the average duration of rides by the hour of the day for each user type

SELECT member_casual, DATEPART(HOUR, started_at) AS time_of_day, AVG(duration) AS average_duration
FROM cyclistic_year_data
--WHERE duration <> 0 -- This part can be included to exclude 0 duration values from result but there was no difference in the results
GROUP BY DATEPART(HOUR, started_at), member_casual
ORDER BY DATEPART(HOUR, started_at), member_casual;



-- Finally we try to group the data by longitues and latitudes belonging to start and end docking stations

SELECT member_casual, start_lat, start_lng, COUNT(*) AS count
FROM cyclistic_year_data
GROUP BY start_lat, start_lng, member_casual
ORDER BY count DESC; 

-- A lot of latitudes and longitudes have only one count and the total rows even after grouping the data by latitude and longitude is huge.

-- we use a CTE in order to first group the data and find the total count against the groups, then filter those groups having a count of more than 1
WITH station_location AS (                                        -- demonstration of a CTE
SELECT member_casual, start_lat, start_lng, COUNT(*) AS count
FROM cyclistic_year_data
GROUP BY start_lat, start_lng, member_casual)

SELECT SUM(count) as geograhical_data FROM station_location
WHERE count > 1;

--This shows that out of total 5.9 mil rides, 4.33 mil was started from same latitude and longitude more than 1 time
-- we can use this data for a plot on a map to see the pattern of use by the two user types

-- again we will use a view in order to filter out all those groups having less than 2 count 

WITH station_location AS (
SELECT member_casual, start_lat, start_lng, COUNT(*) AS count 
FROM cyclistic_year_data 
GROUP BY start_lat, start_lng, member_casual)

SELECT * 
FROM station_location 
WHERE count > 1 
ORDER BY count DESC;

-- the results of the same are imported to excel and later to power BI for visualization
