# TeamPostgreSQL

<b>WARNING: privileged container !!!</b>

see README.md for unprivileged deployment (OpenShift way) 

Web interface for your containerized PostgreSQL servers

## TeamPostgreSQL env vars
```
$TEAMPOSTGRESQL_PORT (default: 8082)
$TEAMPOSTGRESQL_ADMIN_USER (default: unset)
$TEAMPOSTGRESQL_ADMIN_PASSWORD (default: $TEAMPOSTGRESQL_ADMIN_USER)
$TEAMPOSTGRESQL_ANONYMOUS_ACCESS (default 40 or 10 if $TEAMPOSTGRESQL_ADMIN_USER is set )
$TEAMPOSTGRESQL_COOKIES_ENABLED (default: true)
$TEAMPOSTGRESQL_DATA_DIRECTORY (default: /tmp)
$TEAMPOSTGRESQL_HTTPS (default: DISABLED)
$TEAMPOSTGRESQL_DEFAULT_HOST (default: unset)
$TEAMPOSTGRESQL_DEFAULT_PORT (default: 5432)
$TEAMPOSTGRESQL_DEFAULT_USERNAME (default: postgres)
$TEAMPOSTGRESQL_DEFAULT_PASSWORD (default: postgres)
$TEAMPOSTGRESQL_DEFAULT_DATABASENAME (default: postgres)
$TEAMPOSTGRESQL_DEFAULT_SSL (default: false)
```

## define env vars
```
TNS=team-postgresql
SCC=my-scc-anyuid
SA=my-sa-anyuid
TP_NAME=team-postgresql
TP_IMAGE=teampostgresql/teampostgresql:latest
TP_FILE_EV=./team-postgresql-env-vars
```

## create scc
```
cat << EOF | oc create -f -
kind: SecurityContextConstraints
apiVersion: v1
metadata:
  name: ${SCC}
allowPrivilegedContainer: true
runAsUser:
  type: RunAsAny 
seLinuxContext:
  type: RunAsAny
fsGroup:
  type: RunAsAny 
EOF
```

## create deployment env vars
```
cat << EOF > ./team-postgresql-env-vars
# web app
TEAMPOSTGRESQL_PORT=8082
TEAMPOSTGRESQL_ADMIN_USER=admin
TEAMPOSTGRESQL_ADMIN_PASSWORD=passw0rd
TEAMPOSTGRESQL_COOKIES_ENABLED=true
TEAMPOSTGRESQL_DATA_DIRECTORY="/tmp"
TEAMPOSTGRESQL_HTTPS=DISABLED

# postgres server
TEAMPOSTGRESQL_DEFAULT_HOST=my-postgresql-1.team-postgresql.svc.cluster.local
TEAMPOSTGRESQL_DEFAULT_PORT=5432
TEAMPOSTGRESQL_DEFAULT_USERNAME=postgres
TEAMPOSTGRESQL_DEFAULT_PASSWORD=post01gres
TEAMPOSTGRESQL_DEFAULT_DATABASENAME=postgres
TEAMPOSTGRESQL_DEFAULT_SSL=false
EOF
```

## must be cluster admin
```
oc new-project ${TNS}
oc create sa ${SA}
oc adm policy add-scc-to-user ${SCC} system:serviceaccount:${TNS}:${SA}
```

## deploy app
```
oc new-app --docker-image=${TP_IMAGE} --name=${TP_NAME} --env-file=${TP_FILE_EV}
oc scale ${TP_IMAGE} --replicas=0
oc set serviceaccount deployment ${TP_NAME} ${SA}
oc patch deployment/${TP_NAME} --patch '{"spec":{"template":{"spec":{"securityContext":{"runAsUser":0}}}}}'      
oc expose deployment ${TP_NAME} --port=8082
oc expose service ${TP_NAME} --name=route-${TP_NAME}
oc scale ${TP_IMAGE} --replicas=1
```

## get url
```
URL=http://$(oc get route route-team-postgresql -o jsonpath='{.spec.host}')
echo ${URL}
```
