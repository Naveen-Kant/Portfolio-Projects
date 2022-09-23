select * from dbo.deathdata
where continent is not null
order by 3,4

select * from dbo.vaccinationdata
order by 3,4

-- SELCTING DATA WE ARE GOING TO USE

select location,date, total_cases,New_cases,Population
from dbo.deathdata
order by 1,2

--TOTAL CASES VS TOTAL DEATH 

select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from dbo.deathdata
where location = 'india'and continent is not null
order by 1,2

-- TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

select location,date, total_cases,population,  (total_cases/population)*100  as Population_infected_percentage
from dbo.deathdata
where continent is not null
order by 1,2


--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION 

select location,population , MAX(total_cases) as Highest_infection_count,  max((total_cases/population)*100)  as Highest_Population_infected_percentage
from dbo.deathdata
where continent is not null
group by location,population
order by Highest_Population_infected_percentage desc

-- COUNTRIES WITH HIGHEST DEATHS COMPARED TO POPULATION

select location, max(cast(total_deaths as int)) as Total_Death_count,  max((total_deaths/population)*100)  as Total_Population_Death_percentage
from dbo.deathdata
where continent is not null
group by location
order by Total_Death_count desc

-- CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

select continent, max(cast(total_deaths as int)) as Total_Death_count
from dbo.deathdata
where continent is not null
group by continent
order by Total_Death_count desc 


-- GLOBAL NUMBERS

select sum(new_cases) as total_cases,sum(cast (new_deaths as int)) as Total_deaths , 
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from dbo.deathdata
where  continent is not null
order by 1,2

--TOTAL POPULATION VS TOTAL VACCINATION

select dea.continent,dea.location,dea.date,dea.population,cast(vac.new_vaccinations as int) as new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from vaccinationdata vac
join deathdata dea
on dea.location=vac.location
and dea.date=vac.date
where  dea.continent is not null
order by 2,3


-- USE CTE

with popvsvac (continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,cast(vac.new_vaccinations as int) as new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from vaccinationdata vac
join deathdata dea
on dea.location=vac.location
and dea.date=vac.date
where  dea.continent is not null
--order by 2,3
)
select *, (rolling_people_vaccinated/population)*100
from popvsvac


--TEMP TABLE 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
( 
continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
rolling_people_vaccinated bigint
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,cast(vac.new_vaccinations as int) as new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from vaccinationdata vac
join deathdata dea
on dea.location=vac.location
and dea.date=vac.date
--where  dea.continent is not null
--order by 2,3

select *, (rolling_people_vaccinated/population)*100
from #PercentPopulationVaccinated


-- CREATING VIEW FOR VISUALIZATIONS 

create view PercentPeopleVaccinated 
as
select dea.continent,dea.location,dea.date,dea.population,cast(vac.new_vaccinations as int) as new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from vaccinationdata vac
join deathdata dea
on dea.location=vac.location
and dea.date=vac.date
where  dea.continent is not null
--order by 2,3

-- DATA FROM VIEW

select * from PercentPeopleVaccinated