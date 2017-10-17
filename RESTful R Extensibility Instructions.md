# Machine Learning :: RESTful R Extensibility Instructions

## Contents

- [Initial Steps](#initial-steps)
- [Repeatable Steps For Each Datamart](#repeatable-steps-for-each-datamart)
- [Repeatable Steps For Each Destination Entity](#repeatable-steps-for-each-destination-entity)
- [Seed Scripts Templates](#seed-scripts-templates)

This document instructs the user how to integrate their designated R/Python scripts, served from an external RESTful server, into the Catalyst loaders. It begins by installing the required SSIS package and defining new system level attributes. It continues by injecting the new SSIS package into the designated loader step. It concludes by defining the necessary variables for each destination entity.
 
## Initial Steps

1. Install ExternalScriptExtensibility ISPAC on ETL server
    a. Locate inside folder `\SSISDB\CatalsytExtensibility\`
    b. Verify permission to allow EDW loader account to read and execute
2. Seed new attribute names into EDWAdmin.CatalystAdmin.AttributeBASE
    – **fabric.machinelearning.server**
    – **fabric.machinelearning.sourceentity**
    – **fabric.machinelearning.bindingscript**

## Repeatable Steps For Each Datamart

Seed EDWAdmin.CatalystAdmin.ETLEngineConfigurationBASE

|                Column                |                                            Value                                             |
| ------------------------------------ | -------------------------------------------------------------------------------------------- |
| **ExtensionPointNM**                | `OnPostStageToProdLoad`                                                                      |
| **DatamartID**                      | {data mart ID}                                                                               |
| **SSISPackagePathOrSPToExecuteTXT** | `\SSISDB\CatalystExtensibility\ExternalScriptExtensibility\ExternalScriptExecutionREST.dtsx` |
| **IsSSISPackageFLG**                | `1`                                                                                            |
| **ExtensionOwnerNM**                | `Health Catalyst`                                                                            |
| **RunInAsyncModeFLG**               | `0`                                                                                            |
| **Use32BitRuntimeFLG**              | `0`                                                                                            |
| **ExecutionOrderNBR**               | `1`                                                                                            |
| **ActiveFLG**                       | `1`                                                                                            |
| **RequiredParametersTXT**           | `BatchID, TableID`                                                                       |
| **FailsBatchFLG**                   | `1`                                                                                            |

## Repeatable Steps For Each Destination Entity

1.  Seed new destination entity attribute values into EDWAdmin.CatalystAdmin.ObjectAttributeBASE

    |                  Column                  |                  Value                  |
    | ---------------------------------------- | --------------------------------------- |
    | **fabric.machinelearning.sourceentity**  | `SAM.Sample.SampleEntity`               |
    | **fabric.machinelearning.bindingscript** | `jobs/healthcareaitest.R`               |
    | **fabric.machinelearning.server**        | `http://datsci01.hqcatalyst.local:8080` |

2.  Configure dependencies based on need
 
## Seed Scripts Templates

### EDWAdmin.CatalystAdmin.AttributeBASE
```sql
IF NOT EXISTS
    (SELECT * FROM CatalystAdmin.AttributeBASE WHERE AttributeNM = 'fabric.machinelearning.server')
INSERT INTO CatalystAdmin.AttributeBASE
    (AttributeNM, AttributeDSC)
VALUES
    ('fabric.machinelearning.server','Path to remote machine learning server')

IF NOT EXISTS
    (SELECT * FROM CatalystAdmin.AttributeBASE WHERE AttributeNM = 'fabric.machinelearning.sourceentity')
INSERT INTO CatalystAdmin.AttributeBASE
    (AttributeNM, AttributeDSC)
VALUES
    ('fabric.machinelearning.sourceentity','Source entity from which to calculate predictions')

IF NOT EXISTS
    (SELECT * FROM CatalystAdmin.AttributeBASE WHERE AttributeNM = 'fabric.machinelearning.bindingscript')
INSERT INTO CatalystAdmin.AttributeBASE
    (AttributeNM, AttributeDSC)
VALUES
    ('fabric.machinelearning.bindingscript','HCRTools script that contains HC functions')
```

### EDWAdmin.CatalystAdmin.ETLEngineConfigurationBASE

```sql
INSERT INTO CatalystAdmin.ETLEngineConfigurationBASE
    (ExtensionPointNM, DatamartID, SSISPackagePathOrSPToExecuteTXT, IsSSISPackageFLG, ExtensionOwnerNM, RunInAsynchModeFLG, Use32BitRuntimeFLG, ExecutionOrderNBR, ActiveFLG, RequiredParametersTXT, FailsBatchFLG)
VALUES
    ('OnPostStageToProdLoad', [DataMartID], '\SSISDB\CatalystExtensibility\ExternalScriptExtensibility\ExternalScriptExecutionREST.dtsx', 1, 'Health Catalyst', 0, 0, 1, 1, 'BatchID, TableID', 1)
```

### EDWAdmin.CatalystAdmin.ObjectAttributeBASE

```sql
INSERT INTO CatalystAdmin.ObjectAttributeBASE
    (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueTXT)
VALUES
    ([TableID],'Table','fabric.machinelearning.server','string','[URI]')

INSERT INTO CatalystAdmin.ObjectAttributeBASE
    (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueTXT)
VALUES
    ([TableID],'Table','fabric.machinelearning.sourceentity','string', '[DatabaseNM.SchemaNM.ViewNM]')

INSERT INTO CatalystAdmin.ObjectAttributeBASE
    (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueTXT)
VALUES
    ([TableID],'Table','fabric.machinelearning.bindingscript','string', '[Script.R]')
```
