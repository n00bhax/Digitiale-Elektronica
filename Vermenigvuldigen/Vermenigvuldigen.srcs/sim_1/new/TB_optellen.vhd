library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_vermenigvuldigen is
--  Port ( );
end TB_vermenigvuldigen;

architecture Behavioral of TB_vermenigvuldigen is

signal A :  integer range 0 to 8;
signal B :  integer range 0 to 8;


component Vermenigvuldigen
port (
          A : in integer range 0 to 8;
          B : in integer range 0 to 8;
          C : out integer range 0 to 16);
end component;

begin

TB_Vermenigvuldigen: Vermenigvuldigen port map(
    A => A,
    B => B
    );
    
p_Stimuli: process
begin 
    A <= 4;
    B <= 2;
    wait for 50 ns;

end process p_Stimuli;
end Behavioral;
