#!/usr/bin/env bash

API_KEY="<API KLIC Z VIRUSTOTAL>"
HASH_FILE="otisky.sha256"
VERIFIED_HASHES="otisky_otestovane.sha256"
RESULTS="vysledky_$(date +%F).txt"
DIRECTORY="$(dirname "$(readlink -f "$0")")"
VYPOCET="hash_calc.sh"

"$DIRECTORY/$VYPOCET"

while IFS= read -r line; do
	hash=$(echo "$line" | awk '{print $1}' | xargs)
	if ! grep -Fq "$hash" "$VERIFIED_HASHES"; then
		path=$(echo "$line" | awk '{print $2}')
		echo "$path" | tee -a "$RESULTS"

		curl --request GET \
 		--url "https://virustotal.com/api/v3/files/$hash" \
  		--header "x-apikey: $API_KEY" \
  		--silent | jq -r '.data.attributes | "Název: \(.meaningful_name // "Neznámý") | Typ: \(.type_description) | DETEKCE: \(.last_analysis_stats.malicious) / \(.last_analysis_stats.malicious + .last_analysis_stats.undetected + .last_analysis_stats.harmless)"' | tee -a "$RESULTS" 
		
		echo "$hash" >> "$VERIFIED_HASHES"
		#sleep 25
		
	fi
done < "$HASH_FILE"
