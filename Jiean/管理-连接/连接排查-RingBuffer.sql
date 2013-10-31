

--Ring Buffer �Ų���������
/*
SQL Server 2008������һ�����ܣ�Connectivity Ring Buffer������׽ÿһ���ɷ���������Ĺر����Ӽ�¼(server-initiated connection closure)��
����ÿһ��session���¼ʧ���¼��������һЩ�ر��ֵ��������⡣

Ϊ�˽�����Ч�Ĺ����ų���Ring Buffer�᳢���ṩ�ͻ��˵Ĺ��Ϻͷ������Ĺرն���֮��Ĺ�ϵ��Ϣ��
ֻҪ����������, ���1K��Ring Buffer�ͻᱻ���棬1000����¼��Buffer��ʼѭ�����ǣ��������ϵļ�¼��ʼ���ǡ�

�ù���Ĭ�Ͽ���
*/

--DMV��ѯ
SELECT CAST(record AS XML),* FROM sys.dm_os_ring_buffers 
WHERE ring_buffer_type='RING_BUFFER_CONNECTIVITY'


/*
Connectivity Ring Buffer ��¼�����ּ�¼���ͷֱ��ǣ�ConnectionClose��Error����LoginTimers
<TdsBuffersInformation>��¼�ͻ�����TDS�����ж���bytes�����ҿ���֪���Ƿ���TDS�����κεĴ���
<TdsDisconnectFlags>��¼�˹ر����ӵ�״̬

<SspiProcessingInMilliseconds>21756</SspiProcessingInMilliseconds>

SSPI��Security Support Provider Interface������һ��SQL Serverʹ��Windows Authentication�Ľӿڡ�
��Windows login��һ��domain account��SQL Serverʹ��SSPI��Domain Controller������
�Ӷ���֤�û���ݡ���¼�п��Կ�����SSPI����ռ���˴�����ʱ�䣬�������Domain Controller����ʱ����ʱ��
���п�����SQL��������DC֮����������������⣬����DC�ϵ�һЩ������⡣���Կ���������û�н�������ץ����
Ҳû���������⣬���Ǿ��Ѿ���������С��SQL Server��Domain Controller֮��Ľ����������ˡ�


<Frame>tags��ʲô��
ͨ��sys.dm_os_ring_buffers DMV ���Է���һϵ���ڲ���Ϣ���������˵���������Connectivity Ring Buffer��
��ΪDMV������һ���֣��������Ring Buffers �ṩ���¼�����ʱ��ջ�ټ���stack trace����
ÿһ��<frame>�ṩ��һ��ʮ�����Ƶĺ�����ַ����Щ�����Էֽ�Ϊ����������dump Sqlservr.exe���̣�
��WinDbg��dump�������û��ں����ĵ�ַ��LM���

----------------------------
������ڿͻ��˿���һ�����󣬵�����Ring Buffer��û�м�¼����ͱ�����������������һ�֡����á����͵����ӹرգ�
�������ӹر������ڿͻ��������ر����ӵ���Ϊ�����������ڷ������ⲿ��������ɵ����ӹرգ�
�����磬һ������Ӳ���Ĺ��ϣ����������������������Ҫ��עǱ�ڵ����绥�����⡣
�������Ring Buffer�п�����һ����Ŀ������ָ��Ϊʲô������Ҫ�ر�������ӣ���ô�����Ŀ�ͺܿ��ܿ��Լ���İ������ǽ��й����Ų顣
���磬����㿴��һ�����ӹر�������TDS���е���Ϣ���Ϸ�����ô��Ϳ���ȥ�����Щ���ܻ�����������豸������������·�ɺͼ������ȡ�


ͨ��ʹ��һ��trace flag��������Connectivity Ring Buffer��¼�������ӹر��¼���
��������ܹ۲쵽�ͻ��˷�������ӹرյ����κ�Ǳ�ڵĴ���

������trace flag���������ڸı�Connectivity Ring Buffer ����Ϊ��

*/
--��ȫ�ر�Connectivity Ring Buffer��
DBCC TRACEON (7826, -1)

--���ٿͻ��˵����ӹر�
DBCC TRACEON (7827, -1)
/*
Ĭ������¿ͻ��˷�������ӹر��ǲ�����¼�ģ���Ϊ���������������������һ�����󣩣���һ���ͻ�����������session��
���ͶϿ���һ����˵�����ǽ��鲻Ҫȥ���ٿͻ��˷�������ӹرգ�
��Ϊ�������õ�Buffer��¼�ᱻ���ǣ������кܶ��������ֵ�����ʱ������������������Ի�ܴ󣩣�
���߻ᱻ������һ������������ļ�¼�С����ʹ���������Ĵ������⡣
*/