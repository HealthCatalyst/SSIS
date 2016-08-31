/** Sample inserts for an Python script implementation **/

INSERT INTO CatalystAdmin.ObjectAttributeBASE (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueTXT)
	VALUES (0,'System','PythonInterpreterPath','string','C:\python35')

INSERT INTO CatalystAdmin.ObjectAttributeBASE (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueLongTXT)
	VALUES (0,'System','ExternalPythonScript','string','{lengthy HCPythonTools script}')

/** Sample inserts for an R script implementation **/

INSERT INTO CatalystAdmin.ObjectAttributeBASE (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueTXT)
	VALUES (0,'System','RInterpreterPath','string','C:\Program Files\R\R-3.3.1\bin\Rscript.exe')

INSERT INTO CatalystAdmin.ObjectAttributeBASE (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueLongTXT)
	VALUES (0,'System','ExternalRScript','string','{lengthy HCRTools script}')

/** Sample inserts for a destination entity with a table ID of 3 with a source of SAM.Sample.SampleSAMSampleBindingBASE with an R function**/

INSERT INTO CatalystAdmin.ObjectAttributeBASE (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueTXT)
	VALUES (3,'Table','ExternalScriptType','string','R')

INSERT INTO CatalystAdmin.ObjectAttributeBASE (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueTXT)
	VALUES (3,'Table','ExternalScriptSourceEntity','string','SAM.Sample.SampleSAMSampleBindingBASE')

INSERT INTO CatalystAdmin.ObjectAttributeBASE (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueTXT)
	VALUES (3,'Table','ExternalScriptFunction','string','FindTrends')

INSERT INTO CatalystAdmin.ObjectAttributeBASE (ObjectID,ObjectTypeCD,AttributeNM,AttributeTypeCD,AttributeValueTXT)
	VALUES (3,'Table','ExternalScriptArguments','string','"z2" "z3"')