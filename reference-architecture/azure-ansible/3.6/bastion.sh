#!/bin/bash

export MYARGS=$@
IFS=' ' read -r -a array <<< "$MYARGS"
export RESOURCEGROUP=$1
export WILDCARDZONE=$2
export AUSERNAME=$3
export PASSWORD=$4
export THEHOSTNAME=$5
export NODECOUNT=$6
export ROUTEREXTIP=$7
export RHNUSERNAME=$8
export RHNPASSWORD=$9
export RHNPOOLID_BROKER=${10}
export RHNPOOLID=${11}
export SSHPRIVATEDATA=${12}
export SSHPUBLICDATA=${13}
export SSHPUBLICDATA2=${14}
export SSHPUBLICDATA3=${15}
export REGISTRYSTORAGENAME=${array[15]}
export REGISTRYKEY=${array[16]}
export LOCATION=${array[17]}
export SUBSCRIPTIONID=${array[18]}
export TENANTID=${array[19]}
export AADCLIENTID=${array[20]}
export AADCLIENTSECRET=${array[21]}
export RHSMMODE=${array[22]}
export OPENSHIFTSDN=${array[23]}
export METRICS=${array[24]}
export LOGGING=${array[25]}
export OPSLOGGING=${array[26]}
export GITURL=${array[27]}
export CUSTOMWILDCARD=${array[28]}
export CUSTOMPUBLICHOSTNAME=${array[29]}
export PORTALNET=${array[30]}
export CLUSTERNET=${array[31]}
export MASTERKEY=${array[32]}
export MASTERCERT=${array[33]}
export MASTERCA=${array[34]}
export ROUTERKEY=${array[35]}
export ROUTERCERT=${array[36]}
export ROUTERCA=${array[37]}
export CUSTOMDNS=${array[38]}
export AUTOINSTALL=${array[39]}
export IDENTITYPROVIDERS=${array[40]}
export FULLDOMAIN=${THEHOSTNAME#*.*}
# for lab / dev + spec for prod remove spec
export WILDCARDFQDN=${WILDCARDZONE}spec.${FULLDOMAIN}
export WILDCARDIP=`dig +short ${WILDCARDFQDN}`
export WILDCARDNIP=${WILDCARDIP}.nip.io
export LOGGING_ES_INSTANCES="3"
export OPSLOGGING_ES_INSTANCES="3"
export METRICS_INSTANCES="1"
export LOGGING_ES_SIZE="500"
export OPSLOGGING_ES_SIZE="10"
export METRICS_CASSANDRASIZE="200"
export APIHOST=$RESOURCEGROUP.$FULLDOMAIN

if [[ ${CUSTOMWILDCARD} != 'false' ]]; then
  WILDCARDFQDN=${CUSTOMWILDCARD}
else
  WILDCARDFQDN=${WILDCARDNIP}

fi

if [[ ${CUSTOMPUBLICHOSTNAME} != 'false' ]]; then
  PUBLICHOSTNAME=${CUSTOMPUBLICHOSTNAME}
else
  PUBLICHOSTNAME=${RESOURCEGROUP}.${FULLDOMAIN}
fi


echo "Show wildcard info"
echo $WILDCARDFQDN
echo $WILDCARDIP
echo $WILDCARDFQDN
echo $PUBLICHOSTNAME
echo $RHSMMODE
echo $GITURL

echo 'Show Registry Values'
echo $REGISTRYSTORAGENAME
echo $REGISTRYKEY
echo $LOCATION
echo $SUBSCRIPTIONID
echo $TENANTID
echo $AADCLIENTID
echo $AADCLIENTSECRET

domain=$(grep search /etc/resolv.conf | awk '{print $2}')

ps -ef | grep bastion.sh > cmdline.out

systemctl enable dnsmasq.service
systemctl start dnsmasq.service

# add users for octopus and bamboo
useradd -md /home/bamboo -s /bin/bash bamboo
useradd -md /home/octopus -s /bin/bash octopus
mkdir -m 700 /home/bamboo/.ssh
mkdir -m 700 /home/octopus/.ssh

cat > /home/bamboo/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDquVPz50NcZHo4NHFH4wKKJulZZOet0lx0XhvAhKScve+ujgyl564Sebz0BcJH2F+Kev4LjKHn2CsCmDISAxg+icgkjUb8B8QcFI78uK1byy1NaZMdQ6O5mXHaDyWv0LGQby29rxTBM5rQJWuyqJ9x7MLlnPd2FxGqTq8RRzENGJXNFA7TUtYDPFqWkVCrfswIjEfcPCr8/+aotKNnt8egPJwXs2uD1BZRhiKH0HmEyLfpszno1UKYV7HCfm4kX6KyUR2stQy7mrnmoMt8KtOc5MsUtuGew+qdep2bRinQY/P6xQo+8uryQUdtzSDVRC9rBc0ISYbncLUyy87g7qUj bamboo@bastion
EOF

cat > /home/octopus/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD1mk5kxkiV9MVOzM+lwn6fWtUwqj7UWrRB7+UHwR9tMVCAeXZitAO0u+kKFwcC5RaHF3YBYbCJQU8vH/GOkbxrbWHMJDfZWG+brX5QCTRthtA/PWTdRsivjCEyb70Yq2aaw9G8ygYTJG0uGNaybvWqiEC6OkPROXxbiTz4Zs7uQhjpy1man5z3Oye0DhYBYN6ehUwfFPf0HlKYsGD4izl3XEwOVxFNlSSN3piVgeqf/NtZ7JXntvz2TVPhBaH/Kp5tbetfEvJLNDETFlFlSBDBRjablJ0Ivg63ka8w7GqV718WN0Q5xpxxGD9+sIHdaLQ5dlJoQjQMZEyGt4KKjp7x octopus@bastion
EOF
chmod 644 /home/bamboo/.ssh/authorized_keys
chmod 644 /home/octopus/.ssh/authorized_keys
chown -R  octopus:octopus /home/octopus
chown -R  bamboo:bamboo /home/bamboo
###

# add other local user accounts
for USER in clasohm jhorn jmcdonough tuttle; do
    useradd -G wheel $USER
    mkdir -m 700 /home/$USER/.ssh
done

cat >/home/clasohm/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtENPMx0/h3RyvlPGeuWPM/g08D1DE0D914XMcIvYdR6ryD+gpMoRTfTMkIHmiaSNe1+Dd1yYzaT6CvWNZ0kyfLA9VKaVkqut7yWagaZOC8vBUKx2vUpJkw9OjeW+X9KDmTgaGnbc4eQm/ey+XPLRmwBLrxvtJ5dTLVrD3L6KQ/9HSPx898V+PmqSE9S+5hDXBpbA5r2R0DPlo0yFkaOJEaJ+BFZbcqX40t+MMRFdnPAS45BgSW1fqD3bDFXkzsdTOq3C7Z5ihCWMFcPxL0Ifp3o/LWEHRVh7N/rilZko+B/o3OP0iFHsIgJ9RIxahGQh4MlMU5ivI9v3ReL1x2icNQ== clasohm
EOF

cat >/home/jhorn/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzlRETx5/d/53o+hjWc+LKXhayVxhBYXoPUTQwBto2bX/JYaD9+Lxrq+2jxGngj6J96YcWfM4r9jm4ejBgC2gEnIJ60MQNEIlJIdVuBAY3y4Koi1dhrXWGcUp29cgEeav7uSuQHimAn0Z3jIVDXqMruIVdCZtx0pP2VWoxwQY8Y3/6+ZNgT2RkDNw+BsbEnaOkNLrP1ezPK5IwoFdoRJEPz3vzZzZzRyAzYOletFjSUSqCV2YgtKoShp/ErdeBn47AULDQ9jquXqI/MQYgCI84op7gjjT40sUoLsg6PuuWKzdEMxwHjYNaCwrqQArl7F0bWDT3H1QSK1fKHB0yXI3j jhorn
EOF

cat >/home/jmcdonough/.ssh/authorized_keys <<EOF
EOF

cat >/home/tuttle/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5Tnh1DfnYwtwWZPzcXdfyZfJwWc6jGwhtjYZmy6gkKuSa0ETmTQpwY9WTA+/SncieoQLb3x9kHFrlO4Ofh4SHm6+TY75HA972I4L3+Vmz5W/2Ly7nTiXLP1R/O4Tc4RjFIChBvE0Gz4UQMkJgVB/aJcTJEMHRoj0R3mHK4kSpohVv29LKoSDtH821v2CC0Ih8Aw1qs0qjhlY4ovB3kgwzpO12RPwjrWWplynubRjxnSfrA7P//Wy3l9foRn5ka0+R3jCQb1K+HTz3EXANKIqh/FCgqsftIeUi0q1jUJz9oQxHoNFwcCkSkObOmu27w+ulZ1+yknmjZlOEH6RMZhLR h278331@ga69mln0002b9
EOF

for USER in clasohm jhorn jmcdonough tuttle; do
    chown -R $USER:$USER /home/$USER/.ssh
    chmod -R g-w /home/$USER/.ssh
done
###

echo "Resize Root FS"
rootdev=`findmnt --target / -o SOURCE -n`
rootdrivename=`lsblk -no pkname $rootdev`
rootdrive="/dev/"$rootdrivename
majorminor=`lsblk  $rootdev -o MAJ:MIN | tail -1`
part_number=${majorminor#*:}
yum install -y cloud-utils-growpart.noarch
growpart $rootdrive $part_number -u on
xfs_growfs $rootdev

mkdir -p /home/$AUSERNAME/.azuresettings
echo $REGISTRYSTORAGENAME > /home/$AUSERNAME/.azuresettings/registry_storage_name
echo $REGISTRYKEY > /home/$AUSERNAME/.azuresettings/registry_key
echo $LOCATION > /home/$AUSERNAME/.azuresettings/location
echo $SUBSCRIPTIONID > /home/$AUSERNAME/.azuresettings/subscription_id
echo $TENANTID > /home/$AUSERNAME/.azuresettings/tenant_id
echo $AADCLIENTID > /home/$AUSERNAME/.azuresettings/aad_client_id
echo $AADCLIENTSECRET > /home/$AUSERNAME/.azuresettings/aad_client_secret
echo $RESOURCEGROUP > /home/$AUSERNAME/.azuresettings/resource_group
chmod -R 600 /home/$AUSERNAME/.azuresettings/*
chown -R $AUSERNAME /home/$AUSERNAME/.azuresettings

mkdir -p /home/$AUSERNAME/.ssh
echo $SSHPUBLICDATA $SSHPUBLICDATA2 $SSHPUBLICDATA3 >  /home/$AUSERNAME/.ssh/id_rsa.pub
echo $SSHPRIVATEDATA | base64 --d > /home/$AUSERNAME/.ssh/id_rsa
chown $AUSERNAME /home/$AUSERNAME/.ssh/id_rsa.pub
chmod 600 /home/$AUSERNAME/.ssh/id_rsa.pub
chown $AUSERNAME /home/$AUSERNAME/.ssh/id_rsa
chmod 600 /home/$AUSERNAME/.ssh/id_rsa
cp /home/$AUSERNAME/.ssh/authorized_keys /root/.ssh/authorized_keys

mkdir -p /root/.azuresettings
echo $REGISTRYSTORAGENAME > /root/.azuresettings/registry_storage_name
echo $REGISTRYKEY > /root/.azuresettings/registry_key
echo $LOCATION > /root/.azuresettings/location
echo $SUBSCRIPTIONID > /root/.azuresettings/subscription_id
echo $TENANTID > /root/.azuresettings/tenant_id
echo $AADCLIENTID > /root/.azuresettings/aad_client_id
echo $AADCLIENTSECRET > /root/.azuresettings/aad_client_secret
echo $RESOURCEGROUP > /root/.azuresettings/resource_group
chmod -R 600 /root/.azuresettings/*
chown -R root /root/.azuresettings

mkdir -p /root/.ssh
echo $SSHPRIVATEDATA | base64 --d > /root/.ssh/id_rsa
echo $SSHPUBLICDATA $SSHPUBLICDATA2 $SSHPUBLICDATA3   >  /root/.ssh/id_rsa.pub
cp /home/$AUSERNAME/.ssh/authorized_keys /root/.ssh/authorized_keys
chown root /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/id_rsa.pub
chown root /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
chown root /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys


sleep 30
cat <<EOF > /root/setup_ssmtp.sh
# \$1 = Gmail Account (Leave off @gmail.com ie user)
# \$2 = Gmail Password
# \$3 = Notification email address
# Setup ssmtp mta agent for use with gmail
yum -y install wget
wget -c https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm
yum -y install ssmtp
alternatives --set mta  /usr/sbin/sendmail.ssmtp
mkdir /etc/ssmtp
cat <<EOFZ > /etc/ssmtp/ssmtp.conf
root=${1}
mailhub=mail
TLS_CA_File=/etc/pki/tls/certs/ca-bundle.crt
mailhub=smtp.gmail.com:587   # SMTP server for Gmail
Hostname=localhost
UseTLS=YES
UseSTARTTLS=Yes
FromLineOverride=YES #TO CHANGE FROM EMAIL
Root=\${3} # Redirect root email
AuthUser=\${1}@gmail.com
AuthPass=\${2}
AuthMethod=LOGIN
rewriteDomain=azure.com
EOFZ
cat <<EOFZ > /etc/ssmtp/revaliases
root:\${1}@gmail.com:smtp.gmail.com:587
EOFZ
EOF
chmod +x /root/setup_ssmtp.sh
# Continue even if ssmtp.sh script errors out
/root/setup_ssmtp.sh ${AUSERNAME} ${PASSWORD} ${RHNUSERNAME} || true

sleep 30
echo "${RESOURCEGROUP} Bastion Host is starting software update" | mail -s "${RESOURCEGROUP} Bastion Software Install" ${RHNUSERNAME} || true
# Continue Setting Up Bastion
subscription-manager unregister
yum -y remove RHEL7
rm -f /etc/yum.repos.d/rh-cloud.repo
# Found that wildcard disable not working all the time - make sure
yum-config-manager --disable epel
yum-config-manager --disable epel-testing
sleep 30
if [[ $RHSMMODE == "usernamepassword" ]]
then
   subscription-manager register --username="${RHNUSERNAME}" --password="${RHNPASSWORD}"
else
   subscription-manager register --org="${RHNPASSWORD}" --activationkey="${RHNUSERNAME}"
fi
subscription-manager remove --all
subscription-manager attach --pool=${RHNPOOLID_BROKER}
subscription-manager repos --disable="*"
subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-fast-datapath-rpms"
subscription-manager repos --enable="rhel-7-server-ose-3.7-rpms"
yum -y install atomic-openshift-utils git net-tools bind-utils iptables-services bridge-utils bash-completion httpd-tools nodejs qemu-img
yum -y install --enablerepo="epel" jq
touch /root/.updateok


if [[ ${CUSTOMDNS} != "false" ]]; then
  DOMAIN=$(echo ${CUSTOMDNS} | awk -F'=' '{print $1}')
  NAMESERVER=$(echo ${CUSTOMDNS} | awk -F'=' '{print $2}')
cat > /home/${AUSERNAME}/bastion-dnsmasq.yml <<EOF
- hosts: localhost
  gather_facts: yes
  become: yes
  vars:
    domain: ${DOMAIN}
    nameserver: ${NAMESERVER}
  tasks:
    - name: install dnsmasq
      yum:
        state: installed
        name: dnsmasq
      notify:
        - restart dnsmasq

    - name: create custom dnsmasq domain
      copy:
        content: |
          server=/{{ domain }}/{{ nameserver }}
        dest: /etc/dnsmasq.d/honeywell-dnsmasq.conf
      notify:
        - restart dnsmasq

    - name: update resolv.conf
      lineinfile:
        path: /etc/resolv.conf
        insertbefore: '^nameserver '
        line: 'nameserver {{ ansible_default_ipv4.address }}'

    - name: create dns.conf
      copy:
        content: |
          no-resolv
          domain-needed
          no-negcache
          max-cache-ttl=1
          enable-dbus
          bind-interfaces
          listen-address={{ ansible_default_ipv4.address }}
        dest: /etc/dnsmasq.d/dns.conf
      notify:
        - restart dnsmasq

    - name: create upstream-dns.conf
      copy:
        content: |
          server=168.63.129.16
        dest: /etc/dnsmasq.d/upstream-dns.conf
      notify:
        - restart dnsmasq


  handlers:
    - name: restart dnsmasq
      systemd:
        name: dnsmasq
        state: restarted
EOF


cat > /home/${AUSERNAME}/custom-dnsmasq-domain.yml <<EOF
- hosts: all
  gather_facts: no
  become: yes
  vars:
    domain: ${DOMAIN}
    nameserver: ${NAMESERVER}
  tasks:
    - name: ensure dnsmasq.d directory exists
      file:
        path: /etc/dnsmasq.d/
        state: directory
        mode: 0755

    - name: create custom dnsmasq domain
      copy:
        content: |
          server=/{{ domain }}/{{ nameserver }}
        dest: /etc/dnsmasq.d/honeywell-dnsmasq.conf
      notify:
        - restart dnsmasq

  handlers:
    - name: restart dnsmasq
      systemd:
        name: dnsmasq
        state: restarted
EOF

fi # end custom dns 

# Create azure.conf file

cat > /home/${AUSERNAME}/azure.conf <<EOF
{
   "tenantId": "$TENANTID",
   "subscriptionId": "$SUBSCRIPTIONID",
   "aadClientId": "$AADCLIENTID",
   "aadClientSecret": "$AADCLIENTSECRET",
   "aadTenantID": "$TENANTID",
   "resourceGroup": "$RESOURCEGROUP",
   "location": "$LOCATION",
   "useInstanceMetadata": true,
}
EOF

cat > /home/${AUSERNAME}/vars.yml <<EOF
g_tenantId: $TENANTID
g_subscriptionId: $SUBSCRIPTIONID
g_aadClientId: $AADCLIENTID
g_aadClientSecret: $AADCLIENTSECRET
g_resourceGroup: $RESOURCEGROUP
g_location: $LOCATION
EOF

# Create Azure Cloud Provider configuration Playbook

cat > /home/${AUSERNAME}/azure-config.yml <<EOF
#!/usr/bin/ansible-playbook
- hosts: all
  gather_facts: no
  vars_files:
  - vars.yml
  become: yes
  vars:
    azure_conf_dir: /etc/azure
    azure_conf: "{{ azure_conf_dir }}/azure.conf"
  tasks:
  - name: make sure /etc/azure exists
    file:
      state: directory
      path: "{{ azure_conf_dir }}"

  - name: populate /etc/azure/azure.conf
    copy:
      dest: "{{ azure_conf }}"
      content: |
        {
          "aadClientID" : "{{ g_aadClientId }}",
          "aadClientSecret" : "{{ g_aadClientSecret }}",
          "subscriptionID" : "{{ g_subscriptionId }}",
          "tenantID" : "{{ g_tenantId }}",
          "location" : "{{ g_location }}",
          "resourceGroup": "{{ g_resourceGroup }}",
          "useInstanceMetadata": true
        }
EOF

# Create Azure Cloud Provider configuration Playbook for Node Config

cat > /home/${AUSERNAME}/setup-azure-node.yml <<EOF
#!/usr/bin/ansible-playbook
- hosts: nodes
  gather_facts: yes
  become: yes
  vars:
    node_conf: /etc/origin/node/node-config.yaml
  tasks:
  - name: update multippath conf for MSFT
    blockinfile:
      path: /etc/multipath.conf
      insertafter: 'blacklist'
      block: |
        #
              device {
                      vendor  "Msft"
                      product "Virtual Disk"
              }


  - name: insert the azure disk config into the node
    modify_yaml:
      dest: "{{ node_conf }}"
      yaml_key: "{{ item.key }}"
      yaml_value: "{{ item.value }}"
    with_items:
    - key: kubeletArguments.cloud-config
      value:
      - /etc/azure/azure.conf

    - key: kubeletArguments.cloud-provider
      value:
      - azure

  - name: Deactivate openshift.local.volumes mount
    lineinfile:
      path: /etc/fstab
      regexp: 'UUID=([^ ]+) +/var/lib/origin/openshift.local.volumes.*'
      line: '#UUID=\1 /var/lib/origin/openshift.local.volumes xfs  defaults,gquota 1 2'
      backrefs: yes
      state: present
      backup: yes

  # Run the reboot asynchronously and let the managed system wait
  # for 1 minute before rebooting. If we reboot immediately, the 
  # SSH connection breaks and the playbook run for this host 
  # would be aborted.
  - name: Reboot node
    command: shutdown -r +1
    async: 600
    poll: 0

  - name: Wait for node to come back
    local_action: wait_for
    args:
      host: "{{ ansible_nodename }}"
      port: 22
      state: started
      # Wait for the reboot delay from the previous task plus 10 seconds.
      # Otherwise, the SSH port would still be open because the system
      # has not rebooted.
      delay: 70 
      timeout: 600
    register: wait_for_reboot

  - name: Activate openshift.local.volumes mount
    lineinfile:
      path: /etc/fstab
      regexp: 'UUID=([^ ]+) +/var/lib/origin/openshift.local.volumes.*'
      line: 'UUID=\1 /var/lib/origin/openshift.local.volumes xfs  defaults,gquota 1 2'
      backrefs: yes
      state: present
      backup: yes

  # Run the reboot asynchronously and let the managed system wait
  # for 1 minute before rebooting. If we reboot immediately, the 
  # SSH connection breaks and the playbook run for this host 
  # would be aborted.
  - name: Reboot node
    command: shutdown -r +1
    async: 600
    poll: 0

  - name: Wait for node to come back
    local_action: wait_for
    args:
      host: "{{ ansible_nodename }}"
      port: 22
      state: started
      # Wait for the reboot delay from the previous task plus 10 seconds.
      # Otherwise, the SSH port would still be open because the system
      # has not rebooted.
      delay: 70 
      timeout: 600
    register: wait_for_reboot

- hosts: nodes
  become: no
  tasks:
  - name: Wait for node state Ready
    shell: oc get node {{ ansible_nodename }} | grep -q ' Ready'
    ignore_errors: yes
    delegate_to: "{{ groups['masters'][0] }}"
    register: node_ready
    until: node_ready.rc == 0
    retries: 12
    delay: 10

- hosts: masters
  become: no
  tasks:
  - name: Mark masters as unschedulable
    command: oc adm manage-node {{ ansible_nodename }} --schedulable=false
    delegate_to: "{{ groups['masters'][0] }}"

  - name: Set master node labels
    command: oc label --overwrite node {{ ansible_nodename }} role=master zone=default logging=true
    delegate_to: "{{ groups['masters'][0] }}"

# There are no groups for infrastructure or application nodes in the inventory.
# The number of infranodes is fixed. For now, we assume that there are 3 application
# nodes.
- hosts: "{{ groups['masters'][0] }}"
  become: no
  tasks:
  - name: Set infranode labels
    command: oc label --overwrite node {{ item }} role=infra zone=default logging=true
    with_items:
    - infranode1
    - infranode2
    - infranode3

  - name: Set application node labels
    command: oc label --overwrite node {{ item }} role=app zone=default logging=true
    with_items:
    - node01
    - node02
    - node03
EOF

cat <<EOF > /etc/ansible/hosts
[OSEv3:children]
masters
nodes
etcd
new_nodes
new_masters

[OSEv3:vars]
# v3.7
# fix for kb 3376031 bz1551862
openshift_disable_check=package_version
openshift_release=3.7
deployment_type=openshift-enterprise
openshift_rolling_restart_mode=system
openshift_deployment_type=openshift-enterprise

openshift_enable_service_catalog=false
ansible_service_broker_install=false
template_service_broker_install=false
template_service_broker_selector={"role":"infra"}

osm_project_request_message=“To create a new project, contact your Team Admin.”

osm_controller_args={'cloud-provider': ['azure'], 'cloud-config': ['/etc/azure/azure.conf']}
osm_api_server_args={'cloud-provider': ['azure'], 'cloud-config': ['/etc/azure/azure.conf']}
openshift_node_kubelet_args={'enable-controller-attach-detach': ['true']}
debug_level=2
console_port=443
docker_udev_workaround=True
openshift_node_debug_level="{{ node_debug_level | default(debug_level, true) }}"
openshift_master_debug_level="{{ master_debug_level | default(debug_level, true) }}"
openshift_master_access_token_max_seconds=2419200
openshift_hosted_router_replicas=3
openshift_hosted_registry_replicas=3
openshift_master_api_port="{{ console_port }}"
openshift_master_console_port="{{ console_port }}"
openshift_override_hostname_check=true
osm_use_cockpit=false
openshift_pkg_version=-3.7.42
openshift_cloudprovider_kind=azure
openshift_node_local_quota_per_fsgroup=512Mi
azure_resource_group=${RESOURCEGROUP}
rhn_pool_id=${RHNPOOLID}
openshift_install_examples=true
openshift_master_identity_providers=$(echo $IDENTITYPROVIDERS | base64 --d)
openshift_master_manage_htpasswd=false

os_sdn_network_plugin_name=${OPENSHIFTSDN}

# default selectors for router and registry services
openshift_hosted_router_selector='role=infra'
openshift_hosted_registry_selector='role=infra'

# Select default nodes for projects
osm_default_node_selector="role=app"
ansible_become=yes
ansible_ssh_user=${AUSERNAME}
remote_user=${AUSERNAME}
EOF

if [[ ${MASTERCERT} != 'false' && ${MASTERKEY} != 'false' && ${MASTERCA} != 'false' ]]; then
  # Create files from data in vars
  CERTDIR="/home/${AUSERNAME}/certs"
  mkdir -p ${CERTDIR}
  echo ${MASTERCERT} | base64 --d  > ${CERTDIR}/master.crt
  echo ${MASTERKEY}  | base64 --d > ${CERTDIR}/master.key
  echo ${MASTERCA}   | base64 --d > ${CERTDIR}/master.ca
  cat <<EOF >> /etc/ansible/hosts
# MASTER Certificates
openshift_master_named_certificates=[{"certfile": "${CERTDIR}/master.crt", "keyfile": "${CERTDIR}/master.key", "cafile": "${CERTDIR}/master.ca", "names": ["${PUBLICHOSTNAME}"]}]
openshift_master_overwrite_named_certificates=true
EOF

fi

if [[ ${ROUTERCERT} != 'false'  && ${ROUTERKEY} != 'false' && ${ROUTERCA} != 'false' ]]; then
  CERTDIR="/home/${AUSERNAME}/certs"
  mkdir -p ${CERTDIR}
  echo ${ROUTERCERT} | base64 --d > ${CERTDIR}/router.crt
  echo ${ROUTERKEY}  | base64 --d > ${CERTDIR}/router.key
  echo ${ROUTERCA}   | base64 --d > ${CERTDIR}/router.ca
  cat <<EOF >> /etc/ansible/hosts
# ROUTER Certificates
openshift_hosted_router_certificate={"certfile": "${CERTDIR}/router.crt", "keyfile": "${CERTDIR}/router.key", "cafile": "${CERTDIR}/router.ca"}
openshift_hosted_router_create_certificate=False
EOF

fi

cat <<EOF >> /etc/ansible/hosts
# Networking
osm_cluster_network_cidr=${CLUSTERNET}
openshift_portal_net=${PORTALNET}

openshift_use_dnsmasq=true
openshift_master_cluster_method=native
openshift_master_default_subdomain=${WILDCARDFQDN}
openshift_master_cluster_hostname=master1
openshift_master_cluster_public_hostname=${PUBLICHOSTNAME}

# Do not install metrics but post install
openshift_metrics_install_metrics=false
openshift_metrics_cassandra_storage_type=dynamic
openshift_metrics_cassandra_pvc_size="${METRICS_CASSANDRASIZE}G"
openshift_metrics_cassandra_replicas="${METRICS_INSTANCES}"
openshift_metrics_hawkular_nodeselector={"role":"infra"}
openshift_metrics_cassandra_nodeselector={"role":"infra"}
openshift_metrics_heapster_nodeselector={"role":"infra"}

# Do not install logging but post install
openshift_logging_install_logging=false
openshift_logging_master_public_url=https://${PUBLICHOSTNAME}
#openshift_logging_es_pv_selector={"usage":"elasticsearch"}
openshift_logging_es_pvc_dynamic="true"
openshift_logging_es_pvc_size="${LOGGING_ES_SIZE}G"
openshift_logging_es_cluster_size=${LOGGING_ES_INSTANCES}
openshift_logging_fluentd_nodeselector={"logging":"true"}
openshift_logging_es_nodeselector={"role":"infra"}
openshift_logging_kibana_nodeselector={"role":"infra"}
openshift_logging_curator_nodeselector={"role":"infra"}
# 3.7
openshift_logging_es_pvc_storage_class_name=""

# prometheus
#openshift_prometheus_additional_rules_file
openshift_prometheus_pvc_access_modes=ReadWriteOnce
openshift_prometheus_pvc_size="100Gi"
openshift_prometheus_storage_type=pvc
openshift_prometheus_alertmanager_storage_type=pvc
openshift_prometheus_alertmanager_pvc_name=alertmanager
openshift_prometheus_alertbuffer_storage_type=pvc
#openshift_prometheus_alertbuffer_pvc_size=10Gi
openshift_prometheus_node_selector={"role":"infra"}

openshift_logging_use_ops=false
#openshift_logging_es_ops_pv_selector={"usage":"opselasticsearch"}
openshift_logging_es_ops_pvc_dynamic="true"
openshift_logging_es_ops_pvc_size="${OPSLOGGING_ES_SIZE}G"
openshift_logging_es_ops_cluster_size=${OPSLOGGING_ES_INSTANCES}
openshift_logging_es_ops_nodeselector={"role":"infra"}
openshift_logging_kibana_ops_nodeselector={"role":"infra"}
openshift_logging_curator_ops_nodeselector={"role":"infra"}

[masters]
master1 openshift_hostname=master1 openshift_node_labels="{'role': 'master'}"
master2 openshift_hostname=master2 openshift_node_labels="{'role': 'master'}"
master3 openshift_hostname=master3 openshift_node_labels="{'role': 'master'}"

[etcd]
master1
master2
master3

[new_nodes]
[new_masters]

[nodes]
master1 openshift_hostname=master1 openshift_node_labels="{'role':'master','zone':'default','logging':'true'}" openshift_schedulable=false
master2 openshift_hostname=master2 openshift_node_labels="{'role':'master','zone':'default','logging':'true'}" openshift_schedulable=false
master3 openshift_hostname=master3 openshift_node_labels="{'role':'master','zone':'default','logging':'true'}" openshift_schedulable=false
infranode1 openshift_hostname=infranode1 openshift_node_labels="{'role': 'infra', 'zone': 'default','logging':'true'}"
infranode2 openshift_hostname=infranode2 openshift_node_labels="{'role': 'infra', 'zone': 'default','logging':'true'}"
infranode3 openshift_hostname=infranode3 openshift_node_labels="{'role': 'infra', 'zone': 'default','logging':'true'}"
EOF

# Loop to add Nodes
for (( c=01; c<((10#$NODECOUNT+1)); c++ ))
do
  pnum=$(printf "%02d" $c)
  echo "node${pnum} openshift_hostname=node${pnum} \
openshift_node_labels=\"{'role':'app','zone':'default','logging':'true'}\"" >> /etc/ansible/hosts
done



# FIX: if specifying specific version openshift_pkg_version
#      this will enable the installation of atomic-openshift{{ openshift_pkg_version }}
#      in subscribe.yml below
if [[  $(grep -q ^openshift_pkg_version /etc/ansible/hosts; echo $?) == 0 ]];then 
  pkg_version=$(awk -F'=' '/^openshift_pkg_version/ {print $2}'  /etc/ansible/hosts)
  echo "FOUND: openshift_pkg_version ${pkg_version}"
fi
cat <<EOF > /home/${AUSERNAME}/subscribe.yml
---
- hosts: all
  vars:
    description: "Wait for nodes"
  tasks:
  - name: wait for .updateok
    wait_for: path=/root/.updateok
- hosts: all
  vars:
    description: "Subscribe OCP"
    ocp_release: "{{ openshift_release }}"
  tasks:
  - name: check connection
    ping:

  - name: Get rid of RHUI repos
    file: path=/etc/yum.repos.d/rh-cloud.repo state=absent

  - name: Get rid of RHUI load balancers
    file: path=/etc/yum.repos.d/rhui-load-balancers state=absent

  - name: remove the RHUI package
    yum: name=RHEL7 state=absent

  - name: Allow rhsm a longer timeout to help out with subscription-manager
    lineinfile:
      dest: /etc/rhsm/rhsm.conf
      line: 'server_timeout=600'
      insertafter: '^proxy_password ='

  - name: Get rid of old subs
    shell: subscription-manager unregister
    ignore_errors: yes

  - name: register hosts | Master and Infra subs only
EOF
if [[ $RHSMMODE == "usernamepassword" ]]; then
cat <<EOF >> /home/${AUSERNAME}/subscribe.yml
    redhat_subscription:
      state: present
      username: "${RHNUSERNAME}"
      password: "${RHNPASSWORD}"
      pool: "${RHNPOOLID_BROKER}"
      force_register: yes
    register: task_result
    until: task_result | success
    retries: 10
    delay: 30
    ignore_errors: yes
    when:  '"master" in inventory_hostname or "infra"  in inventory_hostname'
EOF
else
cat <<EOF >> /home/${AUSERNAME}/subscribe.yml
    redhat_subscription:
      state: present
      activationkey: "${RHNUSERNAME}"
      org_id: "${RHNPASSWORD}"
      pool: "${RHNPOOLID_BROKER}"
      force_register: yes
    register: task_result
    until: task_result | success
    retries: 10
    delay: 30
    ignore_errors: yes
    when:  '"master" in inventory_hostname or "infra"  in inventory_hostname'

  # Remove worker node subscription from masters/infra nodes
  - name: remove pool id | Master and Infra subscription only
    shell: subscription-manager remove --pool "${RHNPOOLID}"
    ignore_errors: yes
    when:  '"master" in inventory_hostname or "infra"  in inventory_hostname'
EOF
fi

cat <<EOF >> /home/${AUSERNAME}/subscribe.yml

  - name: register hosts | node subscription only
EOF

# Register Worker Nodes
if [[ $RHSMMODE == "usernamepassword" ]]
then
cat <<EOF >> /home/${AUSERNAME}/subscribe.yml
    redhat_subscription:
      state: present
      username: "${RHNUSERNAME}"
      password: "${RHNPASSWORD}"
      pool: "${RHNPOOLID}"
      force_register: yes
    register: task_result
    until: task_result | success
    retries: 10
    delay: 30
    ignore_errors: yes
    when:
      - '"master" not in inventory_hostname'
      - '"infra" not in inventory_hostname'
EOF
else
cat <<EOF >> /home/${AUSERNAME}/subscribe.yml
    redhat_subscription:
      state: present
      activationkey: "${RHNUSERNAME}"
      org_id: "${RHNPASSWORD}"
      force_register: yes
    register: task_result
    until: task_result | success
    retries: 10
    delay: 30
    ignore_errors: yes
    when:
      - '"master" not in inventory_hostname'
      - '"infra" not in inventory_hostname'
EOF
fi

cat <<EOF >> /home/${AUSERNAME}/subscribe.yml

  - name: disable all repos
    shell: subscription-manager repos --disable="*"
    register: repo_result
    until: repo_result | success
    retries: 10
    delay: 30

  - name: enable repos
    shell: subscription-manager repos --enable="rhel-7-server-rpms" \
           --enable="rhel-7-server-extras-rpms" --enable="rhel-7-fast-datapath-rpms" \
           --enable="rhel-7-server-ose-{{ ocp_release }}-rpms"
    register: enable_result
    until: enable_result | success
    retries: 10
    delay: 30

  - name: install the latest version of PyYAML
    yum: name=PyYAML state=latest

  - name: Install the docker
    yum: name=docker-1.12.6 state=present

  - name: Update all hosts
    yum: name="*" state=latest exclude='atomic-openshift,atomic-openshift-clients,docker*'
    register: update_result
    until: update_result | success
    retries: 10
    delay: 30

EOF

if [[ ${pkg_version} != "" ]]
then
    echo "  - name: Install the OCP client" >> /home/${AUSERNAME}/subscribe.yml
    echo "    yum: name=atomic-openshift-clients${pkg_version} state=present" >> /home/${AUSERNAME}/subscribe.yml
    echo >> /home/${AUSERNAME}/subscribe.yml
    echo "  - name: Install atomic-openshift${pkg_version}"                 >> /home/${AUSERNAME}/subscribe.yml
    echo "    yum: name=atomic-openshift${pkg_version} state=present"       >> /home/${AUSERNAME}/subscribe.yml
else
    echo "  - name: Install the OCP client" >> /home/${AUSERNAME}/subscribe.yml
    echo "    yum: name=atomic-openshift-clients state=latest" >> /home/${AUSERNAME}/subscribe.yml
    echo >> /home/${AUSERNAME}/subscribe.yml
    echo "  - name: Install atomic-openshift"                 >> /home/${AUSERNAME}/subscribe.yml
    echo "    yum: name=atomic-openshift state=latest"       >> /home/${AUSERNAME}/subscribe.yml
fi

cat <<EOF >> /home/${AUSERNAME}/subscribe.yml

  - name: Install the docker
    yum: name=docker state=latest
  - name: Start Docker
    service:
      name: docker
      enabled: yes
      state: started
    register: docker_status
    ignore_errors: yes

#  - name: Reboot node
#    command: shutdown -r +1
#    async: 600
#    poll: 0
#
  - name: Wait for node to come back
    local_action: wait_for
    args:
      host: "{{ ansible_nodename }}"
      port: 22
      state: started
      # Wait for the reboot delay from the previous task plus 10 seconds.
      # Otherwise, the SSH port would still be open because the system
      # has not rebooted.
      delay: 70
      timeout: 600

  - name: Wait for Things to Settle
    pause: minutes=2

EOF

cat <<EOF >> /home/${AUSERNAME}/upgrade.yml
---
- name: upgrade prep hosts file
  hosts: localhost
  become: true
  vars:
    openshift_release: "3.7"
  tasks:
    - debug: var=openshift_release

    - name: "add variables for "
      lineinfile:
        #path: "./hosts"
        path: "/etc/ansible/hosts"
        state: "{{ item.state }}"
        line: "{{ item.line }}"
        insertafter: ".*OSEv3.*vars"
        backup: yes
      with_items:
         - { state: 'present', line: 'openshift_rolling_restart_mode=system' }
         - { state: 'present', line: 'openshift_enable_service_catalog=true' }
         - { state: 'present', line: 'ansible_service_broker_install=false' }
         - { state: 'present', line: 'template_service_broker_install=false' }
         - { state: 'present', line: 'template_service_broker_selector=role=infra' }
      tags: test

    - name: "change variables for "
      lineinfile:
        path: "/etc/ansible/hosts"
        state: "{{ item.state }}"
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
        insertafter: ".*OSEv3.*vars"
        backup: yes
      with_items:
         - { state: 'present', regexp: 'deployment_type=openshift-enterprise', line: 'openshift_deployment_type=openshift-enterprise' }
         - { state: 'present', regexp: '^openshift_release', line: 'openshift_release={{ openshift_release }}' }
      tags: test

    - name: subscription-manager refresh
      command: subscription-manager refresh

    - name: Enable repos
      command: 'subscription-manager repos --disable="rhel-7-server-ose-3.6-rpms" \
    --enable="rhel-7-server-ose-{{ openshift_release }}-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-fast-datapath-rpms"'

    - name: Clean yum
      command: yum clean all

    - name: Install the OCP client
      yum:
        name: "{{ item }}"
        state: latest
      with_items:
        - atomic-openshift-utils
        - atomic-openshift-clients

- name: upgrade prep cluster
  hosts: all
  tasks:
    - debug: var=openshift_release
      tags: debug
    - pause:
    - name: subscription-manager refresh
      command: subscription-manager refresh

    - name: Enable repos
      command: 'subscription-manager repos --disable="rhel-7-server-ose-3.6-rpms" \
    --enable="rhel-7-server-ose-{{ openshift_release }}-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-fast-datapath-rpms"'

    - name: Clean yum
      command: yum clean all

    - name: Install the OCP client
      yum:
        name: atomic-openshift-clients
        state: latest

- name: upgrade prep masters
  hosts: masters
  become: true
  tasks:
    - name: copy kube config to root
      copy:
        src: ~/.kube/config
        dest: /root/.kube/config

- import_playbook:  /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-cluster/upgrades/v3_7/upgrade.yml

# after upgrade the dns search domain is erased
- name: update DNS search
  hosts: all
  tasks:
    - name: set domain
      shell: domainname -d
      register: domain
      tags: domain
      run_once: true
      delegate_to: localhost

    - debug: var=domain.stdout
      tags: domain
      run_once: true
      delegate_to: localhost

    - name: update dns search domain
      command: 'nmcli con modify eth0 ipv4.dns-search {{ domain.stdout }}'

    - name: Update resolv conf
      command: 'nmcli con up eth0'
EOF


cat <<EOF > /home/${AUSERNAME}/postinstall.yml
---
- hosts: masters
  vars:
    description: "auth users"
  tasks:
  - name: Create Master Directory
    file: path=/etc/origin/master state=directory
  - name: add initial user to Red Hat OpenShift Container Platform
    shell: htpasswd -c -b /etc/origin/master/htpasswd ${AUSERNAME} ${PASSWORD}

EOF

cat <<EOF > /home/${AUSERNAME}/fix-api-url.yml
---
- hosts: masters
  tasks:
  - name: Configure master client for local API
    lineinfile:
      path: "{{ item }}/.kube/config"
      regexp: "    server: https://[^:]+:{{ console_port }}"
      line: "    server: https://{{ ansible_hostname }}:{{ console_port }}"
      state: present
    with_items:
      - /root
      - /home/${AUSERNAME}

  - name: Configure master node for local API
    lineinfile:
      path: /etc/origin/node/system:node:{{ ansible_hostname }}.kubeconfig
      regexp: "    server: https://[^:]+:{{ console_port }}"
      line: "    server: https://{{ ansible_hostname }}:{{ console_port }}"
      state: present
    notify: Restart atomic-openshift-node
  handlers:
  - name: Restart atomic-openshift-node
    service:
      name: atomic-openshift-node
      state: restarted

- hosts: nodes:!masters
  tasks:
  - name: Configure non-master node for API load balancer
    lineinfile:
      path: /etc/origin/node/system:node:{{ ansible_hostname }}.kubeconfig
      regexp: "    server: https://[^:]+:{{ console_port }}"
      line: "    server: https://{{ openshift_master_cluster_public_hostname }}:{{ console_port }}"
      state: present
    notify: Restart atomic-openshift-node
  handlers:
  - name: Restart atomic-openshift-node
    service:
      name: atomic-openshift-node
      state: restarted

- hosts: localhost
  become: yes
  tasks:
  - name: Configure bastion client for API load balancer
    lineinfile:
      path: "{{ item }}/.kube/config"
      regexp: "    server: https://[^:]+:{{ hostvars['master1']['console_port'] }}"
      line: "    server: https://{{ hostvars['master1']['openshift_master_cluster_public_hostname'] }}:{{ hostvars['master1']['console_port'] }}"
      state: present
    with_items:
      - /root
      - /home/${AUSERNAME}
EOF

cat > /home/${AUSERNAME}/ssovars.yml <<EOF
---
  sso_username: ${AUSERNAME}
  sso_project: "sso"
  sso_password: ${PASSWORD}
  sso_domain:   ${WILDCARDFQDN}
  hostname_https: "login.{{sso_domain}}"
  api_master:   ${APIHOST}
EOF

cat > /home/${AUSERNAME}/setup-sso.yml <<EOF
---
- hosts: masters[0]
  vars_files:
    - ssovars.yml
  vars:
    description: "SSO Setup"
    create_data:
        clientId: "openshift"
        name:     "OpenShift"
        description: "OpenShift Console Authentication"
        enabled: true
        protocol: "openid-connect"
        clientAuthenticatorType: "client-secret"
        directAccessGrantsEnabled: true
        redirectUris: ["https://{{api_master}}:443/*"]
        webOrigins: []
        publicClient: false
        consentRequired: false
        frontchannelLogout: false
        standardFlowEnabled: true
  tasks:
  - debug:
      msg: "Domain: {{sso_domain}}"
  - set_fact: idm_dir="/home/{{sso_username}}/{{sso_project}}"
  - debug:
      msg: "Idm dir {{ idm_dir }}"
  - name: Install Java
    yum:
      name: java-1.8.0-openjdk
      state: latest
  - name: Cleanup old idm directory
    file:
      state: absent
      path: "{{idm_dir}}"
  - name: C eate new idm directory
    file:
      state: directory
      path: "{{idm_dir}}"
  - name: Delete service account
    command: oc delete service account "{{sso_project}}-service_account"
    ignore_errors: yes
    register: result
    failed_when:
      - "result.rc > 10"
  - name: Delete Secret
    command: oc delete secret "{{sso_project}}-app-secret"
    ignore_errors: yes
    register: result
    failed_when:
      - "result.rc > 10"
  - name: Delete Old Project
    command: oc delete project "{{sso_project}}"
    ignore_errors: yes
    register: result
    failed_when:
      - "result.rc > 10"
  - name: Pause for cleanup of old install
    pause:
      minutes: 2
  - set_fact: sso_projectid="{{sso_project}}"
  - set_fact: idm_xpassword="Xp-{{sso_password}}"
  - name: Create Openshift Project for SSO
    command: oc new-project "{{sso_project}}"
  - name: Create Service Account
    command: "oc create serviceaccount {{sso_project}}-service-account -n {{ sso_project }}"
  - name: Add admin role to user
    command: "oc adm policy add-role-to-user admin {{sso_username}}"
  - name: Add view to user
    command: "oc policy add-role-to-user view system:serviceaccount:${1}idm:{{sso_project}}-service-account"
  - name: Stage 1 - OpenSSL Request
    command: "openssl req -new  -passout pass:{{idm_xpassword}} -newkey rsa:4096 -x509 -keyout {{idm_dir}}/xpaas.key -out {{idm_dir}}/xpaas.crt -days 365 -subj /CN=xpaas-sso.ca"
  - name: Stage 2 - GENKEYPAIR
    command: "keytool  -genkeypair -deststorepass {{idm_xpassword}} -storepass {{idm_xpassword}} -keypass {{idm_xpassword}} -keyalg RSA -keysize 2048 -dname CN={{hostname_https}} -alias sso-https-key -keystore {{idm_dir}}/sso-https.jks"
  - name: Stage 3 - CERTREQ
    command: "keytool  -deststorepass {{idm_xpassword}} -storepass {{idm_xpassword}} -keypass {{idm_xpassword}} -certreq -keyalg rsa -alias sso-https-key -keystore {{idm_dir}}/sso-https.jks -file {{idm_dir}}/sso.csr"
  - name: Stage 4 - X509
    command: "openssl x509 -req -passin pass:{{idm_xpassword}} -CA {{idm_dir}}/xpaas.crt -CAkey {{idm_dir}}/xpaas.key -in {{idm_dir}}/sso.csr -out {{idm_dir}}/sso.crt -days 365 -CAcreateserial"
  - name: Stage 5 - IMPORT CRT
    command: "keytool  -noprompt -deststorepass {{idm_xpassword}} -import -file {{idm_dir}}/xpaas.crt  -storepass {{idm_xpassword}} -keypass {{idm_xpassword}} -alias xpaas.ca -keystore {{idm_dir}}/sso-https.jks"
  - name: Stage 6 - IMPORT SSO
    command: "keytool  -noprompt -deststorepass {{idm_xpassword}} -storepass {{idm_xpassword}} -keypass {{idm_xpassword}}  -import -file {{idm_dir}}/sso.crt -alias sso-https-key -keystore {{idm_dir}}/sso-https.jks"
  - name: Stage 7 - IMPORT XPAAS
    command: "keytool -noprompt -deststorepass {{idm_xpassword}} -storepass {{idm_xpassword}} -keypass {{idm_xpassword}}   -import -file {{idm_dir}}/xpaas.crt -alias xpaas.ca -keystore {{idm_dir}}/truststore.jks"
  - name: Stage 8 - GENSECKEY
    command: "keytool  -deststorepass {{idm_xpassword}} -storepass {{idm_xpassword}} -keypass {{idm_xpassword}} -genseckey -alias jgroups -storetype JCEKS -keystore {{idm_dir}}/jgroups.jceks"
  - name: Stage 9 - OCCREATE SECRET
    command: "oc create secret generic sso-app-secret --from-file={{idm_dir}}/jgroups.jceks --from-file={{idm_dir}}/sso-https.jks --from-file={{idm_dir}}/truststore.jks"
  - name: Stage 10 - OCCREATE SECRET ADD
    command: "oc secret add sa/{{sso_project}}-service-account secret/sso-app-secret"
  - name: Stage 11 - Create App Parameters
    blockinfile:
       path: "{{idm_dir}}/sso.params"
       create: yes
       block: |
         HOSTNAME_HTTP="nlogin.{{sso_domain}}"
         HOSTNAME_HTTPS="login.{{sso_domain}}"
         APPLICATION_NAME="{{sso_project}}"
         HTTPS_KEYSTORE="sso-https.jks"
         HTTPS_PASSWORD="{{idm_xpassword}}"
         HTTPS_SECRET="sso-app-secret"
         JGROUPS_ENCRYPT_KEYSTORE="jgroups.jceks"
         JGROUPS_ENCRYPT_PASSWORD="{{idm_xpassword}}"
         JGROUPS_ENCRYPT_SECRET="sso-app-secret"
         SERVICE_ACCOUNT_NAME={{sso_project}}-service-account
         SSO_REALM=cloud
         SSO_SERVICE_USERNAME="{{sso_username}}"
         SSO_SERVICE_PASSWORD="{{sso_password}}"
         SSO_ADMIN_USERNAME=admin
         SSO_ADMIN_PASSWORD="{{sso_password}}"
         SSO_TRUSTSTORE=truststore.jks
         SSO_TRUSTSTORE_PASSWORD="{{idm_xpassword}}"

  - name: Stage 12 - OCCREATE SECRET ADD
    command: oc new-app sso71-postgresql --param-file {{idm_dir}}/sso.params -l app=sso71-postgresql -l application=sso -l template=sso71-https
  - name: Stage 13 - add xml pv
    command: oc volume dc/sso --add --claim-size 512M --type=emptyDir --mount-path /opt/eap/standalone/configuration/standalone_xml_history --name standalone-xml-history
  - set_fact: sso_token_url="https://login.{{sso_domain}}/auth/realms/cloud/protocol/openid-connect/token"
  - name: Pause for app create
    pause:
      minutes: 4
  - name: Login to SSO and Get Token
    uri:
      url: "{{sso_token_url}}"
      method: POST
      body: "grant_type=password&client_id=admin-cli&username={{sso_username}}&password={{sso_password}}"
      return_content: yes
      status_code: 200
      validate_certs: no
    register: login
    until: login.status == 200
    retries: 90
    delay: 30
  - debug: var=login.json.access_token
  - name: Create SSO Client for Openshift
    uri:
      url: "https://login.{{sso_domain}}/auth/realms/cloud/clients-registrations/default"
      method: POST
      headers:
           "Authorization": "bearer {{login.json.access_token}}"
           "Content-Type": "application/json"
      body: "{{ create_data | to_json }}"
      return_content: yes
      status_code: 201
      validate_certs: no
    register: create
  - debug: var=create.json.secret
  - local_action: copy content={{create.json.secret}} dest=/tmp/ssosecret.var
  - fetch:
       src: "{{idm_dir}}/xpaas.crt"
       dest: "{{idm_dir}}/xpaas.crt"
       flat: yes
- hosts: masters
  vars_files:
    - ssovars.yml
  vars:
     ssosecret: "{{lookup('file', '/tmp/ssosecret.var')}}"
  tasks:
  - set_fact: idm_dir="/home/{{sso_username}}/{{sso_project}}"
  - name: Copy xpass.crt to masters
    copy:
      src:  "{{idm_dir}}/xpaas.crt"
      dest: /etc/origin/master/xpaas.crt
      owner: root
      mode: 0600
  - name: Setup SSO Config
    blockinfile:
      backup: yes
      dest: /etc/origin/master/master-config.yaml
      insertafter: HTPasswdPasswordIdentityProvider
      block: |1
         - name: sso
           challenge: false
           login: true
           mappingInfo: add
           provider:
             apiVersion: v1
             kind: OpenIDIdentityProvider
             clientID: openshift
             clientSecret: {{ssosecret}}
             ca: xpaas.crt
             urls:
               authorize: https://login.{{sso_domain}}/auth/realms/cloud/protocol/openid-connect/auth
               token: https://login.{{sso_domain}}/auth/realms/cloud/protocol/openid-connect/token
               userInfo: https://login.{{sso_domain}}/auth/realms/cloud/protocol/openid-connect/userinfo
             claims:
               id:
               - sub
               preferredUsername:
               - preferred_username
               name:
               - name
               email:
               - email

  - service:
      name: atomic-openshift-master-api
      state: restarted
  - service:
      name: atomic-openshift-master-controllers
      state: restarted
  - name: Pause for service restart
    pause:
      seconds: 10
  - name: Add our user as cluster admin
    command: oc adm policy add-cluster-role-to-user cluster-admin "{{sso_username}}"
  - debug:
      msg: "Completed"
EOF
# JTH:
cat > /home/${AUSERNAME}/add_host.sh <<EOF
#!/bin/bash
set -eo pipefail

usage(){
  echo "\$0 [-t node|master|infranode] [-u username] [-p /path/to/publicsshkey] [-s vmsize] [-d extradisksize (in G)] [-d extradisksize] [-d...]"
  echo "  -t|--type           node, master or infranode"
  echo "                      If not specified: node"
  echo "  -u|--user           regular user to be created on the host"
  echo "                      If not specified: Current user"
  echo "  -p|--sshpub         path to the public ssh key to be injected in the host"
  echo "                      If not specified: ~/.ssh/id_rsa.pub"
  echo "  -s|--size           VM size"
  echo "                      If not specified:"
  echo "                        * Standard_DS12_v2 for nodes"
  echo "                        * Standard_DS12_v2 for infra nodes"
  echo "                        * Standard_DS3_v2 for masters"
  echo "  -d|--disk           Extra disk size in GB (it can be repeated a few times)"
  echo "                      If not specified: 2x128GB"
  echo "Examples:"
  echo "    \$0 -t infranode -d 200 -d 10"
  echo "    \$0"
}

login_azure(){
  export TENANT=\$(< ~/.azuresettings/tenant_id)
  export AAD_CLIENT_ID=\$(< ~/.azuresettings/aad_client_id)
  export AAD_CLIENT_SECRET=\$(< ~/.azuresettings/aad_client_secret)
  export RESOURCEGROUP=\$(< ~/.azuresettings/resource_group)
  export LOCATION=\$(< ~/.azuresettings/location)
  echo "Logging into Azure..."
  azure login \
    --service-principal \
    --tenant \${TENANT} \
    -u \${AAD_CLIENT_ID} \
    -p \${AAD_CLIENT_SECRET} >/dev/null
}

create_nic_azure(){
  echo "Creating the VM NIC..."
  azure network nic create \
    --resource-group \${RESOURCEGROUP} \
    --name \${VMNAME}nic \
    --location \${LOCATION} \
    --subnet-id  "/subscriptions/\${SUBSCRIPTION}/resourceGroups/\${RESOURCEGROUP}/providers/Microsoft.Network/virtualNetworks/\${NET}/subnets/\${SUBNET}" \
    --ip-config-name \${IPCONFIG} \
    --internal-dns-name-label \${VMNAME} \
    --tags "displayName=NetworkInterface" >/dev/null
}
create_vm_azure(){
  # VM itself
  echo "Creating the VM..."
  azure vm create \
    --resource-group \${RESOURCEGROUP} \
    --name \${VMNAME} \
    --location \${LOCATION} \
    --image-urn \${IMAGE} \
    --admin-username \${ADMIN} \
    --ssh-publickey-file \${SSHPUB} \
    --vm-size \${VMSIZE} \
    --storage-account-name \${SA} \
    --storage-account-container-name \${SACONTAINER} \
    --os-disk-vhd http://\${SA}.blob.core.windows.net/\${SACONTAINER}/\${VMNAME}.vhd \
    --nic-name \${VMNAME}nic \
    --availset-name \${TYPE}availabilityset \
    --os-type Linux \
    --disable-boot-diagnostics \
    --tags "displayName=VirtualMachine" >/dev/null
}

create_disks_azure(){
  # Disks
  echo "Creating the VM disks..."
  for ((i=0; i<\${#DISKS[@]}; i++))
  do
    azure vm disk attach-new \
      --resource-group \${RESOURCEGROUP} \
      --vm-name \${VMNAME} \
      --size-in-gb \${DISKS[i]} \
      --vhd-name \${VMNAME}_datadisk\${i}.vhd \
      --storage-account-name \${SA} \
      --storage-account-container-name \${SACONTAINER} \
      --host-caching \${HOSTCACHING} >/dev/null
  done
}

create_host_azure(){
  create_nic_azure
  create_vm_azure
  create_disks_azure
}

create_nsg_azure()
{
  echo "Creating the NGS..."
  azure network nsg create \
    --resource-group \${RESOURCEGROUP} \
    --name \${VMNAME}nsg \
    --location \${LOCATION} \
    --tags "displayName=NetworkSecurityGroup" >/dev/null
}

create_nsg_rules_master_azure()
{
  echo "Creating the NGS rules for a master host..."
  azure network nsg rule create \
    --resource-group \${RESOURCEGROUP} \
    --nsg-name \${VMNAME}nsg \
    --destination-port-range \${APIPORT} \
    --protocol tcp \
    --name default-allow-openshift-master \
    --priority 2000 >/dev/null
}

create_nsg_rules_infranode_azure()
{
  echo "Creating the NGS rules for an infranode..."
  azure network nsg rule create \
    --resource-group \${RESOURCEGROUP} \
    --nsg-name \${VMNAME}nsg \
    --destination-port-range \${HTTP} \
    --protocol tcp \
    --name default-allow-openshift-router-http \
    --priority 1000 >/dev/null
  azure network nsg rule create \
    --resource-group \${RESOURCEGROUP} \
    --nsg-name \${VMNAME}nsg \
    --destination-port-range \${HTTPS} \
    --protocol tcp \
    --name default-allow-openshift-router-https \
    --priority 2000 >/dev/null
}

attach_nsg_azure()
{
  echo "Attaching NGS rules to a NSG..."
  azure network nic set \
    --resource-group \${RESOURCEGROUP} \
    --name \${VMNAME}nic \
    --network-security-group-name \${VMNAME}nsg >/dev/null
}

attach_nic_lb_azure()
{
  echo "Attaching VM NIC to a LB..."
  BACKEND="loadBalancerBackEnd"
  azure network nic ip-config set \
    --resource-group \${RESOURCEGROUP} \
    --nic-name \${VMNAME}nic \
    --name \${IPCONFIG} \
    --lb-address-pool-ids "/subscriptions/\${SUBSCRIPTION}/resourceGroups/\${RESOURCEGROUP}/providers/Microsoft.Network/loadBalancers/\${LB}/backendAddressPools/\${BACKEND}" >/dev/null
}

create_node_azure()
{
  common_azure
  export SUBNET="node"
  export SA="sanod\${RESOURCEGROUP//-}"
  create_host_azure
}

create_master_azure()
{
  common_azure
  export SUBNET="master"
  export SA="samas\${RESOURCEGROUP//-}"
  export LB="MasterLb\${RESOURCEGROUP//-}"
  create_host_azure
  create_nsg_azure
  create_nsg_rules_master_azure
  attach_nsg_azure
  attach_nic_lb_azure
}

create_infranode_azure()
{
  common_azure
  export SUBNET="infranode"
  export SA="sanod\${RESOURCEGROUP//-}"
  export LB=\$(azure network lb list \${RESOURCEGROUP} --json | jq -r '.[].name' | grep -v "MasterLb")
  create_host_azure
  create_nsg_azure
  create_nsg_rules_infranode_azure
  attach_nsg_azure
  attach_nic_lb_azure
}

common_azure()
{
  echo "Getting the VM name..."
  export LASTVM=\$(azure vm list \${RESOURCEGROUP} | awk "/\${TYPE}/ { print \\\$3 }" | tail -n1)
  if [ \$TYPE == 'node' ]
  then
    # Get last 2 numbers and add 1
    LASTNUMBER=\$((10#\${LASTVM: (-2)}+1))
    # Format properly XX
    NEXT=\$(printf %02d \$LASTNUMBER)
  else
    # Get last number
    NEXT=\$((\${LASTVM: (-1)}+1))
  fi
  export VMNAME="\${TYPE}\${NEXT}"
  export SUBSCRIPTION=\$(azure account list --json | jq -r '.[0].id')
}

BZ1469358()
{
  # https://bugzilla.redhat.com/show_bug.cgi?id=1469358
  echo "Workaround for BZ1469358..."
  ansible master1 -b -m fetch -a "src=/etc/origin/master/ca.serial.txt dest=/tmp/ca.serial.txt  flat=true" >/dev/null
  ansible masters -b -m copy -a "src=/tmp/ca.serial.txt dest=/etc/origin/master/ca.serial.txt mode=644 owner=root" >/dev/null
  ansible localhost -b -m file -a "path=/tmp/ca.serial.txt state=absent" >/dev/null
}

add_node_openshift(){
  echo "Adding the new node to the ansible inventory..."
  sudo sed -i "/\[new_nodes\]/a \${VMNAME} openshift_hostname=\${VMNAME} openshift_node_labels=\"{'role':'\${ROLE}','zone':'default','logging':'true'}\"" /etc/ansible/hosts
  echo "Preparing the host..."
  ansible new_nodes -m shell -a "curl -s ${GITURL}node.sh | bash -x" >/dev/null
  export ANSIBLE_HOST_KEY_CHECKING=False
  ansible-playbook -l new_nodes /home/\${USER}/subscribe.yml
  ansible-playbook -l new_nodes -e@vars.yml /home/\${USER}/azure-config.yml
  # Scale up
  echo "Scaling up the node..."
  ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-node/scaleup.yml
  echo "Adding the node to the ansible inventory..."
  ansible new_nodes -b -m command -a "nmcli con modify eth0 ipv4.dns-search $(domainname -d)"
  ansible new_nodes -b -a "nmcli con up eth0"
  # setup custom dnsmasq domain
  ansible-playbook -l \${VMNAME}  /home/honeywell/custom-dnsmasq-domain.yml
  sudo sed -i "/^\${VMNAME}.*/d" /etc/ansible/hosts
  sudo sed -i "/\[nodes\]/a \${VMNAME} openshift_hostname=\${VMNAME} openshift_node_labels=\"{'role':'\${ROLE}','zone':'default','logging':'true'}\"" /etc/ansible/hosts
  ansible-playbook -l \${VMNAME} /home/honeywell/setup-azure-node.yml
}

add_master_openshift(){
  echo "Adding the new master to the ansible inventory..."
  sudo sed -i "/\[new_nodes\]/a \${VMNAME} openshift_hostname=\${VMNAME} openshift_node_labels=\"{'role':'\${ROLE}','zone':'default','logging':'true'}\" openshift_schedulable=false" /etc/ansible/hosts
  sudo sed -i "/\[new_masters\]/a \${VMNAME} openshift_hostname=\${VMNAME} openshift_node_labels=\"{'role':'\${ROLE}','zone':'default','logging':'true'}\"" /etc/ansible/hosts
  echo "Preparing the host..."
  ansible new_masters -m shell -a "curl -s ${GITURL}master.sh | bash -x"
  # Copy ssh files as master.sh does
  ansible master1 -m fetch -a "src=/home/\${USER}/.ssh/id_rsa.pub dest=/tmp/key.pub flat=true" >/dev/null
  ansible master1 -m fetch -a "src=/home/\${USER}/.ssh/id_rsa dest=/tmp/key flat=true" >/dev/null
  # User
  ansible new_masters -m copy -a "src=/tmp/key.pub dest=/home/\${ADMIN}/.ssh/id_rsa.pub mode=600  owner=\${ADMIN}" >/dev/null
  ansible new_masters -m copy -a "src=/tmp/key dest=/home/\${ADMIN}/.ssh/id_rsa mode=600  owner=\${ADMIN}" >/dev/null
  # Root
  ansible new_masters -b -m copy -a "src=/tmp/key.pub dest=/root/.ssh/id_rsa.pub mode=600 owner=root" >/dev/null
  ansible new_masters -b -m copy -a "src=/tmp/key dest=/root/.ssh/id_rsa mode=600 owner=root" >/dev/null
  # Cleanup
  ansible localhost -b -m file -a "path=/tmp/key state=absent" >/dev/null
  ansible localhost -b -m file -a "path=/tmp/key.pub state=absent" >/dev/null
  export ANSIBLE_HOST_KEY_CHECKING=False
  ansible-playbook -l new_masters /home/\${USER}/subscribe.yml
  ansible-playbook -l new_masters -e@vars.yml /home/\${USER}/azure-config.yml
  echo "Scaling up the master..."
  ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-master/scaleup.yml
  echo "Copying htpasswd..."
  ansible master1 -m fetch -a "src=/etc/origin/master/htpasswd dest=/tmp/htpasswd flat=true" >/dev/null
  ansible new_masters -b -m copy -a "src=/tmp/htpasswd dest=/etc/origin/master/htpasswd mode=600  owner=root" >/dev/null
  ansible localhost -m file -a "path=/tmp/htpasswd state=absent" >/dev/null
  echo "Adding the master to the ansible inventory..."
  sudo sed -i "/^\${VMNAME}.*/d" /etc/ansible/hosts
  sudo sed -i "/\[masters\]/a \${VMNAME} openshift_hostname=\${VMNAME} openshift_node_labels=\"{'role': '\${ROLE}'}\"" /etc/ansible/hosts
  sudo sed -i "/\[nodes\]/a \${VMNAME} openshift_hostname=\${VMNAME} openshift_node_labels=\"{'role':'\${ROLE}','zone':'default','logging':'true'}\" openshift_schedulable=false" /etc/ansible/hosts
  ansible -l \${VMNAME} -b -m command -a "nmcli con modify eth0 ipv4.dns-search $(domainname -d)"
  ansible -l \${VMNAME} -b -m service -a "nmcli con up eth0"
  # setup custom dnsmasq domain
  ansible-playbook -l \${VMNAME}  /home/honeywell/custom-dnsmasq-domain.yml
  ansible-playbook  /home/honeywell/setup-azure-node.yml
}

# Default values
export IPCONFIG="ipconfig1"
export HOSTCACHING="None"
export NET=\$(< ~/.azuresettings/resource_group)
export IMAGE="RHEL"
export SACONTAINER="openshiftvmachines"
export APIPORT="443"
export HTTP="80"
export HTTPS="443"

# Default values that can be overwritten with flags
DEFTYPE="node"
DEFSSHPUB="/home/\${USER}/.ssh/id_rsa.pub"
DEFVMSIZENODE="Standard_DS12_v2"
DEFVMSIZEINFRANODE="Standard_DS12_v2"
DEFVMSIZEMASTER="Standard_DS3_v2"
declare -a DEFDISKS=(128 128)

if [[ ( \$@ == "--help") ||  \$@ == "-h" ]]
then
  usage
  exit 0
fi

while [[ \$# -gt 0 ]]; do
  opt="\$1"
  shift;
  current_arg="\$1"
  if [[ "\$current_arg" =~ ^-{1,2}.* ]]; then
    echo "ERROR: You may have left an argument blank. Double check your command."
    usage; exit 1
  fi
  case "\$opt" in
    "-t"|"--type")
      TYPE="\${1,,}"
      shift
      ;;
    "-u"|"--user")
      ADMIN="\$1"
      shift
      ;;
    "-p"|"--sshpub")
      SSHPUB="\$1"
      shift
      ;;
    "-s"|"--size")
      VMSIZE="\$1"
      shift
      ;;
    "-d"|"--disk")
      DISKS+=("\$1")
      shift
      ;;
    *)
      echo "ERROR: Invalid option: \""\$opt"\"" >&2
      usage
      exit 1
      ;;
  esac
done

export TYPE=\${TYPE:-\${DEFTYPE}}
export ADMIN=\${ADMIN:-\${USER}}
export SSHPUB=\${SSHPUB:-\${DEFSSHPUB}}
export DISKS=("\${DISKS[@]:-\${DEFDISKS[@]}}")

azure telemetry --disable 1>/dev/null
echo "Updating atomic-openshift-utils..."
sudo yum update -y atomic-openshift-utils 1>/dev/null
login_azure
BZ1469358

case "\$TYPE" in
  'node')
    # NODE
    export VMSIZE=\${VMSIZE:-\$DEFVMSIZENODE}
    export ROLE="app"
    echo "Creating a new node..."
    create_node_azure
    echo "Adding the node to OCP..."
    add_node_openshift
    ;;
  'infranode')
    # INFRANODE
    export VMSIZE=\${VMSIZE:-\$DEFVMSIZEINFRANODE}
    export ROLE="infra"
    echo "Creating a new infranode..."
    create_infranode_azure
    echo "Adding the node to OCP..."
    add_node_openshift
    ;;
  'master')
    # MASTER
    export VMSIZE=\${VMSIZE:-\$DEFVMSIZEMASTER}
    export ROLE="master"
    echo "Creating a new master..."
    create_master_azure
    echo "Adding the master to OCP..."
    add_master_openshift
    ;;
  *)
    echo "Wrong argument"
    ;;
esac

BZ1469358

echo "Done"
EOF
chmod a+x /home/${AUSERNAME}/add_host.sh

npm install -g azure-cli
azure telemetry --disable
cat <<'EOF' > /home/${AUSERNAME}/create_azure_storage_container.sh
# $1 is the storage account to create container
mkdir -p ~/.azuresettings/$1
export TENANT=$(< ~/.azuresettings/tenant_id)
export AAD_CLIENT_ID=$(< ~/.azuresettings/aad_client_id)
export AAD_CLIENT_SECRET=$(< ~/.azuresettings/aad_client_secret)
export RESOURCEGROUP=$(< ~/.azuresettings/resource_group)
azure login --service-principal --tenant ${TENANT}  -u ${AAD_CLIENT_ID} -p ${AAD_CLIENT_SECRET}
azure storage account connectionstring show ${1} --resource-group ${RESOURCEGROUP}  > ~/.azuresettings/$1/connection.out
sed -n '/connectionstring:/{p}' < ~/.azuresettings/${1}/connection.out > ~/.azuresettings/${1}/dataline.out
export DATALINE=$(< ~/.azuresettings/${1}/dataline.out)
export AZURE_STORAGE_CONNECTION_STRING=${DATALINE:27}
azure storage container create ${2} > ~/.azuresettings/${1}/container.dat
EOF
chmod +x /home/${AUSERNAME}/create_azure_storage_container.sh

cat <<EOF > /home/${AUSERNAME}/scgeneric.yml
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: "generic"
  annotations:
    storageclass.beta.kubernetes.io/is-default-class: "true"
    volume.beta.kubernetes.io/storage-class: "generic"
    volume.beta.kubernetes.io/storage-provisioner: kubernetes.io/azure-disk
provisioner: kubernetes.io/azure-disk
parameters:
  storageAccount: sapv${RESOURCEGROUP//-}
  location: ${LOCATION}
  storageaccounttype: Premium_LRS
  kind: dedicated
EOF

cat <<EOF > /home/${AUSERNAME}/openshift-install.sh
export ANSIBLE_HOST_KEY_CHECKING=False
sleep 120
ansible all --module-name=ping > ansible-preinstall-ping.out || true

yum -y install atomic-openshift-clients


ansible-playbook  /home/${AUSERNAME}/subscribe.yml
ansible-playbook  /home/${AUSERNAME}/azure-config.yml
echo "${RESOURCEGROUP} Bastion Host is starting ansible BYO" | mail -s "${RESOURCEGROUP} Bastion BYO Install" ${RHNUSERNAME} || true
ansible-playbook  /usr/share/ansible/openshift-ansible/playbooks/byo/config.yml < /dev/null

wget http://master1:443/api > healtcheck.out

ansible all -b -m command -a "nmcli con modify 'System eth0' ipv4.dns-search $(domainname -d)"
ansible all -b -m service -a "name=NetworkManager state=restarted"

EOF

if [[ ${CUSTOMDNS} != "false" ]];then
  echo "# setup dnsmasq on bastion" >> /home/${AUSERNAME}/openshift-install.sh
  echo "ansible-playbook /home/${AUSERNAME}/bastion-dnsmasq.yml" >> /home/${AUSERNAME}/openshift-install.sh
  echo "# setup custom dnsmasq domain" >> /home/${AUSERNAME}/openshift-install.sh
  echo "ansible-playbook /home/${AUSERNAME}/custom-dnsmasq-domain.yml" >> /home/${AUSERNAME}/openshift-install.sh
fi

cat <<EOF >> /home/${AUSERNAME}/openshift-install.sh

ansible-playbook  /home/${AUSERNAME}/setup-azure-node.yml

ansible-playbook /home/${AUSERNAME}/postinstall.yml
cd /root
mkdir .kube
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${AUSERNAME}@master1:~/.kube/config /tmp/kube-config
cp /tmp/kube-config /root/.kube/config
mkdir /home/${AUSERNAME}/.kube
cp /tmp/kube-config /home/${AUSERNAME}/.kube/config
chown --recursive ${AUSERNAME} /home/${AUSERNAME}/.kube
rm -f /tmp/kube-config

ansible-playbook /home/${AUSERNAME}/fix-api-url.yml &&

echo "setup registry for azure"
oc env dc docker-registry -e REGISTRY_STORAGE=azure -e REGISTRY_STORAGE_AZURE_ACCOUNTNAME=$REGISTRYSTORAGENAME -e REGISTRY_STORAGE_AZURE_ACCOUNTKEY=$REGISTRYKEY -e REGISTRY_STORAGE_AZURE_CONTAINER=registry
oc patch dc registry-console -p '{"spec":{"template":{"spec":{"nodeSelector":{"role":"infra"}}}}}'
sleep 30
echo "Setup Azure PV"
/home/${AUSERNAME}/create_azure_storage_container.sh sapv${RESOURCEGROUP//-} "vhds"

echo "Setup Azure PV for metrics & logging"
/home/${AUSERNAME}/create_azure_storage_container.sh sapvlm${RESOURCEGROUP//-} "loggingmetricspv"

oc adm policy add-cluster-role-to-user cluster-admin ${AUSERNAME}
# Workaround for BZ1469358
ansible master1 -b -m fetch -a "src=/etc/origin/master/ca.serial.txt dest=/tmp/ca.serial.txt flat=true"
ansible masters -b -m copy -a "src=/tmp/ca.serial.txt dest=/etc/origin/master/ca.serial.txt mode=644 owner=root"
ansible-playbook /home/${AUSERNAME}/setup-sso.yml &> /home/${AUSERNAME}/setup-sso.out
cat /home/${AUSERNAME}/openshift-install.out | tr -cd [:print:] |  mail -s "${RESOURCEGROUP} Install Complete" ${RHNUSERNAME} || true
touch /root/.openshiftcomplete
touch /home/${AUSERNAME}/.openshiftcomplete
EOF

cat <<EOF > /home/${AUSERNAME}/openshift-postinstall.sh
export ANSIBLE_HOST_KEY_CHECKING=False

DEPLOYMETRICS=${METRICS,,}
DEPLOYLOGGING=${LOGGING,,}
DEPLOYOPSLOGGING=${OPSLOGGING,,}

while true
do
  [ -e /home/${AUSERNAME}/.openshiftcomplete ] && break || sleep 10
done

# JTH: Moved to top for dynamic provisioning
oc create -f /home/${AUSERNAME}/scgeneric.yml

if [ \${DEPLOYMETRICS} == "true" ]
then
  echo "Deploying Metrics"
  #/home/${AUSERNAME}/create_pv.sh sapvlm${RESOURCEGROUP//-} loggingmetricspv metricspv ${METRICS_INSTANCES} ${METRICS_CASSANDRASIZE}
  ansible-playbook -e "openshift_metrics_install_metrics=\${DEPLOYMETRICS}" /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-cluster/openshift-metrics.yml
fi
# https://bugzilla.redhat.com/show_bug.cgi?id=1544243
# Pass with openshift-ansible:v3.7.36.
# logging_elasticsearch_rollout_override=True
  ansible-playbook -e "openshift_logging_install_logging=\${DEPLOYLOGGING} openshift_logging_use_ops=\${DEPLOYOPSLOGGING}" -e logging_elasticsearch_rollout_override=True /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-cluster/openshift-logging.yml

# Service catalog
ansible-playbook -e openshift_enable_service_catalog=True -e template_service_broker_install=True /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-cluster/service-catalog.yml

# prometheus
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-cluster/openshift-prometheus.yml
 -e openshift_prometheus_state=present

# Assign the application node network security group that was created by the
# ARM template to the node subnet that already existed as part of the
# pre-created VNet.
azure network vnet subnet set ${RESOURCEGROUP} ${RESOURCEGROUP} node --network-security-group-name appnodensg
EOF

cat <<'EOF' > /home/${AUSERNAME}/create_pv.sh
# $1 is the storage account to create container
# $2 is the container
# $3 is the blob
# $4 is the times
# $5 is the size in gigabytes

mkdir -p ~/.azuresettings/$1
export TENANT=$(< ~/.azuresettings/tenant_id)
export AAD_CLIENT_ID=$(< ~/.azuresettings/aad_client_id)
export AAD_CLIENT_SECRET=$(< ~/.azuresettings/aad_client_secret)
export RESOURCEGROUP=$(< ~/.azuresettings/resource_group)
azure login --service-principal --tenant ${TENANT}  -u ${AAD_CLIENT_ID} -p ${AAD_CLIENT_SECRET}
azure storage account connectionstring show ${1} --resource-group ${RESOURCEGROUP} > ~/.azuresettings/$1/connection.out
sed -n '/connectionstring:/{p}' < ~/.azuresettings/${1}/connection.out > ~/.azuresettings/${1}/dataline.out
export DATALINE=$(< ~/.azuresettings/${1}/dataline.out)
export AZURE_STORAGE_CONNECTION_STRING=${DATALINE:27}

qemu-img create -f raw /tmp/image.raw ${5}G
mkfs.xfs /tmp/image.raw
qemu-img convert -f raw -o subformat=fixed -O vpc /tmp/image.raw /tmp/image.vhd
rm -f /tmp/image.raw

TIMES=$(expr ${4} - 1)

for ((i=0;i<=TIMES;i++))
do
  azure storage blob upload /tmp/image.vhd ${2} $3-${i}.vhd
  echo "https://${1}.blob.core.windows.net/${2}/$3-${i}.vhd"

  cat<<OEF | oc create -f -
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: "${3}-${i}"
spec:
  capacity:
    storage: "${5}Gi"
  accessModes:
    - "ReadWriteOnce"
  persistentVolumeReclaimPolicy: Delete
  azureDisk:
    diskName: "${3}-${i}"
    diskURI: "https://${1}.blob.core.windows.net/${2}/${3}-${i}.vhd"
    cachingMode: None
    fsType: xfs
    readOnly: false
OEF
done

rm -f /tmp/image.vhd
EOF

chmod +x /home/${AUSERNAME}/create_pv.sh

cat <<EOF > /home/${AUSERNAME}/.ansible.cfg
[defaults]
remote_tmp     = ~/.ansible/tmp
local_tmp      = ~/.ansible/tmp
host_key_checking = False
forks=30
gather_timeout=60
timeout=240
callback_whitelist = profile_tasks, timer
library = /usr/share/ansible:/usr/share/ansible/openshift-ansible/library
[ssh_connection]
control_path = ~/.ansible/cp/ssh%%h-%%p-%%r
ssh_args = -o ControlMaster=auto -o ControlPersist=600s -o ControlPath=~/.ansible/cp-%h-%p-%r
pipelining = True
EOF
chown ${AUSERNAME} /home/${AUSERNAME}/.ansible.cfg

cat <<EOF > /root/.ansible.cfg
[defaults]
remote_tmp     = ~/.ansible/tmp
local_tmp      = ~/.ansible/tmp
host_key_checking = False
forks=30
gather_timeout=60
timeout=240
callback_whitelist = profile_tasks, timer
library = /usr/share/ansible:/usr/share/ansible/openshift-ansible/library
[ssh_connection]
control_path = ~/.ansible/cp/ssh%%h-%%p-%%r
ssh_args = -o ControlMaster=auto -o ControlPersist=600s -o ControlPath=~/.ansible/cp-%h-%p-%r
pipelining = True
EOF


chmod 755 /home/${AUSERNAME}/openshift-install.sh
chmod 755 /home/${AUSERNAME}/openshift-postinstall.sh
#oc create -f /home/${AUSERNAME}/scgeneric.yml
echo "${AUTOINSTALL}" > /home/${AUSERNAME}/.autoinstall

if [[ ${AUTOINSTALL} != false ]]; then
  cd /home/${AUSERNAME}
  echo "${RESOURCEGROUP} Bastion Host is starting OpenShift Install" | mail -s "${RESOURCEGROUP} Bastion OpenShift Install Starting" ${RHNUSERNAME} || true
  /home/${AUSERNAME}/openshift-install.sh &> /home/${AUSERNAME}/openshift-install.out &
  /home/${AUSERNAME}/openshift-postinstall.sh &> /home/${AUSERNAME}/openshift-postinstall.out &
fi
exit 0
