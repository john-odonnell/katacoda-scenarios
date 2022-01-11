Take a look at the application manifest with `cat /manifests/app_manifest.yml`.

There are a few aspects to note:
- Secrets Provider in Push-to-File mode is configured with Pod annotations,
  named as `conjur.org/<setting>`. A full reference for these settings can be
  found in the [Push-to-File documentation](https://github.com/cyberark/secrets-provider-for-k8s/blob/main/PUSH_TO_FILE.md#reference-table-of-configuration-annotations). Important ones to note:
  - `conjur.org/secrets-destination` enables Push-to-File.
  - `conjur.org/authn-identity` defines the Conjur identity the application is
    using to authenticate.
  - `conjur.org/conjur-secrets.test-app` defines Conjur variables that will be
    rendered in the resulting secret file.
- There are three required volumes:
  1. `podinfo`: This volume will contain a file, created by the K8s Downward
     API, containing configuration data from the Pod annotations. This volume
     needs to be mounted in the Secrets Provider container.
  2. `conjur-secrets`: This volume will contain secret files created by Secrets
     Provider, and needs to be mounted to both the Secrets Provider and
     application containers.
  3. `conjur-templates`: Secrets Provider allows for customizing secret files
     with custom templates. This volume will contain custom template files
     defined in ConfigMaps, and needs to be mounted to the Secrets Provider
     container.

```
kubectl apply -n quickstart-namespace -f /manifests/app_manifest.yml
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
