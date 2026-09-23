-- =====================================================================
-- BASIS DATA SISTEM BIODATA DOSEN
-- Berdasarkan ERD: DOSEN - PENDIDIKAN - PUBLIKASI - MATAKULIAH - AKTIVITAS_LAIN
-- Dialek: MySQL / MariaDB (bisa dijalankan langsung via mysql client / phpMyAdmin)
-- =====================================================================

DROP DATABASE IF EXISTS biodata_dosen;
CREATE DATABASE biodata_dosen;
USE biodata_dosen;

-- =====================================================================
-- 1. TABEL DOSEN (entitas utama)
-- =====================================================================
CREATE TABLE dosen (
    nip           VARCHAR(20)  NOT NULL,
    nama          VARCHAR(100) NOT NULL,
    pangkat       VARCHAR(50)  NULL,
    jabatan       VARCHAR(50)  NULL,
    prodi         VARCHAR(100) NULL,
    fakultas      VARCHAR(100) NULL,
    email         VARCHAR(100) NULL,
    no_hp         VARCHAR(20)  NULL,
    CONSTRAINT pk_dosen PRIMARY KEY (nip),
    CONSTRAINT uq_dosen_email UNIQUE (email)
) ENGINE=InnoDB;

-- =====================================================================
-- 2. TABEL PENDIDIKAN (relasi "lakukan": 1 dosen - N pendidikan)
-- =====================================================================
CREATE TABLE pendidikan (
    id_pendidikan INT AUTO_INCREMENT,
    nip_dosen     VARCHAR(20)  NOT NULL,
    nama_univ     VARCHAR(100) NOT NULL,
    jenjang       VARCHAR(10)  NOT NULL,
    gelar         VARCHAR(50)  NULL,
    kota          VARCHAR(50)  NULL,
    bidang        VARCHAR(100) NULL,
    thn_masuk     YEAR         NOT NULL,
    thn_keluar    YEAR         NULL,
    CONSTRAINT pk_pendidikan PRIMARY KEY (id_pendidikan),
    CONSTRAINT fk_pendidikan_dosen FOREIGN KEY (nip_dosen)
        REFERENCES dosen (nip) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_pendidikan_jenjang CHECK (jenjang IN ('D3','D4','S1','S2','S3')),
    CONSTRAINT chk_pendidikan_tahun CHECK (thn_keluar IS NULL OR thn_keluar >= thn_masuk)
) ENGINE=InnoDB;

-- =====================================================================
-- 3. TABEL PUBLIKASI (relasi "miliki": 1 dosen - N publikasi)
-- =====================================================================
CREATE TABLE publikasi (
    id_publikasi         INT AUTO_INCREMENT,
    nip_dosen            VARCHAR(20)  NOT NULL,
    tahun                YEAR         NOT NULL,
    judul_publikasi      VARCHAR(255) NOT NULL,
    jurnal_atau_seminar  VARCHAR(10)  NOT NULL,
    judul_jurnal_seminar VARCHAR(255) NULL,
    penulis              VARCHAR(255) NULL,
    lokasi               VARCHAR(100) NULL,
    CONSTRAINT pk_publikasi PRIMARY KEY (id_publikasi),
    CONSTRAINT fk_publikasi_dosen FOREIGN KEY (nip_dosen)
        REFERENCES dosen (nip) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_publikasi_jenis CHECK (jurnal_atau_seminar IN ('Jurnal','Seminar'))
) ENGINE=InnoDB;

-- =====================================================================
-- 4. TABEL MATAKULIAH (relasi "ajar": 1 dosen - N matakuliah)
-- =====================================================================
CREATE TABLE matakuliah (
    id_matakuliah INT AUTO_INCREMENT,
    nip_dosen     VARCHAR(20)  NOT NULL,
    kode_mk       VARCHAR(20)  NOT NULL,
    nama_mk       VARCHAR(100) NOT NULL,
    deskripsi     TEXT         NULL,
    thn_ajaran    VARCHAR(20)  NOT NULL,
    semester      VARCHAR(20)  NULL,
    jadwal        VARCHAR(50)  NULL,
    url           VARCHAR(255) NULL,
    CONSTRAINT pk_matakuliah PRIMARY KEY (id_matakuliah),
    CONSTRAINT fk_matakuliah_dosen FOREIGN KEY (nip_dosen)
        REFERENCES dosen (nip) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uq_matakuliah_offering UNIQUE (kode_mk, thn_ajaran, nip_dosen)
) ENGINE=InnoDB;

-- =====================================================================
-- 5. TABEL AKTIVITAS_LAIN (relasi "lakukan": 1 dosen - N aktivitas_lain)
-- =====================================================================
CREATE TABLE aktivitas_lain (
    id_aktivitas   INT AUTO_INCREMENT,
    nip_dosen      VARCHAR(20)  NOT NULL,
    nama_kegiatan  VARCHAR(150) NOT NULL,
    deskripsi      TEXT         NULL,
    peran          VARCHAR(100) NULL,
    lokasi         VARCHAR(100) NULL,
    tgl_mulai      DATE         NOT NULL,
    tgl_akhir      DATE         NULL,
    CONSTRAINT pk_aktivitas_lain PRIMARY KEY (id_aktivitas),
    CONSTRAINT fk_aktivitas_dosen FOREIGN KEY (nip_dosen)
        REFERENCES dosen (nip) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_aktivitas_tanggal CHECK (tgl_akhir IS NULL OR tgl_akhir >= tgl_mulai)
) ENGINE=InnoDB;


-- =====================================================================
-- INSERT DATA
-- =====================================================================

-- ---------------------------------------------------------------------
-- DATA DOSEN (6 data)
-- ---------------------------------------------------------------------
INSERT INTO dosen (nip, nama, pangkat, jabatan, prodi, fakultas, email, no_hp) VALUES
('198501012010121001', 'Dr. Ahmad Fauzi, M.Kom.',      'Penata Muda Tk. I', 'Lektor',           'Teknik Informatika', 'Teknik',          'ahmad.fauzi@usk.ac.id',   '081234567801'),
('198703152011122002', 'Siti Rahmawati, M.Sc.',         'Penata',            'Lektor Kepala',    'Sistem Informasi',  'Teknik',          'siti.rahmawati@usk.ac.id','081234567802'),
('199001202015041003', 'Muhammad Rizki, M.T.',          'Penata Muda',       'Asisten Ahli',     'Teknik Informatika', 'Teknik',          'rizki@usk.ac.id',         '081234567803'),
('198812052014031004', 'Dr. Cut Nabila, M.Kom.',        'Pembina',           'Lektor Kepala',    'Sistem Informasi',  'Teknik',          'cut.nabila@usk.ac.id',    '081234567804'),
('199206102018121005', 'Teuku Iskandar, M.Cs.',         'Penata Muda Tk. I', 'Asisten Ahli',     'Teknik Informatika', 'Teknik',          'teuku.iskandar@usk.ac.id','081234567805'),
('198409302012032006', 'Prof. Dr. Rina Marlina, M.T.',  'Pembina Utama',     'Guru Besar',       'Teknik Elektro',    'Teknik',          'rina.marlina@usk.ac.id',  '081234567806');

-- ---------------------------------------------------------------------
-- DATA PENDIDIKAN (7 data)
-- ---------------------------------------------------------------------
INSERT INTO pendidikan (nip_dosen, nama_univ, jenjang, gelar, kota, bidang, thn_masuk, thn_keluar) VALUES
('198501012010121001', 'Universitas Syiah Kuala',   'S1', 'S.Kom.', 'Banda Aceh', 'Ilmu Komputer',        2003, 2007),
('198501012010121001', 'Institut Teknologi Bandung','S3', 'Dr.',    'Bandung',    'Ilmu Komputer',        2012, 2016),
('198703152011122002', 'Universitas Gadjah Mada',   'S2', 'M.Sc.',  'Yogyakarta', 'Sistem Informasi',     2008, 2010),
('199001202015041003', 'Universitas Indonesia',     'S2', 'M.T.',   'Depok',      'Teknik Informatika',   2011, 2013),
('198812052014031004', 'Universitas Sumatera Utara','S3', 'Dr.',    'Medan',      'Ilmu Komputer',        2014, 2018),
('199206102018121005', 'Universitas Syiah Kuala',   'S2', 'M.Cs.',  'Banda Aceh', 'Ilmu Komputer',        2014, 2016),
('198409302012032006', 'National Univ. of Singapore','S3','Prof.',  'Singapura',  'Teknik Elektro',       2005, 2009);

-- ---------------------------------------------------------------------
-- DATA PUBLIKASI (8 data)
-- ---------------------------------------------------------------------
INSERT INTO publikasi (nip_dosen, tahun, judul_publikasi, jurnal_atau_seminar, judul_jurnal_seminar, penulis, lokasi) VALUES
('198501012010121001', 2020, 'Implementasi IoT untuk Smart Campus',                 'Jurnal',  'Jurnal Teknik Informatika USK',         'Ahmad Fauzi, Rizki',       'Banda Aceh'),
('198501012010121001', 2022, 'Optimasi Algoritma Genetika pada Penjadwalan',        'Seminar', 'Seminar Nasional Informatika',          'Ahmad Fauzi',              'Jakarta'),
('198703152011122002', 2019, 'Analisis Sistem Informasi Akademik Berbasis Cloud',   'Jurnal',  'Jurnal Sistem Informasi Indonesia',     'Siti Rahmawati',           'Yogyakarta'),
('198703152011122002', 2021, 'Model Keamanan Data pada E-Government',              'Jurnal',  'Jurnal Keamanan Siber',                 'Siti Rahmawati, Cut Nabila','Banda Aceh'),
('199001202015041003', 2021, 'Klasifikasi Citra Menggunakan CNN',                  'Seminar', 'International Conference on ICT',       'Muhammad Rizki',           'Kuala Lumpur'),
('198812052014031004', 2018, 'Perancangan Data Warehouse untuk Universitas',       'Jurnal',  'Jurnal Basis Data',                     'Cut Nabila',               'Medan'),
('198812052014031004', 2023, 'Penerapan Machine Learning pada Prediksi Kelulusan', 'Jurnal',  'Jurnal Teknik Informatika USK',         'Cut Nabila, Rizki',        'Banda Aceh'),
('199206102018121005', 2022, 'Pengembangan Aplikasi Mobile untuk Layanan Kampus',  'Seminar', 'Seminar Nasional Sistem Informasi',     'Teuku Iskandar',           'Banda Aceh');

-- ---------------------------------------------------------------------
-- DATA MATAKULIAH (8 data)
-- ---------------------------------------------------------------------
INSERT INTO matakuliah (nip_dosen, kode_mk, nama_mk, deskripsi, thn_ajaran, semester, jadwal, url) VALUES
('198501012010121001', 'TIF101', 'Jaringan Komputer',        'Konsep dasar jaringan dan protokol komunikasi', '2023/2024', 'Ganjil', 'Senin 08:00-10:00', 'https://elearning.usk.ac.id/tif101'),
('198501012010121001', 'TIF201', 'Keamanan Jaringan',        'Prinsip keamanan siber dan jaringan',           '2023/2024', 'Genap',  'Selasa 10:00-12:00','https://elearning.usk.ac.id/tif201'),
('198703152011122002', 'SIF101', 'Basis Data',               'Perancangan dan implementasi basis data',       '2023/2024', 'Ganjil', 'Rabu 08:00-10:00',  'https://elearning.usk.ac.id/sif101'),
('199001202015041003', 'TIF301', 'Struktur Data & Algoritma','Konsep struktur data dan analisis algoritma',   '2023/2024', 'Ganjil', 'Kamis 13:00-15:00', 'https://elearning.usk.ac.id/tif301'),
('198812052014031004', 'SIF202', 'Data Mining',              'Teknik penambangan data dan pola',              '2023/2024', 'Genap',  'Jumat 08:00-10:00', 'https://elearning.usk.ac.id/sif202'),
('199206102018121005', 'TIF102', 'Pemrograman Mobile',       'Pengembangan aplikasi berbasis Android/iOS',    '2023/2024', 'Ganjil', 'Senin 13:00-15:00', 'https://elearning.usk.ac.id/tif102'),
('198409302012032006', 'TEL201', 'Sistem Kendali',           'Dasar-dasar sistem kendali otomatis',           '2023/2024', 'Genap',  'Selasa 08:00-10:00','https://elearning.usk.ac.id/tel201'),
('198501012010121001', 'TIF101', 'Jaringan Komputer',        'Konsep dasar jaringan dan protokol komunikasi', '2024/2025', 'Ganjil', 'Senin 08:00-10:00', 'https://elearning.usk.ac.id/tif101');

-- ---------------------------------------------------------------------
-- DATA AKTIVITAS_LAIN (6 data)
-- ---------------------------------------------------------------------
INSERT INTO aktivitas_lain (nip_dosen, nama_kegiatan, deskripsi, peran, lokasi, tgl_mulai, tgl_akhir) VALUES
('198501012010121001', 'Pelatihan Dosen Nasional',        'Pelatihan peningkatan kompetensi dosen',   'Peserta',    'Jakarta',    '2023-03-01', '2023-03-05'),
('198703152011122002', 'Workshop Kurikulum Merdeka',      'Penyusunan kurikulum berbasis OBE',        'Narasumber', 'Banda Aceh', '2023-05-10', '2023-05-12'),
('199001202015041003', 'Pengabdian Masyarakat Desa Digital','Pelatihan literasi digital untuk desa',  'Ketua Tim',  'Aceh Besar', '2023-07-15', '2023-07-20'),
('198812052014031004', 'Konferensi Internasional ICT',    'Menghadiri dan mempresentasikan makalah',  'Pembicara',  'Singapura',  '2023-09-01', '2023-09-03'),
('199206102018121005', 'Bimbingan Teknis Aplikasi Kampus','Pendampingan penggunaan sistem akademik',  'Fasilitator','Banda Aceh', '2023-11-05', '2023-11-06'),
('198409302012032006', 'Seminar Nasional Teknik Elektro', 'Menjadi keynote speaker seminar nasional', 'Keynote Speaker','Medan',  '2023-10-10', '2023-10-11');


-- =====================================================================
-- QUERY 1: Melibatkan SATU tabel, dilengkapi GROUP BY dan ORDER BY
-- Tema: Menghitung jumlah dosen per jabatan fungsional, diurutkan dari
--       jumlah terbanyak ke paling sedikit
-- =====================================================================
SELECT
    jabatan,
    COUNT(*) AS jumlah_dosen
FROM dosen
GROUP BY jabatan
ORDER BY jumlah_dosen DESC;


-- =====================================================================
-- QUERY 2: Melibatkan SATU tabel, dilengkapi HAVING
-- Tema: Menampilkan dosen (berdasarkan NIP) yang memiliki lebih dari 1
--       publikasi, beserta jumlah publikasinya
-- =====================================================================
SELECT
    nip_dosen,
    COUNT(*) AS jumlah_publikasi
FROM publikasi
GROUP BY nip_dosen
HAVING COUNT(*) > 1
ORDER BY jumlah_publikasi DESC;
