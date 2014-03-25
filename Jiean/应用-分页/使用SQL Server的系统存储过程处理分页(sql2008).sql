CREATE PROC dbo.sp_PageView   
	@sql         ntext,		-- 要执行的sql语句
	@PageCurrent int = 1,	-- 要显示的页码
	@PageSize    int = 10,	-- 每页的大小,
	@PageCount   int OUTPUT	-- 总页数
AS
SET NOCOUNT ON
DECLARE
	@p1 int
-- 初始化分页游标
EXEC dbo.sp_cursoropen 
	@cursor = @p1 OUTPUT,
	@stmt = @sql,
	@scrollopt = 1,
	@ccopt = 1,
	@rowcount = @PageCount OUTPUT  -- 这个参数返回记录数

-- 计算总页数
IF ISNULL(@PageSize, 0) < 1 
	SET @PageSize = 10
SET @PageCount = (@PageCount + @PageSize - 1) / @PageSize

-- 计算分页显示时的开始记录数
IF ISNULL(@PageCurrent, 0) < 1 OR ISNULL(@PageCurrent, 0) > @PageCount
	SET @PageCurrent = 1
ELSE
	SET @PageCurrent = (@PageCurrent - 1) * @PageSize + 1

-- 显示指定页的数据
EXEC sp_cursorfetch @p1, 16, @PageCurrent, @PageSize

-- 关闭分页游标
EXEC sp_cursorclose @p1
GO
