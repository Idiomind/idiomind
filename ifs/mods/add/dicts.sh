#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source "/usr/share/idiomind/ifs/mods/cmns.sh"
DC_a="$HOME/.config/idiomind/addons"
lgtl="$(sed -n 1p "$HOME/.config/idiomind/s/6.cfg")"
lgt=$(lnglss "$lgtl")
DM_tls="$HOME/.idiomind/topics/$lgtl/.share"
v=vj27z

if [ ! -d "$DC_a/dict/" ]; then
mkdir -p "$DC_a/dict/enables"
mkdir -p "$DC_a/dict/disables"
cp -f "$DS_a/Dics/disables"/* "$DC_a/dict/disables"/; fi
[ ! -f "$DC_a/dict/.lng" ] && echo -e "$lgtl\n$v" > "$DC_a/dict/.lng"

if  [[ -z "$(ls "$DC_a/dict/enables/")" ]] \
|| [[ "$(sed -n 1p "$DC_a/dict/.lng")" != "$lgtl" ]] ; then
"$DS_a/Dics/cnfg.sh" "" f " $(gettext "Please select at least one dictionary")"
echo -e "$lgtl\n$v" > "$DC_a/dict/.lng"; fi

function dictt() {
    
    export lgt
    word="${1}"
    [ -d "${2}" ] && cd "${2}"/ || exit 1
    for dict in "$DC_a/dict/enables"/*; do
    "${dict}" "${word}"
    if [ `du ./"${word}.mp3" |cut -f1` = 0 ]; then rm ./"${word}.mp3"
    if [ -f ./"${word}.mp3" ]; then break; fi
    done
}
