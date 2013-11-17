/*
1.��飺
SQL Server 2005�еĴ��ں���������Ѹ�ٲ鿴��ͬ����ľۺϣ�ͨ�������Էǳ�������ۼ��������ƶ�ƽ��ֵ���Լ�ִ���������㡣
���ں������ܷǳ�ǿ��ʹ������Ҳʮ�����ס�����ʹ��������������õ�����ͳ��ֵ��
�������û�ָ����һ���С� ������������Ӵ��������Ľ�����и��е�ֵ��
2.���÷�Χ��
�������������;ۺϿ�������.
Ҳ����˵���ں����ǽ�����������������߾ۺϿ�������һ��ʹ��
OVER�Ӿ�ǰ��������������������ǾۺϺ��� 

*/
--����������
create table #SalesOrder(
OrderID int, --����id
OrderQty decimal(18,2) --����
)
go
--��������
insert into #SalesOrder
select 1,2.0
union all
select 1,1.0
union all
select 1,3.0
union all
select 2,6.0
union all
select 2,1.1
union all
select 3,8.0
union all
select 3,1.1
union all
select 3,7.0
go
--��ѯ�����½��
select * from #SalesOrder
go

SET STATISTICS PROFILE ON
SET STATISTICS IO ON

select OrderID,OrderQty,
sum(OrderQty) over() as [����],
convert(decimal(18,4), OrderQty/sum(OrderQty) over() ) as [ÿ����ռ����],
sum(OrderQty) over(PARTITION BY OrderID) as [�������],
convert(decimal(18,4),OrderQty/sum(OrderQty) over(PARTITION BY OrderID)) as [ÿ���ڸ�����ռ����]
from #SalesOrder
order by OrderID 