# wallpaper-changer
Simple script to download latest Bing picture, set it as Ubuntu wallpaper and
lock screen. Tested on Ubuntu 17.10

## Dependencies
Among standard utilities script use "jq" command so before execution please make sure that it is available.
```
install jq
```
Also, if you are going to run it with Cron make sure that Cron can see it.

## Usage
Just run the script. It will be executed once and quit. You can schedule it with
Cron. This example shows how to execute it every 10 mins:

```
*/10 0 * * * bash /path/to/wallpaper-changer.sh
```
