# PGR301-EKSAMEN
Eksamen DevOps PGR301 - 2023

** OBS! For at workflows skal kjøre korrekt i sensor sin fork må det i Settings -> Secrets & Variables -> actions opprettes 2 variabler: AWS_ACCESS_KEY_ID & AWS_ACCESS_KEY_ID. Disse verdiene kan 
genereres i AWS IAM (selv om du allerede vet det)

## Oppgave 1


## Oppgave 2


```
docker build -t ppe . 
docker run -p 8080:8080 -e AWS_ACCESS_KEY_ID=XXX -e AWS_SECRET_ACCESS_KEY=YYY -e BUCKET_NAME=kjellsimagebucket ppe
```

for å bygge og kjøre applikasjonen med docker kan kommandoene over kjøres i rot terminalen. Kombinert med

```
http://localhost:8080/scan-ppe?bucketName=kjellsimagebucket
```
vil responsen demonstrert i oppgaveteksten vises.




## Oppgave 3


## Oppgave 4


## Drøfte Oppgaver:

### A
Kontinuerlig Intergrasjon er en praksis som er hyppig brukt innenfor DevOps området. Kontinuerlig Integrasjon har, med andre prakiser som
Kontinuerlig Leveranse, et mål om å optimalisere utrulling av kodeendringer til en applikasjon. Konseptet går ut på å pushe kodeendringer jevnlig til kodebasen. Når man pusher ny kode eller kodeendringer til en applikasjon sitt repository, kan til tider føre til problemer. Den nye koden kan knekke noe i applikasjonen, og videre føre til problemer. Dette fenomenet er ikke uvanlig, og ved å pushe koden jevnlig vil man få innblikk
i feilene raskt og effektivt.
Grunnet dette ble kontinuerlig integrasjon som et konsept innført. Dets hensikt er å integrere den nye koden inn i kodebasen. 
Vanlig praksis for dette er å pushe kodeendringer, ikke til main branch, men en annen sub-branch. deretter lager man en pull-request. før denne
går igjennom, vil applikasjonen bli bygget og testet i en Workflow (eks Github Actions). Dersom alle testene passerer. Kan koden merges.

En fordel med Kontinuerlig Integrasjon er, som nevnt tidligere, at det reduserer risikoen for at applikasjonen får problemer, grunnet store eller små feil, dersom testene er godt skrevet. En annen fordel er at om man skal manuelt teste applikasjonen, spesielt store applikasjoner, kan det være svært tidkrevende. Gode automatiserte tester er mer tid-effektivt. 

Et annet problem utviklere hadde før dette konseptet kom, var at kode kun ble pushet når en spesiell jobb ble fullført. Dette førte til at bugs hopet seg opp i større mengder og var mer komplisert å løse. Om det lå et mønster ved flere bugs, kunne muligens flere av de vært unngått om man ble gjort oppmerksom på dette tidligere. 

Kontinuerlig Integrasjon i praksis vil man ofte sette opp Branch Protection Rules for sin main branch. Disse reglene vil ofte innebære at man må 
lage en pull-request for å merge ny kode fra en isolert sub-branch. Etter pull-requesten har blitt laget, må alle workflow jobbene kjøre uten problemer. Det er også vanlig at en eller flere andre utviklere må godkjenne pull-requesten (flere hoder er bedre enn ett).


### B

#### Scrum
Scrum er Programvareutvikling metodikk som fremmer kommunikasjon mellom utviklere og produkteier. Scrum er hensiktsmessig dersom krav og kriterier for et produkt ikke er godt definert. Utviklingsteamet jobber i Sprints. En sprint vil i Scrum gå i rekkefølgen:  planlegge sprint -> jobbe med utvikling -> evaluering av sprint. Dette oppsettet gjør at teamet kommuniserer jevnlig og
konstant kan drøfte og evaluere om fremgangsmåten fungerer eller ikke, og gjøre justeringer deretter. I scrum har man en backlog som definerer kriterier for applikasjonen og gir dem poeng etter vanskelighetsgrad. Denne backloggen er åpen for endring, dersom en oppgave er for kompleks, kan man justere og dele den opp i flere mindre oppgaver, og om en oppgave viser seg å være mer kompleks
enn forutsett, kan poengene justeres opp.
Fordeler med bruk av scrum i en utviklingsprosess er at den er veldig mottakelig mot endringer. I en utviklingsprosess kan priotiteter og ønsker endre seg fort, og da gir Scrum et godt utgangspunkt for dette.
Når man jobber med større prosjekter kan det være vanskelig å vite hvor man skal starte og hvilke oppgaver man skal prioritere over andre. Planleggingen i scrum hjelper med å løse dette. I Backloggen så rangerer man de forskjellige oppgavene etter prioritet.
Siden scrum fremmer kommunikasjon innad i team, og oppfordrer kreativ innputt, kan større team 

#### DevOps

DevOps er en metodikk som fremmer kommunikasjon mellom Developers og Operations, konseptet innfører "Skin in the game". Før DevOps jobbet utviklere og operations isolert. Disse to rollene er ikke
alltid på samme side. Utviklerene ønsker å skrive og pushe kode så fort som mulig, mens operations kan møte på problemer dersom sikkerhetstiltak ikke er tatt før man lanserer endringene. Om applikasjonen feiler, havner det i hendene til operations, utviklerene hadde derfor ikke noe insentiv til å skrive bedre kode. Men med DevOps jobber disse to rollene sammen med delt ansvar og konsekvenser. Skin in the game oppfordrer utviklerene å skrive bedre kode, for de deler konsekvensene hvis det oppstår feil.

