# StackMe

##### An Nginx, PHP-FPM, Maria/Postgres Stack

These stacks seek to provide a customisable more-ready-for-production 
docker-compose based templates for php based CMSs.

## Why?
Simply put files in the right folders then go on your merry way laughing to the
bank as you now have a solid-docker-composed-super-speedy-stack.

## Features

* nginx (alpine)
* php-fpm 7/8 (alpine + customisation)
* MariaDB/PostgreSQL
* varnish-cache*

*currently wordpress only.

## Quickstart
### Fresh beginnings

1. Make sure you have [docker][docker] AND [docker-compose][docker-compose] installed on your host.
2. download the latest version of your hot new php based CMS:
    * [Joomla](https://downloads.joomla.org/)
    * [Wordpress](https://wordpress.org/download/)
3. unzip that bad boy into the `./YOUR_CMS_CHOICE/html` folder.
4. Run the following in a terminal to correct file ownership for alpine:

```sh
cd ./wordpress
chmod +x conform.sh && ./conform.sh
docker-compose up
```

At which point Docker should do it's thing, pulling, building and getting ready
for you to take over the interwebs. Yus.

But, you probably wanna make that thing more secure. So crack into the docker
compose file and change the ENVvars to something more suitable than 'secret'.

### Not so new beginnings

If you've already got a current CMS running, you will need to back up your 
static files and database.

Both MariaDB and PostgresSQL have a similar interface to import existing
databases. This involves adding either a *.sql or *.sh script to the 
'/docker-entrypoint-initdb.d' directory. See the respective docker-compose files
to see how to implement it. You may want to comment it out after the DB has been
imported.

## Changes to php-fpm base
For the images to work better with popular CMS's the following php extensions 
have been added to the base upstream image:

* `apcu` - For an alternate user object cache.
* `bcmath` - For arbitrary precision mathematics, which supports numbers of any size and precision up to 2147483647 decimal digits.
* `bz2` - Provides bzip2 de/compression.
* `exif` - For reading image metadata.
* `gd` - A graphics drawing library that enables manipulating image data.
* `imagick` - ImageMagick is a free and open-source software suite for displaying, creating, converting, modifying, and editing raster images.
* `intl` - Enables performing locale-aware operations including but not limited to formatting, transliteration, encoding conversion, calendar operations, conformant collation, locating text boundaries and working with locale identifiers, timezones and graphemes.
* `mysqli` - MySQL PHP driver.
* `opcache` - Improves PHP performance by storing precompiled script bytecode in shared memory, thereby removing the need for PHP to load and parse scripts on each request.
* `pdo` - A lean, consistent way to access databases.
* `pdo_mysql` - A driver that implements the PHP Data Objects (PDO) interface for MySQL.
* `pdo_pgsql` - A driver that implements the PHP Data Objects (PDO) interface for PostgreSQL.
* `pgsql` - PostgresSQL PHP Driver.
* `tidy` - For correcting and minifying HTML assets.
* `zip` - Well, for zipping things!

Apps installed:
* `ghostscript` - For interpreting PDFs.
* `imagick` - For processing images.

## Building

The easiest way to get the docker image to build is to use `docker-compose` itself, for example:

```shell
docker-compose -f ./wordpress/docker-compose.yml build
```

## Performance Boosting with Varnish
There now exists a wordpress stack that supports the use of [Varnish][varnish] for page caching. 
Varnish can speed up page load for visitors by a massive factor simply by caching the rendered page 
after being processed once by php.

To start playing with this stack, run:

```shell
docker-compose -f ./wordpress/docker-compose.varnish.yml up
```

## Todo

- [ ] Nginx SSL config.
- [ ] Create script to get latest CMS - that also puts files in the right places.
- [ ] Create script to generate config given a site name.

## Contributions
Will take Issues, PRs, new CMS stacks, db/php performance tweaks - all the things!



[docker]: https://www.docker.com
[docker-compose]: https://docs.docker.com/compose/install/
[varnish]: https://varnish-cache.org/