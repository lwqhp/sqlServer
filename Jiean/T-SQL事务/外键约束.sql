

--���Լ��
/*
���ڱ�֤����������ı����Ϣ�����ԣ�Լ�����⽨��һ���ԡ�

ע����ʵ�����ǲ������������Լ�������ٳ���ԱΪ�˷��㣬��֤����������ı�����ݲ����ֹ�������(��������������Ѹ�)
�����ñ����������Լ�����£��������и�ȱ�㣬�ѱ���������Ӧ��Ҫ���ļ�鶪�������ݿ⣬���������ݿ��ѹ����2��������
ҵ���߼������Ӳ��������Ѷȡ�

һЩСӦ�ã�����һ��ʹ��״̬�ֶΣ����Թܿز�����Ҫ��״̬����ʾ������
*/


CREATE TABLE sys_state(
	billStats INT,
	billStatsName VARCHAR(20),
	PRIMARY KEY(billStats) 
)
--�������
ALTER TABLE sys_state ALTER COLUMN  billStats INT NOT NULL 
ALTER TABLE sys_state ADD CONSTRAINT PI_sys_state PRIMARY KEY(billStats)

CREATE TABLE sd_pur_ordermaster(
	companyID VARCHAR(20),
	billno VARCHAR(30),
	billStats INT FOREIGN KEY REFERENCES sys_state(billStats) --���Լ��
)

--������Լ��
ALTER TABLE sd_pur_ordermaster ADD CONSTRAINT FK_sd_pur_ordermaster FOREIGN KEY(billStats) REFERENCES sys_state(billStats)

--��Ӽ�¼
INSERT INTO sys_state
SELECT 0,'δ����' UNION ALL
SELECT 1,'������' UNION ALL
SELECT 2,'δ���' UNION ALL
SELECT 4,'�����' 


INSERT INTO sd_pur_ordermaster
SELECT 'PT','PI131117admin-001',0 UNION ALL 
SELECT 'PT','PI131117admin-002',1 UNION ALL 
SELECT 'PT','PI131117admin-003',2 UNION ALL 
SELECT 'PT','PI131117admin-004',4

--ɾ����Լ����������¼
DELETE sys_state --����

--��Ҫ��ɾ�����Լ����¼����Ӧ�ļ�¼�󣬲���ɾ��������¼
DELETE sd_pur_ordermaster WHERE billStats=4

DELETE sys_state WHERE billStats=4

--����������
UPDATE sys_state SET billStats=5 WHERE billStats=2 --����


