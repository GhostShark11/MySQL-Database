-- 1. membuat tablespace dan temporary tablespace
CREATE TABLESPACE k03_tabspace
	DATAFILE 'k03_tabspace.dat'
	SIZE 10M autoextend ON;

CREATE TEMPORARY TABLESPACE k03_tabspace_temp
	TEMPFILE 'k03_tabspace_temp.dat'
	SIZE 5M autoextend ON;

-- 2. membuat user investigator
CREATE USER k03_investigator
	IDENTIFIED BY "K03Invest1"
	DEFAULT TABLESPACE k03_tabspace
	TEMPORARY TABLESPACE k03_tabspace_temp;

-- 3. memberi privilege
GRANT CREATE SESSION TO k03_investigator;
GRANT CREATE TABLE TO k03_investigator;
GRANT UNLIMITED TABLESPACE TO k03_investigator;

-- 4. verifikasi tablespace 
--SELECT tablespace_name, contents, status
--	FROM dba_tablespaces
--	WHERE tablespace_name LIKE 'K03%';

-- buat koneksi baru, usn : k03_investigator				//1
-- pass : K03Invest1, connection name : K03_investigator	//2
-- hapus 3 baris ini sebelum dikumpul						//3

-- dijalankan di koneksi K03_investigator
-- SELECT * FROM session_privs;