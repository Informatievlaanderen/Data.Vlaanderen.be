all: all.nt all.rdf

all.nt:  adres.nt dienst.nt generiek.nt organisatie.nt persoon.nt
all.rdf: adres.rdf dienst.rdf generiek.rdf organisatie.rdf persoon.rdf


%.nt: %.ttl
	rapper -i turtle -o ntriples $< > $@

%.rdf: %.ttl
	rapper -i turtle -o rdfxml-abbrev $< > $@


clean:
	rm -rf *.nt
	rm -rf *.rdf

