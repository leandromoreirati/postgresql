FROM debian:latest
LABEL maintainer Leandro Moreira <leandro@leandromoreirati.com.br>

COPY configs/   /tmp/configs/

RUN dpkg -i /tmp/configs/zabbix-release_3.4-1+stretch_all.deb && \
    cat /usr/share/doc/apt/examples/sources.list > /etc/apt/sources.list && \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y postgresql-9.6 postgresql-client-9.6 vim zabbix-agent sudo vim && \
    mv -v /tmp/configs/pg_hba.conf /etc/postgresql/9.6/main/pg_hba.conf && \
    chown -R postgres.postgres /var/lib/postgresql && \
    chown -R postgres.postgres /etc/postgresql && \
    mv -v /tmp/configs/postgresql.conf /etc/postgresql/9.6/main/postgresql.conf && \
    mv -v /tmp/configs/zabbix.sql /var/lib/postgresql/ && \
    mv -v /tmp/configs/create.sql.gz /var/lib/postgresql/ && \
    mv -v /tmp/configs/zabbix_agentd.conf /etc/zabbix/ && \
    mv -v /tmp/configs/userparameters_postgresql.conf /etc/zabbix/zabbix_agentd.d/ && \
    mv -v /tmp/configs/scripts /etc/zabbix/zabbix_agentd.d/ && \
    mv -v /tmp/configs/ntp.conf /etc/ && \
    mv -v /tmp/configs/sudoers /etc/ && \
    mv -v /tmp/configs/setup.sh /usr/bin/ && \
    rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    rm -rfv /tmp/* && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

WORKDIR /var/lib/postgresql

EXPOSE 5432/TCP

#USER postgres

#ENTRYPOINT [ setup.sh ]
