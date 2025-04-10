-- mysql -u root -p mySQLへログインコマンド
-- exit; 抜ける
-- mysql -u root -p < employee.sql exit;してから データの更新コマンド

-- どのデータベースを使うか指定 ※これができずにエラーがずっと出てた。
USE my_database;

CREATE TABLE IF NOT EXISTS EMPLOYEE ( -- NOT EXISTS(存在しなければテーブルを作る)
  ID INT AUTO_INCREMENT PRIMARY KEY,
  NAME VARCHAR (50) NOT NULL,
  AGE INT NOT NULL,
  JOB VARCHAR (50) NOT NULL,
  SAL INT NOT NULL
);

INSERT INTO EMPLOYEE (NAME, AGE, JOB, SAL) -- INSERT INTO テーブル名(Column, Column, Column) [テーブル名]の指定カラムに入れるよ
VALUES -- VALUES (次のデータを入れるよ)
('松田', 65, '社長', 950000),
('山田', 43, '部長', 680000),
('北條', 30, '営業マネージャー', 600000);

INSERT INTO EMPLOYEE (NAME, AGE, JOB, SAL)
VALUES
('佐藤次郎', 35, '営業部', 500000); 

-- 応用編で使うSELECT文の学習

-- INNER JOIN
SELECT EMPLOYEES.NAME, DEPARTMENTS.DEPARTMENT_NAME -- 抽出するそれぞれのデータ＝ EMPLOYEESのNAMEとDEPARTMENTSのdepartment_NAME
FROM EMPLOYEES -- 抽出元１
INNER JOIN DEPARTMENTS  -- 抽出元２
ON EMPLOYEES.DEPARTMENT_ID = DEPARTMENTS.DEPARTMENT_ID; -- 抽出条件＝ EMPLOYEESのDEPARTMENT_IDとDEPARTMENTSのDEPARTMENT_IDが一致しているデータを抽出

-- LEFT JOIN
SELECT EMPLOYEES.NAME, DEPARTMENTS.DEPARTMENT_NAME
FROM EMPLOYEES
LEFT JOIN DEPARTMENTS 
ON EMPLOYEES.DEPARTMENT_ID = DEPARTMENTS.DEPARTMENT_ID;
-- INNER JOINとの違いは以下
-- 左側（employees）のデータはすべて取得
-- 右側（departments）に一致するデータがない場合は NULL

-- RIGHT JOIN
SELECT EMPLOYEES.NAME, DEPARTMENTS.DEPARTMENT_NAME
FROM EMPLOYEES
RIGHT JOIN DEPARTMENTS 
ON EMPLOYEES.DEPARTMENT_ID = DEPARTMENTS.ID;
-- LEFT JOINの右が全取得になっただけ

-- FULL OUTER JOIN
SELECT EMPLOYEES.NAME, DEPARTMENTS.DEPARTMENT_NAME
FROM EMPLOYEES
FULL OUTER JOIN DEPARTMENTS 
ON EMPLOYEES.DEPARTMENT_ID = DEPARTMENTS.ID;
-- 両方取得、且つ互換がないものはNULL


-- サブクエリ
-- 動的な条件を指定してデータを取得できる

-- 1 SELECTの中で使用
SELECT NAME, AGE
FROM EMPLOYEES
WHERE AGE > (SELECT AVG(AGE) FROM EMPLOYEES);
-- (SELECT AVG(AGE) FROM EMPLOYEES)がサブクエリ
-- AVG(AGE) AGEの平均を算出
-- WHERE AGE > 平均 メインクエリ

-- 2.2 FROM句で使用
SELECT DEPARTMENT, COUNT(*) AS TOTAL_EMPLOYEES -- COUNT(*) 集計
FROM ( SELECT DEPARTMENT_ID, DEPARTMENT FROM EMPLOYEES ) AS SUBQUERY -- ()内がサブクエリ、抽出したデータをSUBQUERYという仮のテーブルとして扱う
GROUP BY DEPARTMENT;
-- サブクエリを整理すると
SELECT DEPARTMENT, COUNT(*) AS TOTAL_EMPLOYEES -- DEPARTMENTの同じ値を'COUNT(*)'する。カウントした数はTOTAL_EMPLOYEESというカラムになる。
FROM SUBQUERY -- サブクエリ(DEPARTMENT_ID, DEPARTMENTを集約したSUBQUERYという仮テーブル)
GROUP BY DEPARTMENT; -- DEPARTMENTというカラム内の同じ値をグループ化するよ！！！
-- SELECT DEPARTMENT, COUNT(*)でDEPARTMENTを集約していると勘違いしてしまう。ここで見てるのはあくまでSUBQUERY.DEPARTMENTである。
-- つまり、GROUP BY DEPARTMENT;がないと、SUBQUERY.DEPARTMENTの行数をCOUNTしているだけになる。

-- 3グループ操作
SELECT DEPARTMENT, AVG(SALARY) AS AVG_SALARY -- EMPLOYEES.DEPARTMENTとEMPLOYEES.SALARYを抽出 さらにEMPLOYEES.SALARYの平均値を計算しAVG_SALARYという仮のカラムを作る
FROM EMPLOYEES -- テーブル名
GROUP BY DEPARTMENT -- EMPLOYEES.DEPARTMENTの同じ値を集約
HAVING AVG(SALARY) > 50000; -- 平均が50000より低いものを集約
-- 結果 EMPLOYEES.DEPARTMENTの同じ値を集約し、同じくEMPLOYEES.DEPARTMENTに紐づいて集約されたSALARYの平均値を取る。その平均値が50000より高いグループ化されたDEPARTMENTを抽出する。
-- 整理すると、、、
SELECT DEPARTMENT, AVG(SALARY) AS AVG_SALARY 
-- ① EMPLOYEESテーブルから DEPARTMENT（部署）と SALARY（給与）を取得
-- ② SALARY の平均値を計算し、AVG_SALARY という仮のカラム名で表示
FROM EMPLOYEES 
-- ③ データの取得元となるテーブル（EMPLOYEES）
GROUP BY DEPARTMENT 
-- ④ DEPARTMENTごとにデータをグループ化
--    例: 「営業」「開発」「人事」など、同じ部署のデータをまとめる
HAVING AVG(SALARY) > 50000; 
-- ⑤ グループ化された各 DEPARTMENT の AVG(SALARY)（平均給与）が 50,000 を超える場合のみ結果に含める
--    → 50,000 以下の部署は結果から除外

-- ウィンドウ関数
SELECT NAME, SALARY,
-- ① EMPLOYEESテーブルから NAME（名前）と SALARY（給料）を取得
-- ② さらに ROW_NUMBER() を使って、順位（1位、2位…）を付ける
ROW_NUMBER() OVER (
  PARTITION BY DEPARTMENT     -- ③ 部署（DEPARTMENT）ごとにデータをグループ分け
  ORDER BY SALARY DESC        -- ④ 部署ごとの中で SALARY を高い順（降順）に並び替える
) AS RANK
-- ⑤ ROW_NUMBER の結果を rank という仮のカラム名で表示
FROM EMPLOYEES;
-- ⑥ データの取得元となるテーブル（EMPLOYEES）

SELECT NAME, SALARY,
-- ① EMPLOYEESテーブルから NAME（名前）と SALARY（給料）を取得
-- ② さらに RANK() を使って、順位（1位、2位…）を付ける
--     ※ 同じ給料の人は同じ順位になる（重複順位あり）
RANK() OVER (
  PARTITION BY DEPARTMENT     -- ③ 部署（DEPARTMENT）ごとにデータをグループ分け（例：営業、開発、人事など）
  ORDER BY SALARY DESC        -- ④ 部署ごとの中で SALARY を高い順（降順）に並び替える
) AS RANK
-- ⑤ RANK() の結果を rank という仮のカラム名で表示
FROM EMPLOYEE;
-- ⑥ データの取得元となるテーブル（EMPLOYEES）

-- RANK()とROW_NUMBER()の違いは？
-- RANK()な同順位にならない！ROW_NUMBER()は同順位になりうる！


SELECT NAME, SALARY,
-- ① EMPLOYEESテーブルから NAME（名前）と SALARY（給料）を取得
-- ② さらに SUM(SALARY) を使って、累積の給与合計（CUMULATIVE_SALARY）を計算する
SUM(SALARY) OVER (
  PARTITION BY DEPARTMENT     -- ③ 部署（DEPARTMENT）ごとにグループ分け（例：営業、開発、人事）
  ORDER BY NAME               -- ④ 各部署の中で名前（NAME）順に並べながら、累積計算していく
) AS CUMULATIVE_SALARY
-- ⑤ 累積された給料の合計を CUMULATIVE_SALARY という仮のカラム名で表示する
FROM EMPLOYEES;
-- ⑥ データの取得元となるテーブル（EMPLOYEES）

-- GROUP BY とPARTITION BYの違いとは！
-- GROUP BY 👉 結果をグループ単位にまとめる（元の行数は減る）
-- PARTITION BY 👉 元の行を保ちながら、グループごとの計算を各行に追加する

-- 5. トランザクション
START TRANSACTION;
-- ① トランザクション（処理のまとまり）を開始する宣言
--    → ここからの処理は「全部成功したら反映、1つでも失敗したら取り消し」
UPDATE accounts SET balance = balance - 1000 WHERE account_id = 1;
-- ② 口座ID 1番の人から1000円引く
UPDATE accounts SET balance = balance + 1000 WHERE account_id = 2;
-- ③ 口座ID 2番の人に1000円足す
COMMIT;
-- ④ 全ての処理を正式にデータベースに反映する
--    → ここで確定し、実際のデータが更新される！

START TRANSACTION;
UPDATE accounts SET balance = balance - 1000 WHERE account_id = 1;
-- （ここでエラーが発生したと想定）
ROLLBACK; -- エラーの場合あ処理を取り消す

-- 通常業務では上記を併用する場合が多い
START TRANSACTION;
-- ① 何かの更新処理
-- ② さらに他の更新処理
-- 👇 処理がすべて成功したかを確認
COMMIT;      -- ✅ 問題なければ、データを確定する
-- 👇 どれか1つでも失敗したら…
ROLLBACK;   -- ❌ 処理を全部なかったことにする

-- インデックス
CREATE INDEX idx_department_id
-- ① インデックスを作成する命令
-- 「idx_department_id」という名前でインデックスを作る
ON employees(department_id);
-- ② インデックスを作る対象のテーブル：employees
-- ③ インデックスを作るカラム：department_id（部署IDなど）
-- → このカラムを使った検索の速度が速くなる！

-- インデックスを削除する場合
DROP INDEX idx_department_id ON employees;