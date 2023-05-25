

select * 

FROM protofolio..CovidDeaths
where continent is not null
ORDER BY 3,4

--select * 

--FROM protofolio..CovidVacination
--ORDER BY 3,4

select location,date,total_cases,new_cases,total_deaths,population

FROM protofolio..CovidDeaths
ORDER BY 1,2

--total cases vs total deaths

select location,date,total_cases,total_deaths, (cast (total_deaths as float ))/ (cast (total_cases as float))*100 as DeathePercentage

FROM protofolio..CovidDeaths
where location like 'syria'
and continent is not null
ORDER BY 1,2

--total cases vs population

select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected

FROM protofolio..CovidDeaths
--where location like '%syri%'
ORDER BY 1,2

--highest infection countries


select location,population, max (total_cases) as HighestInfection,max((total_cases/population))*100 as PercentPopulationInfected

FROM protofolio..CovidDeaths
--where location like '%syri%'
where continent is not null
Group by location,population

ORDER BY PercentPopulationInfected desc

--Highest Continent with highest death count per population

select continent,max ( cast (total_deaths as float )) as TotalDeathsCount

FROM protofolio..CovidDeaths
--where location like '%syri%'
where continent is not null
Group by continent
ORDER BY TotalDeathsCount desc


--Global numbers
set arithabort on
set ansi_warnings on
select 
sum(new_cases) as total_cases , sum (cast (new_deaths as int)) as new_deaths, sum (cast (new_deaths as int))/sum(nullif (new_cases,0))*100 
as DeathPercentage

FROM protofolio..CovidDeaths
--where location like 'syria'
where continent is not null
--group by date
ORDER BY 1,2

--total population vs  vacinations

select death.continent,death.location,death.population,vacin.new_vaccinations
,Sum(convert (float,vacin.new_vaccinations)) over (partition by death.location order by death.location,death.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from protofolio..CovidDeaths death
join protofolio..CovidVacination vacin
on death.location = vacin.location
and death.date = vacin.date
where death.continent is not null
order by 2,3




with PopvsVac (continent,location,date,population, new_vaccinations, RollingPeopleVaccinated)
as(

select death.continent,death.location,death.date,death.population,vacin.new_vaccinations
,Sum(convert (float,vacin.new_vaccinations)) over (partition by death.location order by death.location,death.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from protofolio..CovidDeaths death
join protofolio..CovidVacination vacin
on death.location = vacin.location
and death.date = vacin.date
where death.continent is not null
--order by 2,3
)
select* , (RollingPeopleVaccinated/population)*100
from PopvsVac


--ll
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
( 
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

select death.continent,death.location,death.population,vacin.new_vaccinations
,Sum(convert (float,vacin.new_vaccinations)) over (partition by death.location order by death.location,death.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from protofolio..CovidDeaths death
join protofolio..CovidVacination vacin
on death.location = vacin.location
and death.date = vacin.date
--where death.continent is not null
--order by 2,3
select* , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--view

create view PPercentPopulationVaccinated as 
select death.continent,death.location,death.date,death.population,vacin.new_vaccinations
,Sum(convert (float,vacin.new_vaccinations)) over (partition by death.location order by death.location,death.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from protofolio..CovidDeaths death
join protofolio..CovidVacination vacin
on death.location = vacin.location
and death.date = vacin.date
where death.continent is not null
--order by 2,3

select *
from PPercentPopulationVaccinated