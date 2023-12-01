data "sops_file" "git_sync_secret" {
  source_file = "./modules/dbt/git-sync-credentials.secret.enc.json"
}