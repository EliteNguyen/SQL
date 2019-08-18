CREATE DATABASE DIALYVN 
ON (NAME='DIALYVN_DATA', FILENAME='C:\SQL\DIALYVN.MDF')
LOG ON (NAME='DIALYVN_LOG', FILENAME='C:\SQL\DIALYVN.LDF')
USE DIALYVN
--1//BẢNG TỈNH THÀNH PHỐ 
CREATE TABLE TINH_TP
(
	MA_T_TP VARCHAR(3) PRIMARY KEY,
	TEN_T_TP NVARCHAR(20),
	DT FLOAT,
	DS BIGINT,
	MIEN NVARCHAR(10)
)
--2//BẢNG BIÊN GIỚI
CREATE TABLE BIENGIOI
(
	NUOC NVARCHAR(15),
	MA_T_TP VARCHAR(3),
	PRIMARY KEY(NUOC,MA_T_TP),
	FOREIGN KEY (MA_T_TP) REFERENCES TINH_TP(MA_T_TP) ON UPDATE CASCADE
)
--3//BẢNG LÁNG GIỀNG
CREATE TABLE LANGGIENG
(
	MA_T_TP VARCHAR(3),
	LG VARCHAR(3),
	PRIMARY KEY(MA_T_TP,LG),
	FOREIGN KEY (MA_T_TP) REFERENCES TINH_TP(MA_T_TP),
	FOREIGN KEY (LG) REFERENCES TINH_TP(MA_T_TP)
)
--4//THỰC HIỆN CÁC TRUY VẤN 
--1.	Xuất ra tên tỉnh, TP cùng với dân số của tỉnh,TP:
--a) Có diện tích >= 5000 Km2
SELECT TEN_T_TP AS [TÊN TỈNH THÀNH PHỐ], DS AS [DÂN SỐ]
FROM TINH_TP
WHERE DT>=5000

--b) Có diện tích >= [input] (SV nhập một số bất kỳ)
SELECT TEN_T_TP AS [TÊN TỈNH THÀNH PHỐ], DS AS [DÂN SỐ]
FROM TINH_TP
WHERE DT>=20000

--2.	Xuất ra tên tỉnh, TP cùng với diện tích của tỉnh,TP:
--a) Thuộc miền Bắc
SELECT TEN_T_TP AS [TÊN TỈNH THÀNH PHỐ], DT AS [DIỆN TÍCH]
FROM TINH_TP
WHERE MIEN=N'BẮC'

--b) Thuộc miền [input] (SV nhập một miền bất kỳ)
SELECT TEN_T_TP AS [TÊN TỈNH THÀNH PHỐ], DS AS [DÂN SỐ]
FROM TINH_TP
WHERE MIEN=N'NAM'

--3.	Xuất ra các Tên tỉnh, TP biên giới thuộc miền [input] (SV cho một miền bất kỳ)
SELECT TEN_T_TP AS [TÊN TỈNH THÀNH PHỐ]
FROM TINH_TP
WHERE MIEN=N'BẮC'

--4.	Cho biết diện tích trung bình của các tỉnh, TP (Tổng DT/Tổng số tỉnh_TP).
SELECT SUM(DT)/COUNT(*) AS [DIỆN TÍCH TRUNG BÌNH CỦA CÁC TỈNH THÀNH PHỐ]
FROM TINH_TP

--5.	Cho biết dân số cùng với tên tỉnh của các tỉnh, TP có diện tích > 7000 Km2.
SELECT TEN_T_TP, DS, DT
FROM TINH_TP
WHERE DT>7000

--6.	Cho biết dân số cùng với tên tỉnh của các tỉnh miền ‘Bắc’.
SELECT TEN_T_TP, DS, MIEN
FROM TINH_TP
WHERE MIEN=N'Bắc'

--7.	Cho biết mã các nước là biên giới của các tỉnh miền ‘Nam’.
SELECT DISTINCT NUOC
FROM	TINH_TP	T,BIENGIOI B
WHERE T.MA_T_TP=B.MA_T_TP AND MIEN=N'Nam'
 
--8.	Cho biết diện tích trung bình của các tỉnh, TP. (Sử dụng hàm)
SELECT AVG(DT) AS [DIỆN TÍCH TRUNG BÌNH CỦA CÁC TÌNH THÀNH PHỐ]
FROM TINH_TP

--9.	Cho biết mật độ dân số (DS/DT) cùng với tên tỉnh, TP của tất cả các tỉnh, TP.
SELECT TEN_T_TP, DS/DT AS [MẬT ĐỘ DÂN SỐ]
FROM TINH_TP

--10.	Cho biết tên các tỉnh, TP láng giềng của tỉnh ‘Long An’.
SELECT TEN_T_TP
FROM TINH_TP T,LANGGIENG L
WHERE T.MA_T_TP=L.LG AND L.MA_T_TP = (SELECT MA_T_TP 
											FROM TINH_TP
											WHERE TEN_T_TP='Long An')

--11.	Cho biết số lượng các tỉnh, TP giáp với ‘CPC’.
SELECT COUNT(MA_T_TP) AS [SỐ LƯỢNG TỈNH THÀNH PHỐ]
FROM BIENGIOI
WHERE NUOC='CPC'

--12.	Cho biết tên những tỉnh, TP có diện tích lớn nhất.
SELECT TOP 1 WITH TIES DT, TEN_T_TP
FROM TINH_TP
ORDER BY DT DESC


--13.	Cho biết tỉnh, TP có mật độ DS đông nhất.
SELECT  TOP 1 WITH TIES MA_T_TP, TEN_T_TP, DS/DT AS [MẬT ĐỘ DÂN SỐ]
FROM TINH_TP
ORDER BY [MẬT ĐỘ DÂN SỐ] DESC

--14.	Cho biết tên những tỉnh, TP giáp với hai nước biên giới khác nhau.
SELECT TEN_T_TP
FROM TINH_TP, BIENGIOI
WHERE TINH_TP.MA_T_TP=BIENGIOI.MA_T_TP
GROUP BY TEN_T_TP

HAVING COUNT(NUOC)>=2

--15.	Cho biết danh sách các miền cùng với các tỉnh, TP trong các miền đó.
SELECT MIEN, MA_T_TP, TEN_T_TP
FROM TINH_TP
ORDER BY MIEN

--16.	Cho biết tên những tỉnh, TP có nhiều láng giềng nhất.
SELECT TOP 1 WITH TIES T.MA_T_TP, TEN_T_TP, COUNT(*) AS [SỐ LÁNG GIỀNG]
FROM TINH_TP T, LANGGIENG L
WHERE T.MA_T_TP=L.MA_T_TP 
GROUP BY T.MA_T_TP, TEN_T_TP
ORDER BY [SỐ LÁNG GIỀNG] DESC
--17.	Cho biết những tỉnh, TP có diện tích nhỏ hơn diện tích trung bình của tất cả tỉnh, TP.
SELECT MA_T_TP, TEN_T_TP, DT
FROM TINH_TP
WHERE DT < (SELECT AVG(DT)
			FROM TINH_TP)

--18.	Cho biết tên những tỉnh, TP giáp với các tỉnh, TP ở miền ‘Nam’ và không phải là miền ‘Nam’.
SELECT T.MA_T_TP, TEN_T_TP
FROM TINH_TP T, LANGGIENG L
WHERE T.MA_T_TP=L.MA_T_TP AND MIEN<>'Nam' AND L.LG IN (SELECT MA_T_TP

													  FROM TINH_TP
													  WHERE	MIEN='Nam')

--19.	Cho biết tên những tỉnh, TP có diện tích lớn hơn tất cả các tỉnh, TP láng giềng của nó.
SELECT T.MA_T_TP, TEN_T_TP
FROM TINH_TP T
WHERE T.DT > ALL (SELECT T.DT
				  FROM TINH_TP T, LANGGIENG L
				  WHERE T.MA_T_TP=L.MA_T_TP )

--20.	Cho biết tên những tỉnh, TP mà ta có thể đến bằng cách đi từ ‘TP.HCM’ xuyên qua ba tỉnh khác nhau và cũng khác với điểm xuất phát, nhưng láng giềng với nhau.
select distinct 'HCM',L1.LG,L2.LG,L3.LG
from TINH_TP T, LANGGIENG L1, LANGGIENG L2, LANGGIENG L3
where T.MA_T_TP=L1.MA_T_TP and L1.LG=L2.MA_T_TP and L2.LG=L3.MA_T_TP
	and T.MA_T_TP='HCM'
	and L2.LG<>'HCM' and L3.LG<>'HCM' and L1.LG<>L3.LG