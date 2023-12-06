SELECT 
	da.ip_address, 
	da.host_name
FROM dim_asset da 
ORDER BY da.host_name ASC