# Github Migration script

This script helps in migrating private/public repositories from Bitbucket to Github.
This includes migration of all branches, tags etc


# Prerequisites

- SSH authentication must be configured by adding ssh public keys to Bitbucket as well as Github settings

# Usage

This script requires two inputs
1. Existing Bitbucket repo name
2. SSH url of the new Github repo

```bash
chmod +x migrate.sh
./migrate.sh
```
OR
```bash
sh migrate.sh
```
