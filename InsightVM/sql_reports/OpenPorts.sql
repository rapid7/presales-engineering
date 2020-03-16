-- OpenPorts.sql
-- Description: Report on open ports/services and provides a view of all open ports on assets
-- Data Model Version: 2.2.0

SELECT ds.name AS site_name, da.ip_address, da.host_name, da.mac_address, dos.description AS operating_system, dht.description, dos.asset_type, dos.cpe , das.service_id , das.port , ds2.name
FROM dim_asset da
   JOIN dim_operating_system dos USING (operating_system_id)
   JOIN dim_host_type dht USING (host_type_id)
   JOIN dim_site_asset dsa USING (asset_id) 
   JOIN dim_site ds USING (site_id)
Join dim_asset_service das USING (asset_id)
join dim_service ds2 USING (service_id)
