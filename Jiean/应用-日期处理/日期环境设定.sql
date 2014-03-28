

--��2�����ڻ����趨

--SQL SERVER ���ԣ�ȷ����һ�����ڽ��ͷ���
SELECT * FROM sys.syslanguages

-->A.����Ĭ������
USE master
EXEC sp_configure 'default language',[langid]
RECONFIGURE WITH override


--���κ�Ӧ�ó�������ʱ�����趨
SET LANGUAGE

/*----------------------------����---------------------------*/

		--���ûỰ�����Ի���Ϊ: English
		SET LANGUAGE N'English'
		SELECT 
			DATENAME(Month,GETDATE()) AS [Month],
			DATENAME(Weekday,GETDATE()) AS [Weekday],
			CONVERT(varchar,GETDATE(),109) AS [CONVERT]
		/*--���:
		Month    Weekday   CONVERT
		------------- -------------- -------------------------------
		March    Tuesday   Mar 15 2005  8:59PM
		--*/

		--���ûỰ�����Ի���Ϊ: ��������
		SET LANGUAGE N'��������'
		SELECT 
			DATENAME(Month,GETDATE()) AS [Month],
			DATENAME(Weekday,GETDATE()) AS [Weekday],
			CONVERT(varchar,GETDATE(),109) AS [CONVERT]
		/*--���
		Month    Weekday    CONVERT
		------------- --------------- -----------------------------------------
		05       ������     05 19 2005  2:49:20:607PM
		--*/
		
-->B.����������ʾ˳��

SET dateFormat --�����ڽ��ַ���ת��Ϊ����ֵʱ���ã���������ֵ����ʾû��Ӱ��

/*----------------------------����---------------------------*/

		--ʾ�� ���������ʾ���У���һ��CONVERTת��δָ��style��ת���Ľ����SET DATAFORMAT��Ӱ�죬�ڶ���CONVERTת��ָ����style��ת�������style��Ӱ�졣
		--������������˳��Ϊ ��/��/��
		SET DATEFORMAT DMY

		--��ָ��Style������CONVERTת�����ܵ�SET DATEFORMAT��Ӱ��
		SELECT CONVERT(datetime,'2-1-2012')
		--���: 2012-01-02 00:00:00.000

		--ָ��Style������CONVERTת������SET DATEFORMAT��Ӱ��
		SELECT CONVERT(datetime,'2-1-2012',101)
		--���: 2012-02-01 00:00:00.000
		GO

		--2.
		/*--˵��

			�����������ڰ��������Ͳ��֣�������ڽ��н��ʹ���ʱ
			��ݵĽ��Ͳ���SET DATEFORMAT���õ�Ӱ�졣
		--*/

		--ʾ����������Ĵ����У�ͬ����SET DATEFORMAT���ã��������ڵ����Ͳ����벻�������ڵ����Ͳ��֣����͵����ڽ����ͬ��
		DECLARE @dt datetime

		--����SET DATEFORMATΪ:������
		SET DATEFORMAT MDY

		--�����������ָ�����Ͳ���
		SET @dt='01-2012-03'
		SELECT @dt
		--���: 2012-01-03 00:00:00.000

		--����������в�ָ�����Ͳ���
		SET @dt='01-02-12'
		SELECT @dt
		--���: 2012-01-02 00:00:00.000
		GO

		--3.
		/*--˵��

			�����������ڲ��������ڷָ�������ôSQL Server�ڶ����ڽ��н���ʱ
			������SET DATEFORMAT�����á�
		--*/

		--ʾ����������Ĵ����У����������ڷָ������ַ����ڣ��ڲ�ͬ��SET DATEFORMAT�����£�����͵Ľ����һ���ġ�
		DECLARE @dt datetime

		--����SET DATEFORMATΪ:������
		SET DATEFORMAT MDY
		SET @dt='010203'
		SELECT @dt
		--���: 2001-02-03 00:00:00.000

		--����SET DATEFORMATΪ:������
		SET DATEFORMAT DMY
		SET @dt='010203'
		SELECT @dt
		--���: 2001-02-03 00:00:00.000

		--����������а������ڷָ���
		SET @dt='01-02-03'
		SELECT @dt
		--���: 2003-02-01 00:00:00.000
		
-->C.����һ�ܵĵ�һ�������ڼ�

set dateFirst 7-- �������û���Ч�������ٴ��޸ģ���������ý�һֱ����

select @@DateFirst

Set DateFirst {number}--1��ʾ����һ��7��ʾ������
