/************************************************************************
 *									*
 * fakedns - Copyright 2008 Matteo Croce <rootkit85@yahoo.it>		*
 * A fake DNS server that always replies the same IP for every hostname *
 *									*
 ***********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

const u_int8_t reply[] = {
	0xc0, 0x0c, 0x00, 0x01,
	0x00, 0x01, 0x00, 0x01,
	0x00, 0x00, 0x00, 0x04,
	192, 168, 1, 1	// IP goes here
};

int main(int argc, char *argv[])
{
	u_int8_t buffer[512] = {0};
	int sockfd, recv;
	struct sockaddr_in sin;
	struct sockaddr_in from;
	socklen_t sinsize = sizeof(from);

	if((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
		perror("socket()");
		return 1;
	}

	sin.sin_family = AF_INET;
	sin.sin_addr.s_addr = INADDR_ANY;
	sin.sin_port = htons(53);
	memset(&sin.sin_zero, 0, 8);

	if(bind(sockfd, (const struct sockaddr *)&sin, sizeof(sin)) == -1) {
		perror("bind()");
		return 1;
	}

	if(fork())
		return 0;

	while(1) {
		recv = recvfrom(sockfd, buffer, 512, 0, (struct sockaddr *)&from, &sinsize);
		if(recv < 0) {
			perror("recv");
			return 1;
		}

		memcpy(buffer + recv, reply, 16);

		buffer[2] = 0x81; // DNS response
		buffer[3] = 0x80;
		buffer[7] = 1;

		recv = sendto(sockfd, buffer, recv + 16, 0, (struct sockaddr *)&from, sinsize);
		if(recv < 0) {
			perror("sendto");
			return 1;
		}
	}
	return 0;
}
