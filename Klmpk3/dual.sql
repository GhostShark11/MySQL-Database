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