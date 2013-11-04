

--��ǿ������� --pivot & unpivot 

/*
��
a) PIVOT��UNPIVOT��SQL Server 2005 ���﷨��2000�汾ʹ�����޸����ݿ���ݼ��� �����ݿ�����->ѡ��->���ݼ����Ϊ   90
b) Pivot��֧�ֶ�̬pivoting,�봫ͳ��ת��û��ʲô���������ܲ��죬����ִ�мƻ���һ���ġ�
c) ������ת�����ֵ��.


*/

/*
����������ԣ����������Ϊ���ǵ������룬λ��FROM�Ӿ�ĵ�һ�����������һ������ʽ��Ϊ�����벢����
һ���������Ϊ�����������ʽ��������ʵ�ı���ʱ���������������CTE����ͼ����ֵ��������Form�Ӿ�
�ĵڶ������������ǰһ����������ص��������Ϊ�����롣

ע��Ϊ�˸������pivot������Ĺ���ԭ���һ�һ��ʽȥ���ͣ�
1����Ҫת�����г�Ϊ�ᣬ����������㡣
2��������ص��г�Ϊ��ֵ�С�
3�����ϵ�ÿһ��ֵ��Ϊ������Ӧ��ֵ�е�ֵΪ��ֵ��ת�����Ϊ��������ֵΪ��ֵ��


Pivot 
Pivot��������ڰ����ݴӶ��еķ���״̬��תΪÿһ��λ��һ�еĶ���״̬�����ڸù�����ִ�оۺ����㡣�򵥽�������ת�С�

Pivot �������
1, P1:��ʽ����
	�ڵ�һ�׶Σ�������δ��Ϊpivot������ж�������ʽ���飬������һ��������group by
2��P2������ֵ��
	�ڵڶ��׶Σ� ����Ŀ���ж�Ӧ��ֵ��Ҳ���ǰ����������Ϊ���ģ���ת90�ȣ������ϵ�ֵΪ������תΪ���У������Ӧ��
	ֵתΪ��Ӧ������ֵ��
	������������case when <����>='��1' then '��ֵ' end as '��1'
				case when <����>='��2' then '��ֵ' end as '��2'
3��P3��Ӧ�þۺϺ���
	�ڵ����׶Σ��ڵ�һ�׶ε�group by ��������϶ԡ���ֵ�����оۺ�����
	������������Max(case when <����>='��1' then '��ֵ' end) as '��1'
				Max(case when <����>='��2' then '��ֵ' end) as '��2'
				
�����﷨��

select [����] from tableName
PIVOT(
	�ۺϺ�������ֵ�У�FOR ���-���� IN(<ת���ϵļ���>)
) a������󷵻ص������A��				
*/
/*
���ӣ��Ƚ�ÿ���и����ȵ�����״��
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




/*
UNPIVOT
	��Pivot������̣�����ת�С�

ע����ת�к���Ҫ����ָ��������ͼ�ֵ����

Pivot�������
1, U1:���ɸ���
	 ������ΪUNpivot����������ʽ�е��У�ÿһ�ж���Ϊin�Ӿ��еĵ�һ��Դ�и���һ�Σ���������
	 ���� һ�����У��������ַ�����ʽ����Դ�е����ơ��������Զ��塣
	 
2, U2:����Ŀ����ֵ
	��Ŀ����ֵ���·ŵ���ֵ���£�Ŀ����ֵ����ת���ϵļ��������¶����ֵ����
	
3, U3:���˵�����Null�ĺ͡�	
	ȥ����ֵ����ֵΪnull���С�
	
�����﷨��

table_source
UNPIVOT(
	�µļ�ֵ���� FOR �µ����-���� IN(<ԭת���ϵ�����-��>)
)



/*
�ܽ�:
1,��Ϊ����δ�ᶨ���н������飬����ܻ�����ʶ�صõ�����ķ��飬Ҫ���������⣬ʹ��ֻ����ָ���е�������
���ñ���ʽ(CTE),Ȼ����Ϊ�ñ���ʽӦ��pivot��

2,�ۺϺ��������������δ������Ļ��У������Ǳ��ʽ(���磺sum(qty*price),�������ۺ��ṩһ�����ʽ��Ϊ��
�룬���Դ���һ���������cte,������Ϊ���ʽָ��һ���б�����qty*price as totalPrice��,�����ⲿ��ѯ��ʹ�ø�
����Ϊpivot�ۺϺ��������롣

3��ͬ�������Ҫ��ת����е����ԣ������������cte���Ƚ��кϲ�������һ���б���(����1_����2) as new_column
4, ��������ת������Դ�����б��������ͬ���������ͣ�������Ͳ�ͬ�����Դ���һ���������CTE,�����е�ת����ת��varchar����
*/

��t-sql p369 ,�ҽű�
*/

--��һ����ת��д��
;with tmp as(
select CompanyID,stuff(
	(select ','+sysparaid 
	from Sys_ParameterDetail 
	where companyID = a.companyID and sysparaid in('0015','0019') for xml path('')),1,1,'') as sysparaid
from Sys_ParameterDetail a where SysParaID in('0015','0019')
)
select * from tmp where charindex('0015',sysparaid)>0
	and charindex('0019',sysparaid)=0