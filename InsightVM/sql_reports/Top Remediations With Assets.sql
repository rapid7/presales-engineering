-- Top Remediations With Assets.sql
-- Description: Identify top remediations and details per asset
-- Data Model Version: 2.2.0

SELECT DISTINCT
  ds.summary AS "Solution",
  proofAsText(ds.fix) AS "Fix",
  ds.estimate AS "Estimate",
  dv.title AS "Vulnerability Title",
  da.ip_address AS "IP Address",
  da.host_name AS "Host Name",
  round(dv.riskscore) AS "Risk Score"
FROM
  fact_remediation(10, 'riskscore DESC') fr
  JOIN dim_solution ds ON (fr.solution_id = ds.solution_id)
  JOIN dim_asset_vulnerability_solution davs ON (fr.solution_id = davs.solution_id)
  JOIN dim_vulnerability dv USING (vulnerability_id)
  JOIN dim_asset da USING (asset_id)
