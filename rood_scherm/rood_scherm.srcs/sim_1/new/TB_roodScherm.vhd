library ieee;
use ieee.std_logic_1164.all;

entity tb_Klok is
end tb_Klok;

architecture tb of tb_Klok is

component roodScherm
    port (CLK : in std_logic);
end component;

signal simClock: std_logic:='0';
    
begin

    dut : roodScherm
    port map (
              CLK => simClock
              );

    stimuli : process
    begin
    
    LoopClock: while(true)loop
    
            simClock <= not(simClock);
            wait for 5 ns; --periode wordt 10ns => 100Mhz
        
    end loop;
    
    end process;

end tb;
