import os
import sys
import csv
from datetime import datetime, timezone

from dotenv import load_dotenv
from google.cloud import bigquery, storage

from schemas import SCHEMAS

load_dotenv()

PROJECT_ID = os.environ["GCP_PROJECT_ID"]
BUCKET = os.environ["GCS_BUCKET"]
DATASET = os.environ.get("BQ_DATASET_RAW", "raw")
LOCAL_DIR = "data/raw"

bq = bigquery.Client(project=PROJECT_ID)
gcs = storage.Client(project=PROJECT_ID)


def count_source_rows(path):
    with open(path, "r", encoding="utf-8") as fh:
        reader = csv.reader(fh)
        next(reader, None)
        return sum(1 for _ in reader)


def upload_to_gcs(local_path, blob_name):
    bucket = gcs.bucket(BUCKET)
    blob = bucket.blob(blob_name)
    blob.upload_from_filename(local_path)
    return f"gs://{BUCKET}/{blob_name}"


def load_table(table_name, spec):
    local_path = os.path.join(LOCAL_DIR, spec["file"])
    if not os.path.exists(local_path):
        print(f"MISSING {local_path}")
        return False

    expected = count_source_rows(local_path)
    uri = upload_to_gcs(local_path, f"olist/{spec['file']}")

    schema = list(spec["schema"]) + [
        bigquery.SchemaField("_loaded_at", "TIMESTAMP")
    ]

    staging_table = f"{PROJECT_ID}.{DATASET}.{table_name}_tmp"
    final_table = f"{PROJECT_ID}.{DATASET}.{table_name}"

    job_config = bigquery.LoadJobConfig(
        schema=list(spec["schema"]),
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
        write_disposition="WRITE_TRUNCATE",
        allow_quoted_newlines=True,
        max_bad_records=0,
    )

    job = bq.load_table_from_uri(uri, staging_table, job_config=job_config)
    job.result()

    loaded_at = datetime.now(timezone.utc).isoformat()
    cols = ", ".join(field.name for field in spec["schema"])
    sql = f"""
    CREATE OR REPLACE TABLE `{final_table}` AS
    SELECT {cols}, TIMESTAMP('{loaded_at}') AS _loaded_at
    FROM `{staging_table}`
    """
    bq.query(sql).result()
    bq.delete_table(staging_table, not_found_ok=True)

    actual = bq.get_table(final_table).num_rows
    status = "OK" if actual == expected else "MISMATCH"
    print(f"{status:9} {table_name:32} expected={expected:>8} loaded={actual:>8}")
    return actual == expected


def main():
    results = []
    for table_name, spec in SCHEMAS.items():
        results.append(load_table(table_name, spec))
    print("-" * 70)
    print(f"{sum(results)}/{len(results)} tables loaded and row-count verified")
    if not all(results):
        sys.exit(1)


if __name__ == "__main__":
    main()