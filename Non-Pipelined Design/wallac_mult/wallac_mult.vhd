library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
use work.my_pkg.all ;


entity wallac_mult is
port 
(
a, b : in std_logic_vector(31 downto 0) ;
c : out std_logic_vector( 63 downto 0)
) ;

end entity ;

architecture dflow of wallac_mult is 

-----------------------------------------------------------------------

type COL1 is array (63 downto 0) of std_logic_vector(31 downto 0) ;

signal CL1 : COL1 := (others => (others => '0'));
-----------------------------------------------------------------------

-----------------------------------------------------------------------
type COL2 is array (63 downto 0) of std_logic_vector(21 downto 0) ;

signal CL2 : COL2 := (others => (others => '0'));
signal dummy_cl2 : COL2 := (others => (others => '0'));
-----------------------------------------------------------------------

-----------------------------------------------------------------------
type COL3 is array (63 downto 0) of std_logic_vector(14 downto 0) ;

signal CL3 : COL3 := (others => (others => '0'));
-----------------------------------------------------------------------

-----------------------------------------------------------------------
type COL4 is array (63 downto 0) of std_logic_vector(9 downto 0) ;

signal CL4 : COL4 := (others => (others => '0'));
-----------------------------------------------------------------------


-----------------------------------------------------------------------
type COL5 is array (63 downto 0) of std_logic_vector(6 downto 0) ;

signal CL5 : COL5 := (others => (others => '0'));
-----------------------------------------------------------------------

-----------------------------------------------------------------------
type COL6 is array (63 downto 0) of std_logic_vector(4 downto 0) ;

signal CL6 : COL6 := (others => (others => '0'));
-----------------------------------------------------------------------


-----------------------------------------------------------------------
type COL7 is array (63 downto 0) of std_logic_vector(3 downto 0) ;

signal CL7 : COL7 := (others => (others => '0'));
-----------------------------------------------------------------------


-----------------------------------------------------------------------
type COL8 is array (63 downto 0) of std_logic_vector(2 downto 0) ;

signal CL8 : COL8 := (others => (others => '0'));
-----------------------------------------------------------------------

-----------------------------------------------------------------------
type COL9 is array (63 downto 0) of std_logic_vector(1 downto 0) ;

signal CL9 : COL9 := (others => (others => '0'));
-----------------------------------------------------------------------


signal ae, be : std_logic_vector(63 downto 0) := (others => '0') ; 
signal ax, ay, bx, by : std_logic_vector(31 downto 0) := (others => '0') ;


signal a1, a2, b1, b2, s1, s2, s3 : std_logic_vector(31 downto 0) := (others => '0'); 
signal c1, c2, carry_select : std_logic ; 


signal db_out_var : integer_array:= (others => 0); 
signal db_out_var_1 : std_logic_array:= (others => (others=> '0'));  

begin

ae(31 downto 0) <= a ;
be(31 downto 0) <= b ; 

-----Partial products generation

columns: for i in 0 to 63 generate 
		rows : for j in 0 to 31 generate 
				pp: if i >= j   generate 
				  cond : if i <= 31 generate
						uut: and_to port map ( a => ae(j), b => be(i-j), c => cl1(i)(j)) ;
						end generate cond ;
						end generate pp ;
				pp_xcs: if (i > 31) and (j > (i-32)) generate
						uut1:and_to port map ( a => ae(j), b => be(i-j), c=> cl1(i)(j));
					   end generate pp_xcs;
		end generate rows;
end generate columns ;

--- Layer 1 Reduction

L1Red : for i in  1 to 64 generate 
	st1: if i < 31 generate
	        fas: for j in 1 to 10 generate 
				      fa_check: if j*3 <= i generate 
						          uutf1 : full_add port map ( a => cl1(i-1)(j*3 - 3), b=>cl1(i-1)(j*3 - 2)  , cin =>cl1(i-1)(j*3 - 1) , s =>cl2(i-1)(j-1), cout =>cl2(i)(i/3 + j) ) ;  
					            end generate fa_check ;
					  end generate fas ;
				has : if i mod 3 = 2 generate 
									uutf1 : half_add port map ( a => cl1(i-1)(i-1), b=>cl1(i-1)(i-2) , s =>cl2(i-1)(i/3), cout =>cl2(i)(i/3+(i+1)/3) ) ;  
						end generate has ;
				wires:if i mod 3 = 1 generate 
									uutf1 : cl2(i-1)(i/3) <= cl1(i-1)(i-1);  
						end generate wires ; 		
				end generate st1 ;
				
				
	st2: if (i < 33) and (i > 30) generate
	     fas_fixed : for k in 1 to 10 generate
				uutf1 : full_add port map ( a => cl1(i-1)(k*3-3), b=>cl1(i-1)(k*3-2)  , cin =>cl1(i-1)(k*3-1) , s =>cl2(i-1)(k-1), cout =>cl2(i)(i/3  + k-1) ) ;
				end generate fas_fixed ;
			wa2_fixed : if i = 32 generate 
				         cl2(31)(20) <= cl1(31)(30) ;
							cl2(31)(21) <= cl1(31)(31) ;
				end generate wa2_fixed ;
			wa1_fixed : if i = 31 generate 
				         cl2(30)(21) <= cl1(30)(30) ;
				end generate wa1_fixed ;
				end generate st2 ;
				
				
   st3: if (i > 32) and (i < 62) generate
				fas1:for l in 0 to 8 generate 
				cond11: if l < (30-(i-32))/3 generate 
				fas1: full_add port map ( a => cl1(i-1)(((i-33)/3+1)*3+l*3), b=>cl1(i-1)(((i-33)/3+1)*3+1+l*3)  , cin =>cl1(i-1)(((i-33)/3+1)*3+2+l*3) , s =>cl2(i-1)(l), cout =>cl2(i)((32-(i-32)-1)/3 +l) ) ;
				end generate cond11 ;	
					
				end generate fas1;
				
				has1:if (i -32) mod 3 = 1 generate
				uut_ha : half_add port map ( a => cl1(i-1)(i-32), b=>cl1(i-1)(i-31) , s =>cl2(i-1)((32-(i-32)-1)/3-1), cout =>cl2(i)((30-(i-32))/3 ) ) ; --+1
				cl2(i-1)((30-(i-32))/3 + (30-(i-33))/3 +1) <= cl1(i-1)(30) ;
				cl2(i-1)((30-(i-32))/3 + (30-(i-33))/3 +2) <= cl1(i-1)(31) ;				
				end generate has1 ;
				
				wires1:if (i- 32) mod 3 = 2 generate
				cl2(i-1)((30-(i-32))/3 + (30-(i-32))/3 +1) <= cl1(i-1)(i-32) ;
				cl2(i-1)((30-(i-32))/3 + (30-(i-33))/3 +2) <= cl1(i-1)(30) ;
				cl2(i-1)((30-(i-32))/3 + (30-(i-33))/3 +3) <= cl1(i-1)(31) ;
				end generate wires1 ;
				
				
				wires2:if (i- 32) mod 3 = 0 generate
				cl2(i-1)((30-(i-32))/3 + (30-(i-33))/3 ) <= cl1(i-1)(30) ;
				cl2(i-1)((30-(i-32))/3 + (30-(i-33))/3 + 1) <= cl1(i-1)(31) ;
				end generate wires2 ;
				
	         end generate st3 ;
	st4 : if (i > 61 ) generate
				cl2(i-1)(0) <= cl1(i-1)(30) ;
				cl2(i-1)(1) <= cl1(i-1)(31) ;
				end generate st4 ;
end generate L1Red ;

--- Layer 2 Reduction


L2Red: for i in  1 to 64 generate 

cond0: if i < 31 generate
gen_fas : for j in  0 to 6 generate 
	cond1: if j <= ((i-1)*2)/9 generate
		uut1: full_add port map ( a => cl2(i-1)(j*3), b=>cl2(i-1)(j*3+1)  , cin =>cl2(i-1)(j*3+2) , s =>cl3(i-1)(j), cout =>cl3(i)((i*2)/9 +1+j)) ;
			end generate cond1 ;
		end generate gen_fas ;
	end generate cond0 ;
	
	
cond2: if (i < 35) and (i > 30) generate
gen_fas1 : for j in  0 to 6 generate 
		uut1: full_add port map ( a => cl2(i-1)(j*3), b=>cl2(i-1)(j*3+1)  , cin =>cl2(i-1)(j*3+2) , s =>cl3(i-1)(j), cout =>cl3(i)(7+j)) ;
		end generate gen_fas1 ;
		cl3(i-1)(14) <= cl2(i-1)(21);
end generate cond2;


cond3: if i > 34 generate
cond1: if i < 47 or( i > 49 and i < 53 ) generate
	 gen_fas : for j in 0 to 5 generate
			cond0 : if j < (7-(i-32)/6) generate
			
			cond4: if i = 46 or i = 52 generate 
			uut1: full_add port map ( a => cl2(i-1)(j*3), b=>cl2(i-1)(j*3+1)  , cin =>cl2(i-1)(j*3+2) , s =>cl3(i-1)(j), cout =>cl3(i)((6-(i-31)/6)+j)) ;
			end generate cond4;
			
			cond5: if i /= 46 and i /= 52 generate 
			uut1: full_add port map ( a => cl2(i-1)(j*3), b=>cl2(i-1)(j*3+1)  , cin =>cl2(i-1)(j*3+2) , s =>cl3(i-1)(j), cout =>cl3(i)((7-(i-31)/6)+j)) ;
			end generate cond5;
			
				end generate cond0;
		end generate gen_fas;
	end generate cond1 ;
cond2: if i > 46 and (i < 50) generate
	gen_fas: for j in 0 to 4 generate
			cond0 : if j < (6-(i-32)/6) generate
			
			
			cond4: if i /= 49 generate 
			uut1: full_add port map ( a => cl2(i-1)(j*3), b=>cl2(i-1)(j*3+1)  , cin =>cl2(i-1)(j*3+2) , s =>cl3(i-1)(j), cout =>cl3(i)((6-(i-31)/6)+j)) ;
			end generate cond4;
			
			
			cond5: if i = 49 generate 
			uut1: full_add port map ( a => cl2(i-1)(j*3), b=>cl2(i-1)(j*3+1)  , cin =>cl2(i-1)(j*3+2) , s =>cl3(i-1)(j), cout =>cl3(i)((7-(i-31)/6)+j)) ;
			end generate cond5;
			
				end generate cond0;
		end generate gen_fas;
	end generate cond2 ;

cond6 : if i > 52 and (i /= 64) generate
gen_fas: for j in 0 to 2 generate 
			uut1: full_add port map ( a => cl2(i-1)(j*3), b=>cl2(i-1)(j*3+1)  , cin =>cl2(i-1)(j*3+2) , s =>cl3(i-1)(j), cout =>cl3(i)(3+j) );
		end generate gen_fas;

	end generate cond6;

cond7: if i = 64 generate

		cl3(63)(0) <= cl2(63)(0);
		end generate cond7 ;	
	
	end generate cond3 ;	
	
	
end generate L2Red ;







L3Red : for i in 1 to 64 generate 

cond0: if i < 6  generate 

		inner_cond1:if i /= 5  generate
			uut1: full_add port map (a => cl3(i-1)(0), b=>cl3(i-1)(1)  , cin =>cl3(i-1)(2) , s =>cl4(i-1)(0), cout =>cl4(i)(1));
		end generate inner_cond1 ;
		
	   inner_cond2:if i = 5 generate
			uut1: full_add port map (a => cl3(i-1)(0), b=>cl3(i-1)(1)  , cin =>cl3(i-1)(2) , s =>cl4(i-1)(0), cout =>cl4(i)(2));
		end generate inner_cond2 ;
			
end generate cond0;



cond1: if (i > 5 and i < 15)  or (i>53 and i < 64) generate 
		gen_fas: for j in 0 to 1 generate 
		inner_cond1:if i /= 14 and i/=63 generate
			uut1: full_add port map (a => cl3(i-1)(j*3), b=>cl3(i-1)(j*3+1)  , cin =>cl3(i-1)(j*3+2) , s =>cl4(i-1)(j), cout =>cl4(i)(2+j) );
		end generate inner_cond1 ;
		inner_cond2:if i = 14 generate
			uut1: full_add port map (a => cl3(i-1)(j*3), b=>cl3(i-1)(j*3+1)  , cin =>cl3(i-1)(j*3+2) , s =>cl4(i-1)(j), cout =>cl4(i)(3+j) );
			end generate inner_cond2 ;
		inner_cond3:if i = 63 generate
			uut1: full_add port map (a => cl3(i-1)(j*3), b=>cl3(i-1)(j*3+1)  , cin =>cl3(i-1)(j*3+2) , s =>cl4(i-1)(j), cout =>cl4(i)(1) );
			end generate inner_cond3 ;
		end generate gen_fas;
end generate cond1;


cond2: if (i > 14 and i < 20)  or (i> 47 and i < 54) generate 
		gen_fas: for j in 0 to 2 generate 
		inner_cond1:if i /= 19 and i/= 53 generate
			uut1: full_add port map (a => cl3(i-1)(j*3), b=>cl3(i-1)(j*3+1)  , cin =>cl3(i-1)(j*3+2) , s =>cl4(i-1)(j), cout =>cl4(i)(3+j) );
		end generate inner_cond1 ;
		inner_cond2:if i = 19 generate
			uut1: full_add port map (a => cl3(i-1)(j*3), b=>cl3(i-1)(j*3+1)  , cin =>cl3(i-1)(j*3+2) , s =>cl4(i-1)(j), cout =>cl4(i)(4+j) );
			end generate inner_cond2 ;
		inner_cond3:if i = 53 generate
			uut1: full_add port map (a => cl3(i-1)(j*3), b=>cl3(i-1)(j*3+1)  , cin =>cl3(i-1)(j*3+2) , s =>cl4(i-1)(j), cout =>cl4(i)(2+j) );
			end generate inner_cond3 ;
		end generate gen_fas;
end generate cond2;


cond3: if (i > 19 and i < 28)  or (i> 38 and i < 48) generate 
		gen_fas: for j in 0 to 3 generate 
		inner_cond1:if i /= 27 and i/= 47 generate
			uut1: full_add port map (a => cl3(i-1)(j*3), b=>cl3(i-1)(j*3+1)  , cin =>cl3(i-1)(j*3+2) , s =>cl4(i-1)(j), cout =>cl4(i)(4+j) );
		end generate inner_cond1 ;
		inner_cond2:if i = 27 generate
			uut1: full_add port map (a => cl3(i-1)(j*3), b=>cl3(i-1)(j*3+1)  , cin =>cl3(i-1)(j*3+2) , s =>cl4(i-1)(j), cout =>cl4(i)(5+j) );
			end generate inner_cond2 ;
		inner_cond3:if i = 47 generate
			uut1: full_add port map (a => cl3(i-1)(j*3), b=>cl3(i-1)(j*3+1)  , cin =>cl3(i-1)(j*3+2) , s =>cl4(i-1)(j), cout =>cl4(i)(3+j) );
			end generate inner_cond3 ;
		end generate gen_fas;
end generate cond3;


cond4: if (i> 27 and i < 39) generate 
		gen_fas: for j in 0 to 4 generate 
		inner_cond1:if i /= 38 generate
			uut1: full_add port map (a => cl3(i-1)(j*3), b=>cl3(i-1)(j*3+1)  , cin =>cl3(i-1)(j*3+2) , s =>cl4(i-1)(j), cout =>cl4(i)(5+j) );
		end generate inner_cond1 ;
		inner_cond2:if i = 38 generate
			uut1: full_add port map (a => cl3(i-1)(j*3), b=>cl3(i-1)(j*3+1)  , cin =>cl3(i-1)(j*3+2) , s =>cl4(i-1)(j), cout =>cl4(i)(4+j) );
			end generate inner_cond2 ;
		end generate gen_fas;
end generate cond4;

cond5 : if i = 64 generate
			cl4(i-1)(0) <= cl3(i-1)(0) ;
end generate cond5 ;

end generate L3Red ;





L4Red : for i in 1 to 64 generate

cond0: if i < 6  generate 

		inner_cond1:if i /= 5  generate
			uut1: full_add port map (a => cl4(i-1)(0), b=>cl4(i-1)(1)  , cin =>cl4(i-1)(2) , s =>cl5(i-1)(0), cout =>cl5(i)(1));
		end generate inner_cond1 ;
		
	   inner_cond2:if i = 5 generate
			uut1: full_add port map (a => cl4(i-1)(0), b=>cl4(i-1)(1)  , cin =>cl4(i-1)(2) , s =>cl5(i-1)(0), cout =>cl5(i)(2));
		end generate inner_cond2 ;
			
end generate cond0;



cond1: if (i > 5 and i < 20)  or (i>48 and i < 64) generate 
		gen_fas: for j in 0 to 1 generate 
		inner_cond1:if i /= 19 and i/=63 generate
			uut1: full_add port map (a => cl4(i-1)(j*3), b=>cl4(i-1)(j*3+1)  , cin =>cl4(i-1)(j*3+2) , s =>cl5(i-1)(j), cout =>cl5(i)(2+j) );
		end generate inner_cond1 ;
		inner_cond2:if i = 19 generate
			uut1: full_add port map (a => cl4(i-1)(j*3), b=>cl4(i-1)(j*3+1)  , cin =>cl4(i-1)(j*3+2) , s =>cl5(i-1)(j), cout =>cl5(i)(4+j) );
			end generate inner_cond2 ;
		inner_cond3:if i = 63 generate
			uut1: full_add port map (a => cl4(i-1)(j*3), b=>cl4(i-1)(j*3+1)  , cin =>cl4(i-1)(j*3+2) , s =>cl5(i-1)(j), cout =>cl5(i)(1) );
			end generate inner_cond3 ;
		end generate gen_fas;
end generate cond1;


cond2: if (i > 19 and i < 49) generate
		gen_fas: for j in 0 to 2 generate 
		inner_cond1:if  i/= 48 generate
			uut1: full_add port map (a => cl4(i-1)(j*3), b=>cl4(i-1)(j*3+1)  , cin =>cl4(i-1)(j*3+2) , s =>cl5(i-1)(j), cout =>cl5(i)(4+j) );
			
		end generate inner_cond1 ;
		inner_cond2:if i = 48 generate
			uut1: full_add port map (a => cl4(i-1)(j*3), b=>cl4(i-1)(j*3+1)  , cin =>cl4(i-1)(j*3+2) , s =>cl5(i-1)(j), cout =>cl5(i)(3+j) );
			end generate inner_cond2 ;
		end generate gen_fas;
		
		wire_cond1: if i /= 48 generate
			cl5(i-1)(3) <= cl4(i-1)(9);
		end generate wire_cond1 ;

end generate cond2;

cond3 : if i = 64 generate
			cl5(i-1)(0) <= cl4(i-1)(0) ;
end generate cond3 ;

end generate L4Red ;






L5Red : for i in 1 to 64 generate

cond0: if (i < 19) or (i>49 and i < 64)  generate 

		inner_cond1:if i /= 18 and i /= 63 generate
			uut1: full_add port map (a => cl5(i-1)(0), b=>cl5(i-1)(1)  , cin =>cl5(i-1)(2) , s =>cl6(i-1)(0), cout =>cl6(i)(1));
		w_cond1 : if i = 50 generate
		cl6(i-1)(3) <= cl5(i-1)(3) ;
		end generate w_cond1 ;
		w_cond2 : if i /= 50 generate
		cl6(i-1)(2) <= cl5(i-1)(3) ;
		end generate w_cond2 ;
		end generate inner_cond1 ;
	   inner_cond2:if i = 18 generate
			uut1: full_add port map (a => cl5(i-1)(0), b=>cl5(i-1)(1)  , cin =>cl5(i-1)(2) , s =>cl6(i-1)(0), cout =>cl6(i)(2));
			cl6(i-1)(2) <= cl5(i-1)(3) ;
		end generate inner_cond2 ;
		inner_cond3:if i = 63 generate
			uut1: full_add port map (a => cl5(i-1)(0), b=>cl5(i-1)(1)  , cin =>cl5(i-1)(2) , s =>cl6(i-1)(0), cout =>cl6(i)(1) );
			cl6(i-1)(2) <= cl5(i-1)(3) ;
		end generate inner_cond3 ;
			
end generate cond0;



cond1: if (i > 18 and i < 50) generate 
		gen_fas: for j in 0 to 1 generate 
		inner_cond1:if i /= 49 generate
			uut1: full_add port map (a => cl5(i-1)(j*3), b=>cl5(i-1)(j*3+1)  , cin =>cl5(i-1)(j*3+2) , s =>cl6(i-1)(j), cout =>cl6(i)(2+j) );
		end generate inner_cond1 ;
		inner_cond2:if i = 49 generate
			uut1: full_add port map (a => cl5(i-1)(j*3), b=>cl5(i-1)(j*3+1)  , cin =>cl5(i-1)(j*3+2) , s =>cl6(i-1)(j), cout =>cl6(i)(1+j) );
			end generate inner_cond2 ;

		end generate gen_fas;
		
		w_cond1 : if i = 19 generate
		cl6(i-1)(3) <= cl5(i-1)(6) ;
		end generate w_cond1 ;
		
		w_cond2 : if i /= 19 generate
		cl6(i-1)(4) <= cl5(i-1)(6) ;
		end generate w_cond2 ;
		
end generate cond1;


cond2 : if i = 64 generate
			cl6(i-1)(0) <= cl5(i-1)(0) ;
end generate cond2 ;

end generate L5Red;





L6Red : for i in 1 to 64 generate

cond0: if (i < 19) or (i > 49 and i < 64) generate 
		inner_cond0: if i /= 18 generate
		uut1: full_add port map (a => cl6(i-1)(0), b=>cl6(i-1)(1)  , cin =>cl6(i-1)(2) , s =>cl7(i-1)(0), cout =>cl7(i)(1));
		end generate inner_cond0 ;
		inner_cond1: if i = 18 generate
		uut1: full_add port map (a => cl6(i-1)(0), b=>cl6(i-1)(1)  , cin =>cl6(i-1)(2) , s =>cl7(i-1)(0), cout =>cl7(i)(2));
		end generate inner_cond1 ;
	end generate cond0 ;

cond1: if (i > 18 and i < 50) generate 
		gen_fas: for j in 0 to 1 generate 
		mask_cond1: if j = 0 generate
		inner_cond1:if i /= 49 generate
			uut1: full_add port map (a => cl6(i-1)(j*3), b=>cl6(i-1)(j*3+1)  , cin =>cl6(i-1)(j*3+2) , s =>cl7(i-1)(j), cout =>cl7(i)(2+j) );
		end generate inner_cond1 ;
		inner_cond2:if i = 49 generate
			uut1: full_add port map (a => cl6(i-1)(j*3), b=>cl6(i-1)(j*3+1)  , cin =>cl6(i-1)(j*3+2) , s =>cl7(i-1)(j), cout =>cl7(i)(1+j) );
			end generate inner_cond2 ;
		end generate mask_cond1 ;
		
		mask_cond2 : if j = 1 generate
		inner_cond1:if i /= 49 generate
			uut1: full_add port map (a => cl6(i-1)(3), b=>cl6(i-1)(4)  , cin => '0' , s =>cl7(i-1)(j), cout =>cl7(i)(2+j) );
		end generate inner_cond1 ;
		inner_cond2:if i = 49 generate
			uut1: full_add port map (a => cl6(i-1)(3), b=>cl6(i-1)(4)  , cin =>'0' , s =>cl7(i-1)(j), cout =>cl7(i)(1+j) );
			end generate inner_cond2 ;
		end generate mask_cond2 ;
		
		end generate gen_fas;
	end generate cond1;
	
cond2 : if i = 64 generate
			cl7(i-1)(0) <= cl6(i-1)(0) ;
end generate cond2 ;

end generate L6Red ;





L7Red : for i in 1 to 64 generate

		inner_cond0: if i = 19 or ( i > 49 and i < 64) generate
		uut1: full_add port map (a => cl7(i-1)(0), b=>cl7(i-1)(1)  , cin =>cl7(i-1)(2) , s =>cl8(i-1)(0), cout =>cl8(i)(1));
		end generate inner_cond0 ;
		
		inner_cond1: if i > 19 and i < 50 generate
		uut1: full_add port map (a => cl7(i-1)(0), b=>cl7(i-1)(1)  , cin =>cl7(i-1)(2) , s =>cl8(i-1)(0), cout =>cl8(i)(1));
		cl8(i-1)(2) <= cl7(i-1)(3) ;
		end generate inner_cond1 ;
		
		inner_cond2: if (i < 19) generate 
		cl8(i-1)(0) <= cl7(i-1)(0) ;
		cl8(i-1)(1) <= cl7(i-1)(1) ;
		end generate inner_cond2 ;
		
		cond2 : if i = 64 generate
			cl8(i-1)(0) <= cl7(i-1)(0) ;
		end generate cond2 ;

end generate L7Red ;

L8Red : for i in 1 to 64 generate

		inner_cond0: if i > 18 and i < 64  generate
		uut1: full_add port map (a => cl8(i-1)(0), b=>cl8(i-1)(1)  , cin =>cl8(i-1)(2) , s =>cl9(i-1)(0), cout =>cl9(i)(1));
		end generate inner_cond0 ;
		
		inner_cond1: if (i < 19) generate 
		cl9(i-1)(0) <= cl8(i-1)(0) ;
		cl9(i-1)(1) <= cl8(i-1)(1) ;
		end generate inner_cond1 ;
		
		cond2 : if i = 64 generate
			cl9(i-1)(0) <= cl8(i-1)(0) ;
		end generate cond2 ;

end generate L8Red ;



--ax <= cl9(63 downto 0)(0) ;
--bx <= cl9(63 downto 0)(0) ;

adder1:  add32 port map ( a => a1, b => b1, cin => '0', s=> s3 , cout => carry_select ) ;
adder2:  add32 port map ( a => a2, b => b2, cin => '0', s=> s1 , cout => c1 ) ;
adder3:  add32 port map ( a => a2, b => b2, cin => '1', s=> s2 , cout => c2 ) ;


c (63 downto 0) <= s1 & s3 when carry_select = '0' else
  					    s2 & s3 ;


--a1 <= db_out_var_1(0)(31 downto 0) ;
--a2 <= db_out_var_1(0)(63 downto 32);
--b1 <= db_out_var_1(1)(31 downto 0) ;
--b2 <= db_out_var_1(1)(63 downto 32);


--process (cl1)
--variable db_out_var : integer_array:= (others => 0);
--variable db_out_var_1 : std_logic_array:= (others => (others=> '0'));
----variable db_out_var :  std_logic_vector(63 downto 0) := (others => '0') ;
--variable temp : std_logic_vector(63 downto 0) := (others => '0') ;
--begin
--for m in 0 to 31 loop
--for n in 0 to 63 loop
--temp(n) := cl1(n)(m) ;
--end loop;
--db_out_var(m) :=  to_integer(unsigned(temp)) ;
--db_out_var_1(m) := temp ;
----db_out_var := std_logic_vector( unsigned(db_out_var) + unsigned(temp)) ;
--end loop;
--db_out <= db_out_var ;
--db_out_1 <= db_out_var_1 ;
--end process;
--dummy_cl2 <= cl2 ;


process (cl9)
--variable db_out_var :  std_logic_vector(63 downto 0) := (others => '0') ;
variable temp : std_logic_vector(63 downto 0) := (others => '0') ;
begin

for m in 0 to 1 loop
for n in 0 to 63 loop
temp(n) := cl9(n)(m) ;
end loop;

if(m = 0) then 
a1 <= temp(31 downto 0) ;
a2 <= temp(63 downto 32) ;
else 
b1 <=  temp(31 downto 0) ;
b2 <= temp(63  downto 32) ;
end if ;

--db_out_var := std_logic_vector( unsigned(db_out_var) + unsigned(temp)) ;

end loop;

end process;

end architecture ;