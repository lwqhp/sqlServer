

--�����ļ��ռ�ʹ��
/*

ֻ�Ǵ��Ե��˽������ļ�����־�ļ���ʹ�ÿռ�
*/
--��Ҫ�����ͨ���ݿ⣬���ܱ�֤ʵʱ���¿ռ�ʹ��ͳ����Ϣ����tempdb���ݿ���洢��һЩϵͳ��ʱ���ݶ����޷�ͳ��
sp_spaceused @updateusage ='true'

/*
unallocated space��δ����ʹ�ÿռ�(
���ݿ�Ŀ��ÿռ䣬Ҳ���ǿɷ���ռ䣬û���˻ᰴ�����Զ������������δ����ʹ�ÿռ�ܴ��п��������ݿ����õ�̫��
���������ļ������⣬������ȷͳ�Ƶ���

)
reserved:���ù��������ͷŵĿռ䣨
	���Ǳ��ù����ͷų����Ŀռ䣬����ɾ����¼�����ı�ṹ����־�ضϺ����������Ŀռ䣬�ⲿ�ݿռ��������ʹ�ã�
����ⲿ�ݿռ�̫�࣬�����ؽ��ۼ����������������������ݿ���ݻ���
��
database-size:��ǰ���ݿ�Ĵ�С,���������ļ�����־�ļ�
data:���������ļ������Ǳ��������ռ�õĿռ䣨������������
unused : û���ù��Ŀռ䣨
	Ϊ���ݿ��ж������ģ���δʹ�õĿռ�����
��


*/

--sqlServer�Դ�����


--��ϸͳ�ƿռ�ʹ�����

--����ͳ��
DBCC showfilestats
/*
�������ֱ�Ӵ�ϵͳ����ҳ�������ȡ��������Ϣ���ܹ�����׼ȷ�ؼ����һ�����ݿ������ļ�������������ʹ�ù���������Ŀ��
��ϵͳ����ҳ�ϵ���Ϣ��Զ��ʵʱ���µģ���������ͳ�Ʒ����Ƚ�׼ȷ�ɿ����ڷ��������غܸߵ������Ҳ�ܰ�ȫִ�У�
�������Ӷ���ϵͳ���������Կ����ݿ������ļ�����ʹ����������Ǹ��ȽϺõ�ѡ��

TotalExtents :��ǰ���ݿ������������ļ����ж��ٸ���
UsedExtents :ʹ�ù��˵���
*/

/*
sys.dm_db_partition_stats :������Ϣ��ͼ,ÿ��������Ӧһ�С�
��ʾ���ڴ洢�͹������ݿ���ȫ�������� '��������'  'LOB ����'��'���������'�� �ռ���й���Ϣ��
 
*/

--��������ϸͳ��
SELECT 
o.name,
SUM(p.reserved_page_count) AS reserved_page_count,
SUM(p.used_page_count) AS used_page_count,
SUM(CASE WHEN p.index_id<2 THEN p.in_row_data_page_count+p.lob_used_page_count+p.row_overflow_used_page_count
	ELSE p.lob_used_page_count+p.row_overflow_used_page_count END )AS Datpages,
SUM(CASE WHEN p.index_id<2 THEN row_count ELSE 0 end) AS RowCounts 
 FROM sys.dm_db_partition_stats p 
INNER JOIN sys.objects o ON p.object_id = o.object_id
where o.name = 'BC_Sal_OrderMaster'
GROUP BY o.name



/*
���
partition_id  ���� ID�� �����ݿ�����Ψһ�ġ� ����ֵ�� sys.partitions Ŀ¼��ͼ�е� partition_id ֵ��ͬ�� 
object_id �÷����ı��������ͼ�Ķ��� ID��
index_id �÷����Ķѻ������� ID  0 = �� 1 = �ۼ�������> 1 = �Ǿۼ����� 

reserved_page_count Ϊ������������ҳ���� ���㷽��Ϊ in_row_reserved_page_count + lob_reserved_page_count + row_overflow_reserved_page_count�� 
used_page_count ���ڷ�������ҳ���� ���㷽��Ϊ in_row_used_page_count + lob_used_page_count + row_overflow_used_page_count�� 

http://technet.microsoft.com/zh-cn/library/ms187737.aspx

SQL Server��ʹ������ҳ��ʱ��Ϊ������ٶȣ����Ȱ�һЩҳ��һ��Ԥ����reserve�������Ȼ�����������ݲ����ʱ��
��ʹ�á��������������У�Reserved_page_count��Used_page_count�����еĽ�����һ�㲻��ܶࡣ
���Դ���������Reserved_page_count*8K���������ű��ռ�õĿռ��С��

DataPages�����ű����ݱ���ռ�еĿռ䡣��ˣ���Used_page_count �C DataPages������������ռ�еĿռ䡣
�����ĸ���Խ�࣬��Ҫ�Ŀռ�Ҳ��Խ�ࡣ

RowCounts����������������ж���������
*/

--��ȷͳ��

DBCC SHOWCONTIG --����ʾָ���ı�����ݺ���������Ƭ��Ϣ
/*
ͳ�� ���� 
ɨ��ҳ��                 
���������ҳ���� 
 
ɨ����չ������           
��������е���չ��������
  
��չ����������           
������������ҳʱ��DBCC ����һ����չ�����ƶ���������չ�����Ĵ����� 
 
ƽ����չ�����ϵ�ƽ��ҳ�� 
ҳ����ÿ����չ������ҳ���� 
 
ɨ���ܶ�[���ֵ:ʵ��ֵ] 
���ֵ��ָ��һ�ж����������ӵ�����£���չ�������ĵ�������Ŀ��ʵ��ֵ��ָ��չ�������ĵ�ʵ�ʴ��������һ�ж���������ɨ���ܶ���Ϊ 100�����С�� 100���������Ƭ��ɨ���ܶ�Ϊ�ٷֱ�ֵ��
  
�߼�ɨ����Ƭ 
��������Ҷ��ҳɨ�������ص�����ҳ�İٷֱȡ�������Ѽ����ı������޹ء�����ҳ��ָ�� IAM ����ָʾ����һҳ��ͬ����Ҷ��ҳ�е���һҳָ����ָ���ҳ�� 
 
��չ����ɨ����Ƭ 
������չ������ɨ������Ҷ��ҳ����ռ�İٷֱȡ�������Ѽ��޹ء�������չ������ָ�����������ĵ�ǰҳ����չ�������������ϵĺ���������ǰһҳ����չ���������һ����չ������ 
 
ƽ��ÿҳ�ϵ�ƽ�������ֽ��� 
��ɨ���ҳ�ϵ�ƽ�������ֽ���������Խ��ҳ�������̶�Խ�͡�����ԽСԽ�á����������д�СӰ�죺�д�СԽ�����־�Խ��
  
ƽ��ҳ�ܶȣ������� 
ƽ��ҳ�ܶȣ�Ϊ�ٷֱȣ�����ֵ�����д�С����������ҳ�������̶ȵĸ�׼ȷ��ʾ���ٷֱ�Խ��Խ�á� 

*/
Create table #showContigResults 
        (ObjectName sysname,
         Objectid bigint,
         IndexName sysname,
         indexid int,
         [level] int,
         pages int , --ɨ��ҳ��
         [rows] bigint,
         minRecsize int,
         maxRecsize int,
         avgRecSize real ,
         ForwardRecs int,
         Extents int, --ɨ������
         ExtentSwitches int, --���л�����
         AvgFreeBytes real, --ÿҳ��ƽ�������ֽ���
         AvgPageDensity real, --ƽ��ҳ�ܶ�(��)
         ScanDensity decimal(5,2), --ɨ���ܶ� [��Ѽ���:ʵ�ʼ���]
         BestCount int,
         ActCount int,
         LogicalFrag decimal (5,2), 
         ExtentFragmentation decimal (5,2))  --��ɨ����Ƭ
insert into #showContigResults
exec('DBCC SHOWCONTIG (''Test'') with tableresults')
select * from #showContigResults



SELECT * FROM sys.dm_db_index_physical_stats(
DB_ID(N'HK_ERP_HP'), OBJECT_ID(N'sd_pos_saledetail'), NULL, NULL , 'DETAILED'
)

/*
http://technet.microsoft.com/zh-cn/library/ms188917.aspx

SQL Server���������ܵĽǶȳ�����������һֱά�������ײ��ͳ����Ϣ��Ϊ�����������
SQL Server����Ҫ�����ݿ����ɨ�衣����˵�����ַ�ʽ��Ȼ��ȷ�����������ݿ⴦�ڹ����߷�ʱ��������Ҫ����ʹ�á�
*/

