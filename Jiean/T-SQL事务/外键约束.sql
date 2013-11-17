

--外键约束
/*
用于保证引用了外键的表的信息完整性，约束主外建的一致性。

注：事实上我们并不建议用外键约束，不少程序员为了方便，保证引用了外键的表的数据不出现孤立数据(即主键表的数据已改)
在引用表上增加外键约束了事，但这样有个缺点，把本来程序里应该要做的检查丢给了数据库，增加了数据库的压力，2，隐藏了
业务逻辑，增加查找问题难度。

一些小应用，增加一个使用状态字段，可以管控不再需要的状态不显示出来。
*/


CREATE TABLE sys_state(
	billStats INT,
	billStatsName VARCHAR(20),
	PRIMARY KEY(billStats) 
)
--添加主键
ALTER TABLE sys_state ALTER COLUMN  billStats INT NOT NULL 
ALTER TABLE sys_state ADD CONSTRAINT PI_sys_state PRIMARY KEY(billStats)

CREATE TABLE sd_pur_ordermaster(
	companyID VARCHAR(20),
	billno VARCHAR(30),
	billStats INT FOREIGN KEY REFERENCES sys_state(billStats) --外键约束
)

--添加外键约束
ALTER TABLE sd_pur_ordermaster ADD CONSTRAINT FK_sd_pur_ordermaster FOREIGN KEY(billStats) REFERENCES sys_state(billStats)

--添加记录
INSERT INTO sys_state
SELECT 0,'未送审' UNION ALL
SELECT 1,'已送审' UNION ALL
SELECT 2,'未审核' UNION ALL
SELECT 4,'已审核' 


INSERT INTO sd_pur_ordermaster
SELECT 'PT','PI131117admin-001',0 UNION ALL 
SELECT 'PT','PI131117admin-002',1 UNION ALL 
SELECT 'PT','PI131117admin-003',2 UNION ALL 
SELECT 'PT','PI131117admin-004',4

--删除受约束的主键记录
DELETE sys_state --出错

--需要先删除外键约束记录中相应的记录后，才能删除主键记录
DELETE sd_pur_ordermaster WHERE billStats=4

DELETE sys_state WHERE billStats=4

--改主键名称
UPDATE sys_state SET billStats=5 WHERE billStats=2 --出错


