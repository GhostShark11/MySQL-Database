# MySQL-Database
**NCC Diploma for Computing done during 2023-2024 MySQL Database**
## What this database does
The finalized script in `schema.sql` creates a MySQL database named `MindsetDB`, defines four tables, inserts sample data, and runs the requested operations:
```sql
DELETE FROM Friends WHERE Attitude = 'toxic';
UPDATE `Self` SET Confidence = 100 WHERE Doubt > 0;
SELECT * FROM `Future` WHERE Excuses IS NULL;
SELECT * FROM Dreams WHERE `Limit` IS NULL;
```
The original `Excuses = NULL` condition was corrected to `Excuses IS NULL`, because SQL requires `IS NULL` when checking for missing values. The `Self`, `Future`, and `Limit` identifiers are quoted where needed so the script remains safe and executable in MySQL.
# Execute Database script 
**Install MySQL, then run:**
```bash
mysql -u root -p < schema.sql
```
**To open the database afterward:**
```bash
mysql -u root -p MindsetDB
```
## Export it
```bash
mysqldump -u root -p MindsetDB > database.sql
```

