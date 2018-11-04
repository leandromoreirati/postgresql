#!/bin/bash
set -x

sudo sed -i 's|$NET|'$NET'|g'                               /etc/postgresql/9.6/main/pg_hba.conf
sudo sed -i 's/$PGSQL_ZABBIX_USER/'$PGSQL_ZABBIX_USER'/g'   /etc/postgresql/9.6/main/pg_hba.conf
sudo sed -i 's/$PGSQL_ZABBIX_BD/'$PGSQL_ZABBIX_BD'/g'       /etc/postgresql/9.6/main/pg_hba.conf
sudo sed -i 's/$PGSQL_ZABBIX_PASS/'$PGSQL_ZABBIX_PASS'/g'   /etc/postgresql/9.6/main/pg_hba.conf
sudo sed -i 's/$ZBX_SERVER_NAME/'$ZBX_SERVER_NAME'/g'       /etc/zabbix/zabbix_agentd.conf
sudo sed -i 's/$MAX_CONNECTIONS/'$MAX_CONNECTIONS'/g'       /etc/postgresql/9.6/main/postgresql.conf

chown -R postgres.postgres /var/lib/postgresql/

chown -R postgres.postgres /etc/postgresql

service postgresql start && service zabbix-agent start

# CRIANDO DATABASE,USUARIO E PRIVILEGIOS

su - postgres -c "psql -c \"create user $PGSQL_ZABBIX_USER with encrypted password '$PGSQL_ZABBIX_PASS';\""

su - postgres -c "psql -c \"create database $PGSQL_ZABBIX_BD;\""

su - postgres -c "psql -c \"grant all privileges on database $PGSQL_ZABBIX_BD to $PGSQL_ZABBIX_USER;\""

su - postgres -c "psql -c \"alter database $PGSQL_ZABBIX_BD owner to $PGSQL_ZABBIX_USER;\""

# CARREGANDO SCHEMA DO BANCO DE DADOS
export PGPASSWORD=$PGSQL_ZABBIX_PASS

$(which zcat) /var/lib/postgresql/create.sql.gz | $(which psql) -U zabbix -d zabbix

# CONFIGURANDO MONITORAMENTO DO BANCO DE DADOS

mkdir /var/lib/zabbix

echo "localhost:5432:$PGSQL_ZABBIX_USER:$PGSQL_ZABBIX_BD:$PGSQL_ZABBIX_PASS" > /var/lib/zabbix/.pgpass

chown zabbix.zabbix -R /var/lib/zabbix

chmod 400 /var/lib/zabbix/.pgpass

rm /etc/zabbix/zabbix_agentd.d/*_mysql*

chown zabbix.zabbix -R /etc/zabbix/zabbix_agentd.d/scripts

rm -v /var/lib/postgresql/create.sql.gz

rm -v /var/lib/postgresql/zabbix.sql

service postgresql restart && tailf /var/log/postgresql/postgresql-9.6-main.log
set +x
