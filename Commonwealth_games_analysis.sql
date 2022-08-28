/* THIS PROJECT IS TO EXPLORE THE COMMONWEALTH GAMES 2022 DATASET 
IN ORDER TO CHECK HOW DIFFERENT COUNTRIES PERFORMED AND BASED ON A RESULTS OF ANALYSIS CREATE A DASHBOARD IN POWER BI*/


--For this analysis we have the commonwealth games dataset from Kaggle which consists of two tables
/*One table is having the information of the players who had participated in the commonwealth games
and the other table contains data of the players who have won a medal in the games */


--To check the two tables for initial overview of the data
SELECT * FROM [commonwealth games 2022 - players participated]
SELECT * FROM [commonwealth games 2022 - players won medals in cwg games 2022]

/*On first look the data looks to be pretty clean and organised but we will still do some checks in order to ensure that 
data we are working with doesn't have too many error or blank values that can compromise the quality of the results*/

-- To check the distinct values in each column of the two dataset
SELECT DISTINCT SPORT FROM [commonwealth games 2022 - players participated]
SELECT DISTINCT GENDER FROM [commonwealth games 2022 - players participated]
SELECT DISTINCT AGE FROM [commonwealth games 2022 - players participated]
SELECT DISTINCT TEAM FROM [commonwealth games 2022 - players participated]

SELECT DISTINCT TEAM FROM [commonwealth games 2022 - players won medals in cwg games 2022]
SELECT DISTINCT SPORT FROM [commonwealth games 2022 - players won medals in cwg games 2022]
SELECT DISTINCT EVENT FROM [commonwealth games 2022 - players won medals in cwg games 2022]
SELECT DISTINCT MEDAL FROM [commonwealth games 2022 - players won medals in cwg games 2022]
SELECT DISTINCT CONTINENT FROM [commonwealth games 2022 - players won medals in cwg games 2022]


--The check of distinct values in all the columns show that only the age column of the players participated table has a NULL value
--We also saw that one of the distinct value of age is also showing as 0 which should not be correct
--All other columns of the two tables didn't have any other issues as such that we noticed
--Hence to check the age column properly we filter the data in the players participated table for age 0 and nulls

SELECT * FROM [commonwealth games 2022 - players participated]
WHERE AGE = 0 OR AGE is NULL

/* The above query showed two results for two atheletes whose age was either showing 0 or was NULL
A quick check on internet was able to help us with the age of both the athletes which was a quick fix to the issue
Hence we will update the table accordingly */

UPDATE [commonwealth games 2022 - players participated]
SET AGE = 20
WHERE ATHLETE_NAME = 'AnthonyPesela'

UPDATE [commonwealth games 2022 - players participated]
SET AGE = 20
WHERE ATHLETE_NAME = 'FelicityCradick'

-- We will ensure that none of the names present in the name columns of the two tables have any data related issues such as NULLS and blanks

SELECT ATHLETE_NAME
FROM [commonwealth games 2022 - players participated]
WHERE ATHLETE_NAME is NULL or ATHLETE_NAME = ''

SELECT ATHLETE_NAME
FROM [commonwealth games 2022 - players won medals in cwg games 2022]
WHERE ATHLETE_NAME is NULL or ATHLETE_NAME = ''

-- we also check for spaces at the end or beginning of the names in the name columns so that there can be trimmed if found

SELECT ATHLETE_NAME
FROM [commonwealth games 2022 - players participated]
WHERE ATHLETE_NAME LIKE ' %' OR ATHLETE_NAME LIKE '% '

SELECT ATHLETE_NAME
FROM [commonwealth games 2022 - players won medals in cwg games 2022]
WHERE ATHLETE_NAME LIKE ' %' OR ATHLETE_NAME LIKE '% '

-- All the necessary checks on the the data on the two tables have been completed and fixed as found
-- the Data is now ready for analysis


/* DATA ANALYSIS */

--Participation by COUNTRY(TEAM)
--HERE we will use WINDOW FUNCTION in order to find the percentage of participation by each country

SELECT COUNT(* ) as Count_of_participants, TEAM, COUNT(*)*100.0/SUM(COUNT(*)) OVER () as participation_percentage
FROM [commonwealth games 2022 - players participated]
GROUP BY TEAM
ORDER BY COUNT(*) DESC


--Participation by GENDER

SELECT GENDER, COUNT(*) AS participation_count, COUNT(*)*100.0/SUM(COUNT(*)) OVER () AS participation_percentage
FROM [commonwealth games 2022 - players participated]
GROUP BY GENDER


--Participation by SPORT

SELECT SPORT, COUNT(*) as participant_count, COUNT(*)*100.0/SUM(COUNT(*)) OVER () as participation_percentage
FROM [commonwealth games 2022 - players participated]
GROUP BY SPORT
ORDER BY COUNT(*) DESC

--We can also group the above data by country to find participation in each sport for each country
-- Here we make a change to our WINDOW function in order to partition the percentage data by Country

SELECT SPORT, COUNT(*) as participant_count, COUNT(*)*100.0/SUM(COUNT(*)) OVER (PARTITION BY TEAM) as participation_percentage, TEAM
FROM [commonwealth games 2022 - players participated]
GROUP BY TEAM, SPORT
ORDER BY TEAM, COUNT(*) DESC


--Participation by AGE GROUP 

--Checking the MIN participant age by country

SELECT MIN(AGE) as AGE, TEAM 
FROM [commonwealth games 2022 - players participated]
GROUP BY TEAM
ORDER BY AGE

--checking the MAX participant age by country

SELECT MAX(AGE) as AGE, TEAM 
FROM [commonwealth games 2022 - players participated]
GROUP BY TEAM
ORDER BY AGE DESC


--Checking participants by age groups
-- In this case we will use CASE statements in order to group the data in 4 groups(<18, 18-35, 36-50, >50)

SELECT SUM(CASE WHEN AGE < 18 THEN 1 ELSE 0 END) AS 'UNDER_18',
SUM(CASE WHEN AGE BETWEEN 18 and 35 THEN 1 ELSE 0 END) AS '18_to_35',
SUM(CASE WHEN AGE BETWEEN 36 and 50 THEN 1 ELSE 0 END) AS '36_to_50',
SUM(CASE WHEN AGE >50 THEN 1 ELSE 0 END) AS 'Over_50', COUNT(*) AS total_participants, TEAM
FROM [commonwealth games 2022 - players participated]
GROUP BY TEAM
ORDER BY COUNT(*) DESC

-- to find the countries with Max number of participants in any age group, we can use the above query in a CTE

WITH age_group_participation AS (
SELECT SUM(CASE WHEN AGE < 18 THEN 1 ELSE 0 END) AS 'UNDER_18',
SUM(CASE WHEN AGE BETWEEN 18 and 35 THEN 1 ELSE 0 END) AS '18_to_35',
SUM(CASE WHEN AGE BETWEEN 36 and 50 THEN 1 ELSE 0 END) AS '36_to_50',
SUM(CASE WHEN AGE >50 THEN 1 ELSE 0 END) AS 'Over_50', COUNT(*) AS total_participants, TEAM
FROM [commonwealth games 2022 - players participated]
GROUP BY TEAM
)

SELECT * 
FROM age_group_participation
ORDER BY Over_50 DESC; -- substitute by the age group you want to check

/*We can also use the above CTE to calculate percentage of participants by count 
or to simply check total participants by age group for all coutries combined*/

-- To check if there are participants who have participated in multiple sports

SELECT COUNT(*) as participation, ATHLETE_NAME, SPORT, TEAM
FROM [commonwealth games 2022 - players participated]
GROUP BY ATHLETE_NAME, SPORT, TEAM
ORDER BY COUNT(*) DESC

-- We find no athelete belonging to one country who participated in more than one sport


-- now we check the count of medals won by each country


SELECT SUM(CASE WHEN MEDAL = 'G' THEN 1 ELSE 0 END) AS 'Gold',
SUM(CASE WHEN MEDAL = 'S' THEN 1 ELSE 0 END) AS 'Silver',
SUM(CASE WHEN MEDAL = 'B' THEN 1 ELSE 0 END) AS 'Bronze', COUNT(*) as total_medals, TEAM
FROM [dbo].[commonwealth games 2022 - players won medals in cwg games 2022]
GROUP BY TEAM
ORDER BY COUNT(*) DESC


/*This gives us the count of medals for each country but the medal count is much higher for many countries than what the official medal count for those countries are
 We find that since for team sport, each member had got the same medal from the same country, it is being counted multiple times in the tally but it should be counted only ones */

 --Hence we have to write a separate query in order to find the medal tally  by sports for the each country
 -- We will first have to create a CTE excluding the athlete names then use the same case statements in order to create the medal tally properly

WITH CTE AS(
    SELECT DISTINCT
           TEAM,
           SPORT,
           EVENT,
           MEDAL
    FROM [dbo].[commonwealth games 2022 - players won medals in cwg games 2022])
SELECT SUM(CASE WHEN MEDAL = 'G' THEN 1 ELSE 0 END) AS Gold,
       SUM(CASE WHEN MEDAL = 'S' THEN 1 ELSE 0 END) AS Silver, 
       SUM(CASE WHEN MEDAL = 'B' THEN 1 ELSE 0 END) AS Bronze, 
       COUNT(*) AS total_medals,
       TEAM
FROM CTE
GROUP BY TEAM
ORDER BY COUNT(*) DESC;


-- We will now find the top 3 sport event for each country in which they have won a medal


DROP TABLE IF EXISTS #new_medal_table

CREATE TABLE #new_medal_table (medal_count int, SPORT nvarchar(100), TEAM VARCHAR(50));

WITH medal_table AS (
	SELECT DISTINCT TEAM, 
	MEDAL, 
	SPORT
FROM [commonwealth games 2022 - players won medals in cwg games 2022]
)
INSERT INTO #new_medal_table (medal_count, SPORT, TEAM)
SELECT COUNT(MEDAL) AS medal_count, SPORT, TEAM
FROM medal_table
GROUP BY TEAM, SPORT;

SELECT x.* FROM (SELECT medal_count, SPORT, TEAM, DENSE_RANK() OVER (PARTITION BY TEAM ORDER BY medal_count) as sport_rank
FROM #new_medal_table) x
WHERE sport_rank < 4 AND TEAM = 'India'

--For those countries which have won a high number of medal, they have multiple sports in top3 ranks as the number of medals in those sports are similar
							

-- Now we will compare the participation from each country and the medals won

--FOR this we will need to join the participation table and the medals table using a CTE and use the same for querying

WITH participation_medal AS (
SELECT p.ATHLETE_NAME, p.SPORT, p.GENDER, p.AGE, p.TEAM, m.EVENT, m.MEDAL, m.CONTINENT
FROM [commonwealth games 2022 - players participated] AS p
LEFT JOIN [commonwealth games 2022 - players won medals in cwg games 2022] AS m
ON p.ATHLETE_NAME = m.ATHLETE_NAME
)

SELECT * FROM participation_medal;