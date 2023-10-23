SELECT ds.name AS site, da.ip_address, da.host_name, da.mac_address, dv.title AS vulnerability_title, dv.severity, 
   round(dv.cvss_score::numeric, 2) AS cvss_score, round(dv.riskscore::numeric, 0) AS risk 

FROM fact_asset_vulnerability_finding favf 
   JOIN dim_asset da USING (asset_id) 
   JOIN dim_operating_system dos USING (operating_system_id) 
   JOIN dim_vulnerability dv USING (vulnerability_id) 
   JOIN dim_site_asset dsa USING (asset_id) 
   JOIN dim_site ds USING (site_id) 
   WHERE dv.title LIKE '%CVE-2017-5638%'
ORDER BY da.ip_address ASC, dv.title ASC