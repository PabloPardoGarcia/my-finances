data "sops_file" "db-secret" {
  source_file = "./modules/my_finances/db.secret.enc.json"
}

data "sops_file" "git-sync-secret" {
  source_file = "./modules/my_finances/git-sync-credentials.secret.enc.json"
}
