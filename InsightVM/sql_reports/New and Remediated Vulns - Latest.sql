WITH previous_vulns AS (
  SELECT asset_id, vulnerability_id
  FROM fact_asset_scan_vulnerability_finding fasvf
  JOIN dim_scan ds USING (scan_id)
  GROUP BY asset_id, vulnerability_id, fasvf.scan_id, ds.finished
  HAVING fasvf.scan_id = previousscan(asset_id)
),
  previous_scan AS (
    SELECT asset_id, das.scan_finished, das.scan_id
    FROM dim_asset_scan das
    GROUP BY asset_id, das.scan_finished, das.scan_id
    HAVING scan_id = previousscan(asset_id)
  ),
  current_vulns AS (
    SELECT asset_id, vulnerability_id
    FROM fact_asset_scan_vulnerability_finding fasvf
    JOIN dim_scan ds USING (scan_id)
    GROUP BY asset_id, vulnerability_id, fasvf.scan_id, ds.finished
    HAVING fasvf.scan_id = lastscan(asset_id)
),
  current_scan AS (
    SELECT asset_id, das.scan_finished, das.scan_id
    FROM dim_asset_scan das
    GROUP BY asset_id, das.scan_finished, das.scan_id
    HAVING scan_id = lastscan(asset_id)
),
  vuln_diff AS (
    SELECT asset_id, cv.vulnerability_id AS current_vuln_id, pv.vulnerability_id AS prev_vuln_id
    FROM current_vulns cv
    FULL JOIN previous_vulns pv USING (asset_id, vulnerability_id)
    GROUP BY asset_id, cv.vulnerability_id, pv.vulnerability_id
    HAVING cv.vulnerability_id IS NULL OR pv.vulnerability_id IS NULL
)
SELECT da.host_name, da.ip_address, dos.description AS operating_system, dv.title, htmltotext(dv.description) AS description, dv.cvss_score, round(dv.riskscore) as risk_score,
  CASE
    WHEN vd.current_vuln_id IS NOT NULL THEN cs.scan_finished
    WHEN vd.prev_vuln_id IS NOT NULL THEN ps.scan_finished
  END AS scan_timestamp,
  CASE
    WHEN vd.current_vuln_id IS NOT NULL THEN cs.scan_id
    WHEN vd.prev_vuln_id IS NOT NULL THEN ps.scan_id
  END AS scan_id,
  CASE
    WHEN vd.current_vuln_id IS NULL THEN 'REMEDIATED'
    WHEN vd.prev_vuln_id IS NULL THEN 'NEW'
  END AS status
FROM dim_asset da
JOIN dim_operating_system dos USING (operating_system_id)
JOIN previous_scan ps USING (asset_id)
JOIN current_scan cs USING (asset_id)
JOIN vuln_diff vd USING (asset_id)
JOIN dim_vulnerability dv ON (dv.vulnerability_id = vd.current_vuln_id) OR (dv.vulnerability_id = vd.prev_vuln_id);

