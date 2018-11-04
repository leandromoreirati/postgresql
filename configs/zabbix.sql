create user $PGSQL_ZABBIX_USER with encrypted password '$PGSQL_ZABBIX_PASS';

create database $PGSQL_ZABBIX_BD;

grant all privileges on database $PGSQL_ZABBIX_BD to $PGSQL_ZABBIX_USER;

alter database $PGSQL_ZABBIX_BD owner to $PGSQL_ZABBIX_USER;
