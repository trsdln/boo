# Meteor Deployment Toolkit

Multiple environment deployment script + additional useful scripts that
work at context of specific server.

Super useful for lazy people: configured once - use any time.

Should be executed from meteor project's root directory (where `.meteor` located).

Looks for configurations at `../config/<configuration-name>`

## `boo deploy <configuration-name>`

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
* `boo clean` remove app's build cache (similar to `meteor reset`, but doesn't remove database).
 
## Todos: 

- [ ] write detailed documentation about each deployment platform
- [ ] add configuration examples
- [ ] describe addtional keys for other commands
