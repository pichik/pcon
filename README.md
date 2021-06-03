# pcon - param converter
pcon is a tool for converting list of parameters to different MIME types.

Currently supported MIME types:  
`json`      application/json  
`xml`       application/xml  
`form-data` multipart/form-data  
`query`     application/x-www-form-urlencoded  


### Flags

`-t` MIME type  
`-s` add value to all params  
`-u` append unique values  
`-a` additional string (works only with xml or form-data)  
    xml - root element (default is `root`)  
    form-data - boundary (default is `-------boundary`)  


# Usage
`cat wordlist.txt | pcon -t json -u -s value123`

### Example

Input:  
`echo 'param1 param2' | pcon -t xml -s value -a ListOfParams -u`

Output:  
```
<?xml version="1.0" encoding="UTF-8"?>
<ListOfParams>
<param1>value1</param1>
<param2><value2</param2>
</ListOfParams>
```
