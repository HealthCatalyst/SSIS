IF NOT EXISTS (SELECT * FROM CatalystAdmin.AttributeBASE WHERE AttributeNM = 'ExternalScriptType')
	INSERT INTO CatalystAdmin.AttributeBASE (AttributeNM, AttributeDSC) VALUES ('ExternalScriptType','Python or R')

IF NOT EXISTS (SELECT * FROM CatalystAdmin.AttributeBASE WHERE AttributeNM = 'ExternalScriptFunction')
	INSERT INTO CatalystAdmin.AttributeBASE (AttributeNM, AttributeDSC) VALUES ('ExternalScriptFunction','Function contained within Python or R script, like FindTrends')

IF NOT EXISTS (SELECT * FROM CatalystAdmin.AttributeBASE WHERE AttributeNM = 'RInterpreterPath')
	INSERT INTO CatalystAdmin.AttributeBASE (AttributeNM, AttributeDSC) VALUES ('RInterpreterPath','Local path to RScript.exe')

IF NOT EXISTS (SELECT * FROM CatalystAdmin.AttributeBASE WHERE AttributeNM = 'PythonInterpreterPath')
	INSERT INTO CatalystAdmin.AttributeBASE (AttributeNM, AttributeDSC) VALUES ('PythonInterpreterPath','Local path to Python interpreter')

IF NOT EXISTS (SELECT * FROM CatalystAdmin.AttributeBASE WHERE AttributeNM = 'ExternalRScript')
	INSERT INTO CatalystAdmin.AttributeBASE (AttributeNM, AttributeDSC) VALUES ('ExternalRScript','HCRTools script that contains HC functions')

IF NOT EXISTS (SELECT * FROM CatalystAdmin.AttributeBASE WHERE AttributeNM = 'ExternalScriptArguments')
	INSERT INTO CatalystAdmin.AttributeBASE (AttributeNM, AttributeDSC) VALUES ('ExternalScriptArguments','HCPythonTools script that contains HC functions')

IF NOT EXISTS (SELECT * FROM CatalystAdmin.AttributeBASE WHERE AttributeNM = 'ExternalScriptSourceEntity')
	INSERT INTO CatalystAdmin.AttributeBASE (AttributeNM, AttributeDSC) VALUES ('ExternalScriptSourceEntity','Source entity from which to calculate predictions')