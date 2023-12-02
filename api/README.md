# API

This module allows communication with My Finances via API.

## Build Image

Run this command to build the image of the FastAPI service:

```shell
docker build -f Dockerfile -t my-finances-api .
```

## Test Locally

To run the tests on the API, you need to create an `.env` file like this:
```shell
echo "POSTGRES_HOST=<postgres host>" >> .env
echo "POSTGRES_USER=<postgres user>" >> .env
echo "POSTGRES_PASSWORD=<postgres password>" >> .env
echo "POSTGRES_DB=<postgres database name>" >> .env
```

Then build the testing image and run it::

```shell
docker build -f Dockerfile --target test my-finances-api:test .
docker run --env-file .env my-finances-api:test
```