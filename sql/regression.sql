CREATE EXTENSION IF NOT EXISTS pg_libnumbertext;

SELECT numbertext('1', 'en');
SELECT numbertext('3', 'ja');
SELECT numbertext('not a number', 'en');
SELECT numbertext('1', 'not a language');
