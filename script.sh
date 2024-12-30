clustername="atifkafka"
region="us-east-1"


eksctl create cluster --name=${clustername} --version=1.30 --region=$region --without-nodegroup
eksctl create nodegroup --cluster=${clustername} --name=${clustername}kafka --node-type=c4.2xlarge --nodes=2 --nodes-min=2 --nodes-max=3 --node-labels="kafka=kafka"
for node in $(kubectl get nodes -o custom-columns=NAME:.metadata.name); do
  kubectl taint nodes $node kafka=kafka:NoSchedule
done
eksctl create nodegroup --cluster=${clustername} --name=${clustername}nodegroup1 --node-type=c4.2xlarge --nodes=2 --nodes-min=2 --nodes-max=3


eksctl utils associate-iam-oidc-provider --region=$region --cluster=$clustername --approve


eksctl create iamserviceaccount \
  --region $region \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster $clustername \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name AmazonEKS_EBS_CSI_DriverRole

eksctl create addon --name aws-ebs-csi-driver --cluster $clustername --service-account-role-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/AmazonEKS_EBS_CSI_DriverRole --force


kubectl apply -f secrets.yaml
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install prometheus  prometheus-community/prometheus -f prometheus.yaml
helm install kafka kafka/ -f ./kafka/kafka-values.yaml 
helm install conduktor conduktor/ -f conduktor/conduktor-values.yaml
helm install grafana grafana/grafana  -f grafana.yaml
helm install kafka-connect kafka-connect -f kafka-connect/values.yaml



# kube_pod_container_status_running{container="kafka", pod=~"kafka-broker.*"}
# kube_pod_container_status_running{ pod=~"conduktor-console.*" , container="conduktor-platform" }

