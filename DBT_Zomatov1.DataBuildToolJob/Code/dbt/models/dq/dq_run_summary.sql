{{ config(materialized='table') }}

with quarantine_check as (

    select
        count(*) as quarantine_count
    from {{ ref('dq_quarantine') }}
    where run_id = '{{ invocation_id }}'

),

reconciliation_check as (

    select
        reconciliation_status
    from {{ ref('dq_reconciliation') }}

)

select
    '{{ invocation_id }}' as run_id,

    q.quarantine_count,

    r.reconciliation_status,

    case
        when q.quarantine_count = 0
         and r.reconciliation_status = 'PASS'
        then 'PASS'
        else 'FAIL'
    end as dq_status

from quarantine_check q
cross join reconciliation_check r

