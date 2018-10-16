# Afspraken in de repository Data.Vlaanderen.be

## Naamgeving

In wat volgt staat `Woord1` voor een eerste woord, beginnend met hoofdletter en `Woordx` voor elk optioneel volgend woord, ook beginnend met hoofdletter.
De varianten `woord1` en `woordx` stellen de overeenkomstige woorden voor, beginnend met kleine letter. 


### Vocabularia

item | attribuut in eap-mapping.json | algemeen | voorbeeld | opmerking
---- | ----------------------------- | -------- | --------- | ---------
symbolische naam | | `Woord1Woordx` | **OpenbaarDomein** | Bevat niet het woord 'Vocabularium'
slugname | "name", optioneel: "prefix" | `woord1-woordx` | **openbaar-domein** | De slugname komt voor in de uiteindeljke url van de specifiatie en in de uri's van alle begrippen gedefinieerd in dit vocabularium
eap bestandsnaam, geval A |  "eap" | `OSLO-Woord1-Woordx-VOC.eap` | **OSLO-Openbaar-Domein-VOC.eap** | Algemeen geval; begint met 'OSLO-', eindigt met '-VOC.eap'
eap bestandsnaam, geval B | "eap" | `OSLO-Woord1-Woordx.eap` | **OSLO-Openbaar-Domein.eap** | Bijzonder geval; '-VOC' ontbreekt; komt voor indien het vocabularium vervat zit in één eap bestand, samen met de er bij horende applicatieprofielen
eap bestandsnaam, geval C | "eap" | `OSLO-Vocabularium.eap` | **OSLO-Vocabularium.eap** | Bijzonder geval; specifieke naam; geldt voor alle geïntegreerde vocabularia samen in één eap bestand
diagramnaam | "diagram" | `OSLO-Woord1-Woordx` | **OSLO-Persoon** | Begint met 'OSLO-'
kolomnaam medewerkers | "contributors" | `Woord1Woordx` | **OpenbaarDomein** | Eventueel afwijkende afwijkende waarden voor Woord1 Woordx om te verwijzen naar de personen die meewerkten aan een bijhorend vocabularium en/of reeks appicatieprofielen
template bestandsnaam | "template" | `woord1-woordx-voc.j2` | **persoon-voc.j2** | Eindigt met '-voc.j2'  


### Applicatieprofielen

item | attribuut in eap-mapping.json | algemeen | voorbeeld | opmerking
---- | ----------------------------- | -------- | --------- | ---------
symbolische naam | | `Woord1Woordx` | **PersoonBasis** | Bevat niet het woord 'Applicatieprofiel' (ook niet afgekort tot 'AP'); voor een basisprofiel: één Woordx, gelijk aan 'Basis'
slugname | "name" | `woord1-woordx` | **persoon-basis** | De slugname komt voor in de uiteindeljke url van de specifiatie
eap bestandsnaam, geval A | "eap" | `OSLO-Woord1-Woordx-AP.eap` | **OSLO-Persoon-Basis-AP.eap** | Algemeen: begint met 'OSLO-', eindigt met '-AP.eap' 
eap bestandsnaam, geval B | "eap" | `OSLO-Woord1-Woordx.eap` | **OSLO-Openbaar-Domein.eap** | Bijzonder geval; '-AP' ontbreekt; komt voor indien het applicatieprofiel vervat zit in één eap bestand, samen met het vocabularium waarop het gebaseerd is en/of samen met verwante applicatieprofielen (afwijkende waarden voor Woord1 Woordx)
diagramnaam | "diagram" | `OSLO²_applicatieprofiel_Woord1_Woordx` | **OSLO_applicatieprofiel_Persoon_Basis** | Vrijblijvend voorstel; begint met 'OSLO²_applicatieprofiel_' 
kolomnaam medewerkers | "contributors" | `Woord1Woordx` | **OpenbaarDomein** | Eventueel afwijkende afwijkende waarden voor Woord1 Woordx om te verwijzen naar de personen die meewerkten aan een bijhorend vocabularium en/of reeks appicatieprofielen 
template bestandsnaam | "template" | `woord1-woordx-ap.j2` | **persoon-basis-ap.j2** | eindigt met '-ap.j2'   
titel | "title" | `Woord1 Woordx` | **Persoon Basis** |
