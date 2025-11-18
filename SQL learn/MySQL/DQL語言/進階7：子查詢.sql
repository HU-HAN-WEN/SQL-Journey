# 進階7：子查詢
/*
 * 含意：
 * 		出現在其他語句中的 select 語句，稱為子查詢或內查詢
 * 		外部的查詢語句，稱為主查詢或外查詢
 * 
 * 分類(按子查詢出現的位置)：
 * 		select 後面：
 * 				僅僅支持標量子查詢
 * 
 * 		from 後面：
 * 				支持表子查詢
 * 
 * 		where 或 having 後面： (重點)
 * 				標量子查詢 (單行)(重點)
 * 				列子查詢 (多行)(重點)
 * 				行子查詢 (較少)
 * 
 * 		exists 後面(相關子查詢)
 * 				表子查詢
 * 
 * 案結果集的行列數不同：
 * 		標量子查詢(結果集只有一行一列，又稱單行子查詢)
 * 		列子查詢(結果集只有一列多行)
 * 		行子查詢(結果集有一行多列)
 * 		表子查詢(結果集一般為多行多列)
 * 
 */

# 一、where 或 having 後面
/*
 * 1. 標量子查詢(單行子查詢)
 * 2. 列子查詢(多行子查詢)
 * (較少) 3. 行子查詢(多列多行)
 * 
 * 特點：
 * 		1. 子查詢放在小括號內
 * 		2. 子查詢一般放在條件的右側
 * 		3. 標量子查詢，一般搭配著單行操作符使用
 * 			>, <, >=, <=, =, <>
 * 		4. 列子查詢，一般搭配著多行操作符使用
 * 			IN/NOT IN, ANY/SOME, ALL
 * 		5. 子查詢的執行優先於主查詢的執行，主查詢的條件用到子查詢的結果
 */

# 1. 標量子查詢
# 案例一：找出所有在訂單 e481f51cbdc54678b7cc49136f2d6af7 之後才成立的新訂單。
# 對應表格：olist_orders

# (1) 出所訂單 e481f51cbdc54678b7cc49136f2d6af7 的時間
SELECT
	oo.order_purchase_timestamp
FROM
	olist_orders oo
WHERE
	oo.order_id = 'e481f51cbdc54678b7cc49136f2d6af7';

# (2) 找出所有訂單時間 > 1. 的新訂單
SELECT
	oo.order_id,
	oo.order_purchase_timestamp
FROM
	olist_orders oo
WHERE
	oo.order_purchase_timestamp > (
	SELECT
		oo.order_purchase_timestamp
	FROM
		olist_orders oo
	WHERE
		oo.order_id = 'e481f51cbdc54678b7cc49136f2d6af7'
) ;


# 案例二：找出所有在產品類別上與 product_id 為 '16b06ede456b922e56fbb4b3818aa875' 的產品相同，
# 	    且在單價上比 product_id 為 '52a8061c8e8e8cea30b41344aac26431' 的產品更貴的所有商品項。
# 對應表格：olist_products 和 olist_order_items

# (1) 找出產品類別為 '16b06ede456b922e56fbb4b3818aa875' 的產品
SELECT
	op.product_category_name
FROM
	olist_products op
WHERE
	op.product_id = '16b06ede456b922e56fbb4b3818aa875' ;

# (2) 找出product_id 為 '52a8061c8e8e8cea30b41344aac26431' 的產品單價
SELECT
	ooi.price
FROM
	olist_order_items ooi
WHERE
	ooi.product_id = '52a8061c8e8e8cea30b41344aac26431' ;

# (3) 找出所有在產品類別上與1. 相同，且在單價上比2. 更貴的所有商品項。
SELECT
	ooi.order_id,
	op.product_id,
	op.product_category_name,
	ooi.price
FROM
	olist_products op,
	olist_order_items ooi
WHERE
	op.product_category_name = (
	SELECT
		op.product_category_name
	FROM
		olist_products op
	WHERE
		op.product_id = '16b06ede456b922e56fbb4b3818aa875' 
)
	AND ooi.price > (
	SELECT
		ooi.price
	FROM
		olist_order_items ooi
	WHERE
		ooi.product_id = '52a8061c8e8e8cea30b41344aac26431' 
) ;


# 案例三：找出哪些州 (customer_state) 的總客戶數，高於『里約熱內盧州 (RJ)』的客戶數？
# 對應表格：olist_customers

# (1) 查詢「里約熱內盧州 (RJ)」的客戶數
SELECT
	COUNT(*)
FROM
	olist_customers oc
WHERE
	oc.customer_state = 'RJ' ;

# (2) 查詢「每個州」的客戶數
SELECT
	oc.customer_state,
	COUNT(*)
FROM
	olist_customers oc
GROUP BY
	oc.customer_state ;

# (3) 在(2)情況下找出客戶數 > (1) 的州
SELECT
	oc.customer_state,
	COUNT(*)
FROM
	olist_customers oc
GROUP BY
	oc.customer_state
HAVING
	COUNT(*) > (
	SELECT
			COUNT(*)
	FROM
			olist_customers oc
	WHERE
			oc.customer_state = 'RJ'
) ;

# 非法使用標量子查詢
# 1. 子查詢結果非一行一列
# 2. 子查詢結果為 NULL


# 2. 列子查詢(多行子查詢)
# 案例一：找出所有屬於『beleza_saude』 (美妝保健) 或『esporte_lazer』 (運動休閒) 這兩個類別的產品 ID 列表，
# 		然後，請幫我從訂單商品表 (olist_order_items) 中，找出所有符合這個列表的銷售紀錄。
# 對應表格：olist_order_items, olist_products

# (1) 所有屬於『beleza_saude』 (美妝保健) 或『esporte_lazer』 (運動休閒) 這兩個類別的產品 ID 列表
SELECT
	DISTINCT op.product_id
FROM
	olist_products op
WHERE
	op.product_category_name IN ('beleza_saude', 'esporte_lazer') ;

# (2) 從訂單商品表 (olist_order_items) 中，找出所有符合(1)的銷售紀錄
SELECT
	ooi.order_id,
	ooi.product_id,
	ooi.price
FROM
	olist_order_items ooi
WHERE
	ooi.product_id IN (
	SELECT
		DISTINCT op.product_id
	FROM
		olist_products op
	WHERE
		op.product_category_name IN ('beleza_saude', 'esporte_lazer')
) ;
# 用 ANY 表達
SELECT
	ooi.order_id,
	ooi.product_id,
	ooi.price
FROM
	olist_order_items ooi
WHERE
	ooi.product_id = ANY (
	SELECT
		DISTINCT op.product_id
	FROM
		olist_products op
	WHERE
		op.product_category_name IN ('beleza_saude', 'esporte_lazer')
) ;

# WHERE ooi.product_id NOT IN () = WHERE ooi.product_id <> ALL ()


# 案例二：『電腦配件』類別中最貴的商品單價是多少？然後，請幫我找出 olist_order_items 中，所有單價 (price) 低於這個「最高單價」的其他商品項。
# 對應表格：olist_order_items, olist_products
# (1)『電腦配件』類別中的商品單價是多少？
SELECT
	DISTINCT ooi.price
FROM
	olist_order_items ooi
JOIN olist_products op ON
	ooi.product_id = op.product_id
WHERE
	op.product_category_name = 'informatica_acessorios'
	AND ooi.price IS NOT NULL ;

# (2) olist_order_items 中，所有單價 (price) 低於這個(1)「最高單價」的其他商品項。
SELECT
	ooi.order_id,
	ooi.product_id,
	ooi.price
FROM
	olist_order_items ooi
WHERE
	ooi.price < ANY (
	SELECT
			DISTINCT ooi.price
	FROM
			olist_order_items ooi
	JOIN olist_products op ON
			ooi.product_id = op.product_id
	WHERE
			op.product_category_name = 'informatica_acessorios'
		AND ooi.price IS NOT NULL
) ;


# 案例三：『電腦配件』類別的商品單價是多少？然後，請幫我找出 olist_order_items 中，所有單價 (price) 低於『電腦配件』類別所有的其他商品項。
# 對應表格：olist_order_items, olist_products
SELECT
	ooi.order_id,
	ooi.product_id,
	ooi.price
FROM
	olist_order_items ooi
WHERE
	ooi.price < ALL (
	SELECT
			DISTINCT ooi.price
	FROM
			olist_order_items ooi
	JOIN olist_products op ON
			ooi.product_id = op.product_id
	WHERE
			op.product_category_name = 'informatica_acessorios'
		AND ooi.price IS NOT NULL
) ;
# 或
SELECT
	ooi.order_id,
	ooi.product_id,
	ooi.price
FROM
	olist_order_items ooi
WHERE
	ooi.price < (
	SELECT
			MIN(ooi.price)
	FROM
			olist_order_items ooi
	JOIN olist_products op ON
			ooi.product_id = op.product_id
	WHERE
			op.product_category_name = 'informatica_acessorios'
		AND ooi.price IS NOT NULL
) ;


# 3. 行子查詢 (結果集一行多列 或 多行多列)

# 案例一：在 olist_order_items 表中，是否存在一個商品項，它的售價 (price) 剛好是全平台最低的，同時它的運費 (freight_value) 又剛好是全平台最高的？
# 對應表格：olist_order_items_dataset

SELECT
	ooi.order_id, 
	ooi.product_id,
	ooi.price,
	ooi.freight_value
FROM
	olist_order_items ooi
WHERE
	(ooi.price,
	ooi.freight_value) = (
	SELECT
		MIN(ooi.price),
		MAX(ooi.freight_value)
	FROM
		olist_order_items ooi
	);

# 過去：
# (1)售價 (price) 剛好是全平台最低的商品
SELECT
	MIN(ooi.price)
FROM
	olist_order_items ooi ;
# (2)運費 (freight_value) 是全平台最高的
SELECT
	MAX(ooi.freight_value)
FROM
	olist_order_items ooi ;
# (3)查詢商品訊息
SELECT
	ooi.order_id, 
	ooi.product_id,
	ooi.price,
	ooi.freight_value
FROM
	olist_order_items ooi
WHERE
	ooi.price = (
	SELECT
			MIN(ooi.price)
	FROM
			olist_order_items ooi
)
	AND ooi.freight_value =(
	SELECT
			MAX(ooi.freight_value)
	FROM
			olist_order_items ooi
) ;

# ---

# 二、 select 後面
# 僅僅支持標量子查詢

# 案例一：在產品列表 (olist_products)旁邊加一欄，清楚地顯示這個產品總共被賣出了多少次（即在 olist_order_items 中出現了幾次）？
SELECT
	(
	SELECT
		count(*)
	FROM
		olist_order_items ooi
	WHERE
		ooi.product_id = op.product_id 
) 賣出次數
FROM
	olist_products op ;

/* 為何 WHERE d.department_id = e.department_id 在子查詢內？
 * 		因為這行 WHERE 就是那個「跑腿SOP」！它必須在子查詢內部，用來關聯「外部的 d」和「內部的 e」。如果寫在外面，邏輯就全錯了。
 * 
 * 子查詢是不是只用了一個表？
 * 		它的 FROM 子句只用了一個表 (employees e)，但它的 WHERE 子句引用 (reference) 了外部查詢的表 (departments d)。
 */

# 案例二：order_id 為 'e481f51cbdc54678b7cc49136f2d6af7' 這筆訂單，它的客戶城市是什麼？
SELECT
	(
	SELECT
		c.customer_city
	FROM
		olist_orders o
	JOIN olist_customers c ON
		o.customer_id = c.customer_id
	WHERE
		o.order_id = 'e481f51cbdc54678b7cc49136f2d6af7'
		-- 確保子查詢只返回一個值
) AS 客戶城市;

# ---

# 三、from 後面
# 將子查詢的結果充當一張表，要求：必須取別名

# 案例：'credit_card', 'boleto', 'voucher' 等每種付款方式，它們的平均支付金額 (AVG) 各是多少？
# 		並且，這個平均金額分別屬於哪個金額等級 ('A', 'B', 'C'...)？
# (1)'credit_card', 'boleto', 'voucher' 等每種付款方式，它們的平均支付金額 (AVG) 各是多少？
SELECT
	oop.payment_type ,
	AVG(oop.payment_value)
FROM
	olist_order_payments oop
GROUP BY
	oop.payment_type ;
# (2)連接(1)的結果與payment_value_grades，篩選條件平均工資： between lowest_value and highest_value
SELECT
	avg_payment_type.*,
	pvg.grade_level
FROM
	(
	SELECT
			oop.payment_type ,
			AVG(oop.payment_value) avg_payment
	FROM
			olist_order_payments oop
	GROUP BY
			oop.payment_type
) avg_payment_type
INNER JOIN payment_value_grades pvg
ON
	avg_payment_type.avg_payment BETWEEN lowest_value AND highest_value ;
# 注意：oop 這個別名只存活於子查詢 () 內部。一旦子查詢執行完畢，oop 這個別名就「死掉了」。
# 		外部的 ON 子句根本不知道 oop 是誰，所以 AVG(oop.payment_value) 會報錯，只能用avg_payment_type.avg_payment

# ---

# 四、exists 後面(相關子查詢)
/*
 * 語法：
 * 		exists(完整查詢語句)
 * 結果：
 * 		1 或 0
 * 
 * 備註：能用exists的必定能用 in 代替
 */

# 案例一：所有至少被賣出過一次的產品
# IN
SELECT
	op.product_id,
	op.product_category_name
FROM
	olist_products op
WHERE
	op.product_id IN (
	SELECT
		DISTINCT ooi.product_id
	FROM
		olist_order_items ooi 
) ;
# EXISTS - 推薦
SELECT
	op.product_id,
	op.product_category_name
FROM
	olist_products op
WHERE
	EXISTS (
	SELECT
		*
	FROM
		olist_order_items ooi
	WHERE
		ooi.product_id - op.product_id 
) ;


# 案例二：所有從未被銷售過的產品
/*
 * 強烈建議「永遠不要」對子查詢使用 NOT IN, 非常、非常低效的事情
 * 1. 執行子查詢：資料庫必須先完整地執行您的子查詢 (SELECT DISTINCT ooi.product_id FROM olist_order_items ooi ...)。
 * 2. 執行主查詢：接著，資料庫開始掃描 olist_products 這張** 4500 萬筆紀錄的表格。
 * 對於每一筆產品，它都必須拿著 op.product_id，去和您在第一步建立的那個數萬筆的「黑名單」進行逐一比對**，檢查「是否不在裡面」。
 * SELECT
 * 	op.product_id,
 * 	op.product_category_name
 * FROM
 * 	olist_products op
 * WHERE
 * 	op.product_id NOT IN (
 * 	SELECT
 * 		DISTINCT ooi.product_id
 * 	FROM
 * 		olist_order_items ooi 
 * 	WHERE ooi.product_id IS NOT null
 * ) 
 */

# NOT EXISTS (強烈推薦)
SELECT
	op.product_id,
	op.product_category_name
FROM
	olist_products op
WHERE
	NOT EXISTS (
	SELECT
		*
	FROM
		olist_order_items ooi
	WHERE
		ooi.product_id - op.product_id 
) ;


# = (等於) 是一個**「標量子查詢 (Scalar Subquery)」。它只期望** () 裡的子查詢返回不多於「一個」值（一行一列）。
# IN 是一個**「列表查詢」。它期望** () 裡的子查詢返回一個「值的列表」。


# --- 練習 ---
# 1. 查詢所有產品類別為 'informatica_acessorios' (電腦配件) 的商品，它們被購買時的訂單 ID 和價格。
# (1)查詢所有產品類別為 'informatica_acessorios' (電腦配件) 的商品
SELECT
	op.product_id
FROM
	olist_products op
WHERE
	op.product_category_name = 'informatica_acessorios' ;
# (2)在(1)的情況下，它們被購買時的訂單 ID 和價格
SELECT
	ooi.product_id,
	ooi.freight_value
FROM
	olist_order_items ooi
WHERE
	ooi.product_id IN (
	SELECT
		op.product_id
	FROM
		olist_products op
	WHERE
		op.product_category_name = 'informatica_acessorios'
)

# 或

SELECT
	ooi.product_id,
	ooi.freight_value
FROM
	olist_order_items ooi
JOIN olist_products op ON
	ooi.product_id = op.product_id
WHERE
	op.product_category_name = 'informatica_acessorios' ;


# 2. 找出所有支付金額高於『平台平均支付金額』的付款紀錄
# (1)『平台平均支付金額』
SELECT
	AVG(oop.payment_value)
FROM
	olist_order_payments oop ;
# (2)所有支付金額高於(1)的付款紀錄
SELECT
	oop.order_id,
	oop.payment_type,
	oop.payment_value
FROM
	olist_order_payments oop
WHERE
	oop.payment_value > (
	SELECT
		AVG(oop2.payment_value)
	FROM
		olist_order_payments oop2
);


# 3. 找出那些支付金額高於「該付款方式 (payment_type) 平均金額」的支付紀錄。例如，找出所有高於『信用卡平均值』的信用卡支付，
# 		以及高於『Boleto 平均值』的 Boleto 支付。
# (1)該付款方式 (payment_type) 平均金額
SELECT
	AVG(oop.payment_value)
FROM
	olist_order_payments oop
GROUP BY
	oop.payment_type ;
# (2)連接(1)的結果集和olist_order_payments，進行篩選
SELECT
	oop.order_id,
	oop.payment_type,
	oop.payment_value
FROM
	olist_order_payments oop
INNER JOIN (
	SELECT
		AVG(oop2.payment_value) ag,
		payment_type
	FROM
		olist_order_payments oop2
	GROUP BY
		oop2.payment_type
)ag_value
ON
	oop.payment_type = ag_value.payment_type
WHERE
	oop.payment_value > ag_value.ag ;


# 4. 哪些產品 (product_id) 至少被一個 'SP' 州的賣家賣過？然後，請給我所有包含這些產品的訂單商品項 (order_items) 紀錄。
# (1)來自'SP' 州的賣家
SELECT
	DISTINCT os.seller_id
FROM
	olist_order_items ooi
JOIN olist_sellers os ON
	ooi.seller_id = os.seller_id
WHERE
	os.seller_state = 'SP';

# (2)查詢地點 = (1) 的賣家產品的訂單商品項
SELECT
	ooi1.seller_id,
	ooi1.product_id,
	ooi1.price
FROM
	olist_order_items ooi1
WHERE
	ooi1.seller_id IN (
	SELECT
		DISTINCT os.seller_id
	FROM
		olist_order_items ooi
	JOIN olist_sellers os ON
		ooi.seller_id = os.seller_id
	WHERE
		os.seller_state = 'SP'
);


# 5. 查看所有來自 'SP' 州的客戶，他們所有訂單的付款方式 (payment_type) 和付款金額 (payment_value)。
# 連接思路 (鏈式連接)：customers -> orders -> order_payments
SELECT
    oc.customer_unique_id,
    oo.order_id,
    oop.payment_type,
    oop.payment_value
FROM
    olist_customers AS oc -- 表 A
JOIN
    olist_orders AS oo ON oc.customer_id = oo.customer_id -- 連接 A 和 B
JOIN
    olist_order_payments AS oop ON oo.order_id = oop.order_id -- 連接 B 和 C
WHERE
    oc.customer_state = 'SP';


# 6. 找出客戶 'dc0a596a36f033e89eeecbbbaa5603e9' 的城市，然後找出所有住在那裡的其他客戶。
# (1) 客戶 '861eff4711a542e7b6ad5e847e13038a' 的城市
SELECT
	oc.customer_city
FROM
	olist_customers oc
WHERE
	oc.customer_id = 'dc0a596a36f033e89eeecbbbaa5603e9' ;

# (2)住在 (1) 的客戶
SELECT
	DISTINCT oc.customer_id
FROM
	olist_customers oc
WHERE
	oc.customer_city = (
	SELECT
		oc.customer_city
	FROM
		olist_customers oc
	WHERE
		oc.customer_id = 'dc0a596a36f033e89eeecbbbaa5603e9'
)
	AND oc.customer_id != 'dc0a596a36f033e89eeecbbbaa5603e9' ;


# 7. 找出單筆訂單總運費 (SUM(freight_value)) 最高的那筆訂單，並顯示該訂單中所有的賣家 ID 和產品 ID以及顯示(產品：+ 賣家:)
# (1)單筆訂單總運費 (SUM(freight_value)) 最高的訂單
SELECT
	ooi.order_id
FROM
	olist_order_items ooi
GROUP BY
	ooi.order_id
ORDER BY
	SUM(ooi.freight_value) DESC
LIMIT 1 ;

# (2)總運費 = (1)訂單中所有的賣家 ID 和產品 ID
SELECT
	ooi.seller_id,
	ooi.order_id,
	CONCAT('Product:', ooi.product_id, 'Sold by:', ooi.seller_id ) 資訊
FROM
	olist_order_items ooi
WHERE
	ooi.order_id = (
	SELECT
		ooi.order_id
	FROM
		olist_order_items ooi
	GROUP BY
		ooi.order_id
	ORDER BY
		SUM(ooi.freight_value) DESC
	LIMIT 1
) ;



# in (都可以用)用多行的結果； = 只能用單個的結果










