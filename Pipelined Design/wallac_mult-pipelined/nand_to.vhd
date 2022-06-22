library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;


entity and_to is
port 
(
a, b : in std_logic ;
c : out std_logic 
) ;

end entity ;

architecture dflow of and_to is 

begin

c <= a and b ;

end architecture ;