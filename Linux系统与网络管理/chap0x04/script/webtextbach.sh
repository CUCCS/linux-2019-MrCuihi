#!/bin/bash
#Web_log text batch processing
#MrCuihi

function usage()
{
echo " IMproved 1.0 (2019 April 2)"

echo " usage: bash wteb [Arguments]"
echo " Arguments: "
echo " -th        Statistical access source host TOP 100 and the corresponding total number of occurrences"
echo " -ti        Statistics access source host TOP 100 IP and total number of corresponding occurrences respectively"
echo " -tu        Statistical most frequently visited URL TOP 100"
echo " -sp        Count the number of occurrences and corresponding percentages of different response status codes"
echo " -su        Count the TOP 10 URLs corresponding to different 4XX status codes and the total number of corresponding occurrences"
echo " -gu <url>  Given URL output TOP 100 access source host"
echo " -h         Output help information"

}
function Statistic()
{

 if [ "$1" != "" ];then
  if [ "$#" -le 2 ];then
     #Statistical access source host TOP 100 and the corresponding total number of occurrences
     if [ "$1" == "-th" ];then
         sed -e '1d' web_log.tsv|awk -F '\t' '{a[$1]++} END {for(i in a) {print i,a[i]}}'|sort -nr -k2|head -n 100
         
     #Statistics access source host TOP 100 IP and total number of corresponding occurrences respectively
     elif [ "$1" == "-ti" ];then
        sed -e '1d' web_log.tsv | awk -F '\t' '{a[$1]++} END {for(i in a){print i,a[i] }}' | awk '{ if($1~/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]/){print} }' | sort -nr -k2 | head -n 100
        
     #Statistical most frequently visited URL TOP 100
     elif [ "$1" == "-tu" ];then
        sed -e '1d' web_log.tsv | awk -F '\t' '{a[$5]++} END {for(i in a){print i,a[i] }}' | sort -nr -k2 | head -n 100
        
     #Count the number of occurrences and corresponding percentages of different response status codes
     elif [ "$1" == "-sp" ];then
        sed -e '1d' web_log.tsv | awk -F '\t' '{a[$6]++} END {for(i in a){print i,a[i] }}' |  sort -nr -k2 | head -n 100
        sed -e '1d' web_log.tsv | awk -F '\t' '{a[$6]++} END {for(i in a){print i,a[i] }}' |  sort -nr -k2 | awk '{arr[$1]=$2;sums+=$2} END {for (k in arr) print k,arr[k]/sums*100}'

     #Count the TOP 10 URLs corresponding to different 4XX status codes and the total number of corresponding occurrences
     elif [ "$1" == "-su"        ];then
        sed -e '1d' web_log.tsv | awk -F '\t' ' {if($6~/^403/) {a[$6":"$1]++}} END {for(i in a){print i,a[i] }}' | sort -nr -k2 | head -n 10
        sed -e '1d' web_log.tsv | awk -F '\t' ' {if($6~/^404/) {a[$6":"$1]++}} END {for(i in a){print i,a[i] }}' | sort -nr -k2 | head -n 10
     
     #Given URL output TOP 100 access source host
     elif [ "$1" == "-gu" ];then
       shift
       if [ "$1" != "" ];then
        sed -e '1d' web_log.tsv|awk -F '\t' '{if($5=="'$1'") a[$1]++} END {for(i in a){print i,a[i]}}'|sort -nr -k2|head -n 100
       else
        echo "Warnning: bash wget -uh <url>"
        exit 1
       fi   
     #Output help information
     elif [ $1 == "-h" ];then
       usage
     fi
  
 #Error 
  else
       usage
       exit 1
       
  fi
 fi
  
}

Statistic $1 $2

