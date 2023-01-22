Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Coviddeaths
WHERE location like '%states%'      
Order by 1,2


Select location, Population, MAX(total_cases) as HighInfectionCount, MAX((total_cases/population))*100 as 
Percentofpopulationinfected
from Coviddeaths
Group by location, population
Order by 1,2

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from Coviddeaths
WHERE continent is not null
Group by location
Order by TotalDeathCount desc

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from Coviddeaths
WHERE continent is null
Group by location
Order by TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, 
(SUM(cast (new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from Coviddeaths
--WHERE location like '%states%'
Where continent is not null
Order by 1,2

---  Temp table

DROP TABLE if exists #PercentpopulationVaccinated
CREATE TABLE #PercentpopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Pop bigint,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentpopulationVaccinated
Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM (CAST (new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as
RollingPeopleVaccinated
from SQLPortfolio..Coviddeaths dea
        JOIN SQLPortfolio..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
---WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/Pop)*100
from #PercentpopulationVaccinated





-----Covidvaccinaton
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as
RollingPeopleVaccinated
from SQLPortfolio..Coviddeaths dea
        JOIN SQLPortfolio..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac




--Creating View to store data

Create View PercentpopulationVaccinated
AS
Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as
RollingPeopleVaccinated
from SQLPortfolio..Coviddeaths dea
        JOIN SQLPortfolio..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent is not null



