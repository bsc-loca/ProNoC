#ifndef _DPI_INTERFACE_HPP_
#define _DPI_INTERFACE_HPP_

#include <queue>
#include "svdpi.h"
#include "socketstream.h"
#include "messages.h"

#define NE 4*4*2
#define RN 16

//***************************************************************************
// DPI-C interface
//***************************************************************************

extern "C" void c_epi_interface ( 
        svLogic startCom, svLogic getData, svLogic ejectReq, 
        svLogic *endCom, svLogic *newReq, 
        svBitVec32 source_all[RN], svBitVec32 destination_all[RN], 
        svBitVec32 address_all[RN], svBitVec32 opcode_all[RN], 
        svBitVec32 id_all[RN], svBitVec32 valid_all[RN],
        svBitVec32 rtrn_source_all[NE]      ,
        svBitVec32 rtrn_opcode_all[NE]      ,
        svBitVec32 rtrn_destination_all[NE] ,
        svBitVec32 rtrn_address_all[NE]     ,
        svBitVec32 rtrn_pkgid_all[NE]       ,
        svBitVec32 rtrn_valid_all[NE]       ,       
        svBitVec32 rtrndat_source_all[NE]      ,
        svBitVec32 rtrndat_opcode_all[NE]      ,
        svBitVec32 rtrndat_destination_all[NE] ,
        svBitVec32 rtrndat_pkgid_all[NE]       ,
        svBitVec32 rtrndat_valid_all[NE]       ,       
        svBitVec32 rtrnrsp_source_all[NE]      ,
        svBitVec32 rtrnrsp_opcode_all[NE]      ,
        svBitVec32 rtrnrsp_destination_all[NE] ,
        svBitVec32 rtrnrsp_pkgid_all[NE]       ,
        svBitVec32 rtrnrsp_valid_all[NE]       ,       
        svBitVec32 hn_source_all[RN]       ,
        svBitVec32 hn_opcode_all[RN]       ,
        svBitVec32 hn_destination_all[RN]  ,
        svBitVec32 hn_address_all[RN]      ,
        svBitVec32 hn_pkgid_all[RN]        ,
        svBitVec32 hn_valid_all[RN]        ,       
        svBitVec32 datrn_source_all[RN]      ,
        svBitVec32 datrn_opcode_all[RN]      ,
        svBitVec32 datrn_destination_all[RN] ,
        svBitVec32 datrn_address_all[RN]     ,
        svBitVec32 datrn_pkgid_all[RN]       ,
        svBitVec32 datrn_valid_all[RN]     ,         
        svBitVec32 rsp_source_all[RN]      ,
        svBitVec32 rsp_opcode_all[RN]      ,
        svBitVec32 rsp_destination_all[RN] ,
        svBitVec32 rsp_address_all[RN]     ,
        svBitVec32 rsp_pkgid_all[RN]       ,
        svBitVec32 rsp_valid_all[RN]       ,       
        svBitVec32 fwd_id_all[RN]          ,
        svBitVec32 fwd_idv_all[RN]         ,     
        svBitVec32 NEready_all[RN]              
        );

extern "C" void connection_init ( 
        svLogic startCom, svLogic *ready
        );

//***************************************************************************
// Connection manager class
//***************************************************************************
struct ReplyPacket {
	int source;
	int dest;
	int id;
	int network;
	int cl;
	int miss_pred;
};

struct RequestPacket {
	int source;
	int dest;
	int id;
	int size;
	int network;
	int cl;
	int miss_pred;
};


class connection_manager {
    private:

	    //SocketStream *_channel;
	    SocketStream _listenSocket;

        int _sources;
        int _dests;
        int _duplicate_networks;


    
    public:
        connection_manager();
        int Init();
        int Step();
        int readMsg();
        int sendResMsg();
        int sendAckMsg();
        int sendAckReqMsg();
        
        int checkInjection();
        
        int getSynfullEndPoint(int node);
        int getPronocEndPoint(int node);
        int getMsgType(int opcode);
        int getChiOpc(int opcode, int type);
        
        ReplyPacket *DequeueReplyPacket();
        int printResMsg(EjectResMsg res); 
        int printReqMsg(InjectReqMsg *req);


};
	    
SocketStream *_channel;

connection_manager *_connection_manager ;

//socket communication
StreamMessage *_msg ;
InjectReqMsg  *_req ;

EjectResMsg  _res    ;
StepResMsg   _ackRes ;
InjectResMsg _ackReq ; 

queue<EjectResMsg> _eject_buffer;

//tmp
RequestPacket *rp;
svLogic _newInjection;

#endif

