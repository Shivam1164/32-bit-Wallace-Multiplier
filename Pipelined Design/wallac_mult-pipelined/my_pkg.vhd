library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;



package my_pkg is
type integer_array is array (31 downto 0) of integer ;
type std_logic_array is array (31 downto 0) of std_logic_vector(63 downto 0) ;
component and_to is
port (
a, b : in std_logic ;
c : out std_logic 
) ;

end component and_to;

component wallac_mult is
port (
a, b : in std_logic_vector(31 downto 0) ;
c : out std_logic_vector(63 downto 0) ;
clk : in std_logic  
) ;

end component wallac_mult;

component full_add is 

port 
(
a, b, cin : in std_logic ;
s, cout : out std_logic 
) ;

end component full_add ;

component half_add is 

port 
(
a, b: in std_logic ;
s, cout : out std_logic 
) ;

end component half_add ;

component element_xor is 
port (
	a, b: in std_logic;
	c : out std_logic
);
end component ;

component element_and is 
port (
	a, b: in std_logic;
	c : out std_logic
);
end component ;

component element_orand is 
port (
	a, b, c: in std_logic;
	d : out std_logic
);
end component ;

component add32 is 
generic ( n : integer := 32);
port (
	a, b: in std_logic_vector((n-1) downto 0);
	cin : in std_logic ;
	s : out std_logic_vector((n-1) downto 0) ;
	cout : out std_logic
);
end component ;

end package my_pkg ;