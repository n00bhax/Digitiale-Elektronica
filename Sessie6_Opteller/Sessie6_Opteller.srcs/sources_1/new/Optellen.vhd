library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 

entity Optellen is
    Port ( A : in signed(4 downto 0);
           B : in signed(4 downto 0);
           C : out signed(4 downto 0)
         );
end Optellen;

architecture Behavioral of Optellen is

attribute use_dsp: string;
attribute use_dsp of C: signal is "yes";

begin

    p_Optelling: process (A,B)
    begin
    
    C <= (A + B);
    
    end process p_Optelling;

end Behavioral;

