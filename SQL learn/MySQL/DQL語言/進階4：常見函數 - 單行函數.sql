# 進階4：常見函數 - 單行函數

/*
 * 概念: 類似java的方法,將一組邏輯語句封裝在方法體中,對外暴露方法名
 * 好處:
 * 		1、隱藏了實作細節 
 * 		2、提高程式碼的重用性
 * 呼叫:
 * 		select 函數名(實參列表) 【from表】;
 * 特點:
 * 		1、叫什麼(函數名)
 * 		2、做什麼(函數功能)
 * 分類:
 * 		1、單行函數，如concat、length、ifnull等
 * 
 * 		2、分組函數
 * 				功能:做統計使用,又稱為統計函數、聚合函數、群組函數
 * 
 * 常見函數：
 * 		字符函數：
 * 			length():字符串长度
 * 			concat():拼接字符串
 * 			substr()：擷取字符串
 * 			instr()：返回字符串
 * 			trim():去除前后字符串，默認為空格
 * 			upper()：轉換為大寫
 * 			lower()：轉換為小寫
 * 			lpad()：字符串左填充
 * 			rpad()：字符串右填充
 * 			replace():字符串替换
 * 
 * 		數學函數：
 * 			round()：四捨五入
 * 			ceil()：向上取整，返回大於等於該參數的最小整數
 * 			floor()：向下取整，返回小於等於該參數的最大整數
 * 			truncate()：數值截斷
 * 			mod()：數值取餘
 * 
 * 		日期函數：
 * 			now()：返回當前系統日期+時間
 * 			curdate()：返回當前系統的日期，不包含時間
 * 			curtime()：返回當前時間，不包含日期
 * 			year()：年
 * 			month()：月
 * 			monthname()：英文月份
 * 			day()：日
 * 			hour()：小時
 * 			minute()：分鐘
 * 			second()：秒
 * 			str_to_date()：將字符通過指定格式轉換為日期
 * 			date_format()：將日期轉換成字符
 * 
 * 		其他函數：
 * 			version()：查詢當前版本號
 * 			database()：查詢當前數據庫
 * 			user()：查詢當前用戶
 * 
 * 		控制函數：
 * 			if： if else 的效果
 * 			else：
 * 				1. 類似java的switch case的效果
 * 				2. 類似於java中的 多重if效果
 */

# 一、字符函數

# length 獲取參數值的字節個數
SELECT
	LENGTH('john');
SELECT
	LENGTH('張三丰hahaha'); # 1 個英文字母母 1 個字節； 1 個中文 3 個字節(utf8)

# 字符集
SHOW variables LIKE '%char%' ;


# 2. concat 拼接字符串
SELECT 
	CONCAT(oc.customer_city , '_', oc.customer_state ) AS 居住地
FROM 
	olist_customers oc ;


# 3. upper, lower
SELECT UPPER('john');
SELECT LOWER('joHn');
# 示例：將城市變大寫，州名變小寫，拼接
SELECT
	CONCAT(UPPER(oc.customer_city), LOWER(oc.customer_state)) 居住地
FROM 
	olist_customers oc ;


# 4. substr, substring
# 注意：索引從 1 開始
# 擷取從指定索引處到後面所有字符
SELECT
	SUBSTR('李莫愁愛上了陸展元', 7) out_put; # 陸展元
# 擷取從指定索引處到指定字符長度的字符
SELECT
	SUBSTR('李莫愁愛上了陸展元', 1, 3) out_put; # 李莫愁

# 案例：城市首字符大寫，其他字符小寫，然後用_拼接顯示出來
SELECT
	CONCAT(UPPER(SUBSTR(oc.customer_city, 1, 1)), '_', LOWER(substr(oc.customer_city, 2))) AS out_put
FROM
	olist_customers oc ;


# 5. instr 返回子串第一次出現的索引，如果找不到返回0
SELECT INSTR('楊不悔愛上了殷六俠', '殷六俠') AS out_put; # 7
SELECT INSTR('楊不悔殷六俠愛上了殷六俠', '殷六俠') AS out_put;  # 4
SELECT INSTR('楊不悔愛上了殷六俠', '殷八俠') AS out_put; # 0


# 6. trim 去除前後符號
SELECT LENGTH(TRIM('       張翠山      ')) AS out_put;
SELECT TRIM('a' FROM 'aaaaaaaaa張aaa翠山aaaaaaa') AS out_put; # 張aaa翠山
SELECT TRIM('aa' FROM 'aaaaaaaaa張aaa翠山aaaaaaa') AS out_put; # a張aaa翠山a
	
	
# 7. lpad 用指定字符實現左填充指定長度
SELECT LPAD('殷素素', 10, '*') AS out_put; # *******殷素素
SELECT LPAD('殷素素', 2, '*') AS out_put; # 殷素
	
	
# 8. rpad 用指定字符實現右填充指定長度
SELECT RPAD('殷素素', 12, 'ab') AS out_put; # 殷素素ababababa

	
# 9. replace 替換
SELECT REPLACE('張無忌愛上了周芷若','周芷若','趙敏') AS out_put; # 張無忌愛上了趙敏
SELECT REPLACE('周芷若周芷若周芷若周芷若周芷若張無忌愛上了周芷若','周芷若','趙敏') AS out_put; # 趙敏趙敏趙敏趙敏趙敏張無忌愛上了趙敏
	
	

# 二、數學函數	

# 1. round 四捨五入
SELECT ROUND(2.462);
SELECT ROUND(2.436853, 2); # 2.44 --> 保留小數點後第 2 位


# 2. ceil 向上取整，返回大於等於該參數的最小整數
SELECT ceil(4.003);
SELECT ceil(-4.003);
	
	
# 3. floor 向下取整，返回小於等於該參數的最大整數
SELECT FLOOR(-9.99); # 10
SELECT floor(9.99);


# 4. truncate 截斷
SELECT TRUNCATE(1.3563, 1); # 1.3


# 5. mod 取餘
/*
 * mod(a,b)：  a - ( ( int )( a/b ) ) * b ;
 * mod(-10, -3)：-10 - ((int)(-10/-3)) * -3 = -1
 */
SELECT mod(10, 3);
SELECT 10 % 3 ;
SELECT mod(-10, -3); # -1



# 三、日期函數

# 1. now 返回當前系統日期+時間
SELECT now();


# 2. curdate 返回當前系統的日期，不包含時間
SELECT CURDATE();


# 3. curtime 返回當前時間，不包含日期
SELECT CURTIME();


# 4. 可以獲取指定的部分：年、月、日、小時、分鐘、秒
SELECT
	YEAR(now()) 年;

SELECT
	YEAR('1998-01-01') 年;

SELECT
	YEAR(oo.order_purchase_timestamp) 年
FROM
	olist_orders oo ;

SELECT
	MONTH (now()) 月 ;

SELECT
	MONTHNAME(now()) 月 ; # 英文月份

SELECT
	DAY(now()) 日 ;

SELECT
	HOUR(NOW()) 小時 ;

SELECT
	MINUTE(now()) 分 ;

SELECT
	SECOND(now()) 秒 ;



# 5. str_to_date 將字符通過指定格式轉換為日期
SELECT str_to_date('2001-4-5', '%Y-%c-%d') AS out_put;

# 查詢客戶下單時間為2017-10-26 15:54:26的顧客訊息
SELECT
	*
FROM
	olist_orders oo
WHERE
	order_purchase_timestamp = '2017-10-26 15:54:26';

SELECT
	*
FROM
	olist_orders oo
WHERE
	oo.order_purchase_timestamp = str_to_date('10-26-2017 15:26:54', '%m-%d-%Y %H:%s:%i') ;

	
# 6. date_format 	將日期轉換成字符
SELECT DATE_FORMAT(NOW(), '%y年%m月%d日') AS out_put ;

# 範例：查詢所有訂單ID、客戶ID和客戶下單時間(指定為 XX月/XX日 XX年)
SELECT
	oo.order_id ,
	oo.customer_id ,
	DATE_FORMAT(oo.order_purchase_timestamp, '%m/%d %y') AS 下單日期
FROM
	olist_orders oo ;



# 四、其他函數

# 查詢當前版本號
SELECT
	version();

# 查詢當前數據庫
SELECT
	DATABASE() ;

# 查詢當前用戶
SELECT
	USER() ;



# 五、流程控制函數

# 1. if 函數： if else 的效果
SELECT
	IF(10 < 5, '大', '小') ; # 小

SELECT
	IF(10 > 5, '大', '小') ; # 大
	
SELECT
	oop.order_id ,
	oop.payment_value ,
	IF(oop.payment_value > 1000, '挖歐！有錢人', '可憐QQ') AS 備註
FROM
	olist_order_payments oop ;


# 2. case 函數的使用一： 類似java的switch case的效果

/*
 * java 中：
 * switch(變量或表達式){
 * 		case 常量1：語句1 ; break ;
 * 		...
 * 		default:語句n ; break ;
 * }
 * 
 * 
 * mySQL中：
 * case 要判斷的字段或表達式
 * when 常量1 then 要顯示的值1 或是語句1 ;
 * when 常量2 then 要顯示的值2 或是語句2 ;
 * ...
 * else 要顯示的值n 或是語句n ;
 * end
 */

/*
 * 案例：根據訂單的付款方式，快速區分出處理的優先級。
 * 例如，信用卡 ('credit_card') 優先級第一，Boleto ('boleto') 次之，優惠券 ('voucher')第三，其他的第四。
 */

SELECT
	oop.order_id ,
	oop.payment_type ,
	CASE
		oop.payment_type 
		WHEN 'credit_card' THEN '第一'
		WHEN 'boleto' THEN '第二'
		WHEN 'voucher' THEN '第三'
		ELSE '第四'
	END AS 處理優先級
FROM
	olist_order_payments oop ;


# 3. case 函數的使用二：類似於java中的 多重if

/*
 * java中：
 * if(條件 1 ){
 * 			語句 1 ;
 * }else if(條件 2 ){
 * 			語句 2 ;
 * }
 * ...
 * else{
 * 			語句 n ;
 * }
 * 
 * 
 * mySQL中：
 * case
 * when 條件 1 then 要顯示的值 1 或語句 1 
 * when 條件 2 then 要顯示的值 2 或語句 2 
 * ...
 * else 要顯示的值 n 或語句 n 
 * end
 */

/*
 * 案例：查詢顧客付款金額的情況
 * 如果付款金額 > 1000, 顯示 A級別
 * 如果付款金額 > 800, 顯示 B級別
 * 如果付款金額 > 600, 顯示 C級別
 * 如果付款金額 > 400, 顯示 D級別
 * 否則，顯示 E級別
 */

SELECT
	order_id ,
	payment_value ,
	CASE
		WHEN payment_value > 1000 THEN 'A'
		WHEN payment_value > 800 THEN 'B'
		WHEN payment_value > 600 THEN 'C'
		WHEN payment_value > 400 THEN 'D'
		ELSE 'E'
	END AS 金額級別
FROM
	olist_order_payments ;




# --- 練習 ---
# 1. 顯示當前系統時間 (註： 日期+時間)
SELECT
	NOW();

# 2. 估算一個商品的『總成本價』，可以簡單地認為是商品價格 (price) 加上運費 (freight_value) 的 10%。如果運費未知 (NULL)，則不計算運費加權。
# 對應表格：olist_order_items
SELECT
	ooi.order_id ,
	ooi.product_id ,
	ooi.price ,
	ooi.freight_value ,
	ooi.price + ooi.freight_value * 0.1 AS 總成本價
FROM
	olist_order_items ooi ;

# 3. 哪些賣家的城市名稱比較簡短？
# 對應表格：olist_sellers
SELECT
	os.seller_id ,
	os.seller_city ,
	os.seller_state ,
	LENGTH(os.seller_city) 城市名稱長度
FROM
	olist_sellers os
ORDER BY
	城市名稱長度 ASC;

# 4. 生成一個字串，能清晰地描述每個客戶所在的城市和州。
# 對應表格：olist_customers
SELECT
	oc.customer_id ,
	oc.customer_city ,
	oc.customer_state ,
	CONCAT(oc.customer_id , '居住在', oc.customer_city , '位於', oc.customer_state ) AS 資訊
FROM
	olist_customers oc ;

# 5. 想將訂單狀態歸納為幾個主要類別，方便統計：
# 處理中 ('processing', 'approved')、已出貨 ('shipped')、已送達 ('delivered')、有問題 ('unavailable', 'canceled')。
# 對應表格：olist_orders
SELECT
	oo.order_id ,
	oo.customer_id ,
	oo.order_status ,
	CASE
		WHEN oo.order_status IN('processing', 'approved') THEN '處理中'
		WHEN oo.order_status IN('shipped') THEN '已出貨'
		WHEN oo.order_status IN('delivered') THEN '已送達'
		WHEN oo.order_status IN('unavailable', 'canceled') THEN '有問題'
		ELSE '其他狀態'
	END AS 訂單狀態
FROM
	olist_orders oo ;

# 如果用方法一
SELECT
	oo.order_id ,
	oo.customer_id ,
	oo.order_status ,
	CASE oo.order_status 
		WHEN 'processing' THEN '處理中'
		WHEN 'approved' THEN '處理中'
		WHEN 'shipped' THEN '已出貨'
		WHEN 'delivered' THEN '已送達'
		WHEN 'unavailable' THEN '有問題'
		WHEN 'canceled' THEN '有問題'
		ELSE '其他狀態'
	END AS 訂單狀態
FROM
	olist_orders oo ;

/*
 * 總結兩者區別：
 * 		方法一：適用於單一欄位與單一常量的等於比較。
 * 
 * 		方法二：適用於任何複雜的條件判斷，包括：
 * 			範圍比較 (>, <, BETWEEN)
 * 			多值比較 (IN, NOT IN)
 * 			模糊比較 (LIKE)
 * 			空值判斷 (IS NULL)
 * 			多欄位組合 (AND, OR)
 */
