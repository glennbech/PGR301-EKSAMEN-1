# PGR301-EKSAMEN
Eksamen DevOps PGR301 - 2023

**!OBS! For at workflows skal kjøre korrekt i sensor sin fork må det i Settings -> Secrets & Variables -> actions opprettes 2 variabler: AWS_ACCESS_KEY_ID & AWS_ACCESS_KEY_ID. Disse verdiene kan 
genereres i AWS IAM (selv om sensor allerede vet det)**

## Oppgave 1.

- [x] Workflow bygger SAM applikasjonen ved push til branches som ikke er main
- [x] Workflow bygger og deployer Sam applikasjonen til S3 Bucket
- [ ] Sam Applikasjonen deployes feilfritt til s3 Bucket


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

Ved push til main, for å ikke bygger container image to ganger, utnyttet jeg github actions sin upload-artifact funksjon for å dele image over flere jobber.




## Oppgave 3.

A. Kodeendringer of forbedringer
 - [x] fjern hardkodingen av service name i main.tf
 - [x] fjerne andre harkodede verdier 
```
variable "service_name"{
    type = string
    default = "apprunner-2039"
}

variable "image_identifier"{
    type = string
    default = "244530008913.dkr.ecr.eu-west-1.amazonaws.com/2039-ecr-repo"
}

variable "iam_role_name"{
    type = string
    default = "2039-role-thingy"
}

variable "policy_name"{
    type = string
    default = "2039-apr-policy-thingy"
}

variable "policy_description"{
    type = string
    default = "Policy for apprunner instance I think"
}

variable "candidate_number"{
    type = string
    default = "candidate_2039"
} 
```
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
- [ ] 




## Oppgave 4.

Metrikkene jeg har valgt å utføre er:

* Respons tiden til endpoint
* Antall brudd på sikkerhetsutstyr
* Antall personer sjekket


## Drøfte Oppgaver.

### A.
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


### B.

#### Scrum
Scrum er Programvareutvikling metodikk som fremmer kommunikasjon mellom utviklere og produkteier. Scrum er hensiktsmessig dersom krav og kriterier for et produkt ikke er godt definert. Utviklingsteamet jobber i Sprints. En sprint vil i Scrum gå i rekkefølgen:  planlegge sprint -> jobbe med utvikling -> evaluering av sprint. Dette oppsettet gjør at teamet kommuniserer jevnlig og
konstant kan drøfte og evaluere om fremgangsmåten fungerer eller ikke, og gjøre justeringer deretter. I scrum har man en backlog som definerer kriterier for applikasjonen og gir dem poeng etter vanskelighetsgrad. Denne backloggen er åpen for endring, dersom en oppgave er for kompleks, kan man justere og dele den opp i flere mindre oppgaver, og om en oppgave viser seg å være mer kompleks
enn forutsett, kan poengene justeres opp.
Fordeler med bruk av scrum i en utviklingsprosess er at den er veldig mottakelig mot endringer. I en utviklingsprosess kan priotiteter og ønsker endre seg fort, og da gir Scrum et godt utgangspunkt for dette.
Når man jobber med større prosjekter kan det være vanskelig å vite hvor man skal starte og hvilke oppgaver man skal prioritere over andre. Planleggingen i scrum hjelper med å løse dette. I Backloggen så rangerer man de forskjellige oppgavene etter prioritet.
Siden scrum fremmer kommunikasjon innad i team, og oppfordrer kreativ innputt, kan større team være utfordrende. Det blir vanskeligere å komme til enighet. Vel å merke, kan fleksibiliteten i Scrum  være som en tveegget sverd. En udefinert sluttdato for utviklingen, og udefinerte krav, kan føre til problemer. Personlig fikk jeg oppleve dette under eksamen i Smidig Prosjekt, forrige semester.
Ved udefinerte krav, er det en mulighet at produkteierene ikke helt vet hva de vil ha. Etterspurte endringer ble gjort, men ble senere takk dårlig imot. 


#### DevOps

DevOps er en metodikk som fremmer kommunikasjon mellom Developers og Operations, konseptet innfører "Skin in the game"(G. Bech 2023) Før DevOps jobbet utviklere og operations isolert. Disse to rollene er ikke
alltid på samme side. Utviklerene ønsker å skrive og pushe kode så fort som mulig, mens operations kan møte på problemer dersom sikkerhetstiltak ikke er tatt før man lanserer endringene. Om applikasjonen feiler, havner det i hendene til operations, utviklerene hadde derfor ikke noe insentiv til å skrive bedre kode. Men med DevOps jobber disse to rollene sammen med delt ansvar og konsekvenser. Skin in the game oppfordrer utviklerene å skrive bedre kode, for de deler konsekvensene hvis det oppstår feil.
I DevOps finnes det 3 hovedprinsipper:

**Flyt** handler om at utviklingsprosessen skal flyte best mulig uten "waste", altså ting som hindrer effektiviteten til utvikling og kvaliteten til applikasjonen. Dette kan være blant annet: delvis ferdig arbeid, task switching, og venting. For å oppnå flyt tar man nytte av metoder som Kontinuerlig Integrering, Kontinuerlig Leveranse, Automatisering og Pipelines.

**Feedback** handler om å få nyttig informasjon som kan hjelpe med forbedring av applikasjonen, fort, og gjøre noe med det. eks. 
Problem:  flere brukere sliter får problemer når de prøver å sjekke ut handlekurven? 
Feedback: tjenesten klarer ikke å prosessere så mange brukere på en gang. 
Løsning: skaler tjenesten ut til å håndtere flere brukere.
For å få god feedback for applikasjonen, tar man nytte av overvåkning, logging, metrikker.

**Kontinuerlig Forbedring** handler om å lære hele tiden. Lærer man litt hver dag i et år, når man ser tilbake har man lært en hel del. I organisasjoner som har DevOps integrert i kulturen, har noen av de til og med dedikerte dager for utviklere å forbedre sine ferdigheter og/eller lære nye.

DevOps har flere fordeler. I den teknologisk utviklende verden som vi lever i, endres trender hyppig, og nye teknologier kommer på banen. DevOps gir organisasjoner fleksibiliteten til å ikke falle bak disse trendene. I Devops verden har de "Blitz Dager" som er dager hvor utviklerene jobber med å gjøre større endringer, som for eksempel å bytte ut en teknologi med potensielt ny og bedre teknologi. Ved å utnytte disse teknologiene man har i DevOps, minimerer det muligheten for menneskelige feil. Automatiserte tester f.eks. Hvis en tester skulle manuelt teste alle tjenesten etter en lang arbeidsdag, og plutselig glemte å teste en av tjenestene, som feilet. Ubevisst om dette pushet vedkommende kode og tjenesten blir utilgjengelig.

Til tross for fordelene med Devops, kan det være utfordrende å implementere i en organisasjon. Det kreves en kulturell endring innad i organisasjonen. Devops tar i bruk mange forskjellige teknologier. Disse teknologiene må organisasjonen investere i. Ikke bare er det en finansiell kostnad. Men det koster tid. Arbeiderne i organisasjonen må ta seg tid til å lære seg å bruke disse teknologiene, og etter personlig erfaring vet jeg at det ikke skjer på en dag. Og dette samtidig som man må holde systemet sitt fungerende, og oppdatert med tidene.


### Scrum vs DevOps; Forskjeller og likheter

DevOps og Scrum har både forskjeller og likheter når det kommer til utviklingsprosess. Begge søker etter å effektivisere utvikling. Men deres tilnærming til hvordan dette gjøres er forskjellige. Scrum fokuserer på Team kommunikasjon og interaksjon, bygge verdier og god kultur for at teamet skal jobbe effektivt. Mens Devops har større fokus på automatisering av jobber og bruk av teknologi i i utviklingsprosessen for effektivitet. 

Disse to konseptene, sett bort ifra sine forskjellige fremgangsmåter, har samme mål. De fokuserer på samarbeid, minimere hindringer, og kanskje viktigst; læring, for raskere produktlevering.

Mens Scrum er en metodikk/verktøy et team kan bruke dersom det virker hensiktsmessig, blir DevOps ofte sett på mer som en kultur/ideologi innad i en organisasjon. For at Devops skal være effektivt, nytter det seg ikke at ett team bruker Devops og resten ikke gjør det. Devops er effektivt når organisasjonen som en enhet tar i bruk denne ideologien. Det er fullt mulig å kombinere disse to. Det kan avhengig av behov, være hensiktsmessig. Scrum definerer hvordan man kan løse et problem, mens DevOps gir oss midlene til å løse dette problemet.


