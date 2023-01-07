#!/bin/bash
SRCDS_TOKEN=`cat .token`
/home/steam/csgo/srcds_run -game csgo -console -usercon +game_type 1 +game_mode 2 +mapgroup mg_allclassic +map de_dust +sv_setsteamaccount $SRCDS_TOKEN -net_port_try 1
