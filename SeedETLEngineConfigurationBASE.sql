INSERT INTO CatalystAdmin.ETLEngineConfigurationBASE (ExtensionPointNM, DatamartID, SSISPackagePathOrSPToExecuteTXT, IsSSISPackageFLG, ExtensionOwnerNM, RunInAsynchModeFLG, Use32BitRuntimeFLG, ExecutionOrderNBR, ActiveFLG, RequiredParametersTXT, FailsBatchFLG)
VALUES ('OnPostStageToProdLoad',{SAM datamart ID},'\SSISDB\CatalystExtensibility\ExternalScriptExtensibility\ExternalScriptExecution.dtsx',1,'Health Catalyst',1,0,1,1,'BatchID, TableID',1)
