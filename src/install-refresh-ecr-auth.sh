### begin installation of refresh-ecr-auth.sh
BINDIR=/usr/local/bin
mkdir -p $BINDIR
SCRIPT=refresh-ecr-auth.sh
cat >$BINDIR/$SCRIPT <<EOF
#!/bin/sh -ex
ECR_LOGIN="\$(docker exec guide-aws aws ecr get-login --no-include-email --region $AWS_REGION)"
eval \$ECR_LOGIN
( until [ "\$?" = "0" -o "\$TRIES" = "300" ]; do
    sleep 1
    TRIES=\$(( TRIES+1 ))
    for SERVICE in \$(docker service ls --format "{{.Name}}"); do
      docker service update -q --with-registry-auth \$SERVICE
    done
  done ) &
EOF
chmod +x $BINDIR/$SCRIPT
sed -e "/$SCRIPT/d" /etc/crontabs/root > /tmp/root-crontab
echo "# run $SCRIPT on the random-th minute every 8 hours" >> /tmp/root-crontab
echo "$(( $RANDOM % 60 )) */8 * * * $BINDIR/$SCRIPT" >> /tmp/root-crontab
crontab -c /etc/crontabs /tmp/root-crontab
rm /tmp/root-crontab
$BINDIR/$SCRIPT
### end installation of refresh-ecr-auth.sh
