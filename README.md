#!/bin/bash
#
# MNH_Expand_Array : Juan ESCOBAR
#
# quelques scripts perl/bash utilisant "filepp" pour convertir
# l'array syntaxe fortran en bloucle DO imbriqué ou DO CONCURRENT
#
# Set PATH

export PATH={...path_vers}/MNH_Expand_Array:${PATH}

# Usage

mnh_expand [OPTIONS] file.F90 > file.f90

# Les OPTIONS sont principalement des déclarations de macro
# compatible CPP  : -Dclef
# Les options sont séparer entre les options pour CPP classique et les extensions fileppe  via  -DMNH_EXPAND*
#
# /!\ Le script 'Filepp' , a été renommé mnh_expand 
# /!\ pour éviter des problèmes sur MacOS qui confond les noms
# /!\ des scripts écrit en minuscule/Majuscule 

#
#  Prérequis installation de "filepp" ( et perl )
#  REM: certaine version de Linux on un package pour cela 
#
#  par exemple dans l'espace utilisateur <-> quelques secondes ...

export FILEPP=~/PATCH/FILEPP
mkdir -p ${FILEPP}
cd ${FILEPP}
wget https://www-users.york.ac.uk/~dm26/filepp/filepp-1.8.0.tar.gz
tar xvf filepp-1.8.0.tar.gz
cd filepp-1.8.0
./configure --prefix=${FILEPP}/FILEPP-1.8.0
make install

#
# Positionnement de l'environnement pour utiliser filepp
#
export PATH=${FILEPP}/FILEPP-1.8.0/bin:${PATH}
export MANPATH=${FILEPP}/FILEPP-1.8.0/share/man:${MANPATH}

# test de l'installation
filepp -h
man filepp

###############################################################################
#
#  Utilisation , Beta Test
#
###############################################################################
#
# 4 directives ( pour le moment ) permettent de convertir l'array en boucle DO nesté
# ou DO CONCURRENT
#
# Cf l'exemple fourni compute_entr_detr.F90
#
#
# Pour de l'array syntaxe
#
!$mnh_expand_array(ii=iib:iie:ip , ij=i2jb:ije , ik=ikb:ike:iks)

Array synatxe

!$mnh_end_expand_array(Commentaire)

#
# Pour les Where
#
!$mnh_expand_where(ii=iib:iie:ip , ij=i2jb:ije , ik=ikb:ike:iks)

Where + Array Syntaxe

!$mnh_end_expand_where(Commentaire)

#
# /!\ Quelques limites pour les WHERE (pour le moment)
# /!\
# /!\  - Les lignes de continuation doivent finir par "&" + suivi immédiatement par retour a la ligne
# /!\      -> "WHERE ... &{blanc}{blanc}" , ne marche pas !!!
# /!\
# /!\  - Pas de commentaire en fin de ligne 
# /!\       -> "WHERE ... ! commentaire" ne fonctionne pas !!!
# /!\        mettre le commentaire avant ou après le WHERE
# /!\
# /!\  - Les "WHERE (condition) A(:) =..." sur une seule ligne , sans END WHERE , ne fonctionne pas !!!
# /!\      -> a remplacer par
# /!\        WHERE (conditio)
# /!\          A(:)= ...
# /!\        END WHERE
#
#
# Script mnh_expand = lancement 3 commandes filepp pipiliné + options + fichier d'entrée
#
# options
#
#   -DMNH_EXPAND : active la transformation (sinon rien ne se passe <-> commentaire dans le code )
#                 et permet aussi de déclarer/initialiser
#                 les variable de boucles <-> cf "#ifdef MNH_EXPAND" dans l'exemple
#
#
#   -DMNH_EXPAND_LOOP : convertie l'array syntaxe en DO imbriqué , sinon par défaut
#                       la conversion est faite en DO CONCURRENT
#
#   -DMNH_EXPAND_NOCPP : convertie l'array syntaxe , mais conserve toutes les directives CPP
#                        "#ifdef" "#define" , etc ...
#                        -> dans ce cas il faut utiliser des "@" soit "@ifdef" "@define" etc...
#                        dans la code si l'on veux activer du preprocessing
#                          <-> cf  "@ifdef MNH_EXPAND" dans l'exemple
#
#
#Exemples
#
# preprocessing CPP + expansion de l'array syntax convertie en do nesté
#

mnh_expand  -DMNH_EXPAND -DMNH_EXPAND_LOOP compute_entr_detr.F90 > compute_entr_detr.f90

#
# conservation de macro "#..." mais expansion de l'array synatx en do concurrent
#
mnh_expand -DMNH_EXPAND_NOCPP -DMNH_EXPAND  compute_entr_detr.F90 > compute_entr_detr.f90

#
# REM1 : Attention , cet outil est très bete !!!
#
#  Pour le moment l'array syntaxe et convertie en boucle fusionné
#  <-> toutes les lignes dans un seul bloque do ... enddo
#  donc a l'utilisateur de vérifier que les calculs en ARRAY syntaxe
#  n'introduise pas de dépendance d'une ligne a l'autre
#  ( ce qui ne devrait pas etre le problème pour la physique en colonne )
#
#  -> Une option supplémentaire -DMNH_EXPAND_NOFUSE , et en cours
#     de développement pour l'ARRAY syntaxe ( sans  where)
#     qui écrira une boucle par ligne d'array syntaxe
#
#
# REM2 : Première version testé avec MesoNH complet = compilation OK
#        en remplacant dans les fichiers 'Rules.LX...mk'
#
CPP = cpp -P -traditional -Wcomment
# par
CPP = mnh_expand
#
#
# REM3 : si l'on veux activer a la fois les directives avec "@" et "#"
#        et par exemple utiliser "ifdef MNH_EXPAND" il faut utilise la syntaxe
#       -Dmacro=macro
#
# mnh_expand  -DMNH_EXPAND=MNH_EXPAND compute_entr_detr.F90 > compute_entr_detr.f90
#
#   sinon le noms de la macro 'disparait' dans le 'ifdef ...'
#
###############################################################################
#
#  Quelques Infos , sous le capot , pour le developpement test de ces scripts filepp
#
###############################################################################
#
# Pour faire du perl interactif , demmarrer le mode debugger
#
perl -d -e 1

#
# lancement de filepp avec le module MesoNH 
# 
filepp -M. -m MNH.pm  toto.F90

#
# enchainemeent analyse + extend array
#
filepp -imacros mnh_macro_expand.fpp titi.F90  |filepp -imacros mnh_macro_array_loop.fpp -M. -m MNH.pm -c

#
# pour allouer les expresions régulières # ou !$mnh -> SetKeywordchar #|!\$mnh
#
filepp -re -imacros mnh_macro_expand.fpp titi.F90  |filepp -imacros mnh_macro_array_loop.fpp -M. -m MNH.pm -c

#
# le -re pose problème avec "SetMacroPrefix !$mnh " 
#
# By default expand to DO CONCURRENT
#
filepp -DMNH_EXPAND -imacros mnh_macro_expand.fpp titi.F90 | filepp -imacros mnh_macro_array_loop.fpp -M. -m MNH.pm -c >& titi.f90 ; sdiff -w270 titi.F90 titi.f90 | less

#
#  with -DMNH_EXPAND_LOOP expand to LOOP nest
#
filepp -DMNH_EXPAND -imacros mnh_macro_expand.fpp compute_entr_detr.F90 | filepp -DMNH_EXPAND_LOOP -imacros mnh_macro_array_loop.fpp -M. -m MNH.pm -c >& compute_entr_detr.f90 ; sdiff -w270 compute_entr_detr.F90 compute_entr_detr.f90 | less
#
# Script mnh_expand = lancement les 3 commandes filepp + options + fichier d'entrée
#
mnh_expand  -DMNH_EXPAND -DMNH_EXPAND_LOOP compute_entr_detr.F90 > compute_entr_detr.f90 2>error
