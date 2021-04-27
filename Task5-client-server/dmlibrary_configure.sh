#!/bin/bash
#Task 5.4 automatic configuration script by Dominik Czerwoniuk & Maciej Kopa.

#VARIABLES
dmserver_path=
dmclient_path=
dmlibrary_path=

#FUNCTIONS
load_sample_books(){
	bookname=
	content=
	
	content="Nothing ever begins.
There is no first moment; no single word or place from which this or any story springs.
The threads can always be traced back to some earlier tale, and the tales that preceded that; though as the narrator's voice recedes the connections will seem to grow more tenuous, for each age will want the tale told as if it were of its own making."
	bookname="${dmlibrary_path}AK1_AndrzejKamien_Opowiesci_notborrowed"
	touch ${bookname}
	echo "$content" > ${bookname}
	
	content="Diuna jest jedyną w swoim rodzaju powieścią prezentującą złożoność i bogactwo wykreowanego świata. Poza «Władcą Pierścieni» nie znam niczego, co można by do niej porównać"
	bookname="${dmlibrary_path}HF1_HerbertFrank_Dune_notborrowed"
	touch ${bookname}
	echo "$content" > ${bookname}
	
	content="Choć filozofię studiowałem,

medyczny kunszt, arkana prawa

i teologię też, z zapałem

godnym, zaiste, lepszej sprawy,

na nic się zdały moje trudy —

jestem tak mądry, jak i wprzódy!

Zwą mnie magistrem, ba, doktorem!

Od lat dziesięciu za nos wodzę

po krętej poszukiwań drodze

swych uczniów głupkowatą sforę

i widzę, że nic nie wiem przecie.

Ta myśl, jak kamień, serce gniecie!

I cóż, żem jest mędrszy niż owe gaduły

magistry, doktory, pismaki i klechy,

że za nic mam wszelkie moralne skrupuły,

nie boję się diabła ni kary za grzechy —

wraz z trwogą i radość została odjęta,

bo księga poznania jest dla mnie zamknięta!

Czyż stertą uczonych książkowych mądrości

naprawić świat zdołam, dać szczęście ludzkości?"
	bookname="${dmlibrary_path}WG1_WolfgangvonGoetheJohann_Faust_notborrowed"
	touch ${bookname}
	echo "$content" > ${bookname}
	
	content="Plato was an Athenian who lived in the late fifth and into the fourth century BCE. He was of aristocratic descent, especially on his mother’s side. As a young man he was attracted to the possibility of a life in politics: many of his relatives were part of an oligarchic coup against the Athenian democracy that was very bloody and destructive (there were actually two such coups, both relatively short-lived, during his boyhood). Then he met Socrates, a great Athenian philosopher, and renounced his traditional political ambitions. One of the interesting questions is — as he eventually turned to writing philosophical dialogues — was he still practising politics but in another form?"
	bookname="${dmlibrary_path}P1_Plato_Republic_notborrowed"
	touch ${bookname}
	echo "$content" > ${bookname}

	content="David Copperfield, Dickens’s eighth novel, was first published as a serial. The first installment was published in May of 1849. The last installment was issued in November of 1850.

David Copperfield held a special place in Dickens’s heart. In the preface to the 1867 edition, Dickens wrote, “like many fond parents, I have in my heart of hearts a favourite child. And his name is David Copperfield.”"
	bookname="${dmlibrary_path}CD1_CharlesDickens_DavidCopperfield_marko"
	touch ${bookname}
	echo "$content" > ${bookname}
	
	echo "Sample books loaded succesfully!"
}

#replaces dmlibrary=path_not_defined in dmlibrary program file
#first variable - file name
replace_path_not_defined() {
	filepath=$1
	echo "$filepath"
	if grep -q "dmlibrary=path_not_defined" ${filepath}; then
		echo "Configuration is possible!"
		
		#Create temporary file with new line in place
		#We use different delimeter ";" as file name contains "/"
		cat ${filepath} | sed -e "s;dmlibrary=path_not_defined;dmlibrary=\"${dmlibrary_path}\";" > /tmp/tmp_dmlibrary_file
		#Copy the new file over the original file
		mv /tmp/tmp_dmlibrary_file ${filepath}
		echo "Correct path has been set"
	else
		echo "Upps, can't configure the file!"
	fi
}

configure_dmlibrary_paths() {
	replace_path_not_defined "$dmserver_path"
	replace_path_not_defined "$dmclient_path"
}

#MAIN

echo "Welcome, I will configure dmlibrary for you!"
echo "--------------------------------------------"
echo "Please, enter the path to dmlibrary_server.sh file"
echo "e.g. /home/username/dmlibrary_server.sh"
echo -ne "\npath:"
read dmserver_path
if [[ -f "$dmserver_path" && "$dmserver_path" == *"/dmlibrary_server.sh" ]]; then
	echo "You've entered correct path!"
else
	echo "Error: wrong path!"
	exit 1
fi

echo ""

echo "Please, enter the path to dmlibrary_client.sh file"
echo "e.g. /home/username/dmlibrary_client.sh"
echo -ne "\npath:"
read dmclient_path
if [[ -f "$dmclient_path" && "$dmclient_path" == *"/dmlibrary_client.sh" ]]; then
	echo "You've entered correct path!"
else
	echo "Error: wrong path!"
	exit 1
fi

echo ""
#asking for good place for book files
echo "Please, enter the path to a place where dmlibrary library folder with books will reside"
echo "e.g. /home/username/"
echo -ne "\npath:"
read dmlibrary_path
if [[ -d "$dmlibrary_path" && "$dmlibrary_path" == *"/" ]]; then
	echo "You've entered correct path!"
else
	echo "Error: wrong path!"
	exit 1
fi
echo ""
#create dir for library
#check if we can create the folder
if [ -d "${dmlibrary_path}dmlibrary" ]; then
	echo "Error: there is a library present, try to remove it manually!"
	exit 1
else
	mkdir "${dmlibrary_path}dmlibrary"
	dmlibrary_path=${dmlibrary_path}"dmlibrary/"
	#sample library files loading
	echo "would you like to load sample books to the library?"
	echo "y - yes n - no"
	choice=
	read choice
	case $choice in
		"yes" | "y") load_sample_books;;
		*) echo "Ok, nevermind";;
	esac
fi

configure_dmlibrary_paths
echo "Configuration ended!"
