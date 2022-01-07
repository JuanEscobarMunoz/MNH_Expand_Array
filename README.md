#
# MNH_Expand_Array : Juan ESCOBAR
#
# quelques scripts perl/bash utilisant "filepp" pour convertir
# l'array syntaxe fortran en bloucle DO imbriqué ou DO CONCURRENT
#

#
#  Prérequis installation de filepp ( et perl )
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
#  Quelques Infos pour le developpement test de ces scripts filepp
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