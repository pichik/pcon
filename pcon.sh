#!/bin/bash

#
# Name: Param Converter
# Author: Pichik
#

type=''
string=''
unique=false
addition=''
input="$(</dev/stdin)"

### Description
print_usage() {
cat << EOF
pcon - param converter
DESCRIPTION:
pcon is a tool for converting list of parameters to different MIME types.

CURRENTLY SUPPORTED MIME TYPES:
   json		application/json
   xml 		application/xml
   form-data 	multipart/form-data
   query 	application/x-www-form-urlencoded or query string

FLAGS:
  -t type (see supported mime types)
  -s add value to all params
  -u append unique values
  -a additional string (works only with xml or form-data)
     xml - root element (default is <root>)
     form-data - boundary (default is -------boundary)
  -h show usage

USAGE:
   cat wordlist.txt | pcon -t json -u -s value123
   cat params.txt | pcon -t query -u

EXAMPLE:
 Input:
   echo 'param1 param2' | pcon -t xml -s value -a ListOfParams -u
 Output:
   <?xml version="1.0" encoding="UTF-8"?>
   <ListOfParams>
   <param1>value1</param1>
   <param2><value2</param2>
   </ListOfParams>
EOF
}
###

while getopts 't:s:a:uh' flag; do
  	case "${flag}" in
    		t) type="${OPTARG}" ;;
    		s) string="${OPTARG}" ;;
		a) addition="${OPTARG}" ;;
		u) unique=true ;;
    		h) print_usage
       		exit 1 ;;
  	esac
done

if [ $unique == true ]; then
	string="${string}unique1337"
fi

if [ -z $type ]; then
	echo "Requires MIME type -t (see -h for more info)"
fi

case $type in
	json)
	echo "{"
	echo $input | sed 's/\s/\n/g' | sed -e 's/^/"/' -e "s/$/\":\"${string}\"/" -e '$!s/$/,/' | awk '{gsub("unique1337",NR,$0);print}'
	echo "}"
	;;
	xml)
	if [ -z $addition ]; then
		addition="root"
	fi
	echo "<?xml version="1.0" encoding="UTF-8"?>"
	echo "<$addition>"
	echo $input | sed 's/\s/\n/g' | sed 's/$/>/' | sed "s/.*/<&${string}<\/&/" | awk '{gsub("unique1337",NR,$0);print}'
	echo "</$addition>"
	;;
	multipart)
	if [ -z $addition ]; then
		addition="-------boundary"
	fi
	echo $input | sed 's/\s/\n/g' | sed -e 's/^/Content-Disposition: form-data; name="/' -e 's/$/"/' | sed -e "s/^/$addition\n/" -e "s/$/\n\n$string/" | awk '{gsub("unique1337",NR,$0);print}'
	echo "$addition--"
	;;
	query)
	echo $input | sed 's/\s/\n/g' | sed -e "s/$/=${string}/g" | awk '{gsub("unique1337",NR,$0);print}' | sed ':a;N;$!ba;s/\n/\&/g'
	;;
esac
