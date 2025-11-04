# Set drive path, for example /dev/sda
# BE CAREFUL: DRIVE ON THIS PATH WILL BE DELETED, USE COMMAND fdisk -l TO CHECK, WHICH ONE YOU WANT TO ERACE
config_drive="none"

# Set this to your ntfy.sh url
config_ntfy="ntfy.sh/YOUR-UNIQUE-URL"

# If this is set to true, script will keep erasing drive until you disconnect it
config_repeat=false

# Some debug notifications for developers
config_debug=false

curl -d "Eraser script booted" $config_ntfy

sleep 1

if [ "$config_drive" = "none" ]; then
    curl -d "config error: change config variables before running script" $config_ntfy
fi

while ! [ "$config_drive" = "none" ]
do
    if test -b $config_drive; then
        curl -d "Drive to erase found, waiting 10 seconds before erasing" $config_ntfy

        sleep 10

        if ! test -b $config_drive; then
            curl -d "Drive disconnected before erasing, canceling operation" $config_ntfy
        else
            curl -d "Drive is still connected, erasing..." $config_ntfy

            if shred -n 2 -z -v $config_drive; then
                curl -d "Erasing successfull" $config_ntfy

                if ! config_repeat; then
                    curl -d "Repeating is disabled, waiting until drive is diconnected" $config_ntfy

                    while test -b $config_drive
                    do
                        sleep 1
                    done
                fi
            else
                curl -d "Erasing failed, trying again" $config_ntfy
            fi
        fi

    elif $config_debug; then
        curl -d "Drive to erase NOT found, trying again in 5 seconds" $config_ntfy
    fi
    sleep 5
done