
EXECUTE master.sys.sp_MSforeachdb 'USE [?]; 

  DECLARE @timeBackInMonths AS INT =  -2
  DECLARE @dbName AS NVARCHAR(50) = ''[?]''

  DECLARE @userUsage AS NVARCHAR(50) = 0
  SET @userUsage = (SELECT TOP 1 1 FROM  sys.dm_db_index_usage_stats WHERE database_id = DB_ID(@dbName) and last_user_update > DATEADD(month, @timeBackInMonths, GETDATE()) )
  IF @userUsage is null
  BEGIN
	SET @userUsage = 0
  END

  DECLARE @dbUsage AS NVARCHAR(50)
  SET @dbUsage = (SELECT TOP 1 1 FROM sys.objects WHERE modify_date > DATEADD(month, @timeBackInMonths, GETDATE()))
  IF @dbUsage is null
  BEGIN
	SET @dbUsage = 0
  END
  
   --PRINT '' ''
   --PRINT @dbName + '': ''
   --PRINT '' userUsage= '' + @userUsage
   --PRINT '' dbUsage= '' + @dbUsage
  IF @userUsage = 0 AND @dbUsage = 0
  BEGIN
	PRINT ''No usage has happened on '' + @dbName
    SELECT TOP 1 @dbName AS DbName, @userUsage AS UserUsage, @dbUsage AS DbUsage FROM sys.objects
  END

'
