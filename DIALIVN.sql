Create database DIALIVN
USE DIALIVN
--TINH_TP (MA_T_TP, TEN_T_TP,DT,DS,MIEN)

CREATE TABLE TINH_TP
(
	MA_T_TP VARCHAR(5) PRIMARY KEY,
	TEN_T_TP NVARCHAR(30) NOT NULL,
	DT FLOAT NOT NULL,
	DS INT NOT NULL,
	MIEN NVARCHAR(10)
)

CREATE TABLE BIENGIOI
(
	NUOC VARCHAR(5),
	MA_T_TP VARCHAR(5),
	FOREIGN KEY (MA_T_TP) REFERENCES TINH_TP(MA_T_TP),
	PRIMARY KEY (NUOC,MA_T_TP)
)
 CREATE TABLE LANGGIENG 
 (
	MA_T_TP VARCHAR(5),
	LG VARCHAR(5),
	FOREIGN KEY (MA_T_TP) REFERENCES TINH_TP(MA_T_TP),
	PRIMARY KEY (MA_T_TP,LG)
 )


SELECT * FROM TINH_TP
SELECT * FROM BIENGIOI
SELECT * FROM LANGGIENG

INSERT INTO TINH_TP (MA_T_TP, TEN_T_TP, DT, DS, MIEN)
VALUES ('BDI',N'Bình Định', 6025,1486465, 'Trung')
DELETE FROM TINH_TP
UPDATE TINH_TP SET DT = 6055.70 WHERE MA_T_TP = 'HTI' 

--1.	Xuất ra tên tỉnh, TP cùng với dân số của tỉnh, TP:
--a) Có diện tích >= 5000 Km2
SELECT TEN_T_TP, DS
FROM TINH_TP
WHERE DT >= 5000

--b) Có diện tích >= [input] (SV nhập một số bất kỳ từ bàn phím)
SELECT TEN_T_TP, DS
FROM TINH_TP
WHERE DT >= 6000

--2.	Xuất ra tên tỉnh, TP cùng với diện tích của tỉnh, TP:
--a) Thuộc miền Bắc
SELECT TEN_T_TP, DT
FROM TINH_TP
WHERE MIEN = N'Bắc'

--b) Thuộc miền [input] (SV nhập một miền bất kỳ từ bàn phím)
SELECT TEN_T_TP
FROM TINH_TP
WHERE MIEN = 'Trung'

--3.	Xuất ra các Tên tỉnh, TP biên giới thuộc miền [input] (SV cho một miền bất kỳ)
SELECT TEN_T_TP, NUOC
FROM TINH_TP A, BIENGIOI B
WHERE A.MA_T_TP = B.MA_T_TP AND A.MIEN = 'Trung'

--4.	Cho biết diện tích trung bình của các tỉnh, TP (Tổng DT/Tổng số tỉnh_TP).
SELECT SUM(DT)/64 AS [DIEN TICH TRUNG BINH]
FROM TINH_TP

--5.	Cho biết dân số cùng với tên tỉnh của các tỉnh, TP có diện tích > 7000 Km2.
SELECT DS, TEN_T_TP
FROM TINH_TP
WHERE DT >= 7000

--6.	Cho biết dân số cùng với tên tỉnh của các tỉnh miền ‘Bắc’.
SELECT DS, TEN_T_TP
FROM TINH_TP
WHERE MIEN = N'Bắc'

--7.	Cho biết mã các nước là biên giới của các tỉnh miền ‘Nam’
SELECT NUOC
FROM TINH_TP A, BIENGIOI B
WHERE A.MA_T_TP = B.MA_T_TP AND A.MIEN = 'Nam'

--8.	Cho biết diện tích trung bình của các tỉnh, TP. (Sử dụng hàm)
SELECT AVG(DT) AS [DIỆN TÍCH TRUNG BÌNH]
FROM TINH_TP

--9.	Cho biết mật độ dân số (DS/DT) cùng với tên tỉnh, TP của tất cả các tỉnh, TP.
SELECT (DS/DT) AS [MẬT ĐỘ DS], TEN_T_TP
FROM TINH_TP
	
--10.	Cho biết tên các tỉnh, TP láng giềng của tỉnh ‘Long An’.
SELECT TEN_T_TP
FROM TINH_TP A, LANGGIENG B, (SELECT MA_T_TP FROM TINH_TP WHERE TEN_T_TP = N'Long An') AS C
WHERE A.MA_T_TP = B.MA_T_TP AND B.LG = C.MA_T_TP

--11.	Cho biết số lượng các tỉnh, TP giáp với ‘CPC’.
SELECT COUNT(TEN_T_TP) AS [SO LUONG]
FROM TINH_TP A, BIENGIOI B
WHERE A.MA_T_TP = B.MA_T_TP AND B.NUOC = 'CPC'

--12.	Cho biết tên những tỉnh, TP có diện tích lớn nhất.
SELECT TEN_T_TP
FROM TINH_TP
WHERE DT IN (SELECT MAX(DT) FROM TINH_TP)

--13.	Cho biết tỉnh, TP có mật độ DS đông nhất.
SELECT TEN_T_TP
FROM TINH_TP
WHERE DS IN (SELECT MAX(DS) FROM TINH_TP)

--14.	Cho biết tên những tỉnh, TP giáp với hai nước biên giới khác nhau.
SELECT TEN_T_TP
FROM TINH_TP AS A, BIENGIOI AS B
WHERE A.MA_T_TP = B.MA_T_TP
GROUP BY TEN_T_TP
HAVING COUNT(TEN_T_TP) = 2

--15.	Cho biết danh sách các miền cùng với các tỉnh, TP trong các miền đó.
SELECT MIEN, TEN_T_TP
FROM TINH_TP
GROUP BY MIEN, TEN_T_TP

--16.	Cho biết tên những tỉnh, TP có nhiều láng giềng nhất.
SELECT TOP (1) WITH TIES TEN_T_TP
FROM TINH_TP A, LANGGIENG B
WHERE A.MA_T_TP = B.MA_T_TP
GROUP BY TEN_T_TP
ORDER BY (COUNT(TEN_T_TP)) DESC


--17.	Cho biết những tỉnh, TP có diện tích nhỏ hơn diện tích trung bình của tất cả tỉnh, TP.
SELECT TEN_T_TP
FROM TINH_TP
WHERE DT < (SELECT AVG(DT)	FROM TINH_TP)

--18.	Cho biết tên những tỉnh, TP giáp với các tỉnh, TP ở miền ‘Nam’ và không phải là miền ‘Nam’.
SELECT TEN_T_TP
FROM TINH_TP A, LANGGIENG B
WHERE A.MA_T_TP = B.MA_T_TP
	AND B.MA_T_TP NOT IN (SELECT MA_T_TP FROM TINH_TP WHERE MIEN = 'Nam')
	AND B.LG IN (SELECT MA_T_TP FROM TINH_TP WHERE MIEN = 'NAM')

--19.	Cho biết tên những tỉnh, TP có diện tích lớn hơn tất cả các tỉnh, TP láng giềng của nó.
SELECT A.TEN_T_TP, A.DT
FROM TINH_TP A
WHERE A.DT > ALL(SELECT MAX(B.DT) FROM TINH_TP B, LANGGIENG C WHERE B.MA_T_TP = C.LG AND A.MA_T_TP = C.MA_T_TP)
--20.	Cho biết tên những tỉnh, TP mà ta có thể đến bằng cách đi từ ‘TP.HCM’ xuyên qua ba tỉnh khác nhau và cũng khác với điểm xuất phát, nhưng láng giềng với nhau.
SELECT A.TEN_T_TP AS [TENTP], COUNT(LG) AS SOLG
FROM TINH_TP A, LANGGIENG B
WHERE A.MA_T_TP = B.LG
GROUP BY A.TEN_T_TP
HAVING COUNT(LG) > 3
ORDER BY COUNT(LG) ASC;


(SELECT TEN_T_TP
FROM TINH_TP A, LANGGIENG B, (SELECT MA_T_TP FROM TINH_TP WHERE TEN_T_TP = N'TP Hồ Chí Minh') AS C
WHERE A.MA_T_TP = B.MA_T_TP AND B.LG = C.MA_T_TP) AS LGTP

(SELECT TEN_T_TP
FROM TINH_TP A, LANGGIENG B, (SELECT MA_T_TP FROM TINH_TP WHERE TEN_T_TP = LGTP.TEN_T_TP) AS C
WHERE A.MA_T_TP = B.MA_T_TP AND B.LG = C.MA_T_TP)