## EV punjaci - lokalno

Ovaj projekat prikazuje lokacije EV punjaca na mapi i omogucava pretragu po gradu. Backend je serverless (API Gateway + Lambda) a podaci se cuvaju u DynamoDB. Sve se pokrece lokalno kroz LocalStack.

## Sta aplikacija radi

- Sinhronizuje podatke sa OpenChargeMap API-ja u DynamoDB (Lambda `sync`).
- Vadi punjace po gradu (Lambda `getChargersByTown`).
- Prikazuje punjace na mapi (Leaflet).
- Klik na mapu trazi najblizi punjac po ruti (OSRM). Ako OSRM ne radi, koristi vazdusnu liniju.

## Preduslovi

- Node.js (preporuka: 18+)
- npm
- Docker + Docker Compose
- AWS CLI (za LocalStack, koriste se test kredencijali)

## Brzi start (preporuceno)

```
cd /home/aleksandra/Desktop/XD/moj-rvtech-projekat
npm install
npm run start-local
```

Komanda `start-local`:
- postavlja AWS test kredencijale,
- pokrece LocalStack (ako nije vec pokrenut),
- saceka health,
- radi `serverless deploy`,
- azurira API ID u `web/index.html`,
- uploaduje frontend u S3,
- otvara link u browseru (ako postoji `xdg-open`).

Frontend URL:
```
http://punjaci-website-rvtech.s3-website.localhost.localstack.cloud:4566
```

## Rucni start (korisno za debug)

```
cd /home/aleksandra/Desktop/XD/moj-rvtech-projekat
npm install
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
npm run up
npm run deploy
npm run update-api-id
npm run deploy-frontend
```

## Testiranje API-ja

```
curl "http://localhost:4566/restapis/<API_ID>/dev/_user_request_/sync"
curl "http://localhost:4566/restapis/<API_ID>/dev/_user_request_/chargers/Beograd"
```

`API_ID` je upisan u `web/index.html`.

## OSRM (najblizi punjac po ruti)

Za racunanje rute koristi se javni OSRM servis:
```
https://router.project-osrm.org
```

Potrebna je internet konekcija. Ako OSRM ne radi, aplikacija automatski koristi vazdusnu liniju kao fallback.

## Bitni fajlovi

- `lambdas/sync.js` - sinhronizacija podataka iz OpenChargeMap u DynamoDB
- `lambdas/getChargersByTown.js` - vraca punjace po gradu (GSI `TownIndex`)
- `serverless.yml` - definicija funkcija i resursa (DynamoDB, S3, API Gateway)
- `web/index.html` - frontend (Leaflet mapa)
- `scripts/start-local.sh` - automatizovan start lokalno
- `scripts/update-api-id.js` - upisuje API ID u frontend

## Najcesci problemi

### Port 4566 ili 4510 je zauzet
Znaci da je vec pokrenut drugi LocalStack. Ugasi ga:
```
docker ps
docker stop <ime_containera>
```

### "Unable to locate credentials"
Postavi test kredencijale:
```
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

### "Could not connect to the endpoint URL"
LocalStack nije pokrenut. Pokreni:
```
npm run up
```

### "Table already exists: Chargers"
Obrisi tabelu ili resetuj LocalStack:
```
aws --endpoint-url=http://localhost:4566 dynamodb delete-table --table-name Chargers --region us-east-1
```
ili
```
npm run reset
```

## Struktura projekta

```
moj-rvtech-projekat/
  lambdas/
    getChargersByTown.js
    sync.js
  scripts/
    start-local.sh
    update-api-id.js
  web/
    index.html
    error.html
  serverless.yml
  docker-compose.yml
  package.json
```

