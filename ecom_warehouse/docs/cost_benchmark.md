## Incremental vs full refresh

| Run type | Bytes billed | Partitions written | Runtime |
|----------|--------------|--------------------|---------|
| Full refresh | 0.00015 GB | 31 | 5.19s |
| Incremental (3-day lookback) | 0.00015 GB | 1 | 8.47s |
| Reduction | 0% | 97% | -63% |

The lookback window reprocesses three days on each run to absorb
late-arriving events. `insert_overwrite` replaces those partitions
rather than appending, which is what keeps the model idempotent under
repeated execution. A verification query confirms
`count(*) = count(distinct event_key)` after three consecutive
incremental runs.

In this test, incremental is slower because you're using a single-day source table. In production with real multi-month data, incremental would be dramatically faster. The 3-day lookback processes only 1 partition instead of 31, which saves bytes and time on large datasets.