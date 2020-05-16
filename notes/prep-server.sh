#!/bin/bash

#
# Définitions de fonctions
#

printMessage () {
  echo -e "\n$Yellow$1$Cyan"
  $1>>~/infos.txt
}


#
# Définitions de variables
#

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
Color_Off='\033[0m'       # Text Reset


#
# Debut du script
#

if [[ "${UID}" -ne 0 ]]; then
    printMessage "[NFO] Vous devez executer le script en ROOT"
    exit 1
fi

printMessage "\n[NFO] Installation des programmes"
apt -y update
apt -y upgrade
apt -y install unzip unrar-free wget

printMessage "\n[NFO] Création d'un utilisateur"

read -p "[QUS] Identifiant de l'utilisateur : " NAME_USER
adduser $NAME_USER --disabled-password

PSD_USERG=$(</dev/urandom tr -dc '12345!{}()[]-_@#$%qwertQWERTasdfgASDFGzxcvbZXCVB\\!$/' | head -c32; echo "")
read -p "[QUS] Mot de passe de l'utilisateur [$PSD_USERG]: " PSD_USER
PSD_USER=${PSD_USER:-$PSD_USERG}
printMessage="\n[NFO] Le mot de passe est $PSD_USER"
sudo passwd $PSD_USER
PSD_USER=''
PSD_USERG=''

printMessage "\n[NFO] Ajout des droits admins"
usermod -aG sudo $NAME_USER

printMessage "\n[NFO] Allègement des règles sur la demande du mot de passe"
echo "$NAME_USER ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/010-$NAME_USER-nopassword

read -p "[QUS] Nom du serveur : " NEW_HOSTNAME
sudo hostnamectl set-hostname $NEW_HOSTNAME

CURRENT_HOSTNAME=$(hostname)
HOSTNAME_FQDN=$(hostname --all-fqdns)
printMessage "\n[NFO] Vérifier que le nom $HOSTNAME_FQDN soit associé à une IP, zone DNS, enregistrement A"
#sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts

mv /etc/hosts /etc/hosts.old
cat <<EOF >/etc/hosts
127.0.0.1       localhost

::1     localhost       ip6-localhost   ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

127.0.1.1       $NEW_HOSTNAME
127.0.1.1       $HOSTNAME_FQDN       $NEW_HOSTNAME
EOF

printMessage "\n[NFO] Pensez à ajouter la clé SSH dans le fichier ~/.ssh/authorized_keys"
printMessage "\n[NFO] La commande depuis votre poste est : "
printMessage "\n[NFO] cat ~/.ssh/id_rsa.pub | ssh @NAME_USER@@$HOSTNAME_FQDN \"cat - >> ~/.ssh/authorized_keys\""

printMessage "\n[NFO] Préparation de SSH"
mkdir /home/$NAME_USER/.ssh/
chown $NAME_USER:$NAME_USER /home/$NAME_USER/.ssh/
SSH_PORT=$((1000 + RANDOM % 9999))

printMessage "\n[NFO] Le port SSH est désormais le $SSH_PORT"

sed -i 's/#\?\(Port\s*\).*$/\1 $SSH_PORT/' /etc/ssh/sshd_config
sed -i 's/#\?\(PerminRootLogin\s*\).*$/\1 no/' /etc/ssh/sshd_config
sed -i 's/#\?\(PubkeyAuthentication\s*\).*$/\1 yes/' /etc/ssh/sshd_config
sed -i 's/#\?\(PermitEmptyPasswords\s*\).*$/\1 no/' /etc/ssh/sshd_config
#sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 no/' /etc/ssh/sshd_config
systemctl restart ssh
systemctl restart sshd

wget https://raw.githubusercontent.com/cedricAbonnel/server-web/master/scripts/bash_aliases
mv bash_aliases /home/$NAME_USER/.bash_aliases
chown $NAME_USER:$NAME_USER /home/$NAME_USER/.bash_aliases
chmod +x /home/$NAME_USER/.bash_aliases


printMessage "\n[NFO] Les informations sont notées dans le fichier ~/infos.txt"
