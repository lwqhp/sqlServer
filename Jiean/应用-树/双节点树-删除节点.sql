--ɾ���ڵ�PT0003
--���½ڵ�������ӽڵ�ĸ��ڵ�Ϊ�ڵ�ĸ��ڵ㣨���Ǹ��ڵ�ĸ��ڵ㣩

SELECT * 
--UPDATE subNode SET subNode.parentID= superNode.parentID
FROM Bas_InterCompany subNode
INNER JOIN Bas_InterCompany superNode ON subNode.parentID = superNode.vendCustID
WHERE superNode.VendCustID ='PT0003'

--ɾ����ǰ�ڵ�
SELECT * 
--DELETE 
FROM Bas_InterCompany WHERE vendcustID ='PT0003'


--ɾ������
DELETE FROM dbo.Employees
  WHERE path LIKE 
    (SELECT M.path + '%'
     FROM dbo.Employees as M
     WHERE M.empid = 7);

/*
���ǣ��������漰�ڵ���������Ƚڵ�����к���ڵ�ʱ�����ֽڵ����������Ե÷ǳ����Ѻ͸��ӡ�
������Ҫչ����ǰ�ڵ�����к���㣬ͳ�ƺ���ڵ����������������Ҫ��һ�νڵ���Ȼ��ȱ�������ʵ��
*/


