#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <linux/filter.h>
#include <linux/if_packet.h>
#include <linux/if_ether.h>
#include <linux/if_arp.h>
#include <linux/ip.h>
#include <linux/tcp.h>

#define BUF_SIZE 2048

void print_ip_address(const unsigned char *ip) {
    printf("%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]);
}

int handle_packet(void* buffer, int length) {
    if(length < sizeof(struct ethhdr)) return 1;

    struct ethhdr *eth = (struct ethhdr *)buffer;
    struct iphdr *ip = (struct iphdr *)(buffer + sizeof(struct ethhdr));

    // If not TCP, ignore
    if (ip->protocol != IPPROTO_TCP) {
        return 1;
    }

    struct tcphdr *tcp = (struct tcphdr *)(buffer + sizeof(struct ethhdr) + ip->ihl * 4);

    printf("[ TCP ]: ");
    print_ip_address((unsigned char *)&ip->saddr);
    printf(":%d", ntohs(tcp->source));
    printf(" -> ");
    print_ip_address((unsigned char *)&ip->daddr);
    printf(":%d", ntohs(tcp->dest));
    printf("\n");

    return 0;
}

void set_bpf_filter(int sock) {
    uint32_t ip = ntohl(inet_addr("142.250.74.46"));
    struct sock_filter bpf_code[] = {
        { BPF_LD  | BPF_H   | BPF_ABS, 0, 0, 0x0000000c }, // A = packet header
        { BPF_JMP | BPF_JEQ | BPF_K,   0, 2, ETH_P_IP },   // Check for packet header
        { BPF_LD  | BPF_W   | BPF_ABS, 0, 0, 0x0000001e }, // Load IP
        { BPF_JMP | BPF_JEQ | BPF_K,   0, 1, ip },         // If IP == target IP, allow packet
        { BPF_RET | BPF_K,             0, 0, 0x00040000 }, // Allow
        { BPF_RET | BPF_K,             0, 0, 0x00000000 }  // Reject
    };

    struct sock_fprog bpf = {
        .len = sizeof(bpf_code) / sizeof(bpf_code[0]),
        .filter = bpf_code,
    };

    // Attach the BPF filter to the socket
    if (setsockopt(sock, SOL_SOCKET, SO_ATTACH_FILTER, &bpf, sizeof(bpf)) < 0) {
        perror("setsockopt SO_ATTACH_FILTER");
        close(sock);
        exit(EXIT_FAILURE);
    }
}

int main() {
    int sock = 0;
    struct ifreq ifr = {};
    struct sockaddr_ll sll = {};
    char buffer[BUF_SIZE] = {};
    int bytes_received = 0;

    // Create a raw socket
    sock = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
    if (sock < 0) {
        perror("socket");
        exit(EXIT_FAILURE);
    }

    // Get the interface index
    strncpy(ifr.ifr_name, "enp0s1", IFNAMSIZ);
    if (ioctl(sock, SIOCGIFINDEX, &ifr) < 0) {
        perror("ioctl SIOCGIFINDEX");
        close(sock);
        exit(EXIT_FAILURE);
    }

    set_bpf_filter(sock);

    // Bind the socket to the interface
    sll.sll_family = AF_PACKET;
    sll.sll_ifindex = ifr.ifr_ifindex;
    sll.sll_protocol = htons(ETH_P_ALL);
    if (bind(sock, (struct sockaddr *)&sll, sizeof(sll)) < 0) {
        perror("bind");
        close(sock);
        exit(EXIT_FAILURE);
    }

    // Set the socket to promiscuous mode
    struct packet_mreq mreq = {};
    mreq.mr_ifindex = ifr.ifr_ifindex;
    mreq.mr_type = PACKET_MR_PROMISC;
    if (setsockopt(sock, SOL_PACKET, PACKET_ADD_MEMBERSHIP, &mreq, sizeof(mreq)) < 0) {
        perror("setsockopt PACKET_ADD_MEMBERSHIP");
        close(sock);
        exit(EXIT_FAILURE);
    }

    // Receive packets
    while (1) {
        bytes_received = recvfrom(sock, buffer, BUF_SIZE, 0, NULL, NULL);
        if (bytes_received < 0) {
            perror("recvfrom");
            close(sock);
            exit(EXIT_FAILURE);
        }

        if(handle_packet(buffer, bytes_received) == 1) {
            printf("[ IGN ]: %d bytes\n", bytes_received);
        }
    }

    close(sock);
    return 0;
}