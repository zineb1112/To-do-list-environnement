# 1. Start with official Ubuntu LTS
FROM ubuntu:latest

# 2. Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# 3. Install MariaDB Server and clean apt cache to keep image lightweight
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# 4. Configure MariaDB to accept connections from outside the container
RUN sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# 5. Expose default MariaDB Port
EXPOSE 3306

# 6. Initialize database system files and start safe database engine as main process
CMD ["sh", "-c", "mysql_install_db --user=mysql --datadir=/var/lib/mysql && mysqld_safe --user=mysql --datadir=/var/lib/mysql"]