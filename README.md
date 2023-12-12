# My Finances

[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![Imports: isort](https://img.shields.io/badge/%20imports-isort-%231674b1?style=flat&labelColor=ef8336)](https://pycqa.github.io/isort/)

## Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
  - [Secrets Encoding](#secrets-encoding)
  - [Database Format](#database-format)
  - [Build and Publish Images](#build-and-publish-images)
  - [Terraform Secrets](#terraform-secrets)
  - [Terraform](#terraform)
- [Deployment](#deployment)
- [Testing](#testing)

## Introduction

Welcome to My Finances repository!

```mermaid
---
title: Architecture Diagram
---
flowchart LR
    subgraph dbt
        direction TB
        s1[[dbt service]];
        web1([dbt docs]);
        web2([dbt api docs]);
        s1 --> web1
        s1 --> web2
    end
    subgraph frontend
        direction TB
        s4[["Streamlit App"]];
        web3(["webapp"]);
        s4 --> web3
    end
    subgraph db [backend db]
        db1[(postgres)];
    end
    subgraph backend
        direction TB
        s3[["FastAPI service"]];
        web4(["api docs"]);
        s3 --> web4
    end

    frontend --> backend
    backend -- INSERT--> db
    frontend -- READ --> db
    dbt -- TRANSFORM --> db
    backend --> dbt

    %% Interactions
    click web1 "https://docs.getdbt.com/docs/collaborate/documentation" _blank
    click web3 "https://docs.streamlit.io/" _blank
    click web4 "https://fastapi.tiangolo.com/#interactive-api-docs" _blank

```

## Prerequisites

Before you can deploy this project, you'll need the following:

- A Kubernetes cluster up and running. The repo has only been tested with a local k8s cluster created by Docker.
- `docker`, `terraform`, `kubectl` to deploy the project in the local cluster
- [`sops`](https://github.com/getsops/sops) and [`age`](https://github.com/FiloSottile/age) to encrypt kubernetes secrets
- GitHub Container Registry

## Configuration

### Secrets Encoding

This repo encodes its secrets with [sops with age](https://github.com/getsops/sops#encrypting-using-age). 
Update [`.sops.yaml`](terraform/.sops.yaml) with your own age recipient.

### Database Format

This repo expects the transaction data to be in the same format as the one provided by ING-DiBa.
To use it with transaction data with other format:

- Update [`init.sql`](db/init.sql) script to create the initial tables with your specific format.
- Modify [dbt source model](dbt/my_finances/models/staging/src_ing.yml) accordingly
- Modify downstream dbt models if needed

### Build and Publish images

Build and publish docker images for the api, dbt and frontend services:

```shell
cd dbt
docker build -f Dockerfile -t ghcr.io/<yourusername>/my-finances-dbt:latest .
docker push ghcr.io/<yourusername>/my-finances-dbt:latest
```

```shell
cd api
docker build -f Dockerfile -t ghcr.io/<yourusername>/my-finances-api:latest .
docker push ghcr.io/<yourusername>/my-finances-api:latest
```

```shell
cd frontend
docker build -f Dockerfile -t ghcr.io/<yourusername>/my-finances-frontend:latest .
docker push ghcr.io/<yourusername>/my-finances-frontend:latest
```

### Terraform Secrets

#### GitHub Container Registry

1. Create GitHub Personal Access Token (PAT)
2. Write secret `./terraform/secrets/dockerconfig.secret.json`:
    ```json
    {
      "username": "<GitHub Username>",
      "github_pat": "<GitHub PAT>"
    }
    ```
3. Encode file with sops:
    ```shell
    cd terraform/secrets
    sops -e dockerconfig.secret.json > dockerconfig.secret.enc.json 
    ```

#### Database Credentials

1. Create file `./terraform/secrets/db.secret.json`:
    ```json
    {
      "password": "example",
      "user": "example",
      "db": "myfinances"
    }
    ```
2. Encode file with sops:
     ```shell
    cd terraform/secrets
    sops -e db.secret.json > db.secret.enc.json 
    ```

### Terraform

1. Update kubernetes provider to match your own cluster configuration
2. Update deployments configuration:
   - Replace variable [`git_sync_git_repo`](terraform/main.tf) to match your own repo
   - Replace node name where to deploy the local storage in [`pv_node_names`](terraform/main.tf)

## Deployment

Run the following terraform commands to deploy the applications on your k8s cluster:

```shell
terraform init
terraform plan
terraform apply
```

## Testing

The project is tested with GitHub Actions. For the workflows to work on a forked repository
you need to add these GitHub secrets: 

- **Docker credentials**
  - `DOCKER_REPOSITORY`: Docker Repository where to push and pull images from (e.g. `ghcr.io` tu publish in GitHub Container Registry)
  - `DOCKER_USERNAME`: Docker username to login into the repository (e.g. `pablopardogarcia` or your GitHub username to publish in GHCR)
  - `DOCKER_PASSWORD`: Docker password to login into the repository (e.g. your GitHub Personal Access Token to publish in GHCR)
- **Postgres credentials**
  - `POSTGRES_HOST`: Postgres server host
  - `POSTGRES_USER`: Postgres user
  - `POSTGRES_PASSWORD`: Postgres password
  - `POSTGRES_DB`: Postgres database name
