
/*
�����������б�ʱ��ʹ���˽⡰FROM sysobjects a,sysobjects b��,�����Ҫ�������������ɶ�����¼�õģ�
�����sysobjectsΪ�������õ��ĸ������������������㹻��¼�ı�
ʹ�ø�����һ���Բ��������¼��������ʹ��ѭ��������������:SQl server��Ҫͨ����������֤����Ҫô�ɹ���Ҫôʧ��,
����ÿ��SQL��䣬sql ���Ὺ��һ���ڲ����񣨶��û����ɼ�����������sql�Ĵ����У�ͬ���Ĵ�����������е����Խ�٣�
һ��Ҳ����ζ�Ŵ���Ч�ʿ���Խ��.
*/

--syscolumns ��ʹ��
CREATE TABLE #t(col int)
DECLARE @i int,@dt datetime
SELECT @i=0,@dt=getdate()
WHILE @i<1000
BEGIN
	INSERT #t VALUES(0)
	SET @i = @i+1
END
SELECT datediff(ms,@dt,getdate())
DROP TABLE #t

CREATE TABLE #t(col int)
DECLARE @dt datetime
SET @dt = getdate()
INSERT #t 
SELECT TOP 1000 0 FROM syscolumns s,syscolumns b 
SELECT datediff(ms,@dt,getdate())
DROP TABLE #t


--�����ڸ�ʽ�ַ����ֶ�

cast(date_start +'00:00:00' AS datetime) <= '2009-09-09 9:9:9'
AND cast(date_end +'23:59:59' AS datetime) >= '2009-9-09 9:9:9'

