----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.03.2022 10:32:29
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    Port ( 
        i_clk     : in std_logic;
        i_start   : in std_logic;
        i_rst     : in std_logic;
        i_data    : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done    : out std_logic;
        o_en      : out std_logic;
        o_we      : out std_logic;
        o_data    : out std_logic_vector(7 downto 0)
    );
end project_reti_logiche;


architecture Behavioral of project_reti_logiche is

    type state_type is (INIZIO,LETTURA_DIM,ATTESA_LETTURA_DIM,LETTURA_BYTE,ATTESA_LETTURA_BYTE,
                        SCRITTURA_BYTE,ATTESA_SCRITTURA_BYTE,FINE);
                        
                        
    signal curr_state,next_state : state_type;
    
    signal o_done_next, o_en_next, o_we_next : std_logic := '0';
    signal o_data_next : std_logic_vector(7 downto 0) := "00000000";
    signal o_address_next : std_logic_vector(15 downto 0) := "0000000000000000";
    
    signal got_dim_ing, got_dim_ing_next : boolean := false;
    signal state: STATE_TYPE := INIZIO;
begin






    transition: process(i_clK)
    begin
        --qua ci andr� il clk in qualche modo 
        --
        --
        --
        --
        if i_rst = '1' then
        --resetta il tutto
            state <= INIZIO;
        else 
            case state is  
            
                 when INIZIO =>
                 -- qua dovremo fare dei reset
                 if i_start = '1' then
                 --inzia il processo
                    state <= LETTURA_DIM;
                 else
                 --aspetta il segnale d'inizio
                    state <= INIZIO;
                 end if; 
                 
                 when LETTURA_DIM =>
                 --Abilita la memoria
                 o_en <= '1';
          end case;   
        end if;
    end process;
end architecture;
