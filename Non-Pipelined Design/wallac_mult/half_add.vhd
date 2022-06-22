library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;


entity half_add is
port 
(
a, b : in std_logic ;
s, cout : out std_logic 
) ;

end entity ;


architecture dflow of half_add is 

begin

s <= a xor b  ;
cout <= (a and b)  ;

end architecture ;