
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM is
    Port (
        clk: in std_logic;
        rst: in std_logic;
        in1: in std_logic;
        out1: out std_logic;
        out2: out std_logic
     );
end FSM;



architecture Behavioral of FSM is

    type state_type is (S00,S01,S10,S11);
    
    signal current_state,next_state: state_type;
   
    begin
        
        sync_proc: process(clk,rst,next_state)
        begin
            if(rst='1') then
                current_state <= S00;
            elsif(rising_edge(clk)) then
                current_state <= next_state;
            end if;
                  
        end process sync_proc;
        
        conc_proc: process(clk,rst,current_state,in1)
        begin
            case current_state is
                when S00 =>
                    if(in1='0') then
                        next_state <= S00;
                        out1 <= '0';
                        out2 <= '0';
                    else
                        next_state <= S10;
                        out1 <= '1';
                        out2 <= '1';
                    end if;
                when S01 =>
                    if(in1='0') then
                        next_state <= S00;
                        out1 <= '1';
                        out2 <= '1';
                    else
                        next_state <= S10;
                        out1 <= '0';
                        out2 <= '0';
                    end if;
                when S10 =>
                    if(in1='0') then
                        next_state <= S01;
                        out1 <= '0';
                        out2 <= '1';
                    else
                        next_state <= S11;
                        out1 <= '1';
                        out2 <= '0';
                    end if;
                when S11 =>
                    if(in1='0') then
                        next_state <= S01;
                        out1 <= '1';
                        out2 <= '0';
                    else
                        next_state <= S11;
                        out1 <= '0';
                        out2 <= '1';
                    end if;
             end case;

        end process conc_proc;
          
        

end Behavioral;
