#! /bin/bash
echo "export AWS_ACCESS_KEY_ID=$(jq '."AccessKey"["AccessKeyId"]' $HOME/mlops-user.json)"
echo "export AWS_SECRET_ACCESS_KEY=$(jq '."AccessKey"["SecretAccessKey"]' $HOME/mlops-user.json)"
export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION # the region from cloud9 environment
EKS_CLUSTER_NAME=$EKS_CLUSTER_NAME
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 &
