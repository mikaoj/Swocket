//
//  Swocket.c
//  Pods
//
//  Created by Joakim Gyllström on 2015-06-19.
//
//

#include "Swocket.h"

void sigchld_handler(int s) {
    while(waitpid(-1, NULL, WNOHANG) > 0);
}

void *get_in_addr(struct sockaddr *sa) {
    if (sa->sa_family == AF_INET) {
        return &(((struct sockaddr_in*)sa)->sin_addr);
    }
    return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

int swocket_connect(const char * port, const char * host) {
    int sockfd;
    struct addrinfo hints, *servinfo, *p;
    int rv;
    char s[INET6_ADDRSTRLEN];

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    if ((rv = getaddrinfo(host, port, &hints, &servinfo)) != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        return -1;
    }
    
    // loop through all the results and connect to the first we can
    for(p = servinfo; p != NULL; p = p->ai_next) {
        if ((sockfd = socket(p->ai_family, p->ai_socktype,
                             p->ai_protocol)) == -1) {
            perror("client: socket");
            continue; }
        if (connect(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
            close(sockfd);
            perror("client: connect");
            continue; }
        break; }
    if (p == NULL) {
        fprintf(stderr, "client: failed to connect\n");
        return -1;
    }
    inet_ntop(p->ai_family, get_in_addr((struct sockaddr *)p->ai_addr), s, sizeof s);
    printf("Connected to %s with socket descriptor: %d\n", s, sockfd);
    freeaddrinfo(servinfo); // all done with this structure
    
    return sockfd;
}

void swocket_close(int sockfd) {
    printf("Closing socket descriptor: %d\n", sockfd);
    close(sockfd);
}

ssize_t swocket_send(int sockfd, const void *buffer, ssize_t length) {
    printf("Sending to: %d\n", sockfd);
    ssize_t result = send(sockfd, buffer, length, 0);
    if (result == -1) {
        printf("Oh dear, something went wrong with read()! %s\n", strerror(errno));
    }
    
    return result;
}
