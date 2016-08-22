#! /bin/bash
#
# Convert tag branches created during `git svn clone` to annotated Git tags.
#
# By default `git svn` imports Subversion tags as branches. This script finds the
# merge base for each tag branch from master (e.g. the commit that the original tag was created from) and applies the
# Git tag to that commit, then removes the tag branch.
#
# NOTE: You should alway review the tag branches to make sure there are no actual
# changes committed to them that would be lost by force deleting.
#

for tag_branch in `git branch | grep "tags/"`; do

	# Extract numeric tag from branch name
	tag=${tag_branch:5}

	# Find the parent commit of commit captured in the tag branch
	commit=`git merge-base $tag_branch master`

	# Create an annotated tag
	echo "Creating tag $tag for branch $tag_branch ($commit)."
	git tag -am "Release $tag" $tag $commit

	# Remove the old tag branch
	echo "Tag branch $tag_branch removed."
	git branch -D $tag_branch
done;

