# MongoDB Scripts Toolkit

Features:

* Multiple configurations support
* Multiple deployment environment support
* Additional useful actions that work at context of specific server
* Custom actions support

Super useful for lazy people: configured once - use any time.

Some commands should be executed from Meteor project's root directory (where `.meteor` is located).

Looks for configurations at `../config/<configuration-name>` or where `BOO_CONFIG_ROOT` from `.boorc` points to.

## Configuration example

`../config/production/settings.json`:

```
{
  "comment": "your application settings here"
}
```

`../config/production/deploy.conf`:

```
# Deployment configuration example for Meteor Galaxy server

SERVER_DESCRIPTION="Production server"
SERVER_TYPE="galaxy"
VERIFY_TIMEOUT=20

MONGO_URL="mongodb://user:pass@localhost:27017/meteor"

DEPLOY_HOSTNAME="us-east-1.galaxy-deploy.meteor.com"
DOMAIN_NAME='app.company.com'
ROOT_URL="https://${DOMAIN_NAME}/"

# optially you can specify organization name at Galaxy
OWNER_ID="glaxy_organization_name"
```

## Syntax

```
boo <action> [configuration-name] [addtional_keys]
```

## Features

* `boo db-copy <config-name>` save specified environment DB dump at
  `./.dump`;
* `boo db-restore <config-name-from> <config-name-to>` restore locally stored from DB to specified database at `<config-name-to>`;
* `boo mongo <configuration-name>` open Mongo shell by server name;
* `boo build <configuration-name>` builds Meteor's Web, iOS (opens in Xcode) and Android (signs and optionally installs on device) apps;
* `boo run <configuration-name>` starts with application with specified configuration. If `ROOT_URL` is defined then it will be used as Meteor's `--mobile-server`;
* `boo clean` remove app's build cache (similar to `meteor reset`, but doesn't remove database);
* `boo help <action-name>` prints short help about specified action.

## boo deploy (Legacy)

Usage:

```
boo deploy <configuration-name>
```

Supports:

* Heroku (requires Heroku Toolbelt)
* AWS (requires Mupx)
* Galaxy

## Custom actions

You can define your own actions as bash functions at `./conf/boo-actions.conf`.

#### Tested on:

* Mac OS X

## Changelog

#### 3.0.0

- [x] __breaking change__: simplify `db-*` scripts to do single action at a time (gives more
  flexibility). Old vs. new:
  * `boo db-copy test` => `boo db-copy test && boo db-restore test
  local -Y`
  * `boo db-restore test` => `boo db-copy local && boo db-restore
  local test -Y`
- [x] add `--yes-im-sure` flag to `db-restore` script
