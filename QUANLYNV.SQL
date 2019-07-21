CREATE DATABASE QLNV
	ON (NAME='QLNV_DATA', FILENAME='C:\SQL\QLNV.MDF')
	LOG ON (NAME='QLNV_LOG', FILENAME='C:\SQL\QLNV.LDF')
USE QLNV
--1// BẢNG VỊ TRÍ
CREATE TABLE VITRI
(
	MaVT CHAR(4) PRIMARY KEY,
	Mota	nvarchar(30)
)
--2//BẢNG PHÒNG BAN
CREATE TABLE PHONGBAN
(
	MaPB char(4) PRIMARY KEY,
	TenPB NVARCHAR(10),
	DiaChi NVARCHAR(40),
	NgayTL DATE,
	MaNV CHAR(4)
)
SET DATEFORMAT DMY
--3// BẢNG NHÂN VIÊN 
CREATE TABLE NHANVIEN
(
	MaNV CHAR(4) PRIMARY KEY,
	TenNV NVARCHAR(30),
	Phai BIT,
	MaVT CHAR(4),
	FOREIGN KEY (MaVT) REFERENCES VITRI(MaVT),
	MaPB CHAR(4),
    FOREIGN KEY (MaPB) REFERENCES PHONGBAN(MaPB),
	Luong BIGINT,
	NgayVL DATE
)
--4//THỰC HIỆN CÁC TRUY VẤN
--a. In ra danh sách các nhân viên (MaNV, TenNV, Phai: Ghi rõ Nam/Nữ) của phòng ’Tài Vụ’ và sắp xếp thứ tự tăng dần theo họ tên.
SELECT n.MaNV, TenNV, (CASE WHEN Phai=0 THEN N'Nữ' ELSE 'Nam' END) AS Phai
FROM NHANVIEN N, PHONGBAN P
WHERE N.MaPB=P.MAPB AND TenPB=N'Tài Vụ'
ORDER BY TenNV ASC

--b. In ra số lượng nhân viên của mỗi phòng ban (TenPB, Số lượng NV) và sắp xếp theo thứ tự tăng dần.
SELECT TenPB, COUNT(*) AS [SỐ LƯỢNG NV]
FROM NHANVIEN N, PHONGBAN P
WHERE N.MaPB=P.MaPB
GROUP BY TenPB
ORDER BY [SỐ LƯỢNG NV] ASC

--c. In ra tên của Trưởng phòng (TenNV, Phai) có lương cao nhất.
SELECT TOP 1 WITH TIES TenNV,(CASE WHEN Phai=0 THEN N'Nữ' ELSE 'Nam' END) AS Phai, Luong
FROM NHANVIEN N, VITRI V
WHERE N.MaVT=V.MaVT AND Mota=N'Trưởng phòng'
GROUP BY TenNV,Phai, Luong
ORDER BY Luong DESC

--d. In ra danh sách nhân viên (TenNV) có vị trí là chuyên viên và có lương cao nhất.
SELECT TOP 7 WITH TIES TenNV, (CASE WHEN Phai=0 THEN N'Nữ' ELSE 'Nam' END) AS Phai, Luong
FROM NHANVIEN N, VITRI V
WHERE N.MaVT=V.MaVT AND Mota=N'chuyên viên'
GROUP BY TenNV , Phai, Luong
ORDER BY Luong DESC

--e. In ra danh sách nhân viên (MaPNV, TenNV) có thâm niên làm việc tính đến năm 2010 nhỏ hơn 5 năm và sắp xếp theo thứ tự tăng dần.
SELECT MaNV, TenNV, CONVERT(VARCHAR(10), NgayVL, 103) AS [NGÀY VÀO LÀM]
FROM NHANVIEN
WHERE 2010-YEAR(NGAYVL) < 5
ORDER BY NgayVL ASC

--f. Tìm tên phòng ban (TenPB) có 5 nhân viên có lương từ 5.000.000  trở lên.
SELECT TOP 5 WITH TIES TenPB, TenNV, (CASE WHEN Phai=0 THEN N'Nữ' ELSE 'Nam' END) AS Phai, Luong
FROM PHONGBAN P, NHANVIEN N
WHERE P.MaPB=N.MaPB AND Luong > 5000000
GROUP BY TenPB, TenNV, Phai, Luong
ORDER BY LUONG DESC

--g. Đếm số lượng nhân viên của từng phòng ban. Hiển thị: Tên_PB, Số_người.
SELECT TenPB, COUNT(*) AS [SO LUONG NHAN VIEN]
FROM NHANVIEN N , PHONGBAN P 
WHERE N.MaPB=P.MaPB 
GROUP BY TenPB

--h. In ra tên phòng ban có từ 4 nhân viên trở lên.
SELECT TenPB, COUNT(*) [SO LUONG NV]
FROM NHANVIEN N, PHONGBAN P
WHERE N.MaPB=P.MaPB 
GROUP BY TenPB
HAVING COUNT(*) > 4

--i. Hãy tính tổng tiền lương của từng phòng ban.
SELECT P.MaPB, TenPB, SUM(Luong) as [TIEN LUONG]
FROM PHONGBAN P , NHANVIEN N
WHERE P.MaPB=N.MaPB 
GROUP BY P.MaPB, TenPB

--j. In ra thông tin của nhân viên cùng số năm công tác (tính đến thời điểm hiện tại). Hiển thị: Mã NV, Tên NV, Số năm công tác.
SELECT MaNV, TenNV, YEAR(GETDATE())-YEAR(NgayVL) as [SO NAM CONG TAC]
FROM NHANVIEN

--k. In ra tên phòng ban cùng tên của trưởng phòng.
SELECT TenPB, TenNV
FROM PHONGBAN P, NHANVIEN N, VITRI V
WHERE P.MaPB=N.MaPB AND N.MaVT=V.MaVT AND Mota=N'Trưởng phòng'

--l. In ra tên các nhân viên không là trưởng của các phòng ban.
SELECT TenNV, Mota
FROM NHANVIEN N, PHONGBAN P, VITRI V
WHERE P.MaPB=N.MaPB AND N.MaVT=V.MaVT AND V.MaVT NOT IN (SELECT V.MaVT
													     FROM NHANVIEN N , VITRI V
														 WHERE N.MaVT=V.MaVT AND Mota=N'Trưởng phòng')

--m. Thêm mới 1 NV bằng lệnh INSERT INTO:
--(‘NV016‘, ‘Đặng Nguyễn Ngân Vinh‘, 1, ‘VT04‘, ‘P005‘, 12000000, ‘20/10/2017‘)
INSERT INTO NHANVIEN(MaNV, TenNV, Phai, MaVT, MaPB, Luong, NgayVL) VALUES ('N017', N'Đặng Nguyễn Ngân Vinh',1, 'VT03', 'P004', 12000000, '20/10/2007')
-- KHI NHẬP THÔNG TIN MỚI Ở BẢNG NHÂN VIÊN ,
-- ĐẾN PHẦN MAVT NÓ SẼ CHIẾU ĐẾN BẢNG CHA LÀ VITRI NẾU MÃ VỊ TRÍ MÀ MÌNH NHẬP KHÔNG TRÙNG VỚI MAVT CỦA BẢNG CHA THÌ MAY SẼ KHÔNG CHO NHẬP VÀ BÁO LỖI ,
--ĐẾN PHẦN MAPB NÓ SẼ CHIẾU ĐẾN BẢNG CHA LÀ PHONGBAN VÀ CŨNG TƯƠNG TỰ NHƯ MÃ VỊ TRÍ , 
--BỎ KÍ TỰ "V" TRONG MÃ NHÂN VIÊN VÌ KHÓA CỦA MÌNH CHỈ CÓ 4 KÍ TỰ , PHẢI SỬA 16 THÀNH 17 VÌ TRÙNG MÃ NHÂN VIÊN ,
--MÁY SẼ KHÔNG CHO NHẬP.
--Nhận xét?
--n. Thêm mới 1 phòng ban sau: (‘P005‘, ‘Thanh tra-Pháp chế‘, ‘91 Nguyễn Chí Thanh‘, ‘10/10/2012‘, ‘N015‘). Nhận xét?

INSERT INTO PHONGBAN(MAPB, TenPB, DiaChi, NgayTL, MaNV) VALUES ('P005', N'TT-PC', N'91 Nguyễn Chí Thanh', '10/10/2012', 'N014')
