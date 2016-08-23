# svn2git
Convert SVN repos into Git

## Usage
```bash
sh svn2git.sh [-h] [--stdlayout|-s 0|1] [-g git-url] <svn-url>
```

## Parameters
* SVN URL: Use the root path of the package (no trailing slash, no trunk/tag)
  `http://bifrost.bu.edu/svn/repos/wordpress/plugins/bu-taxonomies`

* Git URL: Use GitHub URL (https or ssh)
  `git@github.com:bu-ist/bu-taxonomies.git`

* stdlayout: On by default. Use `--stdlayout 0` to avoid it. Necessary to avoid for themes.

## Example
```bash
sh svn2git.sh http://bifrost.bu.edu/svn/repos/wordpress/bu-taxonomies git@github.com:bu-ist/bu-taxonomies.git
```
