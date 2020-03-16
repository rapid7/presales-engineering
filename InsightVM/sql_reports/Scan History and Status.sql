-- Scan History and Status.sql
-- Description: Report site scans along with target(s), assets found, vulns found, and status of scan
-- Data Model Version: 2.2.0

SELECT ds.name AS site_name, dtarget.target, dscan.started, dscan.finished, dst.description AS type, fscan.assets, fscan.vulnerabilities, dsss.description AS status
FROM fact_site AS fs
JOIN dim_site AS ds USING (site_id)
JOIN dim_site_scan AS dss USING (site_id)
JOIN dim_scan AS dscan USING (scan_id)
JOIN dim_scan_status AS dsss USING (status_id)
JOIN dim_scan_type AS dst USING (type_id)
JOIN dim_site_target AS dtarget USING (site_id)
JOIN fact_scan AS fscan USING (scan_id)
ORDER BY ds.name ASC, dscan.finished DESC
