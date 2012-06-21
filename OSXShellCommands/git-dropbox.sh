#!/bin/bash
# Script by Li Richard
# Creates git projects for file folders by making the origin Dropbox. You will need to install Dropbox for this to work.
# Reference URL is http://stackoverflow.com/questions/1960799/using-gitdropbox-together-effectively

ProjectPath=$(pwd)
ProjectName=$(basename $ProjectPath)
GIT=/usr/local/bin/git

#Please notice that if use "~" as path you should use $HOME instead
DropboxPath="$HOME/Dropbox/git"

echo "#${ProjectName}" > README.md ;

# Enable git with this project.
if [ -s '.git' ] ; then
    echo "    $ProjectName is already a git repository, ignoring..."
else
    echo "    Initializing git for $ProjectName..."
    git init -q
    git add .
    git commit -m "first commit to Dropbox." -q

    # Make the origin Dropbox.

	echo "    Putting $ProjectName project on Dropbox..."
    if [ ! -d $DropboxPath ]; then  
	 	mkdir -p $DropboxPath
	fi

	cd $DropboxPath
	if [ ! -d ${DropboxPath}/Repositories ]; then 
		mkdir Repositories
	fi
	cd Repositories
	mkdir ${ProjectName}.git
	cd ${ProjectName}.git
	
	git init -q --bare

    # Link the project to the origin
    echo "    Copying local $ProjectName to Dropbox..."
    cd $ProjectPath
    git remote add origin ${DropboxPath}/Repositories/${ProjectName}.git
    git push -q origin master
    #git branch --set-upstream master origin/master
fi





