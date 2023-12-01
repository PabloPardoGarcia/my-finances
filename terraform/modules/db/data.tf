data "sops_file" "db_secret" {
  source_file = "./modules/db/db.secret.enc.json"
}
