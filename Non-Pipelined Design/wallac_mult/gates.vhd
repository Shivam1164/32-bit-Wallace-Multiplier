library ieee ;
use ieee.std_logic_1164.all ;

entity element_orand is 
port (
	a, b, c: in std_logic;
	d : out std_logic
);
end element_orand;

architecture dflow of element_orand is

begin

d <= a or ( b and c)  ;

end dflow ;


library ieee ;
use ieee.std_logic_1164.all ;

entity element_xor is 
port (
	a, b: in std_logic;
	c : out std_logic
);
end element_xor;

architecture dflow of element_xor is

begin

c <= a xor b ;

end dflow ;


library ieee ;
use ieee.std_logic_1164.all ;

entity element_and is 
port (
	a, b: in std_logic;
	c : out std_logic
);
end element_and;

architecture dflow of element_and is

begin

c <= a and b ;

end dflow ;

