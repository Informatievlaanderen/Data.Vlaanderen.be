#!/bin/bash

set -x

extractwhat=$1

# extraction commands

extract_tsv() {
    jq -r '.[] | select(.type | contains("ap")) | @sh "java -jar /app/ea-2-rdf.jar tsv -i src/\(.eap) -c config/config-ap.json -d \(.diagram) -o /tmp/workspace/tsv/\(if .prefix then .prefix + "/" else "" end)\(.name).tsv"' < config/eap-mapping.json | bash
}

# do the conversions

if [ ! -f "checkout.txt" ]
then
    # normalise the functioning
    echo $CWD > checkout.txt
fi

cat checkout.txt | while read line
do
    echo "Processing line: $line"
    pushd $line
      case $extractwhat in
	tsv) extract_tsv
	     ;;
          *) echo "towhat not defined"
      esac 	   
    popd
done

    
