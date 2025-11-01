select * from hyrax_species;	
--this means  that it works but as main isnt selected as per default  it shows warning

SHOW TABLES;
--shows tables
-
CREATE TABLE hyrax_species (
    species TEXT,
    avg_weight_kg FLOAT,
    avg_length_cm INT,
    diet TEXT,
    habitat TEXT,
    iucn_status TEXT,
    population_estimate INT
);

INSERT INTO hyrax_species
VALUES
('rock_hyrax', 4.5, 55, 'herbivore', 'rocky', 'least concern', 50000),
('bush_hyrax', 3.8, 45, 'herbivore', 'savanna', 'near threatened', 12000),
('tree_hyrax', 2.9, 42, 'herbivore', 'forest', 'vulnerable', 5000);
--mannual insert of valyes  do in order of table headings

SELECT * FROM hyrax_species;
--now is ameneded no error as data inserted

select count(*) as total_species from hyrax_species;
--when using couny must be * as this counts all of whatever and as  assgins  a value for what i want to see alongside total

select avg(avg_weight_kg) as average_weight  from hyrax_species;
--avgfollowed by float value  naming vlaue i need from the table made

-- Average population by IUCN status
SELECT iucn_status, ROUND(AVG(population_estimate), 2) AS avg_population
FROM hyrax_species
GROUP BY iucn_status
ORDER BY avg_population DESC;
-- to get averge better do  round for int  bracket avg  then name in brackets   2 is for decimal placmennt  alisais then name  


--ways to view rows 

DESCRIBE hyrax_species;
-- structure 
SELECT *
FROM hyrax_species
LIMIT 5;
--limit good for cpu
SELECT *
FROM hyrax_species;
--all
PRAGMA table_info('hyrax_species');
--shows values of data type and whats missing 
SELECT COUNT(*) AS total_rows
FROM hyrax_species;
--count rows

select species, population_estimate, iucn_status  from hyrax_species group by iucn_status  order by population_estimate;

--When you use GROUP BY, every column in your SELECT list must be either:

--Grouped (GROUP BY that_column)

--Or aggregated (SUM(), AVG(), MAX(), MIN(), COUNT())

--You can’t just list normal columns — SQL doesn’t know which value to show per group.

SELECT species, population_estimate
FROM hyrax_species
ORDER BY population_estimate DESC;
-- as per here no agg so cant do group by 

SELECT species, COUNT(*) AS count_rows
FROM hyrax_species
GROUP BY species
HAVING COUNT(*) > 1;

SELECT *
FROM hyrax_species
WHERE species IN (
  SELECT species
  FROM hyrax_species
  GROUP BY species
  HAVING COUNT(*) > 1
);



DELETE FROM hyrax_species
WHERE rowid NOT IN (
  SELECT MIN(rowid)
  FROM hyrax_species
  GROUP BY species
);

--Groups each species together.

--Keeps the first (lowest rowid).

--Deletes the rest.

SELECT species, COUNT(*)
FROM hyrax_species
GROUP BY species;


-- data quality notes 

ALTER TABLE hyrax_species
ADD COLUMN notes TEXT;

UPDATE hyrax_species
SET notes = 'Common in rocky habitats'
WHERE habitat = 'rocky';

ALTER TABLE hyrax_species
ADD COLUMN biome TEXT,
ADD COLUMN terrain TEXT,
ADD COLUMN continent TEXT;
-- this works in mysql and postgre

ALTER TABLE hyrax_species ADD COLUMN biome TEXT;
ALTER TABLE hyrax_species ADD COLUMN terrain TEXT;
ALTER TABLE hyrax_species ADD COLUMN continent TEXT;

PRAGMA table_info('hyrax_species');
-- alter  must be done one by one and check with pagama after

select * from hyrax_species where  avg_weight_kg>3;
select * from hyrax_species order by population_estimate desc limit 2;
--filtering


select count(*) as total_species from hyrax_species;

SELECT AVG(avg_length_cm) AS avg_length FROM hyrax_species;

















--this can find duplicate data for data quality 


SELECT *
FROM hyrax_species
WHERE avg_weight_kg > 4;

-- where for specfics 



select from hyrax_species  where habitat= 'forest' AND population_estimate < 100000;




create table habitats(habitat text, continent text, avg_tempature_c float);

insert into habitats (habitat,continent,avg_tempature_c) values ('rocky','africa','27.5'), ('savanna', 'Africa', 30.2),
('forest', 'Africa', 25.0),
('coastal', 'Africa', 29.1);
show table habitats;

-- mismatch so wont create 


DROP TABLE habitats;

CREATE TABLE habitats (
    habitat TEXT,
    continent TEXT,
    avg_temperature_c FLOAT
);

INSERT INTO habitats (habitat, continent, avg_temperature_c)
VALUES 
('rocky', 'Africa', 27.5),
('savanna', 'Africa', 30.2),
('forest', 'Africa', 25.0),
('coastal', 'Africa', 29.1);


-- drop to recrate or do as below

ALTER TABLE habitats
RENAME COLUMN avg_tempature_c TO avg_temperature_c;

--rename colum also works



SELECT * FROM habitats;

--joins

--relationships mutual colums must exist eg habit so to check this select  both tabeles


SELECT * FROM hyrax_species;
SELECT * FROM habitats;


-- inner join  only matching rows between the two tables.

select h.species,h.habitat,b.continent,b.avg_temperature_c FROM  hyrax_species as h inner join habitats as b on h.habitat=b.habitat;


SELECT
    h.species,
    h.habitat,
    b.continent,
    b.avg_temperature_c
FROM hyrax_species AS h
INNER JOIN habitats AS b
    ON h.habitat = b.habitat;



-- left join  shows all from left even if no matching info 
-- for joins think backwards so that you write it correctly  when writing join part eg from  make sure the table for first part matches the row names 
-- this is also true for second table to join 
SELECT 
    h.species,
    h.habitat,
    b.continent,
    b.avg_temperature_c
FROM hyrax_species AS h
LEFT JOIN habitats AS b
    ON h.habitat = b.habitat;
-- right join is opppiste but duckdb doesnt support 

-- full outer all matching rows from both tables -- null will appear for missing values 
SELECT 
    h.species,
    h.habitat,
    b.continent,
    b.avg_temperature_c
FROM hyrax_species AS h
FULL OUTER JOIN habitats AS b
    ON h.habitat = b.habitat;


-- cross join ombines every possible combination between both tables (Cartesian product).
--Usually used for simulations or generating all combinations.

SELECT 
    h.species,
    b.habitat
FROM hyrax_species AS h
CROSS JOIN habitats AS b;



-- self join  comparison within one dataset 


SELECT 
    a.species AS hyrax_1,
    b.species AS hyrax_2,
    a.population_estimate - b.population_estimate AS pop_difference
FROM hyrax_species AS a
JOIN hyrax_species AS b
    ON a.population_estimate > b.population_estimate;

--exists keep rows that have a match elsewhere use when u need a match to exist 

SELECT species, habitat
FROM hyrax_species h
WHERE EXISTS (
    SELECT 1
    FROM habitats b
    WHERE h.habitat = b.habitat
);


-- not exists is oppisite 

-- in this is basically “For each row in hyrax_species,
--look into habitats — if you find at least one row
--where the habitat value is the same, keep the species.”

SELECT species, habitat
FROM hyrax_species h
WHERE NOT EXISTS (
    SELECT 1
    
    
    -- in and not in
    
    SELECT species, habitat
FROM hyrax_species
WHERE habitat IN (SELECT habitat FROM habitats);

SELECT species, habitat
FROM hyrax_species
WHERE habitat NOT IN (SELECT habitat FROM habitats);


--Tip: NOT IN can break if there are NULLs in the subquery —
-- pros prefer NOT EXISTS because it’s safer.

--Anti-join explained simply
--Anti-join  isn’t a separate SQL keyword — it’s how you use LEFT JOIN + WHERE NULL to find non-matches.
--eg

SELECT b.habitat, b.avg_temperature_c
FROM habitats b
LEFT JOIN hyrax_species h
  ON h.habitat = b.habitat
WHERE h.species IS NULL;



    FROM habitats b
    WHERE h.habitat = b.habitat
);


--case 
SELECT species, avg_weight_kg,  CASE     WHEN avg_weight_kg >= 4 THEN 'Large Hyrax'     WHEN avg_weight_kg BETWEEN 3 AND 3.9 THEN 'Medium Hyrax'
    ELSE 'Small Hyrax' END AS size_category  FROM hyrax_species;


--  so slect what ya wanna see  comma case when (used for condtion use a table head ) then  and can keep this going once u ahve decided that use else 
-- else being everyone not the condtions set  and then used end as and alias  from table you use


--COALESCE() to Handle Missing Values


--sometimes a table has NULLs — empty cells where data wasn’t entered.
--in SQL, NULL ≠ 0 or “blank”; it literally means “unknown.

-- population check 

SELECT species, population_estimate
FROM hyrax_species;

--updating 


UPDATE hyrax_species
SET population_estimate = NULL
WHERE species = 'tree_hyrax';


SELECT 
    species,
    COALESCE(population_estimate, 0) AS safe_population
FROM hyrax_species;


--1️⃣ COALESCE() — when you want to keep the row

--Goal: you still want the record included in analysis but with a safe substitute.


--2️⃣ WHERE — when you want to exclude bad data

-- Goal: remove incomplete, invalid, or sensitive data entirely.

--3️⃣ NOT EXISTS or ANTI JOIN — when you want to remove linked records

--Goal: exclude based on another table’s condition (like “deceased”, “opt-out”, etc.)

🧩 Example:
--If you had a restricted_species table listing protected animals:

SELECT *
FROM hyrax_species h
WHERE NOT EXISTS (
    SELECT 1
    FROM hyrax_species r
    WHERE r.species = h.species
);



-- Module: Analytic SQL
--️⃣ What window functions do

T--hey let you perform calculations across groups of rows without collapsing the data (unlike GROUP BY, which aggregates).

T--hink of them as saying:

--“For each row, also show me stats from its group.”

--basic

function_name(column) OVER (
    PARTITION BY column_to_group
    ORDER BY column_to_sort
    
    
    SELECT 
    h.species,
    h.habitat,
    b.continent,
    b.avg_temperature_c,
    AVG(h.population_estimate) OVER (PARTITION BY b.continent) AS avg_population_continent
FROM hyrax_species h
JOIN habitats b ON h.habitat = b.habitat;


--PARTITION BY = group rows by continent (like “Africa”).

--AVG() calculates within that group.

--But unlike GROUP BY, it still shows each species individually.

SELECT
    h.species,                -- show species name
    h.habitat,                -- its habitat
    b.continent,              -- continent (from joined table)
    h.population_estimate,    -- population
    AVG(h.population_estimate) OVER (PARTITION BY b.continent) AS avg_pop_by_continent--calculate by countrey is b as in end habitat table is b
FROM hyrax_species h
JOIN habitats b ON h.habitat = b.habitat;








--ranking 


--RANK() OVER (PARTITION BY b.continent ORDER BY h.avg_weight_kg DESC)





-- Select specific columns from the hyrax_species table
SELECT 
    species,               -- 🦛 the name of each hyrax species
    avg_weight_kg,         -- ⚖️ the species' average weight (numeric column used for sorting)

    -- 🥇 RANK(): gives each row a rank according to weight.
    --    • Highest weight gets rank 1
    --    • If two hyraxes have the same weight, they share that rank
    --    • The next rank number then skips (e.g., 1, 1, 3)
    RANK() OVER (
        ORDER BY avg_weight_kg DESC     -- DESC = heaviest first
    ) AS rank_standard,

    -- 🥈 DENSE_RANK(): similar to RANK but with no skipped numbers.
    --    • If two hyraxes tie at rank 1, the next becomes 2 (not 3)
    DENSE_RANK() OVER (
        ORDER BY avg_weight_kg DESC
    ) AS rank_dense,

    -- 🧮 ROW_NUMBER(): simply counts rows in the order given.
    --    • Ignores ties completely, always unique (1, 2, 3, ...)
    ROW_NUMBER() OVER (
        ORDER BY avg_weight_kg DESC
    ) AS row_number

-- 🧱 source table
FROM hyrax_species;


)


--topn 
-- step 1 join
FROM hyrax_species h
JOIN habitats b ON h.habitat = b.habitat


-- step 2 add rank

RANK() OVER (
    PARTITION BY b.continent        -- restart rank for each continent
    ORDER BY h.avg_weight_kg DESC   -- order heaviest first
) AS weight_rank

--step 3 full


SELECT
    h.species,
    b.continent,
    h.avg_weight_kg,
    RANK() OVER (
        PARTITION BY b.continent
        ORDER BY h.avg_weight_kg DESC
    ) AS weight_rank
FROM hyrax_species h
JOIN habitats b ON h.habitat = b.habitat;




-- 🧾 goal: find the top N (e.g. top 1) heaviest hyrax species per continent
-- this query uses: 
--  • a JOIN to connect species and habitats
--  • a RANK() window function to order species by weight within each continent
--  • a CTE (Common Table Expression) to filter the ranked results cleanly

-- 🦛 STEP 1: create a CTE (a temporary, named result you can query later)
WITH ranked_hyrax AS (

    SELECT 
        h.species,            -- name of the hyrax species
        b.continent,          -- continent from the habitats table
        h.avg_weight_kg,      -- average weight of the species

        -- 🧮 assign rank within each continent based on avg_weight_kg
        RANK() OVER (
            PARTITION BY b.continent        -- restart ranking for each continent
            ORDER BY h.avg_weight_kg DESC   -- heaviest species gets rank = 1
        ) AS weight_rank

    FROM hyrax_species h
    JOIN habitats b 
      ON h.habitat = b.habitat             -- join both tables on their habitat field
)

-- 🧾 STEP 2: query the CTE and filter for top-ranked species
SELECT 
    species,
    continent,
    avg_weight_kg,
    weight_rank
FROM ranked_hyrax
WHERE weight_rank <= 1;   -- 🥇 change 1→3 if you want top 3 per continent

-- 🧠 explanation:
--   1. The CTE "ranked_hyrax" calculates rank numbers for each species inside its continent.
--   2. The main SELECT then filt




--a CTE (Common Table Expression) is basically a temporary table that exists just for one query.

--think of it like a “note to self”:

--“hey SQL, here’s a mini result I’ll use again right away.”

--it’s written with the keyword WITH at the top of your query.


WITH name_of_cte AS (
    SELECT ...
)
SELECT ...
FROM name_of_cte;


--diff between cte and subquery

--Both CTEs and subqueries:

--create temporary results inside a single SQL statement,

d--isappear when that query finishes,

--let you reuse logic like filters or calculations.

--so they’re siblings — the difference is readability, reusability, and scope.

--  SUBQUERY — inline “mini-query”
SELECT *
FROM (
    SELECT species, population_estimate
    FROM hyrax_species
    WHERE population_estimate > 4000
) AS active_species;


--💬 it lives inside parentheses.
--the database must execute it first, then feed its result to the outer query.

✅ pros

--compact for very short, one-off lookups.

--can be used anywhere (FROM, WHERE, SELECT, HAVING).

⚠️ cons

--messy when nested multiple times.

--hard to debug (deep indentation).

--can’t reuse — if you need the same logic twice, you must rewrite it.


--CTE — named “temporary view”

WITH filtered_species AS (
    SELECT species, population_estimate
    FROM hyrax_species
    WHERE population_estimate > 4000
)
SELECT *
FROM filtered_species;


--Hey SQL, remember this subquery as filtered_species,
then let me query it cleanly below.”

✅ pros

--Readable: logic sits at the top, easy to follow.

--Reusable: you can reference the same CTE multiple times in one query.

--Chainable: you can stack several CTEs to build multi-step transformations (like a data pipeline).

--Debug-friendly: run each step separately to test results.

⚠️ cons

--not all databases optimise multiple CTEs equally (DuckDB does fine).

--exists only within that single SQL execution (temporary).


--chained ctes


--you can declare more than one CTE at the top of your query by separating them with commas:


WITH cte1 AS (...),
     cte2 AS (...)
SELECT ...
FROM cte2;


-- 🧾 goal: clean up missing population values, then rank hyraxes by weight
WITH cleaned AS (
    -- STEP 1 – replace NULL population_estimate with 0
    SELECT 
        species,
        habitat,
        COALESCE(population_estimate, 0) AS safe_population,
        avg_weight_kg
    FROM hyrax_species
),

ranked AS (
    -- STEP 2 – join cleaned data with habitats and add ranking per continent
    SELECT 
        c.species,
        h.continent,
        c.safe_population,
        c.avg_weight_kg,
        RANK() OVER (
            PARTITION BY h.continent
            ORDER BY c.avg_weight_kg DESC
        ) AS weight_rank
    FROM cleaned c
    JOIN habitats h ON c.habitat = h.habitat
)

-- STEP 3 – final output: top 1 per continent
SELECT 
    species,
    continent,
    avg_weight_kg,
    safe_population,
    weight_rank
FROM ranked
WHERE weight_rank <= 1;     -- change 1→3 for top 3 per continent



-- 3 chain ccte 


-- 🌍 goal: add summary layer after ranking
WITH cleaned AS (
    -- STEP 1 – fix missing values
    SELECT 
        species,
        habitat,
        COALESCE(population_estimate, 0) AS safe_population,
        avg_weight_kg
    FROM hyrax_species
),

ranked AS (
    -- STEP 2 – join cleaned data with habitats and rank per continent
    SELECT 
        c.species,
        h.continent,
        c.safe_population,
        c.avg_weight_kg,
        RANK() OVER (
            PARTITION BY h.continent
            ORDER BY c.avg_weight_kg DESC
        ) AS weight_rank
    FROM cleaned c
    JOIN habitats h ON c.habitat = h.habitat
),

continent_summary AS (
    -- STEP 3 – aggregate results by continent
    SELECT
        continent,
        COUNT(species) AS species_count,
        ROUND(AVG(avg_weight_kg), 2) AS avg_weight_by_continent,
        SUM(safe_population) AS total_population
    FROM ranked
    GROUP BY continent
)
-- 🧠 why this matters

this kind of layered query mimics real ETL or BI pipelines:

step 1: clean data

step 2: enrich / transform

step 3: summarise for reporting

you’re now effectively doing multi-stage data processing inside SQL — the same logic analysts use before visualising in Tableau or Power BI.
-- STEP 4 – final output: show summary
SELECT 
    continent,
    species_count,
    avg_weight_by_continent,
    total_population
FROM continent_summary;


-- ============================================
-- 🦦 ZOO_HYRAX DATABASE: MULTI-SPECIES EXPANSION (TEXT-BASED HABITATS)
-- CONTEXT: Base project has hyrax_species (habitat TEXT)
-- GOAL: Add other animal groups + learn constraints + UNION
-- ============================================

-- 1️⃣ Create meerkats table
CREATE TABLE meerkats (
    species TEXT,
    avg_weight_kg FLOAT CHECK(avg_weight_kg > 0),      -- must be positive
    avg_length_cm INT CHECK(avg_length_cm > 0),        -- positive integer
    diet TEXT CHECK(diet IN ('Omnivore', 'Herbivore', 'Carnivore')),  
    habitat TEXT NOT NULL,                             -- same text field as hyrax_species
    iucn_status TEXT CHECK(iucn_status IN ('Least Concern','Near Threatened','Vulnerable','Endangered','Critically Endangered')),
    population_estimate INT CHECK(population_estimate >= 0)
);

-- 2️⃣ Insert meerkat records
INSERT INTO meerkats
VALUES
('meerkat', 1.0, 25, 'Omnivore', 'savanna', 'Least Concern', 25000);

-- 3️⃣ Create elephants table
CREATE TABLE elephants (
    species TEXT,
    avg_weight_kg FLOAT CHECK(avg_weight_kg > 0),
    avg_length_cm INT CHECK(avg_length_cm > 0),
    diet TEXT CHECK(diet = 'Herbivore'),               -- elephants only herbivore
    habitat TEXT NOT NULL,
    iucn_status TEXT DEFAULT 'Endangered',
    population_estimate INT CHECK(population_estimate >= 0)
);

-- 4️⃣ Insert elephant record
INSERT INTO elephants
VALUES
('african_elephant', 5400, 700, 'Herbivore', 'savanna', 'Endangered', 415000);

-- 5️⃣ Create rock_rabbits table
CREATE TABLE rock_rabbits (
    species TEXT,
    avg_weight_kg FLOAT CHECK(avg_weight_kg > 0),
    avg_length_cm INT CHECK(avg_length_cm > 0),
    diet TEXT CHECK(diet = 'Herbivore'),
    habitat TEXT NOT NULL,
    iucn_status TEXT DEFAULT 'Least Concern',
    population_estimate INT CHECK(population_estimate >= 0)
);

-- 6️⃣ Insert rock rabbit record
INSERT INTO rock_rabbits
VALUES
('rock_rabbit', 2.3, 40, 'Herbivore', 'rocky', 'Least Concern', 8000);

-- 7️⃣ UNION all species into one combined dataset for Excel export
SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status, population_estimate, 'Hyrax' AS category
FROM hyrax_species
UNION ALL
SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status, population_estimate, 'Meerkat' AS category
FROM meerkats
UNION ALL
SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status, population_estimate, 'Elephant' AS category
FROM elephants
UNION ALL
SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status, population_estimate, 'Rock Rabbit' AS category
FROM rock_rabbits;

-- 🧠 Notes:
-- • UNION ALL keeps duplicates (since species names might overlap).
-- • All columns must match in number + type across all tables.
-- • This combined view can be exported for Excel statistical analysis.

-- 8️⃣ Optional constraint practice:
-- INSERT INTO elephants VALUES ('test_elephant', -5, 500, 'Herbivore', 'forest', 'Endangered', 300);
-- ❌ Should fail due to avg_weight_kg < 0 (CHECK constraint).

-- ============================================
-- 🦦 END OF FIXED MULTI-SPECIES EXPANSION SCRIPT
-- ============================================


SELECT * FROM hyrax_species;
SELECT * FROM meerkats;
SELECT * FROM elephants;
SELECT * FROM rock_rabbits;


--🧱 Constraints

Rules that protect data integrity inside a table.

Common types:

PRIMARY KEY – unique ID per row.

NOT NULL – value required (no blanks).

UNIQUE – no duplicate values allowed.

CHECK – enforces valid ranges (e.g. weight > 0).

DEFAULT – auto-fills missing values.

FOREIGN KEY – links to another table safely.




🔗 UNION / UNION ALL

Combines results from multiple SELECT queries vertically.

All SELECTs must have the same number and type of columns.

UNION removes duplicates, UNION ALL keeps them.

Used to merge related datasets (e.g. hyrax + meerkat + elephant).


ctes are Temporary “mini-tables” created with WITH at the top of a query.

Each CTE builds on the previous one — like steps in a data pipeline.

Example flow:

cleaned → fix NULLs

ranked → add ranks

summary → aggregate for reporting

Makes long SQL analyses modular, readable, and reusable.







--postgre sql

COPY (
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status, population_estimate, 'Hyrax' AS category
    FROM hyrax_species
    UNION ALL
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status, population_estimate, 'Meerkat' AS category
    FROM meerkats
    UNION ALL
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status, population_estimate, 'Elephant' AS category
    FROM elephants
    UNION ALL
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status, population_estimate, 'Rock Rabbit' AS category
    FROM rock_rabbits
) 
TO 'C:/Users/sam breen/Documents/zoo_species_expanded.csv' 
(WITH HEADER, DELIMITER ',');


--db


COPY (
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status,
           population_estimate, 'Hyrax' AS category
    FROM hyrax_species
    UNION ALL
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status,
           population_estimate, 'Meerkat' AS category
    FROM meerkats
    UNION ALL
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status,
           population_estimate, 'Elephant' AS category
    FROM elephants
    UNION ALL
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status,
           population_estimate, 'Rock Rabbit' AS category
    FROM rock_rabbits
)
TO 'C:/Users/sam breen/Documents/zoo_species_expanded.csv'
WITH (HEADER TRUE, DELIMITER ',');




COPY (
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status,
           population_estimate, 'Hyrax' AS category
    FROM hyrax_species
    UNION ALL
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status,
           population_estimate, 'Meerkat' AS category
    FROM meerkats
    UNION ALL
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status,
           population_estimate, 'Elephant' AS category
    FROM elephants
    UNION ALL
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status,
           population_estimate, 'Rock Rabbit' AS category
    FROM rock_rabbits
)
TO 'C:\\Users\\sam breen\\Desktop\\zoo_species_expanded.csv'
WITH (HEADER TRUE, DELIMITER ',');



COPY (
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status,
           population_estimate, 'Hyrax' AS category
    FROM hyrax_species
    UNION ALL
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status,
           population_estimate, 'Meerkat' AS category
    FROM meerkats
    UNION ALL
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status,
           population_estimate, 'Elephant' AS category
    FROM elephants
    UNION ALL
    SELECT species, avg_weight_kg, avg_length_cm, diet, habitat, iucn_status,
           population_estimate, 'Rock Rabbit' AS category
    FROM rock_rabbits
)
TO 'C:\\Temp\\zoo_species_expanded.csv'
WITH (HEADER TRUE, DELIMITER ',');


