/*
1,CTE�ݹ�ѭ��(���ṹ)
2,CTE�ݹ�ѭ��(����ݹ�)    


*/
--CTE�ݹ�ѭ��(���ṹ)
    go  
    create table Tree  
    (  
      ID int identity(1,1) primary key not null,  
      Name varchar(20) not null,  
      Parent varchar(20) null  
    )  
    go  
    insert Tree values('��ѧ',null)  
    insert Tree values('ѧԺ','��ѧ')  
    insert Tree values('�����ѧԺ','ѧԺ')  
    insert Tree values('���繤��','�����ѧԺ')  
    insert Tree values('��Ϣ����','�����ѧԺ')  
    insert Tree values('����ѧԺ','ѧԺ')  
    insert Tree values('����','��ѧ')  
    insert Tree values('���Ͽ�','����')  
    insert Tree values('������','��ѧ')  
    go  
    SELECT * FROM Tree
    ;with CTE as  
    (  
    -->Begin һ����λ���Ա  
     select ID, Name,Parent,cast(Name as nvarchar(max)) as TE,0 as Levle from Tree where Parent is null  
    -->End   
    union all  
    -->Beginһ���ݹ��Ա  
     select Tree.ID, Tree.Name,Tree.Parent,cast(replicate(' ',len(CTE.TE))+'|_'+Tree.name as nvarchar(MAX)) as TE,Levle+1 as Levle  
            from Tree inner join CTE  
            on Tree.Parent=CTE.Name  --�¼��ӽڵ㣨��ID=��һ��ID��
    -->End  
    )  
    select * from CTE order by ID  
    --1.�� CTE ���ʽ���Ϊ��λ���Ա�͵ݹ��Ա��  
    --2.���ж�λ���Ա��������һ�����û��׼����� (T0)��  
    --3.���еݹ��Ա���� Ti ��Ϊ����(����ֻ��һ����¼)���� Ti+1 ��Ϊ�����  
    --4.�ظ����� 3��ֱ�����ؿռ���  
    --5.���ؽ���������Ƕ� T0 �� Tn ִ�� UNION ALL �Ľ����  
    
    

--CTE�ݹ�ѭ��(����ݹ�)    

create function generateTime
 
(
 
    @begin_date datetime,
 
    @end_date datetime
 
)
 
returns @t table(date datetime)
 
as
 
begin
 
    with maco as
 
    (
 
       select @begin_date AS date
 
       union all
 
       select date+1 from maco
 
       where date+1 <=@end_date--�ݹ��Լ���������ֵ����
 
    )
 
    insert into @t
 
    select * from maco option(maxrecursion 0);
 
    return
 
end
 
 
DECLARE @1 datetime
DECLARE @2 datetime
DECLARE @now varchar(20)
DECLARE @a int
SET @a=4
SET @now='2013-'+CONVERT(CHAR(2),@a)+'-'+'01'
set @1=DATEADD(MONTH,DATEDIFF(MONTH,0,@now),0)
set @2=DATEADD(DD,-1,DATEADD(MONTH,1+DATEDIFF(MONTH,0,@now),0)) 
 
select * from dbo.generateTime(@1,@2)