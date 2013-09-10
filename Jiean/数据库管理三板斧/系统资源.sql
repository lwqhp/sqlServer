
--sqlserver 是怎么样使用一台服务器上的系统资源的

/*
作为一个window操作系统上的应用程序，sql server首先接受window的管理，利用window开放出的各种API
来申请和调度各项资源的使用。而作为一个数据引擎系统，sqlserver有它自己一套的系统资源管理理念。
尤其是对内顾和cpu资源。

也就是说在资源调度上，一层是window层面上，由window决定调度多少系统资源给sqlserver,第二层在sqlserver
内部，由sqlserver调度自己掌控的资源到底怎么用。

内存管理
作为一个须要反复访问数据的应用，sqlserver必须在内存中缓存很多信息，才能具有良好的性能。

1，sqlServer所占用的内存数量从启动以后，就不停地增长。
要解决这种现象，须要了解sqlserver与window，以及与运行在window之上的其它服务和应用是怎么相互办调，
共享服务器上的内存的，我们也须要了解怎么才能比较准确地分析一台服务器上window和包括sqlserver在内
的所有应用进程的内存使用。

2，在window2003以上版本上运行的slqserver,内存使用量突然急剧下降。

3，用户在做操作时，遇到内存申请失败。

4，内存压力导致的性能下降

从操作系统层面看sql server内存分配
 sqlserver和其它应用程序在请求内存上没有什么区别，都是通过virtualalloc之类的API向windows申请内存。
 window要协调并尽量满足各个应用的请求，还要保证这些请求不会危及window自身的安全。
 
 Virtual Address Space 虚拟地址空间
 就是内存寻址空间，每一个内存单元都有一个对应的访问地址，寻址空间的大小决定了应用程序能够申请访问的
 的最大地址空间，32位的服务器上，由于地址单元的长度是32位，寻址空间最大2^32,即4GB，再大的空间也无法
 被应用程序使用到。
 注：虚拟地址空间里存放的数据信息不一定都在物理内存里，window会根据其使用情况，决定它们什么时放在物理
 内存里，什么时候放在内存文件里(paging file)

 Page Hard Fault(硬错误)
 当访问一个存在于虚拟地址空间，但不存在于物理内存的页面，就会发生一次page Fault.windows内存管理组件会处理
 每一个页面访问错误，首先它要判断是不是访问越界，如果不是，如果目标页面存在于硬盘上(例如,在page file里)，
 这种访问会带来一次硬盘读写，我们称其为Hard Fault.另一种页面已尼桑在物理内存中，但是还没有直接放在这个进程
 的working Set 下，需要windows重新定向一次，这种访问不会带来硬盘操作，我们称之为Soft Fault.

 Reserved Memory（保留内存）
 应用程序在内存中保留一出一块内存寻址空间，以供将来使用,但不会实际去分配内存空间。

 Committed Memory(提交内存)
 将预先保留的内存寻址正式提交使用，存入数据。也就是说，正式在物理内存中申请一段空间，向页面中存入数据。

 Working Set(工作集)
 某个进程的地址空间中，存放在物理内存的那一部份。
 
 shared Memory(可共享)
 windows提供了在进程和操作系统间共享内存的机制。共享内存可以定义为对一个以上的进程都是可见的内存，或存
 在于多个进程的虚拟地址空间。
 
 private bytes(专用)
 某个进程提交的地址空间(Committed Memory)中，非共享的部分。
 

 Memory Leak(内存泄漏)
 当应用程序中出现某种循环，一直不断地保留(Reserve)或提交(Commit)内存资源，哪怕它们不再被使用，也不释放给其他用户重用。
 就会出现内存泄漏。sqlServer的内存泄漏有两种：一种是SqlServer 作为一个进程，不断地向windows申请内存资源，直到整个window内存耗尽。
 另一种是在sqlServr内部，某个sql Server 组件不断地申请内存，直到把sqlServer能申请到的所有内存都耗尽，使得其他sqlServer的功能
 组件不能正常使用内存。

 特别了解下32位下的寻址范围
 32位window 下用户 进程会有4G的寻址空间，其中2GB是给核心态(Kernel Mode)留下的，剩下2GB是给用户态(user Mode)留下的，window不会因
 为其中某一块内存地址空间用尽而将另外一块的空间让出。

 /3GB参数
 在boot.ini文件中使用/3GB参数可以把核心态的寻址空间降到1G,用户态寻址空间升到3G.

 AWE(Address Windowsing Extensions 地址空间扩展)
 这是一种允许 32位应用程序分配64GB物理内存，并把视图或窗口映射2GB虚拟地址空间的机制。

 注：sqlserver是通过一些特殊函数调用，去申请2G以外内存地址保留Reserve，然后通过Commit的内存调用，让它们使用扩展的内存，而
 一般的方式申请的内存，还是只能使用2GB的.

 启用AWE
 1)需要sqlserver启动帐户在window上有lock pages in memory权限。
 2)登陆用户有服务器权限
 3) sp_configure 'awe enabled',1
 4)确认 sql日志中有
	server Address Windowing Extensions enabled.
	失败：Cannot use Address Windowing Extensions Because lock memory Privilege was not granted.
 

 --------windows 内存检查------------------------------------------------
 windows层面没有明显的内存压力，是sqlServer正常运行的前提。
 检查：
 1)windows系统自身内存使用数量及内存分布。
 2）服务器上每一个进程的内存使用情况， 了解那些进程内存使用得最多，那些进程遇到了内存压力。

 监视windows 系统使用情况
 
 资源监视器
1）任务管理器中看到的内存数量是进程的专享内存大小
2）工作集=可共享+专用
3）提交~=专享内存+页文件大小,操作系统预留了一部分物理内存给自己使用

a) 为硬件保留的内存：除了显存以外，还有没开或者根本没有内存重映射技术主板，由硬件占用的一部分低端地址空间。
b) 正在使用：	供进程、驱动程序或操作系统使用的内存
c) 已修改：其内容必须在进入磁盘后才能用作其他目的的内存。指进程已经完成了操作，等待写入磁盘那部份内存。
d) 备用：	包含未活跃使用的缓存数据和代码的内存，也就是已处理完或弃用的死数据的内存空间，可重新申请使用。
e) 可用：即空闲内存，不包含任何有价值数据，以及当进程、驱动程序或操作系统需要更多内存时将首先使用的内存。

 1,整体使用分析
Committed Bytes
整个windows系统，包括windows自身及所有用户进程使用的内存总数，包括物理内存里的数据和文件缓存中的数据。

计算器的内存总量-资源监视器中的正在使用内存-为硬件保留的内存=使用的页面文件数量

2,Commit Limit
整个windows系统能够申请的最大内存数，其值等于物理内存加上文件缓存的大小。

如果Committed Bytes已经接近或等于Commit Limit,说明系统的内存使用已经接近极限，如果缓
存文件不能自动增长，系统将不能提供更多的内存空间。

3,Available Mbytes
现在系统空闲的物理内存数，这个指标能够直接反映出windows层面上有没有内存压力。
比较：这个数值跟“资源监视器”里的可用总数是对得上的。但计数器能反映出某段时间最大，最小，平均值。

4，Page File:%Usage 和Page File:%Peak Usage
这两个是百分比数，反应缓存文件使用量的多少，数据在文件级存中存得越多，说明物理内存数量和实际需求
量的差距越大，性能也越差。

5，pages/sec
Hard Page Fault 每秒钟需要从磁盘上读取或写入的页面数目。这里包括windows系统和所有应用进程的所有磁
盘paging动作，是Memory:pages input/sec 和memory:pages output/sec 的和。

对于一个调整良好，有足够内存资源的系统来讲，它所要处理的数据应该比较长期地保存在物理内存里，如果频繁
地被换进换出(page in/page/out)，势必会严重影响性能，所以如果一个系统不缺内存，pages/sec不能长时间地保
持在一个比较高的值。

总结：了解现有内存地址空间的使用大小，以及有多少数据期实级存在硬盘上的缓存文件里。
有多少空闲的物理内存还能被使用。对于一台sqlserver服务器，如果长期小于10MB，一般来讲物理内存是不太够的。
确认系统是否因为物理内存不足，而频繁做页面换进换出动作。如果是，也说明物理内存不富裕。


----Windows系统自身内存使用情况------------------------------------
一般32位的windows 系统，windows正常的内存使用在几百Mb,64位机器上，可能会达到1-2GB,但是如果windows在做一些
特殊的操作，或者是在windows层面出现内存泄漏（一般是由一些硬件驱动造成的）。windows可能会用到几个G甚至十几GB，
反过来挤压了应用程序的物理内存使用。

Memory:Cache Bytes
系统的working Set ,也就是系统使用的物理内存数目。包括高速缓存，页交换区，可调页的ntoskrnl.exe 和驱动程序代码，以及
系统映射视图等。
等于以下计数器的总和
Memory:Ststem cache Resident bytes(system cache)
系统高速缓存消耗的物理内存。

Memory:Pool paged resident bytes
页交换区消耗的物理内存

Memory:System Driver Resident Bytes
可调页的设备驱动程序代码消耗的物理内存。

Memory:System Code Resident Bytes
Ntoskrnl.exe 中可调页代码消耗的内存。

----System Pool------------------------------------
windows里面有两块重要的交换区(pool),如果这两块内存出现泄漏，或者空间用尽，windows会出现一些奇怪
的不正常行为，进而影响sqlServer的稳定运行，所以这两块内存的使用情况也要检查一下。
memory:pool Nonpaged bytes(非页交换区) 
Memory:Pool paged resident Bytes(页交换区)

*/


