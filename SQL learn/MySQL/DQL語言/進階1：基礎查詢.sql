# 進階1：基礎查詢
/*
 * 語法：
 * select 查詢列表 from 表名;
 * 
 * 類似於： system.out.println(打印東西);
 * 
 * 特點：
 *  1. 查詢列表可以是：表中的字段、常量值、表達式、函數
 *  2. 查詢的結果是一個虛擬的表格
 */ 


#DBeaver 的「自動格式化」快捷鍵： Windows/Linux: Ctrl + Shift + F

# 1. 查詢表中的單個字段
SELECT customer_id FROM olist_customers ;

# 2. 查詢表中的多個字段 (按照自己打的順序)
SELECT
	customer_id,
	customer_zip_code_prefix,
	customer_unique_id
FROM
	olist_customers ;

# 3. 查詢表中的所有字段
SELECT * FROM olist_customers ;

# `name` --> ``用於區分關鍵字與字段

# 4. 查詢常量值
SELECT 100 ;
SELECT 'john';

# 5. 查詢表達式
SELECT 100*98 ;
SELECT 100%98 ;

# 6. 查詢函數 
SELECT VERSION();

# 7. 起別名 AS
/*
 * 1. 便於理解
 * 2. 如果要查詢的字段有重名的情況， 使用別名可以做區分
 */

# 方式一： 使用as
SELECT 100%98 AS 結果 ;

SELECT
	customer_id AS 訂單層級的客戶ID,
	customer_unique_id AS 客戶層級的唯一ID,
	customer_zip_code_prefix AS 郵遞區號前五碼,
	customer_city AS 客戶所在的城市,
	customer_state AS 客戶所在的州
FROM
	olist_customers ;

# 方式二： 使用空格
SELECT
	customer_id 訂單層級的客戶ID,
	customer_unique_id 客戶層級的唯一ID,
	customer_zip_code_prefix 郵遞區號前五碼,
	customer_city 客戶所在的城市,
	customer_state 客戶所在的州
FROM
	olist_customers ;

# 案例：查詢客戶ID，顯示結果為 out put
# SELECT customer_id AS OUT put  FROM olist_customers ; 錯誤
SELECT customer_id AS 'out put' FROM olist_customers ;

# 8. 去重 DISTINCT
# 案例：查詢 客戶資料集 中涉及到的所有 客戶層級的唯一ID
SELECT DISTINCT customer_unique_id FROM olist_customers ;

# 9. +號的作用 CONCAT('a', 'b', 'c')
/*
 * java中的+號：
 * 1. 運算符號，兩個操作都為數值型
 * 2. 連接符號，只要有一個操作數為字符串
 * 
 * mySQL中的+號：
 * 僅僅只有一個功能：運算符號
 * select 100+90; 兩個操作數都為數值型，則作加法運算
 * select '123'+90;  其中一方為字符型，試圖將字符型數值轉換成數值型；
 *                   如果轉換成功，則繼續做加法運算 =213
 * select 'John'+90; 如果轉換失敗，則將字符型轉換為0 =90
 * select null+90;   只要其中一方結果為null，則結果肯定為null =null
 */

# 案例：查詢顧客所在的城市和州連接成一個字段，並顯示為 地點
SELECT CONCAT('a', 'b', 'c') AS 結果 ;

SELECT
	CONCAT(customer_city, ', ', customer_state) AS 地點
FROM
	olist_customers ;


# 10 結構 DESC
DESC olist_customers;


# 11. 如果有一個值為null，但還是想顯示怎麼辦 --> IFNULL(列, 為null顯示的值)
# SELECT CONCAT(`first_name`, ', ', IFNULL(commission_pct,0)) AS out_put FROM employees;


