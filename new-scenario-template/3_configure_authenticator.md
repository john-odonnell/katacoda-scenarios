# Configure the Kubernetes Authenticator

Next, we will enable and configure the Kubernetes Authenticator, and establish
an identity in Conjur to authenticate the application.

First, deploy a Conjur CLI pod, and load policy to setup the Conjur Kubernetes
Authenticator.

Deploy a Conjur CLI pod to the recently created Conjur namespace:
```
cat <<EOF | kubectl apply -n conjur-oss -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: conjur-cli
  labels:
    app: conjur-cli
spec:
  replicas: 1
  selector:
    matchLabels:
      app: conjur-cli
  template:
    metadata:
      name: conjur-cli
      labels:
        app: conjur-cli
    spec:
      serviceAccountName: conjur-deployment-conjur-oss
      containers:
      - name: conjur-cli
        image: localhost:5000/conjur-cli:5-latest
        imagePullPolicy: Always
        command: ["sleep"]
        args: ["infinity"]
        env:
        - name: ADMIN_API_KEY
          value: ${ADMIN_API_KEY}
      imagePullSecrets:
        - name: dockerpullsecret
EOF
```{{execute}}

Once the CLI pod is running, copy policy files into the CLI container:
```
CLI_POD="$(kubectl get pods -n conjur-oss | grep cli | awk '{print $1}')"
kubectl cp /policy "${CLI_POD}:/policy" -n conjur-oss
```{{execute}}

Get a shell into the CLI container:
```
kubectl exec -it "$CLI_POD" -n conjur-oss -- /bin/bash
```{{execute}}

Initialize and authenticate the CLI:
```
yes yes | conjur init -u https://conjur-deployment-conjur-oss.conjur-oss.svc.cluster.local -a myAccount
conjur authn login -u admin -p $ADMIN_API_KEY
```{{execute}}

Load the Policy to setup the Kubernetes Authenticator. For more information on
the policy included here, see the documentation for
[Enabling the Kubernetes Authenticator](https://docs.conjur.org/Latest/en/Content/Integrations/Kubernetes_deployApplicationCluster.htm?tocpath=Integrations%7COpenShift%252C%20Kubernetes%7C_____4).
```
conjur policy load root /policy/setup_k8s_authn.yml
conjur policy load root /policy/create_host.yml
conjur policy load root /policy/app_secrets.yml
conjur policy load root /policy/grants.yml
```{{execute}}


Add secret values to Conjur:
```
conjur variable values add quickstart-app-resources/url 'https://service-url.com'
conjur variable values add quickstart-app-resources/username 'quickstartUser'
conjur variable values add quickstart-app-resources/password 'MySecr3tP@ssword'
```{{execute}}

Exit the CLI with `exit`{{execute}}.

Now that the Kubernetes Authenticator has been setup in policy, initialize
the authenticator's certificate authority.

```
kubectl exec "$CONJUR_POD" -c conjur-oss -n conjur-oss \
  -- bash -c "CONJUR_ACCOUNT=myAccount rake authn_k8s:ca_init['conjur/authn-k8s/quickstart-cluster']"
```{{execute}}
