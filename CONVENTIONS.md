# Afspraken in de repository Data.Vlaanderen.be

## Naamgeving voor vocabularia en applicatieprofielen

In wat volgt staat `Woord1` voor een eerste woord, beginnend met hoofdletter en `Woordx` voor elk optioneel volgend woord, ook beginnend met hoofdletter.
De varianten `woord1` en `woordx` stellen de overeenkomstige woorden voor, beginnend met kleine letter. 

### Vocabularia

Voor een vocabularium met symbolische naam `Woord1 Woordx`:

* algemeen
  * In de symbolische naam is het woord 'Vocabularium' niet inbegrepen.

* slugname
  * attribuut in eap-mapping.json: "name" en indien nodig ook "prefix"
  * formaat: `woord1-woordx`
  * voorbeelden: **persoon**, **openbaar-domein**
  * opmerking: De slugname komt voor in de uiteindeljke url van de specificatie en in de uri's van alle begrippen gedefinieerd in dit vocabularium. Daartoe moet de slugname afgestemd zijn met de baseURI die vastgelegd is in de package tags. 

* eap bestandsnaam, normaal geval
  * attribuut in eap-mapping.json: "eap"
  * formaat: `OSLO-Woord1-Woordx-VOC.eap`
  * voorbeeld: **OSLO-Persoon-VOC.eap**

* eap bestandsnaam, bijzonder geval; komt voor indien het vocabularium vervat zit in één eap bestand, samen met de bijhorende applicatieprofielen
  * attribuut in eap-mapping.json: "eap"
  * formaat: `OSLO-Woord1-Woordx.eap` ('-VOC' ontbreekt)
  * voorbeeld: **OSLO-Openbaar-Domein.eap**

* eap bestandsnaam, **TIJDELIJK** bijzonder geval voor geïntegreerde vocabularia uit de centrale EA repo, die nog niet in een afzonderlijk eap bestand (zie normaal geval hoger) beschikbaar staan
  * attribuut in eap-mapping.json: "eap"
  * formaat: `OSLO-Vocabularium.eap` (vaste naam)
  * voorbeeld: **OSLO-Vocabularium.eap**

* diagramnaam
  * attribuut in eap-mapping.json: "diagram"
  * formaat: `OSLO-Woord1-Woordx`
  * voorbeelden: **OSLO-Persoon**, **OSLO-Openbaar-Domein**

* kolomnaam medewerkers
  * attribuut in eap-mapping.json: "contributors"
  * formaat: `Woord1Woordx`
  * voorbeeld: **OpenbaarDomein**

* template bestandsnaam
  * attribuut in eap-mapping.json: "template"
  * formaat: `woord1-woordx-voc.j2`
  * voorbeelden: **persoon-voc.j2**, **openbaar-domein-voc.j2**

* titel
  * attribuut in eap-mapping.json: -
  * formaat: `Woord1 Woordx`
  * voorbeelden: **Persoon**, **Openbaar Domein**
  * opmerking: Voor een vocabularium wordt de titel vastgelegd in de package tags; er is geen attribuut in eap-mapping.json. 

### Applicatieprofielen

Voor een applicatieprofiel met symbolische naam `Woord1 Woordx`:

* algemeen
  * In de symbolische naam is het woord 'Applicatieprofiel' niet inbegrepen, ook niet afgekort tot 'AP'.
  * Voor een basisprofiel is de symbolische naam de symbolische naam van het vocabularium gevolgd door ' Basis'.

* slugname
  * attribuut in eap-mapping.json: "name"
  * formaat: `woord1-woordx`
  * voorbeelden: **persoon-basis**, **objectcatalogus-begraafplaats**
  * opmerking: De slugname komt voor in de uiteindeljke url van de specifiatie.

* eap bestandsnaam, normaal geval
  * attribuut in eap-mapping.json: "eap"
  * formaat: `OSLO-Woord1-Woordx-AP.eap`
  * voorbeeld: **OSLO-Persoon-Basis-AP.eap**

* eap bestandsnaam, bijzonder geval; komt voor indien het applicatieprofiel vervat zit in één eap bestand, samen met het vocabularium waarop het gebaseerd is en/of samen met verwante applicatieprofielen
  * attribuut in eap-mapping.json: "eap"
  * formaat: `OSLO-Woord1-Woordx.eap` ('-AP' ontbreekt)
  * voorbeeld: **OSLO-Openbaar-Domein.eap**
  * opmerking: Woord1 Woordx in de bestandsnaam kan hier afwijken t.o.v. de symbolische naam van dit applicatieprofiel.

* diagramnaam
  * attribuut in eap-mapping.json: "diagram"
  * formaat: `OSLO-Woord1-Woordx`
  * voorbeelden: **OSLO-Persoon-Basis**, **OSLO-Objectcatalogus-Begraafplaats**
 
* kolomnaam medewerkers
  * attribuut in eap-mapping.json: "contributors"
  * formaat: `Woord1Woordx`
  * voorbeelden: **Persoon**, **OpenbaarDomein**
  * opmerking: Woord1 Woordx in de kolomnaam kan hier afwijken t.o.v. de symbolische naam van dit applicatieprofiel, aangezien deze hier kunnen verwijzen naar het bijhorende vocabularium of naar een groep applicatieprofielen.
 
* template bestandsnaam
  * attribuut in eap-mapping.json: "template"
  * formaat: `woord1-woordx-ap.j2`
  * voorbeeld: **persoon-basis-ap.j2**

* titel
  * attribuut in eap-mapping.json: "title"
  * formaat: `Woord1 Woordx`
  * voorbeelden: **Persoon Basis**, **Objectcatalogus Begraafplaats**

