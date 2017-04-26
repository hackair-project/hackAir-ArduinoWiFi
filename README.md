# hackAir Arduino WiFi Shield

## Changelog

### Version 2
 - [Add] Pull-down resistor for pin 2 (ESP Reset) so the user can flash the Arduino without jumpers
 - [Add] Silkscreen markings for pin numbers
 - [Add] Programming header for the WiFi module
 - [Del] Removed sensor I/O header used by analog sensors
 - [Del] Removed the RC filter required by some analog sensors by SHARP
 - [Fix] Move some decoupling capacitors closer to the power pads
 - [Fix] Moved the CONN_POWER and CONN_SERIAL connectors away from the USB connector of the Arduino board
 - [Fix] Fixed some acid traps in the routing
 - [Fix] Fixed the footprint of Q1 (DSG -> DGS)
 - [Fix] Changed the foorprints of all non-electrolytic caps to be wider.
 - [Fix] Fixed the silkscreen of U1 appearing on the wrong layer.
 
### Version 1
Initial release
