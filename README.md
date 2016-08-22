# svn2git
Convert SVN repos into Git

## Usage
```bash
sh svn2git.sh <svn-url> [git-url]"
```

## Parameters
* SVN URL: Use the root path of the package (no trailing slash, no trunk/tag)
  `http://bifrost.bu.edu/svn/repos/wordpress/plugins/bu-thickbox`

* Git URL: Use GitHub URL (https or ssh)
  `git@github.com:bu-ist/bu-thickbox.git`

## Example
```bash
sh svn2git.sh http://bifrost.bu.edu/svn/repos/wordpress/bu-thickbox git@github.com:bu-ist/bu-thickbox.git
```
