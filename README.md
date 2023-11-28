# PGR301-EKSAMEN
Eksamen DevOps PGR301 - 2023. Kandidat 2039

[![Build and Deploy SAM](https://github.com/Mariusflores/PGR301-EKSAMEN/actions/workflows/sam_deploy.yml/badge.svg)](https://github.com/Mariusflores/PGR301-EKSAMEN/actions/workflows/sam_deploy.yml)
[![Build and Push Docker to ECR](https://github.com/Mariusflores/PGR301-EKSAMEN/actions/workflows/docker.yml/badge.svg)](https://github.com/Mariusflores/PGR301-EKSAMEN/actions/workflows/docker.yml)

# Besvarelse


**!OBS! For at workflows skal kjøre korrekt i sensor sin fork må det opprettes 2 variabler: AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY. Dette gjøres ved**

1. Gå til IAM i AWS
2. Finn Bruker
3. Create Access key
4. Velg Command Line Interface
5. Kopier verdiene
6. I Github i Settings -> Secrets & Variables -> actions
7. New Repository secret
8. Secret: ```AWS_ACCESS_KEY_ID``` og tilsvarende verdi
9. Secret: ```AWS_SECRET_ACCESS_KEY``` med tilsvarende verdi


## Oppgave 1.

A.

- [x] Fjerne hardkoding av S3 Bucket
      
```
# Oppgave 1A
BUCKET_NAME = os.environ.get('BUCKET_NAME') 
```
Koden over henter S3 bucket navnet fra miljøvariabel

```
Properties:
  BucketName:
```
 Fjernet koden over fra template.yaml da den ikke er nødvendig siden BucketName blir spesifisert via deploy kommandoen i workflow filen

B.

- [x] Workflow bygger SAM applikasjonen ved push til branches som ikke er main
- [x] Workflow bygger og deployer Sam applikasjonen til S3 Bucket feilfritt ved push til main branch
      
```
name: Build and Deploy SAM

on:
  push:
    branches:
      - main
      - '*'

defaults:
  run:
    working-directory: "kjell"

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v2

      - name: Setup Python
        uses: actions/setup-python@v2

      - name: Setup SAM
        uses: aws-actions/setup-sam@v1

      - name: Setup AWS CLI
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Build SAM Application
        run: sam build --use-container
        
      - name: Deploy SAM Application
        if: github.ref == 'refs/heads/main'
        run: sam deploy --no-confirm-changeset --no-fail-on-empty-changeset --stack-name sam-candidate-2039 --s3-bucket candidate-2039 --capabilities CAPABILITY_IAM --region eu-west-1
```

## Oppgave 2.
A. Dockerfile
- [x] Multi-stage Dockerfile som bygger prosjektet
```
FROM maven:3.8.4-openjdk-11 as builder

WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn package

FROM adoptopenjdk/openjdk11:alpine-slim
COPY --from=builder /app/target/*.jar /app/application.jar
ENTRYPOINT ["java","-jar","/app/application.jar"] 
```
I første steg av Dockerfilen kopieres pom.xml filen og src mappen og kjøren mvn package for å bygge applikasjonen en /app mappe
videre kopieres application.jar filen som inneholder applikasjonen og Entrypoint til Docker image settes til å kjøre kommandoen java -jar <filepath>

```
docker build -t ppe . 
docker run -p 8080:8080 -e AWS_ACCESS_KEY_ID=XXX -e AWS_SECRET_ACCESS_KEY=YYY -e BUCKET_NAME=kjellsimagebucket ppe
```

for å bygge og kjøre applikasjonen med docker kan kommandoene over kjøres i rot terminalen. Kombinert med

```
http://localhost:8080/scan-ppe?bucketName=kjellsimagebucket
```
vil responsen demonstrert i oppgaveteksten vises.

B. Workflow
- [x] Ved push til main bygges container image og publiseres til ECR repository
- [x] Ved push til branch som ikke er main bygges container image, men publiseres ikke til AWS ECR
- [x] Container image har tag som er lik commit hash i Git
- [x] Siste pushet container image i ECR har :latest tag.
<img width="252" alt="image" src="https://github.com/Mariusflores/PGR301-EKSAMEN/assets/89774644/79ede513-b018-45af-805f-7567c6f21837">

``` 
name: Build and Push Docker to ECR
on:
  push:
    branches:
      - main
      - '*'
jobs:
  build:
    name: Build Docker Image
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v4
        
      - name: Build Docker Image
        run: |
           docker build . -t 2039-ppe
           docker save -o /tmp/2039-ppe.tar 2039-ppe

      - name: Upload Docker Image as Artifact
        if: github.ref == 'refs/heads/main'
        # upload built Docker Image
        uses: actions/upload-artifact@v2
        with:
          name: 2039-ppe
          path: /tmp/2039-ppe.tar
           
  push_to_registry:
    name: Push Docker image to ECR
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    needs: build
    steps:
      - name: Check out the repo
        uses: actions/checkout@v4
        # Download Docker image from previous job
      - name: Download artifacts (Docker images) from previous workflows
        uses: actions/download-artifact@v2
        with:
          name: 2039-ppe
          path: tmp  # Specify the path to download the artifact to
        
      - name: Push Docker image
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 244530008913.dkr.ecr.eu-west-1.amazonaws.com
          rev=$(git rev-parse --short HEAD)
          docker load --input tmp/2039-ppe.tar  # Correct the path to match the downloaded artifact
          docker tag 2039-ppe 244530008913.dkr.ecr.eu-west-1.amazonaws.com/2039-ecr-repo:$rev
          docker tag 2039-ppe 244530008913.dkr.ecr.eu-west-1.amazonaws.com/2039-ecr-repo:latest
          docker push 244530008913.dkr.ecr.eu-west-1.amazonaws.com/2039-ecr-repo:$rev
          docker push 244530008913.dkr.ecr.eu-west-1.amazonaws.com/2039-ecr-repo:latest
          
```

Ved push til main, for å ikke bygge container image to ganger, utnyttet jeg github actions sin upload-artifact funksjon for å dele image over flere jobber.




## Oppgave 3.

A. Kodeendringer of forbedringer
- [x] fjern hardkodingen av service name i main.tf
- [x] fjerne andre harkodede verdier 
- [x] Endre cpu til 256 og memory til 1024
```
  instance_configuration {
    instance_role_arn = aws_iam_role.role_for_apprunner_service.arn
    cpu               = 256
    memory            = 1024
  }
```

- [x] Legge til Provider og Backend kode i Terraform

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }
 backend "s3" {
    bucket = "pgr301-2021-terraform-state"
    key    = "candidate-2039/s3-bucket.state"
    region = "eu-north-1"
 }
}

provider "aws"{
  region="eu-west-1"
}
```

B. Workflow

- [x] docker.yml kjører terraform koden ved hver push til main
```
terraform:
    name: "Terraform Apply"
    runs-on: ubuntu-latest
    needs: push_to_registry
    if: github.ref == 'refs/heads/main'
    env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          NOTIFICATION_EMAIL: ${{ secrets.NOTIFICATION_EMAIL }}
          SERVICE_NAME: ${{secrets.SERVICE_NAME}}
          working-directory: ./infra
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Init
        run: terraform init
        working-directory: ${{env.working-directory}}

      - name: Terraform Plan
        run: terraform plan -var "service_name=$SERVICE_NAME" -var "alarm_email=$NOTIFICATION_EMAIL" -no-color
        continue-on-error: true
        working-directory: ${{env.working-directory}}

      - name: Terraform Plan Status
        if: steps.plan.outcome == 'failure'
        run: exit 1

      - name: Terraform Apply
        run: terraform apply -var "service_name=$SERVICE_NAME" -var "alarm_email=$NOTIFICATION_EMAIL" --auto-approve 
        working-directory: ${{env.working-directory}}
```
For at denne workflowen skal kjøre trenger sensor, i tillegg til AWS_ACCESS_KEY_ID og AWS_SECRET_ACCESS_KEY, legge til repository secrets 
```NOTIFICATION_EMAIL```
```SERVICE_NAME```


## Oppgave 4.
A.
Metrikkene jeg har valgt å implementere er:

- **Respons tiden/latency til endepunkt**
  - Denne metrikken ble valgt ved grunnlag av at en applikasjon for å være optimal, må ha god responstid til sine endepunkt. For denne metrikkern har jeg valgt å bruke average som måleenheten. Dette har jeg valgt siden om applikasjonen bruker lang tid 1 gang og ikke mer, er det ikke krise. Men dersom applikasjonen jevnlig har lang responstid, er det verdt å se om man får gjort noe med det.
    ```
       @Timed(value = "scan_latency", description = "Latency of Scan")
    ```
    

- **Antall brudd på sikkerhetsutstyr**
  - Hensikten til vernevokterne er å bedre arbeidssikkerheten. Derfor er hvor mange som bryter sikkerhetsprotekollene en viktig metrikk å monitorere
    ```
    if (violation){
                meterRegistry.counter("violations").increment();
            }
    ```

- **Antall personer sjekket**
  - denne metrikken har jeg valgt for å hjelpe til med å holde på kontroll om hvor mange prosent som bryter sikkerhetsprotokollene
    ```
     meterRegistry.counter("number_checked").increment(personCount);
    ```

B.
/infra/alarm_module ligger alarm modulen min. Jeg valgte å implementere at alarmen skal utløses dersom responstiden når 15,000 millisekunder altså 15 sekunder.
modulen har en hardkodet verdi, threshold som sier når alarmen skal utløses.
utover det er det 2 andre variabler: prefiks og candidate_nr, som begge får sin verdi fra variables.tf i infra mappen.



## Revurdering av prosessen, problemer jeg møtte på og hvordan de ble løst
**Oppgave 1**
Møtte på et stort hinder i denne oppgaven da jeg fikk ```Error: Failed to create changeset for the stack: sam-candidate-2039, An error occurred (ValidationError) when calling the CreateChangeSet operation: Stack:arn:aws:cloudformation:eu-west-1:244530008913:stack/sam-candidate-2039/eb133220-84a8-11ee-b9c6-02e00905e343 is in ROLLBACK_COMPLETE state and can not be updated. ```
lette lenge etter endringer og utførte de, men samme problem. prøvde å slette genererte filer i s3 bucket, men fortsatt ingen fremgang. Til slutt innså jeg at jeg ikke hadde prøvd å slette selve stacken, som var roten av problemet. Da prøvde jeg å slette både genererte filer og stacken før jeg deployet på nytt, så funket det.

**Oppgave 2 og 3**
Oppgave 2 gikk veldig greit i utgangspunktet, det var først i oppgave 3, etter mye hodebry at jeg innså feilen jeg hadde gjort. Jeg hadde glemt å legge til 'latest' tag på container image som ble pushet til ECR. Så da jeg prøvde å lage en apprunner service ble jeg møtt med en lite hjelpsom feilmelding 
```
Error: waiting for App Runner Service (arn:aws:apprunner:eu-west-1:244530008913:service/apprunner-2039/fdcf4ad637e442bea9740c3ada2a6a1d) creation: unexpected state 'CREATE_FAILED', wanted target 'RUNNING'. last error: %!s(<nil>)
```
I apprunner logs så jeg videre at den ikke klarte å kopiere image. Etter en gjennomgang av oppgave teksten og sjekk av s3 bucket så jeg at den siste ikke hadde en latest tag, derav vanskelig for apprunner å kopiere et image som ikke eksisterer.

**Oppgave 4**
Her møtte jeg på en hindring som jeg ennå ikke har fått løst. Metrics vises ikke i cloudwatch. Om sensor har noen diagnose om hva som hindrer dette, setter jeg pris på tilbakemelding for læringens skyld, om dette er mulig.

## Drøfte Oppgaver.

### A. Kontinuerlig Integrering
##### Hva er Kontinuerlig Integrasjon?
Kontinuerlig Intergrasjon (CI) er en praksis som er hyppig brukt innenfor DevOps området. Sammen med andre prakiser som
Kontinuerlig Leveranse (CD), et mål om å optimalisere utrulling av kodeendringer til en applikasjon. Konseptet går ut på å jevnlig integrere nye kodeendringer i kodebasen, med sikte på å oppdage feil raskt og effektivt.

##### Gjennomføring av Kontinuerlig Integrasjon

God praksis er å pushe kodeendringer til en dedikert sub-branch i stedet for main branch. Deretter opprettes det en pull-request, og før denne godkjennes, gjennomgår applikasjonen bygge- og testprosesser gjennom en Workflow som for eksempel Github Actions. Merging tillates bare hvis alle tester passerer. 

##### Fordeler med kontinuerlig integrasjon
Kontinuerlig Integrasjon reduserer risikoen for applikasjonsfeil ved å avdekke problemer gjennom grundig testing. Automatiserte tester bidrar også til økt tids- og kostnadseffektivitet, spesielt for store applikasjoner. 

##### Kontinuerlig Integrasjon i praksis

Kontinuerlig Integrasjon i praksis vil man ofte sette opp Branch Protection Rules for sin main branch. Disse reglene krever vanligvis en pull-request fra en isolert sub-branch. Etter opprettelsen av pull-requesten gjennomgår applikasjonen nødvendige workflow jobber, og godkjenning fra medutviklere er vanligvis påkrevd.


### B. Scrum, DevOps. Forskjeller og Likheter

#### Scrum
##### Hva er Scrum
Scrum er en programvareutviklings metodikk som fremmer kommunikasjon mellom utviklere og produkteier. Scrum er hensiktsmessig dersom krav og kriterier for et produkt ikke er godt definert. Utviklingsteamet jobber i Sprints. En sprint vil i Scrum gå i rekkefølgen:  planlegge sprint -> jobbe med utvikling -> evaluering av sprint. Dette oppsettet gjør at teamet kommuniserer jevnlig og
konstant kan drøfte og evaluere om fremgangsmåten var optimal eller ikke, og gjøre justeringer deretter. I Scrum har man en backlog som definerer kriterier for applikasjonen og disse gis poeng etter grad av kompleksitet. Denne backloggen er fleksibel, dersom en oppgave er for kompleks, kan man justere og dele den opp i flere mindre oppgaver.

##### Fordeler og utfordringer med Scrum
Fordeler med bruk av Scrum i en utviklingsprosess er at den er veldig mottakelig mot endringer. I en utviklingsprosess kan priotiteter og ønsker endre seg fort, og da gir Scrum et godt utgangspunkt for dette.
Når man jobber med større prosjekter kan det være vanskelig å vite hvor man skal starte og hvilke oppgaver man skal prioritere over andre. Den grundige planleggingen hjelper med å løse dette.

Grunnet Scrum's vektlegging på kommunikasjon og kreativt bidrag fra teamet, kan større team stå overfor utfordringer med å komme til enighet. Dette skyldes den økte kompleksiteten i koordineringen og behovet for å håndtere ulike synspunkter. Det er som et tveegget sverd – mens Scrum fremmer samarbeid, kan det også introdusere utfordringer i store team.

Spesielt kan fleksibiliteten i Scrum, selv om den er en styrke, også være en potensiell kilde til vanskeligheter. Uten en tydelig definert sluttdato for utviklingen og uklare krav, kan prosjektet lide. Jeg opplevde personlig dette under en Smidig Prosjekt-eksamen forrige semester.

Udefinerte krav kan skape usikkerhet, spesielt hos produktutviklere. Det åpner rom for endringer basert på forståelse som kan utvikle seg over tid. Imidlertid er det en risiko for at produktutviklere ikke klart vet hva de ønsker. Dette ble tydelig i et prosjekt hvor etterspurte endringer ble implementert, men senere møtt med motstand fra produktansvarlige som hadde forventet noe annet.

#### DevOps
##### Hva er DevOps

DevOps er en metodikk som fremmer samarbeid mellom utviklere (Dev) og drift (Ops). Konseptet introduserer "Skin in the game", som betyr at begge parter deler ansvar og konsekvenser. Før DevOps arbeidet utviklere og drift isolert. Dette skapte utfordringer da disse to rollene ikke alltid var på samme side.

Utviklere ønsker å skrive og distribuere kode så raskt som mulig, mens drift kan møte problemer hvis sikkerhetstiltak ikke er implementert før endringene lanseres. Når applikasjonen mislykkes, er det driftens ansvar å håndtere konsekvensene. Dette skapte et paradoks hvor utviklere hadde begrenset insentiv til å skrive bedre kode, da de ikke direkte opplevde konsekvensene av en dårlig ytelse.

Med DevOps blir dette paradokset adressert. Utviklere og driftsarbeidere samarbeider tettere, deler ansvar og konsekvenser. "Skin in the game" oppfordrer utviklere til å skrive bedre kode, fordi de nå deler konsekvensene hvis feil oppstår. Dette skaper et miljø der begge parter er motivert til å forbedre kvaliteten på kode og samtidig opprettholde et effektivt utviklings- og utrullingsmiljø.

##### DevOps' 3 hovedprinsipper

*Flyt* handler om at utviklingsprosessen skal flyte best mulig uten "waste", altså ting som hindrer effektiviteten til utvikling og kvaliteten til applikasjonen. Dette kan være blant annet: delvis ferdig arbeid, task switching, og venting. For å oppnå flyt tar man nytte av metoder som Kontinuerlig Integrering, Kontinuerlig Leveranse, Automatisering og Pipelines.

*Feedback* er avgjørende for å få nyttig informasjon som kan hjelpe med forbedring av applikasjonen raskt. For eksempel:
* Problem:  Flere brukere sliter får problemer når de prøver å sjekke ut handlekurven.
* Feedback: Tjenesten klarer ikke å prosessere så mange brukere på en gang. 
* Løsning: Skalér tjenesten ut til å håndtere flere brukere.
For å oppnå god feedback for applikasjonen, benytter man seg av overvåkning, logging og metrikker.

*Kontinuerlig Forbedring* fokuserer ikke bare på forbedring av en applikasjon. Holde følge med nye endringer i Teknologi-verden. men også på forbedring av utviklerene. En daglig læringsinnsats over et år resulterer i betydelig kompetansevekst. I organisasjoner som har integrert DevOps i kulturen, kan det til og med være dedikerte dager der utviklere jobber med å forbedre sine ferdigheter eller lære nye.

##### Fordeler og utfordringer med DevOps
DevOps bringer med seg flere fordeler. I den hurtigevolverende teknologiverden gir DevOps organisasjoner fleksibilitet til å holde tritt med endringer og adoptere nye teknologier. Noen organisasjoner i DevOps-verdenen har integrert "Blitz Dager". Disse dagene innebærer at utviklere jobber med større endringer, som å erstatte en eksisterende teknologi med en potensielt nyere og bedre løsning. 

Ved å utnytte teknologiene som tilbys av DevOps, reduseres risikoen for menneskelige feil, for eksempel ved bruk av automatiserte tester. Dersom en tester skulle overse å manuelt teste en tjeneste etter en lang arbeidsdag, kan det føre til utilsiktet feil ved å pushe kode, og tjenesten blir utilgjengelig.

Å innføre DevOps, til tross for dens fordeler, utfordrer organisasjoners etablerte kultur og krever investeringer. Denne overgangen involverer ikke bare finansielle kostnader, men også tid, da ansatte må dedikere seg til å lære og tilpasse seg nye teknologier. Samtidig må organisasjonen opprettholde driften av eksisterende systemer, og dette doble ansvaret gjør implementeringen kompleks. Overgangen til DevOps krever derfor en nøye planlagt og langsiktig innsats, hvor kultur og teknologi integreres gradvis for å sikre en vellykket transformasjon.

### Scrum vs DevOps; Forskjeller og likheter

DevOps og Scrum har både distinkte forskjeller og interessante likheter i tilnærmingen til utviklingsprosesser. Begge har som mål å optimalisere utviklingen, men deres metoder varierer betydelig. Scrum legger vekt på teamkommunikasjon, interaksjon, og bygging av verdier samt en god kultur for å sikre effektivt samarbeid. På den andre siden har DevOps en tydeligere fokus på automatisering av oppgaver og bruk av teknologi for å oppnå effektivitet i utviklingsprosessen.

Selv om disse konseptene benytter ulike tilnærminger, deler de et felles mål: å fremme samarbeid, redusere hindringer og, mest betydningsfullt, fremme kontinuerlig læring for å muliggjøre raskere produktlevering.

Scrum betraktes som en metodikk og et verktøy som et team kan implementere når det er hensiktsmessig. På den andre siden oppfattes DevOps ofte mer som en kultur eller ideologi som skal innarbeides i hele organisasjonen for å være virkelig effektiv. DevOps oppnår sin maksimale effektivitet når det omfavnes av hele organisasjonen som en enhet. Det er fullt mulig å kombinere disse to metodikkene avhengig av behovene. Mens Scrum definerer hvordan man kan løse et problem, gir DevOps de nødvendige midlene for å effektivt løse disse problemene.


### C. Det Andre Prinsippet - Feedback.

#### Implementering av Feedback for ny Funksjonalitet
Når en ny funksjonalitet er implementert i en applikasjon, er det avgjørende å etablere og bruke feedback-teknikker for å sikre at den møter brukernes behov på en optimal måte.
For å best mulig løse spørsmålet om hvilke teknikker for å møte brukerenes behov, må disse først identifiseres.

#### Behov
* Brukeropplevelse
  * Vurdere brukerens preferanser når det gjelder design, navigasjon og brukergrensesnitt.
  * Identifisere eventuelle smertepunkter eller frustrasjoner brukerne kan møte under interaksjon med funksjonaliteten.
* Ytelse
  * Vurdere brukerens forventninger til responstider og generell ytelse.
  * Identifisere potensielle områder for forbedringer for å sikre en jevn opplevelse.
* Feilhåndtering
    * Vurdere brukerens forventninger til feilhåndtering og tilgjengelighet.
    * Identifisere hvordan brukeren ønsker å bli informert om eventuelle feil eller problemer.

#### Hvordan kan Feedback hjelpe oss møte behov
Nå som behovene er identifisert, kan man se på hvilke teknikker som kan hjelpe oss med å sikre at funksjonaliteten møter brukernes behov.

*Brukeropplevelse* er avgjørende for hvordan en applikasjon eller funksjonalitet blir tatt imot av brukerne. Feedback-teknikker som A/B-testing spiller en viktig rolle her. Ved å dele brukergrupper og gi dem forskjellige versjoner av funksjonaliteten, kan man måle responsen og identifisere hvilken versjon som gir den beste brukeropplevelsen. Deretter kan man ta den mest suksessrike versjonen som utgangspunkt for videre utvikling, og dermed forbedre brukeropplevelsen gjennom iterativ testing.

Når det gjelder *ytelse*, er det essensielt å benytte seg av metrikker for å måle og overvåke responstiden. Responstiden er den tiden det tar for systemet å svare på brukerforespørsler, og det er en kritisk faktor for å sikre en effektiv brukeropplevelse. Ved å implementere og analysere responstidsmetrikker kan man kontinuerlig optimalisere ytelsen. Her er noen sentrale metrikker:
1. Gjennomsnittlig Responstid
   * Gir indikasjon på systemets responstid. Endring i gjennomsnittlig responstid, kan vise til behov for ytelsestilpasninger.
3. Maksimal Responstid
   * Identifiserer ekstreme tilfeller av treg respons, som kan være kritiske for brukeropplevelsen.
5. Antall Samtidige Brukere vs. Responstid
   * Identifiserer potensielle begrensninger og hjelper med å skalere ressurser for å opprettholde god ytelse under belastning.

*Feilhåndtering* er en kritisk del av å møte brukernes behov og sikre en pålitelig og feilfri opplevelse. Feedback om feil og problemer fra brukere eller systemovervåkning er avgjørende for kontinuerlig forbedring av feilhåndteringen. Teknikker som kan hjelpe oss med dette er å implementere gode logføringsrammeverk, og kontinuerlig overvåkning av tjenestene.

#### Hvordan feedback bidrar til Kontinuerlig Forbedring

Feedback spiller en viktig rolle for kontinuerlig forbedring gjennom hele utviklingslivssyklusen. I de tidlige stadiene av kravspesifikasjon og planlegging bidrar feedback til å avdekke potensielle utfordringer og muligheter, slik at justeringer og forbedringer kan gjøres. 

Under utvikling og implementering muliggjør kontinuerlig integrasjon og leveranse (CI/CD) konstant tilbakemelding på kodekvalitet, feil og ytelse gjennom automatiserte tester og kodegjennomganger. Dette gir utviklerne muligheten til å rette feil umiddelbart og iterativt forbedre koden.

I testing- og kvalitetssikringsfasen gir feedback fra forskjellige tester innsikt i styrker og svakheter i applikasjonen. Automatiserte tester og manuell testing gir konstant tilbakemelding, og endringer implementeres basert på testresultatene.

Selv etter at produktet er implementert og i drift, spiller feedback en avgjørende rolle. Overvåking av systemets ytelse og bruk av loggfiler gir informasjon om potensielle begrensninger, feil og bruksmønstre. Denne innsikten muliggjør kontinuerlig optimalisering av applikasjonens stabilitet.

Integrasjonen av feedback gjennom hele utviklingslivssyklusen muliggjør ikke bare feilretting, men også proaktiv tilpasning til endrede krav og forhold. Den iterative naturen av smidige og DevOps-metoder understreker viktigheten av å lytte til feedback for å oppnå kontinuerlig forbedring og levere verdifull programvare. Dette skaper en smidig utviklingsprosess der lærdommen fra tidligere faser blir en drivkraft for konstant forbedring gjennom hele livssyklusen til programvaren.





