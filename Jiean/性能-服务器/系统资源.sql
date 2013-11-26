
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

这类问题往往不是sqlserver自己导致的，而是windows"感觉"到急迫的内存压力，迫使用sqlserver释放内存。

3，用户在做操作时，遇到内存申请失败。

sqlserver里的内存分成好多部份，每一部份都有它们的使用限制，不是用户想申请多少，就能申请多少的，首先要分
析sqlserver里面到底是哪一部份内存用完了，到底是哪一部份用掉了最多的内存。

4，内存压力导致的性能下降



-----
从操作系统层面看sql server内存分配
 sqlserver和其它应用程序在请求内存上没有什么区别，都是通过virtualalloc之类的API向windows申请内存。
 window要协调并尽量满足各个应用的请求，还要保证这些请求不会危及window自身的安全。所以，从window层面来看，
 sqlserver也是和普通的应用程序一样的，window不会给sqlserver 任何特珠照顾。
 
 Virtual Address Space 虚拟地址空间
 就是内存寻址空间，每一个内存单元都有一个对应的访问地址，寻址空间的大小决定了应用程序能够申请访问的
 的最大地址空间，32位的服务器上，由于地址单元的长度是32位，寻址空间最大2^32,即4GB，再大的空间也无法
 被应用程序使用到。
 注：虚拟地址空间里存放的数据信息不一定都在物理内存里，window会根据其使用情况，决定它们什么时放在物理
 内存里，什么时候放在内存文件里(paging file)

 Page Hard Fault(硬错误)
 当访问一个存在于虚拟地址空间，但不存在于物理内存的页面，就会发生一次page Fault.windows内存管理组件会处理
 每一个页面访问错误，首先它要判断是不是访问越界，如果不是，如果目标页面存在于硬盘上(例如,在page file里)，
 这种访问会带来一次硬盘读写，我们称其为Hard Fault.另一种页面已经在物理内存中，但是还没有直接放在这个进程
 的working Set 下，需要windows重新定向一次，这种访问不会带来硬盘操作，我们称之为Soft Fault.

 Reserved Memory（保留内存）
 应用程序在内存中保留出一块内存寻址空间，以供将来使用,但不会实际去分配内存空间。（如果某块地址已经被其
 他对象保留，你去访问它，就会收到一个访问越界的错误）

 Committed Memory(提交内存)
 将预先保留的内存寻址正式提交使用，存入数据。也就是说，正式在物理内存中申请一段空间，向页面中存入数据。
 
 保留内存-提交内存的作用：通过推迟页面提交来减少物理内存的使用。对可能需要潜在的连续的内存缓冲区的应用
 先保留所需的地址空间，在需要的时候再提交使用，而不是为了整个区域提交页面。
 
 Shared Memory(共享内存)
 window提供了在进程和操作系统间共享内存的机制，就是可以定义一个以上的进程都是可见的内存，或存在于多个进
 程的虚拟空间，比如，如果两个进程使用相同的DLL,只把Dll的代码页装入内存一次，其它所有映身这个dll的进程
 只要共享这些代码页就可以了。
 

 Working Set(工作集)
 某个进程的地址空间中，存放在物理内存的那一部份。
 
 
 private bytes(专用)
 某个进程提交的地址空间(Committed Memory)中，非共享的部分。
 
 window系统进程相关的内存
 1，system cache 系统高速缓存：用于映射在系统高速缓存中打开的文件页面，以提高i/o任务 速度。
 2，Non Paged Pool 非页交换区：包括一定范围的系统虚拟地址的内存交换区，可以保证在任何时候它都驻留 在物理内顾
 中，这样可以在没有io调页的情况下从任何地址空间访问。
 3，page Pool 页交换区：系统空间中可以调入或调出系统进程工作集的虚拟内存区域。
 4，stack 栈 ：每个线程有两个栈，一个给内核模式 kernel mode,另一个组用户模式user mode,每个栈是一块内存空间，
 存放线程运行的过程或函数的调用地址，以及所有参数的值。
 5，in process : 运行在同一个进程的地址空间里，例如，一个进程需要加载一个dll文件，这个dll文件里的代码也会去
 申请内存。如果运行在同一个进程的地址空间里，最大的好处是速度快。
 6，out of Process 运行在不同的进程地址空间里，像oledb这样的驱动程序可以配置 成运行在dllhost.exe的进程空间里。

 Memory Leak(内存泄漏)
 当应用程序中出现某种循环，一直不断地保留(Reserve)或提交(Commit)内存资源，哪怕它们不再被使用，也不释放给其他用户重用。
 就会出现内存泄漏。sqlServer的内存泄漏有两种：一种是SqlServer 作为一个进程，不断地向windows申请内存资源，直到整个window内存耗尽。
 另一种是在sqlServr内部，某个sql Server 组件不断地申请内存，直到把sqlServer能申请到的所有内存都耗尽，使得其他sqlServer的功能
 组件不能正常使用内存。

-------------
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
如果此值长期小于100MB，一般来说物理内存是不太够的。
比较：这个数值跟“资源监视器”里的可用总数是对得上的。但计数器能反映出某段时间最大，最小，平均值。

4，Page File:%Usage 和Page File:%Peak Usage
这两个是百分比数，反应缓存文件使用量的多少，数据在文件级存中存得越多，说明物理内存数量和实际需求
量的差距越大，性能也越差。

5，pages/sec
Hard Page Fault 每秒钟需要从磁盘上读取或写入的页面数目。这里包括windows系统和所有应用进程的所有磁
盘paging动作，是Memory:pages input/sec 和memory:pages output/sec 的和。

如果在缓冲区中未能命中，就需要去物理内存的其它区域寻找，如果找到了，就是一个Soft Page Fault；
如果在缓存文件中找到，就是一个Hard Page Fault。
Pages/sec反映Hard Page Fault 表示每秒钟需要从磁盘上Paging动作（读取或写入）的页面数量。

一共有下列几个相关的计数器，计算公式为：
Memory:Page Faults/sec = Soft Page Fault + Hard Page Fault
Memory:Page/sec = Memory:Pages Input/sec + Memory:Pages Output/sec


对于一个调整良好，有足够内存资源的系统来讲，它所要处理的数据应该比较长期地保存在物理内存里，如果频繁
地被换进换出(page in/page/out)，势必会严重影响性能，所以如果一个系统不缺内存，pages/sec不能长时间地保
持在一个比较高的值。

总结：了解现有内存地址空间的使用大小，以及有多少数据期实级存在硬盘上的缓存文件里。
有多少空闲的物理内存还能被使用。对于一台sqlserver服务器，如果长期小于10MB，一般来讲物理内存是不太够的。
确认系统是否因为物理内存不足，而频繁做页面换进换出动作。如果是，也说明物理内存不富裕。

总结：作为DBA，应当综合考量上述计数器的值。如果Committed Bytes值长期接近Commit Limit值，可能需要增加内存。
通过Page File:% Usage 和 Page File:% Peak Usage 查看有多少数据实际上是缓存在硬盘上的缓存文件里。
通过Available MBytes的值，可以了解系统还有多少空闲的物理内存可被使用。
再看Pages/sec的值，较高的值反映了系统因为物理内存不足而频繁使用缓存文件。

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

--单个proecss 进程的使用情况(查看每个进程process的内存使用情况)
当Available MBytes看出服务器的内存基本用尽，但是从Memory:Cache Bytes 的值看，window自己没有使用多少，现在就要分析
到底是哪些个应用进程把物理内存都占用了。

Process:%processor Time 指的是目标进程消耗的cpu资源数，包括用户态和核心态的时间,也就是处理器用来执行非闲置线程时间
的百分比。
指令是计算机执行的基础单位。线程是执行指令的对象，进程是程序运行时创建的对象，
每个运行的进程至少有一个线程。此计数包括处理某些硬件间隔和陷阱条件所执行的代码。

Process:Page Faults/sec 指在这个进程中执行线程造成的页面错误出现的速度。
当线程引用了不在主内存工作集中的虚拟内存页即会出现 Page Fault。
如果它在备用表中(即已经在主内存中)或另一个共享页的处理正在使用它，就会引起无法从磁盘中获取页。

Process:Handle Count 指由这个进程现在打开的句柄（指向Object的指针）总数。
这个数字等于这个进程中每个线程当前打开的句柄的总数。如果进程内部有对象老是创建，不及时回收，就会造成Handle Leak。

Process:Thread Count 指在这次进程中正在活动的线程数目。如果进程总是创建新线程，不释放老线程，就会发生Thread Leak.

Process:Pool Paged Bytes 指在分页池中的字节数，分页池是系统内存(操作系统使用的物理内存)中可供对象(在不处于使用时可以写入磁盘的)
使用的一个区域。Memory:Pool Paged Bytes 的计数方式与 Process:Pool Paged Bytes 的方式不同，
因此可能不等于 Process:Pool Paged Bytes\_Total。这个计数器仅显示上一次观察的值；而不是一个平均值。

Process:Pool Nonpaged Bytes 指在非分页池中的字节数，非分页池是指系统内存(操作系统使用的物理内存)
中可供对象(指那些在不处于使用时不可以写入磁盘上而且只要分派过就必须保留在物理内存中的对象)使用的一个区域。
Memory:Pool Nonpaged Bytes 的计数方式与 Process:Pool Nonpaged Bytes 的计数方式不同，
因此可能不等于 Pool Nonpaged Bytes\\_Total。 这个计数器仅显示上一次观察的值；而不是一个平均值。


Process:Working Set :某个进程的地址空间中，存放在物理内存的那一部份。包含shared memory 和private memory
Working Set 是在进程中被线程最近触到的那个内存页集。如果计算机上的可用内存处于阈值以上，
即使页不在使用中，也会留在一个进程的 Working Set中。当可用内存降到阈值以下，将从 Working Set 中删除页。
如果需要页时，它会在离开主内存前软故障返回到 Working Set 中。

Working Set - Private 仅用于这个进程并且不共享也不能为其他进程共享的专用显示作业集的大小。

Working Set Peak 指在任何时间这个在进程的 Working Set 的最大字节数。
　　
Process: Virtual Bytes:某个进程所申请的虚拟地址空间大小，包括reserved  Memory和Committed Memory.
使用虚拟地址空间不一定是指对磁盘或主内存页的相应的使用。虚拟空间是有限的，可能会限制处理加载数据库的能力。

Process:Private Bytes:某个进程的提交了的地址空间(committed Memory)中，非共享的部份。除去shared memory以外的committed memory
指这个进程不能与其他处理共享的、已分配的当前字节数。

目标：
使用内存最多的进程
内存使用量在不断增长的进程
出现问题的那个时间段里，内存使用数量发生过突变的进程.


总结：
内存不足，会引起服务器做大量的paging动作，从而也影响了其他系统资源，所以内存资源是第一个需要检查的系统资源。
从磁盘的繁忙程序，确认这个繁忙是否是和内存paging有关系。
从cpu的核心态，用户态时间，确认是否是因为系统做paging动作，频繁怕磁盘io动作造成的核心态时间过高。

1，首先确认服务器是32位还是64位，sqlserver是32位还是64位
2，观察计数值的趋势和相互之间的关系，切忌用一两个值就做出结论
3，分析从检查内存使用开始
4，别忘记了检查window系统自己的内存使用
5，观察应用进程的内存使用
	a)是不是private BYTES 一直往上涨
	b)是不是working SET 一直往上涨
	c)是不是也有handle leak 或 thread leak 的现象
	d)上涨是否引起了其他进程或系统的内存使用缩减
	e)它的使用量涨和系统所遇到的问题有没有关系？时间上是否能匹配？
6，分析内存使用对cpu和io使用的影响


SqlServer内存使用特性

默认最大的用户态地址空间是2GB,如果使用了/3GB参数或开启了 AWE，或者是在64位的机器上，sqlserver可以
使用更多的内存，sqlserver是个很喜欢内存资源的程序，它的理想状态，就是把所有可能会用到的数据和结构
都缓存在物理内存里，以达到最优的性能。

默认情况下，建议sqlServer 动态使用内存，它会定期查询系统以确定可用物理内存量


释放内存机制
Total Server Memory :SqlServer 自己分配的Buffer Pool 内存总和
Target Server Memory : sqlServer在理论上能够使用的最多的内存数目。

当sqlserver启动的时候，它会检查一下自己的虚拟地址空间，是否开启了AWE,sp_configure里的"max Server Memory"值，以及当
前服务器的可用物理内存数，其中取一个最小值，作为自己的Target server memory值。

在sqlServer运行的过程中，如果它感知到windows层面的内存压力，就会降低Target ServerMemory的大小，而sql Server又会定期
比较TotalServerMemory和TargetServerMemory两个值.

当Total Server Memory小于TargetServerMemory时，sqlserver知道系统还有足够的内存，所以在须要缓存任何新的数据时，就会分配新
的内存地址空间。从计数器上看，totalServerMemory的值会不断变大.

当Total Server Memory等于TargetServerMemory时，sqlServer 知道自己已经用足了系统能够给予的内存空间，如果需要缓存任何新的数
据，它不会再去分配新的内存空间，反过来，它会在自己现在的内存空间里清理动作，腾出空间来给新的数据使用。

当sqlServer收到windows内存压力信号，调小target ServerMemory值，使得Total Server Memory大于target Server Memory时，sqlserver
开始内存清理动作，调小自己的地址空间大小，释放内存。

total SERVER memory 和target SERVER memory都是指逻辑上的内存空间大小，而不是物理内存空间大小。数据是放在物理内
存还是放在page file里，sqlserver把这个决定权交给了windows.

合理分配sqlserver内存
1）WINDOWS系统和其他关键应用服务要有足够的内存，不要在运行过程中因为内存不足，而来抢sqlserver已经申请到的内存
这种情况在errorlog中会有这样的擎告信息：working SET (KB):3343434,COMMITTED(KB):232354,memory utilization:50%
注：这里的workingset代表os层面的workingset（就是性能日志监视器当中的那个值 ）+AWE分配的内存+通过大内丰面的方式分配的内存

2)安装64位操作系统，如果是32位系统，务必将awe打开，但是不要再使用/3gb开关。
3）尽量使用服务器专门供数据库使用，不要将其他服务(iis,中间层应用服务)安装在同一台机器上。
4）建议设置sqlserver MAX SERVER memory,确保window有足哆的内存供系统本身使用，如果是一台8GB机器，建议预留2gb,ymc 
置sqlmax SERVER memory 为6G，大于8G，预留3-4G,小于8G的，预留1G
5)赋给sqlserver启动帐号lock pages IN memory的权限。
6）SET working SET size这个sql系统参数在现在的window上不能起到固定sqlserver物理内存的作用，请永远不要使用。


*/