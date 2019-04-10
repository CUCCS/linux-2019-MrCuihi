#!/bin/bash
#Image processing
#MrCuihi

function usage()
{
echo " IMproved 1.0 (2019 April 2)\n"

echo " usage: bash imgpro [Arguments][][][]\n"
echo " Arguments: "
echo " -j  [source(.png)] [destination(.jpg)] : convert png/svg to jpg"
echo " -n  [pattern] [replacement] : Rename files based on input batch"
echo " -q  [quality] [source.jpg] [destination.jpg] : Image quality compression for jpeg format images"
echo " -r  [%|(size)x(size)] [source.jpg|png] [destination.jpg|png] :Compress images while maintaining the same height and width (please add/use %)"
echo " -w  [filename.jpg] [watermark] : Embed a custom watermark (please add/use *.jpg batch)"
echo " -h  Output help information"

}

function Process()
{ 
 while [ "$1" != "" ];do
  #convert png/svg to jpg
  if [ "$1" == "-j" ];then
     if [ $# == 3 ];then
        if [ ! -f $2.png ];then
           echo "No such file"
           exit 1
        else
           if [ `file --mime-type -b $2.png` == "image/png"  ];then
              $(convert $2.png $3.jpg)
              #convert successfully
              if [ $?==1 ];then
                echo "Conversion failed."
                exit 1
              else
                echo "Successfully converted png/svg to jpg."
                echo "Source: $(file $2.png)"
                echo "Destination: $(file $3.jpg)" 
                exit 0
              fi
            else
               echo "Please provide png/svg pictures."
               exit 1
            fi
         fi
      else
         #Eorror , output usage information
         echo "Wrong arguments!"
         usage
      fi
      
  # Rename files based on input batch
  elif [ "$1" == "-n" ];then
      if [ $# == 3];then
        $(rename s'/'$2'/'$3'/' *)
        if [ $? == 1 ];then
           echo "Batch rename file failed."
           exit 1
        else
           echo "Batch renamed file successfully."
           echo "Source: $2"
           echo "Destination: $3"
           exit 0
        fi
      #Eorror , output usage information
      else
        echo "Wrong arguments!"
        usage
      fi
      
  #Image quality compression for jpeg format images
  elif [ "$1" == "-q" ];then
        if [ $# == 4 ];then
           if [ ! -f "$3" ];then
              echo "No such file"
              exit 1
           else
              #only jpeg 
              if [ `file --mime-type -b $3` == "image/jpeg" ];then
                 $(convert -quality $2 $3 $4)
                 if [ $? == 1 ];then
                   echo "Jpeg image quality compression failed"
                   exit 1
                 else
                   echo "Jpeg image quality compression succeeded"
                   echo "Source: $(file $3.jpeg)"
                   echo "Destination: $(file $4.jpg)"
                   exit 0
                 fi
              else
                 echo "Please provide jpeg pictures."
                 exit 1
              fi
            fi
        #Eorror , output usage information
        else
            echo "Wrong arguments!"
            usage
        fi
        
  # Compress images while maintaining the same height and width (please add/use %)
  elif [ "$1" == "-r" ];then
       if [ $# == 4 ];then
         if [ ! -f "$3" ];then
            echo "No such file"
            exit 1
         else
            if [ `file --mime-type -b $3` == "image/jpeg" -o `file --mime-type -b $3` == "image/png" ];then
              $(convert $3 -resize $2 $4)
              if [ $? == 1 ];then
                echo "Compress images while maintaining the same height and width failed."
                exit 1
              else
                echo "Compress images while maintaining the same height and width succeeded."
                echo "Source: $(file $3.jpeg)"
                echo "Destination: $(file $4.jpg)"
                exit 0
              fi
            else
              echo "Please provide jpeg/png/svg pictures."
              exit 1
            fi
          fi
        #Eorror , output usage information
        else
            echo "Wrong arguments!"
            usage
        fi 
    
   #Embed a custom watermark (please add/use *.jpg batch)
  elif [ "$1" == "-w" ];then
       if [ $# == 3 ];then
           $(mogrify -gravity SouthEast -fill black -draw 'text 0,0 '$3'' $2)
           if [ $? == 1 ];then
              echo "Embedding a custom watermark failed."
              exit 1
            else
              echo "Embedding a custom watermark successfully."
              echo "Source: $2"
              echo "Destination: $3"
              exit 0
            fi
        else
           #Eorror , output usage information
            echo "Wrong arguments!"
            usage
        fi
  #Output help information
  elif [ $1 == "-h" ];then
     usage
  else
     usage

  if
  
done 
             
}


Process $1 $2 $3 $4