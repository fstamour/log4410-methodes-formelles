#define NB_CLIENT 5
#define NB_STATION 2
#define clientId_t int
#define selected 1

mtype = { DIESEL, ESSENCE, ELEC };

typedef AwaitingClient {
    clientId_t c;
    chan selectMe
}

typedef Order {
    clientId_t c;
    mtype engineType;
    chan deliverMe
}

chan lineup = [NB_CLIENT] of {AwaitingClient};
chan ticketCounterService = [1] of {Order};
chan pendingOrders = [NB_CLIENT] of {Order};

proctype client(clientId_t id)
{
    // Type de carburant (const)
    mtype engineType;
     if
    :: engineType = DIESEL;
    :: engineType = ESSENCE;
    :: engineType = ELEC;
    fi

    // Attente
    AwaitingClient awaiting;
    awaiting.c = id;
    chan selectMe = [0] of {byte};
    awaiting.selectMe = selectMe;

    // Commande et livraison
    Order pendingOrder;
    pendingOrder.c = id;
    pendingOrder.engineType = engineType;
    chan deliverMe = [0] of {mtype};
    pendingOrder.deliverMe = deliverMe;

    printf("Client %d: Je demarre. Mon moteur est de type %e\n", id, engineType);

    do
        ::  printf("Client %d: J'entre dans la station-service\n", id);
            // Entrer dans la station service
            lineup!awaiting;
            // Attendre que le guichet le selectionne
            awaiting.selectMe?selected;
            // Passer sa commande
            printf("Client %d: Je suis choisi, je commande %e\n", id, engineType);
            ticketCounterService!pendingOrder;
            // Attendre qu'une station soit prete
            mtype orderFulfillment;
            pendingOrder.deliverMe?orderFulfillment;
            printf("Client %d: Je suis servi du %e par la station. Je quitte\n", id, orderFulfillment);
            // Sort de la station service
    od
}

proctype guichet() {
    printf("Guichet: Je demarre\n");
    AwaitingClient awaitingClient;
    Order clientOrder;

    do
        // Selectionner un client au hasard dans la file d'attente
        ::  lineup??awaitingClient;
            printf("Guichet: Le client %d est choisi\n", awaitingClient.c);
            //Signaler au client qu'il est choisi
            awaitingClient.selectMe!selected;
            // Prendre la commande
            ticketCounterService?clientOrder;
            printf("Guichet: Le client %d a choisi %e. Creation de la commande\n", clientOrder.c, clientOrder.engineType);
            // Transmettre la commande a (aux) station(s)
            pendingOrders!clientOrder;

    od
}

proctype station(int id) {
    printf("Station %d: Je demarre\n", id);
    Order clientPendingOrder;
    do
        // Attendre une commande et la recuperer
        ::  pendingOrders?clientPendingOrder;
            // Accueillir le client et lui delivrer sa commande
            printf("Station %d: J'accueille le client %d et je lui delivre sa commande %e\n", id, clientPendingOrder.c, clientPendingOrder.engineType);
            clientPendingOrder.deliverMe!clientPendingOrder.engineType;
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