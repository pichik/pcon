#!/bin/bash

#
# Name: Param Converter
# Author: Pichik
#

unique=false
input="$(</dev/stdin)"

### Description
print_usage() {
cat << EOF
DESCRIPTION:
   pcon - param converter
   pcon is a tool for converting list of parameters to different MIME types.

CURRENTLY SUPPORTED MIME TYPES:
   json		application/json
   xml 		application/xml
   form-data 	multipart/form-data
   query 	application/x-www-form-urlencoded or query string
   jq		convert json to query
   qj		convert query to json

FLAGS:
  -t type (see supported mime types)
  -s add value to all params
  -m mirroring variable names to values
  -u append unique values
  -a additional string (works only with xml or form-data)
     xml - root element (default is <root>)
     form-data - boundary (default is -------boundary)
  -h show usage

USAGE:
   cat wordlist.txt | pcon -t json -u -s value123
   cat params.txt | pcon -t query -u
   cat params.json | pcon -t jq

EXAMPLE:
 Input:
   echo 'param1 param2' | pcon -t xml -s value -m -a ListOfParams -u
 Output:
   <?xml version="1.0" encoding="UTF-8"?>
   <ListOfParams>
   <param1>param1value1</param1>
   <param2>param2value2</param2>
   </ListOfParams>
EOF
}
###

# Setup flags
while getopts 't:s:a:muh' flag; do
  	case "${flag}" in
    		t) type="${OPTARG}" ;;
    		s) string="${OPTARG}" ;;
		a) addition="${OPTARG}" ;;
		m) mirror=true ;;
		u) unique=true ;;
    		h) print_usage
       		exit 1 ;;
  	esac
done

# Add unique word to string for later recognition
if [ $unique == true ]; then
	string="${string}unique1337"
fi

# Switch between MIME types
case $type in
	json)
	echo "{"
	echo $input | sed 's/\s/\n/g' | sed -e 's/^/"/' -e 's/$/":/' | ( [ $mirror ] && sed 's/\(^[^:]*\)\(.*\)/\1\2\1/' || sed 's/$/""/' ) | sed  -e "s/\"$/${string}\"/" -e '$!s/$/,/' | awk '{gsub("unique1337",NR,$0);print}'
	echo "}"
	;;
	qj)
	echo -e -n "{\n\""
	echo -n $input | sed 's/\&/\",\n\"/g' | sed 's/\=/\":\"/g'
	echo -e "\"\n}\n"
	;;
	xml)
	if [ -z $addition ]; then
		addition="root"
	fi
	echo "<?xml version="1.0" encoding="UTF-8"?>"
	echo "<$addition>"
	echo $input | sed 's/\s/\n/g' | sed 's/$/=/' | sed "s/$/${string}/" | ( [ $mirror ] && sed 's/\(^[^=]*\)\(=\)\(.*\)/<\1>\1\3<\/\1>/' || sed 's/\(^[^=]*\)\(=\)\(.*\)/<\1>\3<\/\1>/' ) | awk '{gsub("unique1337",NR,$0);print}'
	echo "</$addition>"
	;;
	form-data)
	if [ -z $addition ]; then
		addition="-------boundary"
	fi
	echo $input | sed 's/\s/\n/g' | sed 's/$/=/'  | sed "s/$/${string}/" | ( [ $mirror ] && sed 's/\(^[^=]*\)\(=\)\(.*\)/Content-Disposition: form-data; name="\1"\n\n\1\3/' || sed 's/\(^[^=]*\)\(=\)\(.*\)/Content-Disposition: form-data; name="\1"\n\n\3/' ) | sed -e "s/Content-Disposition/$addition\nContent-Disposition/"  | awk '{gsub("unique1337",NR,$0);print}'
	echo "$addition--"
	;;
	query)
	echo $input | sed 's/\s/\n/g' | sed "s/$/=/g" | ( [ $mirror ] && sed 's/\(^[^=]*\)\(.*\)/\1\2\1/' || cat ) | sed -e "s/$/${string}/g" | awk '{gsub("unique1337",NR,$0);print}' | sed ':a;N;$!ba;s/\n/\&/g' | sed 's/\[/%5b/g' | sed 's/\]/%5d/g'
	;;
	jq)
	echo $input | sed 's/\"//g' | sed 's/:/=/g' | sed -E 's/, ?/\&/g' | sed 's/{//g' | sed 's/}//g'
	;;
	"")
	echo "Requires MIME type -t (see -h for more info)"
	;;
	*)
	echo "Supported MIME types:json xml form-data query"
	;;
esac
