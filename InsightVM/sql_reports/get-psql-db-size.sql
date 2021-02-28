
SELECT table_schema "DB Name", sum( data_length + index_length ) / 1024 / 1024 "DB Size in MB" FROM information_schema.TABLES GROUP BY table_schema ORDER BY "DB Size in MB" desc;

SELECT table_schema "DB Name",  UPDATE_TIME, CHECK_TIME, CHECKSUM, sum(table_rows) "Total Rows", sum( data_length + index_length ) / 1024 / 1024 "DB Size in MB" FROM information_schema.TABLES GROUP BY table_schema ORDER BY "DB Size in MB" desc limit 10;

show columns from information_schema.tables;
