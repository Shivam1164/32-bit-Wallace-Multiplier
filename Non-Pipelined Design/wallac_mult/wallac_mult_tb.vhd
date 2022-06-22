library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
use work.my_pkg.all ;


entity wallac_mult_tb is

end entity ;

architecture behave of wallac_mult_tb is 

type COL1 is array (63 downto 0) of std_logic_vector(31 downto 0) ;

signal CL1 : COL1 := (others => (others => '0'));

signal a, b, c : std_logic_vector(31 downto 0) ;

begin
dut: wallac_mult port map(a => a, b=> b, c=> c) ;  



end architecture ;