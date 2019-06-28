IF OBJECT_ID('UDF_ModularExponentiation') IS NULL
    EXEC('CREATE function UDF_ModularExponentiation AS SET NOCOUNT ON;')
GO

ALTER FUNCTION UDF_ModularExponentiation(
  @base     INT
, @exponent INT
, @mod      INT
)
RETURNS INT
AS
BEGIN
-- Created: 2019-06-21
-- Creator: Gunnar Sjúrðarson Knudsen
-- Purpose: calculate a^b mod p, by using the identity "(a*b)%p = ((a % p) * (b % p)) % p"
-- Remarks:
--       2019-06-28: Can be greatly optimized by using algorithm for Exponentiation by squaring (https://en.m.wikipedia.org/wiki/Exponentiation_by_squaring)
--                   Would reduce complexity from O(n) to floor(log(N)).
--                   However, for proof of concept, this implementation will suffice.
      DECLARE @tempRes INT = @base;

      DECLARE @counter INT = 1
      WHILE @counter < @exponent
      BEGIN
            SET @tempRes = ((@tempRes % @mod) * (@base % @mod)) % @mod;
            SET @Counter = @counter + 1;
      END

      RETURN @tempRes
END
GO

-- Test function:
SELECT  dbo.UDF_ModularExponentiation(9,121,1001)