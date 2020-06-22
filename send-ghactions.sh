#!/bin/bash

if [ -z "$2" ]; then
  echo -e "WARNING!!\nYou need to pass the WEBHOOK_URL environment variable as the second argument to this script.\nFor details & guide, visit: https://github.com/DS-Homebrew/discord-webhooks" && exit
fi

echo -e "[Webhook]: Sending webhook to Discord...\\n";

case $1 in
  "success" )
    EMBED_COLOR=3066993
    STATUS_MESSAGE="Passed"
    AVATAR="https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/github-logo.png"
    ;;

  "failure" )
    EMBED_COLOR=15158332
    STATUS_MESSAGE="Failed"
    AVATAR="https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/github-logo.png"
    ;;

  * )
    EMBED_COLOR=0
    STATUS_MESSAGE="Status Unknown"
    AVATAR="https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/github-logo.png"
    ;;
esac

AUTHOR_NAME="$(git log -1 "$GITHUB_SHA" --pretty="%aN")"
COMMITTER_NAME="$(git log -1 "$GITHUB_SHA" --pretty="%cN")"
COMMIT_SUBJECT="$(git log -1 "$GITHUB_SHA" --pretty="%s")"
COMMIT_MESSAGE="$(git log -1 "$GITHUB_SHA" --pretty="%b")"

if [ "$AUTHOR_NAME" == "$COMMITTER_NAME" ]; then
  CREDITS="$AUTHOR_NAME authored & committed"
else
  CREDITS="$AUTHOR_NAME authored & $COMMITTER_NAME committed"
fi

TIMESTAMP=$(date --utc +%FT%TZ)
if [ $IMAGE = "" ]; then
  WEBHOOK_DATA='{
    "username": "Github Actions",
    "avatar_url": "'$AVATAR'",
    "embeds": [ {
      "color": '$EMBED_COLOR',
      "author": {
        "name": "Build '"v$CURRENT_DATE"' '"$STATUS_MESSAGE"' - '"$GITHUB_REPOSITORY"'",
        "url": "'"https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"'",
        "icon_url": "'$AVATAR'"
      },
      "title": "'"$COMMIT_SUBJECT"'",
      "url": "'"$URL"'",
      "description": "'"${COMMIT_MESSAGE//$'\n'/ }"\\n\\n"$CREDITS"'",
      "fields": [
        {
          "name": "Commit",
          "value": "'"[\`${GITHUB_SHA:0:7}\`](https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA)"'",
          "inline": true
        },
        {
          "name": "Branch",
          "value": "'"[\`$GITHUB_REF\`](https://github.com/$GITHUB_REPOSITORY/tree/$GITHUB_REF)"'",
          "inline": true
        },
        {
          "name": "TWLBot commit",
          "value": "'"[\`${TWLBOT_COMMIT:0:7}\`](https://github.com/TWLBot/Builds/commit/$TWLBOT_COMMIT)"'",
          "inline": true
        }
      ],
      "timestamp": "'"$TIMESTAMP"'"
    } ]
  }'
else
  WEBHOOK_DATA='{
    "username": "Github Actions",
    "avatar_url": "'$AVATAR'",
    "embeds": [ {
      "color": '$EMBED_COLOR',
      "author": {
        "name": "Build '"v$CURRENT_DATE"' '"$STATUS_MESSAGE"' - '"$GITHUB_REPOSITORY"'",
        "url": "'"https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"'",
        "icon_url": "'$AVATAR'"
      },
      "title": "'"$COMMIT_SUBJECT"'",
      "url": "'"$URL"'",
      "description": "'"${COMMIT_MESSAGE//$'\n'/ }"\\n\\n"$CREDITS"'",
      "fields": [
        {
          "name": "Commit",
          "value": "'"[\`${GITHUB_SHA:0:7}\`](https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA)"'",
          "inline": true
        },
        {
          "name": "Branch",
          "value": "'"[\`$GITHUB_REF\`](https://github.com/$GITHUB_REPOSITORY/tree/$GITHUB_REF)"'",
          "inline": true
        },
        {
          "name": "TWLBot commit",
          "value": "'"[\`${TWLBOT_COMMIT:0:7}\`](https://github.com/TWLBot/Builds/commit/$TWLBOT_COMMIT)"'",
          "inline": false
        }
      ],
      "image": {
        "url": "'"$IMAGE"'"
      },
      "timestamp": "'"$TIMESTAMP"'"
    } ]
  }'
fi

(curl --fail --progress-bar -A "Github-Actions-Webhook" -H Content-Type:application/json -H X-Author:k3rn31p4nic#8383 -d "$WEBHOOK_DATA" "$2" \
  && echo -e "\\n[Webhook]: Successfully sent the webhook.") || echo -e "\\n[Webhook]: Unable to send webhook."
