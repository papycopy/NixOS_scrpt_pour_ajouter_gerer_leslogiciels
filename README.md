il est difficile ou pénible pour un novice d aller modifier le fichier /etc/nixos/configuration.nix pour ajouter des logiciels si on ne veux pas mettre de flatpak alors j ai fait un script pour automatiser ça
on est obligé au moins une fois pour mettre une phrase repere  pour le script
éditez le fichier configuration.nix avant et ajouter

# NOUVEAUX_PAQUETS_ICI"

a la suite de l exemple
`sudo nano /etc/nixos/configuration.nix`
télécharger le script ci joint:
rendez le exécutable
`chmod +x ajout_logiciel.sh`
utilisation:exemple
`sudo ./ajout_logiciel.sh add brave fish`
pour suppr vous remplacez add par rm
ps: ça vérifie si pas déjà installé, si non il l installe et la fin du script il rebuild tout seul
faut juste redémarrer pour les voir installé
`sudo ./ajout_logiciel.sh list`
pour lister les paquet installé par vous
