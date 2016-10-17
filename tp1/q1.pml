#define NB_CLIENT 5
#define NB_STATION 2
#define clientId_t int

mtype = { DIESEL, ESSENCE, ELEC };
chan lineup = [NB_CLIENT] of {clientId_t};

//ya p-e moyen de simplifier ces deux channels avec un rendez vous de messages
chan ticketCounterSelectedClient = [1] of {clientId_t};
chan ticketCounterSubmitOrder = [1] of {clientId_t, mtype, chan};

chan pendingOrders = [NB_CLIENT] of {clientId_t, mtype, chan};

proctype client(clientId_t id)
{
    mtype motorType;
    chan pendingOrder = [0] of {mtype};
    mtype orderContent;
    if
    :: motorType = DIESEL;
    :: motorType = ESSENCE;
    :: motorType = ELEC;
    fi
    printf("Client %d: Je demarre. Mon moteur est de type %e\n", id, motorType);

    do
        ::  printf("Client %d: J'entre dans la station-service\n", id);
            // Entrer dans la station service
            lineup!id;
            // Attendre que le guichet le selectionne
            ticketCounterSelectedClient?eval(id);
            // Passer sa commande
            printf("Client %d: Je suis choisi, je commande %e\n", id, motorType);
            ticketCounterSubmitOrder!id, motorType, pendingOrder;
            // Attendre qu'une station soit prete
            pendingOrder?orderContent;
            printf("Client %d: Je suis servi du %e par la station. Je quitte\n", id, orderContent);
            // Sort de la station service
    od
}

proctype guichet() {
    printf("Guichet: Je demarre\n");
    clientId_t c;
    mtype clientOrderType;
    chan clientPendingOrder;

    do
        // Selectionner un client au hasard dans la file d'attente
        ::  lineup??c;
            printf("Guichet: Le client %d est choisi\n", c);
            ticketCounterSelectedClient!c;
            // Prendre la commande
            ticketCounterSubmitOrder?c, clientOrderType, clientPendingOrder;
            printf("Guichet: Le client %d a choisi %e. Creation de la commande\n", c, clientOrderType);
            // Transmettre la commande a (aux) station(s)
            pendingOrders!c, clientOrderType, clientPendingOrder;

    od
}

proctype station(int id) {
    printf("Station %d: Je demarre\n", id);
    clientId_t c;
    mtype clientOrderType;
    chan clientPendingOrder;
    do
        // Attendre une commande et la recuperer
        ::  pendingOrders?c, clientOrderType, clientPendingOrder;
            // Accueillir le client et lui delivrer sa commande
            printf("Station %d: J'accueille le client %d et je lui delivre sa commande %e\n", id, c, clientOrderType);
            clientPendingOrder!clientOrderType;
    od

}

init {
    int i;

    run guichet();

    for (i : 1 .. NB_STATION) {
        run station(i);
    }

    atomic {
        for (i : 1 .. NB_CLIENT) {
            run client(i);
        }
    }
}