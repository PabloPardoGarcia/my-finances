# My Finances

## Table of Contents
- [Introduction](#introduction)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Configuration](#configuration)
  - [Deployment](#deployment)

## Introduction

Welcome to My Finances repository!

```mermaid
---
title: Architecture Diagram
---
flowchart TB
    %% Graph definition
    subgraph my-finances
        subgraph dbt
            s1[[dbt-docs service]];
            web1([dbt documantation]);
            s2[[git-sync]];
            s1 --> web1
            s2 <--> s1
        end
        subgraph uploader
            s3[["uploader service"]]
            web3(["uploader UI"]);
            s3 --> s1
            web3 <--> s3
        end
        db1[(postgres)];
        s1 --> db1
        s3 --> db1
        
    end
    subgraph lightdash
        sb2[(internal db)];
        s4[[lightdash server]];
        web2([Lightdash web]);
        sb2 <--> s4 
        s4 --> web2
    end
    db1 --> s4
    
    %% Interactions
    click web1 "https://docs.getdbt.com/docs/collaborate/documentation" _blank
    click web2 "https://www.lightdash.com/" _blank
    
    %% Styling
    classDef todoclass fill:#f96,stroke:#f50
```

## Getting Started

### Prerequisites

Before you can deploy this project, you'll need the following:

- A Kubernetes cluster up and running. The repo has only been tested with a local k8s cluster created by Docker.
- `docker`, `terraform`, `kubectl` to deploy the project in the local cluster
- [`sops`](https://github.com/getsops/sops) and [`age`](https://github.com/FiloSottile/age) to encrypt kubernetes secrets

### Configuration

1. Fork and clone this repo to your local machine:

    ```shell
   git clone https://github.com/yourusername/my-financea.git
   cd my-finances
   ```

2. Configure extract data format. Each bank formats the transactions statement slightly different.
   - Update [`init.sql`](db/init.sql) script to create the initial tables with your specific format.
   - Modify [dbt source model](dbt/my_finances/models/staging/ing/src_ing.yml) accordingly
   - Modify downstream dbt models if needed

3. Build dbt and uploader docker images:

   ```shell
   cd dbt
   docker build -f Dockerfile -t my-finances-dbt .
   ```
   
    ```shell
   cd uploader
   docker build -f Dockerfile -t my-finances-uploader .
   ```

4. Configure [sops with age](https://github.com/getsops/sops#encrypting-using-age). 
   Update [`.sops.yaml`](terraform/.sops.yaml) with your own age recipient
    
5. Configure terraform
   1. Update kubernetes provider to match your own cluster configuration
   2. Update deployments configuration:
      - Replace variable [`git_sync_git_repo`](terraform/main.tf) to match your own repo
      - Replace node name where to deploy the local storage in [`pv_node_names`](terraform/modules/my_finances/main.tf)
      - Update modules `my-finances` and `lightdash` to match your needs

### Deployment

Run the following terraform commands to deploy the applications on your k8s cluster:

```shell
terraform init
terraform plan
terraform apply
```
