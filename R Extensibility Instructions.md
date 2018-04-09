# Machine Learning :: R Extensibility Instructions
# Fix links
- [Initial Steps](#initial-steps)
- [Repeatable Steps For Each Data Mart](#repeatable-steps-for-each-data-mart)
- [Repeatable Steps For Each Destination Entity](#repeatable-steps-for-each-destination-entity)
- [Seed Script Tempaltes](#seed-script-templates)

## Overview
This document instructs the user how to integrate their designated R scripts into the Catalyst loaders. It begins by testing the R script, and then installing the required SSIS package and defining new system level attributes. It continues by injecting the new SSIS package into the designated loader step. It concludes by defining the necessary variables for each destination entity. This extensibility point exists to solve the following problems/constraints:

- Typically no file system access is given on the ETL machines. This is required to run an R script with current infrastructure.
- This extensibility point takes an R script stored in a field in the EDW, writes it to a file in the staging folder, executes that file with the correct interpreter, and cleans the file up.
- The extensibility point also coordinates bindings within SAMD so that predictions occur in the right order with other SAMs.

## Requirements

- Permissions needed to 
  - Write EDWAdmin inserts via SQL
  - To install an SSIS package
  - To install the R interpreter
- You know which version of R and healthcareai your model was trained on. Can verify on the workstation in R via
`library(healthcareai)` and then `sessionInfo()`
- This same version of R is installed on the ETL server. See [here](https://cran.r-project.org/bin/windows/base/) for latest download and  [here](https://cran.r-project.org/bin/windows/base/old/) for older versions Please make sure this isn't a user-specific install

## Pre-extensibility checks

### Files Needed in R Working Directory

All of the following must be in the shared folder that is local to the ETL server. Note: the person who trained the model will have to help in identifying these:

  - R script that contains the deploy code. Example: `heart_failure_v1_deploy.R`
  - 2 rda model files that were generated when training. Examples:
    - `heart_failure_v1_rmodel_info_RF.rda`
    - `heart_failure_v1_rmodel_probability.rda`
  
The `.rda` files contain the model logic. Starting with healthcareai v2.0, only one rda is used. You can check healthcareai version via `sessionInfo()` in R

### R Script and Package Verification Process

1. Verify that that packages you depend on are installed correctly on the ETL server. Recall that versioning must be the same as when the model was trained.
    1. Run RGui as administrator
    2. Check that your packages are installed via `library(healthcareai)`
    3. If these need to be installed, type `install.packages('healthcareai')`
    4. Verify that these are _not_ installed in a personal folder by looking for them in `C:\Program Files\R\R-3.4.4\library`
      - If struggling with personal directories, check out the `lib` argument [here](https://stat.ethz.ch/R-manual/R-devel/library/utils/html/install.packages.html)
      - If you need an **old version** of healthcareai see [here](https://github.com/HealthCatalyst/healthcareai-r/releases) for downloads and use this install syntax: `install.packages(<pathtopackage>, repos = NULL, type="source")`

2. Verify your R script runs in RGui on the ETL Server (i.e., you can push predictions to the desired table)

3. Check that the R.exe **folder** has been added to path
    1. Open PowerShell and see if the R.exe **folder** is in your PATH by typing `R.exe`
    2. If R cannot be found, add it to path via [these instructions](http://www.itprotoday.com/management-mobility/how-can-i-add-new-folder-my-system-path); note: this might be `C:\Program Files\R\R-3.4.4\bin`      
    3. Reopen PowerShell and see that `R` starts without errors by typing `R.exe`

4. Test your script in PowerShell
   1. Test your script using `Rscript <PATH\YOUR_SCRIPT_NAME>` and make sure that predictions are inserted into the database
   2. Verify that a log was created in the folder where your script lives
   3. To ease future debugging, delete the logs that were created in the directory where your script lives

Before installing the extensibility points, please verify that the user's R scripts run standalone on the desired machine.
Due to the complexity of the extensibility process, **verifying this now avoids confusion later and reduces debugging time.** Only then should a user proceed to set up the extensibility points.

## Installing the Extensibility Packages From an ISPAC File
The following steps are for the .ispac installation wizard.

1. [Download](https://github.com/HealthCatalyst/SSIS/blob/master/ExternalScriptExtensibility.ispac), unzip, and open the .ispac file

2. Select `Project Deployment File` (Note: you can ignore warning about XML node)
![](images/SSIS_installation/SSIS_installation_1_project_deploy.png)

3. Select the desired server
![](images/SSIS_installation/SSIS_installation_2_select_database_server.png)

4. Create the folder `CatalsytExtensibility` if it does not exist on the database server
![](images/SSIS_installation/SSIS_installation_3_locate_or_create_folder.png)

5. Cick `Next` and then `Deploy` and ensure that all results passed.
![](images/SSIS_installation/SSIS_installation_4_passing_resutls.png)

6. Open SSMS and verify that these packages were installed:
![](images/SSIS_installation/SSIS_installation_5_verify_SSMS.png)

## Extensibility Point Configuration
1. Establish local folder on the ETL server. This is the working directory that the user script will run in. *Ideally, have the client DBA configure it as a shared folder that the analyst (i.e., model developer) can read and write to.*
2. Determine Identity of EDW_Loader account;
   1. In SSMS, look under Security -> Credentials -> Double click on credential roughly called EDW Loader
   2. Look at and note the account listed in the `Identity` field
3. Configure permissions to allow that same `EDW Loader` user account to read, write, and execute in this directory.
   1. Right click on the folder with the R script
   2. Select `Security` -> `Edit`
   3. Add permissions to the EDW_Loader account that you identified above
4. Set permissions for SSIS packages installed above. To find existing extensibility points look in: SSMS > Integration Services Catalog > SSISDB > CatalystExtensibility > Projects
    1. Download ETL User Guide for your version of DOS. Here is v3.2 and v4.0
    2. Look for `Extensibility` chapter and the section called `Set up permissions for SSIS packages`
    3. Follow instructions to verify permission to allow the `EDW loader` user account to execute.
5. Under the `Packages` folder, find the `ExternalScriptExecution.dtsx` package, click `Configure` and set the  `StagingDirectory` to the working directory (where your R script and rda files live), that was determined above.

## Define Attributes in EDWAdmin
1. Seed three new attribute (`RInterpreterPath`, `ExternalScriptType`, `ExternalRScript`) names into `EDWAdmin.CatalystAdmin.AttributeBASE`. This table can be thought of as a set of keys where values of that key can be set for specific instances of an object elsewhere in `ObjectAttributeBASE`. **Note this SQL can be run as-is. There is no configuration required.**
    
```sql
IF NOT EXISTS
    (SELECT * FROM EDWAdmin.CatalystAdmin.AttributeBASE WHERE AttributeNM = 'RInterpreterPath')
INSERT INTO EDWAdmin.CatalystAdmin.AttributeBASE (AttributeNM, AttributeDSC)
    VALUES ('RInterpreterPath','Local path to Rscript.exe')
IF NOT EXISTS
    (SELECT * FROM EDWAdmin.CatalystAdmin.AttributeBASE WHERE AttributeNM = 'ExternalScriptType')
INSERT INTO EDWAdmin.CatalystAdmin.AttributeBASE (AttributeNM, AttributeDSC)
    VALUES ('ExternalScriptType','R or Python')
IF NOT EXISTS
    (SELECT * FROM EDWAdmin.CatalystAdmin.AttributeBASE WHERE AttributeNM = 'ExternalRScript')
INSERT INTO EDWAdmin.CatalystAdmin.AttributeBASE (AttributeNM, AttributeDSC)
    VALUES ('ExternalRScript','R script that contains functions')
```
    
2. Verify that the new Attribute name keys exist in EDWAdmin.
    
```sql
SELECT [AttributeID]
      ,[AttributeNM]
      ,[AttributeDSC]
  FROM [EDWAdmin].[CatalystAdmin].[AttributeBASE]
WHERE AttributeNM IN ('RInterpreterPath', 'ExternalScriptType', 'ExternalRScript')
```
  
## Create an Extensibility Point for Each Data Mart

Seed `EDWAdmin.CatalystAdmin.ETLEngineConfigurationBASE` with these values:

|                Column               |                                          Value                                           |
| ----------------------------------- | ---------------------------------------------------------------------------------------- |
| **ExtensionPointNM**    | `OnPreStageToProdLoad`                                                                  |
| **DatamartID**          | <DATA_MART_ID>                                                                           |
| **SSISPackagePathOrSPToExecuteTXT** | `\SSISDB\CatalystExtensibility\ExternalScriptExtensibility\ExternalScriptExecution.dtsx` |
| **IsSSISPackageFLG**                | `1`                                                                                      |
| **ExtensionOwnerNM**                | `Health Catalyst`                                                                        |
| **RunInAsyncModeFLG**               | `0`                                                                                      |
| **Use32BitRuntimeFLG**              | `0`                                                                                      |
| **ExecutionOrderNBR**               | `1`                                                                                      |
| **ActiveFLG**                       | `1`                                                                                      |
| **RequiredParametersTXT**           | `BatchID, TableID`                                                                       |
| **FailsBatchFLG**                   | `1`                                                                                      |
The following SQL template needs only a single adjustment of the *DataMartID* before running. This is the DataMartID associated with the SAM where extensibility is being configured.

```sql
INSERT INTO EDWAdmin.CatalystAdmin.ETLEngineConfigurationBASE
(
    ExtensionPointNM, DatamartID, SSISPackagePathOrSPToExecuteTXT, 
    IsSSISPackageFLG, ExtensionOwnerNM, 
    RunInAsynchModeFLG, Use32BitRuntimeFLG, 
    ExecutionOrderNBR, ActiveFLG, RequiredParametersTXT, 
    FailsBatchFLG
) 
VALUES 
(
    'OnPostStageToProdLoad', <DATA_MART_ID>, '\SSISDB\CatalystExtensibility\ExternalScriptExtensibility\ExternalScriptExecution.dtsx', 
    1, 'Health Catalyst', 0, 0, 1, 1, 'BatchID, TableID', 1
)

```
Update your `DataMartID` and verify insertion using this SQL template:
```sql
SELECT * FROM EDWAdmin.CatalystAdmin.ETLEngineConfigurationBASE
WHERE DataMartID = <DATA_MART_ID>;
```

## Repeatable Steps For Each Destination Entity
Before proceeding to this step, ensure that your ML script runs on it's own outside the extensibility point workflow. In otherwords, run it in PowerShell via `RScript.exe file.R` . Then, modify this example, adding in your R script at the end. 

```R
# Move to working directory 
setwd("C:/Users/levi.thatcher/Downloads") # --> Change to shared folder on ETL server <--

library(methods) # required if using healthcare.ai <v2.0, along with any other libraries you need

# Your R code below...

```

Some deployment best practices for your R script (which will be inserted into SQL Server):

1. Use functions from packages, if possible. Long R scripts are extremely hard to debug
2. Switch to double quotes (`""`) instead of single quotes (`''`). *Why?*
  - Helps with insertion into database
  - Is [recommended](https://stackoverflow.com/a/20572492) by R community
  - *Note:* if you need single quotes, before inserting into EDWAdmin, escape them by [using two single quotes](https://stackoverflow.com/a/1586588), like (`''Bob''`)

Once modified, copy the example into the SQL template below, so it is stored _in_ the `ExternalRScript` field in ObjectAttributeBASE

1.  Seed following new destination entity attribute values into `EDWAdmin.CatalystAdmin.ObjectAttributeBASE` using the SQL template below. Be sure to adjust the values of the TableID ( = **Destination** Entity of R output).

    |             Column             |                                Value                                |
    | ------------------------------ | ------------------------------------------------------------------- |
    | **ExternalScriptType**         | `R`                                                                 |
    | **ExternalRScript**            | {entire contents of the R script example with only double quotes}   |
    | **RInterpreterPath**           | `C:\Program Files\R\R-3.X.X\Rscript.exe`                            |
   
```sql
INSERT INTO EDWAdmin.CatalystAdmin.ObjectAttributeBASE
    (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueTXT)
VALUES
    (<TableID>,'Table','RInterpreterPath','string','C:\Program Files\R\R-3.X.X\bin\Rscript.exe')
INSERT INTO EDWAdmin.CatalystAdmin.ObjectAttributeBASE
    (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueTXT)
VALUES
    (<TableID>,'Table','ExternalScriptType','string','R')
INSERT INTO EDWAdmin.CatalystAdmin.ObjectAttributeBASE
    (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueLongTXT)
VALUES
    (<TableID>,'Table','ExternalRScript','longstring','<ENTIRE_CONTENTS_OF_MODIFIED_EXAMPLE>')
```

Verify insertion using this SQL template (edit your `TableID`):

```sql
SELECT * FROM CatalystAdmin.ObjectAttributeBASE WHERE ObjectID = <TableID>
```

2.  Configure dependencies based on need. In SAMD, configure the dependencies for the extensibility. The SAMs are loaded serially. From the perspective of SAMD, the extensibility is just another SAM. It must be configured to run in the proper place in the chain. Particularly:
- Which table must finish loading before the R Script can run?
- Which table will the R script write to?
- Which table will begin loading after the R script is done writing to the database?

## Verify that your Extensibility point is working
1. If it doesn't harm ongoing ETL, in [EDW Console](http://127.0.0.1/Atlas) create a SAMD batch to run the binding that the R script depends on (and turn on diagnostic logging).
2. Run the batch
4. Verify that a log was created with output from the user script.
5. Delete the logs that were created.
6. At this point the underlying script and its associated environment and libraries have been verified. Proceed to the other notes below.

## Subject Area Mart (SAM) Configuration
Follow these steps in Subject Area Mart Designer (SAMD) to configure your SAM for typical predictive model extensibility, where SAMD is being used as part of the model deployment infrastructure:

1. Think of the R script as the SAM binding and the output table as the SAM entity. The _source_ entity for the extensibility point should be the entity that serves as the dataset the R scripts pulls from. The _destination_ entity for the extensibility point should be the entity that the R script populates/outputs to

2. Create a new binding in SAMD that will create the structure of the R destination entity/table. Here's a query that creates the schema, but doesn't populate the rows. Note the `1=0` is required because this destination table will be populated by R each day--not the SQL

  ```SQL
  SELECT 
  
   '' AS NationalIDNumber
   , 38.0 AS PredictedProbNBR
   , '' AS Factor1TXT --These are deprecated in healthcare.ai v2.0
   , '' AS Factor2TXT
   , '' AS Factor3TXT
   
  FROM SAM.HR.HRMLSummaryTable where 1=0
  ```
  
Relatedly, here's the bare minimum output schema when doing classification predictions:

|                Column               |                                          Type                                           |
| ----------------------------------------------------------- | ------------------------------------------------------- |
| **GrainID (could be PatientID or PatientEncounterID)** | `Same as in R input table`|
| **PredictedProbNBR **                                  | `decimal(38,2)`|

3. Since this set of instructions requires >= DOS 1.0 (or CAP 4.0), set the binding for the destination entity to `Incremental`

Note:

- This initial metadata entry is essential to being able to reference the R output table in other SAM bindings
- Create a binding (and entity) in the SAM to handle additional transformation of the model output, if desired
- This might include limiting predictions to the most recent predictions that we appended to the output table

## Fixing issues

At this point, when you run your SAM, your R script should run the model and append new rows to the destination table. If that doesn't happen, see these tips.

### Gotchas
- In the R script on Windows paths must use forward slashes `/` because R interprets backslashes as escape characters.
- In the R script there must be no single quotes. They must all be double `"` quotes. Single quotes are escaped in the SQL statement.

### Debugging tips (in order)

1. Make sure you turn on Diagnostic Logging in EDW Console and look for helpful messages in entries with `ExternalScriptExecution`, `Extension` and `OnPostStageToProdLoad`

2. Look in Integration Services Catalogs -> SSISDB -> Catalyst Extensibility and right click on the `ExternalScriptExecution` package and click on Reports -> ... Standard Executions

### Common issues

- When running a batch, if predictins aren't made and you see this error in EDW Console

  ```
  The SELECT permission was denied on the object 'operations', database 'SSISDB'
  ```
  
  Then, you must add a permission in SSMS by executing this query, **where edw_loader is changed to your specific loader account**:
  
  ```SQL
  USE SSISDB;
  GRANT SELECT ON internal.operations TO [HQCATALYST\edw_loader];
  GO
  ```
  
### Client Specific Oddities
- Ally Lina in Midwest
    - Using an old version of the extensibility where `RInterpreterPath` is a system-level variable with ID of 0.
- MCare in Pac N West
    - The folders were configured with the wrong names, "Extensions" instead of "Extensibility." SQL must be modified accordingly.
## TODO
- Get any insight into non-running SAMD. How do we get a smoke-signal out?
- figure out what that field format is
- run stored proc and find out what type it returns
- debug nodes
- check variables
- add breakpoint
- look at V1 loader

### Possibly Helpful Debugging C# That We May Resort To
```C#
try
{
    string dataProcessingServiceBaseUri = GetDataProcessingServiceBaseUri(discoveryServiceBaseUri);
    RewriteIncrementalQueries(dataProcessingServiceBaseUri, batchExecutionId);
    this.Dts.TaskResult = (int)ScriptResults.Success;
}
catch (Exception exception)
{
    string message =
        string.Format(
            "An error occurred while calling the DPS to rewrite the incremental queries: {0}",
            exception.Message);
    this.Dts.Events.FireError(0, "CallDPS", message, string.Empty, 0);
    this.Dts.TaskResult = (int)ScriptResults.Failure;
```