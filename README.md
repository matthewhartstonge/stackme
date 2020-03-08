# StackMe

##### An Nginx, PHP-FPM, Maria/Postgres Stack

These stacks seek to provide a customisable more-ready-for-production 
docker-compose based templates for php based CMSs.

## Why?
Simply put files in the right folders then go on your merry way laughing to the
bank as you now have a solid-docker-composed-super-speedy-stack.

## Features

* nginx (alpine)
* php-fpm 7 (alpine + customisation)
* MariaDB/PostgresSQL

## Quickstart
### Fresh beginnings

1. Make sure you have [docker][docker] AND [docker-compose][docker-compose] installed on your host.
2. download the latest version of your hot new php based CMS:
..* [Joomla](https://downloads.joomla.org/)
..* [Wordpress](https://wordpress.org/download/)
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

* apcu - For an alternate opcache.
* apcu_bc - This module provides a backwards APC compatible API using APCu (object caching).
* gd - A graphics drawing library that enables manipulating image data.
* imagick - ImageMagick is a free and open-source software suite for displaying, creating, converting, modifying, and editing raster images.
* mysqli - MySQL PHP driver.
* pdo - A lean, consistent way to access databases.
* pdo_pgsql - A driver that implements the PHP Data Objects (PDO) interface.
* pgsql - PostgresSQL PHP Driver.
* tidy - For correcting and minifying HTML assets.
* zip - Well, for zipping things!

## Building

The easiest way to get the docker image to build is to use `docker-compose` itself, for example:

```shell
docker-compose -f ./wordpress/docker-compose.yml build
```

## Todo

- [ ] Nginx SSL config.
- [ ] Create script to get latest CMS - that also puts files in the right places.
- [ ] Create script to generate config given a site name.

## Contributions
Will take Issues, PRs, new CMS stacks, db/php performance tweaks - all the things!



[docker]: https://www.docker.com
[docker-compose]: https://docs.docker.com/compose/install/