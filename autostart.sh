#! /bin/bash

config_dir=$HOME/.config/awesome
lockfile_dir=/tmp/awesome-autostart

# prepare pidfile dir
[ ! -e $lockfile_dir ] && ( mkdir -p $lockfile_dir || \
    echo 'naughty.notify({title="Autostart:",text="Unable to create autostart pidfile dir",timeout=10,preset=naughty.config.presets.critical})' | awesome-client && exit 1)

start_all() {
    for script in $config_dir/autostart.d/S* ; do
        echo "naughty.notify({title=\"Autostart:\",text=\"Starting \" .. \"$script\" .. \"...\",timeout=2,preset=naughty.config.presets.normal})" | awesome-client
        $script start &
    done
}

stop_all() {
    for script in $config_dir/autostart.d/S* ; do
        $script stop &
    done
}

if [ x"$1" == "xstart" ] ; then
    start_all
else
    stop_all
fi

