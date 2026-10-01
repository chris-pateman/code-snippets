DECLARE @dbName AS NVARCHAR(20)
SET @dbName = 'TRON'
IF EXISTS (
        SELECT request_session_id
        FROM sys.dm_tran_locks
        WHERE resource_database_id = DB_ID(@dbName)
        )
BEGIN
    PRINT @dbName + ' Database in use!!'
    SELECT *
    FROM sys.dm_exec_sessions
    WHERE session_id IN (
            SELECT request_session_id
            FROM sys.dm_tran_locks
            WHERE resource_database_id = DB_ID(@dbName)
            )
END
ELSE
    PRINT @dbName + ' Database not in used.'