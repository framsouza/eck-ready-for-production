# ECK in production environment

This articles will guide you on how to spin up an ECK environment ready for production together with,

- **dedicated stack monitoring**,
- **fleet-server & elastic-agent** with Kubernetes integratoin,
- **elasticsearch autoscaling**,
- **nodeAffinity & nodeSelector**,
- **SAML with auth0**,
- **hot,warm,cold,frozen architecture**,
- **heartbeat monitor SSL certificate expiration**,
- [external-dns](https://github.com/kubernetes-sigs/external-dns) (with CloudFlare integration),
- [cert-manager](https://github.com/cert-manager/cert-manager) -with let's encrypt integration),
- [ingress controller](https://kubernetes.github.io/ingress-nginx/) (using Cloudflare to register the endpoints)
- _Optional_: [esrally](https://esrally.readthedocs.io/en/stable/) to validate autoscaling and run benchmark against es cluster 

_Remember you must have `basic` or `enterprise` license to run ECK._

## Demo

### cert-manager
Cert-manager adds certificates and  certificate issuers as resource types in Kubernetes, and simplifies the process of obtaining, renewing and using those certificates. It's very command Kubernetes administrator use cert-manager to handle certificate, and on this exemple we are going to use cert-manager with let's encrypt to access Kibana. Remember that, TLS certificates for the Elasticsearch transport layer that are used for internal communications between Elasticsearch nodes are managed by ECK and **cannot** be changed.

### ingress
Ingress controller is specialized load balancer for Kubernetes, qhich accepts traffic from outside the Kubernetes cluster and balances it to pods. 

### external-dns
It's a addon that configures public DNS servers about exposed Kubernetes services, on this examples we are integrating external-dns with Cloudflare. For each Ingress/Service resource you us, a DNS entry will created on Cloudflare with the respective IP address, on external-dns logs you should be able to see the following

```
time="2022-03-02T13:36:52Z" level=info msg="Using inCluster-config based on serviceaccount-token"
time="2022-03-02T13:36:52Z" level=info msg="Created Kubernetes client https://10.76.0.1:443"
time="2022-03-02T13:41:04Z" level=info msg="Changing record." action=CREATE record=kibana.framsouza.co ttl=1 type=A zone=4cd4c7c1cb8f7bf3a7482749654ae6fb
time="2022-03-02T13:41:05Z" level=info msg="Changing record." action=CREATE record=kibana.framsouza.co ttl=1 type=TXT zone=4cd4c7c1cb8f7bf3a7482749654ae6fb
```

### How-to setup

_Make sure to respect the commands execution order_

1. Create GKE cluster with Kubernetes `type` hot, warm, cold,  frozen for each dedicated node pool, make sure you will have enough resouce to run the pods in the nodes. [Here](https://github.com/framsouza/terraform), there's a terraform example that will spin up it for you, 
2. Create a cluster role mapping that gives you permission to install ECK operator 
	- `kubectl create clusterrolebinding cluster-admin-binding --cluster-role=cluster-admin --user=<USERNAME>`
3. Install ECK operator 
	- `helm repo add elastic https://helm.elastic.co && helm repo update && helm install elastic-operator elastic/eck-operator -n elastic-system --create-namespace`
4. Create dedicated storage class by applying files **storageclass-hot.yaml** and **storageclass-warm.yaml**
5. Download your license and apply it via secret (or apply the [license.yaml](https://github.com/framsouza/eck-ready-for-production/blob/main/license.yaml))
	- `kubectl create secret generic eck-license --from-file <LICENSE-PATH> -n elastic-system && kubectl label secret eck-license "license.k8s.elastic.co/scope"=operator -n elastic-system`
6. Create the monitoring cluster (it will create a `ns` call *monitoring*) by applying [monitoring-es.yaml](https://github.com/framsouza/eck-ready-for-production/blob/main/monitoring-es.yaml),
7. Create elasticsearch resource, [elasticsearch.yaml](https://github.com/framsouza/eck-ready-for-production/blob/main/elasticsearch.yaml)
8. Create kibana resource, [kibana.yaml](https://github.com/framsouza/eck-ready-for-production/blob/main/kibana.yaml)
9. Create fleet resource, [fleet.yaml](https://github.com/framsouza/eck-ready-for-production/blob/main/fleet.yaml)
10. Create heartbeat, [heartbeat.yaml](https://github.com/framsouza/eck-ready-for-production/blob/main/heartbeat.yaml)
11. Install external-dns
	- `CF_API_KEY=<YOURAPI> && CF_API_EMAIL=<YOUREMAIL> && helm upgrade --install external-dns bitnami/external-dns --set provider=cloudflare --set CF_API_KEY=$CF_API_KEY --set CF_API_EMAIL=$CF_API_EMAI`
12. Install cert-manager
	- `kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml`
13. Create cluster issuer apply [clusterissuer.yaml](https://github.com/framsouza/eck-ready-for-production/blob/main/clusterissuer.yaml)
14. Create let's encrypt certificate [certificate.yaml](https://github.com/framsouza/eck-ready-for-production/blob/main/certificate.yaml)
15. Install ingress-nginx ,
	- `helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace`
16. Create ingress resource, [ingress.yaml](https://github.com/framsouza/eck-ready-for-production/blob/main/ingress.yaml)


### Autoscaling validation
(_Optional_)

To confirm if autoscaling is working as expected, you can use [esrally](https://esrally.readthedocs.io/en/stable/) to test that and run benchmark against your cluster. Make sure to have `params-file.json` with the following content:
```
{
    "number_of_replicas": 1,
    "number_of_shards": 2
}
```

then you just need to run and wait a couple of hours until the test is finished.

```
docker run -v /tmp/params-file.json:/tmp/params-file.json elastic/rally race --track=http_logs --target-hosts=${IP}:9200 --pipeline=benchmark-only --client-options="timeout:60,use_ssl:true,verify_certs:false,basic_auth_user:'elastic',basic_auth_password:'${PASSWORD}'"  --track-params=/tmp/params-file.json
```

Have a look at [esrally-result.txt](https://github.com/framsouza/eck-ready-for-production/blob/main/esrally-result.txt).
