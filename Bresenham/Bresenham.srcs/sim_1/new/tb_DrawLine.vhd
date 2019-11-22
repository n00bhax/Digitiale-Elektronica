library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.textio.all;

entity tb_DrawLine is
--  Port ( );
end tb_DrawLine;

architecture Behavioral of tb_DrawLine is

COMPONENT DrawLine
 Port (    x0 : in STD_LOGIC_VECTOR (9 downto 0);
           y0 : in STD_LOGIC_VECTOR (8 downto 0);
           x1 : in STD_LOGIC_VECTOR (9 downto 0);
           y1 : in STD_LOGIC_VECTOR (8 downto 0);
           Start : in STD_LOGIC;
           CurrentX : out STD_LOGIC_VECTOR (9 downto 0);
           CurrentY : out STD_LOGIC_VECTOR (8 downto 0);
           Plotting : out STD_LOGIC;
           
           CLK : in STD_LOGIC);
        
END COMPONENT;

--internal signals
file testFile: text;

signal x0,x1,CurrX: STD_LOGIC_VECTOR (9 downto 0);
signal y0,y1,CurrY: STD_LOGIC_VECTOR (8 downto 0);
signal Start, Plotting, CLK: STD_LOGIC:= '0';

begin

dut: DrawLine
port map (
            x0 => x0,
            y0 => y0,
            x1 => x1,
            y1 => y1,
            Start => Start, 
            CurrentX => CurrX,
            CurrentY => CurrY,
            Plotting => Plotting,
            
            CLK => CLK
            );
            
process 
    variable inLine    : line;
    variable char     : character;
    variable temp : integer;
    variable cX : integer;
    variable cY : integer;
begin 

    Start <= '1';
    file_open(testFile,"testvector.txt", read_mode);
    readline(testFile,inline);
    read(inline,char);
    readline(testFile,inline);
    
    read(inLine,temp);
        X0 <= std_logic_vector(to_unsigned(temp,10));
        read(inLine,temp);
        Y0 <= std_logic_vector(to_unsigned(temp,9));
        read(inLine,temp);
        X1 <= std_logic_vector(to_unsigned(temp,10));
        read(inLine,temp);
        Y1 <= std_logic_vector(to_unsigned(temp,9));
        
        wait for 10 ns;
        Start <='0';
        wait for 10 ns;
        
    while not endfile(testFile) loop
        wait until Plotting ='1';
                while Plotting = '1' loop -- AND not endfile(testFile)               
                    readLine(testFile,inLine);
                    read(inLine,cX);
                    read(inLine,cY);
                    
                    if(cx/=to_integer(unsigned(currX)) OR cy/=to_integer(unsigned(currY)))
                    then
                         assert false report "Wrong coordinate! Expected (" &
                         integer'image(cX) & ", " & integer'image(cY) & ") but got (" &
                         integer'image(to_integer(unsigned(currX))) & ", " & integer'image(to_integer(unsigned(currY))) & ") instead." severity warning;
                    else 
                         report "OK (" & integer'image(to_integer(unsigned(currX))) & ", " & integer'image(to_integer(unsigned(currY))) & ")";-- severity warning niet nodig, want er is geen probleem. 
                    end if;
                    
                    wait for 40ns;
                end loop;
                
                readline(testFile,inLine);
                read(inLine, char);
                if char /= 'E'
                then
                    assert false report "Line drawing is incomplete!" severity warning;
                end if;

                while char /= 'E'
                loop --blijven lezen tot ge de E tegenkomt
                    readline(testFile,inLine);
                    read(inLine, char);
                    wait for 20 ns;
                end loop;
                
                readline(testFile,inLine);
                read(inLine,char);
                
                Start <= '1';   --Nieuwe lijn testen
                readline(testfile,inLine);
                
                read(inLine,temp);
                    X0 <= std_logic_vector(to_unsigned(temp,10));
                    read(inLine,temp);
                    Y0 <= std_logic_vector(to_unsigned(temp,9));
                    read(inLine,temp);
                    X1 <= std_logic_vector(to_unsigned(temp,10));
                    read(inLine,temp);
                    Y1 <= std_logic_vector(to_unsigned(temp,9));
                            
                wait for 20ns;     
    end loop;

    wait;


end process;

p_Clock: process
begin 
    CLK<= not CLK;
    wait for 10ns; 
end process p_Clock;

end Behavioral;
