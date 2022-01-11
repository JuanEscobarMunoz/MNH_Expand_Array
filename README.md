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

Filepp [OPTIONS] file.F90 > file.f90

# Les OPTIONS sont principalement des déclarations de marcro
# compatible CPP  : -Dclef
#
# /!\ au "F" majuscule 'F'ilepp ,
# /!\ enrobage de la commande de base 'f'ilepp avec un "f" minuscle

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
# Script Filepp = lancement 3 commandes filepp pipiliné + options + fichier d'entrée
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
# Exemple

Filepp  -DMNH_EXPAND -DMNH_EXPAND_LOOP compute_entr_detr.F90 > compute_entr_detr.f90

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
CPP = Filepp
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
# Script Filepp = lancement des 2 commandes filepp + options + fichier d'entrée
#
Filepp  -DMNH_EXPAND -DMNH_EXPAND_LOOP compute_entr_detr.F90 > compute_entr_detr.f90 2>error
