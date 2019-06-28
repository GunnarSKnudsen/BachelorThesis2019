IF OBJECT_ID('UDF_GenerateHASHforLargeValue') IS NULL
    EXEC('CREATE FUNCTION UDF_GenerateHASHforLargeValue () returns int as begin return 2 end;')
GO
ALTER FUNCTION [UDF_GenerateHASHforLargeValue](
      @Algorithm VARCHAR(128)
    , @TextValue NVARCHAR(MAX)
)
RETURNS VARBINARY(20)
AS
BEGIN
-- Created: 2017-07-14
-- Creator: Latheesh NK (https://sqlzealots.com/2017/07/14/hashbytes-for-a-large-string-in-sql-server/)
-- Modified by Gunnar Sjúrðarson Knudsen at 2019-06-18
-- Purpose: To circumvent the SQL-Servers limit of the function HASHBYTES on strings greater than 4000 characters.
-- Remarks:

      IF @TextValue = NULL
      BEGIN
         RETURN HASHBYTES(@Algorithm, 'NULL')
      END

      DECLARE @TextLength AS INTEGER
      DECLARE @BinaryValue AS VARBINARY(20)

      SET @TextLength = LEN(@TextValue)
      DECLARE @LenCount INT = 3500

      IF @TextLength > @LenCount
      BEGIN
            ;WITH cte 
            AS (
            SELECT  SUBSTRING(@TextValue,1, @LenCount) textval
                  , @LenCount+1 AS start
                  , @LenCount Level
                  , HASHBYTES(@Algorithm, SUBSTRING(@TextValue,1, @LenCount)) hashval
            UNION ALL 
            SELECT  SUBSTRING(@TextValue,start,Level)
                  , start+Level 
                  , @LenCount Level
                  , HASHBYTES(@Algorithm, SUBSTRING(@TextValue,start,Level) + CONVERT( varchar(20), hashval )) 
            FROM cte 
            WHERE 1=1
                  AND LEN(SUBSTRING(@TextValue,start,Level))>0
            ) 
            SELECT @BinaryValue = (SELECT TOP 1 hashval FROM cte ORDER BY start DESC)
            RETURN @BinaryValue
      END
      ELSE
      BEGIN
            SET @BinaryValue = HASHBYTES(@Algorithm, @TextValue)
            RETURN @BinaryValue
      END

      RETURN NULL
END
;
GO