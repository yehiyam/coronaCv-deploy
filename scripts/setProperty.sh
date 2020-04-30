#!/bin/bash

############################
#script function
############################
setProperty(){
    filename="$3"
    thekey="$1"
    newvalue="$2"
    
    if ! grep -R "^[#]*\s*${thekey}=.*" $filename > /dev/null; then
        echo "APPENDING because '${thekey}' not found"
        echo "$thekey=$newvalue" >> $filename
    else
        echo "SETTING because '${thekey}' found already"
        sed -i "s/^[#]*\s*${thekey}=.*/$thekey=$newvalue/" $filename
    fi
}
############################
### usage: setProperty $key $value $filename
setProperty $1 $2 $3