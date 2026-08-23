# Query Cost Benchmark: Partitioning and Clustering

## Setup

Two physically identical tables built from the same GA4 source over
2020-12-01 to 2021-01-31.

- `stg_ga4__events_unpartitioned`: no partitioning, no clustering
- `stg_ga4__events`: partitioned daily on `event_date`, clustered on
  `event_name` and `user_pseudo_id`

Bytes billed captured from
`region-us.INFORMATION_SCHEMA.JOBS_BY_PROJECT`, not from the pre-run
estimate. Clustering benefits are invisible in the estimate.

## Results

| Query | Pattern | Unpartitioned | Partitioned + Clustered | Reduction |
|-------|---------|---------------|-------------------------|-----------|
| A | 7-day aggregation | X.XX GB | X.XX GB | XX% |
| B | 14-day, 3 event types | X.XX GB | X.XX GB | XX% |
| C | Single user, 31-day window | X.XX GB | X.XX GB | XX% |
| **Total** | | **X.XX GB** | **X.XX GB** | **XX%** |

At BigQuery on-demand pricing of $6.25 per TB, this is $X.XX against
$X.XX for these three queries. Extrapolated to a workload of 500 such
queries per day, the annual difference is approximately $X,XXX.

## Interpretation

Partition pruning accounts for most of the reduction on A and B, since
both filter to a subset of the date range. Clustering contributes
additionally on B by skipping blocks not containing the target event
names, and dominates on C, where a single user's rows occupy a small
number of physical blocks.

`require_partition_filter=true` is set on the partitioned table so that
an unfiltered scan is rejected rather than silently expensive.

## Limitation

The Olist marts are partitioned and clustered for consistency, but at
roughly 99,000 rows they sit below BigQuery's minimum billing threshold
of 10 MB per query. No measurable saving is claimed there.