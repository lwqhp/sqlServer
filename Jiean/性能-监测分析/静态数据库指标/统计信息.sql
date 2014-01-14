

--统计信息
/*
统计是一组存储为柱状图的信息（柱状图是显示数据落入不同分类中的频度的一种统计结构）

统计中的信息
最后更新时间信息：可以帮助你决定是否应该手工更新统计
平均关键字长度表示索引键列中平均的数据大小，它帮助你了解索引键的宽度，这在确定索引有效性时是重要的指标

统计密度指标
统计以密度比率的形式跟踪列的选择性，高选择性的列将有低的密度，低密度的列造用于非聚集索引，因为它帮助优化器
很快的检索少量的行，这也是过滤索引操作的主要依据，因为过滤器的目标是改进索引的选择性或密度。

密度可以表示为：
密度=1/列中不同值的数量
select 1.0/count(distinct a1) from tb

列密度越低，越适合于非聚集索引

可以在dbcc show_statistics的输出中 的all density列中看到真实的数据这个列上的高密度值使其不适合于作为索引，
即使是过滤索引也一样。
*/

--显示创建统计信息
CREATE STATISTICS stats_customer
ON slaes.customer(accountnumber)
WITH fullscan

--更新统计信息
UPDATE STATISTICS sales.customer
WITH fullscan

--对数据库中那些没有关联统计信息的列创建新的统计信息
EXEC sys.sp_createstats @indexonly = '', -- char(9)
    @fullscan = '', -- char(9)
    @norecompute = '' -- char(12)
    
--更新所有必要的(当数据发生改变时)统计信息，不会更新未改变数据的统计信息
EXEC sys.sp_updatestats @resample = '' -- char(8)

--查看统计信息
DBCC SHOW_STATISTICS('sales.customer',stats_customer)
/*
列alldensity表示列的选择生，选择性是指给定具体列的值返 回的行的百分比，较低的alldensity值表示较高的选择性，
经常用高选择性的列作为有用的索引。
*/

--删除统计信息
DROP STATISTICS     
