--Willem Van der Elst
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.willem.all;

entity VGA_RGB is
Port (      
    CLK100MHz: in std_logic;
    
    VGA_R: out std_logic_vector (3 downto 0);
    VGA_G: out std_logic_vector (3 downto 0);
    VGA_B: out std_logic_vector (3 downto 0);
    
    VGA_HS: out std_logic; 
    VGA_VS: out std_logic;  
                       
    addrb0 : OUT STD_LOGIC_VECTOR(18 DOWNTO 0);
    doutb0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
                     
    addrb1 : OUT STD_LOGIC_VECTOR(18 DOWNTO 0);
    doutb1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    
    WritingInVidmem0: in STD_LOGIC;
    WritingInVidmem1: in STD_LOGIC;
    
    klaar0Out: out STD_LOGIC;
    klaar1Out: out STD_LOGIC;
    
    SW: in STD_LOGIC;
    
    pxlClock: OUT STD_LOGIC;
    
    LED: out std_logic_vector (15 downto 7)
 );

end VGA_RGB;

architecture Behavioral of VGA_RGB is

--------------------------------------------------------------
--SIGNALS--
--------------------------------------------------------------
signal VideoActive: std_logic;
signal PixelClock: std_logic;
signal s_addrb0: STD_LOGIC_VECTOR(18 DOWNTO 0):= (others => '0'); --nodig omdat een out niet gelezen kan worden. 
signal s_addrb1: STD_LOGIC_VECTOR(18 DOWNTO 0):= (others => '0'); --nodig omdat een out niet gelezen kan worden. 
--signal s_VGA_HS: std_logic; 
--signal s_VGA_VS: std_logic;
signal klaar0: STD_LOGIC:='1';
signal klaar1: STD_LOGIC:='1';
signal BlockTillDecentFrame: STD_LOGIC:='1';

begin


addrb0 <= s_addrb0;
addrb1 <= s_addrb1;
klaar0Out <= klaar0;
klaar1Out <= klaar1;
--------------------------------------------------------------
--PORT MAPS--
--------------------------------------------------------------
VGATiming_map: VGATiming
 PORT MAP (
    VideoActive => VideoActive,
    VGA_HS => VGA_HS,
    VGA_VS => VGA_VS,
    
    CLK100MHz => CLK100MHz,
    PixelClock => PixelClock
    );
    
pxlClock <= PixelClock;
--------------------------------------------------------------
--PROCESSES--
--------------------------------------------------------------
p_Display: process(VideoActive,doutb0,doutb1,WritingInVidmem0,WritingInVidmem1) is 
begin
    if VideoActive='1' then 
        if WritingInVidmem0='0' then 
            if (doutb0(0 downto 0)="1") then --werkt niet als ik niet downto gebruik
                VGA_B<="1111";
            else 
                VGA_B<="0000";
            end if;
            
            if (doutb0(1 downto 1)="1") then 
                VGA_G<="1111";
            else 
                VGA_G<="0000";
            end if;
            
            if (doutb0(2 downto 2)="1") then 
                VGA_R<="1111";
            else 
                VGA_R<="0000";
            end if;
        elsif WritingInVidmem1='0' then
            if (doutb1(0 downto 0)="1") then 
                VGA_B<="1111";
            else 
                VGA_B<="0000";
            end if;
            
            if (doutb1(1 downto 1)="1") then 
                VGA_G<="1111";
            else 
                VGA_G<="0000";
            end if;
            
            if (doutb1(2 downto 2)="1") then 
                VGA_R<="1111";
            else 
                VGA_R<="0000";
            end if;
        else  
            VGA_R<="0000";
            VGA_G<="0000";
            VGA_B<="0000"; 
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
        if SW='0'  then     
            LED(15) <='1';  
            LED(14) <='0';  
            if (to_integer(unsigned(s_addrb0)) = 307199) then --0 tot 307199 is 307200 plaatsen in totaal 
                s_addrb0 <= (others => '0');
                klaar0 <= '1';
            else 
                s_addrb0 <= std_logic_vector(to_unsigned((to_integer(unsigned(s_addrb0))+1),19)); --addrb +1 doen. Hiervoor moet veel omgevormd worden.  
                klaar0 <= '0';
                BlockTillDecentFrame <='0'; --vanaf nu alleen goeie frames met driehoeken in. 
            end if;
        elsif SW='1' and BlockTillDecentFrame/='1' then --elsif wel juist? gaat nu niet de eerste if voorang krijgen.
            LED(14) <='1'; 
            LED(15) <='0';   
            if (to_integer(unsigned(s_addrb1)) = 307199) then --0 tot 307199 is 307200 plaatsen in totaal 
                s_addrb1 <= (others => '0');
                klaar1 <= '1';
            else 
                s_addrb1 <= std_logic_vector(to_unsigned((to_integer(unsigned(s_addrb1))+1),19)); --addrb +1 doen. Hiervoor moet veel omgevormd worden.  
                klaar1 <= '0';
            end if;
        end if;
    end if; 
end if;
end process p_Addr;

end Behavioral;
