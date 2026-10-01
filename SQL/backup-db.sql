

DECLARE @databaseName AS NVARCHAR(100) 
DECLARE @backupPath AS NVARCHAR(100)

-- PARAMETERS --
SET @databaseName = 'TyDI'
SET @backupPath = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup'
-- PARAMETERS --

DECLARE @currentTimestamp AS NVARCHAR(30)
SET @currentTimestamp = (select convert(varchar(30), getdate(),112) + replace(convert(varchar(30), getdate(),108),':',''))
DECLARE @backupFullPath AS NVARCHAR(100)
SET @backupFullPath = @backupPath + '\' + @databaseName + '_07-12-2023.bak' 
DECLARE @backupName AS NVARCHAR(100)
SET @backupName = @databaseName + '_' + @currentTimestamp + ' Full Backup' 

PRINT 'Backing up to ' + @backupFullPath 

EXEC ('BACKUP DATABASE [' + @databaseName+'] TO DISK = '''+@backupFullPath+'''
WITH
    NOFORMAT,
    NOINIT,
    NAME = '''+@backupName+''',
    SKIP,
    NOREWIND,
    NOUNLOAD,
    STATS = 10;
')

