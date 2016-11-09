#include "Timer.h"
#include "Lab3.h"
//#include "printf.h"

module Lab3C @safe()
{
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface AMSend;
    interface Receive;
    interface Timer<TMilli>;
    interface Leds;
    
    interface SplitControl as SerialControl;
    interface AMSend as UartSend[am_id_t id];
    interface Receive as UartReceive[am_id_t id];
    interface Packet as UartPacket;
    interface AMPacket as UartAMPacket;
  }
}
implementation
{
  message_t sendBuf;
  bool sendBusy;

  lab3_t local;
  
  uint8_t master;
  uint8_t first_bid = 0;
  uint8_t first_source = 0;
  uint8_t random0to5 = 0;
  

  event void Boot.booted() {
    local.generation = 0;
    local.source = TOS_NODE_ID;
    local.type = BID;
    local.bid = 7;
    local.winner = 0;
    master = 1;
    
    srand(TOS_NODE_ID);
   
	sendBusy = FALSE;
 
    call Leds.set(0);
    call RadioControl.start();
  }

  void startTimer() {
	//printf("Starting timer\n");
	//printfflush();
    call Leds.set(local.bid);
    call Timer.startOneShot(DEFAULT_INTERVAL);
  }
  
  void sendLocal() {
    //printf("TX: Source: %d  Bid: %d  Type: %d   Generation: %d   Winner: %d\n", local.source, local.bid, local.type, local.generation, local.winner);
	//printfflush();
	if (!sendBusy && sizeof local <= call AMSend.maxPayloadLength())
	{
		memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
		if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) == SUCCESS)
		  sendBusy = TRUE;
	}
  }

  event void RadioControl.startDone(error_t error) {
  
	//Only start timer and broadcast if master
	if(master == TOS_NODE_ID) {
		startTimer();
	}
	
  }

  event void RadioControl.stopDone(error_t error) {
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    lab3_t *l3msg = payload;
    
    //printf("RX: Source: %d  Bid: %d  Type: %d   Generation: %d   Winner: %d\n", l3msg->source, l3msg->bid, l3msg->type, l3msg->generation, l3msg->winner);
	//printfflush();
    
	if(master == TOS_NODE_ID) {
		
		//Master
		//printf("Receiving packet as master\n");
	    //printfflush();
				
		if(local.generation != l3msg->generation) {
		
			//Master must ignore other generation packets
			//printf("Packet is from current master generation\n");
			//printfflush();
			return msg;
			
		}
		
		//Determine if first bid or second bid	
		if(!first_bid && !first_source) {
			
			//First bid
			first_bid = l3msg->bid;
			first_source = l3msg->source;
			
			//printf("Bid rx: 1st bid, %d, from %d\n", first_bid, first_source);
			//printfflush();
			
		} else {
		
			//Second bid must come from second slave
			if(l3msg->source != first_source)  {   
			
				//printf("Bid rx: 2nd bid, %d, from %d\n", l3msg->bid, l3msg->source);
				//printfflush();
				
				//Switch to AWARD phase
				local.type = AWARD;
				
				if(l3msg->bid <= first_bid) {
					//First bid won, or tie
					local.bid = first_bid;
					local.winner = first_source;
					//printf("Packet: 1st bid won\n");
					//printfflush();
					
				} else {
					//Second bid won
					local.bid = l3msg->bid;
					local.winner = l3msg->source;
					//printf("Packet: 2nd bid won\n");
					//printfflush();
				}
				startTimer();
			}
		}
		
	} else {
		
		//Slave
		//printf("Rx packet as slave\n");
		//printfflush();
		
		//Ignore messages not from master
		if(l3msg->source != master) {
			//printf("Ignored message not from master\n");
			//printfflush();
			return msg;
		}
		
		//Update slave generation if necessary
		if(l3msg->generation > local.generation) {
			//printf("updating slave generation to %d\n", l3msg->generation);
			//printfflush();
			local.generation = l3msg->generation;
		}
		
		if(local.type == BID) {
		
			//Compute bid and display
			random0to5 = rand();
			//printf("Got random number: %d\n", random0to5);
			local.bid = 1 + (random0to5 % 6); //random between 1 and 6 inclusive
			//printf("Bidding %d from mote %d\n", local.bid, TOS_NODE_ID);
			//printfflush();
			startTimer();
				
		} else {  //AWARD
		
			//printf("Processing award\n");
			//printfflush();
			call Leds.set(0);
			local.generation++;
			local.type = BID;
			
			//Determine if we won, set next generation and state
			if(l3msg->winner == TOS_NODE_ID) {
			
				//We are the master now
				//printf("We are now master, node %d\n", TOS_NODE_ID);
			    //printfflush();
				master = TOS_NODE_ID;
				local.bid = 7;
				startTimer();
				
			} else {
			
				//Still a slave
				//printf("We are still a slave, node %d\n", TOS_NODE_ID);
			    //printfflush();
				master = l3msg->winner;
				local.bid = 0;
				
			}
		
		}
		
	}
		

    return msg;
  }

  event void Timer.fired() {
  
  
    if(master == TOS_NODE_ID) {
		//Master
		
		//Clear LEDs, send message
		//printf("Sending bid request\n");
		//printfflush();
		call Leds.set(0);
		sendLocal();
		
		if(local.type == AWARD) {
		    //Set new master, next generation
		    //printf("Setting new master node %d\n", local.winner);
			//printfflush();
		    first_source = 0;
		    first_bid = 0;
			master = local.winner;
			local.generation++;
			local.type = BID;
			local.bid = 0;
		}

	} else {
		//Slave 
		if(local.type == BID) {
			//send bid
		    //printf("Setting new master node %d\n", local.winner);
			//printfflush();
			sendLocal();
			local.type = AWARD;
		} 
		//Timer shouldn't fire in AWARD phase on slaves!
	}

  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    sendBusy = FALSE;
    //printf("Packet sent\n");
	//printfflush();
  }


}
