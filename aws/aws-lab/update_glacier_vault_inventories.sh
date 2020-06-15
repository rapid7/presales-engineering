#!/bin/bash
#update all vault inventories on current account
#https://docs.aws.amazon.com/cli/latest/reference/glacier/initiate-job.html

VAULT_LIST=$(aws glacier list-vaults --account-id - | grep "VaultName" | cut -d \" -f 4)

for vault_name in $VAULT_LIST
do
	#echo "$vault_name"
	aws glacier initiate-job --account-id - --vault-name "$vault_name" --job-parameters '{"Type": "inventory-retrieval"}'

done

#aws glacier list-jobs --account-id - --vault-name 