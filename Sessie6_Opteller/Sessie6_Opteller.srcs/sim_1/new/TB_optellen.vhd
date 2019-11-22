library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_optellen is
--  Port ( );
end TB_optellen;

architecture Behavioral of TB_optellen is

signal A :  integer range 0 to 8;
signal B :  integer range 0 to 16;

component Optellen
port (
          A : in integer range 0 to 8;
          B : in integer range 0 to 16;
          C : out integer range 0 to 16);
end component;

begin

TB_optellen: Optellen port map(
    A => A,
    B => B);
    
p_Stimuli: process
begin 
    A <= 8;
    B <= 7;
    wait for 50 ns;
--    A<= 8;
--    B<= 9;
--    wait for 50 ns;
end process p_Stimuli;
end Behavioral;
