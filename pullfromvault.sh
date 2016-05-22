#!/bin/bash
#Written by Andrew Guidetti

VAULT_IP="IP.AND.PORT.FOR.VAULT"
APP_ID="722d6410-cda6-4d47-bbfb-4d9103368bf0"
#USER_ID="00000000-0000-0000-0000-00000000000"
#the user_id and app_id should never be hardcoded together in production!

function connect2Vault {

	#TODO: add some logic here if vault is not initialized
	echo -e "\nChecking if vault is initialized..."
	curl "http://"$VAULT_IP"/v1/sys/init"
	sleep 1

	echo -e "\nlogging into vault with app_id:"
	sleep 1
	echo $APP_ID
	sleep 1

	echo -e "\nYou must now provide a private user_id:"
	read USER_ID
	sleep 1
	echo "Checking: "$USER_ID""
	sleep 1

	JSONTOKEN=`
		curl \
		-s \
		-X POST \
		-d '{"app_id":"'"$APP_ID"'", "user_id":"'"$USER_ID"'"}' \
		"http://"$VAULT_IP"/v1/auth/app-id/login"`		

    	VAULT_TOKEN=`echo "$JSONTOKEN" | sed -e 's/^.*"client_token"[ ]*:[ ]*"//' -e 's/".*//'`
	export VAULT_TOKEN

	#check if the key is long enough
	if [ ${#VAULT_TOKEN} -ge 2 ]; 
	then
		echo -e "\nVault has granted you a key:"
		sleep 1
		echo $VAULT_TOKEN
		sleep 1
		echo -e "\nConnected to Vault. Ready for step 3.\n"
	else
		echo -e "\n!!!Vault did not give you a key!!!"
		echo -e "Please check your user_id and try again before step 3.\n"
	fi
menu
}

function pullPasswords {

	#TODO: make this recursive and reusable, add some logic if not connected
	echo -e "Retrieving passwords...\n"
	sleep 1
	
	echo -e "Password1 = \c"
	curl \
   	    -s \
	    -H "X-Vault-Token:$VAULT_TOKEN" \
   	     http://"$VAULT_IP"/v1/secret/password1 | sed -e 's/^.*"Password1"[ ]*:[ ]*"//' -e 's/".*//'
		 
	echo -e "Password2 = \c"
	curl \
	    -s \
	    -H "X-Vault-Token:$VAULT_TOKEN" \
	     http://"$VAULT_IP"/v1/secret/password2 | sed -e 's/^.*"Password2"[ ]*:[ ]*"//' -e 's/".*//'
			
	echo -e "Password3 = \c"
	curl \
	    -s \
	    -H "X-Vault-Token:$VAULT_TOKEN" \
	     http://"$VAULT_IP"/v1/secret/password3 | sed -e 's/^.*"Password3"[ ]*:[ ]*"//' -e 's/".*//'

	echo ""
menu
}

function menu {
        echo -e "Choose an option\n1: Connect to Vault \n2: Pull passwords from Vault \n3: Exit "
        read menuPick
                if [ "$menuPick" == "1" ]
                then
                    connect2Vault
                elif [ "$menuPick" == "2" ]
                then
                    pullPasswords
                elif [ "$menuPick" == "3" ]
                then
		    echo "Goodbye!"
		    exit
                else
		    echo "Try again"
		    menu	
                fi
}
menu
