-- Выполнил Базуев Станислав Валерьевич

-- Контрольное задание №1

/*
Написать запрос, выводящий имя и фамилию самых бедных клиентов - среди замужных женщин,
не проживающих ни в Японии, ни в Бразилии, ни в Италии.
Богатство определяется по кредитному лимиту.
[Отсортировать по CUST_LAST_NAME].
*/
WITH NotJBI_and_F_married AS (
	SELECT
		u.CUST_FIRST_NAME,
		u.CUST_LAST_NAME,
		u.CUST_CREDIT_LIMIT
	FROM CUSTOMERS u JOIN COUNTRIES c ON u.COUNTRY_ID = c.COUNTRY_ID
	WHERE u.CUST_MARITAL_STATUS IN ('married')
		AND u.CUST_GENDER IN ('F')
		AND c.COUNTRY_NAME NOT IN ('Brazil', 'Japan', 'Italy')
	)
SELECT
	u.CUST_FIRST_NAME,
	u.CUST_LAST_NAME
FROM NotJBI_and_F_married u
WHERE u.CUST_CREDIT_LIMIT = (SELECT MIN(CUST_CREDIT_LIMIT) FROM NotJBI_and_F_married)
ORDER BY u.CUST_LAST_NAME
;


-- Контрольное задание №2

/*
Написать запрос, выводящий клиента с самым длинным домашним адресом,
чей телефонный номер заканчивается на 77.
Вывести результат в одном столбце, в формате:
“Name: [cust_first_name] [cust_last_name]; city: [cust_city]; address: [cust_street_address]; number:[cust_main_phone_number]; email: [cust_email]; ”
(всё, что обернуто в [] – названия полей (столбцов) таблицы).
*/
WITH PhoneEnd77 AS (
    SELECT
        CUST_FIRST_NAME,
        CUST_LAST_NAME,
        CUST_CITY,
        CUST_STREET_ADDRESS,
        CUST_MAIN_PHONE_NUMBER,
        CUST_EMAIL,
        LENGTH(CUST_STREET_ADDRESS) AS address_length,
        MAX(LENGTH(CUST_STREET_ADDRESS)) OVER () AS max_address_length
    FROM CUSTOMERS
    WHERE REGEXP_LIKE(CUST_MAIN_PHONE_NUMBER, '77$')
	)
SELECT
    'Name: ' || CUST_FIRST_NAME || ' ' || CUST_LAST_NAME ||
    '; city: ' || CUST_CITY ||
    '; address: ' || CUST_STREET_ADDRESS ||
    '; number: ' || CUST_MAIN_PHONE_NUMBER ||
    '; email: ' || CUST_EMAIL || '; ' AS result
FROM PhoneEnd77
WHERE ADDRESS_LENGTH = MAX_ADDRESS_LENGTH
;


-- Контрольное задание №3

/*
Написать запрос, выводящий всех клиентов, которые купили самый дешевый продукт
(цена считается от цены продажи - prod_list_price) в субкатегории 'Sweaters - Men' или 'Sweaters - Women'
(связка таблиц CUSTOMERS -> SALES -> PRODUCTS),
среди тех, кто родился позже 1980 года,
вывод должен быть отсортирован по cust_id.
*/
WITH CustomersOlder1980Sweaters AS (
	SELECT
		c.*,
		p.PROD_LIST_PRICE
	FROM CUSTOMERS c
		JOIN SALES s ON c.CUST_ID = s.CUST_ID
		JOIN PRODUCTS p ON s.PROD_ID = p.PROD_ID
	WHERE p.PROD_SUBCATEGORY IN ('Sweaters - Men', 'Sweaters - Women')
		AND CUST_YEAR_OF_BIRTH > 1980
	)
SELECT
	CUST_ID,
	CUST_FIRST_NAME,
	CUST_LAST_NAME,
	CUST_GENDER,
	CUST_YEAR_OF_BIRTH,
	CUST_MARITAL_STATUS,
	CUST_STREET_ADDRESS,
	CUST_POSTAL_CODE,
	CUST_CITY,
	COUNTRY
FROM CustomersOlder1980Sweaters
WHERE PROD_LIST_PRICE = (SELECT MIN(PROD_LIST_PRICE) FROM CustomersOlder1980Sweaters)
ORDER BY CUST_ID
;


-- Контрольное задание №4

/*
Написать запрос, выводящий всех клиентов-мужчин с уровнем дохода "D",
у которых не заполнено поле "семейное положение"
и которые проживают в США или Германии (с использованием EXISTS).
Отсортировать по cust_id.
*/
SELECT c.*
FROM CUSTOMERS c
WHERE
	SUBSTR(c.CUST_INCOME_LEVEL, 1, 1) = 'D'
	AND CUST_MARITAL_STATUS IS NULL
	AND EXISTS(SELECT COUNTRY_NAME
			   FROM COUNTRIES
               WHERE COUNTRY_ISO_CODE IN ('US', 'DE')
                   AND COUNTRY_ID = c.COUNTRY_ID)
    AND c.CUST_GENDER = 'M'
ORDER BY c.CUST_ID
;


-- Контрольное задание №5

/*
Написать запрос, выводящий среднюю сумму покупки
(сумма покупки является произведением цены товара (prod_list_price)
на количество проданного товара (quantity_sold)) в каждой стране,
полное название страны.
Отсортировать в порядке убывания средней суммы.
*/
WITH AVGTotalForCountry AS (
	SELECT
        SUM(s.QUANTITY_SOLD * p.PROD_LIST_PRICE) OVER (PARTITION BY co.COUNTRY_NAME) AS TOTAL,
        COUNT(*) OVER (PARTITION BY co.COUNTRY_NAME) AS COUNT_ORDERS,
		co.COUNTRY_NAME
	FROM COUNTRIES co
		JOIN CUSTOMERS cu ON cu.COUNTRY_ID = co.COUNTRY_ID
		JOIN SALES s ON cu.CUST_ID = s.CUST_ID
		JOIN PRODUCTS p ON s.PROD_ID = p.PROD_ID
	)
SELECT DISTINCT
	ROUND(TOTAL / COUNT_ORDERS, 2) AS AVGTotal,
	COUNTRY_NAME
FROM AVGTotalForCountry
ORDER BY AVGTotal DESC
;


-- Контрольное задание №6

/*
Написать запрос, выводящий "популярность" почтовых доменов клиентов,
т.е. количество клиентов с почтой в каждом из доменов.
*/
SELECT DISTINCT
	REGEXP_SUBSTR(CUST_EMAIL, '@(.+)$', 1, 1, NULL, 1) AS EMAIL_DOMEN,
	COUNT(*) OVER (PARTITION BY REGEXP_SUBSTR(CUST_EMAIL, '@(.+)$', 1, 1, NULL, 1))  AS COUNT_USERS
FROM CUSTOMERS
ORDER BY COUNT_USERS DESC
;


-- Контрольное задание №7

/*
Написать запрос, выводящий распределение суммы проданных товаров в единицах (quantity_sold) категории "Men" по странам
(т.е. распределение по странам, в которых проживают клиенты),
в конечной выборке оставить те страны,
в которых общее количество проданных товаров в единицах выше,
чем среднее количество проданных товаров этой категории по странам всего мира.
Упорядочить по полному названию стран.
 */
WITH CountrySales AS (
    SELECT
--        SUM(s.QUANTITY_SOLD * p.PROD_LIST_PRICE) AS TOTAL_PRICE,
--        COUNT(s.PROD_ID) AS COUNT_ORDERS,
        co.COUNTRY_NAME,
        SUM(s.QUANTITY_SOLD) AS TOTAL_QUANTITY_SOLD
    FROM COUNTRIES co
	    JOIN CUSTOMERS cu ON cu.COUNTRY_ID = co.COUNTRY_ID
	    JOIN SALES s ON cu.CUST_ID = s.CUST_ID
	    JOIN PRODUCTS p ON s.PROD_ID = p.PROD_ID
    WHERE p.PROD_CATEGORY = 'Men'
    GROUP BY co.COUNTRY_NAME, p.PROD_CATEGORY
),
AverageSales AS (
    SELECT
        AVG(TOTAL_QUANTITY_SOLD) AS AVG_QUANTITY_SOLD
    FROM CountrySales
)
SELECT
    cs.COUNTRY_NAME,
    cs.TOTAL_QUANTITY_SOLD--,
--    ROUND(avg.AVG_QUANTITY_SOLD, 0) AS AVG_QUANTITY_SOLD,
--    ROUND(cs.TOTAL_PRICE / NULLIF(cs.COUNT_ORDERS, 0), 2) AS AVG_TOTAL
FROM CountrySales cs
JOIN AverageSales avg ON cs.TOTAL_QUANTITY_SOLD > avg.AVG_QUANTITY_SOLD
ORDER BY cs.COUNTRY_NAME
--JOIN AverageSales avg ON cs.TOTAL_QUANTITY_SOLD <> avg.AVG_QUANTITY_SOLD OR cs.TOTAL_QUANTITY_SOLD = avg.AVG_QUANTITY_SOLD
--ORDER BY  cs.TOTAL_QUANTITY_SOLD DESC, AVG_TOTAL
;


-- Контрольное задание №8

/*
Написать запрос, выводящий процентное соотношение мужчин и женщин,
проживающих в каждой стране, отсортированное по названию страны в алфавитном порядке.
Столбцы в выводе должны быть такими: «Страна», «% мужчин», «% женщин» [использовать WITH].
Упорядочить по полному названию стран.
*/
WITH PopulationGender AS (
    SELECT
        c.COUNTRY_NAME,
        u.CUST_GENDER,
        COUNT(u.CUST_ID) AS GENDER_POPULATION
    FROM CUSTOMERS u
    JOIN COUNTRIES c ON u.COUNTRY_ID = c.COUNTRY_ID
    GROUP BY c.COUNTRY_NAME, u.CUST_GENDER
),
TotalPopulation AS (
    SELECT
        COUNTRY_NAME,
        SUM(GENDER_POPULATION) AS TOTAL_POPULATION
    FROM PopulationGender
    GROUP BY COUNTRY_NAME
)
--SELECT * FROM TotalPopulation ORDER BY COUNTRY_NAME;
SELECT
    tp.COUNTRY_NAME AS Страна,
    ROUND(SUM(CASE WHEN pg.CUST_GENDER = 'M'
				   THEN pg.GENDER_POPULATION
				   ELSE 0 END
			  ) * 100.0 / tp.TOTAL_POPULATION, 2) AS "% мужчин",
    ROUND(SUM(CASE WHEN pg.CUST_GENDER = 'F'
                   THEN pg.GENDER_POPULATION
                   ELSE 0 END
              ) * 100.0 / tp.TOTAL_POPULATION, 2) AS "% женщин"
FROM PopulationGender pg
JOIN TotalPopulation tp ON pg.COUNTRY_NAME = tp.COUNTRY_NAME
GROUP BY tp.COUNTRY_NAME, tp.TOTAL_POPULATION
ORDER BY tp.COUNTRY_NAME
;


-- Контрольное задание №9

/*
Написать запрос, выводящий максимальное суммарное количество проданных единиц товара (quantity_sold)
за день для каждого продукта (т.е. продукты в выводе не должны повторяться).
Запрос должен выводить TOP 20 строк, отсортированных по убыванию количества проданных единиц товара
(Столбцы должны быть такими: "Макс покуп/день", prod_name)
[Под первым столбцом подразумевается объединение в одно поле количества покупок и последней даты,
за которую сделаны эти покупки].
*/
WITH DailySalesProdName AS (
    SELECT
        p.PROD_NAME,
        TO_CHAR(s.TIME_ID, 'YYYY-MM-DD') AS SALE_DATE,
        SUM(s.QUANTITY_SOLD) AS TOTAL_QUANTITY_SOLD
    FROM SALES s
    JOIN PRODUCTS p ON s.PROD_ID = p.PROD_ID
    GROUP BY p.PROD_NAME, s.TIME_ID
),
MaxDailySalesProdName AS (
    SELECT
        PROD_NAME,
        MAX(TOTAL_QUANTITY_SOLD) AS MAX_SOLD,
        MAX(SALE_DATE) AS LAST_SALE_DATE
    FROM DailySalesProdName
    GROUP BY PROD_NAME
)
SELECT
    MAX_SOLD || ' / ' || LAST_SALE_DATE AS "Макс покуп/день",
    PROD_NAME
FROM MaxDailySalesProdName
ORDER BY MAX_SOLD DESC
FETCH FIRST 20 ROWS ONLY
;


-- Контрольное задание №10

/*
Написать запрос, выводящий максимальное суммарное количество проданных единиц товара за день
для каждой категории продуктов. Отсортировать по убыванию количества.
(Столбцы должны быть такими: "Макс за день", prod_category).
[Под первым столбцом подразумевается одно число].
*/
WITH DailySalesProdCategory AS (
    SELECT
        p.PROD_CATEGORY,
        SUM(s.QUANTITY_SOLD) AS TOTAL_QUANTITY_SOLD
    FROM SALES s
    JOIN PRODUCTS p ON s.PROD_ID = p.PROD_ID
    GROUP BY p.PROD_CATEGORY, s.TIME_ID
),
MaxDailySalesProdCategory AS (
    SELECT
        PROD_CATEGORY,
        MAX(TOTAL_QUANTITY_SOLD) AS MAX_SOLD
    FROM DailySalesProdCategory
    GROUP BY PROD_CATEGORY
)
SELECT * FROM MaxDailySalesProdCategory ORDER BY MAX_SOLD DESC
;

-- Контрольное задание №11

/*
Написать запрос, который создаст таблицу с именем sales_[имя пользователя в ОС]_[Ваше имя]_[Ваша фамилия],
содержащую строки из таблицы sh.sales за один пиковый месяц.
(Т.е. месяц, за который получена максимальная выручка).
Показать все поля таблицы в порядке возрастания дат.
*/
CREATE TABLE sales_SH_Станислав_Базуев AS
WITH MonthlyRevenue AS (
    SELECT
        t.CALENDAR_MONTH_DESC,
        s.PROD_ID,
        s.CUST_ID,
        s.TIME_ID,
        s.CHANNEL_ID,
        s.PROMO_ID,
        s.QUANTITY_SOLD,
        s.AMOUNT_SOLD,
        SUM(s.QUANTITY_SOLD * s.AMOUNT_SOLD) OVER (PARTITION BY t.CALENDAR_MONTH_DESC) AS TOTAL_REVENUE
    FROM SALES s
    JOIN TIMES t ON s.TIME_ID = t.TIME_ID
	)
SELECT
    PROD_ID,
    CUST_ID,
    TIME_ID,
    CHANNEL_ID,
    PROMO_ID,
    QUANTITY_SOLD,
    AMOUNT_SOLD
FROM MonthlyRevenue
WHERE CALENDAR_MONTH_DESC = (
    SELECT CALENDAR_MONTH_DESC
    FROM MonthlyRevenue
    GROUP BY CALENDAR_MONTH_DESC
    ORDER BY SUM(TOTAL_REVENUE) DESC
    FETCH FIRST 1 ROW ONLY
)
ORDER BY TIME_ID
;
SELECT * FROM sales_SH_Станислав_Базуев;

-- Контрольное задание №12

/*
Написать запрос, который для созданной в задании 11 таблицы
изменит значение поля time_id на формат 'DD.MM.YYYY HH24:MI:SS' (см. NLS_DATE_FORMAT).
Значение hh24:mm:ss должно выбираться случайным образом.
Сохранить сделанные изменения.
Показать все поля таблицы в порядке возрастания дат.
SELECT dbms_random.value FROM DUAL возвращает случайное значение от 0 до 1;
*/

-- ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY HH24:MI:SS';

ALTER TABLE sales_SH_Станислав_Базуев ADD NEW_TIME_ID VARCHAR(20);

UPDATE sales_SH_Станислав_Базуев
	SET NEW_TIME_ID = TO_CHAR(TIME_ID + INTERVAL '1' SECOND * ROUND(dbms_random.value(0, 86399)),
					          'DD.MM.YYYY HH24:MI:SS'
);
ALTER TABLE sales_SH_Станислав_Базуев DROP COLUMN TIME_ID;
ALTER TABLE sales_SH_Станислав_Базуев RENAME COLUMN NEW_TIME_ID TO TIME_ID;

SELECT * FROM sales_SH_Станислав_Базуев ORDER BY TIME_ID;

-- ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';


-- Контрольное задание №13

/*
Написать запрос, выводящий почасовую разбивку количества операций продажи для Вашей таблицы.
*/
WITH GroupDateHour AS(
	SELECT
		REGEXP_REPLACE(TIME_ID, REGEXP_SUBSTR(TIME_ID, '.(\d\d:\d\d)$', 1, 1, NULL, 1), '00:00') AS DATE_HOUR
	FROM sales_SH_Станислав_Базуев
	)
SELECT
	DATE_HOUR,
	COUNT(*) AS COUNT_SALES
FROM GroupDateHour
GROUP BY DATE_HOUR
ORDER BY DATE_HOUR
;

-- Контрольное задание №14

/*
Написать запрос, который удалит созданную в задании 11 таблицу.
Сохранить сделанные изменения.
*/
DROP TABLE sales_SH_Станислав_Базуев;
