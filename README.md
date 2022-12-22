# TeamPostgreSQL

This build of TeamPostgrSQL is a web interface for your containerized PostgreSQL servers.

The multi-platform version package was used for the construction of the containerized application.

More infos at

https://teampostgresql.com

http://cdn.webworks.dk/download/teampostgresql_multiplatform.zip

Many thanks to https://github.com/steigr/docker-teampostgresql for its script on how to run the application.

This container image is built to run in any K8S platform, podman and docker runtimes.

This container image does not require special security permissions when deployed on Openshift.

This container image is based on a RedHat 'ubi8/ubi' image and an intermediate image in which the Java runtime has been installed.

## Deployment

To execute the deployment use following steps

1. Definition of environment variables for creating intermediate artifacts.
```
#---------------------------
# define env vars
TNS=<your-namespace>
TP_NAME=<your-deployment-name>
TP_IMAGE=quay.io/marco_antonioni/teampostgres:v1
TP_FILE_EV=./team-postgresql-env-vars
```

2. Creating a properties file used for defining environment variables for deployment (change the values for your needs), for TEAMPOSTGRESQL_DEFAULT_HOST use the Service name used to reach out your Postgres pod instance
```
#---------------------------
# create deployment env vars file
cat << EOF > ./team-postgresql-env-vars
TEAMPOSTGRESQL_PORT=8082
TEAMPOSTGRESQL_ADMIN_USER=admin
TEAMPOSTGRESQL_ADMIN_PASSWORD=passw0rd
TEAMPOSTGRESQL_COOKIES_ENABLED=true
TEAMPOSTGRESQL_DATA_DIRECTORY="/tmp"
TEAMPOSTGRESQL_HTTPS=DISABLED
TEAMPOSTGRESQL_DEFAULT_HOST=my-postgresql. !!!--your--namespace--!!! .svc.cluster.local
TEAMPOSTGRESQL_DEFAULT_PORT=5432
TEAMPOSTGRESQL_DEFAULT_USERNAME=postgres
TEAMPOSTGRESQL_DEFAULT_PASSWORD=postgres
TEAMPOSTGRESQL_DEFAULT_DATABASENAME=postgres
TEAMPOSTGRESQL_DEFAULT_SSL=false
EOF
```

3. Create a namespace (optional)
```
#---------------------------
oc new-project ${TNS}
```

4. Deploy and expose the application
```
#---------------------------
oc new-app --image=${TP_IMAGE} --name=${TP_NAME} --env-file=${TP_FILE_EV}
oc expose deployment ${TP_NAME} --port=8082
oc expose service ${TP_NAME} --name=route-${TP_NAME}

URL=http://$(oc get route route-team-postgresql -o jsonpath='{.spec.host}')/teampostgresql/webapp
echo "Browse at " ${URL}
```

## For local execution run the commands

```
#-----------------
# run local

podman pull quay.io/marco_antonioni/teampostgres:v1

podman run -it --rm --publish=8082:8082 \
  --name=teampostgresql \
  --env=TEAMPOSTGRESQL_ADMIN_PASSWORD=passw0rd \
  --env=TEAMPOSTGRESQL_ADMIN_USER=admin \
  --env=TEAMPOSTGRESQL_PORT="8082" \
  --env=TEAMPOSTGRESQL_COOKIES_ENABLED="true" \
  --env=TEAMPOSTGRESQL_DATA_DIRECTORY=/tmp \
  --env=TEAMPOSTGRESQL_DEFAULT_DATABASENAME=??? \
  --env=TEAMPOSTGRESQL_DEFAULT_HOST=??? \
  --env=TEAMPOSTGRESQL_DEFAULT_USERNAME=??? \
  --env=TEAMPOSTGRESQL_DEFAULT_PASSWORD=??? \
  --env=TEAMPOSTGRESQL_DEFAULT_PORT="5432" \
  --env=TEAMPOSTGRESQL_DEFAULT_SSL="false" \
  --env=TEAMPOSTGRESQL_HTTPS=DISABLED \
  quay.io/${REPO_NAME}/teampostgres:latest
```

