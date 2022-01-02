# FILE:
#	elaborazione.s
# AUTORI: Marco Castelli & Emanuele Poiana && Lleshaj Ledjo 
#	
#


.section .data
	newline: .ascii "\n"

.section .text
	.global elaborazione

elaborazione:

	# OPERAZIONI PRELIMINARI #
	# - Imposto lo stack pointer attuale come base pointer
	# - Salvo lo stato dei registri (per ripristino futuro)
	# - Salvo l'indirizzo dei parametri in %esi e %edi
	# - Controllo se mi viene passato un file vuoto

	#salvo ebp attuale e imposto esp
	pushl %ebp
	movl %esp,%ebp
	
	#salvo lo stato dei registri, MEMO: REIMPOSTARLI A FINE ESECUZIONE
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edi
	pushl %esi
	
	#esi contiene l'indirizzo di bufferin
	#edi contiene l'indirizzo di bufferout
	movl 8(%ebp), %esi
	movl 12(%ebp), %edi
	
	#svuoto i registri
	xorl %ecx,%ecx
	xorl %eax,%eax
	xorl %ebx,%ebx
	xorl %edx,%edx

	#se la stringa è vuota, salto alla fine
	cmpb $0, (%esi)
	je end

	#utilizzo dl per mantenere il numero di caratteri di ogni riga in modo che posso incrementare per raggiungere la riga successiva 
	#lo inizializzo a 0.
	movb $0, %dl

	#utilizzo dh per mantenere il numero di salvataggi effettuati A,B,C =3 e lo inizializzo a 0
	movb $0, %ch

#INIZIO SALVATAGGIO AUTO
salvataggio:
	

	cmpb $3,%ch		#sono stati effettuati i 3 salvataggi?
	je automatico		#salta al funzionamento automatico
	
	#Possibili errori
	cmpb $45,2(%esi)	#è stato inserito un numero negativo 
	je Error
	#se non è una cifra
	cmpb $48,2(%esi)	#è <0 
	jl Error
	cmpb $57,2(%esi)	#è >9 
	jg Error
	

	cmpb $65,(%esi)		#vuoi salvare in A?
	je salvaInA
	cmpb $66,(%esi)		#vuoi salvare in B?
	je salvaInB
	cmpb $67,(%esi)		#vuoi salvare in C?
	je salvaInC
	jmp Error		#non è ne A,B,C ed inoltre è un numero 

	salvaInA:
	 cmpb $51,2(%esi)
	 je controlloUnitaA1		#ho decine=3 devo controllare le unità
	 jg controlloUnitaA2		#ho una decina >0 , controllo di avere nelle unità un numero >=0
	 jmp controlloUnaSolaCifraA	#vado a vedere se ho una sola cifra
	
	 controlloUnitaA1:
	    	cmpb $49,3(%esi)
			jge inserisciPienoA
			jmp controlloUnaSolaCifraA
	 controlloUnitaA2:
			cmpb $48,3(%esi)
			jl controlloUnaSolaCifraA
			jmp inserisciPienoA
	 controlloUnaSolaCifraA:
			cmpb $48,2(%esi)		#controllo di avere un numero>0
			jl inserisciPienoA		#se ho inserito qualcosa di sbagliato x ipotesi metto tutto il parcheggio pieno
			cmpb $10,3(%esi)		#guardo se ho \n se vero ho una sola cifra altrimenti mi salvo tutto
			je salvaUnaSolaCifraA
			movb 2(%esi),%bl		#sfrutto il registro bl per fare lo spostamento non so perchè non mi lascia farli tra i due valori
			movb %bl,3(%edi)
			movb 3(%esi),%bl
			movb %bl,4(%edi)
			movb $5,%dl			#metto il valore 5 per spostarmi alla riga successiva
			movb $48,12(%edi) 		#settore A non pieno
			jmp incrSalvattaggi
	 salvaUnaSolaCifraA:
		movb 2(%esi),%bl
		movb %bl,4(%edi)
		movb $48,3(%edi)
		movb $4,%dl			#mi sposterò di 4 per andare alla riga successiva
		movb $48,12(%edi) 		#settore A non pieno
		jmp incrSalvattaggi
	 inserisciPienoA:
		movb $49,12(%edi) 		#settore A pieno
		movb $51,3(%edi)		
		movb $49, 4(%edi)
		movb $5,%dl			#metto il valore 5 per spostarmi alla riga successiva
		jmp incrSalvattaggi
	salvaInB:
	 cmpb $51,2(%esi)
	 je controlloUnitaB1		#ho decine=3 devo controllare le unità
	 jg controlloUnitaB2		#ho una decina >0 , controllo di avere nelle unità un numero >=0
	 jmp controlloUnaSolaCifraB	#vado a vedere se ho una sola cifra
	
	 controlloUnitaB1:
		cmpb $49,3(%esi)
		jge inserisciPienoB
		jmp controlloUnaSolaCifraB
	 controlloUnitaB2:
		cmpb $48,3(%esi)
		jl controlloUnaSolaCifraB
		jmp inserisciPienoB
	 controlloUnaSolaCifraB:
		cmpb $48,2(%esi)		#controllo di avere un numero>0
		jl inserisciPienoB		#se ho inserito qualcosa di sbagliato x ipotesi metto tutto il parcheggio pieno
		cmpb $10,3(%esi)		#guardo se ho \n se vero ho una sola cifra altrimenti mi salvo tutto
		je salvaUnaSolaCifraB
		movb 2(%esi),%bl
		movb %bl,6(%edi)
		movb 3(%esi),%bl
		movb %bl,7(%edi)
		movb $5,%dl			#metto il valore 5 per spostarmi alla riga successiva
		movb $48,13(%edi) 		#settore B non pieno
		jmp incrSalvattaggi
	 salvaUnaSolaCifraB:
		movb 2(%esi),%bl
		movb %bl,7(%edi)
		movb $48,6(%edi)
		movb $4,%dl			#mi sposterò di 4 per andare alla riga successiva
		movb $48,13(%edi) 		#settore B non pieno
		jmp incrSalvattaggi
	 inserisciPienoB:
		movb $49,13(%edi) 		#settore B pieno
		movb $51,6(%edi)		
		movb $49,7(%edi)
		movb $5,%dl			#metto il valore 5 per spostarmi alla riga successiva
		jmp incrSalvattaggi
	salvaInC:
	 cmpb $50,2(%esi)
	 je controlloUnitaC1		#ho decine=2 devo controllare le unità
	 jg controlloUnitaC2		#ho una decina >2 , controllo di avere nelle unità un numero >=0
	 jmp controlloUnaSolaCifraC	#vado a vedere se ho una sola cifra
	
	 controlloUnitaC1:
		cmpb $52,3(%esi)
		jge inserisciPienoC
		jmp controlloUnaSolaCifraC
	 controlloUnitaC2:
		cmpb $48,3(%esi)
		jl controlloUnaSolaCifraC
		jmp inserisciPienoC
	 controlloUnaSolaCifraC:
		cmpb $48,2(%esi)		#controllo di avere un numero>0
		jl inserisciPienoC		#se ho inserito qualcosa di sbagliato x ipotesi metto tutto il parcheggio pieno
		cmpb $10,3(%esi)		#guardo se ho \n se vero ho una sola cifra altrimenti mi salvo tutto
		je salvaUnaSolaCifraC
		movb 2(%esi),%bl
		movb %bl,9(%edi)
		movb 3(%esi),%bl
		movb %bl,10(%edi)
		movb $5,%dl			#metto il valore 5 per spostarmi alla riga successiva
		movb $48,14(%edi) 		#settore C non pieno
		jmp incrSalvattaggi
	 salvaUnaSolaCifraC:
		movb 2(%esi),%bl
		movb %bl,10(%edi)
		movb $48,9(%edi)
		movb $4,%dl			#mi sposterò di 4 per andare alla riga successiva
		movb $48,14(%edi) 		#settore C non pieno
		jmp incrSalvattaggi
	 inserisciPienoC:
		movb $49,14(%edi) 		#settore C pieno
		movb $50,9(%edi)		
		movb $52, 10(%edi)
		movb $5,%dl			#metto il valore 5 per spostarmi alla riga successiva
		jmp incrSalvattaggi

	incrSalvattaggi:
 		incb %ch	#incremento di 1 i salvataggi
		jmp rigaNext
	



#FUNZIONAMENTO AUTOMATICO DEL SISTEMA
automatico:				 # è il modulo che permette di IN e OUT nei parcheggi
	#se la stringa è vuota, salto alla fine
	cmpb $0, (%esi)
	je end
	
	#inizializzo stringa di output con valori standard
	movb $45,2(%edi)
	movb $45,5(%edi)
	movb $45,8(%edi)
	movb $45,11(%edi)
	movb $10,15(%edi)
	movb $67,(%edi)	#chiudo le sbarre IN e OUT
	movb $67,1(%edi)

	
	inout:
     #controllo se è scritto 'I' oppure 'O' nel primo carattere
     cmpb $73, (%esi) #è guale a I?
     je in2			
     cmpb $79,(%esi)
     je out2
     jmp Error		#arrivo qua se il primo carattere non è ne I nè O --> ho una stringa sbagliata

    # parte degli IN-
    in2:
        # controllo se è scritto 'N' nel secondo carattere
        cmpb $78,1(%esi) 
        je in3
        jmp Error		#stringa sbagliata
    in3:
        # controllo se è scritto '-'  
        cmpb $45,2(%esi) 
        je inA			#vuoi entrare in A
        jmp Error		#stringa sbagliata
    inA:
        # controllo se è scritto 'A'  
        cmpb $65, 3(%esi) 
        je  ingressoA
        jmp inB
    inB:
        # controllo se è scritto 'B'
        cmpb $66, 3(%esi) 
        je ingressoB 
        jmp inC
    inC:
        # controllo se è scritto 'C'
        cmpb $67, 3(%esi) 
        je ingressoC
        jmp Error		#ho una stringa sbagliata conto quanti caratteri contiene 

    # parte degli OUT-
    out2:
        # controllo se è scritto 'U' 
        cmpb $85,1(%esi) 
        je out3
        jmp Error
    out3:
        # controllo se è scritto 'T'
        cmpb $84,2(%esi) 
        je out4
        jmp Error
    out4:
        # controllo se è scritto '-'
        cmpb $45,3(%esi) 
        je outA
        jmp Error
    outA:
        # controllo se è scritto 'A'
        cmpb $65,4(%esi) 
        je uscitaA 
        jmp outB
    outB:
        # controllo se è scritto 'B'
        cmpb $66,4(%esi) 
        je uscitaB
        jmp outC
    outC:
        # controllo se è scritto 'C'
        cmpb $67,4(%esi) 
        je uscitaC
        jmp Error
   
	#Modulo che fa la somma controllando che si possa entrare
	ingressoA:	#blocchetto IN-A		i valori di A stanno in 3-4 edi
     
	 #controllo di avere \n altrimenti ho una stringa sbagliata
	 cmpb $10,4(%esi)
	 jne Error		#ho una stringa sbagliata vado a vedere quanti caratteri ha

	 cmpb $49,12(%edi)	#se il bit di PienoA=1 allora non posso entrare
	 je Error

	 cmpb $51,3(%edi)
	 jne sommaSeparataA	#la decina NON è 3 non sarà pieno se entro
	 movb $49,12(%edi)	#se ho 3 per forza devo avere 0 e quindi se entro è pienoA
	 jmp sommaSeparataA
	 
	 sommaSeparataA:
		cmpb $57,4(%edi)	#l'unità di A vale 9'
		je incrementoDecineA
	   incb 4(%edi)		#incremento le unità
	   jmp apriSbarraIngresso
	 incrementoDecineA:
	  movb $48,4(%edi)	#0 unità
	  incb 3(%edi)		#incremento le decine
	  jmp apriSbarraIngresso
	ingressoB:	#blocchetto IN-B		i valori di B stanno in 6-7 edi
     
	 #controllo di avere \n altrimenti ho una stringa sbagliata
	 cmpb $10,4(%esi)
	 jne Error		#ho una stringa sbagliata vado a vedere quanti caratteri ha

	 cmpb $49,13(%edi)	#se il bit di PienoB=1 allora non posso entrare
	 je Error

	 cmpb $51,6(%edi)
	 jne sommaSeparataB	#la decina NON è 3 non sarà pieno se entro
	 movb $49,13(%edi)	#se ho 3 per forza devo avere 0 e quindi se entro è pienoB
	 jmp sommaSeparataB

	 sommaSeparataB:
		cmpb $57,7(%edi)	#l'unità di B vale 9'
		je incrementoDecineB
	   incb 7(%edi)		#incremento le unità
	   jmp apriSbarraIngresso
	 incrementoDecineB:
	  movb $48,7(%edi)	#0 unità
	  incb 6(%edi)		#incremento le decine
	  jmp apriSbarraIngresso
	ingressoC:	#blocchetto IN-C		i valori di C stanno in 9-10 edi
     
	 #controllo di avere \n altrimenti ho una stringa sbagliata
	 cmpb $10,4(%esi)
	 jne Error		#ho una stringa sbagliata vado a vedere quanti caratteri ha

	  cmpb $49,14(%edi)	#se il bit di PienoC=1 allora non posso entrare
	 je Error

	  cmpb $50,9(%edi)
	 jne sommaSeparataC	#la decina NON è 2 non sarà pieno se entro
	 cmpb $51,10(%edi)
	 jne sommaSeparataC	#l'unità non vale 3 quindi se enetro non diventa pieno'
	 movb $49,14(%edi)	#altrimenti vale 3 e se entro diventa pienoC
	 jmp sommaSeparataC

	 sommaSeparataC:
		cmpb $57,10(%edi)	#l'unità di C vale 9'
		je incrementoDecineC
	   incb 10(%edi)		#incremento le unità
	   jmp apriSbarraIngresso
	 incrementoDecineC:
	  movb $48,10(%edi)	#0 unità
	  incb 9(%edi)		#incremento le decine
	  jmp apriSbarraIngresso

	#Modulo che fa la sottrazione controllando che si possa uscire
	uscitaA:
	 #controllo di avere \n altrimenti ho una stringa sbagliata
	 cmpb $10,5(%esi)
	 jne Error		#ho una stringa sbagliata vado a vedere quanti caratteri ha

	 #casi possibili 00,01,X0,X9
	 cmpb $48, 3(%edi)
	 je isZeroUnitaA
	 cmpb $48, 4(%edi)
	 jne sottraiUnitaA
	 decb 3(%edi)
	 movb $57,4(%edi)
	 movb $48,12(%edi)
	 jmp apriSbarraUscita
	 isZeroUnitaA:	#qui entro se ho decina = 0
		cmpb $48, 4(%edi)
		je Error 	#ho 00
		jmp sottraiUnitaA		#ho 0X
	 sottraiUnitaA:
		decb 4(%edi)		#decremento di un unità A
		movb $48,12(%edi)
		jmp apriSbarraUscita
	uscitaB:
	 #controllo di avere \n altrimenti ho una stringa sbagliata
	 cmpb $10,5(%esi)
	 jne Error		#ho una stringa sbagliata vado a vedere quanti caratteri ha

	 #casi possibili 00,01,X0,X9
	 cmpb $48, 6(%edi)
	 je isZeroUnitaB
	 cmpb $48, 7(%edi)
	 jne sottraiUnitaB
	 decb 6(%edi)
	 movb $57,7(%edi)
	 movb $48,13(%edi)
	 jmp apriSbarraUscita
	 isZeroUnitaB:	#qui entro se ho decina = 0
		cmpb $48, 7(%edi)
		je Error 	#ho 00
		jmp sottraiUnitaB		#ho 0X
	 sottraiUnitaB:
		decb 7(%edi)		#decremento di un unità B
		movb $48,13(%edi)
		jmp apriSbarraUscita

	uscitaC:
	 #controllo di avere \n altrimenti ho una stringa sbagliata
	 cmpb $10,5(%esi)
	 jne Error		#ho una stringa sbagliata vado a vedere quanti caratteri ha

	 #casi possibili 00,01,X0,X9
	 cmpb $48, 9(%edi)
	 je isZeroUnitaC
	 cmpb $48, 10(%edi)
	 jne sottraiUnitaC
	 decb 9(%edi)
	 movb $57,10(%edi)
	 movb $48,14(%edi)
	 jmp apriSbarraUscita
	 isZeroUnitaC:	#qui entro se ho decina = 0
		cmpb $48, 10(%edi)
		je Error 	#ho 00
		jmp sottraiUnitaC		#ho 0X
	 sottraiUnitaC:
		decb 10(%edi)		#decremento di un unità C
		movb $48,14(%edi)
		jmp apriSbarraUscita

	
	#apertura sbarre
	apriSbarraIngresso:
		 movb $79,(%edi)			#apro la sbarra di entrata
		 movb $5,%dl			#metto il valore 5(IN-X\n) per spostarmi alla riga successiva 
		 jmp rigaNext
	apriSbarraUscita:
		 movb $79,1(%edi)			#apro la sbarra di uscita
		 movb $6,%dl			#metto il valore 6(OUT-X\n) per spostarmi alla riga successiva 
		 jmp rigaNext

	#modulo di combinazione errata
	Error:		
		movb $1,%dl	#metto il contacaratteri a 1 perchè uscendo da questo ciclo esi punterà a \n e quindi per andare alla riga successiva sommo un carattere
		loop:
		 addl $1,%esi			 #mando avanti bufferin di un carattere
         cmpb $10,(%esi)	 # finchè non trova '\n' continua a confrontare caratteri
         jne loop  
         jmp rigaNext    # quando trova '\n ' salta alla prossima riga



	
	
rigaNext:
	movb $0,%dh			#metto 0 in dh in modo che sommando edx a esi è come se sommassi solo dl
	addl %edx,%esi		#incremento per andare alla riga successiva del bufferin
	cmpb $3,%ch			#sono stati effettuati i 3 salvataggi?
	jl salvataggio		#se non sono stati effettuati i 3 salvataggi 

	incb %ch			#incremento di 1 ch per far vedere che ho finito i salvataggi nei parcheggi
	cmpb $4,%ch			#se ho appena finito di fare i salvataggi (ch vale 3 perchè è stato incrementato 3 volte per i parcheggi +1 adesso) vado in automatico senza crearmi una nuova riga di edi
	je automatico

	#altrimenti creo una nuova riga di edi se ho finito i salvataggi
	jmp copiaInfo

#permette di copiare i valori presenti in edi quali i valori delle macchine nei relativi parcheggi e i bit pieni nella nuova riga di edi che verrà poi usata
copiaInfo:	
	movl %edi, %ebx	#mi salvo l'indirizzo attuale di edi in ebx
	addl $16, %edi	#edi punta ad una nuova riga  di bufferout
	#mi copio i valori "vecchi" nella nuova riga
	movb 3(%ebx),%al	
	movb %al,3(%edi)
	movb 4(%ebx),%al
	movb %al,4(%edi)
	movb 6(%ebx),%al
	movb %al,6(%edi)
	movb 7(%ebx),%al
	movb %al,7(%edi)
	movb 9(%ebx),%al
	movb %al,9(%edi)
	movb 10(%ebx),%al
	movb %al,10(%edi)
	movb 12(%ebx),%al
	movb %al,12(%edi)
	movb 13(%ebx),%al
	movb %al,13(%edi)
	movb 14(%ebx),%al
	movb %al,14(%edi)
	jmp automatico
	
end:
	
	#metto /0 a fine stringa
	movl $0, (%edi)

	#scarico lo stack
	popl %esi
	popl %edi
	popl %ecx
	popl %ebx
	popl %eax
	popl %ebp
	
	ret


