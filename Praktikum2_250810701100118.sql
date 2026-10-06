-- =====================================================================
-- TUGAS PRAKTIKUM 2 - AUDIT KILAT PERUSAHAAN HR CORP
-- Oracle Database XE 21c | DBeaver | Skema HR
-- Nama : Zaw Thein Htet
-- NPM  : 250810701100118
-- employee_id = 1000 + 118 = 1118 | email = ZTH250810701100118
-- =====================================================================
-- BAGIAN 1: Menghubungkan Diri ke Perusahaan
-- Koneksi dibuat lewat UI DBeaver:
--   Nama koneksi : HR_Konsultan_250810701100118
--   Host         : localhost
--   Port         : 1521
--   Service name : XEPDB1
--   User         : hr
-- Query berikut hanya untuk memastikan koneksi aktif sebagai user HR.
SELECT SYS_CONTEXT('USERENV', 'SESSION_USER') AS pengguna_aktif,
       SYS_CONTEXT('USERENV', 'CON_NAME')     AS nama_database
FROM dual;
SELECT COUNT(*) AS jumlah_karyawan FROM employees;

-- =====================================================================
-- BAGIAN 2: Simulasi Bonus Akhir Tahun (Operator)
-- Departemen terpilih: Finance (department_id = 100)
-- Alasan: Finance punya 6 karyawan, cukup banyak untuk dibandingkan
-- tetapi masih muat dalam satu layar, dan gajinya bervariasi sehingga
-- hasil simulasi bonus mudah dibaca. (Tulis ulang dengan kata-katamu.)
-- =====================================================================
SELECT last_name                      AS nama_belakang,
       salary                         AS gaji_per_bulan,
       salary * 12                    AS gaji_per_tahun,
       salary * 12 * 0.15             AS besar_bonus_15_persen,
       salary * 12 + salary * 12 * 0.15 AS total_gaji_setahun_plus_bonus
FROM employees
WHERE department_id = 100
ORDER BY total_gaji_setahun_plus_bonus DESC;

-- =====================================================================
-- BAGIAN 3: Laporan Rapi untuk Direksi (Fungsi)
-- BAGIAN 3.1: Gaji per hari (ROUND), departemen Finance (ID 100)
SELECT last_name                     AS nama_belakang,
       ROUND(salary * 12 / 365, 2)   AS gaji_per_hari
FROM employees
WHERE department_id = 100
ORDER BY last_name;

-- BAGIAN 3.2: Format nama yang seragam (UPPER, INITCAP, LOWER)
SELECT UPPER(last_name)   AS nama_belakang,
       INITCAP(first_name) AS nama_depan,
       LOWER(email)       AS email
FROM employees
ORDER BY email;

-- BAGIAN 3.3 (a): Lama bekerja dalam tahun (EXTRACT)
SELECT last_name AS nama_belakang,
       EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM hire_date) AS lama_bekerja_tahun
FROM employees
ORDER BY lama_bekerja_tahun DESC, last_name;

-- BAGIAN 3.3 (b): Tanggal masuk berbentuk kalimat, contoh: 1 JANUARI 2005 (TO_CHAR)
SELECT last_name AS nama_belakang,
       TO_CHAR(hire_date, 'FMDD MONTH YYYY', 'NLS_DATE_LANGUAGE=INDONESIAN') AS tanggal_masuk
FROM employees
ORDER BY hire_date;
-- Cadangan jika muncul error ORA-12702 (bahasa INDONESIAN tidak tersedia).
-- Hapus tanda komentar pada query di bawah, dan beri komentar pada query di atas:
-- SELECT last_name AS nama_belakang,
--        TO_CHAR(hire_date, 'FMDD') || ' ' ||
--        DECODE(TO_CHAR(hire_date, 'MM'),
--               '01','JANUARI','02','FEBRUARI','03','MARET','04','APRIL',
--               '05','MEI','06','JUNI','07','JULI','08','AGUSTUS',
--               '09','SEPTEMBER','10','OKTOBER','11','NOVEMBER','12','DESEMBER') || ' ' ||
--        TO_CHAR(hire_date, 'YYYY') AS tanggal_masuk
-- FROM employees
-- ORDER BY hire_date;

-- BAGIAN 3.4: Simulasi ganti kode pos (TO_NUMBER), country_id = 'US'
SELECT city                         AS kota,
       postal_code                  AS kode_pos_lama,
       TO_NUMBER(postal_code) + 1   AS kode_pos_baru
FROM locations
WHERE country_id = 'US'
ORDER BY city;

-- BAGIAN 3.5: Total gaji setahun per departemen (SUM, GROUP BY, HAVING)
-- Batas: Rp 500.000 per tahun. Alasan: departemen dengan total gaji di atas
-- setengah juta per tahun dianggap pos biaya besar yang perlu diawasi direksi.
-- (Tulis ulang alasan dengan kata-katamu.)
SELECT department_id       AS id_departemen,
       SUM(salary) * 12    AS total_gaji_setahun
FROM employees
GROUP BY department_id
HAVING SUM(salary) * 12 > 500000
ORDER BY total_gaji_setahun DESC;

-- =====================================================================
-- BAGIAN 4: Menyambut Karyawan Baru (DML)
-- employee_id = 1000 + tiga digit terakhir NIM (contoh: 1118)
-- Aturan: DELETE hanya memakai WHERE employee_id = ... milikmu sendiri.
-- BAGIAN 4.0: Kondisi awal (sebelum INSERT) - harus 0 baris
SELECT * FROM employees WHERE employee_id = 1118;

-- BAGIAN 4.1: INSERT (salary dikosongkan)
INSERT INTO employees (employee_id, last_name, email, hire_date, job_id)
VALUES (1118, 'HTET', 'ZTH250810701100118', DATE '2026-10-07', 'IT_PROG');
COMMIT;
-- Bukti sesudah INSERT
SELECT employee_id, last_name, email, hire_date, job_id, salary
FROM employees WHERE employee_id = 1118;

-- BAGIAN 4.2 (a): UPDATE - isi gaji dengan angka pilihan sendiri
UPDATE employees SET salary = 6000 WHERE employee_id = 1118;
COMMIT;
-- Bukti sesudah isi gaji
SELECT employee_id, last_name, salary FROM employees WHERE employee_id = 1118;

-- BAGIAN 4.2 (b): UPDATE - naikkan gaji 10%
UPDATE employees SET salary = salary * 1.10 WHERE employee_id = 1118;
COMMIT;
-- Bukti sesudah kenaikan 10% (6000 -> 6600)
SELECT employee_id, last_name, salary FROM employees WHERE employee_id = 1118;

-- BAGIAN 4.3: DELETE - hanya baris milik sendiri
DELETE FROM employees WHERE employee_id = 1118;
COMMIT;
-- Bukti sesudah DELETE - harus 0 baris
SELECT * FROM employees WHERE employee_id = 1118;

-- =====================================================================
-- BAGIAN 5: Dashboard Mini (View)
-- BAGIAN 5.1: Buat view lewat SQL Editor (karyawan departemen Finance)
CREATE VIEW V_RINGKASAN_250810701100118 AS
SELECT first_name || ' ' || last_name AS nama_lengkap,
       salary * 12                    AS gaji_tahunan
FROM employees
WHERE department_id = 100;

-- BAGIAN 5.2: Ubah view dengan CREATE OR REPLACE (tambah kolom & departemen IT)
CREATE OR REPLACE VIEW V_RINGKASAN_250810701100118 AS
SELECT first_name || ' ' || last_name AS nama_lengkap,
       department_id                  AS id_departemen,
       job_id                         AS id_pekerjaan,
       salary * 12                    AS gaji_tahunan
FROM employees
WHERE department_id IN (60, 100);

-- BAGIAN 5.3: View V_MENU_250810701100118 dibuat lewat UI DBeaver (BUKAN diketik):
--   Database Navigator > HR > klik kanan folder "Views" > Create New View
--   > beri nama V_MENU_250810701100118 > isi query, contoh:
--      SELECT job_id, COUNT(*) AS jumlah_karyawan FROM employees GROUP BY job_id
--   > Save/Persist. Screenshot prosesnya.
-- JALANKAN BAGIAN 5.3 SEBELUM BARIS SELECT V_MENU DI BAWAH, kalau tidak
-- akan muncul ORA-00942 (table or view does not exist).
-- BAGIAN 5.4: Panggil kedua view
SELECT * FROM V_RINGKASAN_250810701100118;
SELECT * FROM V_MENU_250810701100118;

-- =====================================================================
-- BAGIAN 6: Soal Modul
-- BAGIAN 6.1: Karyawan yang masuk kerja tahun 2005 sampai 2007
SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date >= DATE '2005-01-01'
  AND hire_date <  DATE '2008-01-01'
ORDER BY hire_date;

-- BAGIAN 6.2: Rata-rata salary untuk tiap job_id
SELECT job_id,
       ROUND(AVG(salary), 2) AS rata_rata_salary
FROM employees
GROUP BY job_id
ORDER BY job_id;

-- BAGIAN 6.3: job_id, rata-rata, min_salary, max_salary (EMPLOYEES + JOBS)
SELECT e.job_id,
       ROUND(AVG(e.salary), 2) AS rata_rata_salary,
       j.min_salary,
       j.max_salary
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
GROUP BY e.job_id, j.min_salary, j.max_salary
ORDER BY e.job_id;
