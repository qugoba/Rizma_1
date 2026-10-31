-- رِزمة — تفعيل pg_cron قبل ملف الصيانة، فتتم جدولة الصيانة اليومية تلقائيًا.
create extension if not exists pg_cron;
