# Data.Vlaanderen.be

Deze repository is een onderdeel van het initiatief **Open Standaarden voor Linkende Organisaties __(OSLO)__**.
Meer informatie is terug te vinden op de [OSLO productpagina](https://overheid.vlaanderen.be/producten-diensten/OSLO2).

Deze repository bevat alle bronbestanden die compileerd worden tot de specificaties die terug te vinden zijn op https://data.vlaanderen.be/

Issues in deze repository dienen betrekking te hebben op technische of editoriale problemen met de website data.vlaanderen.be. Voor inhoudelijke discussies met betrekking tot de data standaarden verwijzen we naar de [OSLO-Discussion repository](https://github.com/Informatievlaanderen/OSLO-Discussion).

## Informatie voor beheerders

Deze repository bevat de bronbestanden voor https://data.vlaanderen.be. De effectieve site zit in de https://github.com/Informatievlaanderen/OSLO-Generated repository.
Het omzetten van de bronbestanden naar de website gebeurt met een Circle CI pipeline. De configuratie van deze pipeline is terug te vinden in `.circleci/config.yml`.

De volgende componenten zijn van belang in de pipeline:

* **site-skeleton**
  Deze map bevat alle statische assets, zoals figuren of overzichtspagina's van data.vlaanderen.be. De inhoud van deze map wordt zonder aanpassing gekopieerd naar de finale website
* **src**
  Deze map bevat alle eap (enterprise architect project) bestanden. Deze bestanden zijn de "bron der waarheid" voor alle vocabularia en applacieprofielen. Het volstaat een eap file te vervangen om een applicatieprofiel of vocabularium bij te werken. Om nieuwe vocabularia toe te voegen moet de correcte eap file in deze map geplaats worden en de nodige configuratie toegevoegd worden in `config/eap-mapping.json`.
* **templates**
  Deze map bevat de jinja / nunjucks templates voor ieder vocabularium en applicatieprofiel. Dit is de plaats waar de HTML beschrijvingen toegevoegd worden.
* **config**
  Deze map bevat verscheidene configuratie bestanden voor de toolchain:
  * *config-ap.json*: Bevat de applicatieprofiel specifieke configuratie voor ea-2-rdf (gebruikt in de pipeline)
  * *config-voc.json*: Bevat de vocabularium specifieke configuratie voor ea-2-rdf
  * *shacl-validator-config.json*: Bevat de configuratie van https://data.vlaanderen.be/shacl-validator. De validator laadt deze in vanop de github URL. Indien nieuwe shacl files beschikbaar gemaakt moeten worden aan de validator, moet dit bestand aangepast worden.
  * *eap-mapping.json*: Bevat de configuratie van de pipeline zelf.

## `eap-mapping.json` structuur
De `eap-mapping.json` configuratie is een array met objecten van de volgende vorm:
```json
{
  "name": "wegenregister",
  "type": "ap",
  "eap": "OSLO-Weg.eap",
  "diagram": "Wegenregister_applicatieprofiel",
  "contributors": "Weg",
  "template": "wegenregister-api.j2",
  "title": "Wegenregister"
}
```
De attributen hebben de volgende betekenis:
* *name*: Is de naam van het vocabularium / applicatieprofiel zoals hij in uiteindelijke url komt. Voor applicatieprofielen bepaalt dit ook waar overview.jpg gezocht wordt.
* *type*: Geeft aan of het item een vocabularium (`voc`) of applicatieprofiel (`ap`) is.
* *eap*: Is de naam van de eap file waar het te converteren diagramma zich bevindt. Dit is hoofdlettergevoelig en het bestand moet aanwezig zijn in `/src`.
* *diagram*: Is de naam van het diagramma in de eap file dat geconverteerd moet worden. Dit is hoofdlettergevoelig.
* *contributors*: Is de naam van de kolom in `stakeholders_latest.csv` die gebruikt wordt om contributors toe te voegen.
* *template*: Is de bestandsnaam van de template die gebruikt wordt om de HTML te genereren. Dit bestand moet aanwezig zijn in `/templates`
* *title*: Dit is de titel die getoond wordt in de HTML van een applicatieprofiel. Dit attribuut is niet van toepassing voor vocabularia en wordt genegeerd indien er toch een waarde is.
* *prefix*: Een optioneel prefix voor de url van een vocabularium. Kan ook gebruikt worden in een AP, maar dan zal de resulterende jsonld context file niet beschikbaar zijn onder /context.
