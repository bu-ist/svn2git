#!/bin/bash

function usage() {
	echo ""
	echo "+ Usage:"
	echo "  sh $0 [-h] [--stdlayout|-s 0|1] [-g git-url] <svn-url>"
	echo ""
	echo "+ SVN URL: Use the root path of the package (no trailing slash, no trunk/tag)"
	echo "  http://bifrost.bu.edu/svn/repos/wordpress/plugins/bu-taxonomies"
	echo ""
	echo "+ Git URL: Use github URL (https or ssh)"
	echo "  git@github.com:bu-ist/bu-taxonomies.git"
	echo ""
	echo "+ stdlayout: On by default. Use --stdlayout 0 to avoid it."
	echo "  git@github.com:bu-ist/bu-taxonomies.git"
	exit 1
}


function display_info() {
	if [[ $PACKAGE != "" ]]; then
		echo "+ Converting to Git package ($PACKAGE) from SVN URL: $SVNURL"
		if [[ -n "$STDLAYOUT" ]]; then
			echo "+ Using stdlayout."
		else
			echo "+ Not using stdlayout."
		fi
		if [[ $GITURL != "" ]]; then
			echo "+ Pushing git source to $GITURL"
		else
			echo "+ Not pushing git source. DO IT MANUALLY!"
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
	git svn clone $SVNURL git/$PACKAGE $STDLAYOUT --no-metadata --authors-file=bu-git-authors.txt
	if [[ $? != "0" ]]; then
		echo "PROBLEM! Something is wrong with the git-svn checkout."
		echo "May be missing authors in bu-git-authors.txt file!"
		echo "Check above. Fix and commit new version of bu-git-authors.txt."
		echo "Delete broken checkout from git/$PACKAGE. Rerun script."
		exit
	fi
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

# Constants
SVNURL=""
GITURL=""
LOCPATH=`pwd`
PACKAGE=""
STDLAYOUT="--stdlayout"

# Parse
while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
		-s|--stdlayout)
		if [[ "$2" == "0" ]]; then
			STDLAYOUT=""
		fi
		shift
		;;
		-g|--git)
		GITURL="$2"
		shift # past argument
		;;
		-h|--help)
		usage
		;;
		*)
		SVNURL="$1"
		;;
	esac
	shift # past argument or value
done

PACKAGE=$(basename "$SVNURL")

# Action!
display_info
confirmation
test_svn
git_clone
cleanup_branches
cleanup_svn_meta
create_tags
push_to_git