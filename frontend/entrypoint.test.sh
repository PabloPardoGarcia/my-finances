#echo "Running PyTest tests ..."
#pytest tests/ -v

echo "Running iSort checks ..."
isort ./ -c

echo "Running Black checks ..."
black ./ --check

echo "Done!!"