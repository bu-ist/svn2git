# svn2git
Convert SVN repos into Git

## Usage
Clone this repository.

```bash
cd svn2git

sh svn2git.sh [-h] [--stdlayout|-s 0|1] [-g git-url] <svn-url>
```

## Parameters
* SVN URL: Use the root path of the package (no trailing slash, no trunk/tag)
  `http://bifrost.bu.edu/svn/repos/wordpress/plugins/bu-taxonomies`

* Git URL: Use GitHub URL (https or ssh)
  `git@github.com:bu-ist/bu-taxonomies.git`

* stdlayout: On by default. Use `--stdlayout 0` to avoid it. Necessary to avoid for themes.

* -g: Set git URL

* -h: Help

## Example
```bash
sh svn2git.sh -g git@github.com:bu-ist/bu-taxonomies>.git http://bifrost.bu.edu/svn/repos/wordpress/bu-taxonomies
```
