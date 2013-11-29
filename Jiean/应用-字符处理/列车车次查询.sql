-- ���ĳ�������Ƿ���ָ�����ַ�����(�ַ����а���������Ϣ)
CREATE FUNCTION dbo.f_CompSTR(
	@str  varchar(8000),  --�������ε��ַ���
	@find varchar(50)     --Ҫ��ѯ��ֵ
)RETURNS bit
AS
BEGIN
	-- ��ȫƥ���ֱ�ӷ���
	IF @str = @find
		RETURN(1)

	-- �����ѯ�����ݳ��ȴ��ڱ���ѯ���ݵĳ���, ֱ�ӷ���
	IF LEN(@str) < LEN(@find)
		RETURN(0)

	-- �滻�������ַ����е���Ч����
	SELECT 
		@str = REPLACE(@str, a, b)
	FROM(
		-- ����Ӳ�ѯ�г���������Ч���ַ�����, ÿ���ַ�����һ����¼, ���Ը���ʵ����������
		SELECT a = '"', b = ''
	)A

	-- ͳһ���ݷָ���
	SELECT
		@str = REPLACE(@str, a, b)
	FROM(
		-- ����Ӳ�ѯ�г������п��ܳ��������ݷָ���, ��ͳһ�滻Ϊ\
		SELECT a = '(',  b='\' UNION ALL
		SELECT a = ')',  b='\' UNION ALL
		SELECT a = '��', b='\' UNION ALL
		SELECT a = '��', b='\' UNION ALL
		SELECT a = ' ',  b='\' UNION ALL
		SELECT a = '��', b='\' UNION ALL
		SELECT a = '.',  b='\' UNION ALL
		SELECT a = '��', b='\'
	)A

	--�ֲ�Ƚϴ���
	DECLARE 
		@s1 varchar(8000),
		@h varchar(100),
		@s varchar(100),
		@l int
	WHILE @str > ''
	BEGIN
		SELECT
			-- �ַ����еĵ�һ��������
			@s1 = LEFT(@str, CHARINDEX('\', @str + '\') - 1),
			-- ���ַ�����ȥ����һ��������(��Ϊ��ǰѭ���ᴦ�����������)
			@str = STUFF(@str, 1, CHARINDEX('\', @str + '\'), ''),
			-- �������еĵ�һ������(������Ϊ����������ٴβ��)
			@h = LEFT(@s1, CHARINDEX('/', @s1 + '/') - 1),
			-- ��һ�����εĳ���
			@l = LEN(@h) + 1

		-- �����һ�����ξ���Ҫ���ҵ�����, ���˳�
		IF @h = @find
			RETURN(1)

		-- ����������е�ÿ������
		WHILE CHARINDEX('/', @s1 + '/') > 0
		BEGIN
			SELECT 
				-- ȡ�������еĵ�һ������
				@s = LEFT(@s1, CHARINDEX('/', @s1 + '/') - 1),
				-- �����������Ƴ���һ������(��Ϊ��ǰѭ���лᴦ���������)
				@s1 = STUFF(@s1, 1, CHARINDEX('/', @s1 + '/'), '')

			-- ����Ƿ������ĳ�����Ϣ, �������, ���䲹������(���ݵ�һ�����ε���Ϣ)
			IF LEN(@s) < @l
				SET @s = STUFF(@h, @l - LEN(@s), 8000, @s)
			-- ȷ���Ƿ�Ҫ�ҵĳ���, �����, �򷵻ز��ҽ��
			IF @find = @s
				RETURN(1)	
		END
	END
	RETURN(0)
END
GO

-- ʹ��ʾ��
-- ������Ϣ��¼��
DECLARE @t TABLE(
	col varchar(100))
INSERT @t SELECT '1434/1/2/14'
UNION ALL SELECT '"10653(85707)"'
UNION ALL SELECT '"32608/7(83212/1)"'
UNION ALL SELECT '"50057��)"'
UNION ALL SELECT '"T888������"'
UNION ALL SELECT '"21058(81404/3)0"'
UNION ALL SELECT '"22028(80404.10264)"'
UNION ALL SELECT '20037(80303.84006/9)'
UNION ALL SELECT '24031(80410/9'
UNION ALL SELECT '24048(80904)(23118)'
UNION ALL SELECT '22080(80406.83080.10284)'
UNION ALL SELECT '0031(5632  5629. 1434/1/2/14)'

--��������������ѯ��������1434�ļ�¼
SELECT * FROM @t 
WHERE dbo. f_CompSTR(col,'1432') = 1
GO

-- ɾ�����Ի���
DROP FUNCTION dbo.f_CompSTR
