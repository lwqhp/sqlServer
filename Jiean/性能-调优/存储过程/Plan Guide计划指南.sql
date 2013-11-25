

--Plan Guide �ƻ�ָ��
/*
���ڲ��ܱ������ʱ�򣬿���ʹ�üƻ�ָ��ǿ��ָ���µļƻ�����

���Դ����������͵ļƻ�ָ�ϡ���������SQL Server����������ժ¼�ܽ����⼸�ּƻ�ָ�ϣ�

OBJECT �ƻ�ָ��������-SQL�洢���̡�����������������-ֵ������DML�������������Ļ�����ִ�еĲ�ѯ��ƥ�䡣

SQL �ƻ�ָ���뵥������-SQL���Ͳ������ݿ����ĳɷ������Ļ�����ִ�еĲ�ѯ��ƥ�䡣����SQL�ļƻ�ָ��Ҳ��������ƥ��ȷ��ָ����Ĳ����Ĳ�ѯ��

TEMPLATE �ƻ�ָ����ȷ��ָ����Ĳ����ĵ�����ѯ��ƥ�䡣��Щ�ƻ�ָ������ȡ��һϵ�еĲ�ѯ��Ϊһ�����ݿ⵱ǰ�����������ݿ�����ѡ�
*/

--һ���ƻ�ָ�ϵĶ�����ͨ��ϵͳ�洢����sp_create_plan_guide��ʵ�ֵ�:
sp_create_plan_guide parameters
EXEC sp_create_plan_guide @name, @stmt, @type, @module_or_batch, @params, @hints
Here is an explanation of the parameters:
@name - name of the plan guide
@stmt - a T-SQL statement or batch
@type - indicates the type of guide (OBJECT, SQL, or TEMPLATE)
@module_or_batch - the name of a module (i.e. a stored procedure)
@params - for SQL and TEMPLATE guides, a string of all parameters for a T-SQL batch to be matched by this plan guide
@hints - OPTION clause hint to attach to a query as defined in the @stmt parameter

--�鿴�����ݿ��д洢�����мƻ�ָ���б�
SELECT * FROM sys.plan_guides
GO


--ɾ���ƻ�ָ�ϣ�����ͣ�ã��������֮ǰ�Ѿ�ֹͣ������ô������������
sp_control_plan_guide parameters
EXEC sp_control_plan_guide @operation, @name
Explanation of its parameters:
@operation - a control option; one of DROP, DROP ALL, DISABLE, DISABLE ALL, ENABLE, ENABLE ALL
@name - name of the plan guide to CONTROL

EXEC sp_control_plan_guide N'DROP', N'GETSALESPRODUCTS_RECOMPILE_Fix'
GO

--ԭ��������
EXEC sys.sp_create_plan_guide 
	@ @name = 'Guidel', -- sysname
    @stmt = N'SELECT COUNT(b.salesorderid),SUM(p.weight)
FROM salesorderheader_test a
INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
INNER JOIN production.product p ON b.productid = p.productid
WHERE a.salesorderid = @i', -- nvarchar(max)
    @type = N'OBJECT', -- nvarchar(60)
    @module_or_batch = N'Sniff', -- nvarchar(max)
    @params = null, -- nvarchar(max)
    @hints = N'Option(optimize for(@i=75124))' -- nvarchar(max)

