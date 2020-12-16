CREATE DATABASE QLCB
USE QLCB

--CHUYENBAY(MaCB, GaDi, GaDen, DoDai, GioDi, GioDen, ChiPhi, MaMB)
CREATE TABLE CHUYENBAY
(
	MACB VARCHAR(5) PRIMARY KEY,
	GADI VARCHAR(50) NOT NULL,
	GADEN VARCHAR(50) NOT NULL,
	DODAI INT NOT NULL CHECK(DODAI > 0),
	GIODI TIME NOT NULL,
	GIODEN TIME NOT NULL,
	CHIPHI INT CHECK (CHIPHI > 0) NOT NULL,
	MAMB INT,
	FOREIGN KEY (MAMB) REFERENCES MAYBAY(MAMB)
)

--MAYBAY(MaMB, Loai, TamBay)
CREATE TABLE MAYBAY
(
	MAMB INT PRIMARY KEY,
	LOAI NVARCHAR(50) NOT NULL,
	TAMBAY INT NOT NULL, 
)

--NHANVIEN(MaNV, Ten, Luong)
CREATE TABLE NHANVIEN
(
	MANV VARCHAR(9) PRIMARY KEY,
	TEN NVARCHAR(50) NOT NULL,
	LUONG INT NOT NULL
)
--CHUNGNHAN(MaNV, MaMB)
CREATE TABLE CHUNGNHAN
(
	MANV VARCHAR(9),
	MAMB INT,
	PRIMARY KEY(MANV, MAMB),
	FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV),
	FOREIGN KEY (MAMB) REFERENCES MAYBAY(MAMB)
)

SELECT * FROM CHUNGNHAN
SELECT * FROM MAYBAY
SELECT * FROM CHUYENBAY
SELECT * FROM NHANVIEN

--Chọn và kết:
--1)	Cho biết các chuyến bay đi Đà Lạt (DAD).
SELECT *
FROM CHUYENBAY
WHERE GADEN = 'DAD'

--2)	Cho biết các loại máy bay có tầm bay lớn hơn 10,000km.
SELECT MAMB, LOAI
FROM MAYBAY
WHERE TAMBAY > 10000

--3)	Tìm các nhân viên có lương nhỏ hơn 10,000.
SELECT *
FROM NHANVIEN
WHERE LUONG < 10000

--4)	Cho biết các chuyến bay có độ dài đường bay nhỏ hơn 10.000km và lớn hơn 8.000km.
SELECT *
FROM CHUYENBAY
WHERE DODAI BETWEEN 8000 AND 10000

--5)	Cho biết các chuyến bay xuất phát từ Sài Gòn (SGN) đi Ban Mê Thuộc (BMV).
SELECT *
FROM CHUYENBAY
WHERE GADI = 'SGN' AND GADEN = 'BMV'

--6)	Có bao nhiêu chuyến bay xuất phát từ Sài Gòn (SGN).
SELECT COUNT(MACB) AS [SL]
FROM CHUYENBAY
WHERE GADI = 'SGN'

--7)	Có bao nhiêu loại máy báy Boeing.
SELECT COUNT(MAMB) AS [SL]
FROM MAYBAY
WHERE LOAI LIKE 'BOEING%'

--8)	Cho biết tổng số lương phải trả cho các nhân viên.
SELECT SUM(LUONG) AS [TONGLUONG]
FROM NHANVIEN

--9)	Cho biết mã số của các phi công lái máy báy Boeing.
SELECT B.MANV
FROM MAYBAY A, CHUNGNHAN B
WHERE LOAI LIKE 'BOEING%' AND A.MAMB = B.MAMB
GROUP BY B.MANV

--10)	Cho biết các nhân viên có thể lái máy bay có mã số 747.
SELECT B.MANV, B.TEN
FROM CHUNGNHAN A, NHANVIEN B
WHERE A.MAMB = 747 AND A.MANV = B.MANV

--11)	Cho biết mã số của các loại máy bay mà nhân viên có họ Nguyễn có thể lái.
SELECT B.MAMB
FROM NHANVIEN A, CHUNGNHAN B
WHERE A.TEN LIKE N'Nguyễn%' AND A.MANV = B.MANV;

--12)	Cho biết mã số của các phi công vừa lái được Boeing vừa lái được Airbus.
SELECT AI.MANV
FROM
(SELECT B.MANV FROM MAYBAY A, CHUNGNHAN B WHERE A.MAMB = B.MAMB AND LOAI LIKE 'Boeing%' GROUP BY B.MANV) AS BO
INNER JOIN
(SELECT B.MANV FROM MAYBAY A, CHUNGNHAN B WHERE A.MAMB = B.MAMB AND LOAI LIKE 'Airbus%' GROUP BY B.MANV) AS AI
ON AI.MANV = BO.MANV

--13)	Cho biết các loại máy bay có thể thực hiện chuyến bay VN280.
SELECT A.LOAI
FROM MAYBAY A, CHUYENBAY B
WHERE B.MACB = 'VN280' AND A.MAMB = B.MAMB

--14)	Cho biết các chuyến bay có thể được thực hiện bởi máy bay Airbus A320.
SELECT *
FROM CHUYENBAY A, MAYBAY B
WHERE B.LOAI = 'Airbus A320' AND A.MAMB = B.MAMB

--15)	Cho biết tên của các phi công lái máy bay Boeing.
SELECT A.TEN
FROM NHANVIEN A, CHUNGNHAN B
WHERE A.MANV = B.MANV AND B.MAMB IN (SELECT MAMB FROM MAYBAY WHERE LOAI LIKE 'Boeing%')
GROUP BY A.TEN

--16)	Với mỗi loại máy bay có phi công lái cho biết mã số, loại máy báy và tổng số phi công có thể lái loại máy bay đó.
SELECT A.MAMB, B.LOAI, A.SL
FROM
(SELECT MAMB, COUNT(MAMB) AS [SL]
FROM CHUNGNHAN
GROUP BY MAMB) AS A
LEFT JOIN MAYBAY AS B ON A.MAMB = B.MAMB

--17)	Giả sử một hành khách muốn đi thẳng từ ga A đến ga B rồi quay trở về ga A. Cho biết các đường bay nào có thể đáp ứng yêu cầu này.
SELECT A.MACB
FROM CHUYENBAY A, CHUYENBAY B
WHERE A.GADEN = B.GADI AND A.GADI = B.GADEN

--Gom nhóm:
--18)	Với mỗi ga có chuyến bay xuất phát từ đó cho biết có bao nhiêu chuyến bay khởi hành từ ga đó.
SELECT GADI, COUNT(GADI) AS [SL]
FROM CHUYENBAY
GROUP BY GADI

--19)	Với mỗi ga có chuyến bay xuất phát từ đó cho biết tổng chi phí phải trả cho phi công lái các chuyến bay khởi hành từ ga đó.
SELECT GADI, SUM(CHIPHI) AS [CHIPHI]
FROM CHUYENBAY
GROUP BY GADI

--20)	Với mỗi địa điểm xuất phát cho biết có bao nhiêu chuyến bay có thể khởi hành trước 12:00.
SELECT GADI, COUNT(GADI) AS [SL]
FROM CHUYENBAY
WHERE GIODI < '12:00:00'
GROUP BY GADI

--21)	Cho biết mã số của các phi công chỉ lái được 3 loại máy bay.
SELECT MANV
FROM CHUNGNHAN
GROUP BY MANV
HAVING COUNT(MAMB) = 3

--22)	Với mỗi phi công có thể lái nhiều hơn 3 loại máy bay, cho biết mã số phi công và tầm bay lớn nhất của các loại máy bay mà phi công đó có thể lái.
SELECT A.MANV, MAX(B.TAMBAY) AS [TBLN]
FROM CHUNGNHAN A, MAYBAY B
WHERE A.MAMB = B.MAMB
GROUP BY A.MANV
HAVING COUNT(A.MAMB) > 3

--23)	Với mỗi phi công cho biết mã số phi công và tổng số loại máy bay mà phi công đó có thể lái.
SELECT MANV, COUNT(MAMB) AS [SOMB]
FROM CHUNGNHAN
GROUP BY MANV

--24)	Cho biết mã số của các phi công có thể lái được nhiều loại máy bay nhất.
SELECT TOP(1) WITH TIES MANV
FROM CHUNGNHAN
GROUP BY MANV
ORDER BY COUNT(MAMB) DESC

--25)	Cho biết mã số của các phi công có thể lái được ít loại máy bay nhất.
SELECT TOP(1) WITH TIES MANV
FROM CHUNGNHAN
GROUP BY MANV
ORDER BY COUNT(MAMB) ASC

--Truy vấn lồng:
--26)	Tìm các nhân viên không phải là phi công.
SELECT MANV, TEN
FROM NHANVIEN
WHERE MANV NOT IN (SELECT MANV FROM CHUNGNHAN GROUP BY MANV)

--27)	Cho biết mã số của các nhân viên có lương cao nhất.
SELECT TOP(1) WITH TIES MANV
FROM NHANVIEN
ORDER BY LUONG DESC

--28)	Cho biết tổng số lương phải trả cho các phi công.
SELECT SUM(LUONG) AS [TONG LUONG]
FROM NHANVIEN
WHERE MANV IN (SELECT MANV FROM CHUNGNHAN GROUP BY MANV)

--29)	Tìm các chuyến bay có thể được thực hiện bởi tất cả các loại máy bay Boeing.
SELECT *
FROM CHUYENBAY
WHERE MAMB IN (SELECT MAMB FROM MAYBAY WHERE LOAI LIKE 'Boeing%')

--30)	Cho biết mã số của các máy bay có thể được sử dụng để thực hiện chuyến bay từ Sài Gòn (SGN) đến Huế (HUI).
SELECT MAMB
FROM CHUYENBAY
WHERE GADI = 'SGN' AND GADEN = 'HUI'

--31)	Tìm các chuyến bay có thể được lái bởi các phi công có lương lớn hơn 100,000.
SELECT A.MACB, A.GADI, A.GADEN, A.GIODI, A.GIODEN, A.CHIPHI, A.MAMB
FROM CHUYENBAY A WHERE MAMB IN
(SELECT A.MAMB
FROM CHUNGNHAN A, NHANVIEN B
WHERE A.MANV = B.MANV AND B.LUONG > 100000) 


--32)	Cho biết tên các phi công có lương nhỏ hơn chi phí thấp nhất của đường bay từ Sài Gòn (SGN) đến Buôn Mê Thuộc (BMV).
SELECT TEN
FROM NHANVIEN
WHERE MANV IN
(SELECT A.MANV
FROM CHUNGNHAN A, NHANVIEN B
WHERE A.MANV = B.MANV AND B.LUONG < (SELECT TOP(1) WITH TIES CHIPHI FROM CHUYENBAY WHERE GADI = 'SGN' AND GADEN = 'BMV' ORDER BY CHIPHI ASC)
GROUP BY A.MANV)

--33)	Cho biết mã số của các phi công có lương cao nhất.
SELECT TOP(1) WITH TIES MANV
FROM NHANVIEN
WHERE MANV IN (SELECT MANV FROM CHUNGNHAN GROUP BY MANV)
ORDER BY LUONG DESC

--34)	Cho biết mã số của các nhân viên có lương cao thứ nhì.
SELECT TOP(1) WITH TIES MANV
FROM NHANVIEN
WHERE LUONG < (SELECT MAX(LUONG) FROM NHANVIEN)
ORDER BY LUONG DESC

--35)	Cho biết mã số của các nhân viên có lương cao thứ nhất hoặc thứ nhì.
SELECT TOP(2) WITH TIES MANV
FROM NHANVIEN
ORDER BY LUONG DESC

--36)	Cho biết tên và lương của các nhân viên không phải là phi công và có lương lớn hơn lương trung bình của tất cả các phi công.
SELECT TEN, LUONG
FROM NHANVIEN
WHERE MANV NOT IN (SELECT MANV FROM CHUNGNHAN)
AND LUONG > (SELECT AVG(LUONG) FROM NHANVIEN WHERE MANV IN (SELECT MANV FROM CHUNGNHAN))

--37)	Cho biết tên các phi công có thể lái các máy bay có tầm bay lớn hơn 4,800km nhưng không có chứng nhận lái máy bay Boeing.
SELECT A.TEN
FROM NHANVIEN A, CHUNGNHAN B
WHERE B.MANV NOT IN (SELECT MANV FROM CHUNGNHAN WHERE MAMB IN (SELECT MAMB FROM MAYBAY WHERE LOAI LIKE 'Boeing%'))
AND B.MAMB IN (SELECT MAMB FROM MAYBAY WHERE TAMBAY > 4800 AND LOAI NOT LIKE 'Boeing%')
AND A.MANV = B.MANV

--38)	Cho biết tên các phi công lái ít nhất 3 loại máy bay có tầm bay xa hơn 3200km.
SELECT TEN
FROM NHANVIEN
WHERE MANV IN (SELECT MANV
FROM CHUNGNHAN
WHERE MAMB IN (SELECT MAMB FROM MAYBAY WHERE TAMBAY > 3200)
GROUP BY MANV
HAVING COUNT(MAMB) >= 3 
)

--Kết ngoài:
--39)	Với mỗi nhân viên cho biết mã số, tên nhân viên và tổng số loại máy bay mà nhân viên đó có thể lái.
SELECT A.MANV, A.TEN, ISNULL(PC.SL,0)
FROM
NHANVIEN A
LEFT JOIN
(SELECT MANV, COUNT(MAMB) AS [SL] FROM CHUNGNHAN GROUP  BY MANV) AS PC
ON A.MANV = PC.MANV;

--40)	Với mỗi nhân viên cho biết mã số, tên nhân viên và tổng số loại máy bay Boeing mà nhân viên đó có thể lái.
SELECT A.MANV, A.TEN, ISNULL(PC.SL,0)
FROM
NHANVIEN A
LEFT JOIN
(SELECT MANV, COUNT(MAMB) AS [SL] FROM CHUNGNHAN WHERE MAMB IN (SELECT MAMB FROM MAYBAY WHERE LOAI LIKE 'Boeing%') GROUP BY MANV) AS PC
ON A.MANV = PC.MANV

--41)	Với mỗi loại máy bay cho biết loại máy bay và tổng số phi công có thể lái loại máy bay đó.
SELECT B.MAMB, B.LOAI, A.SLPC
FROM
(SELECT MAMB, COUNT(MANV) AS [SLPC] FROM CHUNGNHAN GROUP BY MAMB) AS A
LEFT JOIN MAYBAY B
ON A.MAMB = B.MAMB

--42)	Với mỗi loại máy bay cho biết loại máy bay và tổng số chuyến bay không thể thực hiện bởi loại máy bay đó.
SELECT B.MAMB, B.LOAI, C.SL
FROM
(SELECT MAMB FROM CHUNGNHAN GROUP BY MAMB) AS A
INNER JOIN MAYBAY B
ON A.MAMB = B.MAMB
INNER JOIN (SELECT MAMB, ((SELECT COUNT(MACB) FROM CHUYENBAY) - COUNT(MACB)) AS [SL] FROM CHUYENBAY GROUP BY MAMB) AS C
ON C.MAMB = B.MAMB

--43)	Với mỗi loại máy bay cho biết loại máy bay và tổng số phi công có lương lớn hơn 100,000 có thể lái loại máy bay đó.
SELECT  B.MAMB, A.LOAI, B.SL
FROM
MAYBAY A
INNER JOIN (SELECT A.MAMB, COUNT(A.MANV) AS [SL] FROM CHUNGNHAN A, NHANVIEN B WHERE A.MANV = B.MANV AND B.LUONG > 100000 GROUP BY A.MAMB) AS B
ON A.MAMB = B.MAMB

--44)	Với mỗi loại máy bay có tầm bay trên 3200km, cho biết tên của loại máy bay và lương trung bình của các phi công có thể lái loại máy bay đó.
SELECT A.MAMB, A.LOAI, B.TBL
FROM
(SELECT MAMB, LOAI FROM MAYBAY WHERE TAMBAY > 3200) AS A
INNER JOIN (SELECT A.MAMB, AVG(B.LUONG) AS [TBL] FROM CHUNGNHAN A, NHANVIEN B WHERE A.MANV = B.MANV GROUP BY A.MAMB) AS B
ON A.MAMB = B.MAMB

--45)	Với mỗi loại máy bay cho biết loại máy bay và tổng số nhân viên không thể lái loại máy bay đó.
SELECT A.MAMB, A.LOAI, ((SELECT COUNT(MANV) FROM NHANVIEN) - B.SL) AS TONGNV
FROM MAYBAY A
INNER JOIN (SELECT MAMB, COUNT(MANV) AS[SL] FROM CHUNGNHAN GROUP BY MAMB) AS B
ON A.MAMB = B.MAMB

--46)	Với mỗi loại máy bay cho biết loại máy bay và tổng số phi công không thể lái loại máy bay đó.
SELECT A.MAMB, A.LOAI, ((SELECT COUNT(MANV) FROM (SELECT MANV FROM CHUNGNHAN GROUP BY MANV) AS C) - B.SL) AS TONGNV
FROM MAYBAY A
INNER JOIN (SELECT MAMB, COUNT(MANV) AS[SL] FROM CHUNGNHAN GROUP BY MAMB) AS B
ON A.MAMB = B.MAMB

--47)	Với mỗi nhân viên cho biết mã số, tên nhân viên và tổng số chuyến bay xuất phát từ Sài Gòn mà nhân viên đó có thể lái.
SELECT B.MANV, B.TEN, ISNULL(A.SL,0) AS SL
FROM
(SELECT MANV, COUNT(MAMB) AS SL FROM CHUNGNHAN WHERE MAMB IN (SELECT MAMB FROM CHUYENBAY WHERE GADI = 'SGN' GROUP BY MAMB) GROUP BY MANV) A
RIGHT JOIN NHANVIEN B
ON B.MANV = A.MANV;

--48)	Với mỗi nhân viên cho biết mã số, tên nhân viên và tổng số chuyến bay xuất phát từ Sài Gòn mà nhân viên đó không thể lái.
SELECT B.MANV, B.TEN, ISNULL(((SELECT COUNT(MACB) FROM CHUYENBAY WHERE GADI = 'SGN') - A.SL),(SELECT COUNT(MACB) FROM CHUYENBAY WHERE GADI = 'SGN')) AS SL
FROM
(SELECT MANV, COUNT(MAMB) AS SL FROM CHUNGNHAN WHERE MAMB IN (SELECT MAMB FROM CHUYENBAY WHERE GADI = 'SGN' GROUP BY MAMB) GROUP BY MANV) A
RIGHT JOIN NHANVIEN B
ON B.MANV = A.MANV;

--49)	Với mỗi phi công cho biết mã số, tên phi công và tổng số chuyến bay xuất phát từ Sài Gòn mà phi công đó có thể lái.
SELECT D.MANV, E.TEN, ISNULL(C.SL,0) AS SL
FROM
(SELECT MANV, COUNT(A.MAMB) AS SL
   FROM
   (SELECT MAMB FROM CHUYENBAY WHERE GADI = 'SGN' GROUP BY MAMB) A
   INNER JOIN
   CHUNGNHAN B 
   ON B.MAMB =A.MAMB
   GROUP BY MANV
) AS C
RIGHT JOIN
(SELECT MANV FROM CHUNGNHAN GROUP BY MANV) D
ON D.MANV = C.MANV
INNER JOIN
NHANVIEN E
ON E.MANV = D.MANV;

--50)	Với mỗi phi công cho biết mã số, tên phi công và tổng số chuyến bay xuất phát từ Sài Gòn mà phi công đó không thể lái.
SELECT B.MANV, C.TEN, ISNULL(((SELECT COUNT(MACB) FROM CHUYENBAY WHERE GADI = 'SGN') - A.SL),(SELECT COUNT(MACB) FROM CHUYENBAY WHERE GADI = 'SGN')) AS SL
FROM
(SELECT MANV, COUNT(MAMB) AS SL FROM CHUNGNHAN WHERE MAMB IN (SELECT MAMB FROM CHUYENBAY WHERE GADI = 'SGN' GROUP BY MAMB) GROUP BY MANV) AS A
RIGHT JOIN
(SELECT MANV FROM CHUNGNHAN GROUP BY MANV) AS B
ON B.MANV = A.MANV
LEFT JOIN NHANVIEN C
ON C.MANV = B.MANV

--51)	Với mỗi chuyến bay cho biết mã số chuyến bay và tổng số loại máy bay không thể thực hiện chuyến bay đó.


--52)	Với mỗi chuyến bay cho biết mã số chuyến bay và tổng số loại máy bay có thể thực hiện chuyến bay đó.

--53)	Với mỗi chuyến bay cho biết mã số chuyến bay và tổng số nhân viên không thể lái chuyến bay đó.
SELECT A.MACB, ((SELECT COUNT(MANV) FROM NHANVIEN) - B.SL) AS SL
FROM CHUYENBAY A
LEFT JOIN
(SELECT MAMB, COUNT(MANV) AS SL FROM CHUNGNHAN GROUP BY MAMB) AS B
ON A.MAMB = B.MAMB

--54)	Với mỗi chuyến bay cho biết mã số chuyến bay và tổng số phi công không thể lái chuyến bay đó.
SELECT A.MACB, ((SELECT COUNT(MANV) FROM NHANVIEN WHERE MANV IN (SELECT MANV FROM CHUNGNHAN GROUP BY MANV)) - B.SL) AS SL
FROM CHUYENBAY A
LEFT JOIN
(SELECT MAMB, COUNT(MANV) AS SL FROM CHUNGNHAN GROUP BY MAMB) AS B
ON A.MAMB = B.MAMB

--Exists và các dạng khác:
--55)	Một hành khách muốn đi từ Hà Nội (HAN) đến Nha Trang (CXR) mà không phải đổi chuyến bay quá một lần. Cho biết mã chuyến bay và thời gian khởi hành từ Hà Nội nếu hành khách muốn đến Nha Trang trước 16:00.
--56)	Cho biết tên các loại máy bay mà tất cả các phi công có thể lái đều có lương lớn hơn 200,000.
--57)	Cho biết thông tin của các đường bay mà tất cả các phi công có thể bay trên đường bay đó đều có lương lớn hơn 100,000.
--58)	Cho biết tên các phi công chỉ lái các loại máy bay có tầm bay xa hơn 3200km.
--59)	Cho biết tên các phi công chỉ lái các loại máy bay có tầm bay xa hơn 3200km và một trong số đó là Boeing.
--60)	Tìm các phi công có thể lái tất cả các loại máy bay.
--61)	Tìm các phi công có thể lái tất cả các loại máy bay Boeing.
--CÁCH 1
SELECT MANV FROM CHUNGNHAN WHERE MAMB IN (SELECT MAMB FROM MAYBAY WHERE LOAI LIKE 'Boeing%') GROUP BY MANV
--CÁCH 2:
