#!/bin/bash
set -e

echo "==== SystemPoolFailure Prereqs ===="
echo ""

test_result=0
failed_tests=()

# Test function - runs a command and checks its exit status
run_test() {
  local test_name="$1"
  local command="$2"
  local skip_if_failed="$3"

  if [ "$skip_if_failed" = "true" ] && [ $test_result -ne 0 ]; then
    echo "⏩ SKIPPED: $test_name (previous test failed)"
    return
  fi

  echo -n "🧪 Testing: $test_name ... "
  if eval "$command &>/dev/null"; then
    echo "✅ PASSED"
    return 0
  else
    echo "❌ FAILED"
    test_result=1
    failed_tests+=("$test_name")
    return 1
  fi
}

# Check if Azure CLI is installed and user is logged in
run_test "Azure CLI installation" "az version" "false"
run_test "Azure login status" "az account show --query name -o tsv" "false"

# Check Terraform installation
run_test "Terraform installation" "terraform version" "false"

# Check if kubectl is installed
run_test "kubectl installation" "kubectl version --client=true" "false"

# Check if Helm is installed
run_test "Helm installation" "helm version --short" "false"

# Check if kubelogin is installed
run_test "kubelogin installation" "kubelogin --version" "false"

# Check if Azure CLI aks-preview extension is installed
run_test "Azure CLI aks-preview extension" "az extension show --name aks-preview" "false"

# Check if AutomaticSKUPreview feature is registered
run_test "AutomaticSKUPreview feature registration" "az feature show --namespace Microsoft.ContainerService --name AutomaticSKUPreview --query properties.state -o tsv | grep -q 'Registered'" "false"

# Check if Microsoft.ContainerService provider is registered
run_test "Microsoft.ContainerService provider registration" "az provider show --namespace Microsoft.ContainerService --query registrationState -o tsv | grep -q 'Registered'" "false"

echo ""
echo "==== Test Summary ===="
if [ ${#failed_tests[@]} -eq 0 ]; then
  echo "✅ All tests passed successfully!"
else
  echo "❌ ${#failed_tests[@]} tests failed:"
  for failed_test in "${failed_tests[@]}"; do
    echo "  - $failed_test"
  done
  echo ""
  echo "Please fix these issues before proceeding."
fi

echo ""
echo "Testing completed at $(date)"
exit $test_result