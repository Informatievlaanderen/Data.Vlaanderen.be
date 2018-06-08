all: all.nt all.rdf all.jsonld all.json

.PHONY: all.nt all.rdf all.jsonld all.json

all.nt:  adres.nt begroeidvoorkomen.nt besluit.nt dienst.nt gebouw.nt generiek.nt mandaat.nt melding.nt notificatie.nt openbaardomein.nt organisatie.nt persoon.nt subsidie.nt toestemming.nt transactie.nt vegetatie.nt weg.nt
all.rdf: adres.rdf begroeidvoorkomen.rdf besluit.rdf dienst.rdf gebouw.rdf generiek.rdf mandaat.rdf melding.rdf notificatie.rdf openbaardomein.rdf organisatie.rdf persoon.rdf subsidie.rdf toestemming.rdf transactie.rdf vegetatie.rdf weg.rdf
all.jsonld: adres.jsonld begroeidvoorkomen.jsonld besluit.jsonld dienst.jsonld gebouw.jsonld generiek.jsonld mandaat.jsonld melding.jsonld notificatie.jsonld openbaardomein.jsonld organisatie.jsonld persoon.jsonld subsidie.jsonld toestemming.jsonld transactie.jsonld vegetatie.jsonld weg.jsonld
all.json: adres.json begroeidvoorkomen.json besluit.json dienst.json gebouw.json generiek.json mandaat.json melding.json notificatie.json openbaardomein.json organisatie.json persoon.json subsidie.json toestemming.json transactie.json vegetatie.json weg.json


%.nt: %.ttl
	rapper -i turtle -o ntriples $< > $@

%.rdf: %.ttl
	rapper -i turtle -o rdfxml-abbrev $< > $@

%.jsonld: %.ttl
	rdf-serialize.sh $< --input-format turtle --output-format rj > $@

%.json: %.ttl
	rdf-serialize.sh $< --input-format turtle --output-format rj > $@



clean:
	rm -rf *.nt
	rm -rf *.rdf

