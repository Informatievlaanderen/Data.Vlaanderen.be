# Afspraken in de repository Data.Vlaanderen.be

## Naamgeving voor vocabularia en applicatieprofielen

In wat volgt staat `Woord1` voor een eerste woord, beginnend met hoofdletter en `Woordx` voor elk optioneel volgend woord, ook beginnend met hoofdletter.
De varianten `woord1` en `woordx` stellen de overeenkomstige woorden voor, beginnend met kleine letter. 

### Vocabularia

* symbolische naam
  * attribuut in eap-mapping.json: -
  * formaat: `Woord1Woordx`
  * voorbeeld: **OpenbaarDomein**
  * opmerking: Bevat niet het woord 'Vocabularium'.

* slugname
  * attribuut in eap-mapping.json: "name", optioneel: "prefix"
  * formaat: `woord1-woordx`
  * voorbeeld: **openbaar-domein**
  * opmerking: De slugname komt voor in de uiteindeljke url van de specifiatie en in de uri's van alle begrippen gedefinieerd in dit vocabularium.

* eap bestandsnaam, normaal geval
  * attribuut in eap-mapping.json: "eap"
  * formaat: `OSLO-Woord1-Woordx-VOC.eap`
  * voorbeeld: **OSLO-Openbaar-Domein-VOC.eap**

* eap bestandsnaam, bijzonder geval; komt voor indien het vocabularium vervat zit in één eap bestand, samen met de er bij horende applicatieprofielen
  * attribuut in eap-mapping.json: "eap"
  * formaat: `OSLO-Woord1-Woordx.eap` (-VOC ontbreekt)
  * voorbeeld: **OSLO-Openbaar-Domein.eap**
  * opmerking: Afwijkende waarden voor Woord1 Woordx, aangezien deze naar een (groep van) applicatieprofiel(en) verwijst.

* eap bestandsnaam, bijzonder geval; geldt voor alle geïntegreerde vocabularia samen in één eap bestand
  * attribuut in eap-mapping.json: "eap"
  * formaat: `OSLO-Vocabularium.eap` (vaste naam)
  * voorbeeld: **OSLO-Vocabularium.eap**

* diagramnaam
  * attribuut in eap-mapping.json: "diagram"
  * formaat: `OSLO-Woord1-Woordx`
  * voorbeeld: **OSLO-Persoon**

* kolomnaam medewerkers
  * attribuut in eap-mapping.json: "contributors"
  * formaat: `Woord1Woordx`
  * voorbeeld: **OpenbaarDomein**
  * opmerking: Eventueel afwijkende afwijkende waarden voor Woord1 Woordx om te verwijzen naar de personen die meewerkten aan een bijhorend vocabularium en/of reeks appicatieprofielen.

* template bestandsnaam
  * attribuut in eap-mapping.json: "template"
  * formaat: `woord1-woordx-voc.j2`
  * voorbeeld: **persoon-voc.j2**

### Applicatieprofielen

* symbolische naam
  * attribuut in eap-mapping.json: - 
  * formaat: `Woord1Woordx`
  * voorbeeld: **PersoonBasis**
  * opmerking: Bevat niet het woord 'Applicatieprofiel' (ook niet afgekort tot 'AP'); voor een basisprofiel: één Woordx, gelijk aan 'Basis'.

* slugname
  * attribuut in eap-mapping.json: "name"
  * formaat: `woord1-woordx`
  * voorbeeld: **persoon-basis**
  * opmerking: De slugname komt voor in de uiteindeljke url van de specifiatie.

* eap bestandsnaam, normaal geval
  * attribuut in eap-mapping.json: "eap"
  * formaat: `OSLO-Woord1-Woordx-AP.eap`
  * voorbeeld: **OSLO-Persoon-Basis-AP.eap**

* eap bestandsnaam, bijzonder geval; komt voor indien het applicatieprofiel vervat zit in één eap bestand, samen met het vocabularium waarop het gebaseerd is en/of samen met verwante applicatieprofielen
  * attribuut in eap-mapping.json: "eap"
  * formaat: `OSLO-Woord1-Woordx.eap` (-AP ontbreekt)
  * voorbeeld: **OSLO-Openbaar-Domein.eap**
  * opmerking: Afwijkende waarden voor Woord1 Woordx, aangezien deze naar een vocabularium of een groep applicatieprofielen verwijst.

* diagramnaam
  * attribuut in eap-mapping.json: "diagram"
  * formaat: `OSLO²_applicatieprofiel_Woord1_Woordx`
  * voorbeeld: **OSLO²_applicatieprofiel_Persoon_Basis**
  * opmerking: Onnodig met terugwerkende kracht toe te passen op bestaande applicatieprofielen.
 
* kolomnaam medewerkers
  * attribuut in eap-mapping.json: "contributors"
  * formaat: `Woord1Woordx`
  * voorbeeld: **OpenbaarDomein**
  * opmerking: Eventueel afwijkende afwijkende waarden voor Woord1 Woordx om te verwijzen naar de personen die meewerkten aan een bijhorend vocabularium en/of reeks appicatieprofielen.
 
* template bestandsnaam
  * attribuut in eap-mapping.json: "template"
  * formaat: `woord1-woordx-ap.j2`
  * voorbeeld: **persoon-basis-ap.j2**

* titel
  * attribuut in eap-mapping.json: "title"
  * formaat: `Woord1 Woordx`
  * voorbeeld: **Persoon Basis**
