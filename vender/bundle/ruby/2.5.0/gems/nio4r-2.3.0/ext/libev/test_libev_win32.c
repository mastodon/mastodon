  // a single header file is required
  #include <ev.h>
   #include <stdio.h>
   #include <io.h>

   // every watcher type has its own typedef'd struct
   // with the name ev_TYPE
   ev_io stdin_watcher;
   ev_timer timeout_watcher;

   // all watcher callbacks have a similar signature
   // this callback is called when data is readable on stdin
   static void
   stdin_cb (EV_P_ ev_io *w, int revents)
   {
     puts ("stdin ready or done or something");
     // for one-shot events, one must manually stop the watcher
     // with its corresponding stop function.
     //ev_io_stop (EV_A_ w);

     // this causes all nested ev_loop's to stop iterating
     //ev_unloop (EV_A_ EVUNLOOP_ALL);
   }

   // another callback, this time for a time-out
   static void
   timeout_cb (EV_P_ ev_timer *w, int revents)
   {
     puts ("timeout");
     // this causes the innermost ev_loop to stop iterating
     ev_unloop (EV_A_ EVUNLOOP_ONE);
   }



   #include <winsock.h>

#include <stdlib.h>
#include <iostream>
   int get_server_fd()
   {

  //----------------------
  // Initialize Winsock.
  WSADATA wsaData;
  int iResult = WSAStartup(MAKEWORD(2,2), &wsaData);
  if (iResult != NO_ERROR) {
    printf("Error at WSAStartup()\n");
    return 1;
  }

  //----------------------
  // Create a SOCKET for listening for
  // incoming connection requests.
  SOCKET ListenSocket;
  ListenSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (ListenSocket == INVALID_SOCKET) {
    printf("Error at socket(): %ld\n", WSAGetLastError());
    WSACleanup();
    return 1;
  }
  printf("socket returned %d\n", ListenSocket);

  //----------------------
  // The sockaddr_in structure specifies the address family,
  // IP address, and port for the socket that is being bound.
  sockaddr_in service;
  service.sin_family = AF_INET;
  service.sin_addr.s_addr = inet_addr("127.0.0.1");
  service.sin_port = htons(4444);

  if (bind( ListenSocket,
    (SOCKADDR*) &service,
    sizeof(service)) == SOCKET_ERROR) {
    printf("bind() failed.\n");
    closesocket(ListenSocket);
    WSACleanup();
    return 1;
  }

  //----------------------
  // Listen for incoming connection requests.
  // on the created socket
  if (listen( ListenSocket, 1 ) == SOCKET_ERROR) {
    printf("Error listening on socket.\n");
    closesocket(ListenSocket);
    WSACleanup();
    return 1;
  }


  printf("sock and osf handle are %d %d, error is \n", ListenSocket, _get_osfhandle (ListenSocket)); // -1 is invalid file handle: http://msdn.microsoft.com/en-us/library/ks2530z6.aspx
  printf("err was %d\n",  WSAGetLastError());
  //----------------------
  return ListenSocket;
   }


   int
   main (void)
   {
     struct ev_loop *loopy = ev_default_loop(0);
     int fd = get_server_fd();
     int fd_real =  _open_osfhandle(fd, NULL);
     int conv = _get_osfhandle(fd_real);
     printf("got server fd %d, loop %d, fd_real %d, that converted %d\n", fd, loopy, fd_real, conv);
    // accept(fd, NULL, NULL);
     // initialise an io watcher, then start it
     // this one will watch for stdin to become readable
     ev_io_init (&stdin_watcher, stdin_cb, /*STDIN_FILENO*/ conv, EV_READ);
     ev_io_start (loopy, &stdin_watcher);

     // initialise a timer watcher, then start it
     // simple non-repeating 5.5 second timeout
     //ev_timer_init (&timeout_watcher, timeout_cb, 15.5, 0.);
     //ev_timer_start (loopy, &timeout_watcher);
    printf("starting loop\n");
     // now wait for events to arrive
     ev_loop (loopy, 0);

     // unloop was called, so exit
     return 0;
   }
