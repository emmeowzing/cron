#! /bin/bash
# Compile resume.

#PATH=/home/brandon/anaconda3/bin:/home/brandon/anaconda3/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

location="/homePool/home/resume/brandon-doyle-resume.tex"

out="$(dirname "$location")"
file="$(basename "$location")"
misc="$out/misc"

if ! [ -d "$misc" ]
then
    mkdir "$misc"
fi


# Compile (ensure options / flags are before the file name, otherwise this
# won't work).
pdflatex -var-value="$out" -output-directory="$misc" "$location"


# Clean up
mv "$misc/${file%.*}.pdf" "$out/"

if [ -n "$(ls -A "$misc")" ]
then
    rm "$misc/"*
fi

rmdir "$misc"

unset location out file misc PATH

sudo -u brandon DISPLAY=":1" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus" notify-send "Resume has been recompiled at ${location}"
