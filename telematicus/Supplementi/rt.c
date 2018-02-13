#include <stdio.h>
#include <string.h>

#define TRUE      1
#define FALSE     0
#define SEEK_SET  0
#define VERSION   0.70
#define MAX_PAGE  99

#define CLS    "\033[2J"
#define CLL    "\033[K"
#define HEAD   "\033[0;30;47m"
#define TEXT   "\033[1;33;44m"
#define DEF    "\033[0m"
#define NUM    "\033[0;31;47m"

#define goline(x) (void)printf("\033[%d;1H",(x))
#define head()    (void)printf(HEAD)
#define text()    (void)printf(TEXT)
#define num(x)    (void)printf(NUM); (void)printf("\033[24;1H%2d",(x))
#define reset()   off = 0; (void)printf(HEAD); (void)printf("\033[24;1H  ");
#define pag()     (void)printf("\033[1;71H")

char     blank[81];           /* per azzerare una riga */
long     index[MAX_PAGE];     /* l'offset di ogni pagina; in [0] il # pag. */
int      art[MAX_PAGE];       /* la pagina iniziale di ogni articolo */
FILE     *fp;
long     size;

void readpar(int argc, char * argv[], char * filename);
void titolo (char * fil, int vol, int num, int anno, int pagina);
void leggi  (int pagina);
void creaindex (void);
void stampa (void);

int main(int argc, char * argv[]) {

   short i;
   int   status;
   char  filename[81], line[83], fil[9], c;
   int   anno, vol, num, pagina;
   int   off;               /* l'offset da contare per i comandi con nn */

   for (i=0; i<81; i++) blank[i]=' ';
   for (i=0; i<MAX_PAGE; i++) index[i] = art[i] = 0;

   readpar(argc, argv, filename);

   if ((fp = fopen(filename,"rt")) == NULL) {
      (void) printf("Non posso aprire il file %s",filename);
      exit(2);
   }
   fgets (line, 82, fp);
   if ((status = sscanf(line,
         " #### %s - Telematicus - Volume %d - Numero %d - Anno %d - %d pag.",
         fil, &vol, &num, &anno, index)) != 5) {
      (void) printf("Il file %s non e` del formato corretto", filename);
      exit(3);
   }

   fil[8]='\0';
   pagina = 1; off=0;
   creaindex();      /* riempiamo i vettori index[] e art [] */
   titolo(fil+5, vol, num, anno, pagina);

   for (;;) {
      if (!off) leggi(pagina);
      c = getch();
      switch(c) {
      case ' ': case 'n': case 'N':
         if (off == 0) off = 1; pagina += off; reset();
         if (pagina > index[0]) pagina = index[0]; break;
      case 'b': case 'B':
         if (off == 0) off = 1; pagina -= off; reset();
         if (pagina < 1) pagina = 1; break;
      case 'g': case 'G':
         if (off <= index[0] ) pagina = off; reset(); break;
      case 'q': case 'Q':
         (void) printf(DEF);
         exit (0);
      case 't': case 'T':
         pagina = 1; reset(); break;
      case 'e': case 'E':
         pagina = index[0]; reset(); break;
      case 'p': case 'P':
         reset(); stampa(); break;
      case 's': case 'S':
         if (pagina != index[0]) {
            for (i = 0; art[i] <= pagina; ) i++; pagina = art[i];
         }
         reset(); break;
      case 'i': case 'I':
         pagina = 2; reset(); break;
      case 'j': case 'J':
         pagina = art[off]; reset();
         if ((pagina>index[0]) || (pagina<1)) pagina = 2; break;
      case 'r': case 'R':
         titolo(fil+5, vol, num, anno, pagina); reset(); break;
      case '0': case '1': case '2': case '3': case '4':
      case '5': case '6': case '7': case '8': case '9':
         off *= 10; off %= 100; off += (c-48); num(off); break;
      default:
         reset(); break;
      }
   }
}

/*.........................................................................*/

void readpar(int argc, char ** argv, char * filename) {
   int status;

   switch(argc) {
   case 1:
      do {
         (void) printf("nome file da leggere (con ext)? ");
         status = scanf("%s",filename);
      } while (status != 1);
      break;
   case 2:
      (void) strcpy(filename,argv[1]);
      break;
   default:
      (void) printf("Uso: rt [nome_file]");
      exit (1);
   }
}

/*.........................................................................*/

void titolo (char * fil, int vol, int num, int anno, int pagina) {

   (void) printf(DEF); (void) printf(CLS);
   goline(1);
   head();
   (void) printf("####    Telematicus %s - Volume %2d - Numero %2d - Anno %4d\
 - Pagina  %2d    ####", fil, vol, num, anno, pagina);
   goline(24); (void) printf(CLL);
   (void) printf("   (N)ext (B)ack (T)op (E)nd (G)o (J)ump (S)kip (P)rint \
(I)ndex (R)edraw (Q)uit");
   text();
}

/*.........................................................................*/

void leggi (int pagina) {

   char  riga[83];
   int   i, l, status;

   status = fseek(fp,index[pagina],SEEK_SET);
   head(); pag(); printf("%2d",pagina); text();

   for (i=0; i<22; i++) {
      goline(i+2);
      l = strlen(fgets(riga,82,fp));
      strncpy(riga+l-1,blank,81-l);
      fwrite(riga,1,80,stdout);
   }
}

/*.........................................................................*/

void creaindex (void) {

   int i, j, num, status, pag;
   char riga[83];

   for (j=1; j<= index[0]; j++) {   /* per ogni pagina ... */
      index[j] = ftell(fp);
      if (j != 2) 
         for (i=1; i<=22; i++) fgets(riga, 82, fp);
		else
         for (i=1; i<=22; i++) {
            fgets(riga, 82, fp);
            if ((status = sscanf(riga," [%d]  %*70c%d",&num,&pag)) == 2) 
               art[num] = pag;
         }
   }
   art[0] = 2;
   art[num+1] = index[0]; /* l'ultima pagina */
}

/*.........................................................................*/

void stampa (void) {
   /* to be done */
}
