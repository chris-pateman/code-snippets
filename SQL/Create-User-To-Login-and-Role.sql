

USE TyDI
GO

DECLARE @loginName AS VARCHAR(100)
SET @loginName = 'portal\TRS DEV_RT Consultants'
DECLARE @userName AS VARCHAR(100)
SET @userName = @loginName

DECLARE @roleName AS VARCHAR(100)
SET @roleName = 'TRSReporting'


IF NOT EXISTS(SELECT 1 FROM sys.database_principals WHERE name = @userName) 
    BEGIN
        -- Add User to Login
        PRINT 'Creating User ' + @userName + ' in login ' + @loginName + '.'
        
        DECLARE @CREATE_USER NVARCHAR(200)
        SET @CREATE_USER = ('CREATE USER [' + @userName + '] FOR LOGIN [' + @loginName + ']')
        EXEC (@CREATE_USER)
    END
ELSE
    BEGIN
        PRINT 'User ' + @userName + ' already exists skipping.'
    END

-- Add User to Role
PRINT 'Adding user ' + @userName + ' to role ' + @roleName + '.'

DECLARE @ALTER_ROLE NVARCHAR(200)
SET @ALTER_ROLE = ('ALTER ROLE ' + @roleName + ' ADD MEMBER [' + @userName + ']')
EXEC (@ALTER_ROLE)
