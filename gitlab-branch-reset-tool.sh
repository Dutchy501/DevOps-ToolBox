#!/bin/bash

read -p "Enter the GitLab URL: " GITLAB
read -s -p "Enter your authentication token: " TOKEN
echo

CFG_FILE="projects_to_fix.cfg"

APPLY=false

case "$1" in
  -y|--yes)
    APPLY=true
    ;;
esac

echo "Apply mode: $APPLY"
echo

if $APPLY; then
  read -p "Are you sure you want to update ALL projects to 'main'? (y/N): " CONFIRM
  if [[ "$CONFIRM"  != "y" ]]; then
    echo "Aborted"
    exit 1
  fi
  echo
fi

while IFS='=' read -r PROJECT_ID BRANCH; do
  [[ -z "$PROJECT_ID" ]] && continue

  if [[ "$BRANCH" == "main" ]]; then
    echo "Skipping $PROJECT_ID - already main"
    continue
  fi

  printf "Project: %10s Current: %-20s" "$PROJECT_ID" "$BRANCH"

  if $APPLY; then
    RESPONSE=$(curl --silent --show-error \
      --output /dev/null \
      --write-out "%{http_code}" \
      --request PUT \
      --header "PRIVATE-TOKEN: $TOKEN" \
      --data "default_branch=main" \
      "$GITLAB/api/v4/projects/$PROJECT_ID")

    HTTP_CODE="${RESPONSE: -3}"

    if [[ "$HTTP_CODE" == "200" ]]; then
      echo " -> project updated."
    else
      echo " -> Failed (HTTP $HTTP_CODE)"
    fi

  else
    echo " -> [DRY RUN]"
  fi

done < "$CFG_FILE"

