
-- Sélectionne les connexions qui ne sont pas 'idle' et montre les query quelles
-- sont en train d'exécuter
select
    state,
    query,
    datname,
    client_addr,
    backend_start,
    waiting
from pg_catalog.pg_stat_activity
where state <> 'idle'

-- Select query and join on DB to see locks


\d pg_catalog.pg_locks
\d pg_catalog.pg_class
select
    pg_l.database,
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
order by query
