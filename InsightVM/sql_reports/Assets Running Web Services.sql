-- Assets Running Web Services.sql
-- Description: Identify port of HTTP/HTTPS services running on assets
-- Data Model Version: 2.2.0

SELECT DISTINCT da.host_name, da.ip_address, ds.name AS service_name, das.port
FROM fact_asset fa
JOIN dim_asset da USING (asset_id)
JOIN dim_asset_service das USING (asset_id)
JOIN dim_service ds USING (service_id)
WHERE (ds.name LIKE '%HTTP%') AND (ds.name NOT LIKE '%UPnP%')
GROUP BY fa.asset_id, da.host_name, da.ip_address, ds.name, das.port
ORDER BY da.ip_address
