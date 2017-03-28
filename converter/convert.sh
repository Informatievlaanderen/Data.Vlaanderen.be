#!/usr/bin/env bash

echo "$(dirname $(readlink -f $0))"

# Adres

python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --contributors --target Adres --output $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../src/adres.ttl --rdf_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf --merge --output $(dirname $(readlink -f $0))/../ns/adres.ttl
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../ns/adres.ttl --output $(dirname $(readlink -f $0))/../ns/adres.html --schema vocabularynl
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/adres_ap.tsv --csv_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --ap --output $(dirname $(readlink -f $0))/../doc/ap/adres/index.html

# Generiek

python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --contributors --target Generiek --output $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../src/generiek.ttl --rdf_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf --merge --output $(dirname $(readlink -f $0))/../ns/generiek.ttl
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../ns/generiek.ttl --output $(dirname $(readlink -f $0))/../ns/generiek.html --schema vocabularynl

# Gebouw

#python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --contributors --target Gebouw --output $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf
#python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../src/gebouw.ttl --rdf_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf --merge --output $(dirname $(readlink -f $0))/../ns/gebouw.ttl
#python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../ns/gebouw.ttl --output $(dirname $(readlink -f $0))/../ns/gebouw.html --schema vocabularynl

# Dienstverlening

python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --contributors --target Dienstverlening --output $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../src/dienstverlening.ttl --rdf_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf --merge --output $(dirname $(readlink -f $0))/../ns/dienstverlening.ttl
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../ns/dienstverlening.ttl --output $(dirname $(readlink -f $0))/../ns/dienstverlening.html --schema vocabularynl
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/dienstverlening_ap.tsv --csv_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --ap --output $(dirname $(readlink -f $0))/../doc/ap/dienstverlening/index.html

# Organisatie

python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --contributors --target Organisatie --output $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../src/organisatie.ttl --rdf_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf --merge --output $(dirname $(readlink -f $0))/../ns/organisatie.ttl
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../ns/organisatie.ttl --output $(dirname $(readlink -f $0))/../ns/organisatie.html --schema vocabularynl
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/organisatie_ap.tsv --csv_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --ap --output $(dirname $(readlink -f $0))/../doc/ap/organisatie/index.html

# Persoon

python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --contributors --target Persoon --output $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../src/persoon.ttl --rdf_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf --merge --output $(dirname $(readlink -f $0))/../ns/persoon.ttl
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../ns/persoon.ttl --output $(dirname $(readlink -f $0))/../ns/persoon.html --schema vocabularynl
python3 ./specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/persoon_ap.tsv --csv_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --ap --output $(dirname $(readlink -f $0))/../doc/ap/persoon/index.html