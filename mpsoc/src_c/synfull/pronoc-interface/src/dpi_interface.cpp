#include <stdio.h>
#include <stdlib.h>
#include <sstream>
#include <cassert>
#include <cstdlib>
#include <cstdio>
#include <cerrno>
#include "socketstream.h"
#include "messages.h"
#include "svdpi.h"
#include "dpi_interface.hpp"


extern "C" void connection_init ( 
        svLogic startCom, svLogic *ready
        )
{
    
    if ( startCom == 1 )
    {
        _connection_manager = new connection_manager;
        rp = new RequestPacket();
        _connection_manager->Init();
        *ready = '1';
    }
    
}

extern "C" void c_dpi_interface ( 
        svLogic startCom, svLogic getData, svLogic ejectReq, svLogic *endCom, svLogic *newReq, 
        svBitVec32 source_all[RN], svBitVec32 destination_all[RN], 
        svBitVec32 address_all[RN], svBitVec32 opcode_all[RN], 
        svBitVec32 id_all[RN], svBitVec32 valid_all[RN],
        svBitVec32 rtrn_source_all[NE]          ,
        svBitVec32 rtrn_opcode_all[NE]          ,
        svBitVec32 rtrn_destination_all[NE]     ,
        svBitVec32 rtrn_address_all[NE]         ,
        svBitVec32 rtrn_pkgid_all[NE]           ,
        svBitVec32 rtrn_valid_all[NE]           ,       
        svBitVec32 rtrndat_source_all[NE]       ,
        svBitVec32 rtrndat_opcode_all[NE]       ,
        svBitVec32 rtrndat_destination_all[NE]  ,
        svBitVec32 rtrndat_pkgid_all[NE]        ,
        svBitVec32 rtrndat_valid_all[NE]        ,       
        svBitVec32 rtrnrsp_source_all[NE]       ,
        svBitVec32 rtrnrsp_opcode_all[NE]       ,
        svBitVec32 rtrnrsp_destination_all[NE]  ,
        svBitVec32 rtrnrsp_pkgid_all[NE]        ,
        svBitVec32 rtrnrsp_valid_all[NE]        ,       
        svBitVec32 hn_source_all[RN]            ,
        svBitVec32 hn_opcode_all[RN]            ,
        svBitVec32 hn_destination_all[RN]       ,
        svBitVec32 hn_address_all[RN]           ,
        svBitVec32 hn_pkgid_all[RN]             ,
        svBitVec32 hn_valid_all[RN]             ,       
        svBitVec32 datrn_source_all[RN]         ,
        svBitVec32 datrn_opcode_all[RN]         ,
        svBitVec32 datrn_destination_all[RN]    ,
        svBitVec32 datrn_address_all[RN]        ,
        svBitVec32 datrn_pkgid_all[RN]          ,
        svBitVec32 datrn_valid_all[RN]          ,       
        svBitVec32 rsp_source_all[RN]           ,
        svBitVec32 rsp_opcode_all[RN]           ,
        svBitVec32 rsp_destination_all[RN]      ,
        svBitVec32 rsp_address_all[RN]          ,
        svBitVec32 rsp_pkgid_all[RN]            ,
        svBitVec32 rsp_valid_all[RN]            ,  
        svBitVec32 fwd_id_all[RN]               ,
        svBitVec32 fwd_idv_all[RN]              
        )
{

    bool process_more = true;
    int msgDone = 0;
    *endCom = '0'; 
    *newReq = '0';
    int noreq=0;
    int node_dst;
    int node_src;
    int toDataPort=0;
    int toRspPort=0;

    int rtrn_valid_all_[NE];    
    int rtrndat_valid_all_[NE];
    int rtrnrsp_valid_all_[NE];
    int fwd_idv_all_[RN];


    for(int i=0; i<NE; i++) {valid_all[i] = 0;}
    for(int i=0; i<RN; i++) {fwd_idv_all_[i] = fwd_idv_all[i];}

    for(int i=0; i<NE; i++) 
    {
        rtrn_valid_all_[i]    = rtrn_valid_all[i];
        rtrndat_valid_all_[i] = rtrndat_valid_all[i];    
        rtrnrsp_valid_all_[i] = rtrnrsp_valid_all[i];
    }

    if (startCom == 1 && getData == 1) 
    {
        //cout << "\n*** new clock *** " << endl;
        while ( process_more )
        {
            // read message
            _connection_manager->readMsg();

            switch(_msg->type)
            { 
                case STEP_REQ: //2
                    {
                    //cout << "\n*** STEP *** " << endl;
                        StepResMsg res;
                        *_channel << res;

                        // fall-through and increment your network one cycle
                        process_more = false;
                       
                       break;
                    }
                case INJECT_REQ: //4
                    {
                        cout << "\n*** INJECT_REQ *** " << endl;
                        _req = (InjectReqMsg*) _msg;
                        _connection_manager->sendAckReqMsg(); 
                        msgDone =(_req->coType == 1 || _req->coType == 2 || _req->coType == 5);
                        noreq = 0;

                        if((_req->coType==1 && _req->msgType==1)  || 
                                (_req->coType == 2 && _req->msgType==2) ||
                                (_req->coType == 5 && _req->msgType==2)) //only read for the moment
                        {    
                            node_dst =_connection_manager->getPronocEndPoint(_req->dest);
                            node_src =_connection_manager->getPronocEndPoint(_req->source);
                             
                            //cout << "id:" << _req->id << " src:" 
                            //    << _req->source << " dst:" << _req->dest 
                            //    << " mt:" << _req->msgType << " ct:" << _req->coType << " addr:" << _req->address  
                            //    << " p.src:" << node_src << " p.dst:" << node_dst << endl;
                            cout << "id:" << _req->id << " mt:" << _req->msgType << " ct:" << _req->coType 
                                << " node src:" << node_src << " node dst:" << node_dst << endl;

                            toDataPort=(_req->coType == 2 && _req->msgType == 2);
                            toRspPort=(_req->coType == 5 && _req->msgType == 2);

                            if( node_src >= 16 || node_dst >= 16 )
                            {
                                cout << "Error: node out of range"<< endl;
                            }

                            if( _req->source%2 )
                            {
                                if ( _req->coType == 2 && _req->msgType == 2)
                                {
                                    //cout << "Main Memory response"<< endl;
                                }
                                else
                                {
                                    //cout << "It's a directory request"<< endl;
                                    //if(_req->id==16){cout << "ID === 16 (1)" <<  endl;}
                                    hn_source_all[node_src]      = node_src       ;
                                    hn_opcode_all[node_src]      = _connection_manager->getChiOpc(_req->coType,_req->msgType)   ;
                                    hn_destination_all[node_src] = node_dst       ;
                                    hn_address_all[node_src]     = _req->address  ;
                                    hn_pkgid_all[node_src]       = _req->id       ;
                                    hn_valid_all[node_src]       = msgDone        ;      
                                }
                            }
                            else 
                            {
                                if (toDataPort)
                                {
                                    //cout << "It's a data response"<< endl;
                                    datrn_address_all[node_src]     = _req->address     ;
                                    datrn_destination_all[node_src] = node_dst          ;
                                    datrn_source_all[node_src]      = node_src          ;
                                    datrn_opcode_all[node_src]      = _connection_manager->getChiOpc(_req->coType,_req->msgType) ;
                                    datrn_pkgid_all[node_src]       = _req->id          ;
                                    datrn_valid_all[node_src]       = msgDone           ;
                                }
                                else if (toRspPort)
                                {
                                    //cout << "It's a Ack response"<< endl;
                                    rsp_address_all[node_src]     = _req->address     ;
                                    rsp_destination_all[node_src] = node_dst          ;
                                    rsp_source_all[node_src]      = node_src          ;
                                    rsp_opcode_all[node_src]      = _connection_manager->getChiOpc(_req->coType,_req->msgType) ;
                                    rsp_pkgid_all[node_src]       = _req->id          ;
                                    rsp_valid_all[node_src]       = msgDone           ;
                                }
                                else
                                {
                                    address_all[node_src]     = _req->address     ;
                                    destination_all[node_src] = node_dst          ;
                                    source_all[node_src]      = node_src          ;
                                    opcode_all[node_src]      = _connection_manager->getChiOpc(_req->coType,_req->msgType) ;
                                    id_all[node_src]          = _req->id          ;
                                    valid_all[node_src]       = msgDone           ;
                                }
                            }
                        }
                        else
                        {
                            cout << "---------- NO INJECTED ---------"<< endl;
                        }

                        break;
                    }
                case EJECT_REQ:  //6
                    {
                        if(ejectReq == 1)
                        {
                            cout << "\n*** EJECT_REQ *** " << endl;

                            for(int k=0; k<NE; k++)
                            {
                                if (rtrn_valid_all_[k] == 1){
                                    _res.id =  rtrn_pkgid_all[k];
                                    _eject_buffer.push(_res);
                                    rtrn_valid_all_[k] = 0;
                                }
                            } 
                            for(int k=0; k<NE; k++)
                            {
                                if (rtrndat_valid_all_[k] == 1){
                                    _res.id =  rtrndat_pkgid_all[k];
                                    _eject_buffer.push(_res);
                                    rtrndat_valid_all_[k] = 0;
                                }
                            } 
                            for(int k=0; k<NE; k++)
                            {
                                if (rtrnrsp_valid_all_[k] == 1){
                                    _res.id =  rtrnrsp_pkgid_all[k];
                                    _eject_buffer.push(_res);
                                    rtrnrsp_valid_all_[k] = 0;
                                }
                            } 
                            //fwd request - request to same RN node
                            for(int k=0; k<RN; k++)
                            {
                                if (fwd_idv_all_[k] == 1){
                                    _res.id = fwd_id_all[k];
                                    _eject_buffer.push(_res);
                                    fwd_idv_all_[k] = 0;
                                }
                            } 
                        }
                        else
                        {
                            _res.id = -1; //not pckage
                        }
                       
                        if (!_eject_buffer.empty()) {
                                _res = _eject_buffer.front();
                                _eject_buffer.pop();
                                _res.remainingRequests = _eject_buffer.size();
                                _connection_manager->sendResMsg();
                                cout << "id:" << _res.id << endl;
                        }
                        else
                        {
                            _connection_manager->sendResMsg();
                        }
                        
                        break;
                    }
                default:
                    {
                        break;
                    }
            
            }
        }
        
        *newReq = msgDone     ;
        

        StreamMessage::destroy(_msg);
        
    }
}

//*****************************************************************
// Connection Manager
//*****************************************************************
connection_manager::connection_manager(){
    _channel = NULL;
    _sources = 4;
    _dests   = 4;
    _duplicate_networks = 1;
}

//--
int connection_manager::Init() {                            
    // Start listening for incoming connections
    if (_listenSocket.listen(NS_HOST, NS_PORT) < 0) {
        return -1;
    }
            
    // Waiting to connect
    _channel = _listenSocket.accept();
                                        
    cout << "Connected... " << endl;
                   
    // Initialize client
    InitializeReqMsg req;
    InitializeResMsg res;
    *_channel >> req << res;
                    
    return 0;
}

int connection_manager::readMsg() 
{    
    _msg = NULL;
    
    if (_channel) 
    {
        *_channel >> (StreamMessage*&) _msg;
    }
    return 0;
}

int connection_manager::sendResMsg() 
{   
    *_channel << _res;
    return 0;
}

int connection_manager::sendAckMsg() 
{   
    *_channel << _ackRes;
    return 0;
}

int connection_manager::sendAckReqMsg() 
{   
    *_channel << _ackReq;
    return 0;
}

int connection_manager::checkInjection(){
    return _newInjection;
}                            

int connection_manager::getPronocEndPoint(int node){
    return (node-(node%2))/2 ; 
}                            

int connection_manager::getSynfullEndPoint(int node){
    return (((node-(node%3))/3)*2)+!(node%3); 
}

int connection_manager::getMsgType(int opcode)
{
    int type;
    switch (opcode)
    {
        case 1: // readshared - read 
            type = 1; // req
            break;
        case 4: // compdata - data 
            type = 0; // req
            break;
        default:
            type = 2;
            break;
    }
    return type; 
}

int connection_manager::getChiOpc(int opcode, int type)
{
    int chiopc;
    switch (type)
    {
        case 1:
            switch (opcode)
            {
                case 1: // readshared - read 
                    chiopc = 1 ;
                    break; 
                default:
                    chiopc = 999;
                    cout << "(req) coherency message not supported" << endl;
                    break;
            }
            break;
        case 2:
            switch (opcode)
            {
                case 2: // compdata - data 
                    chiopc = 4;
                    break;
                case 5: // compack - unblock 
                    chiopc = 2;
                    break;
                default:
                    chiopc = 999;
                    cout << "(resp) coherency message not supported" << endl;
                    break;
            } 
            break;
        default:
            chiopc = 999;
            cout << "coherency message not supported" << endl;
            break;
    }
    return chiopc; 
}

//-------Debug functions Neiel-Leyva

int connection_manager::printResMsg(EjectResMsg res) {
    cout << "Debug Neiel: res.id                = " << res.id << endl;
    cout << "Debug Neiel: res.remainingRequests = " << res.remainingRequests << endl;
    cout << "Debug Neiel: res.source            = " << res.source << endl;
    cout << "Debug Neiel: res.destination       = " << res.dest << endl;
    cout << "Debug Neiel: req.packetSize        = " << res.packetSize   << endl;
    cout << "Debug Neiel: res.network           = " << res.network << endl;
    cout << "Debug Neiel: res.cl                = " << res.cl << endl;
    cout << "Debug Neiel: res.miss_prediction   = " << res.miss_pred << endl;
    return 0;
};

int connection_manager::printReqMsg(InjectReqMsg *req) {
    cout << "  " << endl;
    cout << "Debug Neiel: req.source     = " << req->source       << endl;
    cout << "Debug Neiel: req.dest       = " << req->dest         << endl;
    cout << "Debug Neiel: req.id         = " << req->id           << endl;
    cout << "Debug Neiel: req.packetSize = " << req->packetSize   << endl;
    cout << "Debug Neiel: req.network    = " << req->network      << endl;
    cout << "Debug Neiel: req.cl         = " << req->cl           << endl;
    cout << "Debug Neiel: req.msgType    = " << req->msgType      << endl; 
    cout << "Debug Neiel: req.coType     = " << req->coType       << endl; 
    cout << "Debug Neiel: req.address    = " << req->address      << endl; 
    return 0;                                                    
};



//*****************************************************************************
// SocketStream
//*****************************************************************************

int SocketStream::listen(const char *host, int port){
    
    char *socket_path = "./socket";
    
    // Create a socket
    if ( (so = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
        cout << "Error creating socket." << endl;
        return -1;
    }
            
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path)-1);
                  
    // Bind it to the listening port
    unlink(socket_path);
    if (bind(so, (struct sockaddr*)&addr, sizeof(addr)) != 0) {
         cout << "Error binding socket." << endl;
         return -1;
    }
    
    //// Listen for connections
    if (::listen(so, NS_MAX_PENDING) != 0) {
         cout << "Error listening on socket." << endl;
         return -1;
    }
    
    bIsAlive = true;
                    
#ifdef NS_DEBUG
    cout << "Listening on socket" << endl;
#endif
        
    return 0;
}

// accept a new connection
SocketStream* SocketStream::accept()
{
    struct sockaddr_un clientaddr;
    socklen_t clientaddrlen = sizeof clientaddr;
    int clientsock = ::accept(so, (struct sockaddr*)&clientaddr, &clientaddrlen);
    
    if ( clientsock < 0 ){
        cout << "Error accepting a connection";
        return NULL;
    }

    return new SocketStream(clientsock, (struct sockaddr*)&clientaddr, clientaddrlen);
}

int SocketStream::connect(const char *host, int port)
{
    char *socket_path = "./socket";
    // Create a socket.
    if ( (so = socket(AF_UNIX, SOCK_STREAM, 0)) < 0 ){
        cout << "Error creating socket." << endl;
        return -1;
    }
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path)-1);

    // Connect to the server.
    if ( ::connect(so, (struct sockaddr*)&addr, sizeof(addr)) != 0) {
        cout << "Connection failed." << endl;
        return -1;
    }

    bIsAlive = true;

#ifdef NS_DEBUG
    cout << "Connected to host" << endl;
#endif

    return 0;
}

// read from the socket
int SocketStream::get(void *data, int number)
{

    int remaining = number;
    int received = 0;
    char *dataRemaining = (char*) data;

    errno = 0;
    while (remaining > 0 && (errno == 0 || errno == EINTR))
    {
        received = recv(so, dataRemaining, remaining, 0); // MSG_WAITALL
        if (received > 0)
        {
            dataRemaining += received;
            remaining -= received;
        }
    }

    return number - remaining;
}

// write to socket
int SocketStream::put(const void *data, int number)
{
    // MSG_NOSIGNAL prevents SIGPIPE signal from being generated on failed send
    return send(so, data, number, MSG_NOSIGNAL);
}


//*****************************************************************
//*****************************************************************


using namespace std;

SocketStream& operator<<(SocketStream& os, StreamMessage& msg)
{
#ifdef NS_DEBUG_EXTRA
    std::cout << "<MessageSend> Sending message: " << msg.type << ", size: " << msg.size << std::endl;
#endif

    // cork the connection
    int flag = 1;
    setsockopt (os.so, SOL_TCP, TCP_CORK, &flag, sizeof (flag));

    os.put(&(msg.size), sizeof(int));
    os.put(&msg, msg.size);

    // uncork the connection
    flag = 0;
    setsockopt (os.so, SOL_TCP, TCP_CORK, &flag, sizeof (flag));

    // os.flush();

    return os;
}

SocketStream& operator>>(SocketStream& is, StreamMessage*& msg)
{
#ifdef NS_DEBUG_EXTRA
    std::cout << "<MessageRecv> Waiting for message" << std::endl;
#endif

    int msgSize = -1;
    int gotBytes = is.get(&msgSize, sizeof(int));

    if (gotBytes != sizeof(int))
        return is;

    assert(msgSize > 0);

    msg = (StreamMessage*) malloc(msgSize);
    is.get(msg, msgSize);


#ifdef NS_DEBUG_EXTRA
    std::cout << "<MessageRecv> Got message: " << msg->type << std::endl;
#endif

    return is;
}

SocketStream& operator>>(SocketStream& is, StreamMessage& msg)
{
#ifdef NS_DEBUG_EXTRA
    std::cout << "<MessageRecvSync> Waiting for message" << std::endl;
#endif

    int msgSize = -1;
    int gotBytes = is.get(&msgSize, sizeof(int));

    if (gotBytes != sizeof(int))
        return is;

    assert(msgSize == msg.size);
    is.get(&msg, msgSize);

#ifdef NS_DEBUG_EXTRA
    std::cout << "<MessageRecvSync> Got message: " << msg.type << std::endl;
#endif

    return is;
}

void StreamMessage::destroy(StreamMessage* msg)
{
    assert (msg != NULL);
    free(msg);
}

