library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity roodScherm is
  Generic (
            g_Vvisible : integer := 480;
            g_Vfront   : integer := 10;
            g_Vback    : integer := 33;
            g_Vsync    : integer := 2;
            g_Vframe    : integer := 525;
            
            g_Hvisible : integer := 640;
            g_Hfront   : integer := 16;
            g_Hsync    : integer := 96;
            g_Hback    : integer := 48;
            g_Hline    : integer := 800);
                
  Port ( 
        CLK: in std_logic;
        VGA_R: out std_logic_vector (3 downto 0);
        VGA_G: out std_logic_vector (3 downto 0);
        VGA_B: out std_logic_vector (3 downto 0);
        
        VGA_HS: out std_logic;
        VGA_VS: out std_logic     
        );
end roodScherm;

architecture Behavioral of roodScherm is

component clk_wiz_0
    port
     (-- Clock out ports
      clk_25Mhz          : out   std_logic;
      clk_in1           : in     std_logic
     );
end component;

signal pixelClock: std_logic;
signal Hcount: integer range 0 to g_Hline  :=0;
signal Vcount: integer range 0 to g_Vframe :=0;
signal HS: std_logic :='0';                         --duidt aan of een sync bezig is. 0 is nee ,1 is ja
signal VS: std_logic :='0';
signal Hok: std_logic :='0';                        --is 0 tijdens back porches enzo
signal Vok: std_logic :='0';
signal videoActive: std_logic :='0';                --is 1 als Hok en Vok 1 zijn

begin

VGA_G<="0000";
VGA_B<="0000";

VGA_HS <= HS;
VGA_VS <= VS;  
videoActive <= Vok and Hok and HS and VS;

clock : clk_wiz_0 
    port map ( 
            -- Clock out ports  
    clk_25Mhz => pixelClock,
            -- Clock in ports
    clk_in1  => CLK 
    );      
    
                    
p_pixelClock: process (pixelClock) is
begin 
    if rising_edge(pixelClock) then -- stijgende flank van klok    
            
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
end process p_pixelClock;

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

p_SendPixels: process (videoActive) is
begin

    if(videoActive='1') then
        VGA_R<="1111";
    else
        VGA_R<="0000";
    end if;
end process p_SendPixels;

end Behavioral;
