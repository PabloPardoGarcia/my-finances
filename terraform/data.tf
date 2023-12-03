data "sops_file" "dockerconfig_secret" {
  source_file = "./secrets/dockerconfig.secret.enc.json"
}
