
/*
�ַ������� Ӱ���ַ����Ĵ���ʹ��
������� ���ַ���������������ַ�������Сд��
*/
--ִ�ж�̬T-SQL���
EXECUTE
sp_executesql --���ִ��Ч�ʸ���

DECLARE @s varchar(100)
SET @s = 'adfafwehfdgdp'

--�ַ�������
SELECT len(@s)

--�����ַ�����ָ�����ʽ����ʼλ�á��� expression2 ������ expression1 ����ʼ�ַ�λ��
CHARINDEX ( expression1 , expression2 [ , start_location ] ) 
 
 --ɾ��ָ�����ȵ��ַ�����ָ������ʼ�������һ���ַ���
STUFF ( character_expression, start, length, character_expression ) 

--�����ַ��������ơ��ı���ͼ����ʽ��һ���֡� 
SUBSTRING ( expression, start, length ) 
 
--����������Ч���ı����ַ��������ͣ�����ָ�����ʽ��ģʽ��һ�γ��ֵ���ʼλ�ã����δ�ҵ�ģʽ���򷵻��㡣
PATINDEX ( '%pattern%', expression )

--���෴˳�򷵻��ַ����ʽ��
REVERSE(character_expression)
 
--����һ���ַ������ʽ�еڶ��������ַ������ʽ������ʵ�����滻Ϊ���������ʽ��
REPLACE ( 'string_expression1' , 'string_expression2' , 'string_expression3' )
 



 



 




/*
��̬sqlSQL��䷨
����select expression���UNION ALL ��ֱ�ӹ�������ı���ԭ�����������ַ����е����ݷָ����滻��֮
�������������Ҫ��UNION SELECT.
*/
declare @s varchar(100),@sql varchar(1000)
set @s='1,2,3,4,5,6,7,8,9,10'
set @sql='select col='''+ replace(@s,',',''' union all select ''')+''''
PRINT @sql
exec (@sql)


/*
  ����������⡣����ǰ�벿����ָ�����������֧�ֵ��ַ������磺

  Chinese_PRC_CS_AI_WS

  ǰ�벿�ݣ�ָUNICODE�ַ�����Chinese_PRC_ָ��Դ�½������UNICODE����������������ĺ�벿�ݼ���׺���壺

  _BIN ����������
  _CI(CS) �Ƿ����ִ�Сд��CI�����֣�CS����
  _AI(AS) �Ƿ�����������AI�����֣�AS���֡�����
  _KI(KS) �Ƿ����ּ������ͣ�KI�����֣�KS���֡�
  _WI(WS) �Ƿ����ֿ��WI�����֣�WS���֡�

  ���ִ�Сд�� ������ñȽϽ���д��ĸ��Сд��ĸ��Ϊ���ȣ���ѡ���ѡ�
  ���������� ������ñȽϽ������ͷ�������ĸ��Ϊ���ȣ���ѡ���ѡ����ѡ���ѡ��Ƚϻ���������ͬ����ĸ��Ϊ���ȡ�
  ���ּ����� ������ñȽϽ�Ƭ������ƽ��������������Ϊ���ȣ���ѡ���ѡ�
  ���ֿ�ȣ� ������ñȽϽ�����ַ���ȫ���ַ���Ϊ���ȣ���ѡ���ѡ��

  �������ݵ��������ͬ�����������������ͻ��

  �������ʾָ����������磺

  select name,id from database1..sysobjects where xtype ='U' collate Chinese_PRC_CI_AS
  and name in ( select name from ReportServer..sysobjects where xtype='U' collate Chinese_PRC_CI_AS)

  ��Ȼ����������ݿ�侭��Ҫ�������ݱȽϣ�����޸�����һ�����ݵ��������

  alter database database_name collate collate_name

  �ڶ����ݿ�Ӧ�ò�ͬ�������֮ǰ����ȷ������������������

  ���ǵ�ǰ���ݿ��Ψһ�û���
  û���������ݿ��������ļܹ��󶨶���
  ������ݿ��д����������������ݿ��������Ķ����� ALTER DATABASE database_name COLLATE ��佫ʧ�ܡ�SQL Server �����ÿһ������ ALTER �����Ķ��󷵻�һ��������Ϣ��
  ͨ�� SCHEMABINDING �������û����庯������ͼ��
  �����С�
  CHECK Լ����
  ��ֵ�������ذ����ַ��еı���Щ�м̳���Ĭ�ϵ����ݿ��������
  �ı����ݿ��������򲻻����κ����ݶ����ϵͳ�����в����ظ����ơ�
  ����ı�������������ظ������ƣ������������ռ���ܵ��¸ı����ݿ��������Ĳ���ʧ�ܣ�
  ������������̡�������������ͼ��
  �ܹ�����
  ���壬�����顢��ɫ���û���
  ��������������ϵͳ���û��������͡�
  ȫ��Ŀ¼���ơ�
  �����ڵ��������������
  ��Χ�ڵ���������
  ���µ��������������ظ����ƽ����¸��Ĳ���ʧ�ܣ�SQL Server �����ش�����Ϣ��ָ���ظ��������ڵ������ռ䡣
*/