#!/usr/bin/bash

#Java installation
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

#Docker installation

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
#Jenkins installation
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y


#Initial setup cancellation
sudo systemctl stop jenkins
echo '2.0' > /var/lib/jenkins/jenkins.install.UpgradeWizard.state
sudo systemctl start jenkins #Start required 

#Security cancellation
sudo systemctl stop jenkins
sudo sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/' /var/lib/jenkins/config.xml
sudo systemctl start jenkins

#Jenkins CLI move.
sudo wget -O /var/lib/jenkins/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar


#Plugin install
sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 install-plugin \
ant antisamy-markup-formatter build-timeout cloudbees-folder credentials-binding \
dark-theme email-ext git github-branch-source gradle ldap mailer matrix-auth \
pam-auth pipeline-github-lib pipeline-graph-view ssh-slaves timestamper docker-ipeline \
workflow-aggregator ws-cleanup

sudo systemctl restart jenkins

#Pipeline

GIT_TOKEN=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

echo '<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>                                      
<scope>GLOBAL</scope>
  <id>git</id>
  <description></description>
  <username></username>
  <password>
    ${GIT_TOKEN}
  </password>                                                                                                            
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>'\
 | sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080/ \
   create-credentials-by-xml system::system::jenkins _

