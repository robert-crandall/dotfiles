#!/bin/zsh

function start_server() {
  local max_retries=3
  local retry_count=0
  local wait_time=60

  while [[ $retry_count -lt $max_retries ]]; do
    first_start=true

    if [[ $retry_count -gt 0 ]]; then
      first_start=false
    fi
    
    echo "Checking if server is running (attempt $((retry_count + 1))/$max_retries)..."
    
    if service --status-all | grep -Fq 'nginx'; then
      echo "✅ Server logs look good, no errors found."
      return 0
    else
      if [[ $first_start == true ]]; then
        echo "Attempting to start the server"
      else
        echo "⚠️ Server did not start properly. Restarting server..."
      fi
      script/dx/server-start
      
      echo "Waiting $wait_time seconds before checking again..."
      sleep $wait_time
      
      ((retry_count++))
    fi
  done

  echo "❌ Maximum retry attempts reached. Please check the server manually."
  return 1
}
