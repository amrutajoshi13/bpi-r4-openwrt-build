#!/bin/sh
luci2_htmlpath=/usr/local/bin/Testscripts/Customer_Specific_logo/luci2.html
ui_path=/usr/local/bin/Testscripts/Customer_Specific_logo/ui.js

echo "======================================================================
 Whitelabel_logo
======================================================================= "
echo " "
echo "Do you want Whitelabel_logo ?(y/n)"
read res7 

if [ $res7 = "y" ]
then 
    echo "Please choose below option"
    echo "1)Web page without logo"
    echo "2)Web page with customer specific logo"
fi
    read ans
   case $ans in 
      1)
        cp  /usr/local/bin/Testscripts/without_logo/ui.js /www/luci2/                                  
        cp  /usr/local/bin/Testscripts/without_logo/luci2.html /www/                            
        /etc/init.d/uhttpd restart
        echo "Please open the web page in incognito mode and check the web page."
        break
	;;
      2)
        echo "Please make sure that you have copied customer logo in PC path /Silbo-RF-44/Customer_logo/"
        echo "Please enter customer logo name"
         read customer_logoname
        echo "Please enter  Enter PC username"
         read PC_username
         scp -p $PC_username@192.168.9.2:Silbo-RF-44/Customer_logo/$customer_logoname /www/luci2/icons/

        var=$(ls -l /www/luci2/icons/$customer_logoname)
        size=$(echo $var | cut -d " " -f 5)
	        if [ "$size" -le "20000" ]
	        then            
		        previous_icon_html=$(grep -ow "inv_logo.svg" ${luci2_htmlpath})        
				customerIcon1_replace_html="$customer_logoname"           
				sed -i "s/${previous_icon_html}/${customerIcon1_replace_html}/" "$luci2_htmlpath"
		
				previous_icon=$(grep -ow "inv_logo.svg" ${ui_path})        
				customerIcon2_replace="$customer_logoname"
				sed -i "s/${previous_icon}/${customerIcon2_replace}/" "$ui_path"
		
		        cp  /usr/local/bin/Testscripts/Customer_Specific_logo/ui.js /www/luci2/
		        cp   /usr/local/bin/Testscripts/Customer_Specific_logo/luci2.html /www/
		        /etc/init.d/uhttpd restart
		        echo "Please open the web page in incognito mode and check the web page."
	        else 
	            rm /www/luci2/icons/$customer_logoname
	            echo "The above given logo cannot be updated in Webpage,as the logo size is greater than 20.0K"
	        fi
        break
        ;;
    * );;
esac
