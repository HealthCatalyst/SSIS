# SSIS

## What is this

- Data flow process
    + Pause the SAM by having it stop after an entity runs.
    + Run the R script that makes predictions and populates a table.
    + Resume the SAM.
- Configuration for extensibility poits are stored in
    + `ETLEngineConfig` (some configuration)
    + `ObjectAttributeBase` (additional configuration)

## Details

The ExternalScriptExecution.dtsx runs as an extensibility after the OnPostTableLoad on the empty destination table. The empty destination table should have already been designed in SAMD with the appropriate columns and data types. The binding query for that empty destination table should execute a select statement from the source table where 1 = 2. For example, SELECT {columns with Aliases matching destination columns} FROM {DatabaseNM}.{SchemaNM}.{SourceTableNM} WHERE 1 = 2. This simple binding query creates a simple dependency upon the source table.

Once the destination table loads its empty binding, the OnPostTableLoad will trigger the ExternalScriptExecution. This script will execute the intended function on the intended external script (Python or R) if all the required Object Attributes are defined.

The require Object Attributes are as follows:
ExternalRScript: System-level object attribute containing the HCRTools script
ExternalPythonScript: System-level object attribute containing the HCPythonTools script
RInterpreterPath: System-level local path of the RScript.exe interpreter
PythonInterpreterPath: System-level local path of the Python interpreter
ExternalScriptType: Table-level variable, "R" or "Python"
ExternalScriptFunction: Table-level variable, function within script, i.e. "FindTrends"
ExternalScriptSourceEntity: Table-level variable, source table from which to query
ExternalScriptArguments: Table-level variable, space-delimited extra arguments for script function, i.e. "z2" "Test.txt"

If any of these attributes are not defined, the package will exit, logging the reason in EDW Console.

## Glossary

- Batches
    + Scheduled in EDW Console (web portal) by TD.
- **Icepack File**
    + SSIS package installer
- **DTX File**
    + These are the files that are installed into SSMS.
- SSIS packages are found in:
    + SSMS > `Integration Services Catalogs` > `CatalystExtensibility`