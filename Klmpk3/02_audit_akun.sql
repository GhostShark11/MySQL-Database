-- 1. buat 3 user dan beri privilege
	-- admin_data : perannya sama seperti investigator
	CREATE USER k03_admin_data
		IDENTIFIED BY "K03Admin1"
		DEFAULT TABLESPACE k03_tabspace
		TEMPORARY TABLESPACE k03_tabspace_temp;
	GRANT CREATE SESSION TO k03_admin_data;
	GRANT CREATE TABLE TO k03_admin_data;
	GRANT UNLIMITED TABLESPACE TO k03_admin_data;

	-- tamu : hanya boleh login
	CREATE USER k03_tamu
		IDENTIFIED BY "K03Tamu1"
		DEFAULT TABLESPACE k03_tabspace
		TEMPORARY TABLESPACE k03_tabspace_temp;
	GRANT CREATE SESSION TO k03_tamu;

	--analis : kelebihan privilege
	CREATE USER k03_analis
		IDENTIFIED BY "K03Analis1"
		DEFAULT TABLESPACE k03_tabspace
		TEMPORARY TABLESPACE k03_tabspace_temp;
	GRANT CREATE SESSION TO k03_analis;
	GRANT CREATE TABLE TO k03_analis;
	GRANT UNLIMITED TABLESPACE TO k03_analis;
	
-- 2. audit 3 user yang telah diberi privilege
SELECT username, account_status, default_tablespace,
	temporary_tablespace, created 
	FROM dba_users WHERE username LIKE 'K03%'
	ORDER BY username;

-- buat 3 koneksi baru													//1
-- usn : k03_admin_data, pass : K03Admin1, conn.name : K03_admin_data	//2 
-- usn : k03_tamu, pass : K03Tamu1, conn.name : K03_tamu				//3 
-- usn : k03_analis, pass : K03Analis1, conn.name : K03_analis			//4 
-- hapus 5 baris ini sebelum dikumpul									//5

-- jalankan query di bawah pada koneksi admin_data, tamu dan analis
-- SELECT * FROM session_privs;

-- 3. Perbaikan akun analis
-- disconnect dulu K03_analis sebelum drop (hapus baris ni sebelum kumpul)
DROP USER k03_analis;

CREATE USER k03_analis
	IDENTIFIED BY "K03Analis1"
	DEFAULT TABLESPACE k03_tabspace
	TEMPORARY TABLESPACE k03_tabspace_temp;
GRANT CREATE SESSION TO k03_analis;
-- connect lagi K03_analis (hapus baris ni sebelum kumpul)

