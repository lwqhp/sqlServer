IF OBJECT_ID(N'dbo.p_show') IS NOT NULL
	DROP PROCEDURE dbo.p_show
GO

/*--ʵ�ַ�ҳ��ͨ�ô洢����

	��ʾָ������ͼ����ѯ����ĵ�Xҳ
	���ڱ����������ʶ�е����,ֱ�Ӵ�ԭ��ȡ����ѯ���������ʹ����ʱ��ķ���
	�����ͼ���ѯ�����������,���Ƽ��˷���
	���ʹ�ò�ѯ���,���Ҳ�ѯ���ʹ����order by,���ѯ���������top ���

--*/

/*--����ʾ��
EXEC dbo.p_show 
	@QueryStr = N'tb',
	@PageSize = 5,
	@PageCurrent = 3,
	@FdShow = 'id, colid, name',
	@FdOrder = 'colid, name'
select id, colid from tb
order by colid, name


EXEC dbo.p_show 
	@QueryStr = N'
SELECT TOP 100 PERCENT 
	* 
FROM dbo.sysobjects
ORDER BY xtype',
	@PageSize = 5,
	@PageCurrent = 2,
	@FdShow = 'name, xtype',
	@FdOrder = 'xtype, name'
--*/
CREATE PROC dbo.p_show
	@QueryStr nvarchar(4000),		-- ��������ͼ������ѯ���
	@PageSize int = 10,				-- ÿҳ�Ĵ�С(����)
	@PageCurrent int = 1,			-- Ҫ��ʾ��ҳ
	@FdShow nvarchar (4000) = N'',	-- Ҫ��ʾ���ֶ��б�,�����ѯ�������Ҫ��ʶ�ֶ�,��Ҫָ����ֵ,�Ҳ�������ʶ�ֶ�
	@FdOrder nvarchar (1000) = N''	-- �����ֶ��б�
AS
SET NOCOUNT ON
-- 1. ��������
-- 1.a ��������
DECLARE
	@Obj_ID int,		-- ����ID
	@Id1 sysname,		-- ��ҳ��¼(����ʹ����ʱ��ķ�ҳ����, ��Ϊ��ʱ��ļ�¼ ID)
	@Id2 sysname

-- 1.b ���ڱ����е�����(��Ψһ��), ������ʱ��(������Դ�ڲ�ѯ���)
DECLARE
	@FdName sysname 	-- ���е���������ʱ���еı�ʶ����

-- 1.b �����и��������Ĵ���
DECLARE
	@strfd nvarchar(2000),		-- ���������б�
	@strjoin nvarchar(4000),	-- JOIN ��������
	@strwhere nvarchar(2000)	-- ��ѯ����

-- 2. �������
SELECT
	@Obj_ID = OBJECT_ID(@QueryStr),  -- ��ȡ object id, �����Դ�ȷ��������Դ�ڲ�ѯ��仹�����ݿ��еĶ���
	@FdShow = CASE 
					WHEN @FdShow > N'' THEN N' ' + @FdShow
					ELSE N' *'
				END,
	@FdOrder = CASE
					WHEN @FdOrder > N'' THEN N' ORDER BY ' + @FdOrder
					ELSE N' ' 
				END,
	@QueryStr = CASE  -- ���������Դ�ڲ�ѯ���, ���װ�Ӳ�ѯ
					WHEN @Obj_ID IS NULL THEN N' (' + @QueryStr + N')A'
					ELSE N' ' + @QueryStr
				END

-- 3. ��ҳ����
-- a. �����ʾ��һҳ������ֱ���� top �����
IF @PageCurrent = 1	
BEGIN
	SELECT 
		@Id1 = CAST(@PageSize as varchar(20))
	EXEC(N'
SELECT TOP ' + @Id1 + N'
	' + @FdShow + N'
FROM ' + @QueryStr + N'
' + @FdOrder
)
	RETURN
END

-- b. ȷ��������Դȷ��������
--    ���������Դ���Ǳ�, ��ʹ����ʱ��Ĵ�����
IF @Obj_ID IS NULL OR OBJECTPROPERTY(@Obj_ID, 'IsTable') = 0
	GOTO lb_usetemp
ELSE
BEGIN
-- ���������Դ�Ǳ�, ��������Ƿ��м�¼��λ����(�������߱�ʶ��)
	-- ��ҳ��¼
	SELECT
		@Id1 = CAST(@PageSize as varchar(20)),
		@Id2 = CAST((@PageCurrent - 1) * @PageSize as varchar(20))

	-- ����ʶ��
	SELECT
		@FdName = name
	FROM dbo.syscolumns
	WHERE id = @Obj_ID
		AND status = 0x80
	IF @@ROWCOUNT = 0 -- ��������ޱ�ʶ��,��������Ƿ�������
	BEGIN
		DECLARE
			@pk_number int

		SELECT
			@strfd = N'',
			@strjoin = N'',
			@strwhere = N''

		-- �������
		SELECT
			-- �����б�
			@strfd = @strfd 
					+ N',' + QUOTENAME(name),
			-- ���� JOIN ����
			@strjoin = @strjoin 
					+ N' AND A.' + QUOTENAME(name) 
					+ N' = B.' +  QUOTENAME(name),
			-- ������������
			@strwhere = @strwhere 
					+ N' AND B.' + QUOTENAME(name) + N' IS NULL'
		FROM(
			SELECT
				IX.id, IX.indid,
				IXC.colid, ixc.keyno,
				C.name
			FROM dbo.sysobjects O, 
				dbo.sysindexes IX,
				dbo.sysindexkeys IXC,
				dbo.syscolumns C
			WHERE O.parent_obj = @Obj_ID
				AND O.xtype = 'PK'
				AND O.name = IX.name
				AND IX.id = @Obj_ID
				AND IX.id = IXC.id
				AND IX.indid = IXC.indid
				AND IXC.id = C.id
				AND IXC.colid = C.colid
		)A
		ORDER BY keyno

		SELECT
			@pk_number = @@ROWCOUNT,			
			@strfd = STUFF(@strfd, 1, 1, N''),
			@strjoin = STUFF(@strjoin, 1, 5, N''),
			@strwhere = STUFF(@strwhere, 1, 5, N'')			

		-- ȷ���Ƿ�������, �����ǵ�һ��, ���Ǹ��ϵ�, ������Ӧ�Ĵ���
		IF @pk_number = 0
			GOTO lb_usetemp		--�������������,������ʱ����
		ELSE IF @pk_number = 1
		BEGIN
			SELECT
				@FdName = @strfd
			GOTO lb_useidentity	-- ʹ�õ�һ����
		END
		ELSE
			GOTO lb_usepk		-- ʹ�ø�������
	END
END

/*-- ʹ�ñ�ʶ�л�����Ϊ��һ�ֶεĴ����� --*/
lb_useidentity:	
EXEC(N'
SELECT TOP ' + @Id1 + N'
	' + @FdShow + N'
FROM '+@QueryStr + N'
WHERE ' + @FdName + ' NOT IN(
		SELECT TOP ' + @Id2 + N'
			' + @FdName + '
		FROM ' + @QueryStr + N'
		' + @FdOrder + N')
' + @FdOrder + N'
')
RETURN

/*-- �����и��������Ĵ����� --*/
lb_usepk:		
EXEC(N'
SELECT 
	' + @FdShow + N'
FROM(
	SELECT TOP ' + @Id1 + N'
		A.*
	FROM ' + @QueryStr + N' A
		LEFT JOIN(
				SELECT TOP ' + @Id2 + N'
					' + @strfd + N' 
				FROM ' + @QueryStr + N'
				' + @FdOrder + N'
			)B
				ON ' + @strjoin + N'
	WHERE ' + @strwhere + N'
	' + @FdOrder + N'
)A
' + @FdOrder + N'
')
RETURN

/*-- ����ʱ����ķ��� --*/
lb_usetemp:		
SELECT
	-- ���ӵı�ʶ����(���ڶ�λ��¼)
	@FdName = QUOTENAME(N'ID_' + CAST(NEWID() as varchar(40))),
	@Id1 = CAST(@PageSize * (@PageCurrent-1) as varchar(20)),
	@Id2 = CAST(@PageSize * @PageCurrent-1 as varchar(20))

EXEC(N'
SELECT 
	' + @FdName + N' = IDENTITY(int, 0, 1),
	' + @FdShow + N'
INTO #tb
FROM(
	SELECT TOP 100 PERCENT 
		* 
	FROM ' + @QueryStr + N'
	' + @FdOrder + N'
)A
' + @FdOrder + N'

SELECT 
	' + @FdShow + N'
FROM #tb 
WHERE ' + @FdName + ' BETWEEN ' + @Id1 + ' AND ' + @Id2 + N'
'
)
GO
