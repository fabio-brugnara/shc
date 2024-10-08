#!/bin/bash

shells=('/bin/sh' '/bin/dash' '/bin/bash' '/bin/ash' '/bin/ksh' '/bin/zsh' '/usr/bin/tcsh' '/bin/csh' '/usr/bin/rc' '/usr/bin/python' '/usr/bin/python2' '/usr/bin/python3')
## Install: sudo apt install dash bash ash ksh zsh tcsh csh rc

check_opts=('' '-r' '-v' '-D' '-S' '-P')

shc=${1-shc}

txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtrst='\e[0m'    # Text Reset

stat=0
pc=0
fc=0
echo
echo "== Running tests ..."
for shell in ${shells[@]}; do
    [ -x "$shell" ] || continue
    for opt in "${check_opts[@]}"; do
        tmpd=$(mktemp -d)
        tmpf="$tmpd/test.$(basename $shell)"
        echo '#!'"$shell" >"$tmpf"
	if [ ${shell#*pyth} = "$shell" ]; then
		echo "echo 'Hello World fp:'\$1 sp:\$2"
	else
		echo 'import sys'
		echo 'sys.stdout.write(("Hello World fp:%s sp:%s" % (sys.argv[1],sys.argv[2]))+"\n")'
	fi >> "$tmpf"
        "$shc" $opt -f "$tmpf" -o "$tmpd/a.out"
        out=$("$tmpd/a.out" first second)
        #~ echo "  Output: $out"
        if [[ "$out" = 'Hello World fp:first sp:second' ]]; then
            echo    "===================================================="
            echo -e "=== $shell [with shc $opt]: ${txtgrn}PASSED${txtrst}"
            echo    "===================================================="
            ((pc++))
        else
            echo    "===================================================="
            echo -e "=== $shell [with shc $opt]: ${txtred}FAILED${txtrst}"
            echo    "===================================================="
            stat=1
            ((fc++))
        fi
        rm -r "$tmpd"
    done
done

echo
echo "Test Summary"
echo "------------"

if ((pc>0)); then
    pt="${txtgrn}PASSED${txtrst}"
else
    pt="PASSED"
fi

if ((fc>0)); then
    ft="${txtred}FAILED${txtrst}"
else
    ft="FAILED"
fi

echo -e "$pt: $pc"
echo -e "$ft: $fc"
echo "------------"
echo

exit $stat
