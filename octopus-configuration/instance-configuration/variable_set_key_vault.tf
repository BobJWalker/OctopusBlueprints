resource "octopusdeploy_library_variable_set" "key_vault" {
  name        = "Key Vault"
  description = "Set of common key vault names and output variable names to use for runbooks and deployments."
}

locals {
  key_vault_variables = {
    "KeyVault.Azure.Secrets.List" = {
      type = "String"
      # Format: <key vault secret name> | <output variable name> | <default value>
      value = join("\n", [
        "azure-sql-server | SQLServerName | 127.0.0.1",
        "azure-sql-password | SQLUserPassword | Octopus_Deploy",
        "azure-sql-username | SQLUserName | Password01!",
        "octopus-api-key | OctopusApiKey | blah",
        "github-token | GitHubToken | blah",
        "sumo-logic-url | SumoLogicUrl | blah",
        "slack-notifications | SlackWebhookUrl | blah",
      ])
    }
    "KeyVault.GitHub.Token" = {
      type  = "String"
      value = "#{Octopus.Action[Key Vault-Set Output Variables].Output.GitHubToken}"
    }
    "KeyVault.Octopus.Api.Key" = {
      type  = "String"
      value = "#{Octopus.Action[Key Vault-Set Output Variables].Output.OctopusApiKey}"
    }
    "KeyVault.Slack.Webhook.Url" = {
      type  = "String"
      value = "#{Octopus.Action[Key Vault-Set Output Variables].Output.SlackWebhookUrl}"
    }
    "KeyVault.SQLServer.Server.Name" = {
      type  = "String"
      value = "#{Octopus.Action[Key Vault-Set Output Variables].Output.SQLServerName}"
    }
    "KeyVault.SQLServer.User.Name" = {
      type  = "String"
      value = "#{Octopus.Action[Key Vault-Set Output Variables].Output.SQLUserName}"
    }
    "KeyVault.SQLServer.User.Password" = {
      type  = "String"
      value = "#{Octopus.Action[Key Vault-Set Output Variables].Output.SQLUserPassword}"
    }
    "KeyVault.Sumologic.Url" = {
      type  = "String"
      value = "#{Octopus.Action[Key Vault-Set Output Variables].Output.SumoLogicUrl}"
    }
    "KeyVault.SQLServer.Connection.String" = {
      type  = "String"
      value = "Server=tcp:#{KeyVault.SQLServer.Server.Name},1433;Database=#{Standards.Database.Name};User Id=#{KeyVault.SQLServer.User.Name};Password=#{KeyVault.SQLServer.User.Password};TrustServerCertificate=True;Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;"
    }
  }
}

resource "octopusdeploy_variable" "key_vault" {
  for_each = local.key_vault_variables

  owner_id = octopusdeploy_library_variable_set.key_vault.id
  name     = each.key
  type     = each.value.type
  value    = each.value.value
}
