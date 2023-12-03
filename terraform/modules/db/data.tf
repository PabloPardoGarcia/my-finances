data "sops_file" "db_secret" {
  source_file = "./secrets/db.secret.enc.json"
}
