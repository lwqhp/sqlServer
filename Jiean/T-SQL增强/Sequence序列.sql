

--Sequence����
/*
����sql2012�����Ĺ��ܣ���������Identity�в�ͬ���ǡ�SequenceNumber��һ���빹�ܰ󶨵����ݿ⼶��Ķ���
�����������ı�ľ��������󶨡�����ζ��SequenceNumber�������֮�乲�����кŵı���֮�⣬����������²���Ӱ��:
1����Identity�в�ͬ���ǣ�Sequence������е����кſ��Ա�Update,����ͨ�������������б���
2����Identity�в�ͬ��Sequence�п��ܲ����ظ�ֵ������ѭ��SequenceNumber��˵��
3��Sequence��������������кţ���������������ʹ�����кţ���˵�����һ�����кű�Rollback֮��
Sequence�����������һ���ţ��Ӷ������к�֮�������϶��

*/

--����һ������
create sequence testSequence
as int
start with 1
increment by 1

--�鿴����
select * from sys.sequences

--��ȡһ������,���е�ǰֵ�ı�
select next value for testSequence

--ʹ��
create table #test(id int)
go
declare @index int
set @index=0
while @index <=50
begin 
	insert into #test
	select next value for testSequence
	set @index+=1
end

--select * from #test

--���ü�����
alter sequence testSequence
restart with 1