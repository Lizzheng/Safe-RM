#!/bin/bash

function findInode(){

        local inode=$(ls -i $1 | cut -d" " -f1)
        echo $inode
}

function restorefileInfo(){

        fullPath=$(readlink -f $1)
        local baseName1=$(basename $1)
        local pathName1=$fullPath
        echo $baseName1'_'$(findInode $1):$pathName1 >> ~/.restore.info
}

function moveFile(){

        local pathName=$(readlink -f $1)
        local baseName=$(basename $1)
        mv $pathName $recyclePath/$baseName'_'$(findInode $1)
}

function checkDir(){

        if [ -d $1 ] ; then
                echo "safe_rm: cannot remove '$1' since it is a directory"
                exit
        fi
}

function checkArg(){

        if [ $# -eq 0 ] ; then
                echo "safe_rm: missing filename"
                exit
        fi
}

function checkFileExist(){

        if [ ! -e $1 ] ; then
                echo "safe_rm: file does not exist"
                exit
        fi
}

function restoreinfoCheck(){

        if [ ! -e  $HOME/.restore.info ] ; then
                recyclebinCheck
                touch $HOME/.restore.info
        fi
}

function verboseFile(){

        if $verbose ; then
                echo "safe_rm: removed $1 "
        fi
}

function interactiveFile() {

        if $interactive ; then
                read -p  "Do you want to delete $1?(y/n)" response
                if [ $response == 'y' ] ; then
                        moveFile $1
                elif [ $response == 'n' ] ; then
                        exit
                else
                        echo "not valid"
                fi
                if [ $verbose ] ; then
                        verboseFile $1
                fi
        fi
}

function recursiveFile(){

        if [[ -d $1 && -s $1 ]] ; then
                        recursiveDelete $1
        fi

        #echo "recursive working"

}

function recursiveDelete(){

        for k in $1/*
        do
                if [ -f $k ] ; then
                        restorefileInfo $k
                        moveFile $k
                        if [ $verbose ] ; then
                                verboseFile $k
                        fi
                elif [ -d $k ] && [ -s $k ] ; then
                        recursiveDelete $k
                fi
        done

        if [ $interactive ] ; then
                read -p "Would you like to delete $1? (y/n)" response_r2
                        if [ $response_r2 == 'y' ] ; then
                                rmdir $1
                                if [ $verbose ] ; then
                                        verboseFile $1
                                fi
                        elif [ $response_r == 'n' ] ; then
                                exit
                        fi
        fi
        #echo "recursive Delete called"

}

function restoreinfoCheck(){

        if [ ! -e  $HOME/.restore.info ] ; then
                recyclebinCheck
                touch $HOME/.restore.info
        fi
}

function recyclebinCheck(){

        if [ ${#RMCFG} -gt 0 ] ; then
                recyclePath=$RMCFG
        elif [ -f $HOME/.rm.cfg ]; then
                recyclePath=$(head -n1 ~/.rm.cfg)
        else
                recyclePath=$HOME/deleted
        fi

        if [ ! -d $recyclePath ] ; then
                mkdir $recyclePath
        fi
}

recyclebinCheck
restoreinfoCheck

checkArg $1
checkDir $1

interactive=false;
verbose=false;
recursive=false;


while getopts :ivr OPT
do
        case $OPT in
        i)interactive=true ;;
        v)verbose=true ;;
        r)recursive=true ;;
        esac
done

shift $(($OPTIND-1))

checkFileExist $1

for z in $*
do

        if $recursive ; then
                recursiveFile $z
        elif $verbose ; then
                restorefileInfo $z
                moveFile $z
                verboseFile $z
        elif $interactive ; then
                restorefileInfo $z
                interactiveFile $z

        else
                restorefileInfo $z
                moveFile $z
        fi

done
