+++
title = 'Create Mysql on a new server with Docker'
date = 2024-05-27T10:44:51+08:00
draft = false
+++

**1. Log in with SSH**
![png](/img/docker_create_mysql/01.png)

**2. Install Docker**
```
# Update Package Lists:
sudo apt update

# Install Required Packages:
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker’s Official GPG Key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set Up the Stable Repository:
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update Package Lists Again:
sudo apt update

# Install Docker Engine:
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Verify Docker Installation:
sudo docker --version

```
![png](/img/docker_create_mysql/02.png)

**3. Pull MySQL Image from Docker Hub: Fetch the latest MySQL 8.0 Docker image**
```
sudo docker pull mysql:8.0
```
![png](/img/docker_create_mysql/03.png)

**4. Prepare a config file for remote connection**
create a folder
```
mkdir -p ~/mysql-docker-config
```

in the folder create a file named my.cnf, put below content and save.
```
[mysqld]
bind-address = 0.0.0.0
```

**5. Run MySQL Container: Create and start a new MySQL container. Replace your_root_password with a strong password for the root user.**
```
sudo docker run --name mysql-container -d \
    -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD=your_root_password \
    -v ~/mysql-docker-data:/var/lib/mysql \
    -v ~/mysql-docker-config/my.cnf:/etc/mysql/my.cnf \
    mysql:8.0
```

**6. Provide the root user remote visit access**
```
sudo docker exec -it mysql-container bash
mysql -u root -p
```
in mysql write below code:
```
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'your_root_password';
FLUSH PRIVILEGES;
```

