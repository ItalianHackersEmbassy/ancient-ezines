struct ip {
#if defined(__i386__)
	u_char	ip_hl:4,
		ip_v:4;
#else
#error Please modify lcompat.h to support your CPU.
#endif
	u_char	ip_tos;
	short	ip_len;
	u_short	ip_id;
	short	ip_off;
#define	IP_DF 0x4000
#define	IP_MF 0x2000
#define	IP_OFFMASK 0x1fff
	u_char	ip_ttl;
	u_char	ip_p;
	u_short	ip_sum;
	struct	in_addr ip_src,ip_dst;
};

#define ICMP_MINLEN			8
#define ICMP_UNREACH			3
#define ICMP_UNREACH_NET		0
#define ICMP_UNREACH_PROTOCOL		2
#define ICMP_UNREACH_PORT		3
#define ICMP_UNREACH_HOST		1

struct icmp {
	u_char	icmp_type;
	u_char	icmp_code;
	u_short	icmp_cksum;
	union {
		u_char ih_pptr;
		struct in_addr ih_gwaddr;
		struct ih_idseq {
			n_short	icd_id;
			n_short	icd_seq;
		} ih_idseq;
		int ih_void;

		struct ih_pmtu {
			n_short ipm_void;    
			n_short ipm_nextmtu;
		} ih_pmtu;
	} icmp_hun;
#define	icmp_pptr	icmp_hun.ih_pptr
#define	icmp_gwaddr	icmp_hun.ih_gwaddr
#define	icmp_id		icmp_hun.ih_idseq.icd_id
#define	icmp_seq	icmp_hun.ih_idseq.icd_seq
#define	icmp_void	icmp_hun.ih_void
#define	icmp_pmvoid	icmp_hun.ih_pmtu.ipm_void
#define	icmp_nextmtu	icmp_hun.ih_pmtu.ipm_nextmtu
	union {
		struct id_ts {
			n_time its_otime;
			n_time its_rtime;
			n_time its_ttime;
		} id_ts;
		struct id_ip  {
			struct ip idi_ip;
		} id_ip;
		u_long	id_mask;
		char	id_data[1];
	} icmp_dun;
#define	icmp_otime	icmp_dun.id_ts.its_otime
#define	icmp_rtime	icmp_dun.id_ts.its_rtime
#define	icmp_ttime	icmp_dun.id_ts.its_ttime
#define	icmp_ip		icmp_dun.id_ip.idi_ip
#define	icmp_mask	icmp_dun.id_mask
#define	icmp_data	icmp_dun.id_data
};

struct bsd_udphdr {
	u_short	uh_sport;
	u_short	uh_dport;
	short	uh_ulen;
	u_short	uh_sum;
};
