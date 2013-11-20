

--触发器
/*
触发器的用途：
1，强制参照完整性：一般建议使用声明参照完整性DRI,但对于跨数据库或服务器的参照完整性
2，创建审计跟踪：跟踪大多数当前的数据，还包括对每个记录进行实际修改的历史数据，2008有个数据跟踪功能。
3，创建与check约束类似的功能，可以跨表，跨数据库，甚至是跨服务器使用。
4，用自己的语句代替用户的操作语句：这通常用于启动复杂视图中的插入操作。
5，监控表结构的变化。

--触发器类型
触发器是附加在表或视图上的代码片段，无传入参数和返回码，根据表，视图的插入，更新和删除操作分为三种类型+ 混合型

注：进行的操作在记录中活动才会激活触发器，truncate table是释放空间操作，不会激活触发器
批量操作默认情况下不激活触发器，需显示甜知批量操作激活触发器。

create Trigger 
on --指出触 发器将要附加的表或视图
for|after  触发器激活的类型,after不能用于视图，insert update,delete

触发器的应用：实施数据完整性规则
1，处理来自于其他表的需求
2,使用触发器来检查更新的变化inserted 和deleted
3，将触发器用于自定义错误消息

update()函数：只在触发器的作用域内适用，提供一个布尔值，来说明某个特殊列是否已经更新。
olumns_updated()函数：

触发器与激活触发器的语句被视为同一事务处理，这意味着语句直到触 发器完成后才算完成。after触发器在所有工作已经
完成后发生，这意味着回滚的代价是昂贵的

instead of
*/

--触发器的调试
BEGIN TRAN 

UPDATE 

UPDATE 

if @@trancount>0
ROLLBACK TRAN 