USE QuanLyDiem
-- Cho cơ sở dữ liệu QuanLyDiem gồm các bảng dữ liệu sau:
--SinhVien gồm các thuộc tính: masv varchar(5), holot nvarchar(30), ten nvarchar(10),
-- gioitinh bit, ngaysinh datetime.
-- Trong đó: masv là khóa chính.

-- - MonHoc gồm các thuộc tính: mamh varchar(5), tenmh nvarchar(30), sotiet int
-- Trong đó: mamh là khóa chính; sotiet  > 0.

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
EXEC sp_insert_sinhvien 'SV001', N'Trần', 'Minh', 1, '2020-12-12'

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
EXEC sp_update_sinhvien 'SV001', N'Nguyễn', N'Thanh', 0, '2020-10-12'

----------------- Thủ tục xóa sinh viên -------------------------
GO
CREATE PROC sp_delete_sinhvien (@maSV VARCHAR(5))
AS 
DELETE FROM SinhVien WHERE MaSV = @maSV
-- Test
GO
sp_delete_sinhvien 'SV001'

----------------------------------------------------------------
-- 3. Tạo Function để đánh mã tự động cho bảng SinhVien.
-----------------------------------------------------------------
GO
CREATE FUNCTION fc_auto_masv()
RETURNS VARCHAR(5)
AS 
BEGIN 
    DECLARE @maSV VARCHAR(5)
    SELECT @maSV = RIGHT(ISNULL(MAX(MaSV), 1), 3) + 1 FROM SinhVien
    SET @maSV = 'SV' + REPLICATE('0', 3 - LEN(@maSV)) + @maSV
    return @maSV
END
-- test 
GO
INSERT INTO SinhVien VALUES(dbo.fc_auto_masv(), N'Lê', N'Hải', 1, '2001-12-12')

--------------------------------------------------------------------------------------------------
-- 4. Tạo trigger kiểm tra tính hợp lệ về việc nhập điểm lần 2 cho các sinh viên. Tính hợp lệ được
-- quy ước: Nếu điểm lần 1 < 5 mới cho phép nhập điểm lần 2.
--------------------------------------------------------------------------------------------------








-- 5. Sử dụng câu lệnh Select để hiển thị danh sách sinh viên thi môn Cấu trúc dữ liệu có điểm
-- lần 1 nhỏ hơn 4.
SELECT sv.MaSV, sv.Ten, mh.TenMH from SinhVien sv, MonHoc mh, DiemThi dt 
WHERE sv.MaSV = dt.MaSV and mh.MaMH = dt.MaMH


-- 6. Sử dụng câu lệnh Select để hiển thị danh sách các sinh viên thi môn Cơ sở dữ liệu mà có
-- điểm thi lần 1 >=5.



-- 7. Sử dụng câu lệnh Select để hiển thị danh sách kết quả học tập của sinh viên gồm : Họ và tên,
-- Tên môn học, điểm thi cao nhất trong hai lần thi.
SELECT sv.HoLot, sv.Ten, mh.TenMH,dt.DiemCaoNhat FROM SinhVien sv, MonHoc mh, (SELECT DiemLan2 AS DiemCaoNhat, MaMH, MaSV FROM DiemThi WHERE DiemLan2 > DiemLan1) dt
WHERE sv.MaSV = dt.MaSV and dt.MaMH = mh.MaMH AND sv.MaSV = 'SV003'
UNION ALL
SELECT sv.HoLot, sv.Ten, mh.TenMH,dt.DiemCaoNhat FROM SinhVien sv, MonHoc mh, (SELECT DiemLan1 AS DiemCaoNhat, MaMH, MaSV FROM DiemThi WHERE DiemLan1 >= DiemLan2) dt
WHERE sv.MaSV = dt.MaSV and dt.MaMH = mh.MaMH AND sv.MaSV = 'SV003'

SELECT *  FROM DiemThi WHERE MaSV = 'SV003'




--------------------------------------------------------------------------------------------------------------
-- 8. Thống kê sinh viên có điểm thi lần 1 >=5, bao gồm các thông tin : Họ tên, Tên môn học, Tổng số sinh viên
-------------------------------------------------------------------------------------------------------------- 
SELECT mh.TenMH, TongSoSV = COUNT(sv.MaSV) FROM SinhVien sv, MonHoc mh, DiemThi dt 
WHERE sv.MaSV = dt.MaSV and mh.MaMH = dt.MaMH
    AND dt.DiemLan1 >= 5
GROUP BY mh.TenMH

GO
SELECT * FROM DiemThi