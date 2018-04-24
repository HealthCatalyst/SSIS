## Install and Configure R #

1. Install R to a local directory
2. Give EDW Loader account execute permissions on RScript.exe
3. Seed 3 attributes in CatalystAdmin.AttributeBASE
```sql
    IF NOT EXISTS (SELECT * FROM EDWAdmin.CatalystAdmin.AttributeBASE WHERE AttributeNM = 'RInterpreterPath')
    INSERT INTO EDWAdmin.CatalystAdmin.AttributeBASE (AttributeNM, AttributeDSC)
        VALUES ('RInterpreterPath','Local path to RScript.exe')

    IF NOT EXISTS (SELECT * FROM EDWAdmin.CatalystAdmin.AttributeBASE WHERE AttributeNM = 'ExternalScriptType')
    INSERT INTO EDWAdmin.CatalystAdmin.AttributeBASE (AttributeNM, AttributeDSC)
        VALUES ('ExternalScriptType','Python or R')

    IF NOT EXISTS (SELECT * FROM EDWAdmin.CatalystAdmin.AttributeBASE WHERE AttributeNM = 'ExternalRScript')
    INSERT INTO EDWAdmin.CatalystAdmin.AttributeBASE (AttributeNM, AttributeDSC)
        VALUES ('ExternalRScript','R script that contains functions')
    ```


## Installing the Extensibility Packages From an ISPAC File

The following steps are for the .ispac installation wizard.

1. [Download](https://github.com/HealthCatalyst/SSIS/blob/master/ExternalScriptExtensibility.ispac) and unzip the .ispac file
2. Select **Project Deployment File**
![](images/SSIS_installation/SSIS_installation_1_project_deploy.png)
3. Select the desired server
![](images/SSIS_installation/SSIS_installation_2_select_database_server.png)
4. Create the folder `CatalsytExtensibility` if it does not exist on the database server
![](images/SSIS_installation/SSIS_installation_3_locate_or_create_folder.png)
5. Deploy and ensure that all results passed.
![](images/SSIS_installation/SSIS_installation_4_passing_resutls.png)
6. Open SSMS and verify that these packages were installed:
![](images/SSIS_installation/SSIS_installation_5_verify_SSMS.png)


## Configure Data Mart for External Script Execution##
1. Add extensibility point to engine configuration
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


## Configure Binding for External Script Execution ##

1. Build SQL binding that SELECTs from any entities that your script depends on
2. Add "WHERE 1=2" to binding query
3. Add 3 attributes in CatalystAdmin.ObjectAttributeBASE
    ```sql
    INSERT INTO CatalystAdmin.ObjectAttributeBASE (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueTXT)
    VALUES (<TableID>,'Table','RInterpreterPath','string','C:\Program Files\R\R-3.X.X\bin\Rscript.exe')

    INSERT INTO CatalystAdmin.ObjectAttributeBASE (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueTXT)
    VALUES (<TableID>,'Table','ExternalScriptType','string','R')

    INSERT INTO CatalystAdmin.ObjectAttributeBASE (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueLongTXT)
    VALUES (<TableID>,'Table','ExternalRScript','longstring','<full R script>')
    ```
