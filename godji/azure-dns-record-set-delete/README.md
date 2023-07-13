# Azure DNS Record Set Delete
This script deletes specific DNS record sets from Azure based on a keyword.

## Usage
* Modify config.sh to include the correct arguments.
* Run main.sh: `./main.sh`

## Config.sh

```
    #!/bin/bash

    #Get the subscription name
    SUBSCRIPTION_NAME=""

    # Get the resource group name and zone name from the user.
    RESOURCE_GROUP_NAME=""
    DNS_ZONE_NAME=""

    # Get the keyword to select the dns record sets.
    # This should be common string in all the record names you want to delete.
    # Examples: hpcc, hpcc2, play
    KEYWORD=""

    # Types of DNS record sets
    RECORD_TYPES=("A" "TXT")
```
