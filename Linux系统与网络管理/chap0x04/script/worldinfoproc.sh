#!/bin/bash
#Worldcup player info batch processing
#MrCuihi

function usage()
{
echo " IMproved 1.0 (2019 April 6)"

echo " usage: bash wip [Arguments]"
echo " Arguments: "
echo " -rage Count the number and percentage of players in different age ranges (under 20, [20-30], over 30)."
echo " -posi Count the number and percentage of players on different positions."
echo " -name Count the longest player, the shortest player."
echo " -tage Count the oldest player, the youngest player."
echo " -h  Output help information."

}

#Count the number and percentage of players in different age ranges (under 20, [20-30], over 30) 
function countrage()
{
    age=$(awk -F '\t' '{print $6}' Linux系统与网络管理/chap0x04/script/worldcupplayerinfo.tsv)
    sum_agelt20=0
    sum_ageb20to30=0
    sum_agegt30=0
    sum_total=0
    per_agelt20=0
    per_ageb20to30=0
    per_agegt30=0
    
    for a in $age
    do 
       #delete the first line
       if [ "$a" != "Age" ];then
	   sum_total=$[$sum_total+1]
           #age<20
           if [ "$a" -lt 20 ];then
              sum_agelt20=$[$sum_agelt20+1]
            #age [20,30]
           elif [ "$a" -ge 20 ] && [ "$a" -le 30 ];then
              sum_ageb20to30=$[$sum_ageb20to30+1]
            #age>30
           elif [ "$a" -gt 30 ];then
              sum_agegt30=$[$sum_agegt30+1] 
           fi
        fi
    done
   
    per_agelt20=$[$sum_agelt20*100/$sum_total]
    per_ageb20to30=$[$sum_ageb20to30*100/$sum_total]
    per_agegt30=$[$sum_agegt30*100/$sum_total]

    echo "===World Cup athletes age statistics==="
    echo "Age  <  20 : $sum_agelt20 ; Percentage : '$(awk 'BEGIN{printf "%.3f",'"$sum_agelt20"*100/"$sum_total"'}')'%"
    echo "Age[20,30] : $sum_ageb20to30 ; Percentage : '$(awk 'BEGIN{printf "%.3f",'"$sum_ageb20to30"*100/"$sum_total"'}')'%"
    echo "Age  >  30 : $sum_agegt30 ; Percentage : '$(awk 'BEGIN{printf "%.3f",'"$sum_agegt30"*100/"$sum_total"'}')'%"
        
}

#Count the number and percentage of players on different positions.
function countposi()
{
  positions=$(awk -F '\t' '{print $5}' Linux系统与网络管理/chap0x04/script/worldcupplayerinfo.tsv) 
  declare -A poscountdic
  total_sum=0
  for pos in $positions
  do  
      #delete the first line
	 if [ "$pos" != "Position" ];then
	        total_sum=$[$total_sum+1]
		if [ !${poscountdic[$pos]} ];then	
			poscountdic[$pos]=$[${poscountdic[$pos]}+1]
		else
			poscountdic[$pos]=0
		fi
        fi
	 	
  done
  for pos in ${!poscountdic[@]}
  do
    echo "$pos : ${poscountdic[$pos]} ; Percentage: '$(awk 'BEGIN{printf "%.2f",'${poscountdic[$pos]}*100/$total_sum'}')'%"
  done
  
}

#Count the longest player, the shortest player.
function countname()
{
        namelength=$( awk -F '\t' '{print length($9)}' Linux系统与网络管理/chap0x04/script/worldcupplayerinfo.tsv)
	longestnamelen=0
	shortestnamelen=103

 	for l in $namelength
 	do 
       		if [ "$l" -gt "$longestnamelen" ];then
        	longestnamelen=$l
      		elif [ "$l" -lt "$shortestnamelen" ];then
        	shortestnamelen=$l
     		fi
 	done
	
	longestname=$(awk -F '\t' '{if (length($9)=='$longestnamelen') {print $9} }' worldcupplayerinfo.tsv)
	shortestname=$(awk -F '\t' '{if (length($9)=='$shortestnamelen') {print $9} }' worldcupplayerinfo.tsv)
       
       	echo "===World Cup athletes the length of name statistics==="
        echo "The longest name : $longestname ; The longest name length : $longestnamelen"
        echo "The shortest name : $shortestname ; The shortest name length : $shortestnamelen"
        echo "======================================================"  
}

#Count the oldest player, the youngest player.
function counttage()
{
   age=$(awk -F '\t' '{print $6}' Linux系统与网络管理/chap0x04/script/worldcupplayerinfo.tsv)
   oldest=0
   youngest=103
   oldestname=''
   youngestname=''
   total_sum=0
   
   for a in $age
   do
     #delete the first line
     if [ "$a" != "Age" ];then
        total_sum=$[$total_sum+1]
        if [ "$a" -gt $oldest ];then
           oldest=$a
           oldestname=$(awk -F '\t' 'NR=='$[$total_sum +1]' {print $9}' worldcupplayerinfo.tsv)
        
        elif [ "$a" -lt $youngest ];then
           youngest=$a
           youngestname=$(awk -F '\t' 'NR=='$[$total_sum +1]' {print $9}' worldcupplayerinfo.tsv)
        fi
     fi
    done
    
    echo "===World Cup athletes age statistics==="
    echo "The name of the oldest : $oldestname ; Age : $oldest"
    echo "The name of the youngest : $youngestname ; Age : $youngest"
    echo "======================================="
}

#Worldcup player info batch processing
function worldinfoproc()
{
   if [ "$1" != "" ];then
     if [ $# == 1 ];then
        #Count the number and percentage of players in different age ranges (under 20, [20-30], over 30) 
        if [ "$1" == "-rage" ];then
           countrage
        elif [ "$1" == "-posi" ];then
           countposi
        elif [ "$1" == "-name" ];then
           countname
        elif [ "$1" == "-tage" ];then
           counttage
        elif [ "$1" == "-h" ];then
           usage
        fi
     #Error
     else
        usage
     fi
     
   fi
   
 
}

worldinfoproc $1
