# 進階2：條件查詢
/*
 * 語法：
 * 		select
 * 				查詢列表 (順序：3)
 * 		from 
 * 				表名 (順序：1)
 * 		where
 * 				篩選條件; (順序：2)
 * 
 * 分類：
 *  	1. 按條件表達式篩選：
 * 		   			條件運算符：>, <, =, <>(不等於), >=, <=
 *  	2. 按邏輯表達式篩選：
 * 					作用：用於連接條件表達式
 * 		   			邏輯運算符：and(與 && ), or(或 || ), not(非 ! )
 * 
 * 					( and 與 && ：兩個條件皆為TURE，結果為TURE，反之則為FALSE)
 * 					( or 或 || ：只要有一個條件為TURE，結果為TURE，反之為FALSE)
 * 					( not 或 ! ：如果連接條件本身為FALSE，結果為TRUE，反之為FALSE)
 * 
 * 		3. 模糊查詢：
 * 					like
 * 					between and
 * 					in
 * 					is null | is not null
 */ 

# 1. 按條件表達式篩選
# 案例一：查詢消費金額 ＞ 200 的顧客訊息
SELECT
	*
FROM
	olist_order_payments
WHERE
	payment_value > 200;

# 案例二：哪些訂單目前還在運送途中或處理中？
SELECT
    order_id,
    customer_id,
    order_status,             -- 訂單狀態
    order_purchase_timestamp  -- 下單時間
FROM
    olist_orders
WHERE
    order_status <> 'delivered'; -- 篩選出訂單狀態不是 'delivered' (已送達) 的訂單
    
# 2. 按邏輯表達式篩選
# 案例一：2018 年第一季 (1月到3月) 的訂單有哪些？
SELECT
	order_id,
	customer_id,
	order_purchase_timestamp,
	-- 下單時間
	order_status
FROM
	olist_orders
WHERE
	order_purchase_timestamp >= '2018-01-01 00:00:00'
	-- 條件1: 時間 >= 2018年1月1日
	AND order_purchase_timestamp < '2018-04-01 00:00:00'; -- 條件2: 時間 < 2018年4月1日 (注意用 < 而不是 <= 來包含整個3月)

# 案例二：找出訂單狀態不是 'delivered' 或 是在 2018 年 8 月之後才下單的訂單
SELECT
    order_id,
    customer_id,
    order_status,             -- 訂單狀態
    order_purchase_timestamp  -- 下單時間
FROM
    olist_orders
WHERE
    NOT (order_status = 'delivered') -- 條件1: 狀態不是 'delivered'
    OR order_purchase_timestamp > '2018-08-01 00:00:00'; -- 條件2: 下單時間晚於 2018年8月1日

# 3. 模糊查詢：
/*
 * like
 * between and		
 * in	
 * is null
*/ 


# 1. like
/*
 * 特點：
 * 		一般和通配符搭配使用
 * 			通配符：
 * 				 ％ 任意多個字符，包含 0 個字符
 * 				 _ 任意單個字符
 */
    
# 案例一：找出城市名稱包含 "sao" 的客戶（例如 Sao Paulo, Sao Bernardo do Campo 等）
SELECT
	customer_unique_id,
	-- 客戶唯一ID
	customer_city,
	-- 城市
	customer_state
	-- 州
FROM
	olist_customers
WHERE
	customer_city LIKE '%sao%';

# 案例二：找出客戶所在州縮寫，第二個字母是 "P" 的客戶
SELECT
    customer_unique_id,
    customer_city,
    customer_state -- 州縮寫
FROM
    olist_customers
WHERE 
	customer_state LIKE '_P%'; 

# 案例三：(假設性)找出 product_id 中第三個字元是底線 _ 的產品
# 為了確保 LIKE 運算子能穩定地收到一個「用於轉義的單一反斜線」，最安全、最跨平台、最標準的寫法，就是在 SQL 字串中寫 \\
SELECT
	product_id
FROM
	olist_products
WHERE
	product_id LIKE '__\\_%';


# 2. between and
/*
 *  1. 使用 between and 可以提高語句的簡潔度
 *  2. 包含臨界值
 *  3. 兩個臨界值不可調換順序
 * 
 */

# 案例一：2018 年第一季 (1月到3月) 的訂單有哪些？
	## 原始
	SELECT
		order_id,
		customer_id,
		order_purchase_timestamp,
		-- 下單時間
		order_status
	FROM
		olist_orders
	WHERE
		order_purchase_timestamp >= '2018-01-01 00:00:00'
		-- 條件1: 時間 >= 2018年1月1日
		AND order_purchase_timestamp < '2018-04-01 00:00:00'; -- 條件2: 時間 < 2018年4月1日 (注意用 < 而不是 <= 來包含整個3月)
# ---  
	## between and
	SELECT
		order_id,
		customer_id,
		order_purchase_timestamp,
		-- 下單時間
		order_status
	FROM
		olist_orders
	WHERE
		order_purchase_timestamp BETWEEN '2018-01-01 00:00:00' and '2018-04-01 00:00:00';


# 3. in
/*
 *  含意：
 * 		判斷某字段的值是否屬於 in 列表中的某一項
 *  特點：
 * 		1. 使用 in 可以提高語句整潔度
 * 		2.  in 列表的值類型必須一致或兼容
 * 		3. 不支持通配符寫法 ex.AD_%
 */

# 範例：來自聖保羅 (SP)、里約熱內盧 (RJ) 和米納斯吉拉斯 (MG) 這三個主要州的客戶有哪些？
# OR 寫法
	SELECT
	    customer_unique_id,
	    customer_city,
	    customer_state -- 州
	FROM
	    olist_customers
	WHERE
		customer_state = 'SP' OR customer_state = 'RJ' OR customer_state = 'MG'; 

# in 寫法
	SELECT
	    customer_unique_id,
	    customer_city,
	    customer_state -- 州
	FROM
	    olist_customers
	WHERE
		customer_state IN ('SP', 'RJ', 'MG'); 


# is null

/*
 * is null 或 is not null 可以判斷 null 值
*/

# 範例一：哪些訂單可能因為付款失敗或其他原因，一直沒有進入到『付款已核准』的狀態？
-- 錯誤示範：嘗試找出付款核准時間為 NULL 的訂單 (通常不會返回任何結果)
	SELECT
	    order_id,
	    customer_id,
	    order_status,
	    order_approved_at -- 付款核准時間
	FROM
	    olist_orders
	WHERE
	    order_approved_at = NULL; -- 錯誤： = 不能用來判斷 NULL

-- 正確寫法：找出付款核准時間為 NULL 的訂單
	SELECT
	    order_id,
	    customer_id,
	    order_status,
	    order_approved_at -- 付款核准時間
	FROM
	    olist_orders
	WHERE
	    order_approved_at IS NULL; -- 正確：使用 IS NULL 來判斷是否為空


# 範例二：哪些訂單有進入到『付款已核准』的狀態？
SELECT
	order_id,
	customer_id,
	order_status,
	order_approved_at -- 付款核准時間
FROM
	olist_orders
WHERE
	order_approved_at IS NOT NULL;


# 安全等於   <=>

# 範例一：哪些訂單可能因為付款失敗或其他原因，一直沒有進入到『付款已核准』的狀態？
	SELECT
	    order_id,
	    customer_id,
	    order_status,
	    order_approved_at -- 付款核准時間
	FROM
	    olist_orders
	WHERE
	    order_approved_at <=> NULL;

# 範例二：找出付款分期數「安全等於」1 的支付紀錄
SELECT
    order_id,
    payment_type,
    payment_installments, -- 分期數
    payment_value
FROM
    olist_order_payments
WHERE
    payment_installments  <=> 1; -- 找出分期數 安全等於 1 的紀錄



# is null vs <=>
# is null：僅可判斷 NULL 值，可讀性較高
#   <=>  ：既可判斷 NULL 值，亦可判斷普通數值，可讀性較低



# ---
/*
 * 問題：
 * 		(1) SELECT * (查詢所有欄位)
 * 				優點：
 * 					- 方便快捷
 * 					- 完整性
 * 				缺點：
 * 					- 效能較差、造成不必要的資源浪費 (網路頻寬、記憶體)
 * 					- 可讀性較差
 * 					- 程式碼脆弱(如果未來表格結構改變（例如新增或刪除欄位），程式碼或報表可能會出錯。)
 * 		(2) SELECT column1, column2, ... (指定特定欄位)
 * 				優點：
 * 					- 效能較好、更穩定
 * 					- 意圖明確
 * 				缺點：
 * 					- 需要多打一些字
 */

    
    
# 練習
# 1. 查詢付款金額大於 1000 的支付紀錄
# 表格：olist_order_payments
SELECT 
	*
FROM
	olist_order_payments
WHERE
	payment_value >= 1000;

# 2. 查詢特定客戶 (customer_id) 的訂單，並顯示客戶城市 (如果城市是 NULL 則顯示 '未知城市')
# 表格：olist_orders, olist_customers (需要分兩步查詢，或假設我們已知 customer_id 對應的城市)
# 注意：範例 IFNULL 用於計算，這裡我們用它來處理 NULL 值的顯示。

/*
 * 解法：
 * -- 模擬城市為 NULL 的情況
 */

SELECT
    order_id,
    customer_id,
    order_status,
    NULL AS original_city, -- 模擬城市資訊缺失
    IFNULL(NULL, '未知城市') AS display_city -- 這裡會顯示 '未知城市'
FROM
    olist_orders
WHERE
    order_id = 'e481f51cbdc54678b7cc49136f2d6af7'; -- 請替換成資料庫中真實存在的 order_id



# 3. 查詢產品重量不在 100g 到 500g 之間的產品
# 表格：olist_products    
SELECT
	*
FROM
	olist_products
WHERE
	product_weight_g < 100
	OR product_weight_g > 500;
/*
 * 建議：
 * 		NOT BETWEEN 100 AND 500 在功能上等同於 < 100 OR > 500。
 * 		只是 NOT BETWEEN 更簡潔一些。
 */
SELECT
    product_id,
    product_category_name,
    product_weight_g -- 產品重量
FROM
    olist_products
WHERE
    product_weight_g NOT BETWEEN 100 AND 500; -- 篩選重量不在 100g 到 500g 之間 (包含頭尾) 的產品


# 4. 查詢聖保羅州 ('SP') 或里約熱內盧州 ('RJ') 的客戶
# 表格：olist_customers    
SELECT 
	customer_id,
	customer_state
FROM
	olist_customers
WHERE
	customer_state = 'SP'
	OR customer_state = 'RJ';
/*
 * 建議：
 * 		state = 'SP' OR state = 'RJ' 在功能上等同於 state IN ('SP', 'RJ')。
 * 		當選項不多時，OR 也可以接受，但當選項變多時，IN 會更易讀、更推薦。
 */
SELECT 
	customer_id,
	customer_state
FROM
	olist_customers
WHERE
	customer_state IN ('SP', 'RJ');


# 5. 查詢尚未實際送達客戶的訂單
# 表格：olist_orders    
SELECT 
	*
FROM
	olist_orders
WHERE
	NOT(order_status = 'delivered');
/*
 * 建議：
 * 		NOT(order_status = 'delivered') 是有效的語法。
 * 		更常見的寫法是 order_status != 'delivered' 或 order_status <> 'delivered'。
 */


# 6. 查詢付款已核准的訂單
# 表格：olist_orders    
SELECT 
	*
FROM
	olist_orders
WHERE
	order_approved_at IS NOT null;
    
# 7. 查詢客戶城市名稱第三個字母是 'n' 的客戶
# 表格：olist_customers    
SELECT 
	*
FROM
	olist_customers
WHERE
	customer_city LIKE '__n%';
    
# 8. 查詢客戶城市名稱中同時包含 'a' 和 'o' 的客戶
# 表格：olist_customers
SELECT
	*
FROM
	olist_customers
WHERE
	customer_city LIKE '%a%'
	AND customer_city LIKE '%o%' ;
    

# 9. 查詢賣家城市名稱以 'o' 結尾的賣家
# 表格：olist_sellers
SELECT
	*
FROM
	olist_sellers
WHERE
	seller_city LIKE '%o';

# 10. 查詢訂單商品價格介於 80 到 100 之間的品項
# 表格：olist_order_items
SELECT
	*
FROM
	olist_order_items
WHERE
	price BETWEEN 80 AND 100 ;


# 11. 查詢使用特定幾種方式付款的紀錄
# 表格：olist_order_payments
SELECT
    order_id,
    payment_type,
    payment_value
FROM
    olist_order_payments
WHERE
    payment_type IN ('boleto', 'voucher', 'debit_card');


# 12. 古典面試題:
/*試間:select**from employees;
 * 和select * from emplovees where commission_pct like '%%' and last_name like '%%';
 * 結果是否一樣?並說明原因
 */

# 不一樣!
# 如果判斷的欄位有nu11值

# 如果是select * from emplovees where commission_pct like '%%' or last_name like '%%';
# 就一樣