!#/bin/bash
hammer organization update --id 1 --name Demo
hammer location update --id 2 --name Paris

hammer content-view create --organization Demo --name OS --repository-ids 4
hammer content-view create --organization Demo --name Apps --repository-ids 3

hammer content-view create --organization Demo --name RHEL9 --composite --auto-publish true
hammer content-view component add --organization Demo --composite-content-view RHEL9 --latest --component-content-view OS
hammer content-view component add --organization Demo --composite-content-view RHEL9 --latest --component-content-view Apps

hammer lifecycle-environment create --organization Demo --name Dev --prior Library
hammer lifecycle-environment create --organization Demo --name Prod --prior Dev

hammer content-view publish --organization Demo --name OS --lifecycle-environments Dev,Prod
hammer content-view publish --organization Demo --name Apps --lifecycle-environments Dev,Prod


hammer content-view publish --organization Demo --lifecycle-environments Dev,Prod --name OS
hammer content-view publish --organization Demo --lifecycle-environments Dev,Prod --name Apps


ssh-copy-id -i ~foreman-proxy/.ssh/id_rsa_foreman_proxy.pub root@rhel1
ssh-copy-id -i ~foreman-proxy/.ssh/id_rsa_foreman_proxy.pub root@rhel2

ssh -o Stricthostkeychecking=no rhel1 wget https://satellite.lab/pub/katello-ca-consumer-latest.noarch.rpm --no-check-certificate
ssh -o Stricthostkeychecking=no rhel1 dnf install katello-ca-consumer-latest.noarch.rpm -y

ssh -o Stricthostkeychecking=no rhel2 wget https://satellite.lab/pub/katello-ca-consumer-latest.noarch.rpm --no-check-certificate
ssh -o Stricthostkeychecking=no rhel2 dnf install katello-ca-consumer-latest.noarch.rpm -y

hammer scap-content bulk-upload --type default

# We're doing this one later because of lock issue
hammer content-view publish --organization Demo --lifecycle-environments Dev,Prod --name RHEL9

hammer activation-key create --organization Demo --content-view RHEL9 --lifecycle-environment Dev --name RHEL9_Dev
hammer activation-key create --organization Demo --content-view RHEL9 --lifecycle-environment Prod --name RHEL9_Prod

ssh -o Stricthostkeychecking=no rhel1 subscription-manager register --org Acme_Org --activationkey RHEL9_Dev
ssh -o Stricthostkeychecking=no rhel2 subscription-manager register --org Acme_Org --activationkey RHEL9_Prod
