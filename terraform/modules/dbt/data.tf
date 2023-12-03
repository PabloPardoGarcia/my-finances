data "sops_file" "git_sync_secret" {
  source_file = "./secrets/git-sync-credentials.secret.enc.json"
}