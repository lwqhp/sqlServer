-- 测试数据
DECLARE @t TABLE(
	No varchar(10))
INSERT @t SELECT '1'
UNION ALL SELECT '3'
UNION ALL SELECT '302'
UNION ALL SELECT '305'
UNION ALL SELECT '305001'
UNION ALL SELECT '305005'
UNION ALL SELECT '6'
UNION ALL SELECT '601'

-- 重排编码
UPDATE A SET 
	No = RIGHT(( -- 重排第一级编码
					SELECT
						COUNT(DISTINCT No)
					FROM @t
					WHERE LEN(No) = 1   -- 判断是否第一级编码
						AND No <= A.No  -- 仅统计截止当前记录为止, 出现过的一级编码的次数
				), 1)
		+ CASE  -- 重排第二级编码
				WHEN LEN(No) > 1        -- 仅处理包含第二级编码的记录
					THEN RIGHT(100 + (
									SELECT
										COUNT(DISTINCT No)
									FROM @t
									WHERE No LIKE LEFT(A.NO, 1) + '__'  -- 判断是否第二级编码
										AND No <= A.No -- 仅统计截止当前记录为止, 出现过的二级编码的次数
								), 2)
				ELSE ''
			END
		+ CASE -- 重排第三级编码
			WHEN LEN(No) > 3           -- 仅处理包含第三级编码的记录
				THEN RIGHT(1000 + (
								SELECT
									COUNT(DISTINCT No)
								FROM @t
								WHERE No LIKE LEFT(A.NO, 3) + '___' -- 判断是否第三级编码
									AND No <= A.No -- 仅统计截止当前记录为止, 出现过的三级编码的次数
								), 3)
			ELSE '' END
FROM @t A

-- 显示处理结果
SELECT * FROM @t
/*--结果
No
----------
1
2
201
202
202001
202002
3
301
--*/
