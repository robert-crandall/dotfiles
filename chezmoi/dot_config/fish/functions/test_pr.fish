function test_pr
  run_on_modified_files "bin/rails test"
end

function test_pr_emu
  run_on_modified_files "bin/rails test" "TEST_WITH_ALL_EMUS=1 bin/rails test"
end

function test_pr_features
  run_on_modified_files "bin/rails test" "TEST_ALL_FEATURES=1 bin/rails test"
end

function test_pr_all
  run_on_modified_files "bin/rails test" "TEST_WITH_ALL_EMUS=1 bin/rails test" "TEST_ALL_FEATURES=1 bin/rails test" "TEST_WITH_ALL_EMUS=1 TEST_ALL_FEATURES=1 bin/rails test" "MULTI_TENANT_ENTERPRISE=1 bin/rails test"
end

function all_tests
  set file $argv[1]
  bin/rails test $file
  TEST_WITH_ALL_EMUS=1 bin/rails test $file
  TEST_ALL_FEATURES=1 bin/rails test $file
  TEST_WITH_ALL_EMUS=1 TEST_ALL_FEATURES=1 bin/rails test $file
  MULTI_TENANT_ENTERPRISE=1 bin/rails test $file
end

function run_on_modified_files
  set commands $argv
  set test_files (gather_test_files)

  print_header "Running test on the following files:"
  for command in $commands
    for file in $test_files
      echo $command $file
    end
  end
  print_spaces

  for command in $commands
    for file in $test_files
      print_header $command $file
      eval $command $file
      if test $status -ne 0
        set failed_commands $failed_commands "$command $file"
      end
    end
  end

  print_header "Finished running the following tests"
  for command in $commands
    for file in $test_files
      echo $command $file
    end
  end
  print_spaces

  if set -q failed_commands[1]
    print_header "The following commands failed:"
    for failed_command in $failed_commands
      echo $failed_command
    end
  end
end

function print_header
  echo ""
  set header $argv
  echo "----------------------------------------"
  echo $header
  echo "----------------------------------------"
  echo ""
end

function print_spaces
  echo ""
  echo ""
end

function gather_test_files
  set modified_files (git diff --diff-filter=MA --name-only master...)
  set test_files

    for file in $modified_files
      if string match -q -- '*_test.rb' $file
        # echo "Test file changed in PR: $file"
        set test_files $test_files $file
      else
        # echo "found non-test file $file"
        set extra_test_files (find_test_files $file)
        for found_test_file in $extra_test_files
          # echo "Extra test found: $found_test_file"
          set git_diff_format (string replace -r "^./" "" -- $found_test_file)
          set test_files $test_files $git_diff_format
        end
      end
    end

  # Deduplicate test_files
  set test_files (printf "%s\n" $test_files | sort | uniq)

  # Return test_files
  for test_file in $test_files
    echo $test_file
  end
end

function find_test_files
  set path $argv
  if string match -q -- '*.rb' $path
    set new_path (string replace -r '.*/([^/]*/.*\.rb)' '$1' -- $path)
    set test_file (string replace ".rb" "_test.rb" -- $new_path)
    find . -type f -wholename "*/$test_file"
  end
end
