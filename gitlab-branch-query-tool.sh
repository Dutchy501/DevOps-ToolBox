#!/bin/bash

read -p "Enter the GitLab URL: " GITLAB
read -s -p "Enter your authentication token: " TOKEN
echo
read -p "Enter the group path (example my-groups/test-groups): " GROUP_PATH


echo " Token length: ${#TOKEN}"
echo " Gitlab url: $GITLAB"
QUERY=$(jq -n --arg gp "$GROUP_PATH" '{
"query": "query($fullPath: ID!) { group(fullPath: $fullPath) { projects {nodes { id fullPath repository { rootRef }}}}}",
 variables: { fullPath: $gp }
}')

curl --silent \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/json" \
  --data "$QUERY" \
  "$GITLAB/api/graphql" |
jq -r '
  (.data.group.projects.nodes // []) []
  | "\(.id | split("/")[-1])=\(.repository.rootRef // "null")"
' > projects_to_fix.cfg

