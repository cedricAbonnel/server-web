#!/bin/bash

#
# Définitions de fonctions
#

printMessage () {
  echo -e "\n$Yellow$1$Cyan"
  $1>>~/infos_minecraft.txt
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

printMessage "\n[NFO] Installation des programmes"
sudo apt -y update
sudo apt -y upgrade

sudo apt -y install openjdk-11-jdk git

printMessage "\n[NFO] Préparation du dossier minecraft"
mkdir minecraft
cd minecraft

printMessage "\n[NFO] Récupération de BuildTools"
wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar

printMessage "\n[NFO] Execution de BuildTools"
java -Xmx1G -jar BuildTools.jar –rev latest

printMessage "\n[NFO] Préparation du Lanceur"
cd
echo "cd ~/minecraft">~/start.sh
echo "java -Xms1G -Xmx1G -XX:+UseConcMarkSweepGC -jar ~/minecraft/spigot-1.15.2.jar nogui">>~/start.sh
sudo chmod +x ~/start.sh

sed -i 's/false/true/g' ~/minecraft/eula.txt

printMessage "\n[NFO] Execution du lanceur"
~/start.sh

# astuce : executer le script et quitter la session avec la commande
# nohup ~/start.sh&
