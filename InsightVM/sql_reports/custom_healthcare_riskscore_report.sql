
WITH 
   vuln_references AS ( 
     SELECT dv.vulnerability_id,
            round(dv.cvss_score::numeric, 1) AS vuln_cvss,
            dv.severity AS vuln_severity,
            dv.title AS vuln_name,
            dv.description,
            dv.exploits AS exploitability,
            array_to_string(array_agg(dvr.reference) FILTER (WHERE dvr.source = 'CVE'), ', ') AS cves,
            array_to_string(array_agg(dvr.reference) FILTER (WHERE dvr.source <> 'CVE'), ', ') AS other_references
     FROM dim_vulnerability_reference dvr
     LEFT JOIN dim_vulnerability dv ON (dv.vulnerability_id = dvr.vulnerability_id)
     GROUP BY dv.vulnerability_id, dv.cvss_score, dv.severity, dv.title, dv.description, dv.exploits
   ),
   netbios_assets AS (
     SELECT dahn.asset_id, 
            dahn.host_name 
     FROM dim_asset_host_name dahn 
     WHERE source_type_id = 'N'
   ),
   asset_tags AS (
     SELECT da.asset_id,
            da.host_name,
            da.ip_address,
            na.host_name as NetBIOS_Name,
            array_to_string(array_agg(dt.tag_name), ', ') AS Asset_Tags
     FROM dim_asset da
     LEFT JOIN dim_tag_asset dta ON (dta.asset_id = da.asset_id)
     LEFT JOIN dim_tag dt ON (dt.tag_id = dta.tag_id)
     LEFT JOIN netbios_assets na ON (da.asset_id = na.asset_id)
     GROUP BY da.asset_id, da.host_name, da.ip_address, na.host_name
   ),
   asset_vulnerability_solution AS (
     SELECT davbs.asset_id,
            davbs.vulnerability_id,
            davbs.solution_id,
            ds.fix AS vuln_solution
     FROM dim_asset_vulnerability_best_solution davbs
     JOIN dim_solution ds ON (davbs.solution_id = ds.solution_id)
   ),

  --Tim added:
   exploit_method AS (
	SELECT dcav.type_id, 
		dcav.description
	FROM dim_cvss_access_vector dcav
	LEFT JOIN dim_vulnerability ON (dim_vulnerability.cvss_access_vector_id = dcav.type_id)
   )

SELECT favi.vulnerability_id AS PluginID,
	vr.cves,       
	vr.vuln_cvss,


	-- Tim added:
	em.type_id,
	em.description,
	at.Asset_Tags,
	vr.vuln_cvss +
	--case
	--	when vr.exploits == 0 then 1 -- no exploits available, so no need to look up if they are local/remote
	--	when em.description == 'L' then 3
	--	when em.description == 'A' then 5
	--	when em.description == 'N' then 5		
	--	else 1
	--end +
	case 
		when at.Asset_tags like '%HV0%' then 5 
		when at.Asset_tags like '%HV1%' then 4 
		when at.Asset_tags like '%HV2%' then 3 
		when at.Asset_tags like '%HV3%' then 2 
		when at.Asset_tags like '%HV4%' then 1 
		else 0
		-- could be a case where not tagged with HV or it is tagged with multiple HVs and need to make the max
		-- Microsoft SQL does short-circuiting with case when statements, unclear about PSQL. This syntax should solve the multiple tag problem and use the highest one if PSQL does short-circuiting
	end
		AS prospect_custom_risk,





       vr.vuln_severity,
       at.host_name AS Host,
       at.ip_address AS IP_Address,
       at.NetBIOS_Name,
       At.asset_id,
	Dp.name as protocol,
   	CASE WHEN favi.port = -1 THEN NULL ELSE favi.port END AS Ports, 
      vr.vuln_name,
      proofAsText(vr.description) AS Vuln_Synopsis,
      proofAsText(vr.description) AS vuln_description,
      proofAsText(avs.vuln_solution) as solution,
      vr.other_references AS See_Also_Additional_Resources,
      proofAsText(favi.proof) AS plugin_output_proof, 
      vr.exploitability,
	-- asset tags normally goes here          
       -1 AS assigned_asset_category,
	-- custom risk column goes here	prospect_custom_risk,
       -1 AS calculated_priority,
       -1 AS remediation_assignee,
       -1 AS fields_for_query
FROM fact_asset_vulnerability_instance favi
JOIN asset_tags at ON (at.asset_id = favi.asset_id)
JOIN vuln_references vr ON (vr.vulnerability_id = favi.vulnerability_id)
JOIN asset_vulnerability_solution avs ON (favi.asset_id = avs.asset_id AND favi.vulnerability_id = avs.vulnerability_id)
JOIN dim_protocol dp USING (protocol_id) 

-- Tim Added:
LEFT JOIN exploit_method em ON (dim_vulnerability.cvss_access_vector_id = em.type_id)


LEFT JOIN dim_service dsvc USING (service_id) 
