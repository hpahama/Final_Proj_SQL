-- Countries with the highest GDP, happiness ladder score, and an urban population exceeding 50% of the total population.
SELECT 
    c.country_name,
    e.gdp,
    h.ladder_score,
    pd.urban_population
FROM 
    countries c
JOIN 
    economic e ON c.id = e.country_id
JOIN 
    happiness h ON c.id = h.country_id
JOIN 
    population_demographics pd ON c.id = pd.country_id
WHERE 
    e.gdp IN (SELECT MAX(gdp) FROM economic)
    AND h.ladder_score IN (SELECT MAX(ladder_score) FROM happiness)
    AND pd.urban_population > 50;

-- Correlation between generosity and happiness ladder score.
SELECT 
    h.ladder_score,
    s.generosity
FROM 
    happiness h
JOIN 
    social s ON h.country_id = s.country_id;
      -->Note: must have a follow up code for visualization I suppose:
      --> next: - Correlation between generosity and happiness ladder score. - This explores how generosity, a demographic/social behavior, correlates with happiness scores in different countries.
To find the correlation between generosity and the happiness ladder score, you can write an SQL query to retrieve the relevant data and then use statistical software or SQL functions to calculate the correlation. Here’s how you can structure your SQL query:

SQL Code
sql
SELECT 
    h.ladder_score,
    s.generosity
FROM 
    happiness h
JOIN 
    social s ON h.country_id = s.country_id;
Explanation
SELECT Clause: Retrieves the ladder_score from the happiness table and generosity from the social table.

FROM and JOIN Clauses: Joins the happiness and social tables based on their respective country_id.

Next Steps
Once you have the data from the query, you can use statistical software such as R, Python (Pandas), or SQL functions to calculate the correlation coefficient between generosity and the happiness ladder score.

