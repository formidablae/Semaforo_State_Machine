/* ProgettoASM_Semaforo */
asm Semaforo

import StandardLibrary

// Dichiarazione universi e funzioni
signature:

	// Dichiarazione dei domini, enum
	enum domain Colore = { VERDE | GIALLO | ROSSO }
	domain Seconds subsetof Integer
	
	// Variabili e funzioni controlled (leggibili e scrivibili)
	dynamic controlled coloreSemaforo: Colore
	dynamic controlled tempo: Seconds
	dynamic controlled messaggio : String
	
	// Funzioni derivate
	derived maxTempo: Colore -> Seconds
	derived prossimoColore: Colore -> Colore
	

// Definizioni delle funzioni, delle regole, macro regole e dalla regola main.
definitions:
	
	// Funzione che ritorna il max della durata di tempo di ciscun colore
	function maxTempo($colore in Colore) =
		if ($colore = VERDE) then 40
		else if ($colore = GIALLO) then 5
		else 15 endif endif
	
	// Funzione che ritorna il prossimo colore dato in input il colore attuale
	function prossimoColore($coloreAttuale in Colore) = 
		if ($coloreAttuale = VERDE) then GIALLO
		else if ($coloreAttuale = GIALLO) then ROSSO
		else VERDE endif endif
	
	// Regola per passare al prossimo stato, prossimo colore del semaforo
	// e per settare il tempo al max del prossimo colore
	rule r_cambioColore = 
		par
			tempo := maxTempo( prossimoColore(coloreSemaforo) )
			coloreSemaforo := prossimoColore(coloreSemaforo)
			messaggio := "Cambio colore"
		endpar
		
	
	// Macro regola che decrementa il tempo e
	// chiama la regola che porta al prossimo colore
	// se i secondi sono diventati 0
	macro rule r_decrementaTempo =
		if (tempo > 0) then
			par
				tempo := tempo - 1
				messaggio := "Decremento secondi"
			endpar
		else r_cambioColore[] 
		endif
		
	// Macro regola che simola l'inizializzazione e decremento del tempo del semaforo
	macro rule r_simolaSemaforo =
	par
		// Solo la prima volta sceglie a random uno dei tre colori dell'enum Colore
		if (tempo = -1) then
			choose $colore in Colore with true do
			tempo := maxTempo($colore)
		endif
		
		// Decrementa i secondi
		r_decrementaTempo[] 
	endpar
   
	//Definizione della regola principale main. Chiama il simolatore di semaforo
	main rule r_Main = r_simolaSemaforo[]

// Valori di inizializzazione
default init initialize:

	// Stato iniziale tempo = -1 per indicare che il semaforo non e in funzione.
	function tempo = -1