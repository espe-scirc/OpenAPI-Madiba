OpenAPI-Madiba
==============

Application d'authentification et de suivi de volume pour les copieurs Konica


==================================================================================

Rappel : Le code source disponible ici est fourni "en l'état".
  En aucun cas, les auteurs de ce code ne pourront être tenu pour reponsable de tout dommage causé à un copieur,
  un ordinateur, Internet etc...
  
==================================================================================

Installation :

  Si vous souhaitez utiliser ce code, il y a quelques chemin inscrit en dur dans les scripts. Toujours au début, mais quand même.
  Pour vous évitez les modifications, vous pouvez mettre le code suivant dans : /srv/konica
  
  Ensuite, il y a deux fichiers de configuration dans le dossier scripts : Ldaptest.pm-a-modifier et DBtest.pm-a-modifier.
  Copiez les en supprimant la mention -a-modifier. Puis modifiez les.
  Exemple : Ldaptest.pm-a-modifier devient Ldaptest.pm
  
  Dans le dossier scripts toujours, le fichier cronjob.pl est à faire exécuter par une tâche planifiée si vous voulez un reporting planifié. Cela permet l'envoie de mail.
  
  Bien évidemment, il y a des pré-requis :
  
  Plusieurs modules Perl sont indispensables ainsi qu'un serveur HTTP et un serveur de base de données. Je vous fournie des fichiers de configuration Apache fonctionnels sous Debian Wheezy.
  
