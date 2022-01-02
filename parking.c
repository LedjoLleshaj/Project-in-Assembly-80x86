#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/time.h>

/* Inserite eventuali extern modules qui */

/* ************************************* */
extern void elaborazione(char in[], char out[]);

enum { MAXLINES = 200 };
enum { LIN_LEN = 5 };
enum { LOUT_LEN = 15 };


long long current_timestamp() {
    struct timespec tp;
    clock_gettime(CLOCK_REALTIME, &tp);
    /* te.tv_nsec nanoseconds divide by 1000 to get microseconds*/
    long long nanoseconds = tp.tv_sec * 1000LL + tp.tv_nsec; // caculate nanoseconds
    return nanoseconds;
}


int main(int argc, char* argv[]) {
    int i = 0;
    char bufferin[MAXLINES * LIN_LEN + 1];
    char line[1024];
    long long tic_c, toc_c, tic_asm, toc_asm;

    char bufferout_c[MAXLINES * LOUT_LEN + 1] = "";
    char bufferout_asm[MAXLINES * LOUT_LEN + 1] = "";

    FILE* inputFile = fopen(argv[1], "r");

    if (argc != 3)
    {
        fprintf(stderr, "Syntax ./test <input_file> <output_file>\n");
        exit(1);
    }

    if (inputFile == 0)
    {
        fprintf(stderr, "failed to open the input file. Syntax ./test <input_file> <output_file>\n");
        exit(1);
    }

    while (i < MAXLINES && fgets(line, sizeof(line), inputFile))
    {
        i = i + 1;
        strcat(bufferin, line);
    }

    bufferin[MAXLINES * LIN_LEN] = '\0';

    fclose(inputFile);


    /* ELABORAZIONE in C */
    tic_c = current_timestamp();
    

    //CODICE C
    
    int c = 0;                //per scorrere stringa di input bufferin
    int incr=0;                //conta il numero di caratteri presenti su ogni riga e viene sommata a c per andare alla riga successiva
    char tmpout[LOUT_LEN+2];        //stringa temporanea di output contiene l'output di una specifica riga e viene concatenata alla fine a bufferout
    int salvataggi = 0;            //vale 3 se ho inserito le auto sia in A,B,C
    int numeroRigaOutput=0;		//a che riga di output siamo
   
	//Inizializzo i settori come vuoti inizialemente
	tmpout[12] = '0';        
	tmpout[13] = '0';        
	tmpout[14] = '0';        
	
 do {
        if (bufferin[c] == 'A')                    //se ho inserito A-..
        {
            incr = 5;                    //solitamente incremento di 5 per andare alla riga successiva perchè X-AB\n sono che caratteri
            if ((bufferin[c + 2] == '3' && bufferin[c + 3] >= '1') || (bufferin[c + 2] > '3'&& bufferin[c+3]!='\n')) {        //se ho la casella della decina>=3 e quella delle unità>=1 ho inserito un valore non accettato
                tmpout[12] = '1';        //settore A pieno
                tmpout[3] = '3';        //metto tutti i settori occupati rispettivamente decine e unità    
                tmpout[4] = '1';
            }
            else {
                if (bufferin[c + 2] > 0 && bufferin[c + 3] == '\n') {    //se ho una sola cifra e poi vado a capo quindi
                    tmpout[3] = '0';                //avrò 0 decine
                    tmpout[4] = bufferin[c + 2];            //e le unità saranno il numero inserito
                    incr = 4;                    //avendo una cifra in meno devo incrementare di 4 e non di 5 per andare alla riga successiva
                }
                else {                            //se non si sono verificati casi limite
                    tmpout[3] = bufferin[c + 2];            //mi salvo le decine
                    tmpout[4] = bufferin[c + 3];            //mi salvo le unità
                }

            }
            salvataggi++;
        }
        else if (bufferin[c + 0] == 'B') {                //i commenti sono gli stessi che per A
            incr = 5;
            if ((bufferin[c + 2] == '3' && bufferin[c + 3] >= '1') || (bufferin[c + 2] > '3'&& bufferin[c+3]!='\n')) {
                tmpout[13] = '1';        //settore B pieno
                tmpout[6] = '3';
                tmpout[7] = '1';
            }
            else {
                if (bufferin[c + 2] > 0 && bufferin[c + 3] == '\n') {    //una sola cifra
                    tmpout[6] = '0';    //decine
                    tmpout[7] = bufferin[c + 2];
                    incr = 4;
                }
                else {
                    tmpout[6] = bufferin[c + 2];        //mi salvo i posti di B
                    tmpout[7] = bufferin[c + 3];
                }

            }
            salvataggi++;

        }
        else if (bufferin[c + 0] == 'C') {            //i commenti sono gli stessi che per A eccetto che ho max posti 24 per C
            incr = 5;
            if ((bufferin[c + 2] == '2' && bufferin[c + 3] >= '4') || (bufferin[c + 2] > '2' && bufferin[c+3]!='\n')) {
                tmpout[14] = '1';        //settore C pieno
                tmpout[9] = '2';
                tmpout[10] = '4';
            }
            else {
                if (bufferin[c + 2] > 0 && bufferin[c + 3] == '\n') {    //una sola cifra
                    tmpout[9] = '0';    //decine
                    tmpout[10] = bufferin[c + 2];
                    incr = 4;
                }
                else {
                    tmpout[9] = bufferin[c + 2];        //mi salvo i posti di A
                    tmpout[10] = bufferin[c + 3];
                }

            }
            salvataggi++;            //incremento la mia variabile salvataggi che mi dice in quanti settori fino ad adesso ho salvato le macchine 
        }
        c = c + incr;
    } while (salvataggi < 3);            //ripeto finchè non ho salvato in tutti e tre i settori

    tmpout[2] = '-';
    tmpout[5] = '-';
    tmpout[8] = '-';
    tmpout[11] = '-';
    tmpout[15] = '\n';
    tmpout[16]='\0';
    while (bufferin[c]) {
        //inizializzo stringa di output con valori standard in modo che se ci sono dei casi in cui non entro negli if restituisco questi valori
        tmpout[0] = 'C';
        tmpout[1] = 'C';
       
        

        if (bufferin[c] == 'I' && bufferin[c + 1] == 'N' && bufferin[c + 2] == '-' && bufferin[c+4]=='\n')        //qualcuno vuole entrare IN-X\n...
        {
            if (bufferin[c + 3] == 'A') {                            //se ha specificato A
                if (tmpout[12]!='1') {    //c'è posto per entrare in A il bit di pienoA non è attivo
                    if (tmpout[3] == '3' && tmpout[4] == '0')            //se è l'ultimo posto di A
                        tmpout[12] = '1';                    //settore A pieno
                    else tmpout[12] = '0';                        //il settore A non è pieno
                    
                    //sommo (Ho due caselle separate per unità e decine) e quindi devo fare i vari casi
                    if (tmpout[4] == '9') {
                        tmpout[4] = '0';
                        tmpout[3] += 1;
                    }
                    else
                        tmpout[4] += 1;        //incremento le unità
                    tmpout[0] = 'O';        //apro la sbarra in entrata 
                }

            }
            if (bufferin[c + 3] == 'B') {
                if (tmpout[13]!='1') {    //c'è posto per entrare in B
                    if (tmpout[6] == '3' && tmpout[7] == '0')        //se è l'ultimo posto di B
                        tmpout[13] = '1';        //settore B pieno
                    else tmpout[13] = '0';    //il settore B non è pieno
                    //sommo
                    if (tmpout[7] == '9') {
                        tmpout[7] = '0';
                        tmpout[6] += 1;
                    }
                    else
                        tmpout[7] += 1;

                    tmpout[0] = 'O';        //apro la sbarra in entrata
                }
            }
            if (bufferin[c + 3] == 'C') {
                if (tmpout[14]!='1') {    //c'è posto per entrare in C
                    if (tmpout[9] == '2' && tmpout[10] == '3')        //se è l'ultimo posto di C
                        tmpout[14] = '1';        //settore C pieno
                    else tmpout[14] = '0';        //il settore C non è pieno
                    //sommo
                    if (tmpout[10] == '9') {
                        tmpout[10] = '0';
                        tmpout[9] += 1;
                    }
                    else
                        tmpout[10] += 1;

                    tmpout[0] = 'O';        //apro la sbarra in entrata
                }

            }
            incr = 5; //IN-X/n sono 5 caratteri 
        }
        else if (bufferin[c] == 'O' && bufferin[c + 1] == 'U' && bufferin[c + 2] == 'T' && bufferin[c + 3] == '-' && bufferin[c+5]=='\n') //qualcuno vuole uscire
        {
            if (bufferin[c + 4] == 'A') {                    //se ha specificato il settore A
                if (tmpout[3] > '0' || tmpout[4] > '0')        //il numero di macchine in A è >0 quindi ci sono maccchine e quindi si può uscire altrimenti c'era errore
                {
                    tmpout[12] = '0';                //imposto a 0 perchè se è pieno ed esce qualcuno rimane posto oppure avevo già posto e non cambia nulla
                    //faccio sottrazione di un auto
                    if (tmpout[3] == '0' && tmpout[4] != '0') {
                        tmpout[4] -= 1;
                    }
                    else if (tmpout[4] == '0') {
                        tmpout[4] = '9';
                        tmpout[3] -= 1;
                    }
                    else 
                        tmpout[4] -= 1;
                    tmpout[1] = 'O';        //apro la sbarra in uscita
                }
            }
            if (bufferin[c + 4] == 'B') {
                if (tmpout[6] > '0' || tmpout[7] > '0')        //il numero è>0 quindi ci sono maccchine
                {
                    tmpout[13] = '0';        //c'è posto 
                    //faccio sottrazione di un auto
                    if (tmpout[6] == '0' && tmpout[7] != '0') {
                        tmpout[7] -= 1;
                    }
                    else if (tmpout[7] == '0') {
                        tmpout[7] = '9';
                        tmpout[6] -= 1;
                    }
                    else 
                        tmpout[7] -= 1;
                    tmpout[1] = 'O';        //apro la sbarra in uscita
                }
            }
            if (bufferin[c + 4] == 'C') {
                if (tmpout[9] > '0' || tmpout[10] > '0')        //il numero è>0 quindi ci sono maccchine
                {
                    tmpout[14] = '0';
                    //faccio sottrazione di un auto
                    if (tmpout[9] == '0' && tmpout[10] != '0') {
                        tmpout[10] -= 1;
                    }
                    else if (tmpout[10] == '0') {
                        tmpout[10] = '9';
                        tmpout[9] -= 1;
                    }
                    else 
                        tmpout[10] -= 1;
                    tmpout[1] = 'O';        //apro la sbarra in uscita
                }
            }
            incr = 6; //l'incremento vale 6 OUT-X\n
        }
        else {            //ho una stringa sbagliata con un numero indefinito di caratteri li conto per salvare l'incremento
            incr = c;                                    //in che posizione sono ora
            for (incr;bufferin[incr] != '\n' && bufferin[incr] != '\0';incr++);         //incr vale quanti caratteri mi devo spostare per raggiungere la nuova riga
            incr = incr +1- c;                    //distanza dalla nuova riga

        }
        c = c + incr;                            //punto al primo carattere della nuova riga
	numeroRigaOutput++;
	//Mi salvo i bit di PienoA,B,C
	bufferout_c[(numeroRigaOutput*17)+12]=tmpout[12];
	bufferout_c[(numeroRigaOutput*17)+12]=tmpout[13];
	bufferout_c[(numeroRigaOutput*17)+12]=tmpout[14];
	
    strcat(bufferout_c, tmpout);                    //concateno la mia stringa temporanea con quella totale che contiene tutte le uscite
    }
    

    /* questo pezzo di codice è solo una base di partenza per fare dei check sui dati */
    /*
    int c = 0;
    while ( bufferin[c] != '\0') {
      printf( "%c", bufferin[c] );
      strncat( bufferout_asm, &bufferin[c], 1);
      c = c + 1 ;
    }
    */

    toc_c = current_timestamp();

    long long c_time_in_nanos = toc_c - tic_c;

    /* FINE ELABORAZIONE C */


    /* INIZIO ELABORAZIONE ASM */
    

    tic_asm = current_timestamp();

    /* Assembly inline:
    Inserite qui il vostro blocco di codice assembly inline o richiamo a funzioni assembly.
    Il blocco di codice prende come input 'bufferin' e deve restituire una variabile stringa 'bufferout_asm' che verrà poi salvata su file. */
	elaborazione(bufferin,bufferout_asm);

    toc_asm = current_timestamp();

    long long asm_time_in_nanos = toc_asm - tic_asm;
	

    /* FINE ELABORAZIONE ASM */


    printf("C time elapsed: %lld ns\n", c_time_in_nanos);
    printf("ASM time elapsed: %lld ns\n", asm_time_in_nanos);

     /*Salvataggio dei risultati C 
    FILE* file;
    file = fopen("testout_c.txt", "w");
    fprintf(file, "%s", bufferout_c);
    fclose(file);*/

    
    // Salvataggio dei risultati ASM 
    FILE* outputFile;
    outputFile = fopen(argv[2], "w");
    fprintf(outputFile, "%s", bufferout_asm);
    fclose(outputFile);

    return 0;
}


