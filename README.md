The `titanic-survival-prediction.py` sample runs a Spark ML pipeline to train a classfication model using random forest on AWS Elastic Map Reduce(EMR).

[Titanic: Machine Learning from Disaster](https://www.kaggle.com/c/titanic)
copy of [Jeffwan's code](https://github.com/Jeffwan/aws-emr-titanic-ml-example) for gitops workshop
Also pipeline sample from [kubeflow/pipeline](https://github.com/kubeflow/pipelines/tree/master/samples/contrib/aws-samples/titanic-survival-prediction)

This repository includes a tar file ready to be deployed to Kubeflow. To build your own tar file fork this repository and clone your fork.
The following instructions are designed to executed in cloud9 or other ec2 instance. 

# Build and Configure Titanic Sample

```shell
# Set default region
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region') # For ec2 client or cloud9
export AWS_DEFAULT_REGION=$AWS_REGION

aws iam create-user --user-name mlops-user
aws iam create-access-key --user-name mlops-user > mlops-user.json
export THE_ACCESS_KEY_ID=$(jq '."AccessKey"["AccessKeyId"]' mlops-user.json)
echo $THE_ACCESS_KEY_ID
export THE_SECRET_ACCESS_KEY=$(jq '."AccessKey"["SecretAccessKey"]' mlops-user.json)

export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)

aws iam create-policy --policy-name mlops-s3-access \
    --policy-document https://raw.githubusercontent.com/paulcarlton-ww/mlops-titanic/master/resources/s3-policy.json  > s3-policy.json

aws iam create-policy --policy-name mlops-emr-access \
    --policy-document https://raw.githubusercontent.com/paulcarlton-ww/mlops-titanic/master/resources/emr-policy.json > emr-policy.json

aws iam create-policy --policy-name mlops-iam-access \
    --policy-document https://raw.githubusercontent.com/paulcarlton-ww/mlops-titanic/master/resources/iam-policy.json > iam-policy.json

aws iam attach-user-policy --user-name mlops-user  --policy-arn $(jq '."Policy"["Arn"]' s3-policy.json)
aws iam attach-user-policy --user-name mlops-user  --policy-arn $(jq '."Policy"["Arn"]' emr-policy.json)

curl  https://raw.githubusercontent.com/paulcarlton-ww/mlops-titanic/master/resources/kubeflow-aws-secret.yaml | \
    sed s/YOUR_BASE64_SECRET_ACCESS/$(echo -n "$THE_SECRET_ACCESS_KEY" | base64)/ | \
    sed s/YOUR_BASE64_ACCESS_KEY/$(echo -n "$THE_ACCESS_KEY_ID" | base64)/ | kubectl apply -f -;echo

aws s3api create-bucket --bucket mlops-kubeflow-pipeline-data --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION
```

## Install sbt

```shell
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java
sdk install sbt
```

## Build Spark Jars

```shell
git clone git@github.com:paulcarlton-ww/mlops-titanic
cd mlops-titanic/
sbt clean package
aws s3api put-object --bucket mlops-kubeflow-pipeline-data --key emr/titanic/titanic-survivors-prediction_2.11-1.0.jar --body target/scala-2.11/titanic-survivors-prediction_2.11-1.0.jar
```

> Note: EMR has all spark libariries and this project doesn't reply on third-party library. We don't need to build fat jars.

## The dataset

Check Kaggle [Titanic: Machine Learning from Disaster](https://www.kaggle.com/c/titanic) for more details about this problem. 70% training dataset is used to train model and rest 30% for validation.

A copy of train.csv is included in this repository

## Install 

See [building a pipeline](https://www.kubeflow.org/docs/guides/pipelines/build-pipeline/) to install the Kubeflow Pipelines SDK.
The following command will install the tools required

```bash
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
source /home/ec2-user/.bashrc
conda create --name mlpipeline python=3.7
pip3 install --user kfp --upgrade
rm Miniconda3-latest-Linux-x86_64.sh 
```

## Compiling the pipeline template

```bash
dsl-compile --py titanic-survival-prediction.py --output titanic-survival-prediction.tar.gz
```

## Deploying the pipeline

Open the Kubeflow pipelines UI. Create a new pipeline, and then upload the compiled specification (`.tar.gz` file) as a new pipeline template.

Once the pipeline done, you can go to the S3 path specified in `output` to check your prediction results. There're three columes, `PassengerId`, `prediction`, `Survived` (Ground True value)

```
...
4,1,1
5,0,0
6,0,0
7,0,0
...
```

## Components source

Create Cluster:
  [source code](https://github.com/kubeflow/pipelines/tree/master/components/aws/emr/create_cluster/src)

Submit Spark Job:
  [source code](https://github.com/kubeflow/pipelines/tree/master/components/aws/emr/submit_spark_job/src)

Delete Cluster:
  [source code](https://github.com/kubeflow/pipelines/tree/master/components/aws/emr/delete_cluster/src)
