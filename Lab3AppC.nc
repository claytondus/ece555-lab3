configuration Lab3AppC { }
implementation
{
  components Lab3C, MainC, ActiveMessageC, LedsC,
    new TimerMilliC(), 
    SerialActiveMessageC as Serial,
    new AMSenderC(AM_LAB3), new AMReceiverC(AM_LAB3);

  Lab3C.Boot -> MainC;
  Lab3C.RadioControl -> ActiveMessageC;
  Lab3C.AMSend -> AMSenderC;
  Lab3C.Receive -> AMReceiverC;
  Lab3C.Timer -> TimerMilliC;
  Lab3C.Leds -> LedsC;
 
  
  Lab3C.SerialControl -> Serial;
  Lab3C.UartSend -> Serial;
  Lab3C.UartReceive -> Serial.Receive;
  Lab3C.UartPacket -> Serial;
  Lab3C.UartAMPacket -> Serial;
  

  
}
