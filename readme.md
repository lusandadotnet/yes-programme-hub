# YES Programme Hub

A fictional scenario I built to practice SAP Cloud Application Programming Model (CAP), Node.js, HANA Cloud and SAP BTP.

For large enterprises, managing YES Programme cohorts usually involves heavy manual tracking to ensure companies hit absorption targets for their B-BBEE audits, and some even just end up outsourcing it. To automate this and keep it in-house, I built an extension using the SAP Cloud Application Programming model with Node.js and HANA Cloud.

### CAP Backend

The backend is built with SAP CAP and Node.js and exposes an OData V4 service:

```text
/odata/v4/yesprogramme/
```

The main `Youth` entity models:

* Participant information
* Placement start and end dates
* Programme status
* Placement details
* Monthly supervisor logs
* Absorption information

### Business Logic

I implemented CAP service handlers to:

* Extract the date of birth from South African ID numbers.
* Validate that a participant is between 18 and 35 at the placement start date.
* Automatically calculate a 365-day placement end date.
* Calculate a high-risk indicator when attendance falls below 80% for two consecutive months.

### Personal Data and Access Control

Because the scenario involves participant PII, I looked into POPIA.

I used CAP `@PersonalData` annotations to identify PII and applied role-based access restrictions to the service.

The application uses two roles:

```text
YES_Admin
YES_Supervisor
```

The domain entities also use CAP's `managed` aspect so records retain created/changed timestamps and user information.

### Fiori Elements Frontend

For the frontend, I used CDS UI annotations to generate a Fiori Elements application.

It provides:

* Youth Participants List Report
* Individual participant Object Pages
* Placement and status information
* Monthly supervisor logs
* YES programme activity information
* Participant risk/status indicators

The frontend consumes the same CAP OData V4 service as the backend.

### Security and Deployment

The solution uses:

* SAP BTP XSUAA
* SAP HANA Cloud / HDI
* SAP BTP Destination Service
* SAP Application Router
* SAP CAP
* Fiori Elements
* OData V4



## Running Locally

Install dependencies:

```bash
npm install
```

Start the CAP development server:

```bash
cds watch
```

The local OData service is available under:

```text
/odata/v4/yesprogramme/
```

## Build and Deploy

Build the CAP production output:

```bash
npx cds build --production
```

Build the MTA archive:

```bash
mbt build -p=cf
```

Deploy to Cloud Foundry:

```bash
cf deploy mta_archives/yes-programme-hub_1.0.0.mtar
```
