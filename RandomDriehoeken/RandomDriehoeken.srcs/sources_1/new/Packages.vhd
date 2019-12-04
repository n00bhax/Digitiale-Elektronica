library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

package willem is 
    component LFSR57 is 
      Port (
        Sequence : out STD_LOGIC_VECTOR(56 downto 0);
        CLK: in STD_LOGIC);
    end component LFSR57;
    
    component DrawLine is 
      Port ( 
        x0 : in STD_LOGIC_VECTOR (9 downto 0);
        y0 : in STD_LOGIC_VECTOR (8 downto 0);
        x1 : in STD_LOGIC_VECTOR (9 downto 0);
        y1 : in STD_LOGIC_VECTOR (8 downto 0);
        Start : in STD_LOGIC;
        CurrentX : out STD_LOGIC_VECTOR (9 downto 0);
        CurrentY : out STD_LOGIC_VECTOR (8 downto 0);
        Plotting : out STD_LOGIC;
        
        CLK: in STD_LOGIC);
    end component DrawLine;
    
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
        PixelClock: out std_logic;
        FirstFrameReady: in STD_LOGIC
        );
    END COMPONENT;
    
    COMPONENT TriangleFifo
     PORT (
        clk: in STD_LOGIC;
        srst: in STD_LOGIC;
     
        din: in STD_LOGIC_VECTOR (58 downto 0); --deze 2 moeten naar de fifo
        wr_en: in STD_LOGIC;
        
        dout: out STD_LOGIC_VECTOR (58 downto 0); --deze komen uit de fifo
        rd_en: in STD_LOGIC;
        full: out STD_LOGIC;
        empty: out STD_LOGIC
        
      
           );
     END COMPONENT;
     
    COMPONENT Triangles
     Port ( 
        CLK100MHz: in STD_LOGIC;
        
        wea0 : out STD_LOGIC_VECTOR(0 DOWNTO 0);    
        addra0 : out STD_LOGIC_VECTOR(18 DOWNTO 0); 
        dina0 : out STD_LOGIC_VECTOR(2 DOWNTO 0);   
                                                
        wea1 : out STD_LOGIC_VECTOR(0 DOWNTO 0);    
        addra1 : out STD_LOGIC_VECTOR(18 DOWNTO 0); 
        dina1 : out STD_LOGIC_VECTOR(2 DOWNTO 0);
        
        FirstFrameReady: out STD_LOGIC;
        klaar0: in STD_LOGIC;
        klaar1: in STD_LOGIC;
        
        LED: out std_logic_vector (6 downto 0);
        SW: in STD_LOGIC
         
        );
    END COMPONENT;
    
    COMPONENT VGA_RGB
     PORT (
        CLK100MHz: in std_logic;
        
        VGA_R: out std_logic_vector (3 downto 0);
        VGA_G: out std_logic_vector (3 downto 0);
        VGA_B: out std_logic_vector (3 downto 0);
        
        VGA_HS: out std_logic; 
        VGA_VS: out std_logic;  
  
        addrb0 : OUT STD_LOGIC_VECTOR(18 DOWNTO 0);    
        doutb0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);  --niet nodig toch? 
                              
        addrb1 : OUT STD_LOGIC_VECTOR(18 DOWNTO 0);      
        doutb1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        
        FirstFrameReady: in STD_LOGIC;
        
        klaar0Out: out STD_LOGIC;
        klaar1Out: out STD_LOGIC;
        
        pxlClock: OUT STD_LOGIC;
        SW: in STD_LOGIC;
        
        LED: out std_logic_vector ( 15 downto 7)  
      );
    END COMPONENT;
                                                                                                                                                          
end willem;