# Cosmetic changes
hammer organization update --id 1 --name Demo
hammer location update --id 2 --name $CITY

# Content 1/2
hammer lifecycle-environment create --organization Demo --name Dev --prior Library
hammer lifecycle-environment create --organization Demo --name Prod --prior Dev

hammer content-view create --organization Demo --name RHEL9 --composite --auto-publish true

hammer content-view create --organization Demo --name OS --repository-ids 4
hammer content-view create --organization Demo --name Apps --repository-ids 3
hammer content-view create --organization Demo --name Tools --repository-ids 8

hammer content-view component add --organization Demo --composite-content-view RHEL9 --latest --component-content-view OS
hammer content-view component add --organization Demo --composite-content-view RHEL9 --latest --component-content-view Apps
hammer content-view component add --organization Demo --composite-content-view RHEL9 --latest --component-content-view Tools

hammer content-view publish --organization Demo --name OS --lifecycle-environments Dev,Prod
hammer content-view publish --organization Demo --name Apps --lifecycle-environments Dev,Prod
hammer content-view publish --organization Demo --name Tools --lifecycle-environments Dev,Prod

hammer content-view publish --organization Demo --lifecycle-environments Dev,Prod --name OS
hammer content-view publish --organization Demo --lifecycle-environments Dev,Prod --name Apps
hammer content-view publish --organization Demo --lifecycle-environments Dev,Prod --name Tools

# Hosts configuration
ssh-copy-id -o Stricthostkeychecking=no -i ~foreman-proxy/.ssh/id_rsa_foreman_proxy.pub root@rhel1
ssh-copy-id -o Stricthostkeychecking=no -i ~foreman-proxy/.ssh/id_rsa_foreman_proxy.pub root@rhel2

ssh -o Stricthostkeychecking=no rhel1 wget https://satellite.lab/pub/katello-ca-consumer-latest.noarch.rpm --no-check-certificate
ssh -o Stricthostkeychecking=no rhel1 dnf install katello-ca-consumer-latest.noarch.rpm -y
ssh -o Stricthostkeychecking=no rhel1 dnf history undo 12 --allowerasing -y &

ssh -o Stricthostkeychecking=no rhel2 wget https://satellite.lab/pub/katello-ca-consumer-latest.noarch.rpm --no-check-certificate
ssh -o Stricthostkeychecking=no rhel2 dnf install katello-ca-consumer-latest.noarch.rpm -y
ssh -o Stricthostkeychecking=no rhel2 dnf history undo 12 --allowerasing -y &

# Content 2/2
hammer content-view publish --organization Demo --lifecycle-environments Dev,Prod --name RHEL9

hammer activation-key create --organization Demo --content-view RHEL9 --lifecycle-environment Dev --name RHEL9_Dev
hammer activation-key create --organization Demo --content-view RHEL9 --lifecycle-environment Prod --name RHEL9_Prod

# Hosts registration
ssh -o Stricthostkeychecking=no rhel1 subscription-manager register --org Acme_Org --activationkey RHEL9_Dev
ssh -o Stricthostkeychecking=no rhel2 subscription-manager register --org Acme_Org --activationkey RHEL9_Prod

# Compliance
hammer scap-content bulk-upload --type default
hammer policy create --organization Demo --deploy-by ansible --name "Hardening Baseline" --scap-content-id 1 --scap-content-profile-id 9 --period weekly --weekday saturday

hammer hostgroup create --name Red --ansible-role-ids 1,5,62 --openscap-proxy-id 1
hammer host update --hostgroup Red --name rhel1
hammer host update --hostgroup Red --name rhel2
