Now we will deploy a PostgreSQL backend, and store it's credentials in Conjur.

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```{{execute}}

```
helm install pg-backend bitnami/postgresql -n quickstart-namespace --wait --timeout "5m0s" \
  --set image.repository="postgres" \
  --set image.tag="9.6" \
  --set fullnameOverride="pg-backend" \
  --set postgresqlDatabase="pg_backend" \
  --set postgresqlUsername="quickstartUser" \
  --set postgresqlPassword="MySecr3tP@ssword"
```{{execute}}