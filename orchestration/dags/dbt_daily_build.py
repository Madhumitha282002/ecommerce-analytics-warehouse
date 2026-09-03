import os
import json
import urllib.request
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

def notify_slack_failure(context):
    webhook = os.environ.get("SLACK_WEBHOOK_URL")
    if not webhook:
        return
    task = context["task_instance"]
    payload = {
        "text": (
            f":red_circle: *Warehouse refresh failed*\n"
            f"DAG: `{task.dag_id}`\n"
            f"Task: `{task.task_id}`\n"
            f"Run: `{context['run_id']}`\n"
            f"Log: {task.log_url}"
        )
    }
    req = urllib.request.Request(
        webhook,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
    )
    urllib.request.urlopen(req)

default_args = {
    'owner': 'airflow',
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'on_failure_callback': notify_slack_failure
}

dag = DAG(
    'dbt_daily_build',
    default_args=default_args,
    schedule_interval='@daily',
    start_date=datetime(2024, 1, 1),
    catchup=False
)

dbt_build = BashOperator(
    task_id='dbt_build',
    bash_command='cd /opt/airflow/dbt && dbt build',
    dag=dag
)