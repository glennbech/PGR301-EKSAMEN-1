# PGR301-EKSAMEN
Eksamen DevOps PGR301 - 2023

## Oppgave 1


## Oppgave 2


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
