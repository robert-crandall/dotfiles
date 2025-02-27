#!/bin/zsh

function test_pr() {
  run_on_modified_files "bin/rails test"
}

function test_pr_emu() {
  run_on_modified_files "bin/rails test" "TEST_WITH_ALL_EMUS=1 bin/rails test"
}

function test_pr_features() {
  run_on_modified_files "bin/rails test" "TEST_ALL_FEATURES=1 bin/rails test"
}

function test_pr_all() {
  run_on_modified_files "bin/rails test" \
    "TEST_WITH_ALL_EMUS=1 bin/rails test" \
    "TEST_ALL_FEATURES=1 bin/rails test" \
    "TEST_WITH_ALL_EMUS=1 TEST_ALL_FEATURES=1 bin/rails test" \
    "MULTI_TENANT_ENTERPRISE=1 bin/rails test"
}

function test_all_on() {
  local file=$1
  bin/rails test $file
  TEST_WITH_ALL_EMUS=1 bin/rails test $file
  TEST_ALL_FEATURES=1 bin/rails test $file
  TEST_WITH_ALL_EMUS=1 TEST_ALL_FEATURES=1 bin/rails test $file
  MULTI_TENANT_ENTERPRISE=1 bin/rails test $file
}

function run_on_modified_files() {
  local -a commands=("$@")
  local -a test_files=($(gather_test_files))
  local -a failed_commands=()

  print_header "Running test on the following files:"
  for command in "${commands[@]}"; do
    for file in "${test_files[@]}"; do
      echo "$command $file"
    done
  done
  print_spaces

  for command in "${commands[@]}"; do
    for file in "${test_files[@]}"; do
      print_header "$command $file"
      eval "$command $file"
      if [[ $? -ne 0 ]]; then
        failed_commands+=("$command $file")
      fi
    done
  done

  print_header "Finished running the following tests"
  for command in "${commands[@]}"; do
    for file in "${test_files[@]}"; do
      echo "$command $file"
    done
  done
  print_spaces

  if (( ${#failed_commands[@]} > 0 )); then
    print_header "The following commands failed:"
    printf '%s\n' "${failed_commands[@]}"
  fi
}

function print_header() {
  echo
  local header="$*"
  echo "----------------------------------------"
  echo "$header"
  echo "----------------------------------------"
  echo
}

function print_spaces() {
  echo
  echo
}

function gather_test_files() {
  local -a modified_files=($(git diff --diff-filter=MA --name-only master...))
  local -a test_files=()
  local -a extra_test_files=()

  for file in "${modified_files[@]}"; do
    if [[ $file =~ _test\.rb$ ]]; then
      test_files+=("$file")
    else
      while IFS= read -r found_test_file; do
        [[ -n "$found_test_file" ]] && test_files+=("${found_test_file#./}")
      done < <(find_test_files "$file")
    fi
  done

  # Deduplicate test_files
  printf '%s\n' "${(u)test_files[@]}"
}

function find_test_files() {
  local file_path=$1
  if [[ $file_path =~ \.rb$ ]]; then
    local filename_without_path=${file_path##*/*/}
    local test_file=${filename_without_path%.rb}_test.rb
    find . -type f -wholename "*/$test_file"
  fi
}
