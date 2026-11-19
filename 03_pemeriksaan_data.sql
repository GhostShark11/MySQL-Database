-- =====================================================================
-- 03_pemeriksaan_data.sql
-- Pemeriksaan data (data checks) pada data mentah hasil impor CSV
-- Dijalankan pada koneksi K03_investigator (pemilik tabel hasil impor)
--
-- Tabel yang diperiksa (nama default hasil impor SQL Developer):
--   PATIENTS, STAFF, STAFF_SCHEDULE, SERVICES_WEEKLY
-- Script ini hanya berisi SELECT (read-only), tidak mengubah data.
-- Kode temuan (T01..T11) sama dengan tabel ringkasan di Bab 4 laporan.
-- =====================================================================

-- 0. persiapan
-- format tanggal disamakan dengan isi CSV (YYYY-MM-DD) supaya TO_DATE
-- tetap aman, baik kolom tanggal berupa DATE maupun VARCHAR2
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

-- =====================================================================
-- 1. profil umum data
-- =====================================================================

-- 1.1 jumlah baris tiap tabel
SELECT 'PATIENTS' AS nama_tabel, COUNT(*) AS jumlah_baris FROM patients
UNION ALL
SELECT 'STAFF', COUNT(*) FROM staff
UNION ALL
SELECT 'STAFF_SCHEDULE', COUNT(*) FROM staff_schedule
UNION ALL
SELECT 'SERVICES_WEEKLY', COUNT(*) FROM services_weekly;

-- 1.2 baris yang memiliki nilai kosong (NULL) pada kolom apa pun
SELECT 'PATIENTS' AS nama_tabel, COUNT(*) AS baris_ada_null
	FROM patients
	WHERE patient_id IS NULL OR name IS NULL OR age IS NULL
		OR arrival_date IS NULL OR departure_date IS NULL
		OR service IS NULL OR satisfaction IS NULL
UNION ALL
SELECT 'STAFF', COUNT(*)
	FROM staff
	WHERE staff_id IS NULL OR staff_name IS NULL
		OR role IS NULL OR service IS NULL
UNION ALL
SELECT 'STAFF_SCHEDULE', COUNT(*)
	FROM staff_schedule
	WHERE week IS NULL OR staff_id IS NULL OR staff_name IS NULL
		OR role IS NULL OR service IS NULL OR present IS NULL
UNION ALL
SELECT 'SERVICES_WEEKLY', COUNT(*)
	FROM services_weekly
	WHERE week IS NULL OR month IS NULL OR service IS NULL
		OR available_beds IS NULL OR patients_request IS NULL
		OR patients_admitted IS NULL OR patients_refused IS NULL
		OR patient_satisfaction IS NULL OR staff_morale IS NULL
		OR event IS NULL;

-- 1.3 duplikasi kunci (hasil 0 = tidak ada duplikasi)
SELECT 'PATIENTS (patient_id)' AS pemeriksaan, COUNT(*) AS kunci_duplikat
	FROM (SELECT patient_id FROM patients
		GROUP BY patient_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'STAFF (staff_id)', COUNT(*)
	FROM (SELECT staff_id FROM staff
		GROUP BY staff_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'STAFF (staff_name)', COUNT(*)
	FROM (SELECT staff_name FROM staff
		GROUP BY staff_name HAVING COUNT(*) > 1)
UNION ALL
SELECT 'STAFF_SCHEDULE (week, staff_id)', COUNT(*)
	FROM (SELECT week, staff_id FROM staff_schedule
		GROUP BY week, staff_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'SERVICES_WEEKLY (week, service)', COUNT(*)
	FROM (SELECT week, service FROM services_weekly
		GROUP BY week, service HAVING COUNT(*) > 1);

-- 1.4 nilai kategori yang muncul (cek salah ketik / beda huruf besar-kecil)
SELECT 'patients.service' AS kolom, service AS nilai, COUNT(*) AS jumlah
	FROM patients GROUP BY service
UNION ALL
SELECT 'staff.role', role, COUNT(*) FROM staff GROUP BY role
UNION ALL
SELECT 'staff.service', service, COUNT(*) FROM staff GROUP BY service
UNION ALL
SELECT 'staff_schedule.role', role, COUNT(*) FROM staff_schedule GROUP BY role
UNION ALL
SELECT 'staff_schedule.service', service, COUNT(*)
	FROM staff_schedule GROUP BY service
UNION ALL
SELECT 'staff_schedule.present', TO_CHAR(present), COUNT(*)
	FROM staff_schedule GROUP BY present
UNION ALL
SELECT 'services_weekly.service', service, COUNT(*)
	FROM services_weekly GROUP BY service
UNION ALL
SELECT 'services_weekly.event', event, COUNT(*)
	FROM services_weekly GROUP BY event
ORDER BY 1, 2;

-- 1.5 rentang nilai kolom numerik (cek nilai negatif / di luar skala)
SELECT 'patients.age' AS kolom,
	MIN(TO_NUMBER(age)) AS nilai_min, MAX(TO_NUMBER(age)) AS nilai_maks
	FROM patients
UNION ALL
SELECT 'patients.satisfaction', MIN(TO_NUMBER(satisfaction)),
	MAX(TO_NUMBER(satisfaction)) FROM patients
UNION ALL
SELECT 'patients.lama_rawat_hari',
	MIN(TO_DATE(departure_date, 'YYYY-MM-DD') - TO_DATE(arrival_date, 'YYYY-MM-DD')),
	MAX(TO_DATE(departure_date, 'YYYY-MM-DD') - TO_DATE(arrival_date, 'YYYY-MM-DD'))
	FROM patients
UNION ALL
SELECT 'services_weekly.available_beds', MIN(TO_NUMBER(available_beds)),
	MAX(TO_NUMBER(available_beds)) FROM services_weekly
UNION ALL
SELECT 'services_weekly.patients_request', MIN(TO_NUMBER(patients_request)),
	MAX(TO_NUMBER(patients_request)) FROM services_weekly
UNION ALL
SELECT 'services_weekly.patients_refused', MIN(TO_NUMBER(patients_refused)),
	MAX(TO_NUMBER(patients_refused)) FROM services_weekly
UNION ALL
SELECT 'services_weekly.patient_satisfaction', MIN(TO_NUMBER(patient_satisfaction)),
	MAX(TO_NUMBER(patient_satisfaction)) FROM services_weekly
UNION ALL
SELECT 'services_weekly.staff_morale', MIN(TO_NUMBER(staff_morale)),
	MAX(TO_NUMBER(staff_morale)) FROM services_weekly;

-- 1.6 konsistensi hitungan di services_weekly (hasil 0 = konsisten)
SELECT
	SUM(CASE WHEN patients_request <> patients_admitted + patients_refused
		THEN 1 ELSE 0 END) AS request_tidak_sama_admit_plus_refuse,
	SUM(CASE WHEN patients_admitted > available_beds
		THEN 1 ELSE 0 END) AS admit_melebihi_bed,
	SUM(CASE WHEN patients_admitted > patients_request
		THEN 1 ELSE 0 END) AS admit_melebihi_request
	FROM services_weekly;

-- 1.7 konsistensi tanggal pasien (hasil 0 = konsisten)
SELECT COUNT(*) AS tanggal_pulang_sebelum_datang
	FROM patients
	WHERE TO_DATE(departure_date, 'YYYY-MM-DD') < TO_DATE(arrival_date, 'YYYY-MM-DD');

-- =====================================================================
-- 2. staff vs staff_schedule (T01, T02, T03)
-- =====================================================================

-- T01 staff_id di jadwal tidak pernah cocok dengan staff_id di tabel staff
SELECT
	(SELECT COUNT(DISTINCT staff_id) FROM staff) AS id_di_staff,
	(SELECT COUNT(DISTINCT staff_id) FROM staff_schedule) AS id_di_jadwal,
	(SELECT COUNT(*) FROM staff s
		WHERE EXISTS (SELECT 1 FROM staff_schedule j
			WHERE j.staff_id = s.staff_id)) AS id_staff_ada_di_jadwal,
	(SELECT COUNT(DISTINCT j.staff_id) FROM staff_schedule j
		WHERE NOT EXISTS (SELECT 1 FROM staff s
			WHERE s.staff_id = j.staff_id)) AS id_jadwal_tanpa_pasangan
	FROM dual;

-- T01 bukti: join berdasarkan staff_id menghasilkan 0 baris
SELECT COUNT(*) AS baris_hasil_join_staff_id
	FROM staff s
	JOIN staff_schedule j ON j.staff_id = s.staff_id;

-- T01 bukti: orang yang sama (nama sama) punya staff_id berbeda (10 contoh)
SELECT * FROM (
	SELECT s.staff_name, s.staff_id AS id_di_staff, j.staff_id AS id_di_jadwal
		FROM staff s
		JOIN (SELECT DISTINCT staff_id, staff_name FROM staff_schedule) j
			ON j.staff_name = s.staff_name
		ORDER BY s.staff_name
) WHERE ROWNUM <= 10;

-- T02 staf di jadwal yang namanya tidak ada di tabel staff (16 orang)
SELECT j.staff_id, j.staff_name, j.role, j.service, COUNT(*) AS baris_jadwal
	FROM staff_schedule j
	WHERE NOT EXISTS (SELECT 1 FROM staff s WHERE s.staff_name = j.staff_name)
	GROUP BY j.staff_id, j.staff_name, j.role, j.service
	ORDER BY j.service, j.staff_name;

-- T02 ringkasan: jumlah orang, unit asal, dan berapa yang juga tercatat sebagai pasien
SELECT COUNT(*) AS jumlah_staf_tanpa_data_staff,
	COUNT(DISTINCT x.service) AS jumlah_unit_berbeda,
	MIN(x.service) AS unit,
	SUM(CASE WHEN EXISTS (SELECT 1 FROM patients p
			WHERE p.name = x.staff_name) THEN 1 ELSE 0 END) AS juga_tercatat_sebagai_pasien
	FROM (SELECT DISTINCT staff_id, staff_name, service
		FROM staff_schedule j
		WHERE NOT EXISTS (SELECT 1 FROM staff s
			WHERE s.staff_name = j.staff_name)) x;

-- T02 bukti: nama staf jadwal yang sama dengan nama pasien (semua nama di jadwal)
SELECT p.patient_id, p.name, p.age, p.service AS unit_pasien,
	j.role AS peran_staf, j.service AS unit_staf
	FROM patients p
	JOIN (SELECT DISTINCT staff_name, role, service FROM staff_schedule) j
		ON j.staff_name = p.name
	ORDER BY j.service, p.name;

-- T03 nama sama tetapi peran / unit berbeda antara staff dan staff_schedule
SELECT COUNT(*) AS nama_cocok,
	SUM(CASE WHEN s.role <> j.role THEN 1 ELSE 0 END) AS peran_berbeda,
	SUM(CASE WHEN s.service <> j.service THEN 1 ELSE 0 END) AS unit_berbeda,
	SUM(CASE WHEN s.role <> j.role AND s.service <> j.service
		THEN 1 ELSE 0 END) AS keduanya_berbeda,
	SUM(CASE WHEN s.role <> j.role OR s.service <> j.service
		THEN 1 ELSE 0 END) AS salah_satu_berbeda
	FROM staff s
	JOIN (SELECT DISTINCT staff_name, role, service FROM staff_schedule) j
		ON j.staff_name = s.staff_name;

-- T03 bukti: 15 contoh ketidakcocokan
SELECT * FROM (
	SELECT s.staff_name, s.role AS peran_staff, j.role AS peran_jadwal,
		s.service AS unit_staff, j.service AS unit_jadwal
		FROM staff s
		JOIN (SELECT DISTINCT staff_name, role, service FROM staff_schedule) j
			ON j.staff_name = s.staff_name
		WHERE s.role <> j.role OR s.service <> j.service
		ORDER BY s.service, s.staff_name
) WHERE ROWNUM <= 15;

-- T03 sebaran: unit di staff vs unit di jadwal
SELECT s.service AS unit_staff, j.service AS unit_jadwal, COUNT(*) AS jumlah_staf
	FROM staff s
	JOIN (SELECT DISTINCT staff_name, service FROM staff_schedule) j
		ON j.staff_name = s.staff_name
	GROUP BY s.service, j.service
	ORDER BY s.service, j.service;

-- =====================================================================
-- 3. kehadiran staf (T04)
-- =====================================================================

-- T04 minggu dengan seluruh staf tidak hadir (present = 0 untuk semua orang)
SELECT COUNT(*) AS minggu_nol_hadir,
	SUM(CASE WHEN MOD(week, 3) = 0 THEN 1 ELSE 0 END) AS yang_kelipatan_3,
	MIN(week) AS minggu_pertama, MAX(week) AS minggu_terakhir
	FROM (SELECT week FROM staff_schedule
		GROUP BY week HAVING SUM(present) = 0);

-- T04 daftar minggu tersebut
SELECT week AS minggu, COUNT(*) AS baris_jadwal, SUM(present) AS total_hadir
	FROM staff_schedule
	GROUP BY week
	HAVING SUM(present) = 0
	ORDER BY week;

-- T04 tingkat kehadiran minggu kelipatan 3 vs minggu lainnya
SELECT CASE WHEN MOD(week, 3) = 0 THEN 'kelipatan 3' ELSE 'lainnya' END AS kelompok_minggu,
	COUNT(*) AS baris_jadwal, SUM(present) AS total_hadir,
	ROUND(100 * SUM(present) / COUNT(*), 1) AS persen_hadir
	FROM staff_schedule
	GROUP BY CASE WHEN MOD(week, 3) = 0 THEN 'kelipatan 3' ELSE 'lainnya' END
	ORDER BY 1;

-- T04 dampak: unit-minggu tanpa staf hadir tetapi pasien tetap diterima
SELECT COUNT(*) AS total_unit_minggu,
	SUM(CASE WHEN h.total_hadir = 0 THEN 1 ELSE 0 END) AS unit_minggu_nol_hadir,
	SUM(CASE WHEN h.total_hadir = 0 AND w.patients_admitted > 0
		THEN 1 ELSE 0 END) AS nol_hadir_tapi_ada_pasien_diterima,
	SUM(CASE WHEN h.total_hadir = 0 THEN w.patients_admitted ELSE 0 END) AS pasien_diterima_saat_nol_hadir
	FROM (SELECT week, service, SUM(present) AS total_hadir
		FROM staff_schedule GROUP BY week, service) h
	JOIN services_weekly w ON w.week = h.week AND w.service = h.service;

-- =====================================================================
-- 4. services_weekly (T05, T09)
-- =====================================================================

-- T05 jumlah minggu dan baris per bulan (bulan 12 memuat 8 minggu)
SELECT month AS bulan, COUNT(DISTINCT week) AS jumlah_minggu,
	MIN(week) AS minggu_awal, MAX(week) AS minggu_akhir, COUNT(*) AS jumlah_baris
	FROM services_weekly
	GROUP BY month
	ORDER BY month;

-- T05 bukti: bulan mengikuti aturan mekanis 4 minggu per bulan (maks. 12)
SELECT COUNT(*) AS baris_total,
	SUM(CASE WHEN month <> LEAST(CEIL(week / 4), 12) THEN 1 ELSE 0 END) AS baris_tidak_sesuai_aturan,
	(SELECT COUNT(*) FROM (SELECT week FROM services_weekly
		GROUP BY week HAVING COUNT(DISTINCT month) > 1)) AS minggu_dengan_2_bulan
	FROM services_weekly;

-- T09 permintaan, penerimaan, dan penolakan pasien per layanan
SELECT service AS layanan, COUNT(*) AS jumlah_minggu,
	SUM(patients_request) AS permintaan,
	SUM(patients_admitted) AS diterima,
	SUM(patients_refused) AS ditolak,
	ROUND(100 * SUM(patients_refused) / SUM(patients_request), 1) AS persen_ditolak,
	SUM(CASE WHEN patients_refused > patients_admitted THEN 1 ELSE 0 END) AS minggu_ditolak_lebih_banyak,
	SUM(CASE WHEN patients_refused = 0 THEN 1 ELSE 0 END) AS minggu_tanpa_penolakan
	FROM services_weekly
	GROUP BY service
	ORDER BY 6 DESC;

-- T09 bukti: 5 minggu dengan penolakan terbesar
SELECT * FROM (
	SELECT week AS minggu, service AS layanan, available_beds, patients_request,
		patients_admitted, patients_refused, event
		FROM services_weekly
		ORDER BY patients_refused DESC, week
) WHERE ROWNUM <= 5;

-- =====================================================================
-- 5. patients (T06, T07, T08, T11)
-- =====================================================================

-- T06 pasien dengan tanggal pulang di luar tahun data (2026)
SELECT COUNT(*) AS pasien_pulang_2026,
	TO_CHAR(MIN(TO_DATE(departure_date, 'YYYY-MM-DD')), 'YYYY-MM-DD') AS pulang_paling_awal,
	TO_CHAR(MAX(TO_DATE(departure_date, 'YYYY-MM-DD')), 'YYYY-MM-DD') AS pulang_paling_akhir
	FROM patients
	WHERE TO_DATE(departure_date, 'YYYY-MM-DD') > TO_DATE('2025-12-31', 'YYYY-MM-DD');

-- T06 rentang tanggal datang dan pulang seluruh pasien
SELECT TO_CHAR(MIN(TO_DATE(arrival_date, 'YYYY-MM-DD')), 'YYYY-MM-DD') AS datang_awal,
	TO_CHAR(MAX(TO_DATE(arrival_date, 'YYYY-MM-DD')), 'YYYY-MM-DD') AS datang_akhir,
	TO_CHAR(MIN(TO_DATE(departure_date, 'YYYY-MM-DD')), 'YYYY-MM-DD') AS pulang_awal,
	TO_CHAR(MAX(TO_DATE(departure_date, 'YYYY-MM-DD')), 'YYYY-MM-DD') AS pulang_akhir
	FROM patients;

-- T07 nama pasien yang muncul lebih dari satu kali (patient_id berbeda)
SELECT name AS nama, COUNT(*) AS jumlah_baris,
	COUNT(DISTINCT patient_id) AS jumlah_patient_id,
	MIN(TO_NUMBER(age)) AS usia_min, MAX(TO_NUMBER(age)) AS usia_maks
	FROM patients
	GROUP BY name
	HAVING COUNT(*) > 1
	ORDER BY name;

-- T08 nama yang memuat gelar / sufiks (bukan nama orang apa adanya)
SELECT 'patients' AS tabel, name AS nama, service AS unit
	FROM patients
	WHERE REGEXP_LIKE(name, ' (DDS|MD|PhD|DVM|Jr\.|Sr\.|II|III|IV)$')
UNION ALL
SELECT 'staff', staff_name, service
	FROM staff
	WHERE REGEXP_LIKE(staff_name, ' (DDS|MD|PhD|DVM|Jr\.|Sr\.|II|III|IV)$')
ORDER BY 1, 2;

-- T08 ringkasan jumlah
SELECT (SELECT COUNT(*) FROM patients
		WHERE REGEXP_LIKE(name, ' (DDS|MD|PhD|DVM|Jr\.|Sr\.|II|III|IV)$')) AS pasien_bergelar,
	(SELECT COUNT(*) FROM staff
		WHERE REGEXP_LIKE(staff_name, ' (DDS|MD|PhD|DVM|Jr\.|Sr\.|II|III|IV)$')) AS staf_bergelar
	FROM dual;

-- T11 sebaran skor kepuasan: batas bawah tepat 60, tidak ada nilai di bawahnya
SELECT COUNT(*) AS jumlah_pasien,
	MIN(TO_NUMBER(satisfaction)) AS skor_min,
	MAX(TO_NUMBER(satisfaction)) AS skor_maks,
	COUNT(DISTINCT satisfaction) AS jumlah_nilai_berbeda,
	SUM(CASE WHEN satisfaction < 60 THEN 1 ELSE 0 END) AS skor_di_bawah_60,
	SUM(CASE WHEN satisfaction = 60 THEN 1 ELSE 0 END) AS skor_tepat_60,
	MAX(TO_NUMBER(age)) AS usia_maks
	FROM patients;

-- =====================================================================
-- 6. rekonsiliasi lintas tabel (T10)
-- =====================================================================

-- T10 pasien di patients vs pasien diterima di services_weekly
SELECT w.service AS layanan, w.diterima AS diterima_mingguan,
	NVL(p.jumlah_pasien, 0) AS pasien_tercatat,
	ROUND(100 * NVL(p.jumlah_pasien, 0) / w.diterima, 1) AS persen_tercatat
	FROM (SELECT service, SUM(patients_admitted) AS diterima
		FROM services_weekly GROUP BY service) w
	LEFT JOIN (SELECT service, COUNT(*) AS jumlah_pasien
		FROM patients GROUP BY service) p
		ON p.service = w.service
	ORDER BY w.service;

-- T10 total keseluruhan
SELECT (SELECT COUNT(*) FROM patients) AS pasien_tercatat,
	(SELECT SUM(patients_admitted) FROM services_weekly) AS diterima_mingguan,
	ROUND(100 * (SELECT COUNT(*) FROM patients)
		/ (SELECT SUM(patients_admitted) FROM services_weekly), 1) AS persen_tercatat
	FROM dual;

-- =====================================================================
-- 7. ringkasan seluruh temuan (sumber angka tabel di Bab 4 laporan)
-- =====================================================================
SELECT 'T01' AS kode, 'STAFF_SCHEDULE' AS tabel_sumber,
	'staff_id jadwal tidak punya pasangan di tabel staff' AS temuan,
	(SELECT COUNT(DISTINCT j.staff_id) FROM staff_schedule j
		WHERE NOT EXISTS (SELECT 1 FROM staff s WHERE s.staff_id = j.staff_id)) AS jumlah_kasus,
	(SELECT COUNT(DISTINCT staff_id) FROM staff_schedule) AS dari_total
	FROM dual
UNION ALL
SELECT 'T02', 'STAFF_SCHEDULE',
	'staf di jadwal yang namanya tidak ada di tabel staff',
	(SELECT COUNT(DISTINCT j.staff_name) FROM staff_schedule j
		WHERE NOT EXISTS (SELECT 1 FROM staff s WHERE s.staff_name = j.staff_name)),
	(SELECT COUNT(DISTINCT staff_name) FROM staff_schedule)
	FROM dual
UNION ALL
SELECT 'T03', 'STAFF / STAFF_SCHEDULE',
	'nama sama tetapi peran atau unit berbeda',
	(SELECT COUNT(*) FROM staff s
		JOIN (SELECT DISTINCT staff_name, role, service FROM staff_schedule) j
			ON j.staff_name = s.staff_name
		WHERE s.role <> j.role OR s.service <> j.service),
	(SELECT COUNT(*) FROM staff)
	FROM dual
UNION ALL
SELECT 'T04', 'STAFF_SCHEDULE',
	'unit-minggu dengan seluruh staf tidak hadir',
	(SELECT COUNT(*) FROM (SELECT week, service FROM staff_schedule
		GROUP BY week, service HAVING SUM(present) = 0)),
	(SELECT COUNT(*) FROM services_weekly)
	FROM dual
UNION ALL
SELECT 'T05', 'SERVICES_WEEKLY',
	'baris pada bulan yang memuat lebih dari 4 minggu',
	(SELECT COUNT(*) FROM services_weekly
		WHERE month IN (SELECT month FROM services_weekly
			GROUP BY month HAVING COUNT(DISTINCT week) > 4)),
	(SELECT COUNT(*) FROM services_weekly)
	FROM dual
UNION ALL
SELECT 'T06', 'PATIENTS',
	'pasien dengan tanggal pulang di tahun 2026',
	(SELECT COUNT(*) FROM patients
		WHERE TO_DATE(departure_date, 'YYYY-MM-DD') > TO_DATE('2025-12-31', 'YYYY-MM-DD')),
	(SELECT COUNT(*) FROM patients)
	FROM dual
UNION ALL
SELECT 'T07', 'PATIENTS',
	'baris pasien dengan nama sama tetapi patient_id berbeda',
	(SELECT COUNT(*) FROM patients
		WHERE name IN (SELECT name FROM patients GROUP BY name HAVING COUNT(*) > 1)),
	(SELECT COUNT(*) FROM patients)
	FROM dual
UNION ALL
SELECT 'T08', 'PATIENTS / STAFF',
	'nama memuat gelar atau sufiks (DDS, MD, PhD, DVM, Jr., II, III)',
	(SELECT COUNT(*) FROM patients
		WHERE REGEXP_LIKE(name, ' (DDS|MD|PhD|DVM|Jr\.|Sr\.|II|III|IV)$'))
	+ (SELECT COUNT(*) FROM staff
		WHERE REGEXP_LIKE(staff_name, ' (DDS|MD|PhD|DVM|Jr\.|Sr\.|II|III|IV)$')),
	(SELECT COUNT(*) FROM patients) + (SELECT COUNT(*) FROM staff)
	FROM dual
UNION ALL
SELECT 'T09', 'SERVICES_WEEKLY',
	'unit-minggu dengan pasien ditolak lebih banyak daripada diterima',
	(SELECT COUNT(*) FROM services_weekly WHERE patients_refused > patients_admitted),
	(SELECT COUNT(*) FROM services_weekly)
	FROM dual
UNION ALL
SELECT 'T10', 'PATIENTS / SERVICES_WEEKLY',
	'pasien tercatat dibanding total pasien diterima per minggu',
	(SELECT COUNT(*) FROM patients),
	(SELECT SUM(patients_admitted) FROM services_weekly)
	FROM dual
UNION ALL
SELECT 'T11', 'PATIENTS',
	'pasien dengan skor kepuasan tepat di batas bawah 60 (tidak ada skor < 60)',
	(SELECT COUNT(*) FROM patients WHERE satisfaction = 60),
	(SELECT COUNT(*) FROM patients)
	FROM dual
ORDER BY 1;
