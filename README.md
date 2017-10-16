# SSIS

These tools enable machine learning in the HC platform by setting up extensibility points that call out to R/Python scripts during ETLs.

## Data Flow Process

1. A SAM Batch ETL runs.
2. The SAM pauses ETLs after a specific entity runs.
3. The R/Python script runs making predictions and populates a table.
4. The SAM resumes ETLs.

## Extensibility Poits Configuration

Configuration for extensibility points are stored in two tables:

- `ETLEngineConfig` (some generic configuration)
- `ObjectAttributeBase` (additional detailed configuration)

## Details

The `ExternalScriptExecution.dtsx` runs as an extensibility after the `OnPostTableLoad` on the empty destination table. The empty destination table should have already been designed in SAMD with the appropriate columns and data types. The binding query for that empty destination table should execute a select statement from the source table where 1 = 2. For example:

```sql
SELECT {columns with Aliases matching destination columns}
FROM {DatabaseNM}.{SchemaNM}.{SourceTableNM}
WHERE 1 = 2.
```

This simple binding query creates a dependency upon the source table.

Once the destination table loads its empty binding, the `OnPostTableLoad` event will trigger the `ExternalScriptExecution`. This script will execute the intended function on the intended external script (Python or R) if all the required Object Attributes are defined correctly.

### Required Object Attributes:

- **ExternalRScript**: System-level object attribute containing the R script
- **ExternalPythonScript**: System-level object attribute containing the Python script
- **RInterpreterPath**: System-level local path of the `RScript.exe` interpreter
- **PythonInterpreterPath**: System-level local path of the Python interpreter
- **ExternalScriptType**: Table-level variable, `R` or `Python`
- **ExternalScriptFunction**: Table-level variable, function within script. For example: `FindTrends`
- **ExternalScriptSourceEntity**: Table-level variable, source table from which to query
- **ExternalScriptArguments**: Table-level variable, space-delimited extra arguments for script function, i.e. "z2" "Test.txt"

If any of these attributes are not defined, the package will exit and log the reason in EDW Console.

## Glossary

- **SSIS**
    + SQL Server Integration Services.
- **SSMS**
    + SQL Server Management Studio. Where work happens.
- **EDW Console**
    + Catalyst web app for viewing and configuring ETLs.
    + Errors are surfaced here.
- **Batches**
    + ETLs scheduled in EDW Console (web portal) by a TD.
- **SSIS packages**
    + are found in: SSMS > `Integration Services Catalogs` > `CatalystExtensibility`
- **ISPAC File**
    + The project deployment file is a self-contained unit of deployment that includes only the essential information about the packages and parameters in the project. [reference](https://docs.microsoft.com/en-us/sql/integration-services/packages/deploy-integration-services-ssis-projects-and-packages)
- **DTX File**
    + The actual SSIS package files that are installed into SSIS via SSMS.