#ifndef LAB3_H
#define LAB3_H

enum {
  /* Trigger state change interval */
  DEFAULT_INTERVAL = 5000,

  AM_LAB3 = 0x59,
  BID = 0x01,
  AWARD = 0x02,
};

typedef nx_struct lab3 {
  nx_uint8_t source; /* Mote id of sending mote. */
  nx_uint8_t generation; /* Bid generation */
  nx_uint8_t type;
  nx_uint8_t bid; 
  nx_uint8_t winner; 
} lab3_t;

#endif
