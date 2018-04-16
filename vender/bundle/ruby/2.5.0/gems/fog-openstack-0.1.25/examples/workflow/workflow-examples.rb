require 'fog/openstack'
require 'fog/workflow/openstack/v2'

auth_url = "http://192.0.2.1:5000/v3/auth/tokens"
username = "admin"
password = "1b1d81f7e25b53e497246b168971823c5754f395"
project  = "admin"

@connection_params = {
  :openstack_auth_url     => auth_url,
  :openstack_username     => username,
  :openstack_api_key      => password,
  :openstack_project_name => project,
  :openstack_domain_id    => "default",
}

mistral = Fog::Workflow::OpenStack.new(@connection_params)

puts "INFO: create_execution"

workflow = "tripleo.plan_management.v1.create_default_deployment_plan"
input = { :container => 'default' }

response = mistral.create_execution(workflow, input)

puts response.body

state = response.body["state"]
workflow_execution_id = response.body["id"]
puts "INFO: state #{state} execution_id #{workflow_execution_id}"

while state == "RUNNING"
  sleep 5
  response = mistral.get_execution(workflow_execution_id)
  state = response.body["state"]
  workflow_execution_id = response.body["id"]
  puts "INFO: state #{state} execution_id #{workflow_execution_id}"
end

puts response.body

puts "INFO: list_executions"

response = mistral.list_executions

puts response.body

puts "INFO: update_execution"

response = mistral.update_execution(workflow_execution_id, "description",
                                    "changed description")
puts response.body

puts "INFO: list_tasks #{workflow_execution_id}"

response = mistral.list_tasks(workflow_execution_id)
task_ex_id = response.body["tasks"][0]["id"]
puts response.body

puts "INFO: get_task #{task_ex_id}"

response = mistral.get_task(task_ex_id)
puts response.body

puts "INFO: rerun_task #{task_ex_id}"

response = mistral.rerun_task(task_ex_id)
puts response.body

puts "INFO: delete_execution"

response = mistral.delete_execution(workflow_execution_id)
puts response.body

puts "INFO: create_action_execution"

input = { :container => 'default' }
response = mistral.create_action_execution("tripleo.get_capabilities", input)

puts response.body

puts "INFO: list_action_executions"

response = mistral.list_action_executions

puts response.body

puts "INFO: get_action_execution"

execution_id = response.body["id"]
response = mistral.get_action_execution(execution_id)

puts response.body

puts "INFO: create_workbook"

workbook_def = {
  :version => "2.0",
  :name => "workbook name",
  :description => "workbook description",
}
response = mistral.create_workbook(workbook_def)
workbook_name = response.body["name"]

puts response.body

puts "INFO: get_workbook"

response = mistral.get_workbook(workbook_name)

puts response.body

puts "INFO: list_workbooks"

response = mistral.list_workbooks

puts response.body

puts "INFO: update_workbook"

workbook_def = {
  :version => "2.0",
  :name => "workbook name",
  :description => "workbook description2",
}

response = mistral.update_workbook(workbook_def)

puts response.body

puts "INFO: get_workbook2"

response = mistral.get_workbook(workbook_name)

puts response.body

puts "INFO: validate_workbook"

response = mistral.validate_workbook(workbook_def)

puts response.body

puts "INFO: delete_workbook"

response = mistral.delete_workbook(workbook_name)
puts response.body

puts "INFO: create_workflow"

workflow_def = {
  :version => "2.0",
  :myworkflow => {
    :type        => "direct",
    :description => "description1",
    :tasks => {
      :create_vm => {
        :description => "create vm"
      }
    }
  }
}
response = mistral.create_workflow(workflow_def)
workflow_id = response.body["workflows"][0]["id"]

puts response.body

puts "INFO: get_workflow #{workflow_id}"

response = mistral.get_workflow(workflow_id)

puts response.body

puts "INFO: list_workflows"

response = mistral.list_workflows

puts response.body

puts "INFO: list_workflows with params"

params = { :limit => 1 }
response = mistral.list_workflows(params)
perm_workflow_id = response.body["workflows"][0]["id"]

puts response.body

puts "INFO: update_workflow"

workflow_def = {
  :version => "2.0",
  :myworkflow => {
    :type        => "direct",
    :description => "description2",
    :tasks => {
      :create_vm => {
        :description => "create vm"
      }
    }
  }
}
response = mistral.update_workflow(workflow_def)

puts response.body

puts "INFO: get_workflow2"

response = mistral.get_workflow(workflow_id)

puts response.body

puts "INFO: validate_workflow"

response = mistral.validate_workflow(workflow_def)

puts response.body

puts "INFO: delete_workflow #{workflow_id}"

response = mistral.delete_workflow(workflow_id)
puts response.body

puts "INFO: create_action"

action_def = {
  :version => "2.0",
  :myaction => {
    :input => ['execution_id'],
    :base  => "std.email",
    "base-input" => {
      :to_addrs      => ['admin@mywebsite.org'],
      :subject       => "subject1",
      :body          => "body1",
      :from_addr     => "mistral@openstack.org",
      :smtp_server   => "smtp.test.com",
      :smtp_password => "secret"
    }
  }
}
response = mistral.create_action(action_def)

puts response.body

puts "INFO: get_action"

action_name = "myaction"
response = mistral.get_action(action_name)

puts response.body

puts "INFO: list_actions"

response = mistral.list_actions

puts response.body

puts "INFO: list_actions with params"

params = { :limit => 1 }
response = mistral.list_actions(params)

puts response.body

puts "INFO: update_action"

action_def = {
  :version => "2.0",
  :myaction => {
    :input => ['execution_id'],
    :base  => "std.email",
    "base-input" => {
      :to_addrs      => ['admin@mywebsite.org'],
      :subject       => "subject updated",
      :body          => "body1",
      :from_addr     => "mistral@openstack.org",
      :smtp_server   => "smtp.test.com",
      :smtp_password => "secret"
    }
  }
}

response = mistral.update_action(action_def)

puts response.body

puts "INFO: get_action2"

response = mistral.get_action(action_name)

puts response.body

puts "INFO: validate_action"

response = mistral.validate_action(action_def)

puts response.body

puts "INFO: delete_action"

response = mistral.delete_action(action_name)
puts response.body

puts "INFO: create_cron_trigger #{perm_workflow_id}"

cron_name = "mycron"
workflow_input = { "container" => "test1" }
response = mistral.create_cron_trigger(cron_name,
                                       perm_workflow_id,
                                       workflow_input)

puts response.body

puts "INFO: get_cron_trigger"

response = mistral.get_cron_trigger(cron_name)

puts response.body

puts "INFO: list_cron_triggers"

response = mistral.list_cron_triggers

puts response.body

puts "INFO: delete_cron_trigger"

response = mistral.delete_cron_trigger(cron_name)

puts response.body

puts "INFO: create_environment"

environment_def = {
  "name" => "environment-1",
  "variables" => {
    "var1" => "value1",
    "var2" => "value2"
  }
}
response = mistral.create_environment(environment_def)
puts response.body

puts "INFO: get_environment"

environment_name = environment_def["name"]
response = mistral.get_environment(environment_name)

puts response.body

puts "INFO: list_environments"

response = mistral.list_environments

puts response.body

puts "INFO: update_environment"

environment_def = {
  "name" => "environment-1",
  "variables" => {
    "var1" => "value3",
    "var2" => "value4"
  }
}
response = mistral.update_environment(environment_def)

puts response.body

puts "INFO: get_environment2"

response = mistral.get_environment(environment_name)

puts response.body

puts "INFO: delete_environment"

response = mistral.delete_environment(environment_name)
puts response.body

#
# Services api is unsupported atm. Next call will fail.
#

puts "INFO: list_services"

response = mistral.list_services

puts response.body
