# wallpaper-changer
Simple script to download latest Bing picture, set it as Ubuntu wallpaper and
lock screen. Tested on Ubuntu 17.10

## Dependencies
Among standard utilities, script use "jq" command so before execution please make sure that it is available.
```
install jq
```
Also, if you are going to run it with Cron make sure that Cron can see it. Example below shows PATH variable upgrade available in the script:
```
PATH="$PATH:/snap/bin"
```

## Usage
Just run the script. It will be executed once and quit. You can schedule it with
Cron. This example shows how to execute it every 10 mins:

```
*/10 * * * * /path/to/wallpaper-changer.sh
```

## Protip
You can change default wallpapers path by changing "WALLPAPER_PATH" variable in the script. However, avoid using spaces. "find" command on the end of the script has problems with them.
