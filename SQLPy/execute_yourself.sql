-- Script to execute yourself the SQL Stored Procedures instead of using PowerShell. 

-- Pre-requisites: 
-- 1) The data should be already loaded with PowerShell (run Load_Data.ps1). 
-- 2) The stored procedures should be defined. Open the .sql files for steps 1,2,3 and run "Execute". 
-- 3) You should connect to the database in the SQL Server of the DSVM with:
-- Server Name: localhost
-- Integrated authentication is used

-- The default table names have been specified. You can modify them by changing the value of the parameters in what follows.

/* Set the working database to the one where you created the stored procedures */ 

--createlogin.sql missing, so wrote this for now.
--user needs read,write,ddladmin and access to execute external py scripts. see: readme.md
if not exists (select 1 from syslogins where name in ('NewsSQLPy','R90GTU6N\MSSQLSERVER01'))
begin
	create login NewsSQLPy with password =N'N3wsQLPy3-14', CHECK_EXPIRATION =off, CHECK_POLICY =off;
	alter server role sysadmin add member NewsSQLPy;
	create login [R90GTU6N\MSSQLSERVER01] from windows;
	alter server role sysadmin add member [R90GTU6N\MSSQLSERVER01];
end
go
--added to enable external scripts.
sp_configure 'external scripts enabled', 1;
RECONFIGURE WITH OVERRIDE;
go
sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
sp_configure 'max server memory', 2147483647;
GO  
RECONFIGURE WITH OVERRIDE;  
GO
/*
alter database NewsSQLPy set single_user with no_wait
drop database NewsSQLPy
*/

Use NewsSQLPy
GO

DROP PROCEDURE IF EXISTS [dbo].[newsgroups]
GO

CREATE PROCEDURE [newsgroups] @input varchar(max), @output varchar(max), @model_key varchar(max)

AS 
BEGIN

	/* Step 1: Feature Engineering and Training */
	exec [dbo].[train_model] @model_key = 'LR';
	
	/* Step 2: Scoring on the testing set */ 
	exec [dbo].[score] @input = 'News_Test', @output = 'Predictions', @model_key = 'LR'

	/* Step 3: Evaluating the model */
	exec [dbo].[evaluate] @predictions_table = 'Predictions', @model_key = 'LR'

	/* Score an additonal data set */
	exec [dbo].[score] @input = 'News_To_Score', @output = 'Predictions_New', @model_key = 'LR'
;
END
GO

