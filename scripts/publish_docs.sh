#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

cd ecom_warehouse
dbt docs generate
cd ..

mkdir -p docs
cp ecom_warehouse/target/index.html docs/
cp ecom_warehouse/target/manifest.json docs/
cp ecom_warehouse/target/catalog.json docs/
touch docs/.nojekyll

echo "Docs staged in docs/. Commit and push to publish."
