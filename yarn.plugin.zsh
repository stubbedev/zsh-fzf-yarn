# Custom completion for yarn run to use fzf-tab with package.json scripts
_yarn_run_completions() {
  # Extract scripts from package.json using jq, and use fzf-tab for fuzzy completion
  local scripts
  scripts=$(jq -r '.scripts | keys_unsorted | .[]' package.json | fzf --select-1 --exit-0)

  if [[ -n "$scripts" ]]; then
    # If a script is selected, complete it
    reply=($scripts)
  fi
}

# Associate the custom function with yarn run
compdef _yarn_run_completions='yarn run'

# Custom completion for yarn (including both built-in commands and package.json scripts)
_yarn_completions() {
  # Get built-in yarn commands
  local yarn_commands
  yarn_commands=$(yarn --help | grep -oP '^\s+\K[a-z-]+' | sort)

  # Get package.json scripts (only if package.json exists)
  local package_json_scripts
  if [[ -f "package.json" ]]; then
    package_json_scripts=$(jq -r '.scripts | keys_unsorted | .[]' package.json)
  fi

  # Combine both built-in yarn commands and package.json scripts
  local all_commands
  all_commands="$yarn_commands"$'\n'"$package_json_scripts"

  # Use fzf for fuzzy matching
  local selected_command
  selected_command=$(echo "$all_commands" | fzf --preview 'echo {}' --select-1 --exit-0)

  if [[ -n "$selected_command" ]]; then
    reply=($selected_command) # This will complete the selected command
  fi
}

# Associate the custom completion with bare yarn
compdef _yarn_completions='yarn'
