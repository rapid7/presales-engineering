-- asset-vuln-solution-fix.sql
-- Description: Identify unique vulnerabilities with solution and fix info for assets
-- Data Model Version: 2.2.0

SELECT fav.asset_id AS "Asset ID", fa.riskscore AS "Asset Riskscore", da.ip_address AS "IP Address", da.host_name AS "Host Name", dv.vulnerability_id AS "Vulnerability ID", dv.title  AS "Vulnerabiltiy", dv.cvss_score AS "CVSS Score", ds.summary AS "Solution", ds.fix AS "Fix"
FROM fact_asset_vulnerability_finding AS fav
JOIN dim_vulnerability AS dv ON fav.vulnerability_id = dv.vulnerability_id
JOIN dim_asset AS da ON fav.asset_id = da.asset_id
JOIN fact_asset fa ON fav.asset_id = fa.asset_id
JOIN dim_vulnerability_solution AS dvs ON dv.vulnerability_id = dvs.vulnerability_id
JOIN dim_solution AS ds ON dvs.solution_id = ds.solution_id
GROUP by fav.asset_id, fa.riskscore, da.ip_address, da.host_name, dv.vulnerability_id, dv.title, dv.cvss_score, ds.summary, ds.fix
ORDER by fav.asset_id ASC
