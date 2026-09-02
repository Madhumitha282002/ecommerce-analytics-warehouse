#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

cd ecom_warehouse
dbt docs generate
cd ..

mkdir -p docs_site
cp ecom_warehouse/target/index.html docs_site/
cp ecom_warehouse/target/manifest.json docs_site/
cp ecom_warehouse/target/catalog.json docs_site/
touch docs_site/.nojekyll

echo "Docs staged in docs_site/. Commit and push to publish."
