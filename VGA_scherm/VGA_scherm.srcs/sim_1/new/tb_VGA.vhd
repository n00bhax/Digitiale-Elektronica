library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Controller is
--  Port ( );
end tb_Controller;

architecture Behavioral of tb_Controller is

COMPONENT Controller
Port (      
    CLK100MHz: in std_logic;
    
    VGA_R: out std_logic_vector (3 downto 0);
    VGA_G: out std_logic_vector (3 downto 0);
    VGA_B: out std_logic_vector (3 downto 0);
    
    VGA_HS: inout std_logic; --inout om buffer te vermijden. anders moet ik speciaal een signaal maken om dat dan hierin te kunnen steken. 
    VGA_VS: inout std_logic
 );
 END COMPONENT;
 
signal simClock: std_logic:='0';

begin

dut : Controller
port map (
          CLK100MHZ => simClock);

stimuli : process
    begin   
    LoopClock: while(true)loop   
            simClock <= not(simClock);
            wait for 5 ns; --periode wordt 10ns => 100Mhz
    end loop;
end process;

end Behavioral;
