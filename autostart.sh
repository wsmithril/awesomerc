#! /bin/bash

for script in ~/.config/awesome/autostart.d/S* ; do
    exec $script &
done

