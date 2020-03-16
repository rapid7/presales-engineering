WITH

   cert_expiration_dates AS (

      SELECT DISTINCT asset_id, service_id, name,value, port

      FROM dim_asset_service_configuration

      WHERE lower(name) LIKE '%ssl.cert.not.valid.after'

   )

SELECT ip_address, host_name, mac_address, ced.value as EXPIRATION_DATE, ced.port

FROM dim_asset

   JOIN cert_expiration_dates AS ced USING (asset_id)

WHERE (cast(ced.value AS DATE) - CURRENT_TIMESTAMP  <= INTERVAL '90 days') AND (cast(ced.value AS DATE) - CURRENT_TIMESTAMP  > INTERVAL '0 days')