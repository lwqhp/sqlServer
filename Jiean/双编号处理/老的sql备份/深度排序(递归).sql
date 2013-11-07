--测试数据
CREATE TABLE tb(
	ID char(3),
	PID char(3),
	Name nvarchar(10)
)
INSERT tb SELECT '001', NULL , N'山东省'
UNION ALL SELECT '002', '001', N'烟台市'
UNION ALL SELECT '004', '002', N'招远市'
UNION ALL SELECT '003', '001', N'青岛市'
UNION ALL SELECT '005', NULL , N'四会市'
UNION ALL SELECT '006', '005', N'清远市'
UNION ALL SELECT '007', '006', N'小分市'
GO

-- 深度搜索排序函数
CREATE FUNCTION dbo.f_Sort(
	@ID char(3) = NULL,  -- 父编码
	@sort int = 1        -- 顺序号
)RETURNS @t_Level TABLE(
		ID char(3),
		sort int)
AS
BEGIN
	DECLARE tb CURSOR LOCAL
	FOR
	SELECT ID FROM tb
	WHERE PID = @ID
		OR (@ID IS NULL AND PID IS NULL)
	OPEN TB
	FETCH tb INTO @ID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT @t_Level
		VALUES(
			@ID, @sort)

		SET @sort = @sort + 1

		IF @@NESTLEVEL < 32 -- 不处理超过 32 层递归的数据(递归最大允许32层)
		BEGIN
			-- 递归查找当前结点的子结点
			INSERT @t_Level
			SELECT * FROM dbo.f_Sort(@ID, @sort)

			SET @sort = @sort + @@ROWCOUNT  -- 排序号加上子结点个数
		END
		FETCH tb INTO @ID
	END
	RETURN
END
GO

--显示结果
SELECT 
	A.*
FROM tb A, dbo.f_Sort(DEFAULT, DEFAULT) B
WHERE A.ID = B.ID
ORDER BY B.sort
/*--结果
ID   PID  Name
---- ---- ----------
001  NULL 山东省
002  001  烟台市
004  002  招远市
003  001  青岛市
005  NULL 四会市
006  005  清远市
007  006  小分市
--*/
GO

-- 删除测试环境
DROP TABLE tb
DROP FUNCTION dbo.f_Sort