# 進階9：聯合查詢

/*
 * union 聯合、合併：將多條查詢語句的結果合併成一個結果
 * 
 * 語法：
 * 查詢語句 1
 * union
 * 查詢語句 2
 * union
 * ...
 * 
 * 應用場景：
 * 要查詢的結果來自於多個表，且多個表沒有直接的連接關係，但查詢信息一致時
 * 
 * 特點：
 * 	1. 要求多條查詢語句的查詢列數是一致的！
 * 	2. 要求多條查詢語句所查詢的每一列類型和順序，最好一致！
 * 	3. union 關鍵字默認去重，如果使用 union all 可以包含重複項
 */

# 引入的案例：查詢訂單狀態為 'canceled' 或 'unavailable' 的訂單資訊
SELECT * FROM olist_orders oo WHERE oo.order_status = 'canceled'
UNION
SELECT * FROM olist_orders oo WHERE oo.order_status = 'unavailable';

# 案例：查詢位於 'RJ' (里約熱內盧) 州的買家與賣家資訊
SELECT oc.customer_id, oc.customer_state, oc.customer_city FROM olist_customers oc WHERE oc.customer_state = 'RJ'
UNION
SELECT os.seller_id, os.seller_state, os.seller_city FROM olist_sellers os WHERE os.seller_state = 'RJ';

# union (去重)
SELECT customer_state FROM olist_customers
UNION
SELECT seller_state FROM olist_sellers;

# union all (不去重)
SELECT customer_state FROM olist_customers
UNION all
SELECT seller_state FROM olist_sellers;


