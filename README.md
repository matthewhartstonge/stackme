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

First, make sure you have docker AND docker-compose installed on your host.
If you have downloaded the latest version of your hot new php based CMS, 
unzip that bad boy into the html folder. Then all we need to do is change them
ownerships.

```sh
chmod +x conform.sh
./conform.sh
docker-compose -f docker-compose.YOUR_CHOICE_OF_CMS.yml up
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

* gd - A graphics drawing library that enables manipulating image data
* mcrypt - Provides encryption capabilities
* mysqli - MySQL PHP driver
* pdo - A lean, consistent way to access databases.
* pdo_pgsql - A driver that implements the PHP Data Objects (PDO) interface
* pgsql - PostgresSQL PHP Driver
* zip - Well, for zipping things!

## Building

The easiest way to get the docker image to build is to use `docker-compose` itself, for example:

```shell
docker-compose -f docker-compose.wordpress.yml build
```

## Todo

* Nginx SSL config
* Create cleaner folder structure?
* Create script to get latest CMS - that also puts files in the right places

## Contributions
Will take Issues, PRs, new CMS stacks, db/php performance tweaks - all the things!
