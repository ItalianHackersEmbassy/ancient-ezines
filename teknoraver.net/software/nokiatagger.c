/*
 *  nokiatagger - a tool to tag mp4 files for Nokia phones
 *  Copyright (C) 2007  Matteo Croce  <rootkit85@yahoo.it>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 *   .""`.     Matteo Croce <matteo@openwrt.org>
 *  : :"  :    proud Debian admin and user
 *  `. `"`
 *    `-  Debian - when you have better things to do than fix a system
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define GENRES_LENGTH 80

char *genres[] = {
	"Blues", "Classic Rock", "Country", "Dance",
	"Disco", "Funk", "Grunge", "Hip-Hop",
	"Jazz", "Metal", "New Age", "Oldies",
	"Other", "Pop", "R&B", "Rap",
	"Reggae", "Rock", "Techno", "Industrial",
	"Alternative", "Ska", "Death Metal", "Pranks",
	"Soundtrack", "Euro-Techno", "Ambient", "Trip-Hop",
	"Vocal", "Jazz+Funk", "Fusion", "Trance",
	"Classical", "Instrumental", "Acid", "House",
	"Game", "Sound Clip", "Gospel", "Noise",
	"AlternRock", "Bass", "Soul", "Punk",
	"Space", "Meditative", "Instrumental Pop", "Instrumental Rock",
	"Ethnic", "Gothic", "Darkwave", "Techno-Industrial",
	"Electronic", "Pop-Folk", "Eurodance", "Dream",
	"Southern Rock", "Comedy", "Cult", "Gangsta",
	"Top 40", "Christian Rap", "Pop/Funk", "Jungle",
	"Native American", "Cabaret", "New Wave", "Psychadelic",
	"Rave", "Showtunes", "Trailer", "Lo-Fi",
	"Tribal", "Acid Punk", "Acid Jazz", "Polka",
	"Retro", "Musical", "Rock & Roll", "Hard Rock"
};

void print_genres(void)
{
	int i;
	for(i = 0; i < GENRES_LENGTH; i++)
		printf("\t%s\n", genres[i]);
	exit(0);
}

void usage(char *name)
{
	fprintf(stderr, "usage: %s [options] <filename>\n\n"
			"\t-t\twrite title\n"
			"\t-a\twrite author\n"
			"\t-A\twrite album\n"
			"\t-y\twrite year\n"
			"\t-c\twrite comment\n"
			"\t-g\twrite genre\n\n"
			"\t-l\tprints list of genres and quits\n\n"
			"Written by Matteo Croce <rootkit85@yahoo.it>\n"
			, name);
	exit(0);
}

#define TAG_LENGTH 129

int main(int argc, char *argv[])
{
	char *myt = 0;
	char *mya = 0;
	char *myA = 0;
	char *myy = 0;
	char *myc = 0;
	unsigned char myg = 0;

	char tag[TAG_LENGTH];
	char *title = tag + 4;
	char *author = title + 30;
	char *album = author + 30;
	char *year = album + 30;
	char *comment = year + 4;
	unsigned char *genre = (unsigned char *)comment + 30;

	int c;
	opterr = 0;

	if(argc <= 1)
		usage(argv[0]);

	while((c = getopt(argc, argv, "t:a:A:y:c:g:hl")) != -1)
		switch(c) {
		case 't':
			myt = optarg;
			break;
		case 'a':
			mya = optarg;
			break;
		case 'A':
			myA = optarg;
			break;
		case 'y':
			myy = optarg;
			break;
		case 'c':
			myc = optarg;
			break;
		case 'g': {
			int i;
			for(i = 0; i < GENRES_LENGTH; i++)
				if(!strcasecmp(optarg, genres[i])) {
					myg = (unsigned char)i;
					break;
				}
			if(!myg)
				fprintf(stderr, "Unknown genre: \"%s\"\n", optarg);
		}
			break;
		case 'l':
			print_genres();
		case '?':
		case 'h':
			usage(argv[0]);
		}

		if(optind == argc - 1) {
			const char magic[4] = "\x1cTAG";
			int file;
			if(myt || mya || myA || myy || myc || myg)
				file = open(argv[optind], O_RDWR);
			else
				file = open(argv[optind], O_RDONLY);
			if(file == -1) {
				perror("open");
				return 1;
			}
			lseek(file, -TAG_LENGTH, SEEK_END);
			read(file, &tag, sizeof(tag));
			if(strncmp(tag, magic, 4)) {
				lseek(file, 0, SEEK_END);
				strncpy(tag, magic, 4);
				bzero(tag + 4, TAG_LENGTH - 4);
				*genre = 0xc;
			} else
				lseek(file, -TAG_LENGTH, SEEK_END);
			if(myt)
				strncpy(title, myt, 30);
			if(mya)
				strncpy(author, mya, 30);
			if(myA)
				strncpy(album, myA, 30);
			if(myy)
				strncpy(year, myy, 4);
			if(myc)
				strncpy(comment, myc, 30);
			if(myg)
				*genre = myg;

			printf(	"%s tags:\n"
				"Title:\t\t%.30s\n"
				"Author:\t\t%.30s\n"
				"Album:\t\t%.30s\n"
				"Year:\t\t%.4s\n"
				"Comment:\t%.30s\n"
				"Genre:\t\t%s\n",
				argv[optind], title, author,
				album, year, comment,
				*genre < GENRES_LENGTH ? genres[*genre] : "");

			if(myt || mya || myA || myy || myc || myg)
				write(file, &tag, TAG_LENGTH);
			close(file);
		} else
			usage(argv[0]);
	return 0;
}
