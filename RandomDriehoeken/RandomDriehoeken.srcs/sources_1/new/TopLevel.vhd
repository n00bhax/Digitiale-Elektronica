--Willem Van der Elst
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.willem.all;

entity TopLevel is
Port (      
    CLK100MHz: in std_logic;
    
    VGA_R: out std_logic_vector (3 downto 0);
    VGA_G: out std_logic_vector (3 downto 0);
    VGA_B: out std_logic_vector (3 downto 0);
    
    VGA_HS: out std_logic; 
    VGA_VS: out std_logic;
    
    LED: out std_logic_vector (15 downto 0);
    SW: in std_LOGIC
 );

end TopLevel;

architecture Behavioral of TopLevel is
--------------------------------------------------------------
--SIGNALS--
--------------------------------------------------------------
signal PixelClock: std_logic;

signal wea0 : STD_LOGIC_VECTOR(0 DOWNTO 0);
signal addra0 : STD_LOGIC_VECTOR(18 DOWNTO 0);
signal dina0 : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal addrb0 : STD_LOGIC_VECTOR(18 DOWNTO 0);
signal doutb0 : STD_LOGIC_VECTOR(2 DOWNTO 0);

signal wea1 : STD_LOGIC_VECTOR(0 DOWNTO 0);
signal addra1 : STD_LOGIC_VECTOR(18 DOWNTO 0);
signal dina1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal addrb1 : STD_LOGIC_VECTOR(18 DOWNTO 0);
signal doutb1 : STD_LOGIC_VECTOR(2 DOWNTO 0);

signal WritingInVidmem0: STD_LOGIC;
signal WritingInVidmem1: STD_LOGIC;
signal klaar0: STD_LOGIC;
signal klaar1: STD_LOGIC;



begin
--------------------------------------------------------------
--PORT MAPS--
--------------------------------------------------------------
VideMemory0: VideoMemory
  PORT MAP (
    clka => CLK100MHz, 
    wea => wea0,
    addra => addra0,
    dina => dina0,
    douta => open, --niet nodig
    clkb => PixelClock, 
    web => "0",  --niet nodig
    addrb => addrb0,
    dinb => "000", --niet nodig
    doutb => doutb0
  );
  
VideMemory1: VideoMemory
  PORT MAP (
    clka => CLK100MHz, 
    wea => wea1,
    addra => addra1,
    dina => dina1,
    douta => open, --niet nodig
    clkb => PixelClock, 
    web => "0", --niet nodig
    addrb => addrb1,
    dinb => "000", --niet nodig
    doutb => doutb1
  );  

Triangles_map: Triangles
  PORT MAP (
    CLK100MHz => CLK100MHz,
    wea0 => wea0,
    addra0 => addra0,
    dina0 => dina0,   
    wea1 => wea1,
    addra1 => addra1,
    dina1 => dina1,
    
    WritingInVidmem0 => WritingInVidmem0,
    WritingInVidmem1 => WritingInVidmem1,
    klaar0 => klaar0, 
    klaar1 => klaar1, 
    
    SW => SW,
    LED => LED(6 downto 0)
  );
  
VGA_RGB_map: VGA_RGB
  PORT MAP (
        CLK100MHz => CLK100MHz,
      
        VGA_R => VGA_R,
        VGA_G => VGA_G,
        VGA_B => VGA_B,
       
        VGA_HS => VGA_HS,
        VGA_VS => VGA_VS,
        
        addrb0 => addrb0,
        doutb0 => doutb0 ,
       
        addrb1 => addrb1,
        doutb1 => doutb1,
        
        WritingInVidmem0 => WritingInVidmem0,
        WritingInVidmem1 => WritingInVidmem1,
        klaar0Out => klaar0,
        klaar1Out => klaar1,
        
        pxlClock => PixelClock,
        SW => SW,
        
        LED => LED(15 downto 7)
      );

end Behavioral;
