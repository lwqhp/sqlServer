/*
1,CTE递归循环(树结构)
2,CTE递归循环(自身递归)    


*/
--CTE递归循环(树结构)
    go  
    create table Tree  
    (  
      ID int identity(1,1) primary key not null,  
      Name varchar(20) not null,  
      Parent varchar(20) null  
    )  
    go  
    insert Tree values('大学',null)  
    insert Tree values('学院','大学')  
    insert Tree values('计算机学院','学院')  
    insert Tree values('网络工程','计算机学院')  
    insert Tree values('信息管理','计算机学院')  
    insert Tree values('电信学院','学院')  
    insert Tree values('教务处','大学')  
    insert Tree values('材料科','教务处')  
    insert Tree values('招生办','大学')  
    go  
    SELECT * FROM Tree
    ;with CTE as  
    (  
    -->Begin 一个定位点成员  
     select ID, Name,Parent,cast(Name as nvarchar(max)) as TE,0 as Levle from Tree where Parent is null  
    -->End   
    union all  
    -->Begin一个递归成员  
     select Tree.ID, Tree.Name,Tree.Parent,cast(replicate(' ',len(CTE.TE))+'|_'+Tree.name as nvarchar(MAX)) as TE,Levle+1 as Levle  
            from Tree inner join CTE  
            on Tree.Parent=CTE.Name  --下级子节点（父ID=上一级ID）
    -->End  
    )  
    select * from CTE order by ID  
    --1.将 CTE 表达式拆分为定位点成员和递归成员。  
    --2.运行定位点成员，创建第一个调用或基准结果集 (T0)。  
    --3.运行递归成员，将 Ti 作为输入(这里只有一条记录)，将 Ti+1 作为输出。  
    --4.重复步骤 3，直到返回空集。  
    --5.返回结果集。这是对 T0 到 Tn 执行 UNION ALL 的结果。  
    
    

--CTE递归循环(自身递归)    

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
 
       where date+1 <=@end_date--递归自己，自身数值运算
 
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