SELECT *
FROM medical_costs
limit 20;

--1. What is the financial impact of smoking? Calculate the total charges, 
--average charges, and the percentage of total company revenue contributed by smokers versus non-smokers.

WITH total_cost AS (
SELECT smoker, ROUND(SUM(charges)::numeric,2) AS total_revenue, ROUND(AVG(charges)::numeric,2) AS avg_revenue
FROM medical_costs
GROUP BY smoker
)
SELECT 
	smoker, 
	total_revenue,
	avg_revenue,
	ROUND(100* total_revenue / SUM(total_revenue) OVER()::numeric,2) AS ptg_revenue
FROM total_cost
ORDER BY total_revenue DESC;


--2. Are we undercharging or overcharging based on BMI? Group customers into standard BMI categories 
--(Underweight < 18.5, Normal 18.5-24.9, Overweight 25-29.9, Obese > 30) and find the average insurance charge for each group.

WITH bmi_group AS(
SELECT 
	charges,
	bmi,
	CASE 
		WHEN bmi < 18.5 THEN 'Underweight'
		WHEN bmi >=18.5 AND bmi <=24.99 THEN 'Normal'
		WHEN bmi >=25 AND bmi <=29.99 THEN 'Overweight'
		ELSE 'Obese'
	END AS bmi_cat
FROM medical_costs
)
SELECT bmi_cat, ROUND(AVG(charges)::numeric,2) AS avg_charge
FROM bmi_group
GROUP BY bmi_cat;
	

--3. Who are our top 5% highest-cost customers? Write a query to identify them and list their profiles (age, sex, bmi, smoker status) 
--to see what drives the highest claims.

WITH percent_charges AS (
SELECT PERCENT_RANK() OVER(ORDER BY charges DESC) AS percentage_rank , age, sex, bmi, smoker, charges
FROM medical_costs
)
SELECT age, sex, bmi, smoker, charges
FROM percent_charges
WHERE percentage_rank<=0.05
ORDER by charges DESC;


--4. Which specific combination of risk factors (e.g., Smoker + Obese, Smoker + Non-Obese, Non-Smoker + Obese, Non-Smoker + Non-Obese) 
--results in the highest average insurance charge?

WITH bmi_group AS(
SELECT 
	smoker,
	charges,
	bmi,
	CASE 
		WHEN bmi < 18.5 THEN 'Underweight'
		WHEN bmi >=18.5 AND bmi <=24.99 THEN 'Normal'
		WHEN bmi >=25 AND bmi <=29.99 THEN 'Overweight'
		ELSE 'Obese'
	END AS bmi_cat
FROM medical_costs
)
SELECT smoker, bmi_cat, ROUND(AVG(charges)::numeric,2) AS avg_charge
FROM bmi_group
GROUP BY  smoker, bmi_cat
ORDER BY avg_charge DESC;

	
--5. Which geographic region has the highest concentration of smokers who are also obese? Rank the regions based on this specific customer count.

WITH bmi_group AS(
SELECT 
	region,
	charges,
	bmi,
	smoker,
	CASE 
		WHEN bmi < 18.5 THEN 'Underweight'
		WHEN bmi >=18.5 AND bmi <=24.99 THEN 'Normal'
		WHEN bmi >=25 AND bmi <=29.99 THEN 'Overweight'
		ELSE 'Obese'
	END AS bmi_cat
FROM medical_costs
)
SELECT  RANK () OVER (ORDER BY COUNT(*) DESC), region, COUNT(*) AS NUM_people
FROM bmi_group
WHERE smoker='yes' AND bmi_cat='Obese'
GROUP BY region;

