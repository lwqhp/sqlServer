Create Table #tmp(
work_code	Varchar(10)	Null,
min_seq		Integer		Null,
mstrmk		Char(1)		Null)

Insert Into #tmp(work_code,mstrmk)
Select work_code,'N'
From skills
Group By work_code
Having Count(*) > 1
Order By work_code

Update #tmp Set min_seq = (Select Min(sid) From skills Where skills.work_code = #tmp.work_code)

Update #tmp
Set mstrmk = 'Y'
Where Exists(Select * From skills Where skills.work_code = #tmp.work_code And Not(skills.master is null Or skills.master = ''))

Select * From #tmp

-- Delete From skills
-- Where Exists(Select * From #tmp Where #tmp.work_code = skills.work_code And #tmp.mstrmk = 'N' And #tmp.min_seq <> skills.sid) Or
-- 	(Exists(Select * From #tmp Where #tmp.work_code = skills.work_code And #tmp.mstrmk = 'Y') And (skills.master is null or skills.master = ''))