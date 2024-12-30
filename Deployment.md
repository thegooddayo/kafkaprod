Conversation opened. 1 unread message.

Skip to content
Using Gmail with screen readers
3 of 3,370
Deployment File
Inbox

Atif Naseem
Attachments
Dec 26, 2024, 8:38 PM (4 days ago)
to me

Deployment File
 One attachment
  •  Scanned by Gmail
Write your reply to generate with AI
Yes
No
Follow up
# Deploy all services regarding kafka


# Kafka Deployment Updation

Upgraded Broker and Controller replica counts to 3
Add Toleration and Node Selector for running kafka on specific nodes
  nodeSelector:
    kafka: specific

  tolerations:
    - key: "kafka"
      operator: "Equals"
      value: "kafka"
      effect: "NoSchedule"



# Why not changing the service name to pod name
As recommended, service name sends traffic to all pods instead of one, As a result there will be no downtime until all pods are down.




# Service Account Permission

As service accounts are there for each service to connect with other service or application without any interruption, so there is no need to provide specific permissions unless permission of aws services are needed.


# Configure Grafana

Uncomment datasource and configure prometheus as default data source

 datasources.yaml:
   apiVersion: 1
   datasources:
   - name: Prometheus
     type: prometheus
     url: http://prometheus-server
     access: proxy
     isDefault: true


Configure  TestFramework :  false



# Prometheus/Alerts

Created service discovery for kafka metrics with below scrape_configs for queries related to kafka r.

    - job_name: kafka_broker
        static_configs:
        - targets:
        - kafka-broker-headless:5556

Health can be queried by below metrics request from Prometheus and Grafana:


kube_pod_container_status_running{container="kafka", pod=~"kafka-broker.*"}
kube_pod_container_status_running{ pod=~"conduktor-console.*" , container="conduktor-platform" }




# Now Deploy script.sh file to deploy all resources with eks cluster itself including all taints and node labels

RUN: chmod +x script.sh

then

RUN: ./script.sh

<!-- Script Internal Process -->

1: EKS Creation
2: Kafka Node Group Creation 
3: Taint and Labels for kafka nodes
4: Extra Node Group for other deployments
5: OIDC and service account creation for CSI drivers
6: Installation of helm repositories
7: Deployment of all services including Prometheus, Grafana, Secrets, Kafka, Kafka-connect , secrets and Kafka-conduktor
Deployment.md
Displaying Deployment.md.
