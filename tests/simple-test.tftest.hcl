# Simple test to verify Terraform test framework works

run "simple_variable_test" {
  command = plan

  variables {
    project_name = "test-project"
    environment  = "test"
  }

  assert {
    condition     = var.project_name == "test-project"
    error_message = "Project name should be test-project"
  }

  assert {
    condition     = var.environment == "test"
    error_message = "Environment should be test"
  }
}