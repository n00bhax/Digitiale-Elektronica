library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGATiming is
  Generic (
        g_Vvisible : integer := 480;
        g_Vfront   : integer := 10;
        g_Vback    : integer := 33;
        g_Vsync    : integer := 2;
        g_Vframe   : integer := 525;
        
        g_Hvisible : integer := 640;
        g_Hfront   : integer := 16;
        g_Hsync    : integer := 96;
        g_Hback    : integer := 48;
        g_Hline    : integer := 800
        );
        
  Port ( 
        CLK100MHz: in std_logic;
        VGA_HS: out std_logic;
        VGA_VS: out std_logic;              
        VideoActive: out std_logic;
        PixelClock: out std_logic;     
        
        FirstFrameReady: in STD_LOGIC
        );
end VGATiming;

architecture Behavioral of VGATiming is
--------------------------------------------------------------
--COMPONENTS--
--------------------------------------------------------------
component ClockingWizard
    port
     (
      PixelClk          : out   std_logic;
      Clk100MHz         : in     std_logic --maakt van 100mhz een klok met andere snelheid. 
     );
end component;

--------------------------------------------------------------
--SIGNALS--
--------------------------------------------------------------    
signal pixelClk: std_logic;
signal Hcount: integer range 0 to g_Hline  :=0;
signal Vcount: integer range 0 to g_Vframe :=0;
signal HS: std_logic :='0';                         --duidt aan of een sync bezig is. 0 is nee ,1 is ja
signal VS: std_logic :='0';

signal Hok: std_logic :='0';                        --is 0 tijdens back porches enzo
signal Vok: std_logic :='0';
    
signal x: integer range -g_Hback to g_Hline;    
signal y: integer range -g_Vback to g_Vframe;   

begin
--------------------------------------------------------------
--PORT MAPS--
--------------------------------------------------------------
clock : ClockingWizard
    port map ( 
            -- Clock out ports  
    PixelClk => PixelClk  ,
            -- Clock in ports
    Clk100MHz  => Clk100MHz
    );   
        
--------------------------------------------------------------
--PROCESSES--
-------------------------------------------------------------- 
VGA_HS <= HS;
VGA_VS <= VS;  
videoActive <= Vok and Hok and HS and VS;    
x <= Hcount-g_Hback;
y <= Vcount-g_Vback;   
PixelClock <= pixelclk;       
    
p_PixelClk  : process (PixelClk, FirstFrameReady) is
begin 
    if rising_edge(PixelClk) and FirstFrameReady='1' then -- stijgende flank van klok    
            
        if Hcount>=800 then --elektronen moeten terug naar links gericht worden.
            Hcount <= 0;  
            
            if Vcount>=g_Vframe then
                Vcount<=0;
            else
                Vcount <= Vcount + 1; 
            end if;
            
        else 
            Hcount <= Hcount+1;
        end if;
    end if;        
end process p_PixelClk  ;

p_Hsync: process (Hcount) is
begin
    if Hcount <= g_Hback then 
        Hok<='0';
        HS <= '1';  --Hsync is klaar
      
    elsif Hcount<= g_Hback + g_Hvisible then
        Hok <='1'; --output mag beginnnen.
        HS <= '1';
        
    elsif Hcount <= g_Hback + g_Hvisible + g_Hfront then 
        Hok <= '0';
        HS <= '1';
        
    else --elsif Hcount <= g_Hback + g_Hvisible + g_Hfront + g_Hsync then 
        Hok<='0';
        HS<='0'; --Hsync is bezig 

    end if;

end process p_Hsync;

p_Vsync: process (Vcount,Hcount) is
begin

    if Vcount <= g_Vback then        
        Vok<='0';
        VS <='1'; --sync is klaar
        
    elsif Vcount <= g_Vback + g_Vvisible then
        Vok <='1';   
        VS <='1';
        
    elsif Vcount <= g_Vback + g_Vvisible + g_Vfront then 
        Vok <= '0';
        VS <='1';
        
    else --sync begint  elsif Vcount <= g_Vback + g_Vvisible + g_Vfront +g_Vsync then 
        Vok <= '1';
        VS <='0';   --sync begint          
    end if;
    
end process p_Vsync;

end Behavioral;
