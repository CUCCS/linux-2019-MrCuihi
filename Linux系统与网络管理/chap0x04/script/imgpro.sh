#!/bin/bash
#Image processing
#MrCuihi

function usage()
{
echo " IMproved 1.0 (2019 April 2)"
echo " usage: bash imgpro [Arguments][][][] "
echo " Be sure you have installed ImageMagick, or input 'sudo apt install imagemagick' to install."
echo " Arguments: "
echo " -q  [quality] [source.jpeg] [destination.jpeg] : Image quality compression for jpeg format images"
echo " -r  [%|(size)x(size)] [source.jpg|png] [destination.jpeg|png] :Compress images while maintaining the same height and width (use %)"
echo " -w  [filename.jpeg] [watermark] [destination.jpeg]:Embed a custom watermark (use *.jpeg batch)"
echo " -m  [sourcename] [replacement]: Rename files based on input batch(pattern:*sourcename/sourcename*)"
echo " -c  [source(.png)] [destination(.jpeg)] : convert png/svg to jpeg"
echo " -h  Output help information"

}

function Process()
{ 
 if [ "$1" != "" ];then
  #convert png/svg to jpg
  if [ "$1" == "-c" ];then
     if [ $# == 3 ];then
        if [ ! -f "$2" ];then
           echo "No such file"
           exit 1
        else
	   if [ `file --mime-type -b $2` == "image/png" -o `file --mime-type -b $2` == "image/svg" -o `file --mime-type -b $2` == "image/svg+xml" ];then
              #convert successfully
	      $(convert $2 $3)
              if [ $? == 1 ];then
                echo "Conversion failed."
                exit 1
              else
                echo "Successfully converted png/svg to jpg."
                echo "Source: $(file $2)"
                echo "Destination: $(file $3)" 
                exit 0
              fi
	     else
	        echo "The type of the image :`file --mime-type -b $2`"
                echo "Please provide png/svg pictures."
	     fi
         fi
      else
         #Eorror , output usage information
         echo "Wrong arguments!"
         usage
      fi
      
  # Rename files based on input batch
  elif [ "$1" == "-m" ];then
      if [ $# == 4 ];then
        $(rename 's/'$2'/'$3'/' *)
        if [ $? == 1 ];then
           echo "Batch rename file failed."
           exit 1
        else
           echo "Batch renamed file successfully."
	   echo "Source: $(file $2)"
	   echo "Destination: $(file $3)"
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
                   echo "Source: $(file $3)"
                   echo "Destination: $(file $4)"
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
                echo "Source: $(file $3)"
                echo "Destination: $(file $4)"
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
       if [ $# == 4 ];then
          
           #wimg=$(mogrify -gravity SouthEast -fill black -draw 'text 0,0 '$3'' $2)
	   $(convert $2 -fill red -pointsize 60 -draw "text 60,60 $3" $4 )
           if [ $? == 1 ];then
              echo "Embedding a custom watermark failed."
              exit 1
            else
              echo "Embedding a custom watermark successfully."
	      echo "Source: $(file $2)"
	      echo "Destination:$(file $4)"
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

  fi
 
 fi
             
}


Process $1 $2 $3 $4
