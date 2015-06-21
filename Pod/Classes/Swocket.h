//
//  Swocket.h
//  Pods
//
//  Created by Joakim Gyllström on 2015-06-19.
//
//

#ifndef Swocket_h
#define Swocket_h

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <signal.h>

void sigchld_handler(int s);
void *get_in_addr(struct sockaddr *sa);

int swocket_connect(const char * port, const char * host);

#endif /* Swocket_h */
