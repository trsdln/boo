# Meteor Deployment Toolkit

Features: 

* Multiple deployment environment support
* Multiple configurations support
* Additional useful actions that work at context of specific server
* Custom actions support

Super useful for lazy people: configured once - use any time.

Should be executed from meteor project's root directory (where `.meteor` is located).

Looks for configurations at `../config/<configuration-name>`

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

MONGO_USER="db_user"
MONGO_PASSWORD="db_user_password"
MONGO_HOST="mongo.db.host.com:3001"
MONGO_DB="mongo_db_name"
MONGO_URL="mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}/${MONGO_DB}"

# or if you need to specify replicaSet:
# MONGO_URL="mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}/${MONGO_DB}?replicaSet=set-example"

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


## boo deploy

Usage:

```
boo deploy <configuration-name>
```

Supports:

* Heroku (requires Heroku Toolbelt)
* AWS (requires Mupx)
* Galaxy

## Additional useful features

* `boo build <configuration-name>` builds Meteor's Web, iOS (opens in Xcode) and Android (signs and optionally installs on device) apps;
* `boo mongo <configuration-name>` open Mongo shell by server name;
* `boo db-copy <configuration-name>` copy server's database to `.meteor/local/db`;
* `boo db-restore <configuration-name>` restore database at `.meteor/local/db` to remote server;
* `boo run <configuration-name>` starts with application with specified configuration. If `ROOT_URL` is defined then it will be used as Meteor's `--mobile-server`;
* `boo clean` remove app's build cache (similar to `meteor reset`, but doesn't remove database);
* `boo help <action-name>` prints short help about specified action.

## Custom actions

You can define your own actions as bash functions at `./conf/boo-actions.conf`.

#### Tested on:

* Mac OS X

 
## Future work

- [x] custom scripts
- [ ] describe deployment configuration for each platform in docs
- [ ] add configuration examples
- [ ] describe additional keys for other commands
