configuration Lab3AppC { }
implementation
{
  components Lab3C, MainC, ActiveMessageC, LedsC,
    new TimerMilliC(), new TimerMilliC() as SerialTimerC,
    new AMSenderC(AM_LAB3), new AMReceiverC(AM_LAB3),
    SerialActiveMessageC,
    new SerialAMSenderC(AM_OSCILLOSCOPE), new SerialAMReceiverC(AM_OSCILLOSCOPE);

  Lab3C.Boot -> MainC;
  Lab3C.RadioControl -> ActiveMessageC;
  Lab3C.AMSend -> AMSenderC;
  Lab3C.Receive -> AMReceiverC;
  Lab3C.Timer -> TimerMilliC;
  Lab3C.Leds -> LedsC;
 
  
  Lab3C.SerialControl -> SerialActiveMessageC;
  Lab3C.SerialAMSend -> SerialAMSenderC;
  Lab3C.SerialReceive -> SerialAMReceiverC;
  Lab3C.SerialTimer -> SerialTimerC;
  

  
}
