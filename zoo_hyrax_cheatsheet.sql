-- Create base table
CREATE TABLE species (
  species TEXT PRIMARY KEY,
  habitat TEXT,
  diet TEXT,
  iucn_status TEXT,
  weight_kg DECIMAL(10,2),
  length_cm DECIMAL(10,2),
  category TEXT,
  population_estimate INTEGER
);

-- Species count per habitat
SELECT habitat, COUNT(DISTINCT species) AS species_count
FROM species
GROUP BY habitat
ORDER BY species_count DESC;

-- Total population per species
SELECT species, SUM(population_estimate) AS total_population
FROM species
GROUP BY species
ORDER BY total_population DESC;

-- Population Heatmap export (species x habitat)
SELECT species, habitat, population_estimate
FROM species;

-- Population Density Index
SELECT
  species,
  habitat,
  population_estimate / NULLIF(weight_kg,0) AS population_density_index
FROM species;

-- Risk grouping
SELECT
  species,
  CASE
    WHEN iucn_status IN ('Endangered','Critically Endangered') THEN 'High Risk'
    WHEN iucn_status IN ('Vulnerable','Near Threatened') THEN 'At Risk'
    ELSE 'Stable'
  END AS risk_group
FROM species;

-- Appendix (fundamentals)
SELECT ... FROM ... WHERE ...
GROUP BY ... HAVING ...
ORDER BY ... [ASC|DESC]
JOIN: INNER | LEFT | RIGHT | FULL
Aggregates: COUNT(), COUNT(DISTINCT ...), SUM(), AVG(), MIN(), MAX()
CASE WHEN ... THEN ... ELSE ... END
NULLIF(a,0), COALESCE(a,0)
Window starter: SUM(...) OVER (PARTITION BY ... ORDER BY ...)