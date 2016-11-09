#ifndef LAB3_H
#define LAB3_H

enum {
  /* LED interval */
  LED_INTERVAL = 5000,

  AM_LAB3 = 0x59,
  BID = 0x01,
  AWARD = 0x02,
  
    /* Number of readings per message. If you increase this, you may have to
     increase the message_t size. */
  NREADINGS = 10,

  /* Default sampling period. */
  SERIAL_INTERVAL = 200,

  AM_OSCILLOSCOPE = 0x93
};

typedef nx_struct lab3 {
  nx_uint8_t source; /* Mote id of sending mote. */
  nx_uint8_t generation; /* Bid generation */
  nx_uint8_t type;
  nx_uint8_t bid; 
  nx_uint8_t winner; 
} lab3_t;

typedef nx_struct oscilloscope {
  nx_uint16_t version; /* Version of the interval. */
  nx_uint16_t interval; /* Samping period. */
  nx_uint16_t id; /* Mote id of sending mote. */
  nx_uint16_t count; /* The readings are samples count * NREADINGS onwards */
  nx_uint16_t readings[NREADINGS];
} oscilloscope_t;

#endif
