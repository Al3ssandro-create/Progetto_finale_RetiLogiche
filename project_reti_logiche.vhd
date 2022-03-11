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
                        
                        
    

    
    signal state: STATE_TYPE := INIZIO;
    signal has_dim: boolean := false;                                                --ha trovato la dimensione
    signal has_byte: boolean := false;                                           
    signal MAX_DIM_ING: unsigned (7 downto 0 ) := (others => '1');                  --Dimensione massima ingresso 255
    signal last_byte_address: std_logic_vector(15 downto 0 ) := (others => '0');    --indirizzo ultimo byte letto
    signal current_byte_address: std_logic_vector(15 downto 0 ) := (others => '0'); --indirizzo byte corrente
    signal current_byte: unsigned(7 downto 0):= (others => '0');                 --byte corrente

begin


    Case_scenario: process(i_clk)
    variable var_dim : unsigned(7 downto 0) := (others => '0');
    begin
        if rising_edge(i_clk) then
            o_done <= '0';
            o_en <= '0';
            o_we <= '0';
            o_data    <= (others => '0');
            o_address <= (others => '0');
            if i_rst = '1' then
            --resetta il tutto
                state <= INIZIO;
            else 
                case state is  
                
                    when INIZIO =>
                    -- qua facciamo i reset
                        has_dim <= false;
                        MAX_DIM_ING <= (others => '1');
                        last_byte_address <= (others => '0');
                        current_byte_address <= "0000000000000001";
                        if i_start = '1' then
                        --inzia il processo se c'è il segnale d'inzio
                            state <= LETTURA_DIM;
                        else
                        --aspetta il segnale d'inizio
                            state <= INIZIO;
                        end if; 
                        
                    when LETTURA_DIM =>
                        --Abilita la memoria
                        o_en <= '1';
                        if not has_dim then
                            --vado a prendere la dimensione
                            o_address <= "0000000000000000";
                            state <= ATTESA_LETTURA_DIM;
                            has_dim <= true;
                        else
                            var_dim := unsigned(i_data); --# di parole
                            if not (var_dim = "00000000") then
                            --continuerà
                            --
                            --
                                state <= LETTURA_BYTE;
                            else
                                o_done <= '1';
                                state <= FINE;  
                            end if;    
                        end if;
                    
                    when ATTESA_LETTURA_DIM =>
                        state <= LETTURA_DIM;
                    
                    when LETTURA_BYTE =>
                        o_en <='1';
                        if not has_byte then
                            o_address <= current_byte_address;
                            state <= ATTESA_LETTURA_BYTE;
                            has_dim <= true;
                        else
                            current_byte <= unsigned(i_data);
                            --case scenario
                        end if;
                            









                    when ATTESA_LETTURA_BYTE =>
                        state <= LETTURA_BYTE;

                    
                    



                        


                 






                end case;
            end if;
        end if;
    end process Case_scenario;
end architecture;