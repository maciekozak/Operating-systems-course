#!/bin/bash
#Task 5.4 server by Dominik Czerwoniuk & Maciej Kopa.

#### Functions

prepare_dirs() {	
	#it rebuilds the dirs for the program to work properly
	if [ !  -d "$pathtotmpdir" ]; then
		mkdir ${pathtotmpdir}
		mkdir ${dmqueue}
		mkdir ${dmresponse}
	else
		rm -r ${pathtotmpdir}
		mkdir ${pathtotmpdir}
		mkdir ${dmqueue}
		mkdir ${dmresponse}
	fi
}

process_queue() {
	#getting the filename of the oldest request
	request_to_process=$(ls ${dmqueue} | head -1)
	#gathering information from request
	username=$(cat ${dmqueue}${request_to_process} | sed -n '1p')
	mkdir -p ${dmresponse}${username}
	request=$(cat ${dmqueue}${request_to_process} | sed -n '2p')
	data=$(cat ${dmqueue}${request_to_process} | sed -n '3p')

	case $request in
		"search_author" ) search_author "$username" "$data";;
		"search_title" ) search_title "$username" "$data";;
		"borrow_book" ) borrow_book "$username" "$data";;
		"return_book" ) return_book "$username" "$data";;
		"search_my_library" ) search_my_library "$username";;
		"read_book" ) read_book "$username" "$data";;
		*) echo "upps!";;
	esac	
	echo -e "\nUser $username served ($request)!"
	rm ${dmqueue}${request_to_process}
}

#first variable - username
#second variable - search phrase
search_author() {
	results=$(find ${dmlibrary} -name "*_*$2*_*_*" -printf "%f\n")
	check_results "$1" "$results"
}

#first variable - username
#second variable - search phrase
search_title() {
	results=$(find ${dmlibrary} -name "*_*_*$2*_*" -printf "%f\n")
	check_results "$1" "$results"
}

#first variable - username
search_my_library() {
	results=$(find ${dmlibrary} -name "*_*_*_$1" -printf "%f\n")
	check_results "$1" "$results"
}

check_results() {
	results=$2
	if [ "$results" == "" ]; then
		results="No matching books, try something different."
		send_msg "$1" "display" "$results"
	else
		send_msg "$1" "search_results" "$results"
	fi

}

#first variable - username
#second variable - type of action for the client
#third variable - data for given action
send_msg() {
	username=$1
	action=$2
	data=$3
	#response will contain in the first line command and in the next lines data
	message_file="${dmresponse}${username}/1"
	touch ${message_file}
	echo "$action" >> "$message_file"
	echo "$data" >> "$message_file"
}

#first variable - username
#second variable - filename
borrow_book() {
	username=$1
	book=$2
	#if the book's filename shows that it is NOT borrowed by someone, let the user borrow it
	if [[ $book == *"notborrowed" ]];
	then
		#creating new filename for the book with username at the end
		new_book_name=$(printf "$book" | awk -v username=$username '{gsub("notborrowed",username)}1' )
		mv ${dmlibrary}${book} ${dmlibrary}${new_book_name}
		#creating "pretty" book information for client to display
		book_name_for_human=$(printf "$book" | awk '{gsub("notborrowed","")}1' )
		book_name_for_human=$(printf "$book_name_for_human" | awk '{gsub("_"," ")}1' )
		send_msg "$username" "display" "You have borrowed ${book_name_for_human}"
	else
		send_msg "$username" "display" "You cannot borrow this book!"
	fi

}

# first variable - username
# second variable - filename
return_book() {
	username=$1
	book=$2
	#if the book's filename says that the book is borrowed by given user, let him return it
	if [[ $book == *${username} ]];
	then
		new_book_name=$(printf "$book" | awk -v username=$username '{gsub(username,"notborrowed")}1' )
		mv ${dmlibrary}${book} ${dmlibrary}${new_book_name}
		send_msg "$username" "display" "You have returned the book!"
	else
		send_msg "$username" "display" "You cannot return this book!"
	fi
}

read_book() {
	#username=$1
	book_name=$2
	book=`cat ${dmlibrary}${book_name}`
	send_msg "$1" "read_book" "$book"
}

#### Variables

dmlibrary="/home/maciej/mbin/test/dmlibrary/"

pathtotmpdir="/tmp/dmlibrary/"
dmqueue=$pathtotmpdir"dmqueue/"
dmresponse=$pathtotmpdir"dmresponse/"

#### MAIN

if [ $dmlibrary == path_not_defined ]; then
	echo "Please run configuration script!"
	exit 1
fi	

prepare_dirs

#check if there is something in the queue and process it
#listening for requests
while true
do
	#process queue if there is a file in queue folder
	if ls -1qA $dmqueue | grep -q .
	then
		process_queue
	else
		echo -ne "\rNothing to handle..."
		sleep 0.1
		echo -ne "\rNothing to handle   "
		sleep 0.1
	fi
done



