data "sops_file" "db-secret" {
  source_file = "./modules/my_finances/db.secret.enc.json"
}
