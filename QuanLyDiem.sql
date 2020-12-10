
CREATE DATABASE QuanLyDiem
GO
USE QuanLyDiem
GO
-- Cho cơ sở dữ liệu QuanLyDiem gồm các bảng dữ liệu sau:
--SinhVien gồm các thuộc tính: masv varchar(5), holot nvarchar(30), ten nvarchar(10),
-- gioitinh bit, ngaysinh datetime.
-- Trong đó: masv là khóa chính.

-- - MonHoc gồm các thuộc tính: mamh varchar(5), tenmh nvarchar(30), sotiet int
-- Trong đó: mamh là khóa chính; sotiet  > 0.

-- - DiemThi gồm các thuộc tính: masv varchar(5), mamh varchar(5), diemlan1 float, diemlan2 float.
-- Trong đó: + masv, mamh là khóa chính
-- + masv, mamh là hai khóa ngoại được tham chiếu từ hai bảng tương ứng sinhvien và monhoc.
-- + 0 <= diemlan1, diemlan2 <=10
-- Yêu cầu:
---------------------------------------------------------------------
-- 1. Sử dụng Create table để tạo cấu trúc cho 3 bảng dữ liệu trên.
------------------ Bảng Sinh Viên -----------------------------------
CREATE TABLE SinhVien
(
    MaSV VARCHAR(5) PRIMARY KEY,
    HoLot NVARCHAR(30),
    Ten NVARCHAR(10),
    GioiTinh BIT,
    NgaySinh DATETIME2
)
-------------------Bảng Môn Học --------------------------------------
GO
CREATE TABLE MonHoc 
(
    MaMH VARCHAR(5) PRIMARY KEY,
    TenMH NVARCHAR(30),
    SoTiet INT CHECK(SoTiet > 0)
)

------------------- Bảng Điểm Thi ------------------------------------
GO
CREATE TABLE DiemThi 
(
    MaSV VARCHAR(5) REFERENCES SinhVien(MaSV),
    MaMH VARCHAR(5) REFERENCES MonHoc(MaMH),
    DiemLan1 FLOAT CHECK (DiemLan1 >= 0 and DiemLan1 <= 10),
    DiemLan2 FLOAT CHECK (DiemLan2 >= 0 and DiemLan2 <= 10)
    CONSTRAINT PK_MaSV_MaMH_DiemThi PRIMARY KEY (MaSV, MaMH)
)

----------------------------------------------------------------------------------------------
-- 2. Tạo 3 thủ tục tương ứng để thêm, sửa, xóa dữ liệu cho bảng dữ liệu SinhVien, mỗi thủ tục
-- phải có tham số tương ứng với các thuộc tính của bảng.
----------------------------------------------------------------------------------------------

-------------------  Thủ tục thêm sinh viên -----------------------------------------------
GO
CREATE PROC sp_insert_sinhvien 
(
    @maSV VARCHAR(5),
    @hoLot NVARCHAR(30),
    @ten NVARCHAR(10),
    @gioiTinh BIT,
    @ngaySinh DATETIME2
)
AS
INSERT INTO SinhVien VALUES(@maSV, @hoLot, @ten, @gioiTinh, @ngaySinh)
-- Test 
GO 
EXEC sp_insert_sinhvien 'SV001','Enrdigo', 'Alasteir', 1, '2000-06-12'

SELECT * FROM SinhVien

----------------Thủ tục sửa sinh viên -------------------------------------------
GO
CREATE PROC sp_update_sinhvien 
(
    @maSV VARCHAR(5),
    @hoLot NVARCHAR(30),
    @ten NVARCHAR(10),
    @gioiTinh BIT,
    @ngaySinh DATETIME2
)
AS
UPDATE SinhVien 
SET HoLot = @hoLot,TEn = @ten, GioiTinh = @gioiTinh, NgaySinh = @ngaySinh
WHERE MaSV =  @maSV

-- Test 
GO 

EXEC sp_update_sinhvien 'SV001', 'Curnucke', 'Tarra', 0, '2001-03-22'
GO
SELECT * FROM SinhVien

----------------- Thủ tục xóa sinh viên -------------------------
GO
CREATE PROC sp_delete_sinhvien (@maSV VARCHAR(5))
AS 
DELETE FROM SinhVien WHERE MaSV = @maSV
-- Test
GO
sp_delete_sinhvien 'SV001'
SELECT * FROM SinhVien
----------------------------------------------------------------
-- 3. Tạo Function để đánh mã tự động cho bảng SinhVien.
-----------------------------------------------------------------
GO
CREATE FUNCTION fc_auto_masv()
RETURNS VARCHAR(5)
AS 
BEGIN 
    DECLARE @maSV VARCHAR(5)
    SELECT @maSV = RIGHT(ISNULL(MAX(MaSV), 0), 3) + 1 FROM SinhVien
    SET @maSV = 'SV' + REPLICATE('0', 3 - LEN(@maSV)) + @maSV
    return @maSV
END
-- test 
GO

-- Thêm dữ liệu bảng Sinh Viên
INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Hryncewicz', 'Arlie', 0, '2001-09-10')
SELECT * FROM SinhVien

INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Bautiste', 'Brandyn', 0, '2001-03-12')
INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Tills', 'Harmony', 1, '2001-07-22')
INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Nussii', 'Antin', 1, '2001-08-12')
INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Ellicombe', 'Westleigh', 0, '2001-01-14')
INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Stentiford', 'Ethe', 0, '2001-01-02')
INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Timbs', 'Jerrine', 1, '2001-08-23')
INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Vogeler', 'Linn', 1, '2001-04-14')
INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Humm', 'Alberik', 1, '2001-06-12')
INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Dilston', 'Davidson', 0, '2001-01-17')
INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Savine', 'Melva', 1, '2001-01-10')
INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Trever', 'Jakie', 1, '2001-03-19')
INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Hawtrey', 'Homer', 1, '2001-08-11')
INSERT INTO SinhVien VALUES (dbo.fc_auto_masv(), 'Dearan', 'Austen', 1, '2001-01-12')

-- Thêm dữ liệu bảng Monhoc
INSERT INTO MonHoc VALUES ('MH001', N'Cấu trúc dữ liệu', 24)
INSERT INTO MonHoc VALUES ('MH002', N'Cơ sở dữ liệu', 12)
INSERT INTO MonHoc VALUES ('MH003', N'Đồ họa ứng dụng', 16)
INSERT INTO MonHoc VALUES ('MH004', N'Lập trình dotNet', 20)
INSERT INTO MonHoc VALUES ('MH005', N'Lập trình Java', 28)
INSERT INTO MonHoc VALUES ('MH006', N'Lập trình Nodejs', 32)
INSERT INTO MonHoc VALUES ('MH007', N'Mạng máy tính', 16)
INSERT INTO MonHoc VALUES ('MH008', N'Thiết kế UI, UX', 12)
INSERT INTO MonHoc VALUES ('MH009', N'Tin học văn phòng', 16)
INSERT INTO MonHoc VALUES ('MH010', N'Luật an ninh mạng', 20)

-- Thêm dữ liệu bảng DiemThi
INSERT INTO DiemThi VALUES ('SV001', 'MH001', 8, 3)
INSERT INTO DiemThi VALUES ('SV001', 'MH002', 2, 9)
INSERT INTO DiemThi VALUES ('SV001', 'MH003', 3, 8)
INSERT INTO DiemThi VALUES ('SV001', 'MH006', 6, 5)
INSERT INTO DiemThi VALUES ('SV001', 'MH008', 8, 3)

INSERT INTO DiemThi VALUES ('SV002', 'MH010', 10, 1)
INSERT INTO DiemThi VALUES ('SV002', 'MH001', 8, 3)
INSERT INTO DiemThi VALUES ('SV002', 'MH002', 2, 9)
INSERT INTO DiemThi VALUES ('SV002', 'MH003', 3, 8)
INSERT INTO DiemThi VALUES ('SV002', 'MH004', 4, 7)
INSERT INTO DiemThi VALUES ('SV002', 'MH007', 7, 4)
INSERT INTO DiemThi VALUES ('SV002', 'MH008', 8, 3)

INSERT INTO DiemThi VALUES ('SV003', 'MH001', 1, 10)
INSERT INTO DiemThi VALUES ('SV003', 'MH002', 2, 9)
INSERT INTO DiemThi VALUES ('SV003', 'MH004', 4, 7)
INSERT INTO DiemThi VALUES ('SV003', 'MH005', 8, 3)
INSERT INTO DiemThi VALUES ('SV003', 'MH008', 8, 3)
INSERT INTO DiemThi VALUES ('SV003', 'MH009', 9, 2)
INSERT INTO DiemThi VALUES ('SV003', 'MH010', 10, 1)

INSERT INTO DiemThi VALUES ('SV004', 'MH001', 1, 10)
INSERT INTO DiemThi VALUES ('SV004', 'MH002', 2, 9)
INSERT INTO DiemThi VALUES ('SV004', 'MH003', 3, 8)
INSERT INTO DiemThi VALUES ('SV004', 'MH005', 5, 6)
INSERT INTO DiemThi VALUES ('SV004', 'MH006', 6, 5)
INSERT INTO DiemThi VALUES ('SV004', 'MH008', 8, 3)
INSERT INTO DiemThi VALUES ('SV004', 'MH010', 8, 3)


INSERT INTO DiemThi VALUES ('SV005', 'MH001', 1, 10)
INSERT INTO DiemThi VALUES ('SV005', 'MH002', 2, 9)
INSERT INTO DiemThi VALUES ('SV005', 'MH003', 3, 8)
INSERT INTO DiemThi VALUES ('SV005', 'MH005', 5, 6)
INSERT INTO DiemThi VALUES ('SV005', 'MH007', 7, 4)
INSERT INTO DiemThi VALUES ('SV005', 'MH008', 8, 3)
INSERT INTO DiemThi VALUES ('SV005', 'MH009', 8, 3)


--------------------------------------------------------------------------------------------------
-- 4. Tạo trigger kiểm tra tính hợp lệ về việc nhập điểm lần 2 cho các sinh viên. Tính hợp lệ được
-- quy ước: Nếu điểm lần 1 < 5 mới cho phép nhập điểm lần 2.
--------------------------------------------------------------------------------------------------
GO
CREATE TRIGGER tg_check_enter_diemlan2
ON DiemThi FOR INSERT
AS
BEGIN
    DECLARE @diemLan1 FLOAT
    DECLARE @diemLan2 FLOAT
    SELECT @diemLan1 = DiemLan1 FROM INSERTED
    SELECT @diemLan2 = DiemLan2 FROM INSERTED
    IF @diemLan1 > 5
        IF @diemLan2 IS NOT NULL
            ROLLBACK TRANSACTION
END


-- 5. Sử dụng câu lệnh Select để hiển thị danh sách sinh viên thi môn Cấu trúc dữ liệu có điểm
-- lần 1 nhỏ hơn 4.
SELECT sv.MaSV, sv.HoLot, sv.Ten, mh.TenMH, dt.DiemLan1 FROM SinhVien sv, MonHoc mh, DiemThi dt 
WHERE sv.MaSV = dt.MaSV AND mh.MaMH = dt.MaMH 
    AND mh.TenMH = N'Cấu trúc dữ liệu' AND dt.DiemLan1 < 4

-- 6. Sử dụng câu lệnh Select để hiển thị danh sách các sinh viên thi môn Cơ sở dữ liệu mà có
-- điểm thi lần 1 >=5.
SELECT sv.MaSV, sv.HoLot, sv.Ten, mh.TenMH, dt.DiemLan1 FROM SinhVien sv, MonHoc mh, DiemThi dt
WHERE sv.MaSV = dt.MaSV AND mh.MaMH = dt.MaMH 
    AND mh.TenMH = N'Cơ sở dữ liệu' AND dt.DiemLan1 >= 5



-- 7. Sử dụng câu lệnh Select để hiển thị danh sách kết quả học tập của sinh viên gồm : Họ và tên,
-- Tên môn học, điểm thi cao nhất trong hai lần thi

SELECT sv.HoLot, sv.Ten, mh.TenMH, dcn.DiemCaoNhat FROM SinhVien sv, MonHoc mh, 
(SELECT dt.DiemLan1 AS DiemCaoNhat, dt.MaMH, dt.MaSV FROM DiemThi dt WHERE dt.DiemLan1 > dt.DiemLan2) dcn
WHERE sv.MaSV = dcn.MaSV and dcn.MaMH = mh.MaMH
UNION
SELECT sv.HoLot, sv.Ten, mh.TenMH, dcn.DiemCaoNhat FROM SinhVien sv, MonHoc mh, 
(SELECT dt.DiemLan2 AS DiemCaoNhat, dt.MaMH, dt.MaSV FROM DiemThi dt WHERE dt.DiemLan2 >= dt.DiemLan1) dcn
WHERE sv.MaSV = dcn.MaSV and dcn.MaMH = mh.MaMH

--------------------------------------------------------------------------------------------------------------
-- 8. Thống kê sinh viên có điểm thi lần 1 >=5, bao gồm các thông tin : Họ tên, Tên môn học, Tổng số sinh viên
-------------------------------------------------------------------------------------------------------------- 
SELECT mh.TenMH, TongSoSV = COUNT(sv.MaSV) FROM SinhVien sv, MonHoc mh, DiemThi dt 
WHERE sv.MaSV = dt.MaSV and mh.MaMH = dt.MaMH
    AND dt.DiemLan1 >= 5
GROUP BY mh.TenMH
