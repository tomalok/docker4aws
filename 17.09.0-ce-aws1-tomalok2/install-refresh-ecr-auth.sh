#!/bin/sh -ex

# script installation directory
BINDIR=/usr/local/bin
mkdir -p $BINDIR

# create the refresh script
SCRIPT=refresh-ecr-auth.sh
cat >$BINDIR/$SCRIPT <<EOF
#!/bin/sh -ex
ECR_LOGIN="\$(docker exec guide-aws aws ecr get-login --no-include-email --region $AWS_REGION)"
eval \$ECR_LOGIN
su docker sh -c "eval \$ECR_LOGIN"
EOF
chmod +x $BINDIR/$SCRIPT

# filter out refresh-ecr-auth.sh lines from current crontab
sed -e "/$SCRIPT/d" /etc/crontabs/root > /tmp/root-crontab

# add refresh-ecr-auth.sh cron job random-th minute of every 8 hours
echo "# run $SCRIPT on the random-th minute every 8 hours" >> /tmp/root-crontab
echo "$(( $RANDOM % 60 )) */8 * * * $BINDIR/$SCRIPT" >> /tmp/root-crontab

# update crontab
CRONDIR=/etc/crontabs
crontab -c $CRONDIR /tmp/root-crontab

# cleanup
rm /tmp/root-crontab

# get initial ECR credentials
$BINDIR/$SCRIPT
