

DECLARE @sourceDatabaseName AS NVARCHAR(100) 
DECLARE @databaseName AS NVARCHAR(100) 
DECLARE @backupFullPath AS NVARCHAR(200)
DECLARE @sqlDataPath AS NVARCHAR(200) 
DECLARE @sqlLogPath AS NVARCHAR(200) 

-- PARAMETERS --
SET @sourceDatabaseName = 'TyDI'
SET @databaseName = 'TyDI_TEST'
SET @backupFullPath = 'C:\\Program Files\\Microsoft SQL Server\\MSSQL15.MSSQLSERVER\\MSSQL\\Backup\\' + @sourceDatabaseName + '_07-12-2023.bak'
SET @sqlDataPath = 'E:\\MSSQL\\Data'
SET @sqlLogPath = 'E:\\MSSQL\\Data'
-- PARAMETERS --

DECLARE @dataPath AS NVARCHAR(200) 
SET @dataPath = @sqlDataPath + '\' + @databaseName + '.mdf'
DECLARE @logPath AS NVARCHAR(200) 
SET @logPath = @sqlDataPath + '\' + @databaseName + '_log.ldf'

PRINT 'Restoring ' + @backupFullPath + ' to ' + @databaseName

EXEC ('RESTORE DATABASE ' + @databaseName + ' FROM DISK = ''' + @backupFullPath + ''' WITH 
MOVE ''' + @sourceDatabaseName + ''' TO ''' + @dataPath + ''',
MOVE ''' + @sourceDatabaseName + '_log'' TO ''' + @logPath + ''',
 REPLACE')

