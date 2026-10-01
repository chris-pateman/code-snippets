DECLARE @dbName AS NVARCHAR(20)
SET @dbName = 'TRON'


 DECLARE @kill varchar(8000) = '';  
SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), session_id) + ';'  
FROM sys.dm_exec_sessions
WHERE database_id  = db_id(@dbName)

EXEC(@kill);