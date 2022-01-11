Once the application has been deployed, we're going to examine the secret files
that have been shared with the Pet Store app. Investigate the contents of the
secret file:
```
APP_POD="$(kubectl get pods -n quickstart-namespace | grep quickstart-app | awk '{print $1}')"
kubectl exec "$APP_POD" -c demo-app -n quickstart-namespace -- cat /opt/secrets/conjur/secrets-file
```{{execute}}

The output should resemble the following:
```
export DB_PLATFORM="postgres"
export DB_URL="postgresql://pg-backend.quickstart-namespace.svc.cluster.local:5432/pq_backend"
export DB_USERNAME="quickstartUser"
export DB_PASSWORD="MySecr3tP@ssword"
```

If the file has been successfully rendered in the shared volume, that means our
demo Pet Store app will have the credentials it needs to access it's backend.
Let's create a pod in `quickstart-namespace` that can make HTTP requests to the
Pet Store:
```
kubectl create -f /manifests/curl_manifest.yml -n quickstart-namespace
```{{execute}}

Add a pet to the Pet Store's database:
```
kubectl exec curl-pod -n quickstart-namespace \
  -- curl \
  -d '{"name": "Snoopy"}' \
  -H "Content-Type: application/json" \
  quickstart-app.quickstart-namespace.svc.cluster.local:8080/pet
```{{execute}}

Then, confirm the pet was added:
```
kubectl exec curl-pod -n quickstart-namespace \
  -- curl quickstart-app.quickstart-namespace.svc.cluster.local:8080/pets
```{{execute}}

If the requests are successful, you'll get the following output:
```
[{"id":1,"name":"Snoopy"}]
```