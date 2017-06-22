#!/usr/bin/env bash

echo "$(dirname $(readlink -f $0))"

cd $(dirname $(readlink -f $0))/specgen
. bin/activate

cd $(dirname $(readlink -f $0))/..

# Adres

echo "Adres"

python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --contributors --target Adres --output $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../src/adres.ttl --rdf_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf --merge --output $(dirname $(readlink -f $0))/../ns/adres.ttl
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../ns/adres.ttl --output $(dirname $(readlink -f $0))/../ns/adres.html --schema vocabularynl
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/'Adresregister AP.tsv' --csv_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --ap --output $(dirname $(readlink -f $0))/../doc/ap/adresregister/index.html

# Generiek

echo "Generiek"

python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --contributors --target Generiek --output $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../src/generiek.ttl --rdf_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf --merge --output $(dirname $(readlink -f $0))/../ns/generiek.ttl
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../ns/generiek.ttl --output $(dirname $(readlink -f $0))/../ns/generiek.html --schema vocabularynl
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/'Generiek Basis AP.tsv' --csv_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --ap --output $(dirname $(readlink -f $0))/../doc/ap/generiek/index.html

# Gebouw

#echo "Gebouw"

#python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --contributors --target Gebouw --output $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf
#python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../src/gebouw.ttl --rdf_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf --merge --output $(dirname $(readlink -f $0))/../ns/gebouw.ttl
#python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../ns/gebouw.ttl --output $(dirname $(readlink -f $0))/../ns/gebouw.html --schema vocabularynl

# Dienst

echo "Dienst"

python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --contributors --target Dienst --output $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../src/dienst.ttl --rdf_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf --merge --output $(dirname $(readlink -f $0))/../ns/dienst.ttl
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../ns/dienst.ttl --output $(dirname $(readlink -f $0))/../ns/dienst.html --schema vocabularynl
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/'Dienstencataloog AP.tsv' --csv_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --ap --output $(dirname $(readlink -f $0))/../doc/ap/dienstencataloog/index.html

# Organisatie

echo "Organisatie"

python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --contributors --target Organisatie --output $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../src/organisatie.ttl --rdf_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf --merge --output $(dirname $(readlink -f $0))/../ns/organisatie.ttl
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../ns/organisatie.ttl --output $(dirname $(readlink -f $0))/../ns/organisatie.html --schema vocabularynl
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/'Organisatie Basis AP.tsv' --csv_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --ap --output $(dirname $(readlink -f $0))/../doc/ap/organisatie/index.html

# Persoon

echo "Persoon"

python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --contributors --target Persoon --output $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../src/persoon.ttl --rdf_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.rdf --merge --output $(dirname $(readlink -f $0))/../ns/persoon.ttl
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --rdf $(dirname $(readlink -f $0))/../ns/persoon.ttl --output $(dirname $(readlink -f $0))/../ns/persoon.html --schema vocabularynl
python3 $(dirname $(readlink -f $0))/specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py --csv $(dirname $(readlink -f $0))/../src/'Persoon Basis AP.tsv' --csv_contributor $(dirname $(readlink -f $0))/../src/stakeholders_latest.csv --ap --output $(dirname $(readlink -f $0))/../doc/ap/persoon/index.html
