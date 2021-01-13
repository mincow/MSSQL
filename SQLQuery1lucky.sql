CREATE DATABASE QLSANXUAT
USE QLSANXUAT
GO

SET DATEFORMAT DMY;

CREATE TABLE LOAI
(
	MALOAI TINYINT PRIMARY KEY,
	TENLOAI NVARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE SANPHAM
(
	MASP SMALLINT PRIMARY KEY,
	TENSP NVARCHAR(30) NOT NULL,
	MALOAI TINYINT,
	FOREIGN KEY (MALOAI) REFERENCES LOAI(MALOAI)
)

CREATE TABLE NHANVIEN
(
	MANV VARCHAR(5) PRIMARY KEY,
	HOTEN NVARCHAR(20) NOT NULL,
	NGAYSINH DATE CHECK (YEAR(GETDATE()) - YEAR(NGAYSINH) >= 18 AND YEAR(GETDATE()) - YEAR(NGAYSINH) <= 55),
	PHAI CHAR(2) CHECK(PHAI IN (0,1)) DEFAULT 1
)

CREATE TABLE PHIEUXUAT
(
	MAPX INT IDENTITY(1,1) PRIMARY KEY,
	NGAYLAP DATE,
	MANV VARCHAR(5),
	FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV),
)

CREATE TABLE CTPX
(
	MAPX INT,
	MASP SMALLINT,
	SOLUONG INT CHECK (SOLUONG > 0)
	PRIMARY KEY (MAPX,MASP),
	FOREIGN KEY (MAPX) REFERENCES PHIEUXUAT(MAPX),
	FOREIGN KEY (MASP) REFERENCES SANPHAM(MASP)
)


INSERT INTO LOAI VALUES('VT01','VAT LIEU XAY DUNG')

-- CAU 3-3 : CHO BIET SO LUONG SAN PHAM TRONG TUNG LOAI SANPHAM
CREATE VIEW CAU3_3 AS
SELECT L.MALOAI,COUNT(TENSP)SLSP
FROM LOAI L INNER JOIN SANPHAM SP ON L.MALOAI=SP.MALOAI
GROUP BY L.MALOAI
GO
SELECT * FROM CAU3_3 
GO
----------------------------------------------------------------------------------------------------------------------------FUNC THUONG-----------------------------
-- CAU 4-1: Function CAU4_1 có 2 tham số vào là: tên sản phẩm, năm. Function cho biết: 
----số lượng xuất kho của tên sản phẩm này trong năm này. 
----(Chú ý: Nếu tên sản phẩm này không tồn tại thì phải trả về 0)
CREATE FUNCTION CAU4_1(@TENSP NVARCHAR(30),@NAM INT)
RETURNS INT
AS
BEGIN
	DECLARE @SLXUAT INT
	
	IF NOT EXISTS(SELECT * FROM SANPHAM WHERE TENSP LIKE @TENSP)
		SET @SLXUAT=0
	ELSE
		SELECT @SLXUAT=SUM(SOLUONG) 
		FROM SANPHAM SP, PHIEUXUAT PX, CHITIETXUAT CT
		WHERE SP.MASP=CT.MASP AND CT.MAPX=PX.MAPX AND TENSP LIKE @TENSP AND YEAR(NGAYLAP)=@NAM
	RETURN @SLXUAT
END
GO
DECLARE @TENSP NVARCHAR(20),@NAM INT
SET @NAM=2006
SET @TENSP=N'XI MANG'
PRINT 'SO LUONG XUAT CUA SAN PHAM '+@TENSP+ ' TRONG NAM '+CONVERT(VARCHAR(4),@NAM)+' LA '+ CONVERT(VARCHAR(20),DBO.CAU4_1(@TENSP,@NAM))
GO

-----------------------------------------------------------------------------------------------------------------------------FUNC TABLE----------------------------

--4.	Function F4 có một tham số vào là mã nhân viên để trả về danh sách các phiếu xuất của nhân viên đó. Nếu mã nhân viên không truyền vào thì trả về tất cả các phiếu xuất.
GO
CREATE FUNCTION F4 (@MANV VARCHAR(5))
RETURNS @X TABLE (MAPX INT, NGAYLAP DATE, MANV VARCHAR(5))
AS
BEGIN
	IF (@MANV IS NOT NULL)
		BEGIN
			INSERT INTO @X
			SELECT *
			FROM PHIEUXUAT
			WHERE MANV = @MANV
		END
	ELSE
		BEGIN
			INSERT INTO @X
			SELECT *
			FROM PHIEUXUAT
		END
	RETURN
END;
GO

SELECT * FROM dbo.F4 ('NV01')
SELECT * FROM dbo.F4 (NULL)



GO
CREATE FUNCTION F5 (@MAPX INT)
RETURNS NVARCHAR(20)
AS
BEGIN
	DECLARE @X NVARCHAR(20)
	SELECT @X = A.HOTEN
	FROM NHANVIEN A, PHIEUXUAT B
	WHERE A.MANV = B.MANV AND B.MAPX = @MAPX
	RETURN @X
END;
GO

DECLARE @MAPX INT
SET @MAPX = 02
PRINT 'TEN NHAN VIEN CUA PHIEU XUAT CO MA PHIEU XUAT ' + CAST(@MAPX AS NVARCHAR) + ' LA: ' + dbo.F5(@MAPX)

------PROC--------------------------------------------------------------------------------------------------------PROC------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------PROC OUT----------------
-- CAU 5-1: Procedure tên là P1 cho có 2 tham số sau:
--•	1 tham số nhận vào là: tên sản phẩm.
--•	1 tham số trả về cho biết: tổng số lượng xuất kho của tên sản phẩm này trong năm 2006 
--(Không viết lại truy vấn, hãy sử dụng Function F1 ở câu 4 để thực hiện)

CREATE PROCEDURE CAU5_1
@TENSP NVARCHAR(50),
@TONGSL INT OUT
AS
BEGIN
	SELECT @TONGSL=dbo.CAU4_1(@TENSP,2006)
END
GO

DECLARE @TONGSL INT
EXEC CAU5_1 'XI MANG', @TONGSL OUT
PRINT CONVERT(VARCHAR(20),@TONGSL)
GO

-- CAU 5-2:Procedure tên là P2 có 2 tham số sau:
--•	1 tham số nhận vào là: tên sản phẩm.
--•	1 tham số trả về cho biết: tổng số lượng xuất kho của tên sản phẩm này trong khoảng thời gian 
---từ đầu tháng 4/2006 đến hết tháng 6/2006 (Chú ý: Nếu tên sản phẩm này không tồn tại thì trả về 0)

CREATE PROCEDURE CAU5_2
@TENSAP NVARCHAR(50),
@TONGSL INT OUT
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM SANPHAM WHERE TENSP LIKE @TENSAP)
		SET @TONGSL=0
	ELSE
		SELECT @TONGSL=SUM(SOLUONG) 
		FROM SANPHAM SP, PHIEUXUAT PX, CHITIETXUAT CT
		WHERE SP.MASP=CT.MASP AND CT.MAPX=PX.MAPX AND TENSP LIKE @TENSAP AND YEAR(NGAYLAP)=2006 AND (MONTH(NGAYLAP) BETWEEN 4 AND 6)
END
GO

DECLARE @TONGSL INT
EXEC CAU5_2 'XI MANG 1', @TONGSL OUT
PRINT @TONGSL 
GO

----------------------------------------------------------------------------------------------------------------------------------PROC THUONG----------

-- Lấy danh sách các khách hàng mua hàng X,
CREATE PROCEDURE CAU_1 @DATEX smalldatetime
AS
SELECT A.MAKH, B.TENKH FROM HOADON A, KHACHHANG B WHERE A.NGAY = @DATEX AND A.MAKH = B.MAKH
GO

EXEC dbo.CAU_1 @DATEX = '25/05/2010'

---------------------------------------------------------------------------------------------------------------------------PROC LONGG------------------------

-- CAU 5-3:Procedure tên là P3 chỉ có duy nhất 1 tham số nhận vào là tên sản phẩm. 
--Trong Procedure này có khai báo 1 biến cục bộ được gán giá trị là: 
--số lượng xuất kho của tên sản phẩm này trong khoảng thời gian từ đầu tháng 4/2006 đến hết tháng 6/2006. 
--Việc gán trị này chỉ được thực hiện bằng cách gọi Procedure P2.
CREATE PROCEDURE CAU5_3
@TENSP NVARCHAR(50)
AS
BEGIN
	DECLARE @TONGSL INT
	EXEC CAU5_2 @TENSP, @TONGSL OUT
	PRINT @TONGSL
END
GO

EXEC CAU5_3 'XI MANG'
GO
------------------------------------------------------------------------------------------------------------------------PROC INSERT---------------------

-- CAU 5-4:Procedure P4 để INSERT một record vào trong Table Loai. 
--Giá trị các field là tham số truyền vào.
CREATE PROCEDURE CAU5_4
@MALOAI VARCHAR(5),
@TENLOAI NVARCHAR(30)
AS
	INSERT INTO LOAI VALUES (@MALOAI,@TENLOAI)
GO

EXEC CAU5_4 'L01','DIEN LANH'
GO

-- CAU 5-5:Procedure P5 để DELETE một record trong Table NhânViên theo mã nhân viên. 
--Mã NV là tham số truyền vào.
CREATE PROCEDURE CAU5_5
@MANV VARCHAR(20)
AS
	DELETE FROM NHANVIEN WHERE MANV=@MANV
GO

---------------------------------------------------------------------------------------------------------------------------PROC LONGG FUNC----------------------
-- CAU 5-1: Procedure tên là P1 cho có 2 tham số sau:
--•	1 tham số nhận vào là: tên sản phẩm.
--•	1 tham số trả về cho biết: tổng số lượng xuất kho của tên sản phẩm này trong năm 2006 
--(Không viết lại truy vấn, hãy sử dụng Function F1 ở câu 4 để thực hiện)

CREATE PROCEDURE CAU5_1
@TENSP NVARCHAR(50),
@TONGSL INT OUT
AS
BEGIN
	SELECT @TONGSL=dbo.CAU4_1(@TENSP,2006)
END
GO

DECLARE @TONGSL INT
EXEC CAU5_1 'XI MANG', @TONGSL OUT
PRINT CONVERT(VARCHAR(20),@TONGSL)
GO

-- CAU 5-2:Procedure tên là P2 có 2 tham số sau:
--•	1 tham số nhận vào là: tên sản phẩm.
--•	1 tham số trả về cho biết: tổng số lượng xuất kho của tên sản phẩm này trong khoảng thời gian 
---từ đầu tháng 4/2006 đến hết tháng 6/2006 (Chú ý: Nếu tên sản phẩm này không tồn tại thì trả về 0)

CREATE PROCEDURE CAU5_2
@TENSAP NVARCHAR(50),
@TONGSL INT OUT
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM SANPHAM WHERE TENSP LIKE @TENSAP)
		SET @TONGSL=0
	ELSE
		SELECT @TONGSL=SUM(SOLUONG) 
		FROM SANPHAM SP, PHIEUXUAT PX, CHITIETXUAT CT
		WHERE SP.MASP=CT.MASP AND CT.MAPX=PX.MAPX AND TENSP LIKE @TENSAP AND YEAR(NGAYLAP)=2006 AND (MONTH(NGAYLAP) BETWEEN 4 AND 6)
END
GO

DECLARE @TONGSL INT
EXEC CAU5_2 'XI MANG 1', @TONGSL OUT
PRINT @TONGSL 
GO

-- CAU 5-3:Procedure tên là P3 chỉ có duy nhất 1 tham số nhận vào là tên sản phẩm. 
--Trong Procedure này có khai báo 1 biến cục bộ được gán giá trị là: 
--số lượng xuất kho của tên sản phẩm này trong khoảng thời gian từ đầu tháng 4/2006 đến hết tháng 6/2006. 
--Việc gán trị này chỉ được thực hiện bằng cách gọi Procedure P2.
CREATE PROCEDURE CAU5_3
@TENSP NVARCHAR(50)
AS
BEGIN
	DECLARE @TONGSL INT
	EXEC CAU5_2 @TENSP, @TONGSL OUT
	PRINT @TONGSL
END
GO

EXEC CAU5_3 'XI MANG'
GO
-- CAU 5-4:Procedure P4 để INSERT một record vào trong Table Loai. 
--Giá trị các field là tham số truyền vào.
CREATE PROCEDURE CAU5_4
@MALOAI VARCHAR(5),
@TENLOAI NVARCHAR(30)
AS
	INSERT INTO LOAI VALUES (@MALOAI,@TENLOAI)
GO

EXEC CAU5_4 'L01','DIEN LANH'
GO

-- CAU 5-5:Procedure P5 để DELETE một record trong Table NhânViên theo mã nhân viên. 
--Mã NV là tham số truyền vào.
CREATE PROCEDURE CAU5_5
@MANV VARCHAR(20)
AS
	DELETE FROM NHANVIEN WHERE MANV=@MANV
GO


--TRIGGER----------------------------------------------------------------------------TRIGGER-----------------------------------------------------

--1.	Thực hiện việc kiểm tra các ràng buộc khóa ngoại.
GO
CREATE TRIGGER C61 ON KHACHHANG
FOR DELETE
AS
	DECLARE @MAKH NVARCHAR(5)
	SELECT @MAKH = MAKH FROM DELETED
	IF EXISTS (SELECT * FROM HOADON WHERE MAKH LIKE @MAKH)
	BEGIN
		PRINT('kHONG XOA DUOC')
		ROLLBACK TRANSACTION
	END
GO

--2.	Không cho phép CASCADE DELETE trong các ràng buộc khóa ngoại. Ví dụ không cho phép xóa các HOADON nào có SOHD còn trong table CTHD.
CREATE TRIGGER C62 ON HOADON
FOR DELETE
AS
	IF EXISTS (SELECT D.MAHD FROM CTHD, DELETED D WHERE CTHD.MAHD = D.MAHD)
	PRINT('KHONG XOA DUOC')
	ROLLBACK TRANSACTION

--3.	Không cho phép user nhập vào hai vật tư có cùng tên.
GO
CREATE TRIGGER C63 ON VATTU
FOR INSERT
AS
	IF (SELECT COUNT(*) FROM VATTU A, INSERTED I WHERE A.TENVT = I.TENVT) > 1
BEGIN
	PRINT('kHONG THEM DUOC')
	ROLLBACK TRAN
END
GO

drop trigger c63
INSERT INTO VATTU VALUES('VT31',N'Tôaa',N'Khối',5000,10)
SELECT * FROM VATTU

--4.	Khi user đặt hàng thì KHUYENMAI là 5% nếu SL > 100, 10% nếu SL > 500.
GO
CREATE TRIGGER C64 ON CTHD
FOR UPDATE
AS
BEGIN
	SELECT KHUYENMAI = CASE WHEN SL >= 500 THEN 0.1 WHEN (SL >= 100 AND SL < 500) THEN 0.05 ELSE 0 END
	FROM CTHD
	ROLLBACK TRAN
END
GO


--9.	Không được phép bán hàng lỗ quá 50%.
GO
CREATE TRIGGER C69 ON CTHD
FOR INSERT
AS
	IF (SELECT COUNT(*) FROM VATTU A, INSERTED I WHERE GIABAN < (GIAMUA/2) AND A.MAVT = I.MAVT) >=1
	BEGIN
	RAISERROR ('ERROR !!!!',16,0)
	ROLLBACK TRAN
	END
GO
DROP TRIGGER C69