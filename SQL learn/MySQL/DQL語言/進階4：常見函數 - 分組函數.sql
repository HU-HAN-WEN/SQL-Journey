# 進階4：常見函數 - 分組函數

/*
 * 功能：用作統計使用，又稱為 聚合函數 或 統計函數 或 組函數
 * 
 * 分類：
 * 		sum 求和、avg 平均值、max 最大值、min 最小值、count 計算個數
 * 
 * 特點：
 * 		1. SUM(), AVG() 一般用於處理數值型
 * 		2. MAX(), MIN(), COUNT() 可以處理任何類型
 * 		3. 以上分組函數都忽略 null 
 * 		4. 可以和 distinct 搭配實現去重的運算
 * 		5. COUNT()函數的單獨介紹：『一般使用COUNT(*)用作統計函數』
 * 		6. 和分組函數一同查詢的字段要求是 group by 後的字段
 * 
 */

# 1. 簡單 的使用
SELECT SUM(payment_value ) FROM olist_order_payments ;
SELECT AVG(payment_value ) FROM olist_order_payments ;
SELECT MAX(payment_value ) FROM olist_order_payments ;
SELECT MIN(payment_value ) FROM olist_order_payments ;
SELECT COUNT(payment_value ) FROM olist_order_payments ;

SELECT
	SUM(oop.payment_value) 和,
	AVG(oop.payment_value) 平均,
	MAX(oop.payment_value) 最大,
	MIN(oop.payment_value) 最小,
	COUNT(oop.payment_value) 個數
FROM
	olist_order_payments oop ;

SELECT
	SUM(oop.payment_value) 和,
	ROUND(AVG(oop.payment_value), 3) 平均,
	MAX(oop.payment_value) 最大,
	MIN(oop.payment_value) 最小,
	COUNT(oop.payment_value) 個數
FROM
	olist_order_payments oop ;


# 2. 參數支持哪些類型

SELECT SUM(order_id ), AVG(order_id ) FROM olist_orders ; # 0 0

SELECT MAX(order_id ), MIN(order_id ) FROM olist_orders ;
SELECT MAX(order_estimated_delivery_date  ), MIN(order_estimated_delivery_date  ) FROM olist_orders ;

SELECT COUNT(order_id ) FROM olist_orders ;


# 3. 是否忽略 null

SELECT
	SUM(op.product_weight_g)
FROM
	olist_products op ;

SELECT
	AVG(op.product_weight_g),
	SUM(op.product_weight_g) / COUNT(*),
	SUM(op.product_weight_g) / COUNT(op.product_weight_g)
FROM
	olist_products op ;

SELECT
	MAX(op.product_weight_g),
	MIN(op.product_weight_g)
FROM
	olist_products op ;


# 4. 和 distinct 搭配 

SELECT
	SUM(DISTINCT op.product_weight_g), 
	SUM(op.product_weight_g)
FROM
	olist_products op ;

SELECT
	COUNT(DISTINCT op.product_weight_g), # 義同：計算有幾種重量
	COUNT(op.product_weight_g)
FROM
	olist_products op ;


# 5. COUNT()函數的詳細介紹

/*
 * 效率：
 * 		MyISAM 存儲引擎下，COUNT(*)的效率高
 * 		InnoDB 存儲引擎下，COUNT(*)和COUNT(1)的效率差不多，比COUNT('字段')要高一些
 * 
 * ---
 * MyISAM (較舊，但特定場景有用)：
 * 	特點：不支持事務 (Transaction)、不支持外鍵 (Foreign Key)、鎖定 granularity 是「表級鎖」（操作時會鎖住整張表）。讀取速度通常很快。
 * 	關鍵差異 (與 COUNT 相關)：MyISAM 會在表格的元數據 (metadata) 中直接儲存表格的總行數。
 * 
 * InnoDB (目前預設，功能最全面)：
 * 	特點：支持事務 (ACID)、支持外鍵、鎖定 granularity 是「行級鎖」（操作時只鎖住相關的行，並發性能更好）。功能最完善，是現在絕大多數情況下的首選和預設引擎。
 * 	關鍵差異 (與 COUNT 相關)：InnoDB 不直接儲存表格的總行數。因為 InnoDB 支持事務和 MVCC (多版本並發控制)，
 *  不同事務在同一時間看到的「有效行數」可能是不同的，所以維護一個即時準確的總行數成本很高且意義不大。
 */

SELECT
	COUNT(op.product_weight_g ) # 不返回NULL值
FROM
	olist_products op ;

# 常用的，計算行數
SELECT
	COUNT(*)
FROM
	olist_products op ;

SELECT
	COUNT(1)
FROM
	olist_products op ;

SELECT
	COUNT('崔俠')
FROM
	olist_products op ;


# 6. 和分組函數一同查詢的字段有限制

# SELECT AVG(op.product_weight_g), op.product_id FROM olist_products op ;
# 因為要求規則的表格，所以錯誤



# --- 練習 ---

# 1. 計算所有支付紀錄的整體情況，最大單筆支付金額、最小單筆支付金額、平均單筆支付金額以及總支付金額是多少？
# 對應表格：olist_order_payments
SELECT
	MAX(oop.payment_value) AS 最大單筆支付金額,
	MIN(oop.payment_value) AS 最小單筆支付金額,
	AVG(oop.payment_value) AS 平均單筆支付金額,
	SUM(oop.payment_value) AS 總支付金額
FROM
	olist_order_payments oop ;


# 2. 訂單數據涵蓋了多長的天？
# 對應表格：olist_orders
SELECT
	DATEDIFF(MAX(oo.order_purchase_timestamp), MIN(oo.order_purchase_timestamp))
FROM
	olist_orders oo ;

# 計算活著的天數
SELECT DATEDIFF(NOW(), '2001-12-15');


# 3. 總共有多少客戶是來自聖保羅州的？
# 對應表格：olist_customers
SELECT
	COUNT(*)
FROM
	olist_customers oc
WHERE
	oc.customer_state = 'SP' ;

