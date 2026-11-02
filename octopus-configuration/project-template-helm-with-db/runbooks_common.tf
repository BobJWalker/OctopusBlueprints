# Shared values used by the runbook files (runbook_*.tf) and the deployment process
locals {
  runbook_connectivity = {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  key_vault_properties = {
    "KeyVault.Template.Vault.Name"                         = "#{KeyVault.Azure.Name}"
    "KeyVault.Template.Secrets.List"                       = "#{KeyVault.Azure.Secrets.List}"
    "KeyVault.Template.Worker.Pool"                        = "#{Core.Worker.Pool}"
    "KeyVault.Template.ExecutionContainer.Feed"            = var.container_feed_id
    "Octopus.Action.ProcessTemplate.Reference.Slug"        = "key-vault-retrieve-secrets"
    "Octopus.Action.ProcessTemplate.Reference.VersionMask" = var.process_template_version_masks["key-vault-retrieve-secrets"]
  }

  sql_properties = {
    "Template.SQLServer.Name"          = "#{KeyVault.SQLServer.Server.Name}"
    "Template.SQLServer.User.Name"     = "#{KeyVault.SQLServer.User.Name}"
    "Template.SQLServer.User.Password" = "#{KeyVault.SQLServer.User.Password}"
    "Template.SQLServer.Database.Name" = "#{Standards.Database.Name}"
    "Template.WorkerPool"              = "#{Core.Worker.Pool}"
  }

  notify_properties = {
    "Template.EmailTeam"                                   = var.notification_team_id
    "Octopus.Action.ProcessTemplate.Reference.Slug"        = "notification-emails"
    "Octopus.Action.ProcessTemplate.Reference.VersionMask" = var.process_template_version_masks["notification-emails"]
  }
}
