library ieee ;
use ieee.std_logic_1164.all ;
use work.my_pkg.all ;

entity add32 is 
generic ( n : integer := 32);   ---supported upto 64 bits
port (
	a, b: in std_logic_vector((n-1) downto 0);
	cin : in std_logic ;
	s : out std_logic_vector((n-1) downto 0) ;
	cout : out std_logic
);
end add32;

architecture dflow of add32 is
--alias std_logic_vector as slv ;
signal cx : std_logic_vector(n downto 1) ;
signal g1, p1 : std_logic_vector((n-1) downto 0) ;
signal g2, p2 : std_logic_vector((n/2-1) downto 0) ;
signal g3, p3 : std_logic_vector((n/4-1) downto 0) ;
signal g4, p4 : std_logic_vector((n/8-1) downto 0) ;
signal g5, p5 : std_logic_vector((n/16-1) downto 0) ;
signal g6, p6 : std_logic_vector((n/32-1) downto 0) ;
signal g7, p7 : std_logic_vector((n/64-1) downto 0) ;
signal g1c, g2c, g3c, g4c, g5c, g6c, g7c : std_logic ;
begin

generate1: for i in 0 to (n-1) generate
	generate11:if(i=0) generate
		G : element_and port map (a => a(0), b => b(0), c => g1c);
		C: element_orand port map (a => g1c, b => p1(0), c => cin, d => cx(1));
		p: element_xor port map(a => a(0), b=> b(0), c=> p1(i));
		g1(0) <= cx(1);
	end generate;
	generate111: if(i>0) generate
		g: element_and port map(a => a(i), b=> b(i), c=> g1(i));
		p: element_xor port map(a => a(i), b=> b(i), c=> p1(i));
	end generate;
end generate;

generate2: for i in 0 to (n/2-1) generate
	generate22:if(i=0) generate
		G : element_orand port map (a => g1(1), b => p1(1), c => g1(0), d => g2c);
		C: element_orand port map (a => g2c, b => p2(0), c => cin, d => cx(2));
		g2(0) <= cx(2) ;
		p: element_and port map(a => p1(i*2+1), b=> p1(i*2), c=> p2(i));
	end generate;
	generate222: if(i>0) generate
		g: element_orand port map(a => g1(i*2 + 1), b=> p1(i*2 + 1), c=> g1(i*2), d => g2(i));
		p: element_and port map(a => p1(i*2+1), b=> p1(i*2), c=> p2(i));
	end generate;

end generate;

generate3: for i in 0 to (n/4-1) generate
	generate33:if(i=0) generate
		G : element_orand port map (a => g2(1), b => p2(1), c => g2(0), d => g3c);
		C: element_orand port map (a => g3c, b => p3(0), c => cin, d => cx(4));
		g3(0) <= cx(4) ;
		p: element_and port map(a => p2(i*2+1), b=> p2(i*2), c=> p3(i));
	end generate;
	generate333: if(i>0) generate
		g: element_orand port map(a => g2(i*2 + 1), b=> p2(i*2 + 1), c=> g2(i*2), d => g3(i));
		p: element_and port map(a => p2(i*2+1), b=> p2(i*2), c=> p3(i));
	end generate;

end generate;

generate4: for i in 0 to (n/8-1) generate
	generate44:if(i=0) generate
		G : element_orand port map (a => g3(1), b => p3(1), c => g3(0), d => g4c);
		C: element_orand port map (a => g4c, b => p4(0), c => cin, d => cx(8));
		g4(0) <= cx(8) ;
		p: element_and port map(a => p3(i*2+1), b=> p3(i*2), c=> p4(i));
	end generate;
	generate444: if(i>0) generate
		g: element_orand port map(a => g3(i*2 + 1), b=> p3(i*2 + 1), c=> g3(i*2), d => g4(i));
		p: element_and port map(a => p3(i*2+1), b=> p3(i*2), c=> p4(i));
	end generate;
end generate;

generate5:if ( n > 8 ) generate
	generate55: for i in 0 to (n/16-1) generate
		generate5:if(i=0) generate
			G : element_orand port map (a => g4(1), b => p4(1), c => g4(0), d => g5c);
			C: element_orand port map (a => g5c, b => p5(0), c => cin, d => cx(16));
			g5(0) <= cx(16) ;
			p: element_and port map(a => p4(i*2+1), b=> p4(i*2), c=> p5(i));
		end generate;
		generate555: if(i>0) generate
			g: element_orand port map(a => g4(i*2 + 1), b=> p4(i*2 + 1), c=> g4(i*2), d => g5(i));
			p: element_and port map(a => p4(i*2+1), b=> p4(i*2), c=> p5(i));
		end generate;

end generate;
end generate;

generate6:if ( n > 16 ) generate
	generate66: for i in 0 to (n/32-1) generate
			generate666:if(i=0) generate
				G : element_orand port map (a => g5(1), b => p5(1), c => g5(0), d => g6c);
				C: element_orand port map (a => g6c, b => p6(0), c => cin, d => cx(32));
				g6(0) <= cx(32) ;
				p: element_and port map(a => p5(i*2+1), b=> p5(i*2), c=> p6(i));
			end generate;
			generate6666: if(i>0) generate
				g: element_orand port map(a => g5(i*2 + 1), b=> p5(i*2 + 1), c=> g5(i*2), d => g6(i));
				p: element_and port map(a => p5(i*2+1), b=> p5(i*2), c=> p6(i));
			end generate;

end generate;
end generate;

generate7:if ( n > 32 ) generate
	generate77: for i in 0 to (n/64-1) generate
		generate777:if(i=0) generate
				G : element_orand port map (a => g6(1), b => p6(1), c => g6(0), d => g7c);
				C: element_orand port map (a => g7c, b => p7(0), c => cin, d => cx(64));
				g7(0) <= cx(64) ;
				p: element_and port map(a => p6(i*2+1), b=> p6(i*2), c=> p7(i));
		end generate;
		generate7777: if(i>0) generate
				g: element_orand port map(a => g6(i*2 + 1), b=> p6(i*2 + 1), c=> g6(i*2), d => g7(i));
				p: element_and port map(a => p6(i*2+1), b=> p6(i*2), c=> p7(i));
		end generate;

end generate;
end generate;


cout <= cx(n);
--cx1: element_orand port map (g1(0), p1(0), cin, cx(1)) ;



--cx17: element_orand port map (g1(9), p1(9), cx(9), cx(17)) ;

---cx
cx3  : element_orand port map (g1(2), p1(2), cx(2), cx(3)) ;
cx5  : element_orand port map (g1(4), p1(4), cx(4), cx(5)) ;
cx7  : element_orand port map (g1(6), p1(6), cx(6), cx(7)) ;
cx9  : element_orand port map (g1(8), p1(8), cx(8), cx(9)) ;
cx11 : element_orand port map (g1(10), p1(10), cx(9), cx(11)) ;
cx13 : element_orand port map (g1(12), p1(12), cx(12), cx(13)) ;
cx15 : element_orand port map (g1(14), p1(14), cx(14), cx(15)) ;
cx17 : element_orand port map (g1(16), p1(16), cx(16), cx(17)) ;
cx19 : element_orand port map (g1(18), p1(18), cx(18), cx(19)) ;
cx21 : element_orand port map (g1(20), p1(20), cx(20), cx(21)) ;
cx23 : element_orand port map (g1(22), p1(22), cx(22), cx(23)) ;
cx25 : element_orand port map (g1(24), p1(24), cx(24), cx(25)) ;
cx27 : element_orand port map (g1(26), p1(26), cx(26), cx(27)) ;
cx29 : element_orand port map (g1(28), p1(28), cx(28), cx(29)) ;
cx31 : element_orand port map (g1(30), p1(30), cx(30), cx(31)) ;

cx6  : element_orand port map (g2(2), p2(2), cx(4), cx(6)) ;
cx10 : element_orand port map (g2(4), p2(4), cx(8), cx(10)) ;
cx14 : element_orand port map (g2(6), p2(6), cx(12), cx(14)) ;
cx18 : element_orand port map (g2(8), p2(8), cx(16), cx(18)) ;
cx22 : element_orand port map (g2(10), p2(10), cx(20), cx(22)) ;
cx26 : element_orand port map (g2(12), p2(12), cx(24), cx(26)) ;
cx30 : element_orand port map (g2(14), p2(14), cx(28), cx(30)) ;


cx12 : element_orand port map (g3(2), p3(2), cx(8), cx(12)) ;
cx20 : element_orand port map (g3(4), p3(4), cx(16), cx(20)) ;
cx24 : element_orand port map (g3(5), p3(5), cx(20), cx(24)) ;
cx28 : element_orand port map (g3(6), p3(6), cx(24), cx(28)) ;

sum_generate : for i in 0 to n-1 generate
	sogenerate: if(i=0) generate
		s0 : element_xor port map (a => p1(i), b => cin, c => s(i));
	end generate ;
	s1generate: if(i>0) generate
	s1 : element_xor port map (a => p1(i), b => cx(i), c => s(i));
	end generate; 
end generate;


end dflow ;