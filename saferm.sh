#!/bin/bash

rootname_inode=$1

function recyclebinCheck(){

        if [ ${#RMCFG} -gt 0 ] ; then
                recyclePath=$RMCFG
        elif [ -f $HOME/.rm.cfg ] ; then
                recyclePath=$(head -n1 ~/.rm.cfg)
        else
                recyclePath=$HOME/deleted
        fi

        if [ ! -d $recyclePath ] ; then
                mkdir $recyclePath
        fi
}

function grabInfo(){

        rootname=$(echo $rootname_inode | cut -d"_" -f1)
        inode=$(echo $rootname_inode | cut -d"_" -f2)
        restoreInfo=$(grep $rootname'_'$inode* ~/.restore.info)
        filePath=$(echo $restoreInfo | cut -d":" -f2)
        DirName=$(dirname $filePath)
}

function restoreFile(){
        checkDir $1
        mv $recyclePath/$rootname_inode $DirName/$rootname
}

function removeRestoreInfo(){

        grep -nv ^$1 ~/.restore.info > ~/tempRestore
        mv ~/tempRestore  ~/.restore.info
}

function overwriteFile(){

        read -p "do you want to overwrite $rootname ? (y/n)" response2
                if [ $response2 == 'y' ] ; then
                        restoreFile $rootname_inode
                        removeRestoreInfo $rootname_inode
                else
                        exit
                fi
}

function checkDir() {

   local directory=$(dirname $filePath)
   if [ ! -d $directory ] ; then
      mkdir -p $directory
   fi
}



recyclebinCheck

if [ ! -e $recyclePath/$rootname_inode ] ; then
        echo "safe_rm_restore: file does not exist"
else
        grabInfo $1
fi

if [[ -e $recyclePath/$rootname_inode && -e $DirName/$rootname ]] ; then
        overwriteFile $1
elif [ -e $recyclePath/$rootname_inode ] ; then
        grabInfo $1
        restoreFile $1
        removeRestoreInfo $1
fi
