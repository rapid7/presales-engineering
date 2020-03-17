-- Asset Last Scanned.sql
-- Description: Identify last scan time and asset details by asset_id 
-- Data Model Version: 2.2.0

SELECT fa.asset_id, lastscan(fa.asset_id) as last_scan_id, ds.name, da.host_name, da.ip_address, da.mac_address, fa.scan_finished AS last_scan
FROM fact_asset as fa
JOIN dim_asset as da USING (asset_id)
JOIN dim_site_asset as dsa USING (asset_id)
JOIN dim_site as ds USING (site_id)
ORDER BY name, last_scan DESC
