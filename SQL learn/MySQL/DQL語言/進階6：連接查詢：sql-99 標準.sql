# 進階6：連接查詢二：sql-99標準

# 注意：ON 子句完全不在乎這兩個欄位的「名稱」是否相同。它只在乎這兩個欄位裡的「資料 (值)」是否有邏輯上的關聯性。
# 更新表單：UPDATE ... SET ... WHERE ...

# 建議：盡量不要使用 RIGHT JOIN。
# 可以把 FROM A RIGHT JOIN B 完美地改寫成 FROM B LEFT JOIN A，這樣可以讓 SQL 閱讀順序永遠保持從左到右，更易於理解。

/*
 * 語法：
 * 		select 查詢列表
 * 		from 表1 別名	【連接列表】
 * 		join 表2 別名 
 * 		on 連接條件
 * 		【where 篩選條件】
 * 		【group by 分組】
 * 		【having 篩選條件】
 * 		【order by 排序列表】
 * 
 * 連接列表：
 * 		內連接(重要)：inner
 * 		外連接
 * 				左外(重要)：left 【outer】
 * 				右外(重要)：right 【outer】
 * 				全外：full 【outer】
 * 		交叉連接：cross
 * 
 */

# 一、內連接
/*
 * 語法：
 * 		select 查詢列表
 * 		from 表1 別名
 * 		inner join 表2 別名 
 * 		on 連接條件 ;
 * 
 * 分類：
 * 		等值
 * 		非等值
 * 		自連接
 * 
 * 特點：
 * 		1. 添加排序、分組、篩選
 * 		2. inner 可省略
 * 		3. 篩選條件放在 where 後面，連接條件放在 on 後面，提高分離性，便於閱讀
 * 		4. inner join 連接和 sql-92 語法中的等值連接效果相同，都是查尋多表的交集
 * 
 */

# 1. 等值連接
# 案例一：查詢每一筆訂單的狀態 (order_status)，以及下這筆訂單的客戶所在的城市 (customer_city) 是哪裡？
# 對應表格：olist_orders, olist_customers
SELECT
	oo.order_status,
	oc.customer_city
FROM
	olist_orders oo
INNER JOIN olist_customers oc ON
	oo.customer_id = oc.customer_id ;

# 案例二：所有產品類別名稱包含 'informatica' (電腦) 的商品，它們在訂單中的銷售價格 (price) 各是多少？ (添加篩選)
# 對應表格：olist_order_items, olist_products
SELECT
	op.product_category_name,
	ooi.price
FROM
	olist_order_items ooi
INNER JOIN olist_products op ON
	ooi.product_id = op.product_id
WHERE
	op.product_category_name LIKE '%informatica%' ;

# 案例三：來自聖保羅州的客戶，統計他們總共產生了多少 delivered 訂單、多少 shipped 訂單、多少 canceled 訂單？ (添加分組+篩選)
# 對應表格：olist_orders, olist_customers
SELECT
	oo.order_status,
	count(*) 訂單個數
FROM
	olist_orders oo
INNER JOIN olist_customers oc ON
	oc.customer_id = oo.customer_id
WHERE
	oc.customer_state = 'SP'
GROUP BY
	oo.order_status ;

# 案例四：每個賣家所在的城市 (seller_city) 的總銷售額 (SUM(price)) 是多少？並且只顯示那些總銷售額超過 50000 的城市，按銷售額降序排列。 (添加排序)
# 對應表格：olist_order_items, olist_sellers

# (1)每個賣家所在的城市 (seller_city) 的總銷售額 (SUM(price)) 
SELECT
	os.seller_city,
	SUM(ooi.price)
FROM
	olist_order_items ooi
INNER JOIN olist_sellers os ON
	ooi.seller_id = os.seller_id
GROUP BY
	os.seller_city ;

# (2)在(1)的基礎上篩選總銷售額超過 50000 的城市，並排序
SELECT
	os.seller_city,
	SUM(ooi.price) 總銷售額
FROM
	olist_order_items ooi
INNER JOIN olist_sellers os ON
	ooi.seller_id = os.seller_id
GROUP BY
	os.seller_city
HAVING
	總銷售額 > 50000
ORDER BY
	總銷售額 DESC ;

# 案例五：每筆訂單的下單時間 (order_purchase_timestamp)、客戶所在的州 (customer_state)，以及該筆訂單的付款方式 (payment_type) 是什麼？按訂單時間降序排列。
# 三表連接：customers -> orders -> order_payments
SELECT
	oo.order_purchase_timestamp,
	oc.customer_state,
	oop.payment_type
FROM
	olist_orders oo
	-- 必須與連接表都有連接條件(重要)
INNER JOIN olist_customers oc ON
	oo.customer_id = oc.customer_id
INNER JOIN olist_order_payments oop ON
	oo.order_id = oop.order_id
ORDER BY
	oo.order_purchase_timestamp DESC ;

# 案例五另一種方法
SELECT
	oo.order_purchase_timestamp,
	oc.customer_state,
	oop.payment_type
FROM
	olist_customers oc
JOIN
    olist_orders oo ON
	oc.customer_id = oo.customer_id
JOIN
    olist_order_payments oop ON
	oo.order_id = oop.order_id
ORDER BY
	oo.order_purchase_timestamp DESC;


# 2. 非等值連接

# 範例：查詢顧客消費金額級別(grade_level)個數，並按交費級別降續
# 對應表格：olist_order_payments oop 和payment_value_grades pvg
SELECT
	count(*),
	pvg.grade_level
FROM
	olist_order_payments oop
INNER JOIN payment_value_grades pvg ON
	oop.payment_value BETWEEN pvg.lowest_value AND pvg.highest_value
GROUP BY
	pvg.grade_level
ORDER BY
	pvg.grade_level DESC;


# 3. 自連接

# 範例：找出哪些客戶是『回頭客』。如果一個客戶下了多筆訂單，請幫我列出他們的『訂單配對』（例如，訂單 A 和 訂單 B 來自同一個客戶）。
# 對應表格：olist_customers (自連接)
SELECT
	*
FROM
	olist_customers oc1
INNER JOIN olist_customers oc2 ON
	oc1.customer_unique_id = oc2.customer_unique_id
WHERE
	oc1.customer_id != oc2.customer_id
	AND oc1.customer_id < oc2.customer_id -- 避免 (A,B) 和 (B,A) 這種重複配對
LIMIT 100 ;



# 二、外連接


/*
 * 應用場景：用於查詢一個表中有，另一個表沒有的紀錄
 * 
 * 特點：
 * 1. 外連接查詢結果為主表中的所有紀錄：
 * 			如果從表中有和它匹配的，則顯示 匹配值
 * 			如果從表中無和它匹配的，則顯示 NULL
 * 			外連接查詢結果 = 內連接結果 + 主表中有而從表中沒有的紀錄
 * 2. 左外連接，left join 左邊的是主表
 * 3. 右外連接，right join 右邊的是主表
 * 4. 左外和右外交換兩個表的順序，可以實現同樣的效果
 * 5. 全外連接 = 內連接的結果 + 表1中有但表2中沒有的 + 表2中有但表1中沒有的
 */

# 案例：列出所有的賣家，並嘗試找出他們的經緯度。顯示 geolocation 表中剛好沒有他們那個郵遞區號的經緯度資訊。

# 左外連接
SELECT 
	os.seller_id,
	os.seller_city,
	os.seller_zip_code_prefix,
	og.geolocation_zip_code_prefix,
	og.geolocation_lat,
	og.geolocation_lng
FROM
	olist_sellers os
LEFT outer JOIN 
	olist_geolocation og ON
	os.seller_zip_code_prefix = og.geolocation_zip_code_prefix
WHERE
	og.geolocation_lat IS NULL ;


# 右外連接
SELECT 
	os.seller_id,
	os.seller_city,
	os.seller_zip_code_prefix,
	og.geolocation_zip_code_prefix,
	og.geolocation_lat,
	og.geolocation_lng
FROM
	olist_geolocation og
RIGHT OUTER JOIN 
	olist_sellers os ON
	os.seller_zip_code_prefix = og.geolocation_zip_code_prefix
WHERE
	og.geolocation_lat IS NULL ;


# 全外連接 - mySQL不支持
/*
 * 
SELECT 
	os.seller_id,
	os.seller_city,
	os.seller_zip_code_prefix,
	og.geolocation_zip_code_prefix,
	og.geolocation_lat,
	og.geolocation_lng
FROM
	olist_geolocation og
FULL OUTER JOIN 
	olist_sellers os ON
	os.seller_zip_code_prefix = og.geolocation_zip_code_prefix
WHERE
	og.geolocation_lat IS NULL ;
 * 
 * 
 */


# 交叉連接 (笛卡爾乘積)
# 範例：『每個賣家』和『每種產品類別』所有可能的組合。
SELECT
    s.seller_id,
    s.seller_city,
    t.product_category_name_english
FROM
    olist_sellers AS s
CROSS JOIN
    product_category_name_translation AS t -- 使用 CROSS JOIN
LIMIT 100; -- 關鍵！只看前 100 筆組合結果，必須使用 LIMIT 來限制結果


# sql-92 vs sql-99

# 功能：sql-99 支持的較多
# 可讀性：sql-99 實現連接條件和篩選條件的分離，可讀性較高



# --- 練習 ---

# 範例一：查看所有在 2018 年 8 月下的訂單 (olist_orders)，以及它們對應的付款方式 (olist_order_payments)。
# 如果某筆訂單（例如剛建立或已取消）還沒有付款資訊，也要列出來，付款方式顯示為 NULL。
# 對應表格：olist_orders, olist_order_payments
SELECT
	oo.order_id,
	oo.order_purchase_timestamp,
	oop.payment_type,
	oop.payment_value
FROM
	olist_orders oo
LEFT OUTER JOIN olist_order_payments oop ON
	oo.order_id = oop.order_id
WHERE
	oo.order_purchase_timestamp BETWEEN '2018-08-01' AND '2018-09-01' ;


# 範例二：產品庫 (olist_products) 裡有 3 萬多種產品，但有哪些產品是一次都沒有被客戶購買過（即從未出現在 olist_order_items 表中）的？
# 對應表格：olist_products, olist_order_items
SELECT
	op.product_id ,
	op.product_category_name
FROM
	olist_products op
LEFT OUTER JOIN olist_order_items ooi ON
	ooi.product_id = op.product_id
WHERE
	ooi.order_id IS NULL ;


# 範例三：查詢所有使用『Boleto (現金支付)』或『Voucher (優惠券)』(olist_order_payments) 付款的訂單，
# 它們的訂單狀態 (olist_orders) 和下單時間各是什麼？
# 對應表格：olist_orders, olist_order_payments
SELECT
	oo.order_id,
	oo.order_purchase_timestamp ,
	oop.payment_type
FROM
	olist_orders oo
INNER JOIN olist_order_payments oop ON
	oo.order_id = oop.order_id
WHERE
	oop.payment_type IN ('Boleto', 'Voucher') ;




# 補充：怎麼判斷是用內連接、左外、右外、全外還是交叉？

# 第一步：需要『笛卡爾乘積』嗎？
# 情境：「我想看『所有 T-shirt』和『所有褲子』的所有可能搭配。」
# 答案：是 → 使用 CROSS JOIN。
# 備註：這在真實分析中極少使用，99% 的情況下是您忘了寫 ON 條件。

# 第二步：是否『只』關心在兩張表中『都存在』的匹配紀錄？
# 情境：「我想看所有『成功下單的客戶』的『訂單資訊』。」 (我不需要那些沒下過單的客戶，我也不需要那些沒有客戶資訊的幽靈訂單。)
# 答案：是 → 使用 INNER JOIN (或簡寫 JOIN)。
# 備註：這是最常用的 JOIN 類型。

# 第三步：是否需要保留『左邊』表格的『所有』紀錄，不管它在右邊有沒有匹配？
# 情境：「我想看『所有』客戶的名單，以及他們『可能存在』的訂單。如果客戶沒下過單，訂單欄位顯示 NULL 即可。」
# 答案：是 → 使用 LEFT JOIN (或 LEFT OUTER JOIN)。

# 第四步：(第三步的延伸) 是否『只』想找出『左邊』表格中，那些在『右邊』表格『找不到匹配』的紀錄？
# 情境：「我想看所有『從未下過單』的客戶。」
# 答案：是 → 使用 LEFT JOIN ... WHERE 右表欄位 IS NULL (Anti-Join)。

# 第五步：是否需要保留『右邊』表格的『所有』紀錄，不管它在左邊有沒有匹配？
# 情境：「我想看『所有』訂單，以及它們『可能存在』的客戶資訊。如果某筆訂單沒有客戶資訊（髒數據），客戶欄位顯示 NULL 即可。」
# 答案：是 → 使用 RIGHT JOIN (或 RIGHT OUTER JOIN)。

# 專業建議：盡量不要使用 RIGHT JOIN。
# 可以把 FROM A RIGHT JOIN B 完美地改寫成 FROM B LEFT JOIN A，這樣可以讓 SQL 閱讀順序永遠保持從左到右，更易於理解。

# 第六步：是否需要保留『兩邊』表格的『所有』紀錄，不管有沒有匹配？
# 情境：「我想看一張超級列表，上面有所有的產品，也包含所有已售出的商品項，不管它們是否能匹配上。」
# 答案：是 → 使用 FULL OUTER JOIN。
# 備註：MySQL 不支援 FULL OUTER JOIN 關鍵字，您需要用 LEFT JOIN ... UNION ... RIGHT JOIN 來模擬它。























