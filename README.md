# Data.Vlaanderen.be

Deze repository is een onderdeel van het initiatief **Open Standaarden voor Linkende Organisaties __(OSLO)__**.
Meer informatie is terug te vinden op de [OSLO productpagina](https://overheid.vlaanderen.be/producten-diensten/OSLO2).

Deze repository bevat alle bronbestanden die compileerd worden tot de specificaties die terug te vinden zijn op https://data.vlaanderen.be/

Issues in deze repository dienen betrekking te hebben op technische of editoriale problemen met de website data.vlaanderen.be. Voor inhoudelijke discussies met betrekking tot de data standaarden verwijzen we naar de [OSLO-Discussion repository](https://github.com/Informatievlaanderen/OSLO-Discussion).

Voor afspraken geldend in deze repository, betreffende bestandsnamen en dergelijke, zie deze [bijhorende afspraken](./CONVENTIONS.md).

## Informatie voor beheerders

Deze repository bevat de bronbestanden voor https://data.vlaanderen.be. De effectieve site zit in de https://github.com/Informatievlaanderen/OSLO-Generated repository.
Het omzetten van de bronbestanden naar de website gebeurt met een Circle CI pipeline. De configuratie van deze pipeline is terug te vinden in `.circleci/config.yml`.

De volgende componenten zijn van belang in de pipeline:

* **site-skeleton**
  Deze map bevat alle statische assets, zoals figuren of overzichtspagina's van data.vlaanderen.be. De inhoud van deze map wordt zonder aanpassing gekopieerd naar de finale website
* **src**
  Deze map bevat alle *eap* (enterprise architect project) bestanden en het bestand *stakeholders.csv*. Deze bestanden zijn de "bron der waarheid" voor alle vocabularia en applicatieprofielen. Het volstaat een *eap* file te vervangen om een applicatieprofiel of vocabularium bij te werken. Om een nieuw applicatieprofiel of vocabularium toe te voegen moet de correcte *eap* file in deze map geplaatst worden en de nodige configuratie toegevoegd worden in *config/eap-mapping.json*. Bovendien moeten allicht een nieuwe kolom toegevoegd worden aan *stakeholders.csv*. Zie lager voor meer info over hoe dit te doen.
* **templates**
  Deze map bevat de jinja / nunjucks templates voor ieder vocabularium en applicatieprofiel. Dit is de plaats waar de HTML beschrijvingen toegevoegd worden.
* **config**
  Deze map bevat verscheidene configuratie bestanden voor de toolchain:
  * *config-ap.json*: Bevat de applicatieprofiel specifieke configuratie voor EA-2-RDF (gebruikt in de pipeline)
  * *config-voc.json*: Bevat de vocabularium specifieke configuratie voor EA-2-RDF
  * *shacl-validator-config.json*: Bevat de configuratie van https://data.vlaanderen.be/shacl-validator. De validator laadt deze in vanop de github URL. Indien nieuwe shacl files beschikbaar gemaakt moeten worden aan de validator, moet dit bestand aangepast worden.
  * *eap-mapping.json*: Bevat de configuratie van de pipeline zelf.

## `stakeholders.csv` encoding
Dit bestand moet UTF-8 encoded zijn.
* Als je dit bestand in Windows bewerkt met een tekst editor, moet je dus zeker zijn dat deze UTF-8 encoding kan interpreteren en behoudt bij het updaten (gewone Notepad is niet geschikt).
* Als je dit bestand in Windows bewerkt met Excel, hou er dan rekening mee dat Excel standaard met ANSI encoded bestanden werkt. Dus: vooraleer te openen met Excel eerst converteren van UTF-8 naar ANSI en na bewaren in Excel achteraf terug converteren van ANSI naar UTF-8. Kijk meteen het scheidingsteken nog eens na (moet `,` zijn).
* Tip: [Notepad++](https://notepad-plus-plus.org/) is een tekst editor die voldoet aan de voorwaarden om dit bestand rechtstreeks te bewerken. Er zijn ook menu opties om de encoding te verifiëren en te converteren.

## `eap-mapping.json` structuur
De `eap-mapping.json` configuratie is een array met objecten van de volgende vorm.
 
Voor vocabularia:
```json
{
  "name": "begraafplaats",
  "type": "voc",
  "prefix": "openbaar-domein",
  "eap": "OSLO-Openbaar-Domein.eap",
  "diagram": "OSLO-Openbaar-Domein-Taxonomie-Begraafplaatsen",
  "contributors": "OpenbaarDomein",
  "template": "openbaardomein-uitbreiding-voc.j2"
}
```

Voor applicatieprofielen:
```json
{
  "name": "wegenregister",
  "type": "ap",
  "eap": "OSLO-Weg.eap",
  "diagram": "Wegenregister_applicatieprofiel",
  "contributors": "Weg",
  "template": "wegenregister-ap.j2",
  "title": "Wegenregister"
}
```

 
De attributen hebben de volgende betekenis:
* *name*: Is de naam van het vocabularium / applicatieprofiel zoals hij in de uiteindelijke url komt; wordt ook 'slugname' genoemd.
* *type*: Geeft aan of het item een vocabularium (`voc`) of applicatieprofiel (`ap`) is.
* *eap*: Is de naam van de eap file waar het te converteren diagramma zich bevindt. Dit is hoofdlettergevoelig en het bestand moet aanwezig zijn in `/src`.
* *diagram*: Is de naam van het diagramma in de eap file dat geconverteerd moet worden. Dit is hoofdlettergevoelig.
* *contributors*: Is de naam van de kolom in `stakeholders.csv` die gebruikt wordt om contributors toe te voegen.
* *template*: Is de bestandsnaam van de template die gebruikt wordt om de HTML te genereren. Dit bestand moet aanwezig zijn in `/templates`
* *title*: Dit is de titel die getoond wordt in de HTML van een applicatieprofiel. Dit attribuut is niet van toepassing voor vocabularia en wordt genegeerd indien er toch een waarde is. Bepaalt, na conversie naar kleine letters en vervanging van spaties door '-', het pad waar `overview.jpg` gezocht wordt.
* *prefix*: Een optionele prefix voor de url van een vocabularium, afgestemd met de baseURI van het package, gedefinieerd in de eap file. *Zou* ook kunnen gebruikt worden voor een AP, maar dan zou de resulterende jsonld context file niet beschikbaar zijn onder /context.
