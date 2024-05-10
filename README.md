# Data.Vlaanderen.be

Deze repository is een onderdeel van het initiatief **Open Standaarden voor Linkende Organisaties __(OSLO)__**.
Meer informatie is terug te vinden op de [OSLO productpagina](https://overheid.vlaanderen.be/producten-diensten/OSLO2).

Deze repository bevat alle bronbestanden die compileerd worden tot de specificaties die terug te vinden zijn op https://data.vlaanderen.be/

Issues in deze repository dienen betrekking te hebben op technische of editoriale problemen met de website data.vlaanderen.be. Voor inhoudelijke discussies met betrekking tot de data standaarden verwijzen we naar de [OSLO-Discussion repository](https://github.com/Informatievlaanderen/OSLO-Discussion).

## Informatie voor beheerders

Deze repository bevat de bronbestanden voor https://data.vlaanderen.be. De effectieve site zit in de https://github.com/Informatievlaanderen/OSLO-Generated repository.
Het omzetten van de bronbestanden naar de website gebeurt met een Circle CI pipeline. De configuratie van deze pipeline is terug te vinden in `.circleci/config.yml`.


## `stakeholders.csv` encoding
Dit bestand moet UTF-8 encoded zijn.
* Als je dit bestand in Windows bewerkt met een tekst editor, moet je dus zeker zijn dat deze UTF-8 encoding kan interpreteren en behoudt bij het updaten (gewone Notepad is niet geschikt).
* Als je dit bestand in Windows bewerkt met Excel, hou er dan rekening mee dat Excel standaard met ANSI encoded bestanden werkt. Dus: vooraleer te openen met Excel eerst converteren van UTF-8 naar ANSI en na bewaren in Excel achteraf terug converteren van ANSI naar UTF-8. Kijk meteen het scheidingsteken nog eens na (moet `,` zijn).
* Tip: [Notepad++](https://notepad-plus-plus.org/) is een tekst editor die voldoet aan de voorwaarden om dit bestand rechtstreeks te bewerken. Er zijn ook menu opties om de encoding te verifiëren en te converteren.

