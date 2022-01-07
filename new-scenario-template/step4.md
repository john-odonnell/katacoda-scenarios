# Deploy the Secrets-Provider-enabled Application

```
cat <<EOF | kubectl apply -n quickstart-namespace -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: quickstart-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: quickstart-app
  name: quickstart-app
  namespace: quickstart-namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: quickstart-app
  template:
    metadata:
      labels:
        app: quickstart-app
      annotations:
        conjur.org/authn-identity: host/conjur/authn-k8s/quickstart-cluster/apps/quickstart-app
        conjur.org/debug-logging: "true"
        conjur.org/container-mode: init
        conjur.org/secrets-destination: file
        conjur.org/conjur-secrets-policy-path.test-app: quickstart-app-resources/
        conjur.org/conjur-secrets.test-app: |
          - url
          - admin_username: username
          - admin_password: password
        conjur.org/secret-file-path.test-app: "./credentials.yaml"
        conjur.org/secret-file-format.test-app: "json"
    spec:
      serviceAccountName: quickstart-app
      containers:
      - name: file-examiner
        image: ubuntu:latest
        command: [ "/bin/bash", "-c", "--" ]
        args: [ "while true; do sleep 10; done;" ]
        volumeMounts:
          - name: conjur-secrets
            mountPath: /opt/secrets/conjur
            readOnly: true
      initContainers:
      - name: cyberark-secrets-provider-for-k8s
        image: 'cyberark/secrets-provider-for-k8s:latest'
        imagePullPolicy: Always
        env:
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: MY_POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        envFrom:
        - configMapRef:
            name: conjur-connect
        volumeMounts:
          - name: podinfo
            mountPath: /conjur/podinfo
          - name: conjur-secrets
            mountPath: /conjur/secrets
          - name: conjur-templates
            mountPath: /conjur/templates
      volumes:
        - name: podinfo
          downwardAPI:
            items:
              - path: "annotations"
                fieldRef:
                  fieldPath: metadata.annotations
        - name: conjur-secrets
          emptyDir:
            medium: Memory
        - name: conjur-templates
          emptyDir:
            medium: Memory
EOF
```{{execute}}

Once the application has been deployed, exec into the application container.
For this example, the application is an Ubuntu container, for the purpose of
examining the shared secret files.

```
APP_POD="$(kubectl get pods -n quickstart-namespace | grep quickstart-app | awk '{print $1}')"
kubectl exec -it "$APP_POD" -n quickstart-namespace -- /bin/bash
```{{execute}}

Investigate the contents of the secret file with
`cat /opt/secrets/conjur/credentials.json`{{execute}}. The output should resemble
the following:

```
{"url": "https://service-url.com", "admin_username": "quickstartUser", "admin_password": "MySecr3tP@ssword"}
```
