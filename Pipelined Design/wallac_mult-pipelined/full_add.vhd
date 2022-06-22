library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;


entity full_add is
port 
(
a, b, cin : in std_logic ;
s, cout : out std_logic 
) ;

end entity ;


architecture dflow of full_add is 

begin

s <= a xor b xor cin ;
cout <= (a and b) or (b and cin) or ( cin and a) ;

end architecture ;