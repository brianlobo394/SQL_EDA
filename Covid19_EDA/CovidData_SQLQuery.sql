SELECT * FROM CovidProject..CovidDeaths
ORDER BY 3,4

SELECT * FROM CovidProject..CovidVaccinations
ORDER BY 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
Order by 1,2


--Let's check the Total cases vs Total Deaths
--Shows the percentage of death, if you contract Covid in India.
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM CovidProject..CovidDeaths
Where location like '%india%'
Order by 1,2


--Let's check the total cases vs population
--Shows the percentage of infection w.r.t no of total cases
SELECT location, date, population, total_cases, (total_cases/population)*100 as Infection_Percentage
FROM CovidProject..CovidDeaths
Where location like '%india%'
Order by 1,2;


--Let's check countries with highest infection count
SELECT location, population, Max(total_cases) As Highest_Infection, MAX((total_cases/population))*100 as Infection_Percentage
FROM CovidProject..CovidDeaths
Group by location, population
Order by Infection_Percentage desc;


--Let's check the highest death count
Select location, MAX(cast(total_deaths as int)) AS Total_DeathCount
FROM CovidDeaths
where continent is not null
group by location
order by Total_DeathCount desc


--Let's check the continets with highest death count
--location wise
SELECT location, MAX(cast(total_deaths as int)) as Total_DeathCount
FROM CovidDeaths
where continent is null
group by location
order by Total_DeathCount desc;

--continent wise
SELECT continent, MAX(cast(total_deaths as int)) as Total_DeathCount
FROM CovidDeaths
where continent is not null
group by continent
order by Total_DeathCount desc;


--Let's check the highest death percentage w.r.t population
SELECT location, population, Max(cast(total_deaths as int)) As Total_DeathsCount, MAX((total_deaths/population))*100 as Death_Percentage
FROM CovidProject..CovidDeaths
Where continent is not null
Group by location, population
Order by Death_Percentage desc;


--Global data
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;


--Total cases and deaths with death percentage
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2;



--Let's check the Vaccination table
SELECT *
FROM CovidVaccinations


--Joining both Covid Death and Covid Vaccination tables
SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date;


--Let's check the population vacccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;


--Using CTE to find population vaccinated
WITH PopulationVacinated(continent, location, date, population, new_vaccinations, RollingVaccinationCount)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingVaccinationCount/population)*100 AS PercentagePopulationVaccinated 
FROM PopulationVacinated;


--Using TempTable to find population vaccinated
DROP TABLE if exists #PopulationVaccinated
CREATE TABLE #PopulationVaccinated(
Continet nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)

INSERT INTO #PopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

SELECT *, (RollingVaccinationCount/population)*100 as PercentagePopulationVaccinated
FROM #PopulationVaccinated
