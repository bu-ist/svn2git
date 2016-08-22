#!/bin/bash

function usage() {
	echo ""
	echo "+ Usage:"
	echo "  sh $0 <svn-url> [git-url]"
	echo ""
	echo "+ SVN URL: Use the root path of the package (no trailing slash, no trunk/tag)"
	echo "  http://bifrost.bu.edu/svn/repos/wordpress/plugins/bu-taxonomies"
	echo ""
	echo "+ Git URL: Use github URL (https or ssh)"
	echo "  git@github.com:bu-ist/bu-taxonomies.git"
	exit;
}

function display_info() {
	if [[ $PACKAGE != "" ]]; then
		echo "+ Converting to Git package ($PACKAGE) from SVN URL: $SVNURL"
		if [[ $GITURL != "" ]]; then
			echo "+ Pushing git source to $GITURL"
		fi
		echo ""
	else
		usage
	fi
}

function confirmation() {
	read -p "+ Continue? [yn] " yn
	case $yn in
	    [Nn]* ) exit;;
		[Yy]* ) echo "Continuing...";;
	        * ) echo "Please answer yes or no."; exit;
	esac
}

function test_svn() {

	# Test SVN
	echo "+ List SVN URL items"
	svn list "$SVNURL"

	if [[ $? != "0" ]]; then
		usage
	fi
}

function git_clone() {
	echo "+ Git clone using $SVNURL"
	git svn clone $SVNURL git/$PACKAGE --stdlayout --no-metadata --authors-file=bu-git-authors.txt
	cd git/$PACKAGE
}

function cleanup_branches() {
	echo "+ Recreate and cleanup branches"
	fetch_branches
	for branch in `git branch -r`; do git branch -rd $branch; done
	git branch -d trunk
	for branch in `git branch | grep trunk`; do git branch -d $branch; done # remove trunk@12345 branches
}

function cleanup_svn_meta() {
	echo "+ Cleanup SVN metadata"
	git config --remove-section svn-remote.svn
	rm -Rf .git/svn/
}

function fetch_branches() {
	GITV1R="^1\."
	GITVER=`git --version`
	GITVER=${GITVER/git version /}

	if [[ $GITVER =~ $GITV1R ]]; then
		git fetch . refs/remotes/*:refs/heads/*
	else
		git fetch . refs/remotes/origin/*:refs/heads/*
	fi
}

function create_tags() {
	echo "+ Create matching tags in Git"
	sh $LOCPATH/inc/svn2git-tags.sh
}

function push_to_git() {

	# Push to Github
	if [[ $GITURL != "" ]]; then

		echo ""
		echo "+ If everything is alright..."
		echo ""
		confirmation

		echo "+ Push to Git: $GITURL"
		git remote add origin "$GITURL"
		git push origin --all
		git push origin --tags
	else
		echo "+ NOTE! Use the following commands to push the repo:"
		echo "  git remote add origin URL"
		echo "  git push origin --all"
	fi
}

# Help
if [[ $1 = "-h" || $1 = "--help" ]]; then
	usage
fi

# Constants
SVNURL="$1"
GITURL="$2"
PACKAGE=$(basename "$SVNURL")
LOCPATH=`pwd`

# Action!
display_info
confirmation
test_svn
git_clone
cleanup_branches
cleanup_svn_meta
create_tags
push_to_git