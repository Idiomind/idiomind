#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function check_format_1() {
    source "$DS/ifs/mods/cmns.sh"
    lgt=$(lnglss "$lgtl")
    lgs=$(lnglss "$lgsl")
    LANGUAGES=( 'English' 'Chinese' 'French' \
    'German' 'Italian' 'Japanese' 'Portuguese' \
    'Russian' 'Spanish' 'Vietnamese' )
    CATEGORIES=( 'others' 'comics' 'culture' \
    'family' 'entertainment' 'grammar' 'history' \
    'documentary' 'in_the_city' 'movies' 'internet' \
    'music' 'nature' 'news' 'office' \
    'relations' 'sport' 'social_networks' 'shopping' \
    'technology' 'travel' 'article' \
    'science' 'interview' 'funny' )
    sets=( 'v' 'tname' 'langs' 'langt' \
    'authr' 'cntct' 'ctgry' 'ilink' 'oname' \
    'datec' 'dateu' 'datei' \
    'nword' 'nsent' 'nimag' 'naudi' 'nsize' \
    'level' 'set_1' 'set_2' 'set_3' 'set_4' )
    file="${1}"
    invalid() {
        exit=1
        msg "$1. $(gettext "File is corrupted.")\n" error & exit 1
    }
    [ ! -f "${file}" ] && invalid
    shopt -s extglob; n=0; exit=0
    while read -r line; do
        if [ -z "$line" ]; then continue; fi
        get="${sets[${n}]}"
        val=$(echo "${line}" |grep -o "$get"=\"[^\"]* |grep -o '[^"]*$')
        if [[ ${n} = 1 ]]; then
            if [ -z "${val##+([[:space:]])}" ] || [ ${#val} -gt 60 ] || \
            [ "$(grep -o -E '\*|\/|\@|$|=|-' <<<"${val}")" ]; then invalid 2; fi
        elif [[ ${n} = 2 || ${n} = 3 ]]; then
            if ! grep -Fo "${val}" <<<"${LANGUAGES[@]}"; then invalid 3; fi
        elif [[ ${n} = 4 || ${n} = 5 ]]; then
            if [ ${#val} -gt 30 ] || \
            [ "$(grep -o -E '\*|\/|$|\)|\(|=' <<<"${val}")" ]; then invalid 4; fi
        elif [[ ${n} = 6 ]]; then
            if ! grep -Fo "${val}" <<<"${CATEGORIES[@]}"; then invalid 5; fi
        elif [[ ${n} = 7 ]]; then
            if [ -z "${val##+([[:space:]])}" ] || [ ${#val} -gt 8 ]; then invalid 6; fi
        elif [[ ${n} = 8 ]]; then
            if [ -z "${val##+([[:space:]])}" ] || [ ${#val} -gt 60 ] || \
            [ "$(grep -o -E '\*|\/|\@|$|=|-' <<<"${val}")" ]; then invalid 7; fi
        elif [[ ${n} = 9 || ${n} = 10 || ${n} = 11 ]]; then
            if [ -n "${val}" ]; then
            if ! [[ ${val} =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] \
            || [ ${#val} -gt 12 ]; then invalid 8; fi; fi
        elif [[ ${n} = 12 || ${n} = 13 || ${n} = 14 ]]; then
            if ! [[ $val =~ $numer ]] || [ ${val} -gt 200 ]; then invalid 9; fi
        elif [[ ${n} = 15 ]]; then
             if ! [[ $val =~ $numer ]] || [ ${val} -gt 1000 ]; then invalid 10; fi
        elif [[ ${n} = 16 ]]; then
             if [ "$(grep -o -E '\*|\/|\@|$|\)|\(|=|-' <<<"${val}")" ] || \
             [ ${#val} -gt 9 ]; then invalid 11; fi
        elif [[ ${n} = 17 ]]; then
            if ! [[ $val =~ $numer ]] || [ ${#val} -gt 2 ]; then invalid 12; fi
        fi
        export ${sets[$n]}="${val}"
        let n++
    done < <(tail -n 1 < "${file}" |tr '&' '\n')
    return ${n}
}

check_index() {
    source "$DS/ifs/mods/cmns.sh"
    DC_tlt="$DM_tl/${2}/.conf"; DM_tlt="$DM_tl/${2}"
    topic="${2}"; mkmn=0; f=0; a=0; id=0
    [[ ${3} = 1 ]] && r=1 || r=0
    
    _check() {
        if [ ! -f "${DC_tlt}/0.cfg" ]; then f=1; fi
        if [ ! -d "${DC_tlt}" ]; then mkdir "${DC_tlt}"; fi
        if [ ! -d "${DM_tlt}" ]; then mkdir "${DC_tlt}"; fi
        if [ ! -d "${DM_tlt}/images" ]; then mkdir "${DM_tlt}/images"; fi
        for n in {0..4}; do
            [ ! -e "${DC_tlt}/$n.cfg" ] && touch "${DC_tlt}/$n.cfg" && a=1
            if grep '^$' "${DC_tlt}/$n.cfg"; then
                sed -i '/^$/d' "${DC_tlt}/$n.cfg"; fi
            check_index1 "${DC_tlt}/$n.cfg"
        done
        [ ! -e "${DC_tlt}/id.cfg" ] && echo -e "${c1}" > "${DC_tlt}/id.cfg"
        [ ! -e "${DC_tlt}/10.cfg" ] && echo -e "${c2}" > "${DC_tlt}/10.cfg"
        [ ! -e "${DC_tlt}/9.cfg" ] && touch "${DC_tlt}/9.cfg"
        [[ `wc -l < "${DC_tlt}/id.cfg"` = 21 ]] && id=1
        if [[ ${id} != 1 ]]; then
            eval c1="$(< $DS/default/topicid)"
            echo -e "${c1}" > "${DC_tlt}/id.cfg"; fi
        for i in "${DM_tlt}"/*.mp3 ; do [[ ! -s "${i}" ]] && rm "${i}" ; done
        if grep 'rsntc=' "${DC_tlt}/10.cfg"; then
            rm "${DC_tlt}/10.cfg"; fi
        
        if [ ! -f "${DC_tlt}/8.cfg" ]; then
            echo 1 > "${DC_tlt}/8.cfg"; fi
        export stts=$(sed -n 1p "${DC_tlt}/8.cfg")
        [ $stts = 13 ] && export f=1
        
        cnt0=`wc -l < "${DC_tlt}/0.cfg" |sed '/^$/d'`
        cnt1=`egrep -cv '#|^$' < "${DC_tlt}/1.cfg"`
        cnt2=`egrep -cv '#|^$' < "${DC_tlt}/2.cfg"`
        if [ $((cnt1+cnt2)) != ${cnt0} ]; then
            export a=1; fi
    }
    
    _restore() {
        rm "${DC_tlt}/1.cfg" "${DC_tlt}/3.cfg" "${DC_tlt}/4.cfg"
        while read -r item_; do
            item="$(sed 's/},/}\n/g' <<<"${item_}")"
            type="$(grep -oP '(?<=type={).*(?=})' <<<"${item}")"
            trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
            
            if [ -n "${trgt}" ]; then
                if [ ${type} = 1 ]; then
                    echo "${trgt}" >> "${DC_tlt}/3.cfg"
                elif [ ${type} = 2 ]; then
                    echo "${trgt}" >> "${DC_tlt}/4.cfg"; fi
                echo "${trgt}" >> "${DC_tlt}/1.cfg"
                echo "${item_}" >> "$DT/cfg0"
            fi
        done < "${DC_tlt}/0.cfg"
        > "${DC_tlt}/2.cfg"
    }

    _sanity() {
        cfg0="${DC_tlt}/0.cfg"
        sed -i "/trgt={}/d" "${cfg0}"
        sed -i '/^$/d' "${cfg0}"
        for n in {1..200}; do
            line=$(sed -n ${n}p "${cfg0}" |sed -n 's/^\([0-9]*\)[:].*/\1/p')
            if [ -n "${line}" ]; then
            if [[ ${line} -ne ${n} ]]; then
            sed -i ""${n}"s|"${line}"\:|"${n}"\:|g" "${cfg0}"; fi
            else break; fi
        done
    }
    
    _fix() {
        if [ ${stts} -eq 13 ]; then
            if [ -f "${DC_tlt}/8.cfg_" ] && [ -n $(< "${DC_tlt}/8.cfg_") ]; then
            stts=$(sed -n 1p "${DC_tlt}/8.cfg_")
            rm "${DC_tlt}/8.cfg_"
            else stts=1; fi
            echo ${stts} > "${DC_tlt}/8.cfg"
        fi
        touch "${DC_tlt}/0.cfg" "${DC_tlt}/1.cfg" "${DC_tlt}/2.cfg" \
        "${DC_tlt}/3.cfg" "${DC_tlt}/4.cfg"
    }
    
    _check
    
    if [ ${f} = 1 -o ${a} = 1 ] && [[ ${3} != 1 ]]; then
        > "$DT/ps_lk"; (sleep 1; notify-send -i idiomind "$(gettext "Index Error")" \
        "$(gettext "Fixing...")" -t 3000) & 
    fi
    if [ ${f} = 1 ]; then
        [ ! -d "${DM_tlt}/.conf" ] && mkdir "${DM_tlt}/.conf"
        [ ! -d "${DM_tlt}/images" ] && mkdir "${DM_tlt}/images"
        _restore; _fix; mkmn=1; fi
    if [ ${a} = 1 ]; then
        _restore; _sanity; mkmn=1
    fi
    if [ ${r} = 1 ]; then
        _restore; _sanity
    fi
    if [ ${mkmn} = 1 ] ;then
        "$DS/ifs/tls.sh" colorize
        "$DS/mngr.sh" mkmn
    fi
    if [ -f "$DT/ps_lk" ]; then 
        rm -f "$DT/ps_lk"
    fi
}

add_audio() {
    cd "$HOME"
    aud="$(yad --file --title="$(gettext "Add Audio")" \
    --text=" $(gettext "Browse to and select the audio file that you want to add.")" \
    --class=Idiomind --name=Idiomind \
    --file-filter="*.mp3" \
    --window-icon="$DS/images/icon.png" --center --on-top \
    --width=620 --height=500 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0 |cut -d "|" -f1)"
    ret=$?
    if [ $ret -eq 0 ]; then
    if [ -f "${aud}" ]; then mv -f "${aud}" "${2}/audtm.mp3"; fi
    fi
} >/dev/null 2>&1

_backup() {
    dt=$(date +%F)
    source /usr/share/idiomind/ifs/c.conf
    [ ! -d "$HOME/.idiomind/backup" ] \
    && mkdir "$HOME/.idiomind/backup"
    file="$HOME/.idiomind/backup/${2}.bk"
    if ! grep "${2}.bk" < <(cd "$HOME/.idiomind/backup"/; find . -maxdepth 1 -name '*.bk' -mtime -2); then
        if [ -s "$DM_tl/${2}/.conf/0.cfg" ]; then
            if [ -e "${file}" ]; then
                dt2=`grep '\----- newest' "${file}" |cut -d' ' -f3`
                old="$(sed -n  '/----- newest/,/----- oldest/p' "${file}" \
                |grep -v '\----- newest' |grep -v '\----- oldest')"
            fi
            new="$(cat "$DM_tl/${2}/.conf/0.cfg")"
            echo "----- newest $dt" > "${file}"
            echo "${new}" >> "${file}"
            echo "----- oldest $dt2" >> "${file}"
            echo "${old}" >> "${file}"
            echo "----- end" >> "${file}"
        fi
    fi 
} >/dev/null 2>&1

dlg_backups() {
    cd "$DM/backup"; ls -t *.bk |sed 's/\.bk//g' | \
    yad --list --title="$(gettext "Backups")" \
    --name=Idiomind --class=Idiomind \
    --dclick-action="$DS/ifs/tls.sh '_restfile'" \
    --window-icon="$DS/images/icon.png" --center --on-top \
    --width=520 --height=380 --borders=10 \
    --print-column=1 --no-headers \
    --column=Nombre:TEXT \
    --button=gtk-close:1

} >/dev/null 2>&1

dlg_restfile() {
    file="$HOME/.idiomind/backup/${2}.bk"
    date1=`grep '\----- newest' "${file}" |cut -d' ' -f3`
    date2=`grep '\----- oldest' "${file}" |cut -d' ' -f3`
    [ -n "$date2" ] && val='\nFALSE'
    source "$DS/ifs/mods/cmns.sh"
    if [ -f "${file}" ]; then
        rest="$(echo -e "FALSE\n$date1$val\n$date2" \
        | sed '/^$/d' | yad --list --title="$(gettext "Restore")" \
        --text="${2}" \
        --name=Idiomind --class=Idiomind \
        --print-all --expand-column=2 --no-click \
        --window-icon="$DS/images/icon.png" \
        --image-on-top --on-top --center \
        --width=450 --height=180 --borders=5 \
        --column="$(gettext "Select")":RD \
        --column="$(gettext "Revert to this previous version")":TXT \
        --button="$(gettext "Cancel")":1 \
        --button="$(gettext "OK")":0)"
        ret="$?"
        if [ $ret -eq 0 ]; then
            if [ ! -d "${DM_tl}/${2}" ]; then
                mkdir -p "${DM_tl}/${2}/.conf/practice"; fi
            if grep TRUE <<< "$(sed -n 1p <<<"$rest")"; then
                sed -n  '/----- newest/,/----- oldest/p' "${file}" \
                |grep -v '\----- newest' |grep -v '\----- oldest' > \
                "${DM_tl}/${2}/.conf/0.cfg"
            elif grep TRUE <<< "$(sed -n 2p <<<"$rest")"; then
                sed -n  '/----- oldest/,/----- end/p' "${file}" \
                |grep -v '\----- oldest' |grep -v '\----- end' > \
                "${DM_tl}/${2}/.conf/0.cfg"
            fi
            "$DS/ifs/tls.sh" check_index "${2}" 1
            "$DS/default/tpc.sh" "${2}" 1 &
        fi
    else
        msg "$(gettext "Backup not found")\n" dialog-warning
    fi
}

add_file() {
    cd "$HOME"
    FL=$(yad --file --title="$(gettext "Add File")" \
    --text=" $(gettext "Browse to and select the file that you want to add.")" \
    --name=Idiomind --class=Idiomind \
    --file-filter="*.mp3 *.ogg *.mp4 *.m4v *.jpg *.jpeg *.png *.txt *.pdf *.gif" \
    --add-preview --multiple \
    --window-icon="$DS/images/icon.png" --on-top --center \
    --width=680 --height=500 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0)
    ret=$?
    if [ $ret -eq 0 ]; then
        while read -r file; do
        [ -f "${file}" ] && cp -f "${file}" \
        "${DM_tlt}/files/$(basename "$file" |iconv -c -f utf8 -t ascii)"
        done <<<"$(tr '|' '\n' <<<"$FL")"
    fi
    
} >/dev/null

videourl() {
    source "$DS/ifs/mods/cmns.sh"
    n=$(ls *.url "${DM_tlt}/files/" | wc -l)
    url=$(yad --form --title=" " \
    --name=Idiomind --class=Idiomind \
    --separator="" \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --center --on-top \
    --width=420 --height=100 --borders=5 \
    --field="$(gettext "URL")" \
    --button="$(gettext "Cancel")":1 \
    --button=gtk-ok:0)
    ret=$?
    [ $ret = 1 -o -z "$url" ] && exit
    if [ ${#url} -gt 40 ] && \
        ([ ${url:0:29} = 'https://www.youtube.com/watch' ] \
        || [ ${url:0:28} = 'http://www.youtube.com/watch' ]); then \
        echo "$url" > "${DM_tlt}/files/video$n.url"
    else 
        msg "$(gettext "You have entered an invalid URL").\n" error \
        "$(gettext "You have entered an invalid URL")"
    fi
}

attatchments() {
    source "$DS/ifs/mods/cmns.sh"
    mkindex() {
    rename 's/_/ /g' "${DM_tlt}/files"/*
    echo -e "<meta http-equiv=\"Content-Type\" \
    \rcontent=\"text/html; charset=UTF-8\" />
    \r<link rel=\"stylesheet\" \
    \rhref=\"/usr/share/idiomind/default/attch.css\">\
    \r<body>" > "${DC_tlt}/att.html"

    while read -r file; do
    if grep ".mp3" <<<"${file: -4}"; then
    echo -e "${file::-4}<br><br><audio controls>
    \r<source src=\"../files/$file\" type=\"audio/mpeg\">
    \r</audio><br><br>" >> "${DC_tlt}/att.html"
    elif grep ".ogg" <<<"${file: -4}"; then
    echo -e "${file::-4}<audio controls>
    \r<source src=\"../files/$file\" type=\"audio/mpeg\">
    \r</audio><br><br>" >> "${DC_tlt}/att.html"; fi
    done <<<"$(ls "${DM_tlt}/files")"
    while read -r file; do
    if grep ".txt" <<<"${file: -4}"; then
    txto=$(sed ':a;N;$!ba;s/\n/<br>/g' \
    < "${DM_tlt}/files/$file" \
    | sed 's/\"/\&quot;/;s/\&/&amp;/g')
    echo -e "<div class=\"summary\">
    \r<h2>${file::-4}</h2><br>$txto \
    \r<br><br><br></div>" >> "${DC_tlt}/att.html"; fi
    done <<<"$(ls "${DM_tlt}/files")"
    while read -r file; do
    if grep ".mp4" <<<"${file: -4}"; then
    echo -e "${file::-4}<br><br>
    \r<video width=450 height=280 controls>
    \r<source src=\"../files/$file\" type=\"video/mp4\">
    \r</video><br><br><br>" >> "${DC_tlt}/att.html"
    elif grep ".m4v" <<<"${file: -4}"; then
    echo -e "${file::-4}<br><br>
    \r<video width=450 height=280 controls>
    \r<source src=\"../files/$file\" type=\"video/mp4\">
    \r</video><br><br><br>" >> "${DC_tlt}/att.html"
    elif grep ".jpg" <<<"${file: -4}"; then
    echo -e "${file::-4}<br><br>
    \r<img src=\"../files/$file\" alt=\"$name\" \
    \rstyle=\"width:100%;height:100%\"><br><br><br>" \
    >> "${DC_tlt}/att.html"
    elif grep ".jpeg" <<<"${file: -5}"; then
    echo -e "${file::-5}<br><br>
    \r<img src=\"../files/$file\" alt=\"$name\" \
    \rstyle=\"width:100%;height:100%\"><br><br><br>" \
    >> "${DC_tlt}/att.html"
    elif grep ".png" <<<"${file: -4}"; then
    echo -e "${file::-4}<br><br>
    \r<img src=\"../files/$file\" alt=\"$name\" \
    \rstyle=\"width:100%;height:100%\"><br><br><br>" \
    >> "${DC_tlt}/att.html"
    elif grep ".url" <<<"${file: -4}"; then
    url=$(tr -d '=' < "${DM_tlt}/files/$file" \
    | sed 's|watch?v|v\/|;s|https|http|g')
    echo -e "<iframe width=\"100%\" height=\"85%\" src=\"$url\" \
    \rframeborder=\"0\" allowfullscreen></iframe>
    \r<br><br>" >> "${DC_tlt}/att.html"
    elif grep ".gif" <<<"${file: -4}"; then
    echo -e "${file::-4}<br><br>
    \r<img src=\"../files/$file\" alt=\"$name\" \
    \rstyle=\"width:100%;height:100%\"><br><br><br>" \
    >> "${DC_tlt}/att.html"; fi
    done <<<"$(ls "${DM_tlt}/files")"
    echo -e "</body>" >> "${DC_tlt}/att.html"
    sed -ie 's/^[ \t]*//' "${DC_tlt}/att.html"
    } >/dev/null 2>&1
    [ ! -d "${DM_tlt}/files" ] && mkdir "${DM_tlt}/files"
    ch1="$(ls -A "${DM_tlt}/files")"
    
    if [[ "$(ls -A "${DM_tlt}/files")" ]]; then
        [ ! -f "${DC_tlt}/att.html" ] && mkindex >/dev/null 2>&1
        yad --html --title="$(gettext "Attached Files")" \
        --name=Idiomind --class=Idiomind \
        --encoding=UTF-8 --uri="${DC_tlt}/att.html" --browser \
        --window-icon="$DS/images/icon.png" --center \
        --width=680 --height=580 --borders=10 \
        --button="$(gettext "Open Folder")":"xdg-open \"${DM_tlt}\"/files" \
        --button="$(gettext "Video URL")":2 \
        --button="$(gettext "Add")":0 \
        --button="gtk-close":1
        ret=$?
        
        if [ $ret = 0 ]; then "$DS/ifs/tls.sh" add_file
        elif [ $ret = 2 ]; then "$DS/ifs/tls.sh" videourl; fi
        
        if [[ "$ch1" != "$(ls -A "${DM_tlt}/files")" ]]; then
        mkindex; fi
    else
        yad --form --title="$(gettext "Attached Files")" \
        --text="  $(gettext "Save files related to topic")" \
        --name=Idiomind --class=Idiomind \
        --window-icon="$DS/images/icon.png" --center \
        --width=350 --height=180 --borders=5 \
        --field="$(gettext "Add File")":FBTN "$DS/ifs/tls.sh 'add_file'" \
        --field="$(gettext "YouTube Video URL")":FBTN "$DS/ifs/tls.sh 'videourl'" \
        --button="$(gettext "Cancel")":1 \
        --button="$(gettext "OK")":0
        ret=$?
        if [[ "$ch1" != "$(ls -A "${DM_tlt}/files")" ]] && [ $ret = 0 ]; then
            mkindex
        fi
    fi
} >/dev/null 2>&1

help() {
    URL="http://idiomind.sourceforge.net/doc/help.pdf"
    (xdg-open "$URL") &
     
} >/dev/null 2>&1

fback() {
    source "$DS/ifs/mods/cmns.sh"
    internet
    URL="http://idiomind.sourceforge.net/doc/msg.html"
    yad --html --title="$(gettext "Send Feedback")" \
    --name=Idiomind --class=Idiomind \
    --browser --uri="$URL" \
    --window-icon="$DS/images/icon.png" \
    --no-buttons --fixed \
    --width=500 --height=350
     
} >/dev/null 2>&1

check_updates() {
    source "$DS/ifs/mods/cmns.sh"
    internet
    nver=`wget --user-agent 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:31.0) \
    Gecko/20100101 Firefox/31.0' -qO - http://idiomind.sourceforge.net/doc/release |sed -n 1p`
    cver=`idiomind -v`
    pkg='https://sourceforge.net/projects/idiomind/files/idiomind.deb/download'
    echo "$(date +%d)" > "$DC_s/9.cfg"
    if [ ${#nver} -lt 9 ] && [ ${#cver} -lt 9 ] \
    && [ ${#nver} -ge 3 ] && [ ${#cver} -ge 3 ] \
    && [ "$nver" != "$cver" ]; then
        msg_2 " <b>$(gettext "A new version of Idiomind available\!")</b>\t\n" \
        info "$(gettext "Download")" "$(gettext "Cancel")" "$(gettext "Information")"
        ret=$?
        if [ $ret -eq 0 ]; then xdg-open "$pkg"; fi
    else
        msg " $(gettext "No updates available.")\n" info "$(gettext "Information")"
    fi
    exit 0
}

a_check_updates() {
    source "$DS/ifs/mods/cmns.sh"
    [[ ! -f "$DC_s/9.cfg" ]] && echo `date +%d` > "$DC_s/9.cfg" && exit
    d1=$(< "$DC_s/9.cfg"); d2=$(date +%d)
    if [[ "$(sed -n 1p "$DC_s/9.cfg")" = 28 ]] && \
    [[ "$(wc -l < "$DC_s/9.cfg")" -gt 1 ]]; then
    rm -f "$DC_s/9.cfg"; fi
    [[ "$(wc -l < "$DC_s/9.cfg")" -gt 1 ]] && exit 1

    if [[ "$d1" != "$d2" ]]; then
        sleep 50; curl -v www.google.com 2>&1 | \
        grep -m1 "HTTP/1.1" >/dev/null 2>&1 || exit 1
        echo "$d2" > "$DC_s/9.cfg"
        nver=`wget --user-agent 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:31.0) \
        Gecko/20100101 Firefox/31.0' -qO - http://idiomind.sourceforge.net/doc/release |sed -n 1p`
        cver=`idiomind -v`
        pkg='https://sourceforge.net/projects/idiomind/files/idiomind.deb/download'
        if [ ${#nver} -lt 9 ] && [ ${#cver} -lt 9 ] \
        && [ ${#nver} -ge 3 ] && [ ${#cver} -ge 3 ] \
        && [ "$nver" != "$cver" ]; then
            msg_2 " <b>$(gettext "A new version of Idiomind available\!")\t\n</b> $(gettext "Do you want to download it now?")\n" info "$(gettext "Download")" "$(gettext "Cancel")" "$(gettext "New Version")" "$(gettext "Ignore")"
            ret=$?
            if [ $ret -eq 0 ]; then xdg-open "$pkg"
            elif [ $ret -eq 2 ]; then echo "$d2" >> "$DC_s/9.cfg"; fi
        fi
    fi
    exit 0
}

first_run() {
    dlg() {
        sleep 3; mv -f "${file}" "${file}".p
        yad --title="${title}" --text="${note}" \
        --name=Idiomind --class=Idiomind \
        --image="$image" \
        --always-print-result --selectable-labels \
        --window-icon="$DS/images/icon.png" \
        --image-on-top --on-top --sticky --center \
        --width=500 --height=140 --borders=5 \
        --button="$(gettext "Do not show again")":1 \
        --button="$(gettext "OK")":0
        if [ $? = 1 ]; then rm -f "${file}" "${file}".p; fi
    }
    source /usr/share/idiomind/ifs/c.conf
    NOTE1="$(gettext "<b>How to add notes?</b>\nIn the upper text field, enter text in language that you are learning. In the field below, enter text in the source language. To add an image to a note use the screen clipping.")\n"
    NOTE2="$(gettext "NOTE: If you change the text of an item here listed, then its audio file can be overwritten by another new file. To avoid this, you can edit it individually through its edit dialog.")"
    NOTE3="$(gettext "To start adding notes you need to have a topic.\nCreate one using the button below. ")"

    if [[ ${2} = add ]]; then
        title="$(gettext "How to add notes?")"
        note="${NOTE1}"
        file="$DC_s/add_first_run"
        image=gtk-help
        dlg
    elif [[ ${2} = edit_list ]]; then
        title=" "
        note="${NOTE2}"
        file="$DC_s/elist_first_run"
        image=gtk-help
        dlg
    elif [[ ${2} = topics ]]; then
        "$DS/chng.sh" "$NOTE3"; sleep 1
        source /usr/share/idiomind/ifs/c.conf
        if [ -n "$tpc" ]; then
        rm -f "$DC_s/topics_first_run"
        "$DS/add.sh" new_items & fi
        exit
    elif [[ -z "${2}" ]]; then
        echo "-- done"
        touch "$DC_s/add_first_run" "$DC_s/elist_first_run" \
        "$DC_s/topics_first_run"
        exit
    else 
        exit
    fi
    exit
}

set_image() {
    source "$DS/ifs/mods/cmns.sh"
    cd "$DT"; r=0
    source "$DS/ifs/mods/add/add.sh"
    ifile="${DM_tls}/images/${trgt,,}-0.jpg"
    
    if [ -e "$DT/img$trgt.lk" ]; then
    msg_2 "$(gettext "Attempting download image")...\n" info OK gtk-stop "$(gettext "Warning")"
    if [ $? -eq 1 ]; then "$DT/img$trgt.lk"; else exit 1 ; fi; fi

    if [ -f "$ifile" ]; then
        image="--image=$ifile"
        btn2="--button=gtk-delete:2"
        dlg_form_3
        ret=$?
        if [ $ret -eq 2 ]; then
            rm -f "$ifile"
            ls "${DM_tls}/images/${trgt,,}"-*.jpg | while read -r img; do
            mv -f "$img" "${DM_tls}/images/${trgt,,}"-${r}.jpg
            let r++
            done
        fi
    else 
        scrot -s --quality 90 "$DT/temp.jpg"
        /usr/bin/convert "$DT/temp.jpg" -interlace Plane -thumbnail 405x275^ \
        -gravity center -extent 400x270 -quality 90% "$ifile"
        "$DS/ifs/tls.sh" set_image "${2}" "${trgt}" & exit
    fi
    cleanups "$DT/temp.jpg"
    exit
    
} >/dev/null 2>&1

mkpdf() {
    source "$DS/ifs/mods/cmns.sh"
    cd "$HOME"
    pdf=$(yad --file --save --title="$(gettext "Export to PDF")" \
    --name=Idiomind --class=Idiomind \
    --filename="$HOME/$tpc.pdf" \
    --window-icon="$DS/images/icon.png" --center --on-top \
    --width=600 --height=500 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0)
    ret=$?

    if [ $ret -eq 0 ]; then
        [ -d "$DT/mkhtml" ] && rm -fr "$DT/mkhtml"
        mkdir -p "$DT/mkhtml/images"; wdir="$DT/mkhtml"
        cfg0="${DC_tlt}/0.cfg"
        cfg3="${DC_tlt}/3.cfg"
        cfg4="${DC_tlt}/4.cfg"
        cntwords=`wc -l < "$cfg3"`
        nts="$(sed ':a;N;$!ba;s/\n/<br>/g' < "${DC_tlt}/info" \
        | sed 's/\&/&amp;/g')"
        if [ -f "${DM_tlt}/images/img.jpg" ]; then
        convert "${DM_tlt}/images/img.jpg" \
        -alpha set -channel A -evaluate set 50% "$wdir/img.png"; fi
        while read -r word; do
            if [ -f "${DM_tls}/images/${word,,}-0.jpg" ]; then
                convert "${DM_tls}/images/${word,,}-0.jpg" -alpha set -virtual-pixel transparent \
                -channel A -blur 0x10 -level 70%,100% +channel "$wdir/images/$word.png"
                echo "${word}" >> "$wdir/image_list"
            fi
        done < <(tac "${cfg3}")
        while read -r sntcs; do
            item="$(grep -F -m 1 "trgt={${sntcs}}" "${cfg0}" |sed 's/},/}\n/g')"
            trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
            srce="$(grep -oP '(?<=srce={).*(?=})' <<<"${item}")"
            if [ -n "${trgt}" -a -n "${srce}" ]; then
                echo "${trgt}" >> "$wdir/trgt_sentences"
                echo "${srce}" >> "$wdir/srce_sentences"
            fi
        done < <(tac "${cfg4}")
        
        echo -e "<head>
        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
        <title>$tpc</title><head>
        <link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/pdf.css\">
        </head><body><div><p></p></div><div>" >> "$wdir/temp.html"
        
        if [ -f "$wdir/img.png" ]; then
            echo -e "<table width=\"100%\" border=\"0\"><tr>
            <td><img src=\"$wdir/img.png\" alt="" border=0 height=100% width=100%></img>
            </td>
            </tr>
            </table>" >> "$wdir/temp.html"; fi
        echo -e "<p>&nbsp;</p>
        <h3>$tpc</h3>
        <hr>
        <div width=\"80%\" align=\"left\" border=\"0\" class=\"ifont\">
        <br>" >> "$wdir/temp.html"
        printf "$nts" >> "$wdir/temp.html"
        echo -e "<p>&nbsp;</p>
        <div>" >> "$wdir/temp.html"

        cnt=`wc -l < "$wdir/image_list"`
        if [[ ${cnt} -gt 0 ]]; then

            cd "$wdir"
            echo -e "<p>&nbsp;</p><table width=\"100%\" align=\"center\" border=\"0\" class=\"images\">" >> "$wdir/temp.html"
            n=1
            while [[ ${n} -lt $(($(wc -l < "$wdir/image_list")+1)) ]]; do
                    label1=$(sed -n ${n},$((n+1))p "$wdir/image_list" |sed -n 1p)
                    label2=$(sed -n ${n},$((n+1))p "$wdir/image_list" |sed -n 2p)
                    if [ -n "${label1}" ]; then
                        echo -e "<tr>
                        <td align=\"center\"><img src=\"images/$label1.png\" width=\"200\" height=\"140\"></td>" >> "$wdir/temp.html"
                        if [ -n "${label2}" ]; then
                            echo -e "<td align=\"center\"><img src=\"images/$label2.png\" width=\"200\" height=\"140\"></td></tr>" >> "$wdir/temp.html"
                        else
                            echo '</tr>' >> "$wdir/temp.html"
                        fi
                        echo -e "<tr>
                        <td align=\"center\" valign=\"top\"><p>${label1}</p>
                        <p>&nbsp;</p>
                        <p>&nbsp;</p>
                        <p>&nbsp;</p></td>" >> "$wdir/temp.html"
                        if [ -n "${label2}" ]; then
                            echo -e "<td align=\"center\" valign=\"top\"><p>${label2}</p>
                            <p>&nbsp;</p>
                            <p>&nbsp;</p>
                            <p>&nbsp;</p></td>
                            </tr>" >> "$wdir/temp.html"
                        else
                        echo '</tr>' >> "$wdir/temp.html"
                        fi
                    else
                        break
                    fi

                ((n=n+2))
            done
            echo -e "</table>" >> "$wdir/temp.html"
        fi
        cd "$wdir"
        while read -r word; do
            item="$(grep -F -m 1 "trgt={${word}}" "${cfg0}" |sed 's/},/}\n/g')"
            trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
            srce="$(grep -oP '(?<=srce={).*(?=})' <<<"${item}")"
            exmp="$(grep -oP '(?<=exmp={).*(?=})' <<<"${item}")"
            defn="$(grep -oP '(?<=defn={).*(?=})' <<<"${item}")"
            ntes="$(grep -oP '(?<=note={).*(?=})' <<<"${item}")"
            fname="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${item}")"
            hlgt="${trgt,,}"
            exmp1=$(echo "${exmp}" |sed "s/"$hlgt"/<b>"$hlgt"<\/\b>/g")
            
            if [ -n "${trgt}" -a -n "${srce}" ]; then
                echo -e "<table width=\"55%\" border=\"0\" align=\"left\" cellpadding=\"6\" cellspacing=\"0\">
                <tr>
                <td bgcolor=\"#E6E6E6\" class=\"side\"></td>
                <td bgcolor=\"#FFFFFF\"><w1>${trgt}</w1></td>
                </tr><tr>
                <td bgcolor=\"#FFFFFF\" class=\"side\"></td>
                <td bgcolor=\"#FFFFFF\"><w2>${srce}</w2></td>
                </tr>
                </table>" >> "$wdir/temp.html"
                echo -e "<table width=\"100%\" border=\"0\" align=\"center\" cellpadding=\"10\" class=\"efont\">
                <tr>
                <td width=\"10px\"></td>" >> "$wdir/temp.html"
                if [ -z "${dftn}" -a -z "${exmp1}" ]; then
                    echo -e "<td width=\"466\" valign=\"top\" class=\"nfont\" >${ntes}</td>
                    <td width=\"389\"</td>
                    </tr>
                    </table>" >> "$wdir/temp.html"
                else
                    echo -e "<td width=\"466\">" >> "$wdir/temp.html"
                    if [ -n "${dftn}" ]; then
                        echo -e "<dl>
                        <dd><dfn>${dftn}</dfn></dd>
                        </dl>" >> "$wdir/temp.html"
                    fi
                    if [ -n "${exmp1}" ]; then
                        echo -e "<dl>
                        <dt> </dt>
                        <dd><cite>${exmp1}</cite></dd>
                        </dl>" >> "$wdir/temp.html"
                    fi 
                    echo -e "</td>
                    <td width=\"400\" valign=\"top\" class=\"nfont\">${ntes}</td>
                    </tr>
                    </table>" >> "$wdir/temp.html"
                fi
            fi
        done < <(tac "${cfg3}")
        [ ${cntwords} -gt 0 ] && echo -e "<br><br><br><br>" >> "$wdir/temp.html"

        n=1; trgt=""
        while [[ ${n} -le "$(wc -l < "${cfg4}")" ]]; do
            trgt=$(sed -n ${n}p "$wdir/trgt_sentences")
            while read -r mrk; do
                if grep -Fxo ${mrk^} < "${cfg3}"; then
                trgsm=$(sed "s|$mrk|<mark>$mrk<\/mark>|g" <<<"$trgt")
                trgt="$trgsm"; fi
            done <<<"$(tr ' ' '\n' <<<"${trgt}")"

            if [ -n "${trgt}" ]; then
                srce=$(sed -n ${n}p "$wdir/srce_sentences")
                echo -e "&nbsp;
                <table width=\"90%\" border=\"0\" align=\"left\">
                <tr>
                <td bgcolor=\"#FFFFFF\"><strgt>${trgt}</strgt1></td>
                </tr><tr>
                <td bgcolor=\"#FFFFFF\"><ssrce>${srce}<br><br></ssrce></td>
                </tr>
                </table>" >> "$wdir/temp.html"
            fi
            let n++
        done
        echo -e "</div></div>
        </body></html>" >> "$wdir/temp.html"
        wkhtmltopdf -s A4 -O Portrait "$wdir/temp.html" "$wdir/tmp.pdf"
        mv -f "$wdir/tmp.pdf" "${pdf}"
        rm -fr "$wdir"
    fi
    exit
}

translate_to() {
    # usage: 
    # idiomind translate [language] / e.g. language: en.
    # idiomind translate restore / for restore original language.
    source /usr/share/idiomind/ifs/c.conf
    source "$DS/ifs/mods/cmns.sh"
    [ ! -e "${DC_tlt}/id.cfg" ] && echo -e "  -- error" && exit 1
    l="$(grep -o 'langt="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
    lgt=$(lnglss $l)
    if [ -z "$lgt" ]; then
        lgt=$(lnglss $l)
    fi
    if [ $2 = restore ]; then
        if [ -e "${DC_tlt}/0.data" ]; then
            mv -f "${DC_tlt}/0.data" "${DC_tlt}/0.cfg"
            echo -e "  done!"; else echo -e "  -- error"; fi
    else
        if [ -e "${DC_tlt}/$2.data" ]; then
            cp -f "${DC_tlt}/$2.data" "${DC_tlt}/0.cfg"
            echo -e "  done!"
        else
            include "$DS/ifs/mods/add"
            echo -e "\n\n  --translating \"$tpc\"...\n"
            cnt=`wc -l "${DC_tlt}/0.cfg"`
            > "$DT/words.trad_tmp"
            > "$DT/index.trad_tmp"
            
            while read -r item_; do
                item="$(sed 's/},/}\n/g' <<<"${item_}")"
                type="$(grep -oP '(?<=type={).*(?=})' <<<"${item}")"
                trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
                pos="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"

                if [ -n "${trgt}" ]; then
                    echo "${trgt}" \
                    | python -c 'import sys; print(" ".join(sorted(set(sys.stdin.read().split()))))' \
                    | sed 's/ /\n/g' | grep -v '^.$' | grep -v '^..$' \
                    | tr -d '*)(,;"“”:' | tr -s '&{}[]' ' ' \
                    | sed 's/,//;s/\?//;s/\¿//;s/;//g;s/\!//;s/\¡//g' \
                    | sed 's/\]//;s/\[//;s/<[^>]*>//g' \
                    | sed 's/\.//;s/  / /;s/ /\. /;s/ -//;s/- //;s/"//g' \
                    | tr -d '.' | sed 's/^ *//; s/ *$//; /^$/d' >> "$DT/words.trad_tmp"
                    echo "|" >> "$DT/words.trad_tmp"
                    echo "${trgt} |" >> "$DT/index.trad_tmp"; fi
            done < "${DC_tlt}/0.cfg"

            sed -i ':a;N;$!ba;s/\n/\. /g' "$DT/words.trad_tmp"
            sed -i 's/|/|\n/g' "$DT/words.trad_tmp"
            sed -i 's/^..//' "$DT/words.trad_tmp"
            index_to_trad="$(< "$DT/index.trad_tmp")"
            words_to_trad="$(< "$DT/words.trad_tmp")"
            translate "${index_to_trad}" $lgt $2 > "$DT/index.trad"
            translate "${words_to_trad}" $lgt $2 > "$DT/words.trad"
            sed -i ':a;N;$!ba;s/\n/ /g' "$DT/index.trad"
            sed -i 's/|/\n/g' "$DT/index.trad"
            sed -i 's/^ *//; s/ *$//g' "$DT/index.trad"
            sed -i ':a;N;$!ba;s/\n/ /g' "$DT/words.trad"
            sed -i 's/|/\n/g' "$DT/words.trad"
            sed -i 's/^ *//; s/ *$//;s/\。/\. /g' "$DT/words.trad"
            paste -d '&' "$DT/words.trad_tmp" "$DT/words.trad" > "$DT/mix_words.trad_tmp"
            
            n=1
            while read -r item_; do
                item="$(sed 's/},/}\n/g' <<<"${item_}")"
                type="$(grep -oP '(?<=type={).*(?=})' <<<"${item}")"
                trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
                grmr="$(grep -oP '(?<=grmr={).*(?=})' <<<"${item}")"
                exmp="$(grep -oP '(?<=exmp={).*(?=})' <<<"${item}")"
                defn="$(grep -oP '(?<=defn={).*(?=})' <<<"${item}")"
                id="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${item}")"
                srce="$(sed -n ${n}p "$DT/index.trad")"
                tt="$(sed -n ${n}p "$DT/mix_words.trad_tmp" |cut -d '&' -f1 \
                |sed 's/\. /\n/g' |sed 's/^ *//; s/ *$//g' | tr -d '|.')"
                st="$(sed -n ${n}p "$DT/mix_words.trad_tmp" |cut -d '&' -f2 \
                |sed 's/\. /\n/g' |sed 's/^ *//; s/ *$//g' | tr -d '|.')"

                ( bcle=1
                > "$DT/w.tmp"
                while [[ ${bcle} -le `wc -l <<<"$tt"` ]]; do
                    t="$(sed -n ${bcle}p <<<"$tt" |sed 's/^\s*./\U&\E/g')"
                    s="$(sed -n ${bcle}p <<<"$st" |sed 's/^\s*./\U&\E/g')"
                    echo "${t}_${s}" >> "$DT/w.tmp"
                    let bcle++
                done )
                wrds="$(tr '\n' '_' < "$DT/w.tmp" |sed '/^$/d')"
                
                t_item="${n}:[type={$type},trgt={$trgt},srce={$srce},exmp={$exmp},defn={$defn},note={},wrds={$wrds},grmr={$grmr},].[tag={},mark={},].id=[$id]"
                echo -e "${t_item}" >> "${DC_tlt}/$2.data"
            let n++
            done < "${DC_tlt}/0.cfg"
            
            rm -f "$DT"/*.tmp "$DT"/*.trad "$DT"/*.trad_tmp
            if [ ! -e "${DC_tlt}/0.data" ]; then
                mv "${DC_tlt}/0.cfg" "${DC_tlt}/0.data"; fi
            cp -f "${DC_tlt}/$2.data" "${DC_tlt}/0.cfg"
            echo -e "  done!"
        fi
    fi
}

menu_addons() {
    > /usr/share/idiomind/addons/menu_list
    while read -r _set; do
        if [ -e "/usr/share/idiomind/addons/${_set}/icon.png" ]; then
            echo -e "/usr/share/idiomind/addons/${_set}/icon.png\n${_set}" >> \
            /usr/share/idiomind/addons/menu_list
        else echo -e "/usr/share/idiomind/images/thumb.png\n${_set}" >> \
            /usr/share/idiomind/addons/menu_list; fi
    done < <(cd "/usr/share/idiomind/addons/"; set -- */; printf "%s\n" "${@%/}")
}

colorize() {
    f_lock "$DT/co_lk"
    rm "${DC_tlt}/5.cfg"
    [ ! -e "${DC_tlt}/1.cfg" ] && touch "${DC_tlt}/1.cfg"
    [ ! -e "${DC_tlt}/6.cfg" ] && touch "${DC_tlt}/6.cfg"
    [ ! -e "${DC_tlt}/9.cfg" ] && touch "${DC_tlt}/9.cfg"
    if [[ `egrep -cv '#|^$' < "${DC_tlt}/9.cfg"` -ge 4 ]]; then
    chk=TRUE; else chk=FALSE; fi
    img1='/usr/share/idiomind/images/1.png'
    img2='/usr/share/idiomind/images/2.png'
    img3='/usr/share/idiomind/images/3.png'
    img0='/usr/share/idiomind/images/0.png'
    cfg1="${DC_tlt}/1.cfg"
    cfg5="${DC_tlt}/5.cfg"
    cfg6="${DC_tlt}/6.cfg"
    cd "${DC_tlt}/practice"
    log3="$(cat ./log3)"
    log2="$(cat ./log2)"
    log1="$(cat ./log1)"
    export chk cfg1 cfg5 cfg6 log1 \
    log2 log3 img0 img1 img2 img3
    cd / 

python <<PY
import os
chk = os.environ['chk']
cfg1 = os.environ['cfg1']
cfg5 = os.environ['cfg5']
cfg6 = os.environ['cfg6']
log1 = os.environ['log1']
log2 = os.environ['log2']
log3 = os.environ['log3']
img0 = os.environ['img0']
img1 = os.environ['img1']
img2 = os.environ['img2']
img3 = os.environ['img3']
items = [line.strip() for line in open(cfg1)]
marks = [line.strip() for line in open(cfg6)]
f = open(cfg5, "w")
n = 0
while n < len(items):
    item = items[n]
    if item in marks:
        i="<b><big>"+item+"</big></b>"
    else:
        i=item
    if item in log3:
        f.write("FALSE\n"+i+"\n"+img3+"\n")
    elif item in log2:
        f.write("FALSE\n"+i+"\n"+img2+"\n")
    elif item in log1:
        f.write(chk+"\n"+i+"\n"+img1+"\n")
    else:
        f.write("FALSE\n"+i+"\n"+img0+"\n")
    n += 1
f.close()
PY
    rm -f "$DT/co_lk"
}

about() {
c="$(gettext "Vocabulary learning tool")"
website="$(gettext "Web Site")"
export c website
python << ABOUT
import gtk
import os
app_logo = os.path.join('/usr/share/idiomind/images/idiomind.png')
app_icon = os.path.join('/usr/share/idiomind/images/icon.png')
app_name = 'Idiomind'
app_version = 'v0.1-beta'
app_comments = os.environ['c']
web = os.environ['website']
app_copyright = 'Copyright (c) 2015 Robin Palatnik'
app_website = 'http://idiomind.sourceforge.net'
app_license = (('Idiomind is free software: you can redistribute it and/or modify\n'+
'it under the terms of the GNU General Public License as published by\n'+
'the Free Software Foundation, either version 3 of the License, or\n'+
'(at your option) any later version.\n'+
'\n'+
'This program is distributed in the hope that it will be useful,\n'+
'but WITHOUT ANY WARRANTY; without even the implied warranty of\n'+
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n'+
'GNU General Public License for more details.\n'+
'\n'+
'You should have received a copy of the GNU General Public License\n'+
'along with this program.  If not, see http://www.gnu.org/licenses'))
app_authors = ['Robin Palatnik <patapatass@hotmail.com>']
app_artists = ["Logo based on rg1024's openclipart Ufo Cartoon."]

class AboutDialog:
    def __init__(self):
        about = gtk.AboutDialog()
        about.set_logo(gtk.gdk.pixbuf_new_from_file(app_logo))
        about.set_icon_from_file(app_icon)
        about.set_wmclass('Idiomind', 'Idiomind')
        about.set_name(app_name)
        about.set_program_name(app_name)
        about.set_version(app_version)
        about.set_comments(app_comments)
        about.set_copyright(app_copyright)
        about.set_license(app_license)
        about.set_authors(app_authors)
        about.set_artists(app_artists)
        about.set_website(app_website)
        about.set_website_label(web)
        about.run()
        about.destroy()

if __name__ == "__main__":
    AboutDialog = AboutDialog()
    main()
ABOUT
} >/dev/null 2>&1

gtext() {
$(gettext "Marked items")
$(gettext "Difficult words")
$(gettext "Does not need configuration")
}>/dev/null 2>&1

case "$1" in
    backup)
    _backup "$@" ;;
    dlg_backups)
    dlg_backups "$@" ;;
    _restfile)
    dlg_restfile "$@" ;;
    check_index)
    check_index "$@" ;;
    add_audio)
    add_audio "$@" ;;
    attachs)
    attatchments "$@" ;;
    add_file)
    add_file ;;
    videourl)
    videourl "$@" ;;
    help)
    help ;;
    check_updates)
    check_updates ;;
    a_check_updates)
    a_check_updates ;;
    set_image)
    set_image "$@" ;;
    first_run)
    first_run "$@" ;;
    fback)
    fback ;;
    pdf)
    mkpdf ;;
    update_menu)
    menu_addons ;;
    colorize)
    colorize "$@" ;;
    translate)
    translate_to "$@" ;;
    about)
    about ;;
esac
