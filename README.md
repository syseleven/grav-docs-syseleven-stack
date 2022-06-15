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

## Local testing

To test changes locally before pushing the repository, run:

```sh
docker-compose up --build
```

Then open http://localhost:8080/syseleven-stack in your browser. **Grav is caching very aggressively, if you don’t see changes made, reload without cache.

**Important: If you make changes to the content, you have to execute the command again as all content is built into the image statically**

## Multi-language support

Available documentation languages can be configured in [`user/config/system.yaml`](user/config/system.yaml).

Markdown files must be at least available in English language; If a translation is not available grav will
fall back to English language.

At the moment (Dec 2021) we only support English language documentation. As we used to have German language docs
as well, the German links (/de) are redirected to English pages (/en) for SEO and UX reasons.
In production this permanent redirect is implemented outside of this repository.

For the docker image to test with we implemented a `RedirectMatch` rule in an additional [`.htaccess`](user/apache2/.htaccess) file. 
We deploy the .htaccess file in the [`Dockerfile`](Dockerfile) using `COPY`. Please note that there is another
`.htaccess` file in `/var/www/html/syseleven-stack/` from the parent container; statements there will take precedence.
For that reason you cannot use `Rewrite` rules unfortunately.
