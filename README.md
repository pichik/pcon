# pcon - param converter

## Description
pcon is a tool for converting list of parameters to different MIME types.  
&nbsp;&nbsp;  
### Currently supported MIME types:  
`json`      application/json  
`xml`       application/xml  
`form-data` multipart/form-data  
`query`     application/x-www-form-urlencoded or query string   

### Flags

`-t` MIME type  
`-s` add value to all params  
`-u` append unique values  
`-a` additional string (works only with xml or form-data)  
    xml - root element (default is `root`)  
    form-data - boundary (default is `-------boundary`)  
`-h` show usage

## Installation

1. `wget https://raw.githubusercontent.com/pichik/pcon/main/pcon.sh`
2. `chmod +x pcon.sh`
3. `mv pcon.sh /usr/local/bin/pcon`

## Usage

`cat wordlist.txt | pcon -t query -u -s value123`  
`echo "isAdmin isSubscribed" | pcon -t json -s true`

### Example

Input:  
`echo 'param1 param2' | pcon -t xml -s value -a ListOfParams -u`

Output:  
```
<?xml version="1.0" encoding="UTF-8"?>
<ListOfParams>
<param1>value1</param1>
<param2>value2</param2>
</ListOfParams>
```
