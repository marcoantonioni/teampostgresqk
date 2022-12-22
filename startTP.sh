#!/bin/bash

TP_HOME=/opt/teampostgresql

set -eo pipefail

#---------------------------
# set env vars (with default values if not set)
setEnvVars() {

        if [[ "$TEAMPOSTGRESQL_ADMIN_USER" ]]; then
                export TEAMPOSTGRESQL_ANONYMOUS_ACCESS=${TEAMPOSTGRESQL_ANONYMOUS_ACCESS:-10}
        else
                export TEAMPOSTGRESQL_ANONYMOUS_ACCESS=${TEAMPOSTGRESQL_ANONYMOUS_ACCESS:-40}
        fi

        export TEAMPOSTGRESQL_PORT=${TEAMPOSTGRESQL_PORT:-8082}
        export TEAMPOSTGRESQL_COOKIES_ENABLED=${TEAMPOSTGRESQL_COOKIES_ENABLED:-true}
        export TEAMPOSTGRESQL_DATA_DIRECTORY=${TEAMPOSTGRESQL_DATA_DIRECTORY:-/tmp}
        export TEAMPOSTGRESQL_HTTPS=${TEAMPOSTGRESQL_HTTPS:-DISABLED}

        if [[ "$TEAMPOSTGRESQL_DEFAULT_HOST" ]]; then
                export TEAMPOSTGRESQL_DEFAULT_PORT=${TEAMPOSTGRESQL_DEFAULT_PORT:-5432}
                export TEAMPOSTGRESQL_DEFAULT_USERNAME=${TEAMPOSTGRESQL_DEFAULT_USERNAME:-postgres}
                export TEAMPOSTGRESQL_DEFAULT_PASSWORD=${TEAMPOSTGRESQL_DEFAULT_PASSWORD:-postgres}
                export TEAMPOSTGRESQL_DEFAULT_DATABASENAME=${TEAMPOSTGRESQL_DEFAULT_DATABASENAME:-postgres}
                export TEAMPOSTGRESQL_DEFAULT_SSL=${TEAMPOSTGRESQL_DEFAULT_SSL:-false}
        fi
        
}


#---------------------------
updateTeampostgresqlConfiguration() {

cat<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<config>
<adminuser>$TEAMPOSTGRESQL_ADMIN_USER</adminuser>
<adminuserpassword>$TEAMPOSTGRESQL_ADMIN_PASSWORD</adminuserpassword>
<anonymousaccess>$TEAMPOSTGRESQL_ANONYMOUS_ACCESS</anonymousaccess>
<anonymousprofile>$TEAMPOSTGRESQL_ANONYMOUS_PROFILE</anonymousprofile>
<cookiesenabled>$TEAMPOSTGRESQL_COOKIES_ENABLED</cookiesenabled>
<datadirectory>$TEAMPOSTGRESQL_DATA_DIRECTORY</datadirectory>
<https>$TEAMPOSTGRESQL_HTTPS</https>
EOF

if printenv | grep -q "^TEAMPOSTGRESQL_DEFAULT_"; then
cat<<EOF
<defaultdatabase>
EOF

printenv | grep "^TEAMPOSTGRESQL_DEFAULT_" | cut -f3- -d_ | while read var; do
        val="${var#*=}"
        var="${var%%=*}"
        var="$(echo $var | sed -e 's/_/-/g' | tr '[:upper:]' '[:lower:]')"
        echo "<$var>$val</$var>"
done

cat<<EOF
</defaultdatabase>
EOF

fi

cat<<EOF
</config>
EOF

}

#---------------------------
setConfiguration() {

  updateTeampostgresqlConfiguration > "${TP_HOME}/webapp/WEB-INF/teampostgresql-config.xml" 

  echo "=========================================================="
  echo "==> Running with teampostgresql-config.xml"
  cat ${TP_HOME}/webapp/WEB-INF/teampostgresql-config.xml
  echo "=========================================================="

}

#---------------------------
runTeamPostgresql() {
  cd ${TP_HOME}/webapp
  java -cp ${TP_HOME}/webapp/WEB-INF/lib/log4j-1.2.17.jar-1.0.jar:${TP_HOME}/webapp/WEB-INF/classes:${TP_HOME}/webapp/WEB-INF/lib/* dbexplorer.TeamPostgreSQL $TEAMPOSTGRESQL_PORT . /teampostgresql/webapp
}

#---------------------------
setEnvVars
setConfiguration
runTeamPostgresql
