# grav-docs-syseleven-stack

## SysEleven Stack Documentation Repository

[![Build Status](https://travis-ci.org/syseleven/grav-docs-syseleven-stack.svg?branch=master)](https://travis-ci.org/syseleven/grav-docs-syseleven-stack) 
[![GitHub license](https://img.shields.io/github/license/syseleven/grav-docs-syseleven-stack.svg)](https://github.com/syseleven/grav-docs-syseleven-stack/blob/master/LICENSE)

The content of master is automatically displayed at [https://docs.syseleven.de/syseleven-stack](https://docs.syseleven.de/syseleven-stack) in a [Grav CMS](https://getgrav.org/) installation.

## Development

To check if the markdown is valid run:

```bash
$ npm run lint
```

## Contributions

We welcome contributions and fixes for our documentation. 

It is important that you respect the directory structure pattern already present under `/pages`, so that grav is able to find and link the pages correctly:

* Every page needs one folder
* The folder name maps to the url slug
* The folder name should be prefixed with a number used for ordering the menu items
* Maximum nesting level is 2
* The markdown file with the content within one folder has to be named `default.en.md`
* Content is written in markdown. More information about the syntax can be found [here](https://learn.getgrav.org/content/markdown)
* Be aware that every file needs a Grav specific header. More information about the header can be found [here](https://learn.getgrav.org/content/headers)
* Images are stored in the folder '/pages/images/'
* Links to images and other pages should be relative links to the markdown file, grav will automatically rewrite them correctly

To ensure that there are no syntax errors and that the metadata is correct, run `npm run lint` before creating a pull request.
