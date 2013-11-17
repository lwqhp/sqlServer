

--�������͵���ʽת��

/*
�������͵����ȼ���
	�����ȼ��ϵ͵��������������ȼ��ϸߵ���������ת����

			real -> xml -> sql_variant -> user-defined data types (highest)

   �������ͣ� time -> date -> smalldatetime -> datetime -> datetime2 -> datetimeoffset 

   ��ֵ���ͣ� bit -> tinyint -> smallint -> int -> bigint -> smallmoney -> money -> decimal -> float

   ���������ͣ� image -> text -> ntext

   ������ͣ�	uniqueidentifier -> timestamp
	
   �ַ����ͣ�  char -> varchar (including varchar(max) ) -> nchar -> nvarchar (including nvarchar(max) )

   �����������ͣ� binary (lowest) -> varbinary (including varbinary(max) )


��ҵ��
1����Ǹ��������͵����ȼ�
2,��ϰ�Ӹ������ͺ�ͬ���͵�����ת��

*/


/*
��SQL����������ֳ�����Ҫ������������ת��:

1)set select�Ӿ�  ��������ֵ��д����С�
2)where �����Ӿ�  �������߱��ʽ�ıȽ�

��ͬ����������֮���ת�����ܻ����һЩ�������

a,�����������Ͳ����ݣ������޷�ת����
b,�����������ͼ��ݣ�����Ҫ��ʽ��ת��
c,����ת������ת�����ܻ��������ת����ת��ʧ�ܡ�

��ҵ��
1������ת���ڲ�ͬ�Ӿ��е�����
2������ת���ļ�����
*/
--���Ͳ�����
DECLARE   @a INT
DECLARE   @b DATE
SET           @a = @b

--��ʽת���Բ�����������Ч
DECLARE @a INT
DECLARE @b DATE
SET @a = CONVERT(INT,@b)

--�������ͣ�����Ҫ��ʽת��
DECLARE @a INT
DECLARE @b DATETIME
SET @a = @b 

DECLARE @a INT
DECLARE @b DATETIME
SET @a = CONVERT (INT ,@b)



--ת������
/*
1���� ��ֵ��д���Ӿ��У���ȷ���ұ߱��ʽת������߱��ʽ����������
2) �������Ӿ��У�Ĭ�ϰ������������ȼ��ӵ����ת��������ͬ����������֮��ת��ʱ�����ܻ��������ת����ת��ʧ��

����ʽ�ĸ����ȼ�����ųƼ�����ת������������ݱ��ضϣ�����ת��ʧ�ܡ������ص�˵���²�ͬ���ͼ����ʽת����

a)�����ͺ͸������ͱȽ�ʱ���򸡵�����ת�����ܻ��������ת��
b)���ַ�����ֵ���ͱȽ�ʱ������ֵ����ת�����ܻ����ת��ʧ��
*/

--����д��
DECLARE @a INT
DECLARE @b DATETIME
SET CONVERT(DATETIME,@a) = @b

SET STATISTICS PROFILE ON  

--�������������ȼ���@aת����������
DECLARE @a INT
DECLARE @b DATETIME
SELECT 0 WHERE @a = @b

  |--Compute Scalar(DEFINE:([Expr1000]=(0)))
       |--Filter(WHERE:(STARTUP EXPR(CONVERT_IMPLICIT(datetime,[@a],0)=[@b])))
            |--Constant Scan


--���ͺ͸������͵�ת�����ܻ��������ת��
DECLARE @a INT
DECLARE @b REAL
DECLARE @c INT
SET @a = 1000000001
SET @b = CONVERT(REAL,@a)
SET @c = CONVERT(INT,@b)
SELECT @a AS 'INT', @b AS 'REAL', @c AS 'INT'


-- �����ȼ�������ȼ�����ת�������ܻ����ת��ʧ��
DECLARE @a REAL
DECLARE @b INT
SET @a = 1e13
SET @b = CONVERT(INT,@a)


--�ַ�����������ȼ�����ת�������п��ܳ��ֲ�ȷ�����������ת��ʧ�ܡ�
DECLARE @a INT
DECLARE @b CHAR(4)
SET @a = 1SET @b = @a
SELECT @a AS a, @b AS b,
    CASE WHEN   @a = '1 '  THEN 'True' ELSE 'False' END AS [a = '1'],
    CASE WHEN   @a = '+1' THEN 'True' ELSE 'False' END AS [a = '+1'],
    CASE WHEN   @b = '1'   THEN 'True' ELSE 'False' END AS [b = '1'],
    CASE WHEN   @b = '+1' THEN 'True' ELSE 'False' END AS [b = '+1']
    
--��Unicode��Unicode���ͱȽϣ�����ʽ�ѷ�Unicode������ȼ�Unicode����ת��
DECLARE @a VARCHAR(20)
SELECT 0 WHERE @a = N'a'   
 
  |--Compute Scalar(DEFINE:([Expr1000]=(0)))
       |--Filter(WHERE:(STARTUP EXPR(CONVERT_IMPLICIT(nvarchar(20),[@a],0)=N'a')))
            |--Constant Scan

--���Ͳ���ͬ�ļ�¼����,����ʽ����������ת��Ŀ�������
create table #tmp(cardid varchar(30),cardcode nvarchar(80))
create table #tmp2(cardid varchar(30),cardcode varchar(80))
insert into #tmp2
select * from #tmp
|--Compute Scalar(DEFINE:([Expr1008]=CONVERT_IMPLICIT(varchar(80),[tempdb].[dbo].[#tmp].[cardcode],0)))
    |--Table Scan(OBJECT:([tempdb].[dbo].[#tmp]))
    
    
---------------------------------------------
/*
��������
����ieee 754��׼Float����ʹ�ö����Ƹ�ʽ����ʵ�����ݡ�
�����������ڽ���������������Ϣ����ʹ�ö����ƴ洢������һЩ��Ҫ�����أ�������ͨ�������뵽һ���ǳ��ӽ���ֵ��
*/

DECLARE @float FLOAT
DECLARE @decimal DECIMAL(9,4)

SET @float=59.95
SET @decimal=59.95

SELECT @float*100000000000,@decimal*100000000000