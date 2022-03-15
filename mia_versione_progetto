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
    signal has_byte: boolean := false;                                              --ha letto il byte
    signal MAX_DIM_ING: unsigned (7 downto 0 ) := (others => '1');                  --Dimensione massima ingresso 255
    signal last_byte_address: std_logic_vector(15 downto 0 ) := (others => '0');    --indirizzo ultimo byte letto
    signal current_byte_address: std_logic_vector(15 downto 0 ) := (others => '0'); --indirizzo byte corrente
    --signal current_byte: unsigned(7 downto 0):= (others => '0');                 --byte corrente
    signal stato_conv: std_logic_vector(0 to 1) := (others => '0');              --stato convolutore

    procedure init_loop(
        signal o_address : out std_logic_vector(15 downto 0);
        signal current_byte_address: out std_logic_vector(15 downto 0)) is
    begin
        --inizializzo gli indirizzi
        o_address <= "0000000000000001";
        current_byte_address <="0000000000000001";
    end procedure;    

begin

    Case_scenario: process(i_clk)
    --variabile per tenere a mente il valore durante i calcoli
    variable var : unsigned(7 downto 0) := (others => '0');
    --variabile per memorizzare l'uscita
    variable uscita: unsigned(0 to 15) := (others => '0');
    --contatore
    variable count : integer := 7;
    variable i : integer := 0;
    variable j : integer := 0;

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
                        has_byte <=false;
                        MAX_DIM_ING <= (others => '1');
                        last_byte_address <= (others => '0');
                        current_byte_address <= (others => '0');
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
                            var := unsigned(i_data);
                            if not (var = "0000000000000000") then
                                --settiamo il limite
                                last_byte_address <= std_logic_vector(var+1);
                                init_loop(o_address,current_byte_address);
                                state <= LETTURA_BYTE;
                            else
                                o_done <= '1';
                                state <= FINE;  
                            end if;    
                        end if;
                    
                    when ATTESA_LETTURA_DIM =>
                        state <= LETTURA_DIM;
                    
                    when LETTURA_BYTE =>
                        --calcolo nuovo indirizzo
                        var := unsigned(current_byte_address)+1;
                        --controllo se tutti i byte sono stati letti
                        if not(std_logic_vector(var)=last_byte_address) then --se non sono ancora stati letti tutti
                            --aggiorno gli indirizzi
                            current_byte_address <= std_logic_vector(var);
                            o_address <= std_logic_vector(var+1);
                            --attivo la memoria
                            o_en <='1';
                            state <= ATTESA_LETTURA_BYTE;
                        else --ho letto tutti i byte
                            if not has_dim then
                                has_dim <= true;
                                o_en <= '1';
                                init_loop(o_address,current_byte_address);
                                state <= ATTESA_LETTURA_BYTE;
                            else 
                                o_done <='1';
                                state <= FINE;
                            end if;
                        end if;

                    when ATTESA_LETTURA_BYTE =>
                        if not has_dim then
                            state <= LETTURA_BYTE;
                        else 
                            state <= SCRITTURA_BYTE;
                        end if;

                    when SCRITTURA_BYTE =>
                        if(i<16) then
                            --convolutore
                            if(stato_conv = '00' and i_data(count) = '0') then
                                stato_conv <= '00';
                                --salvo stringa tradotta
                                uscita(i) := '0';
                                i := i+1;
                                uscita(i) := '0';
                                i := i+1;
                            elsif(stato_conv = '00' and i_data(count)= '1') then
                                stato_conv <= '10';
                                --salvo stringa tradotta
                                uscita(i) := '1';
                                i := i+1;
                                uscita(i) := '1';
                                i := i+1;
                            elsif(stato_conv = '10' and i_data(count)= '0') then
                                stato_conv <= '01';
                                --salvo stringa tradotta
                                uscita(i) := '0';
                                i := i+1;
                                uscita(i) := '1';
                                i := i+1;
                            elsif(stato_conv = '10' and i_data(count)= '1') then 
                                stato_conv <= '11';
                                --salvo stringa tradotta
                                uscita(i) := '1';
                                i := i+1;
                                uscita(i) := '0';
                                i := i+1;
                            elsif(stato_conv = '01' and i_data(count)= '0') then
                                stato_conv <= "00";
                                --salvo stringa tradotta
                                uscita(i) := '1';
                                i := i+1;
                                uscita(i) := '1';
                                i := i+1;
                            elsif(stato_conv = '01' and i_data(count)= '1') then
                                stato_conv <= "10";
                                --salvo stringa tradotta
                                uscita(i) := '0';
                                i := i+1;
                                uscita(i) := '0';
                                i := i+1;
                            elsif(stato_conv = '11' and i_data(count)= '0') then 
                                stato_conv <= '01';
                                --salvo stringa tradotta
                                uscita(i) := '1';
                                i := i+1;
                                uscita(i) := '0';
                                i := i+1;
                            elsif(stato_conv = '11' and i_data(count)= '1') then 
                                stato_conv <= '11';
                                --salvo stringa tradotta
                                uscita(i) := '0';
                                i := i+1;
                                uscita(i) := '1';
                                i := i+1;
                            end if;
                            --decremento count cosi al prox ciclo di clock leggo il bit successivo
                            count := count - 1; 
                        else
                            --ora ho i due byte pronti per essere scritti in memoria
                            -- attivo la memoria
                            o_en <= '1';
                            -- attivo segnale di scrittura
                            o_we <= '1';
                            if(j=0) then -- per scrivere il primo byte del vettore uscita
                                --devo settare l'indirizzo di scrittura
                                o_data <= uscita(0 to 7);
                                j := j+1;
                            else -- per scrivere il secondo byte del vettore uscita
                                --devo settare l'indirizzo di scrittura
                                o_data <= uscita(8 to 15);
                                j := 0;
                            end if;    

                        end if;
                    
                    when ATTESA_SCRITTURA_BYTE =>
                        state <= LETTURA_BYTE;

                    when FINE =>
                        if (i_start = '0') then
                            state <= INIZIO;
                        else 
                            o_done <= '1';
                            state <= FINE;
                        end if;
                
                end case;
            end if;
        end if;
    end process Case_scenario;
end architecture;
