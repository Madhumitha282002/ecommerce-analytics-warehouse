from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.sensors.filesystem import FileSensor
from airflow.utils.task_group import TaskGroup

DBT_DIR = "/opt/airflow/dbt"
DBT_PROFILES = "/opt/airflow/.dbt"

default_args = {
    "owner": "madhumitha",
    "depends_on_past": False,
    "email_on_failure": True,
    "email": ["your-email@example.com"],
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "retry_exponential_backoff": True,
    "max_retry_delay": timedelta(minutes=30),
}


def report_run_summary(**context):
    run_id = context["run_id"]
    logical_date = context["logical_date"]
    print(f"Warehouse refresh complete. run_id={run_id} date={logical_date}")


with DAG(
    dag_id="ecommerce_warehouse_refresh",
    description="Daily ELT: ingest Olist to BigQuery, transform with dbt, test",
    default_args=default_args,
    start_date=datetime(2026, 8, 1),
    schedule="0 6 * * *",
    catchup=False,
    max_active_runs=1,
    tags=["bigquery", "dbt", "elt"],
) as dag:

    check_source_files = FileSensor(
        task_id="check_source_files",
        filepath="/opt/airflow/ingest/../data/raw/olist_orders_dataset.csv",
        poke_interval=60,
        timeout=600,
        mode="poke",
    )

    ingest_to_bigquery = BashOperator(
        task_id="ingest_to_bigquery",
        bash_command=(
            "cd /opt/airflow/ingest && "
            "GOOGLE_APPLICATION_CREDENTIALS=/opt/airflow/gcp/dbt-runner-key.json "
            "python load_to_bq.py"
        ),
    )

    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=f"cd {DBT_DIR} && dbt deps --profiles-dir {DBT_PROFILES}",
    )

    check_source_freshness = BashOperator(
        task_id="check_source_freshness",
        bash_command=(
            f"cd {DBT_DIR} && "
            f"dbt source freshness --profiles-dir {DBT_PROFILES}"
        ),
    )

    with TaskGroup(group_id="transform") as transform:

        dbt_run_staging = BashOperator(
            task_id="dbt_run_staging",
            bash_command=(
                f"cd {DBT_DIR} && "
                f"dbt run --select staging --profiles-dir {DBT_PROFILES}"
            ),
        )

        dbt_test_staging = BashOperator(
            task_id="dbt_test_staging",
            bash_command=(
                f"cd {DBT_DIR} && "
                f"dbt test --select staging --profiles-dir {DBT_PROFILES}"
            ),
        )

        dbt_run_marts = BashOperator(
            task_id="dbt_run_marts",
            bash_command=(
                f"cd {DBT_DIR} && "
                f"dbt run --select marts --profiles-dir {DBT_PROFILES}"
            ),
        )

        dbt_test_marts = BashOperator(
            task_id="dbt_test_marts",
            bash_command=(
                f"cd {DBT_DIR} && "
                f"dbt test --select marts --profiles-dir {DBT_PROFILES}"
            ),
        )

        dbt_run_staging >> dbt_test_staging >> dbt_run_marts >> dbt_test_marts

    generate_docs = BashOperator(
        task_id="generate_docs",
        bash_command=(
            f"cd {DBT_DIR} && "
            f"dbt docs generate --profiles-dir {DBT_PROFILES}"
        ),
    )

    notify_completion = PythonOperator(
        task_id="notify_completion",
        python_callable=report_run_summary,
    )

    (
        check_source_files
        >> ingest_to_bigquery
        >> dbt_deps
        >> check_source_freshness
        >> transform
        >> generate_docs
        >> notify_completion
    )