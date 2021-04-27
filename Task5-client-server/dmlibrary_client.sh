#!/bin/bash
#Task 5.4 client by Dominik Czerwoniuk & Maciej Kopa.

#### Functions

#first variable - username
#second variable - type of action for the client
#third variable - data for given action
send_msg() {
	username=$1
	action=$2
	data=$3
	order=$(ls $dmqueue | tail -1)
	((order++))
	
	message_file="${dmqueue}$order"
	touch ${message_file}
	echo "$username" >> "$message_file"
	echo "$action" >> "$message_file"
	echo "$data" >> "$message_file"
}

#function that displays the msg from server and process further instructions
#first variable - borrow_book / return_book / read_book ONLY to take further steps
handle_inquiry() {
	while true; do
		what=$1
		#waiting for server to respond timeout in quarters of seconds
		timeout=25
		waiting_time=0
		#redirecting error message 2> away from user not to bother him
		while [ -z "$(ls -A $dmresponse 2> /dev/null)" ]
		do
			echo -ne "\rwaiting for response   "
			sleep 0.1
			echo -ne "\rwaiting for response..."
			sleep 0.1
			waiting_time=$(($waiting_time + 1))
			case $waiting_time in
				"$timeout")
					echo -e "\nNo reponse from the server. Try again later"
					exit 1
					;;
			esac
		done
		#echo new line after the "waiting animation"
		echo ""
		filename=$(ls $dmresponse | head -1)
		action=`cat ${dmresponse}/${filename} | sed -n '1p'`
		case $action in
			"display")
				cat ${dmresponse}/${filename} | sed -n '2p'
				rm ${dmresponse}/${filename}	
				exit 1
				;;
			"search_results")
				n=1
				echo "Results of your search:"
		
				while read line; do
				if [ "$line" != "search_results" ]; then
					line=$(printf "$line" | awk '{gsub("notborrowed","")}1')
					line=$(printf "$line" | awk -v username=$username '{sub(username," <- You have it!")}1')
					line=$(printf "$line" | awk '{gsub("_"," ")}1')
					echo "$n: $line"
					n=$((n+1))
				fi
				done < ${dmresponse}/${filename}
				
				echo -ne "Provide number with desired book or q to quit: "
				read choice
				
				case $choice in
				"q" ) 	rm ${dmresponse}/${filename}
					exit
				;;
				* ) 	if (( 0<choice && choice < n )); then
					((choice++))
					choice=-$choice
					data=`cat ${dmresponse}/${filename} | head $choice | tail -1`
					rm ${dmresponse}/${filename}	
					case $what in
						"borrow_book" ) send_msg "$username" "borrow_book" "$data";;
						"return_book" ) send_msg "$username" "return_book" "$data";;
						"read_book" ) 	send_msg "$username" "read_book" "$data";;
						*) echo "Error: return/borrow/read? Update client!";;
					esac
					else
					echo "Please provide valid number from 1 to $((n-1))."
					fi
				;;
				esac
				;;
				"read_book" )		echo "==================================================================="
							sed '1d' ${dmresponse}/$filename
							rm ${dmresponse}/${filename}	
							echo "==================================================================="
							echo "Press q to quit or c to copy the file."
						while true; do
							read quit_or_copy
								case $quit_or_copy in
									"q") exit;;
									"c") copy_file "$data";;
									*) echo "Error while copy/quit in read mode. Provide valid key [q/c].";
								esac
						done;;
				*)
				echo -ne "\rError: server response failure. Please wait.";;
		esac
	done
}

#first variable - filename
#this function might not make sense when talking about books, but imagine "books" are files with codes etc.
copy_file() {
	echo "The file $1 will be saved in $username's home dir. Closing lib..."
	cp -i ${dmlibrary}$1 /home/$username
	exit 
}
#simple help
helpinst() {
	echo "=========================================================================="
	echo -e "Library by /// \n lib [OPTION] [...]\n\n -a | --author - search using author's name, i.e. lib -a Wolfgang, than select desired book from the list to borrow it or press q to quit\n\n -t | --title- search using book's title, i.e. lib -t Dreams, than same steps when using -a\n\n -r | --return - return book, it will display borrowed books by the user and than select one to return it or q to quit (in case you change your mind)\n\n -e | --read - display and read/copy* your books *copy to user's home dir\n\n -h | --help - help page"	
	echo "=========================================================================="
	exit 1
}

#### Variables

username=$(id -u -n)
dmlibrary="/home/maciej/mbin/test/dmlibrary/"

pathtotmpdir="/tmp/dmlibrary/"
dmqueue=$pathtotmpdir"dmqueue/" #request from clients
dmresponse=$pathtotmpdir"dmresponse/$username"

#### MAIN

if [ $dmlibrary == path_not_defined ]; then
	echo "Please run configuration script!"
	exit 1
fi

#it clears the dmresponse dir in case user closed the app before and left behind any files there 
if [ -f ${dmresponse}/* ]; then
rm ${dmresponse}/*
fi

#check parameters: lib -a/-t/-r/-e/-h <author/title>
if [ "$1" = "" ]; then
	helpinst
else
while [ "$1" != "" ]; do
	case $1 in
		-a | --author ) shift
						data=$1
						send_msg "$username" "search_author" "$data"
						handle_inquiry "borrow_book";;
		-t | --title ) shift 
						data=$1
						send_msg "$username" "search_title" "$data"
						handle_inquiry "borrow_book";;
		-r | --return ) shift
						send_msg "$username" "search_my_library" ""
						handle_inquiry "return_book";;
		-e | --read ) shift			
						send_msg "$username" "search_my_library" ""
						handle_inquiry "read_book";;
		-h | --help ) helpinst;;
		*) helpinst;;
	esac
	shift
done
fi

