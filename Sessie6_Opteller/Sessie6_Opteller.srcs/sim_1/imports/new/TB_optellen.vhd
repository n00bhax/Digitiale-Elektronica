library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_optellen is
--  Port ( );
end TB_optellen;

architecture Behavioral of TB_optellen is

signal A :  signed(4 downto 0);
signal B :  signed(4 downto 0);

component Optellen
port (
          A : in signed(4 downto 0);
          B : in signed(4 downto 0);
          C : out signed(4 downto 0));
end component;

begin

TB_optellen: Optellen port map(
    A => A,
    B => B);
    
p_Stimuli: process
begin 
    A <= "01111";
    B <= "00010";
    wait for 50 ns;

end process p_Stimuli;
end Behavioral;
