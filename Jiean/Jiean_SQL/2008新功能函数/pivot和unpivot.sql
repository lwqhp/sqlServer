

/*
PIVOT��һ���﷨�ǣ�PIVOT(�ۺϺ���(��) FOR �� in (��) )AS P
 Pivot(�ۺ�ָ����ֵ FOR(�ǰ���һ����з���) in(���а����Զ���ֵ��)�����ⰴ����з���ۺϣ�
 
�����﷨��

select [column] from tableName
PIVOT(
	�ۺϺ�����value_column��FOR pivot_column IN(<column_list>)
) a

UNPIVOT���ڽ�����תΪ��ֵ������ת�У�����SQL Server 2000������UNION��ʵ��

�����﷨��

table_source
UNPIVOT(
	value_column FOR pivot_column IN(<column_list>)
)

ע�⣺PIVOT��UNPIVOT��SQL Server 2005 ���﷨��ʹ�����޸����ݿ���ݼ���
 �����ݿ�����->ѡ��->���ݼ����Ϊ   90*/ 


/*
���󣺱Ƚ�ÿ���и����ȵ�����״����Ҫ��ô���أ�
select * from SalesByQuarter
*/

--һ��ʹ�ô�ͳSelect��CASE����ѯ
SELECT year as ���
    , sum (case when quarter = 'Q1' then amount else 0 end) һ����
    , sum (case when quarter = 'Q2' then amount else 0 end) ������
    , sum (case when quarter = 'Q3' then amount else 0 end) ������
    , sum (case when quarter = 'Q4' then amount else 0 end) �ļ���
FROM SalesByQuarter GROUP BY year ORDER BY year DESC

--����ʹ��PIVOT
--��ÿ��PIVOT��ѯ���漰ĳ�����͵ľۺϣ��������Ժ���GROUP BY��䡣��

    SELECT *
    FROM    SalesByQuarter PIVOT ( SUM(amount) FOR quarter IN ( Q1, Q2, Q3, Q4 ) ) AS P
    ORDER BY YEAR DESC

    SELECT  year AS ��� ,
            Q1 AS һ���� ,
            Q2 AS ������ ,
            Q3 AS ������ ,
            Q4 AS �ļ���
    FROM    SalesByQuarter PIVOT ( SUM(amount) FOR quarter IN ( Q1, Q2, Q3, Q4 ) ) AS P
    ORDER BY YEAR DESC
