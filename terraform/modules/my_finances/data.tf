data "sops_file" "db_secret" {
  source_file = "./modules/my_finances/db.secret.enc.json"
}

data "sops_file" "git_sync_secret" {
  source_file = "./modules/my_finances/git-sync-credentials.secret.enc.json"
}
