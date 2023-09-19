--data we are going work with

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM dbo.Deaths
where continent is not null
order by 1 ,2

ALter table dbo.deaths
alter column total_deaths int
ALter table dbo.deaths
alter column total_cases float
ALter table dbo.deaths
alter column new_deaths float
alter table dbo.Vaccinations
alter column new_vaccinations float


-- Total cases ,Total deaths and death percentage

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percentage
FROM [dbo].[Deaths]
--Where location = 'Cape Verde'
order by 1 ,2;

-- Total cases ,Total deaths 
-- probability of death if you contract covid 
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percentage
FROM [dbo].[Deaths]
--Where location = 'Cape Verde'
order by 1 ,2;

-- Total cases , population
-- percentage of population that got covid
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS death_percentage
FROM [dbo].[Deaths]
--Where location = 'Cape Verde'
order by 1 ,2;


-- Countries with highest infection rate compared to population

SELECT location, population, MAx(total_cases) HighestInfectionCount, MAx(total_cases/population) * 100 AS PercentagePopulationInfected
FROM [dbo].[Deaths]
--Where location = 'Cape Verde'
Group by location,population
order by percentagePopulationInfected desc;

-- Countries with highest deaths rate compared to population

SELECT location, population, MAx(total_cases) HighestInfectionCount, MAx(total_cases/population) * 100 AS PercentagePopulationInfected
FROM [dbo].[Deaths]
--Where location = 'Cape Verde'
Group by location,population
order by percentagePopulationInfected desc;


-- Countries with highest deaths count per population

SELECT location, population, MAX(cast (total_deaths AS bigint)) AS TotalDeathCounth
FROM [dbo].[Deaths]
--Where location = 'Cape Verde'
where continent is not null
Group by location,population
order by TotalDeathCounth desc;


--Total deaths (Group by continent)
SELECT continent, MAX(cast (total_deaths AS bigint)) AS TotalDeathCounth
FROM [dbo].[Deaths]
--Where location = 'Cape Verde'
where continent is not null
Group by continent
order by TotalDeathCounth desc;



--Global Numbers
SELECT sum(new_cases) as 'total cases', 
	SUM(new_deaths ) as total_deaths, 
	SUM(new_deaths ) / SUM(new_cases)* 100 as Death_Percentage
FROM [dbo].[Deaths]
--Where location = 'Cape Verde'
Where continent is not null
--Group by date 
order by 1 ,2;



-- Total population Vs vaccinations (popXvac)



SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
	SUM(va.new_vaccinations) Over (partition by de.location order by de.location,
	de.date) AS Peoplevaccinated,
--	,(Peoplevaccinated/population) * 100
	
	FROM [dbo].[Deaths] de
	JOIN [dbo].[Vaccinations] va 
		ON de.location = va.location
		AND de.date = va.date
	Where de.continent is not null
	order by 2, 3 

-- USE CTE 
	
With popXvac (continent, location, date, Population, new_vaccinations, RollingpeopleVaccinated)
as
(
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
	SUM(va.new_vaccinations) Over (partition by de.location order by de.location,
	de.date) AS rollingpeoplevaccinated
--	,(Peoplevaccinated/population) * 100
	FROM [dbo].[Deaths] de
	JOIN [dbo].[Vaccinations] va 
		ON de.location = va.location
		AND de.date = va.date
Where de.continent is not null
--order by 2, 3 
)
SELECT *, (RollingpeopleVaccinated/Population) * 100 
FROM popXvac


--Creating view to store data for visualization

CREATE VIEW percentagepeoplevaccinated AS 
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
	SUM(va.new_vaccinations) Over (partition by de.location order by de.location,
	de.date) AS rollingpeoplevaccinated
--	,(Peoplevaccinated/population) * 100
	FROM [dbo].[Deaths] de
	JOIN [dbo].[Vaccinations] va 
		ON de.location = va.location
		AND de.date = va.date
Where de.continent is not null
--order by 2, 3 
