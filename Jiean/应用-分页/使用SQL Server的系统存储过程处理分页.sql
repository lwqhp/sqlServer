CREATE PROC dbo.sp_PageView   
	@sql         ntext,		-- Ҫִ�е�sql���
	@PageCurrent int = 1,	-- Ҫ��ʾ��ҳ��
	@PageSize    int = 10,	-- ÿҳ�Ĵ�С,
	@PageCount   int OUTPUT	-- ��ҳ��
AS
SET NOCOUNT ON
DECLARE
	@p1 int
-- ��ʼ����ҳ�α�
EXEC dbo.sp_cursoropen 
	@cursor = @p1 OUTPUT,
	@stmt = @sql,
	@scrollopt = 1,
	@ccopt = 1,
	@rowcount = @PageCount OUTPUT  -- ����������ؼ�¼��

-- ������ҳ��
IF ISNULL(@PageSize, 0) < 1 
	SET @PageSize = 10
SET @PageCount = (@PageCount + @PageSize - 1) / @PageSize

-- �����ҳ��ʾʱ�Ŀ�ʼ��¼��
IF ISNULL(@PageCurrent, 0) < 1 OR ISNULL(@PageCurrent, 0) > @PageCount
	SET @PageCurrent = 1
ELSE
	SET @PageCurrent = (@PageCurrent - 1) * @PageSize + 1

-- ��ʾָ��ҳ������
EXEC sp_cursorfetch @p1, 16, @PageCurrent, @PageSize

-- �رշ�ҳ�α�
EXEC sp_cursorclose @p1
GO
