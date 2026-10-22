resource "octopusdeploy_library_variable_set" "notification" {
  name        = "Notification"
  description = "Set of common variables to use for slack and email notifications."
}

locals {
  notification_variables = {
    "Notification.Subject.Text"                   = "#{Octopus.Project.Name} #{Octopus.Release.Number} to #{Octopus.Environment.Name} has #{if Octopus.Deployment.Error}failed#{else}completed successfully#{/if}"
    "Notification.DeploymentStatus.Subject.Text"  = "#{Octopus.Project.Name} #{Octopus.Release.Number} to #{Octopus.Environment.Name} has #{if Octopus.Deployment.Error}failed#{else}completed successfully#{/if}"
    "Notification.RunbookStatus.Subject.Text"     = "#{Octopus.Project.Name} #{Octopus.Runbook.Name} to #{Octopus.Environment.Name} has #{if Octopus.Deployment.Error}failed#{else}completed successfully#{/if}"
    "Notification.ManualIntervention.Subject.Text" = "#{Octopus.Project.Name} #{Octopus.Release.Number} to #{Octopus.Environment.Name} has paused and is awaiting review."
    "Notification.Body.Text"                      = "You can view the task here: #{Octopus.Web.ServerUri}/app#/#{Octopus.Space.Id}/tasks/#{Octopus.Task.Id}"
    "Notification.Title.Text"                     = "#{Octopus.Project.Name} #{if Octopus.Runbook.Id}#{Octopus.Runbook.Name}#{else}#{Octopus.Release.Number}#{/if} to #{Octopus.Environment.Name}#{if Octopus.Deployment.Tenant.Name} for #{Octopus.Deployment.Tenant.Name}#{else}#{if Octopus.Runbook.Tenant.Name} for #{Octopus.Runbook.Tenant.Name}#{/if}#{/if} has #{if Template.ManualIntervention}paused and waiting intervention#{else}#{if Octopus.Deployment.Error}failed#{else}completed successfully#{/if}#{/if}"
    "Notification.Slack.Channel.Name"             = "feed-bob-local"
  }
}

resource "octopusdeploy_variable" "notification" {
  for_each = local.notification_variables

  owner_id = octopusdeploy_library_variable_set.notification.id
  name     = each.key
  type     = "String"
  value    = each.value
}
