#!/bin/ksh

# Author - jake kirsch
# Usage: see usage() function, below

usage(){
       print "$0 - a custom file watcher script"
       print "Usage: $0 [-d] watch_directory [-f] watch_file [-i] watch_interval [-r] recursive"
       print "   -d  watch_directory [REQUIRED!]"
       print "   -f  watch_file [REQUIRED!]"
       print "   -i  watch_interval [REQUIRED!]"
       print "   -r  recursive [to be completed at a later date]"
}

rec=0

while [ $# -gt 0 ]
do
  case "$1" in
     -d) watch_dir="$2"; shift;;
     -f) watch_file="$2"; shift;;
     -i) watch_int="$2"; shift;;
     -r) rec=1;;
     -*)    usage
            exit 1;;
     *)     break;;
  esac
  shift
done

if [[ ${watch_dir:-notset} == "notset" || ${watch_file:-notset} == "notset" || ${watch_int:-notset} == "notset" ]]; then
   usage
   exit 1
fi

found=0
set -A previous_files
set -A previous_sizes
typeset -i num_of_prev_files=0

#set internal field separator to carriage return to account for spaces
IFS=$'
'

while [ ${found} -eq 0 ]
do

typeset -i index=0
set -A current_files
set -A current_sizes

for file_name in $(ls ${watch_dir} | grep ${watch_file});do
    if [[ -f ${watch_dir}/${file_name} ]]; then
       current_files[index]=${file_name}

       file_size=$(ls -lrt ${watch_dir}/${file_name} | awk '{ print $5}')
       current_sizes[index]=${file_size}

       typeset -i j=0
       while [ $j -lt $num_of_prev_files ]
       do
          #check here if file names/sizes are equivalent
          if [[ ${file_name} == ${previous_files[$j]} && ${file_size} -eq ${previous_sizes[$j]} ]]; then
             found=1
             print "Happy Watchdog, file found!"
          fi
          j=$((j + 1))
       done

       index=$((index + 1))
    fi
done

set -A previous_files -- "${current_files[@]}"
set -A previous_sizes -- "${current_sizes[@]}"
num_of_prev_files=${index}

if [[ ${found} -eq 0 ]]; then
   sleep ${watch_int}
fi

done

print "Exiting script!"
