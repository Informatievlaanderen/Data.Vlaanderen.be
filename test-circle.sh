#!/bin/bash

# This is just a utility file to help with the development of the circleci pipeline
# It assumes you're running on linux with docker installed (it might work on osx or other unix-like systems, but hasn' been tested)
# You need to have local image called `ruby-linkeddata` which has the linkeddata gem installed
# This script does not keep itself automatically up to date with the circleci config
# That said, it might prove useful if the circleci logs are not helpful in finding an issue


set -e
echo "Making output folder /tmp/workspace"
mkdir -p /tmp/workspace
mkdir -p /tmp/oslo-landingpages

echo "Generate VOC ttl"
jq -r '.[] | select(.type | contains("voc")) | @sh "docker run -v /tmp/workspace:/tmp/workspace -v $(pwd):/host -w /host informatievlaanderen/oslo-ea-to-rdf convert -i src/\(.eap) -c config/config-voc.json -d \(.diagram) -o /tmp/workspace/ttl/\(.name).ttl"' < config/eap-mapping.json | bash -e

echo "Generate AP tsv"
jq -r '.[] | select(.type | contains("ap")) | @sh "docker run -v /tmp/workspace:/tmp/workspace -v $(pwd):/host -w /host informatievlaanderen/oslo-ea-to-rdf tsv -i src/\(.eap) -c config/config-ap.json -d \(.diagram) -o /tmp/workspace/tsv/\(.name).tsv"' < config/eap-mapping.json | bash -e

echo "Add VOC contributors"
jq -r '.[] | select(.type | contains("voc")) | @sh "docker run -v /tmp/workspace:/tmp/workspace -v $(pwd):/host -w /host informatievlaanderen/oslo-specification-generator --add_contributors --rdf /tmp/workspace/ttl/\(.name).ttl --csv src/stakeholders.csv --csv_contributor_role_column \(.contributors) --output /tmp/workspace/ttl/\(.name).ttl"' < config/eap-mapping.json | bash -e

echo "Render VOC html"
jq -r '.[] | select(.type | contains("voc")) | @sh "echo \(.name) && docker run -v /tmp/workspace:/tmp/workspace -v $(pwd):/host -w /host informatievlaanderen/oslo-specification-generator --rdf /tmp/workspace/ttl/\(.name).ttl --schema \(.template) --schema_folder templates/ --output /tmp/workspace/voc/\(.name)/index.html"' < config/eap-mapping.json | bash -e

echo "Render VOC serializations"
docker run -v /tmp/workspace:/tmp/workspace alpine sed -i '/TBD/d' /tmp/workspace/ttl/gebouw.ttl
docker run -v /tmp/workspace:/tmp/workspace alpine sed -i '/"TODO"^^xsd:date/d' /tmp/workspace/ttl/openbaardomein.ttl
docker run -v /tmp/workspace:/tmp/workspace alpine sed -i '/"TODO"^^xsd:date/d' /tmp/workspace/ttl/weg.ttl
for model in $(ls /tmp/workspace/ttl | sed 's/.ttl//'); do
  echo ${model}
  docker run -v /tmp/workspace:/tmp/workspace alpine sed -i 's/<TODO>/<http:\/\/example.com\/TODO>/g' /tmp/workspace/ttl/${model}.ttl
  docker run -v /tmp/workspace:/tmp/workspace ruby-linkeddata rdf serialize --input-format turtle --output-format ntriples /tmp/workspace/ttl/${model}.ttl -o /tmp/workspace/voc/${model}.nt
  docker run -v /tmp/workspace:/tmp/workspace ruby-linkeddata rdf serialize --input-format turtle --output-format rdfxml /tmp/workspace/ttl/${model}.ttl -o /tmp/workspace/voc/${model}.rdf
  docker run -v /tmp/workspace:/tmp/workspace ruby-linkeddata rdf serialize --input-format turtle --output-format jsonld /tmp/workspace/ttl/${model}.ttl -o /tmp/workspace/voc/${model}.jsonld
  docker run -v /tmp/workspace:/tmp/workspace alpine cp /tmp/workspace/voc/${model}.jsonld /tmp/workspace/voc/${model}.json
  docker run -v /tmp/workspace:/tmp/workspace alpine cp /tmp/workspace/ttl/${model}.ttl /tmp/workspace/voc/${model}.ttl
done

echo "Render AP html and jsonld"
jq -r '.[] | select(.type | contains("ap")) | @sh "echo \(.name) && docker run -v /tmp/workspace:/tmp/workspace -v $(pwd):/host -w /host informatievlaanderen/oslo-specification-generator --ap --csv /tmp/workspace/tsv/\(.name).tsv --csv_contributor src/stakeholders.csv --csv_contributor_role_column \(.contributors) --title \(.title) --name \(.name) --schema \(.template) --schema_folder templates/ --output /tmp/workspace/ap/\(.name)/index.html"' < config/eap-mapping.json | bash -e
for model in $(ls /tmp/workspace/tsv | sed 's/.tsv//'); do
  docker run -v /tmp/workspace:/tmp/workspace --entrypoint "" informatievlaanderen/oslo-specification-generator python /app/specgen/generate_jsonld.py --input /tmp/workspace/tsv/${model}.tsv --output /tmp/workspace/ap/${model}.jsonld
done

echo "Assemble website in /tmp/oslo-landingpages"
rm -rf /tmp/oslo-landingpages/*

cp -R site-skeleton/* /tmp/oslo-landingpages/

cp -R /tmp/workspace/voc/* /tmp/oslo-landingpages/ns/
cp /tmp/workspace/ap/*.jsonld /tmp/oslo-landingpages/context/
cp -R /tmp/workspace/ap/* /tmp/oslo-landingpages/doc/applicatieprofiel/

echo "Done generating website"
