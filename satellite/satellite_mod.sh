# Cosmetic changes
hammer organization update --id 1 --name Demo
hammer location update --id 2 --name $CITY

# Content 1/2
hammer lifecycle-environment create --organization Demo --name Dev --prior Library
hammer lifecycle-environment create --organization Demo --name Prod --prior Dev

hammer content-view create --organization Demo --name RHEL9 --composite --auto-publish true

hammer content-view create --organization Demo --name OS --repository-ids 4
hammer content-view create --organization Demo --name Apps --repository-ids 3
hammer content-view create --organization Demo --name Tools --repository-ids 6

hammer content-view component add --organization Demo --composite-content-view RHEL9 --latest --component-content-view OS
hammer content-view component add --organization Demo --composite-content-view RHEL9 --latest --component-content-view Apps
hammer content-view component add --organization Demo --composite-content-view RHEL9 --latest --component-content-view Tools

hammer content-view publish --organization Demo --lifecycle-environments Dev,Prod --name OS
hammer content-view publish --organization Demo --lifecycle-environments Dev,Prod --name Apps
hammer content-view publish --organization Demo --lifecycle-environments Dev,Prod --name Tools

# Hosts configuration
ssh-copy-id -o Stricthostkeychecking=no -i ~foreman-proxy/.ssh/id_rsa_foreman_proxy.pub root@rhel1
ssh-copy-id -o Stricthostkeychecking=no -i ~foreman-proxy/.ssh/id_rsa_foreman_proxy.pub root@rhel2

ssh -o Stricthostkeychecking=no rhel1 wget https://satellite.lab/pub/katello-ca-consumer-latest.noarch.rpm --no-check-certificate
ssh -o Stricthostkeychecking=no rhel1 dnf install katello-ca-consumer-latest.noarch.rpm -y

ssh -o Stricthostkeychecking=no rhel2 wget https://satellite.lab/pub/katello-ca-consumer-latest.noarch.rpm --no-check-certificate
ssh -o Stricthostkeychecking=no rhel2 dnf install katello-ca-consumer-latest.noarch.rpm -y

# Content 2/2
hammer content-view publish --organization Demo --lifecycle-environments Dev,Prod --name RHEL9

hammer activation-key create --organization Demo --content-view RHEL9 --lifecycle-environment Dev --name RHEL9_Dev
hammer activation-key create --organization Demo --content-view RHEL9 --lifecycle-environment Prod --name RHEL9_Prod
hammer activation-key content-override --id 1 --content-label satellite-client-6-for-rhel-9-x86_64-rpms --override-name enabled --value 1
hammer activation-key content-override --id 2 --content-label satellite-client-6-for-rhel-9-x86_64-rpms --override-name enabled --value 1

# Hosts registration
ssh -o Stricthostkeychecking=no rhel1 subscription-manager register --org Acme_Org --activationkey RHEL9_Dev
ssh -o Stricthostkeychecking=no rhel2 subscription-manager register --org Acme_Org --activationkey RHEL9_Prod
# ssh -o Stricthostkeychecking=no rhel1 dnf history undo 12 --allowerasing -y 1>/dev/null &
# ssh -o Stricthostkeychecking=no rhel2 dnf history undo 12 --allowerasing -y

# Compliance
hammer ansible roles sync --proxy-id 1 --role-names theforeman.foreman_scap_client
## Assign cockpit and scap roles
hammer hostgroup create --name Red --openscap-proxy-id 1 --ansible-role-ids 2,6

hammer scap-content bulk-upload --type default
hammer policy create --organization Demo --deploy-by ansible --name "Hardening Baseline" --scap-content-id 1 --scap-content-profile-id 9 --period weekly --weekday saturday --hostgroups Red

hammer host update --hostgroup Red --name rhel1
hammer host update --hostgroup Red --name rhel2


## Run Ansible roles
hammer job-invocation create --job-template-id 235 --search-query 'id ^ (2,3)'
## Run OpenSCAP scan
hammer job-invocation create --job-template-id 248 --search-query 'id ^ (2,3)' &

# EPEL
hammer product create --organization Demo --name "Extra packages for Enterprise Linux"
hammer repository create --organization Demo --content-type yum --name "Extra Packages for Enterprise Linux 9 x86_64" --product "Extra packages for Enterprise Linux" --url "https://mirror.in2p3.fr/pub/epel/9/Everything/x86_64/"
hammer repository synchronize --organization Demo --name "Extra Packages for Enterprise Linux 9 x86_64" --product "Extra packages for Enterprise Linux"
hammer content-view create --organization Demo --name EPEL --repository-ids 78
hammer content-view publish --organization Demo --lifecycle-environments Dev,Prod --name EPEL
