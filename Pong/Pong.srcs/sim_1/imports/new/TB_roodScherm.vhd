library ieee;
use ieee.std_logic_1164.all;

entity tb_Klok is
end tb_Klok;

architecture tb of tb_Klok is

component VGA
    port (CLK : in std_logic;
          BTNL: in std_logic;
          BTNR: in std_logic;
          BTNU: in std_logic;
          BTND: in std_logic;
          BTNC: in std_logic  );
end component;

signal simClock: std_logic:='0';
signal L: std_logic:='0'; 
signal R: std_logic:='0'; 
signal U: std_logic:='0'; 
signal D: std_logic:='0'; 
signal C: std_logic:='0';    

begin

    dut : VGA
    port map (
              CLK => simClock,
              BTNL => L,
              BTNR => R,
              BTND => D,
              BTNU => U,
              BTNC => C
              );

    stimuli : process
    begin
        L <= '0';
        R <= '0';
        U <= '0';
        D <= '0';
        C <= '0';
              
    LoopClock: while(true)loop
    
            simClock <= not(simClock);
            wait for 5 ns; --periode wordt 10ns => 100Mhz
        
    end loop;
    
    end process;

end tb;
