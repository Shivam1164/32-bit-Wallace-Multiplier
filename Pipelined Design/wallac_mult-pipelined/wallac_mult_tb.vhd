library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
use work.my_pkg.all ;


entity wallac_mult_tb is

end entity ;

architecture behave of wallac_mult_tb is 


signal a, b: std_logic_vector(31 downto 0) := (others => '0') ;


signal x : std_logic_vector(63 downto 0) ;

signal clk : std_logic := '0' ;
signal enable_clk : std_logic := '1' ;

begin
dut: wallac_mult port map (a => a, b=> b, c => x, clk => clk) ;  

clk <= (not clk ) and enable_clk after 10 ps ;


process (clk) begin

if(clk'event and clk = '1') then
a <= std_logic_vector(to_unsigned((to_integer(unsigned(a))+101), 32)) ; 
b <= std_logic_vector(to_unsigned((to_integer(unsigned(b))+110), 32)) ; 

if (to_integer(unsigned(a)) > 10000) then
enable_clk <= '0' ;
else
enable_clk <= '1' ;
end if ;
end if ;
end process ; 
end architecture ;