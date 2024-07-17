#!/usr/bin/bash

#Java installation
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

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
pam-auth pipeline-github-lib pipeline-graph-view ssh-slaves timestamper \
workflow-aggregator ws-cleanup

sudo systemctl restart jenkins

#Pipeline
