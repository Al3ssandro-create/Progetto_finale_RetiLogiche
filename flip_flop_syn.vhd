----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.03.2022 15:24:16
-- Design Name: 
-- Module Name: ff_d_syn - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ff_d_syn is
    port(
        in1 : in std_logic;
        out1 : out std_logic;
        clk :in std_logic;
        rst :in std_logic     
    );
end ff_d_syn;

architecture Behavioral of ff_d_syn is
    begin 
        process (clk, rst)
        begin  
            if rising_edge(clk) then 
                if rst= '1' then
                 out1 <= '0';
                else   
                    out1 <= in1;
                end if;
            end if;
        end process;
end Behavioral;
