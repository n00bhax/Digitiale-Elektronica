--Willem Van der Elst
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Controller is
Port (      
    CLK100MHz: in std_logic;
    
    VGA_R: out std_logic_vector (3 downto 0);
    VGA_G: out std_logic_vector (3 downto 0);
    VGA_B: out std_logic_vector (3 downto 0);
    
    VGA_HS: inout std_logic; --inout om buffer te vermijden. anders moet ik speciaal een signaal maken om dat dan hierin te kunnen steken. 
    VGA_VS: inout std_logic
 );

end Controller;

architecture Behavioral of Controller is
--------------------------------------------------------------
--COMPONENTS--
--------------------------------------------------------------
COMPONENT VideoMemory
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    clkb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END COMPONENT;

COMPONENT VGATiming
 PORT ( 
        CLK100MHz: in std_logic;
        VGA_HS: out std_logic;
        VGA_VS: out std_logic;            
        VideoActive: out std_logic;
        PixelClock: out std_logic
    );
END COMPONENT;

--------------------------------------------------------------
--SIGNALS--
--------------------------------------------------------------
signal doutb: STD_LOGIC_VECTOR(2 DOWNTO 0);

signal VideoActive: std_logic;
signal PixelClock: std_logic;

signal addrb: std_logic_vector(18 downto 0):= "0000000000000000000";

begin

--------------------------------------------------------------
--PORT MAPS--
--------------------------------------------------------------
VideMemory_map: VideoMemory
  PORT MAP (
    clka => '0', --overal brol in zetten omdat ik dit nu nog niet moet gebruiken. 
    wea => "0",
    addra => "0000000000000000000",
    dina => "000",
    douta => open,
    clkb => PixelClock, 
    web => "0", 
    addrb => addrb,
    dinb => "000",
    doutb => doutb
  );

VGATiming_map: VGATiming
 PORT MAP (
    VideoActive => VideoActive,
    VGA_HS => VGA_HS,
    VGA_VS => VGA_VS,
    
    CLK100MHz => CLK100MHz,
    PixelClock => PixelClock
    );
--------------------------------------------------------------
--PROCESSES--
--------------------------------------------------------------
p_Display: process(VideoActive,doutb) is 
begin
    if VideoActive='1' then 
        if (doutb(0 downto 0)="1") then --werkt niet als ik niet downto gebruik
            VGA_B<="1111";
        else 
            VGA_B<="0000";
        end if;
        
        if (doutb(1 downto 1)="1") then 
            VGA_G<="1111";
        else 
            VGA_G<="0000";
        end if;
        
        if (doutb(2 downto 2)="1") then 
            VGA_R<="1111";
        else 
            VGA_R<="0000";
        end if;
    else  
        VGA_R<="0000";
        VGA_G<="0000";
        VGA_B<="0000"; 
    end if;
end process p_Display;

p_Addr: process(pixelclock) is
begin 

if rising_edge(pixelclock) then 
    if VideoActive='1' then 
        if (to_integer(unsigned(addrb)) = 307199) then --0 tot 307199 is 307200 plaatsen in totaal 
            addrb <= std_logic_vector(to_unsigned(0,19));
        else 
            addrb <= std_logic_vector(to_unsigned((to_integer(unsigned(addrb))+1),19)); --addrb +1 doen. Hiervoor moet veel omgevormd worden.  
        end if;
    end if; 
end if;
end process p_Addr;

end Behavioral;
