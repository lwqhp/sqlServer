

CREATE TABLE NTest(companyID VARCHAR(20),billno VARCHAR(20),sequence VARCHAR(10),val1 INT,val2 INT ,val3 INT)

INSERT INTO NTest
VALUES('WK','WK20130930-001','001',1,0,1),
('WK','WK20130930-001','002',1,0,1),
('WK','WK20130930-001','003',1,0,1),
('WK','WK20130930-001','004',1,0,1),
('WK','WK20130930-001','005',1,0,1),
('WK','WK20130930-001','006',1,0,1),
('WK','WK20130930-001','007',1,0,1),
('WK','WK20130930-001','008',1,0,1),
('WK','WK20130930-001','009',1,0,1),
('WK','WK20130930-001','010',1,0,1),
('WK','WK20130930-001','011',1,0,1),
('WK','WK20130930-001','012',1,0,1),
('WK','WK20130930-001','013',1,0,1),
('WK','WK20130930-001','014',1,0,1),
('WK','WK20130930-001','015',1,0,1),
('WK','WK20130930-001','016',1,0,1),
('WK','WK20130930-001','017',1,0,1),
('WK','WK20130930-001','018',1,0,1),
('WK','WK20130930-001','019',1,0,1),
('WK','WK20130930-001','020',1,0,1),
('WK','WK20130930-001','021',1,0,1),
('WK','WK20130930-001','022',1,0,1),
('WK','WK20130930-001','023',1,0,1),
('WK','WK20130930-001','024',1,0,1),
('WK','WK20130930-001','025',1,0,1),
('WK','WK20130930-001','026',1,0,1),
('WK','WK20130930-001','027',1,0,1),
('WK','WK20130930-001','028',1,0,1)

SELECT * FROM NTest
SET STATISTICS PROFILE ON

CREATE CLUSTERED INDEX IX_NTest ON NTest(companyID,billno,sequence)

UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '001'

UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '002'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '003'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '004'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '005'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '006'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '007'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '008'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '009'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '010'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '011'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '012'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '013'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '014'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '015'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '016'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '017'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '018'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '019'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '020'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '021'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '022'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '023'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '024'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '025'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '026'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '027'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '028'


UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'001'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'002'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'003'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'004'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'005'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'006'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'007'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'008'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'009'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'010'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'011'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'012'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'013'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'014'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'015'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'016'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'017'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'018'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'019'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'020'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'021'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'022'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'023'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'024'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'025'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'026'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'027'
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'028'

