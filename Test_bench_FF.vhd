----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.03.2022 15:55:15
-- Design Name: 
-- Module Name: Test_bench - Behavioral
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
use IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Test_bench is
end Test_bench;

architecture testbench_arch of Test_bench is
    component ff_d_syn is
        port(
        in1 : in std_logic;
        out1 : out std_logic;
        clk :in std_logic;
        rst :in std_logic     
        );
    end component;
    constant clk_period :   time    :=10ns;
    signal in1: std_logic := '0';
    signal out1: std_logic := '0';
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';
    begin
        UUT : ff_d_syn
        port map (in1,out1,clk,rst);
        clk_process: process
        begin 
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end process;
        
        stimula_process: process
            begin
                wait for clk_period;
                in1<= '0';
                rst<='0';
                --------Current time: 10ns
                wait for clk_period;
                in1<= '1';  
                ---------Current time:  20ns
                wait for clk_period;
                in1<= '1';
                rst<='1';
                ----------Current time: 30ns
                wait for clk_period;
                ----------Current time: 40ns
                in1<= '0';
                wait for clk_period;
                ----------Current time: 50ns
                assert (false) report "simulation OK." severity failure;
        end process;
    end testbench_arch;
