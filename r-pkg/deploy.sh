# This script, when run from Jenkins, takes as input the artifacts generated by build jobs and publishes the R packages
# to a S3 hosted CRAN-like repository.  Users can then install the packages using the commmand:
# install.packages(<package-name>, repos="http://<S3_RAN>.synapse.org")

# Params
# AWS_ACCESS_KEY_ID -- S3 creds
# AWS_SECRET_ACCESS_KEY -- S3 creds
# S3_RAN -- either "staging-ran.synapse.org" or "ran.synapse.org"

home=`pwd`

# remove the last build clone
set +e
rm -R ${S3_RAN}
set -e

# retrieving the current content of S3_RAN
mkdir ${S3_RAN}
cd ${S3_RAN}
aws s3 sync s3://${S3_RAN}/ .
cd ..

# artifact folder = $home
# ran folder = $home/s3_ran

curl -o deploy.R https://github.com/kimyen/CI-Build-Tools/blob/WW-70/r-pkg/deploy.R
R -e "source('$home/deploy.R);\
jenkins_deploy($home/$S3_RAN, $home)"

# upload
cd ${S3_RAN}
aws s3 sync --acl public-read . s3://${S3_RAN}/
cd ..

# clean up
rm -rf $home

