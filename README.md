# SSIS

These tools enable ML in the HC platform by setting up extensibility points that call out to R/Python scripts during ETLs. This is only for 4.0 and 4.2 versions of DOS.

## Data Flow Process

1. A SAM binding refreshes table A.
2. A subsequent SAM binding, dependant on table A, hosts the extensibility point.
    - This extensibility point runs the R file which reads from Table A.
    - Since this R file pushes predictions to table B, the SQL query for B just creates the column structure

## Requirements before starting

1. Your environment is on DOS 4.0 of 4.2.
2. You've already been able to [push predictions to a destination database](https://docs.healthcare.ai/articles/site_only/deploy_model.html).
3. The rest are [here](https://github.com/HealthCatalyst/SSIS/blob/master/R%20Extensibility%20Instructions.md#requirements).

## Extensibility Points Configuration

[This doc](https://github.com/HealthCatalyst/SSIS/blob/master/R%20Extensibility%20Instructions.md) details the entire process.

## Who's supposed to work through this?

- AEs and analysts, if they can write to EDWAdmin, can do much of that work
- Sys admins / DBAs are needed for installing the ispac, which requires an RDP into the ETL server

## Glossary

- **SSIS**
    + SQL Server Integration Services.
- **SSMS**
    + SQL Server Management Studio. Where work happens.
- **EDW Console**
    + Catalyst web app for viewing and configuring ETLs.
    + Errors are surfaced here.
- **Batches**
    + ETL jobs scheduled in EDW Console (web portal) by a AD/TD.
- **SSIS packages**
    + are installed in: SSMS > `Integration Services Catalogs` > `CatalystExtensibility`
- **DTSX File**
    + The actual SSIS package files that are installed via the .ispac file.
- **ISPAC File**
    + This is the SSIS project deployment file, which is a self-contained unit of deployment that includes only the essential information about the packages and parameters in the project. [reference](https://docs.microsoft.com/en-us/sql/integration-services/packages/deploy-integration-services-ssis-projects-and-packages)
