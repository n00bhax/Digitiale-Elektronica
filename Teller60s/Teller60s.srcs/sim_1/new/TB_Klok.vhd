library ieee;
use ieee.std_logic_1164.all;

entity tb_Klok is
end tb_Klok;

architecture tb of tb_Klok is

    component Klok
        port (AN        : out std_logic_vector (7 downto 0);
              CA        : out std_logic;
              CB        : out std_logic;
              CC        : out std_logic;
              CD        : out std_logic;
              CE        : out std_logic;
              CF        : out std_logic;
              CG        : out std_logic;
              CLK100MHZ : in std_logic);
    end component;

--    signal AN        : std_logic_vector (7 downto 0);
--    signal CA        : std_logic;
--    signal CB        : std_logic;
--    signal CC        : std_logic;
--    signal CD        : std_logic;
--    signal CE        : std_logic;
--    signal CF        : std_logic;
--    signal CG        : std_logic;
--    signal CLK100MHZ : std_logic;
    
--    signal i: integer range 0 to 300000000 :=0;
    signal simClock: std_logic:='0';
    
begin

    dut : Klok
    port map (--AN        => AN,
--              CA        => CA,
--              CB        => CB,
--              CC        => CC,
--              CD        => CD,
--              CE        => CE,
--              CF        => CF,
--              CG        => CG,
              CLK100MHZ => simClock
              );

    stimuli : process
    begin
    
    LoopClock: while(true)loop
    
            simClock <= not(simClock);
            wait for 5 ns; --periode wordt 10ns => 100Mhz
        
    end loop;
    
    end process;

end tb;
