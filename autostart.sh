#! /bin/bash

pids="~/.config/awesome/autostart.pid" 

startall() {
    for script in ~/.config/awesome/autostart.d/S* ; do
        $script start &
        pid="$pid $!"
    done
    echo $pid > $pids
}

stopall() {
    for script in ~/.config/awesome/autostart.d/S* ; do
        $script stop &
    done
    kill -INT $( cat $pids )
}

if [ "x$1" == "x" ] ; then
    startall
elif [ "x$1" == "xstop" ] ; then
    stopall
fi

