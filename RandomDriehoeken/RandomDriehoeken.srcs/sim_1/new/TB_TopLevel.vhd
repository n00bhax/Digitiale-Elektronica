library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_TopLevel is
--  Port ( );
end TB_TopLevel;

architecture Behavioral of TB_TopLevel is

COMPONENT TopLevel
Port (      
    CLK100MHz: in std_logic;
    
    VGA_R: out std_logic_vector (3 downto 0);
    VGA_G: out std_logic_vector (3 downto 0);
    VGA_B: out std_logic_vector (3 downto 0);
    
    VGA_HS: out std_logic; 
    VGA_VS: out std_logic;
    
    SW: in std_LOGIC
 );
END COMPONENT;

signal simClock: std_logic:='1';
signal SW: STD_LOGIC:='0';
begin

dut : TopLevel
port map (
          CLK100MHZ => simClock,
          SW => SW
          );

stimuli : process
    begin   
    LoopClock: while(true)loop   
            simClock <= not(simClock);
            wait for 5 ns; --periode wordt 10ns => 100Mhz
    end loop;
end process;

end Behavioral;

