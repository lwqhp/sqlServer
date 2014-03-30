-- IP 地址转换为数字
CREATE FUNCTION dbo.f_IP2Int(
	@ip char(15)
)RETURNS bigint
AS
BEGIN
	DECLARE 
		@re bigint
	SET @re = 0
	SELECT
		@re = @re + LEFT(@ip, CHARINDEX('.', @ip + '.') - 1) * ID,
		@ip = STUFF(@ip, 1, CHARINDEX('.', @ip + '.'), '')
	FROM(
		SELECT ID = CAST(16777216 as bigint) UNION ALL
		SELECT 65536 UNION ALL 
		SELECT 256 UNION ALL
		SELECT 1
	)A
	ORDER BY ID DESC

	RETURN(@re)
END
GO

-- 数字转换为IP地址
CREATE FUNCTION dbo.f_Int2IP(
	@IP bigint
)RETURNS varchar(16)
AS
BEGIN
	DECLARE
		@re varchar(16)
	SET @re = ''
	SELECT
		@re = @re + '.' + CAST(@IP / ID as varchar),
		@IP = @IP % ID
	FROM(
		SELECT ID = CAST(16777216 as bigint) UNION ALL
		SELECT 65536 UNION ALL 
		SELECT 256 UNION ALL
		SELECT 1
	)A
	ORDER BY ID DESC

	RETURN(
		STUFF(@re, 1, 1, ''))
END
GO
