\d pg_catalog.pg_stat_activity
/*
                      View "pg_catalog.pg_stat_activity"
      Column      |           Type           | Collation | Nullable | Default 
------------------+--------------------------+-----------+----------+---------
 datid            | oid                      |           |          | 
 datname          | name                     |           |          | 
 pid              | integer                  |           |          | 
 usesysid         | oid                      |           |          | 
 usename          | name                     |           |          | 
 application_name | text                     |           |          | 
 client_addr      | inet                     |           |          | 
 client_hostname  | text                     |           |          | 
 client_port      | integer                  |           |          | 
 backend_start    | timestamp with time zone |           |          | 
 xact_start       | timestamp with time zone |           |          | 
 query_start      | timestamp with time zone |           |          | 
 state_change     | timestamp with time zone |           |          | 
 waiting          | boolean                  |           |          | 
 state            | text                     |           |          | 
 query            | text                     |           |          | 
*/


-- Sélectionne les connexions qui ne sont pas 'idle' et montre les query quelles
-- sont en train d'exécuter
select
    pid,
    state,
    query,
    datname,
    client_addr,
    backend_start,
    waiting
from pg_catalog.pg_stat_activity
where (
    state <> 'idle'
    and pid <> pg_backend_pid()
);


-- Kill a connexion
SELECT
    pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE (
    datname = 'databasename'
    AND pid <> pg_backend_pid()
    AND state in ('idle')
);

-- Select query and join on DB to see locks


\d pg_catalog.pg_locks
/*
                   View "pg_catalog.pg_locks"
       Column       |   Type   | Collation | Nullable | Default 
--------------------+----------+-----------+----------+---------
 locktype           | text     |           |          | 
 database           | oid      |           |          | 
 relation           | oid      |           |          | 
 page               | integer  |           |          | 
 tuple              | smallint |           |          | 
 virtualxid         | text     |           |          | 
 transactionid      | xid      |           |          | 
 classid            | oid      |           |          | 
 objid              | oid      |           |          | 
 objsubid           | smallint |           |          | 
 virtualtransaction | text     |           |          | 
 pid                | integer  |           |          | 
 mode               | text     |           |          | 
 granted            | boolean  |           |          | 
 fastpath           | boolean  |           |          | 
*/
select
    pg_sa.pid,
    pg_sa.query,
    pg_l.mode,
    pg_c.relname,
    pg_l.virtualtransaction
from pg_catalog.pg_locks pg_l
join pg_catalog.pg_class pg_c on (
    pg_l.relation = pg_c.oid
)
join pg_catalog.pg_stat_activity pg_sa on (
    pg_sa.pid = pg_l.pid
)
where (
    pg_sa.pid <> pg_backend_pid()
)
order by query
