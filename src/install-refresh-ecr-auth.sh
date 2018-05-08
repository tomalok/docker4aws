### begin install of refresh-ecr-auth.sh
while true; do
  EXPAND=$(echo $ECR_AUTH_LOGINS | \
    sed -E \
      -e 's/(^,+|,+$)//g' \
      -e 's/,,+/,/g' \
      -e "s/(^|,)([^=,]+)(,|$)/\1\2=$ACCOUNT_ID\3/g" \
      -e "s/(^|,)=/\1$AWS_REGION=/g" \
      -e "s/(=|:):*(:|,|$)/\1$ACCOUNT_ID\2/g" \
      -e "s/:(,|$)/\1/g"
  )
  [ "$EXPAND" = "$ECR_AUTH_LOGINS" ] && break
  ECR_AUTH_LOGINS=$EXPAND
done
if [ -n "$ECR_AUTH_LOGINS" ]; then
  BIN=/usr/local/bin
  SCRIPT=refresh-ecr-auth.sh
  echo " * Installing $BIN/$SCRIPT..."
  mkdir -p $BIN
  cat >$BIN/$SCRIPT <<EOF
#!/bin/sh
log() {
  logger -st \$(basename \$0) \$@
}
for TGT in $(echo $ECR_AUTH_LOGINS | tr ',' ' '); do
  echo "\$TGT" | tr '=' ' ' | (
    read REGION ACCOUNTS
    ACCOUNTS=\$(echo \$ACCOUNTS | tr ':' ' ')
    log "INFO - Refreshing \$REGION ECR creds for \$ACCOUNTS..."
    su docker sh -c "eval \$(docker exec guide-aws aws ecr get-login --no-include-email --region \$REGION --registry-ids \$ACCOUNTS)" | log
  )
done
( WAIT=1; MAX=60; TRY=0
  while true; do
    TRY=\$(( TRY + 1))
    SERVICES=\$(su docker sh -c "docker service ls --format '{{.Name}}' 2>/dev/null")
    if [ \$? -eq 0 ]; then
      log "INFO - Triggering update of swarm services' registry auth..."
      for SERVICE in \$SERVICES; do
        su docker sh -c "docker service update -d -q --with-registry-auth \$SERVICE" | log
      done
      log "INFO - Done triggering swarm services' registry auth updates."
      break
    fi
    if [ \$TRY -eq \$MAX ]; then
      log "ERROR - Still not part of swarm after \$(( MAX * WAIT )) secs, aborting."
      break
    fi
    log "WARN - Not yet part of swarm (try #\$TRY), retry in \$WAIT secs."
    sleep \$WAIT
  done
) &
EOF
  chmod +x $BIN/$SCRIPT
  echo " * Installing cron to execute $BIN/$SCRIPT..."
  sed -e "/$SCRIPT/d" /etc/crontabs/root > /tmp/root-crontab
  echo "# run $SCRIPT on the random-th minute every 8 hours" >> /tmp/root-crontab
  echo "$(( $RANDOM % 60 )) */8 * * * $BIN/$SCRIPT >/dev/null 2>&1" >> /tmp/root-crontab
  crontab -c /etc/crontabs /tmp/root-crontab
  rm /tmp/root-crontab
  echo " * Initial execution of $BIN/$SCRIPT..."
  $BIN/$SCRIPT
else
  echo " * Not Installing ECR Auth Refresh Script - no ECR Auth Login Targets specified."
fi
### end installation of refresh-ecr-auth.sh
