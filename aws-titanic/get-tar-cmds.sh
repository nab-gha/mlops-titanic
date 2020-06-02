#! /bin/bash
echo "export AWS_ACCESS_KEY_ID=$(jq '."AccessKey"["AccessKeyId"]' $HOME/mlops-user.json)"
echo "export AWS_SECRET_ACCESS_KEY=$(jq '."AccessKey"["SecretAccessKey"]' $HOME/mlops-user.json)"
echo "aws s3api get-object --bucket $BUCKET_NAME --key emr/titanic/titanic-survival-prediction.tar.gz \$HOME/titanic-survival-prediction.tar.gz"
