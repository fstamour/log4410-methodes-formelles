/*
Client
Guichet
Station
*/

#define NB_CLIENT 2
#define clientId_t int

mtype = { DIESEL, ESSENCE, ELEC };
chan awaitingService = [NB_CLIENT] of {clientId_t};
chan currentlyServing = [1] of {clientId_t};
chan orders = [1] of {clientId_t, mtype};



proctype client(int id)
{
do
	:: printf("Client %d: J'entre dans la station service\n", id);
	awaitingService!id;
	// Attendre son tour
	currentlyServing??id ->
	           printf("Client %d: Je suis choisi\n", id);
		   if
			// Choisi son carburant.
			:: orders!id, DIESEL;
			:: orders!id, ESSENCE;
			:: orders!id, ELEC;
		   fi
	
od
}

proctype guichet() {
printf("Le guichet demarre");
clientId_t c;
do
	::skip;
	
	if
	
	
	::awaitingService??c ->
	printf("Guichet: le client %d est choisi\n", c);
	currentlyServing!c;
	
	fi
	
	/*clientId_t clientId;
	mtype orderType;
	orders?clientId, orderType
	   printf("client %d chose %d\n", clientId, orderType);*/
	   
od
}

proctype station(int id) {
	 skip;
}

init {
	run client(0);
	run client(1)
	run guichet();
}
