
--Apply �������

/*
apply����������ұ���ʽӦ�õ������ʽ�е�ÿһ�У����������������ȼ����ĸ�����ʽ�����ԣ�apply�������߼��ؼ��������ʽ����
����е�ÿһ����¼�����ұ���ʽ��ͨ������������ֵ�����������ÿһ�еļ����������ɵ��б����������Ϊ�������.

Inner join�Ա�Student��Apply����ȫ��ɨ�裬Ȼ��ͨ����ϣƥ�����ƥ���sIDֵ��
�������������ܴ���ôInner join��ȫ��ɨ��ķ�ʱ���CPU��Դ��������
��Ȼ���������Cross applyʵ�ֵĲ�ѯ������ͨ��Inner joinʵ�֣���Cross apply���ܲ������õ�ִ�мƻ��͸��ѵ����ܣ���Ϊ������������ִ��֮ǰ���Ƽ��ϼ��롣 

cross apply�ǿ������ӱ�ֵ������ ��inner join������ ����������� ��Ȼ�������ӵĲ��Ǻ�����ʱ�� cross apply ����ģ��inner join 
 */
-- 1. cross join ����������
select *
  from TABLE_1 as T1
 cross join TABLE_2 as T2
 
-- 2. cross join ���ӱ�ͱ�ֵ��������ֵ�����Ĳ����Ǹ���������
select *
  from TABLE_1 T1
 cross join FN_TableValue(100)
 
-- 3. cross join  ���ӱ�ͱ�ֵ��������ֵ�����Ĳ����ǡ���T1�е��ֶΡ�
select *
  from TABLE_1 T1
 cross join FN_TableValue(T1.column_a)
 
Msg 4104, Level 16, State 1, Line 1
The multi-part identifier "T1.column_a" could not be bound.
���������ѯ���﷨�д����� cross join ʱ����ֵ�����Ĳ��������Ǳ� T1 ���ֶΣ� Ϊɶ�����������أ��Ҳ¿���΢��ʱû�м�������ܣ����������пͻ���Թ�� ����΢��������� cross apply �� outer apply �����ƣ��뿴 cross apply, outer apply �����ӣ� 
 
 
-- 4. cross apply
select *
  from TABLE_1 T1
 cross apply FN_TableValue(T1.column_a)
 
-- 5. outer apply
select *
  from TABLE_1 T1
 outer apply FN_TableValue(T1.column_a)
 
 /*
cross apply �� outer apply ���� T1 �е�ÿһ�ж�����������ֵ��������T1��ǰ���������ɵĶ�̬�������
 ����һ���������ӡ�cross apply �� outer apply ���������ڣ� 
 ������� T1 ��ĳ���������ɵ�������Ϊ�գ�cross apply ��Ľ���� �Ͳ����� T1 �е��������ݣ�
 �� outer apply �Ի�����������ݣ�����������������ֶ�ֵ��Ϊ NULL�� 
 
���������ժ��΢�� SQL Server 2005 �������������������չ���� cross apply �� outer apply �Ĳ�֮ͬ���� 
 
ע�� outer apply ������ж�������һ�С� �� Departments �����һ���ڽ��н�������ʱ��deptmgrid Ϊ NULL��fn_getsubtree(D.deptmgrid) ���ɵ���������û�����ݣ��� outer apply �Ի������һ�����ݣ���������� cross join �Ĳ�֮ͬ���� 
 
 */
    
    
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
create table #T(���� varchar(10))
insert into #T values('����')
insert into #T values('����')
insert into #T values(NULL )
 
 
create table #T2(���� varchar(10) , �γ� varchar(10) , ���� int)
insert into #T2 values('����' , '����' , 74)
insert into #T2 values('����' , '��ѧ' , 83)
insert into #T2 values('����' , '����' , 93)
insert into #T2 values(NULL , '��ѧ' , 50)
 
 SELECT * FROM #T
  SELECT * FROM #T2
--drop table #t,#T2
go
 
select   * from   #T a
cross apply
    (select �γ�,���� from #t2 where ����=a.����) b
 
/*
����         �γ�         ����
---------- ---------- -----------
����         ����         74
����         ��ѧ         83
����         ����         93
 
(3 ����Ӱ��)
 
*/
 
select     * from     #T a
outer apply
    (select �γ�,���� from #t2 where ����=a.����) b
/*
����         �γ�         ����
---------- ---------- -----------
����         ����         74
����         ��ѧ         83
����         ����         93
����         NULL       NULL
NULL       NULL       NULL
 
(5 ����Ӱ��)
 
 
*/ 
 
 ---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

 -- ��ʾ����
CREATE table  #A (
    id int)
INSERT #A
SELECT id = 1 UNION ALL
SELECT id = 2
 
CREATE table #B (
    id int)
INSERT #B
SELECT id = 1 UNION ALL
SELECT id = 3
 
 SELECT * FROM #A
  SELECT * FROM #b
-- 1. ������Ϊ��ʱ, APPLY��������CROSS JOIN�Ľ��һ��
SELECT *
FROM #A
    CROSS APPLY #B
 
-- 2. ������Ϊ������ʱ, ������APPLY������ģ��JOIN
-- 2.a ģ�� INNER JOIN
SELECT *
FROM #A A
    CROSS APPLY(
        SELECT * FROM #B
        WHERE id = A.id
    )B
 
-- 2.b ģ�� LEFT JOIN
SELECT *
FROM #A A
    OUTER APPLY(
        SELECT * FROM #B
        WHERE id = A.id
    )B
