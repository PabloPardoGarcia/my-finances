echo "Running YAML linter checks ..."
yamllint -f github --no-warnings .

echo "Running SQLFluff checks ..."
sqlfluff lint ./models/

echo "Done!"