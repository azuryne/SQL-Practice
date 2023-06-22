DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;
USE Covid_Database;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
  Continent varchar(255),
  Location varchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinate numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(REGEXP_REPLACE(vac.new_vaccinations, '[^0-9]', '') AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Covid_Database.coviddeaths dea
JOIN Covid_Database.covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location = 'Malaysia'
AND vac.new_vaccinations <> '' AND vac.new_vaccinations IS NOT NULL;

SELECT
  Continent,
  Location,
  Date,
  Population,
  New_vaccinations,
  RollingPeopleVaccinate,
  (RollingPeopleVaccinate/Population)*100 AS PercentageVaccinatedCitizen
FROM PercentPopulationVaccinated
LIMIT 1000;
