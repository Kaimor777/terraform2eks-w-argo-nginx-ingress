
# Create an EKS cluster w Nginx-ingress & Argo-cd using Terraform

In this repo I created a simple EKS cluster w 3 nodes using Terraform and used Helm_provider to create nginx-ingress and argo-cd.  

## Authors

- [@Amitk3293 ](https://github.com/Amitk3293)


## Prerequisites

 - Terraform v0.14+
 - A configured AWS CLI w the relevant IAM permissions ("TF-API-admin" in that case)
 - AWS account w the relevant IAM permissions
 - IAM user w the relevant permissions
 - kubectl
 - wget (required for the eks module)
 - S3 buckets for TF-remote-backend (optional)


## Deployment

Clone the repo

```bash
  git clone https://github.com/Amitk3293/terraform2eks-w-argo-nginx-ingress.git
```

Edit eks-cluster.tf w the required eks settings and variables.tf and fill the requird region and cluster name
```bash
variable "region" {
  default     = "eu-central-1"
  description = "AWS region"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  default     = "eks-0001"

}
```

#### *Edit backend.tf w your remote backend to keep your state file sensitive data being "safe" or delete to use a local backend



Initiallize Terraform, plan and apply
```bash
terraform init
terraform plan
terraform apply
```
When TF process ends successfully configure kubeconfig to be able to use kubectl
```bash
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

### For deploy nginx-ingress using Helm_provider go to /helm-tf/modules/nginx-ingress

**Edit backend.tf w your remote backend to keep your state file "safe" or delete to use a local backend

Initiallize Terraform, plan and apply
```bash
terraform init
terraform plan
terraform apply
```

When TF process ends successfully -  Get the ingress service to have your ingress external IP 

```bash
k get svc -n ingress
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                                 PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   172.20.219.188   a1ceeff3173e8452ab3b1b5c42b60069-404761402.eu-central-1.elb.amazonaws.com   80:31114/TCP,443:31853/TCP   54s
ingress-nginx-controller-admission   ClusterIP      172.20.44.234    <none>                                                                      443/TCP                      54s
```

### For deploy argo-cf using Helm_provider go to /helm-tf/modules/argo-cd
Edit argo-values.yaml hosts to argo-cd.<your-domain>
```bash
server:
  extraArgs:
    - --insecure
  ingress:
    enabled: true
    hosts:
      - argo-cd.amitk.link
    ingressClassName: nginx
    paths:
      - /
```
**Edit DNS Cname record with a record name- argo-cd.<your-domain> and a value of the ingress external IP we check before.


Initiallize Terraform, plan and apply
```bash
terraform init
terraform plan
terraform apply
```


browse to argo-cd.<your-domain>
```bash
amitk@pop-os ~ curl -I argo-cd.amitk.link
HTTP/1.1 200 OK
Date: Sun, 06 Mar 2022 19:33:25 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 843
Connection: keep-alive
Accept-Ranges: bytes
X-Frame-Options: sameorigin
X-Xss-Protection: 1
```

### To sync your application w argo-cd run 
```bash
k get deploy -o yaml -n ingress
k get deploy -o yaml -n argo-cd
```
and add the deployment.yaml outputs into deployments-yaml folder in the repo, then sync argoCD w the git repo and deployments-yamls path.
