----------------------------------------------------------------------------------
-- Company: Politecnico di Milano

-- Engineers(maybe): 
--Matteo Luppi: Codice Persona 10722458, Matricola 937186 
--Alessandro Martinolli: Codice Persona 10700492, Matricola 933814

-- Create Date: 09.03.2022 10:32:29
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: project_reti_logiche
--
----------------------------------------------------------------------------------

--dichiaro le varie librerie che mi servono per la descrizione di questo componente
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    Port ( 
        i_clk     : in std_logic; --è il segnale di clock di ingresso
        i_start   : in std_logic; --è il segnale di start dell'intera macchina
        i_rst     : in std_logic; --è il segnale di reset dell'intera macchina
        i_data    : in std_logic_vector(7 downto 0); --segnale che arriva dalla memoria in seguito ad una richiesta di lettura
        o_address : out std_logic_vector(15 downto 0); --segnale che manda l'indirizzo alla memoria
        o_done    : out std_logic; --è il segnale di uscita che comunica la fine dell'elaborazione e il dato di uscita scritto in memoria 
        o_en      : out std_logic; --è il segnale di ENABLE da dover mandare alla memoria per poter comunicare(sia in lettura che in scrittura)
        o_we      : out std_logic; --è il segnale di WRITE ENABLE da dover mandare alla memoria per poter scriverci
        o_data    : out std_logic_vector(7 downto 0) --è il segnale di uscita dal componente verso la memoria 
    );
end project_reti_logiche;


architecture Behavioral of project_reti_logiche is

    --definisco gli stati della mia FSM che va ad interagire con la memoria in lettura e scrittura
    type state_type is (INIZIO,LETTURA_DIM,ATTESA_LETTURA_DIM,LETTURA_BYTE,ATTESA_LETTURA_BYTE,
                        SCRITTURA_BYTE,FINE);
                        
    signal state: STATE_TYPE := INIZIO;
    signal has_dim: boolean := false;     --flag che indica se la dimensione è stata letta dalla memoria(indirizzo 0)
    signal has_byte: boolean := false;    --flag che indica se il byte è stata letto dalla memoria
    signal first: boolean := false;       --flag per la scrittura dei due byte in uscita
    signal last_byte_address: std_logic_vector(15 downto 0 ) := (others => '0');    --indirizzo dell'ultimo byte letto 
    signal current_byte_address: std_logic_vector(15 downto 0 ) := (others => '0'); --indirizzo del byte corrente
    signal stato_conv: std_logic_vector(1 downto 0) := "00"; --segnale che mi rappresenta gli stati del convolutore
    signal offset_999: std_logic_vector(15 downto 0):= "0000001111100111"; --offset che mi aiuta per la scrittura in memoria
    

begin

    Case_scenario: process(i_clk)
    --variabile di supporto 
    variable var : unsigned(15 downto 0) := (others => '0');
    --variabile per memorizzare i due byte di uscita dal convolutore per ogni byte in ingresso
    variable uscita: std_logic_vector(0 to 15) := (others => '0');
    --contatori interi
    variable count : integer := 7; --per scorrere tutti i bit del byte che leggo-->va da 7 a 0
    variable i : integer := 0; --per scrivere tutti i bit nel vettore uscita -->va da 0 a 15
    variable z : integer := 0; --per aiutarmi a scrivere i due byte al giusto indirizzo di memoria


    begin
        if rising_edge(i_clk) then
            --inizializzo i segnali
            o_done <= '0';
            o_en <= '0';
            o_we <= '0';
            o_data    <= (others => '0');
            o_address <= (others => '0');

            --segnale di reset
            if i_rst = '1' then
                state <= INIZIO;
            else 
                case state is  
                    when INIZIO =>
                        has_dim <= false;
                        has_byte <=false;
                        last_byte_address <= (others => '0');
                        current_byte_address <= (others => '0');
                        if (i_start = '1') then
                        --inzia tutto il processo 
                            state <= LETTURA_DIM;
                        else
                            --attende il segnale d'inizio
                            state <= INIZIO;
                        end if; 
                    
                    when LETTURA_DIM =>
                        --Attivo il segnale per la lettura da memoria
                        o_en <= '1';
                        if not has_dim then
                            --vado a prendere la dimensione dell'input
                            o_address <= "0000000000000000";
                            has_dim <= true; --a questo punto ho la dimensione dell'input
                            state <= ATTESA_LETTURA_DIM;
                        else
                            var := unsigned("00000000" & i_data); --mi salvo il valore della dimensione letta all'indirizzo 0 della memoria
                            if not (var = "0000000000000000") then
                                --settiamo il limite per la lettura da memoria
                                last_byte_address <= std_logic_vector(var);
                                --inizializzo gli indirizzi
                                o_address <= "0000000000000000";
                                current_byte_address <="0000000000000000";
                                state <= ATTESA_LETTURA_BYTE;
                            else
                                --se la dimensione è 0 non parte nessuna codifica
                                o_done <= '1';
                                state <= FINE;  
                            end if;    
                        end if;
                    
                    when ATTESA_LETTURA_DIM =>
                        state <= LETTURA_DIM;
                    
                    when LETTURA_BYTE =>
                        --calcolo del nuovo indirizzo di lettura
                        var := unsigned(current_byte_address)+1;
                        --controllo se tutti i byte sono stati letti
                        if not(std_logic_vector(var)=last_byte_address +1) then --se non sono ancora stati letti tutti
                            --aggiorno gli indirizzi
                            current_byte_address <= std_logic_vector(var);
                            o_address <= std_logic_vector(var);
                            --attivo segnale per la lettura da memoria
                            o_en <= '1';
                            --ora posso settare il flag a true 
                            has_byte <=true;
                            state <= ATTESA_LETTURA_BYTE;
                        else --se ho letto tutti i byte in input                    
                            o_done <= '1';
                            state <= FINE;
                        end if;

                    when ATTESA_LETTURA_BYTE =>
                        --se non ho ancora letto il byte devo ritornare nello stato 'LETTURA_BYTE'
                        if not has_byte then
                            state <= LETTURA_BYTE;
                        else 
                            has_byte <=false; --setto il flag a false per poi essere pronto a leggere il byte successivo
                            state <= SCRITTURA_BYTE;
                        end if;

                    when SCRITTURA_BYTE =>
                        --statto in cui converto il byte in input generando due byte in output che vado a scrivere 
                        --in memoria a due indirizzi differenti ma contigui
                        if(i<=15) then
                            --convolutore-->vado a implementare la FSM che gestisce il meccanismo di traduzione
                            if(stato_conv = "00" and i_data(count) = '0') then
                                --salvo stringa tradotta
                                uscita(i) := '0';
                                i := i+1;
                                uscita(i) := '0';
                                i := i+1;
                                stato_conv <= "00";
                            elsif(stato_conv = "00" and i_data(count)= '1') then
                                --salvo stringa tradotta
                                uscita(i) := '1';
                                i := i+1;
                                uscita(i) := '1';
                                i := i+1;
                                stato_conv <= "10";
                            elsif(stato_conv = "10" and i_data(count)= '0') then
                                --salvo stringa tradotta
                                uscita(i) := '0';
                                i := i+1;
                                uscita(i) := '1';
                                i := i+1;
                                stato_conv <= "01";
                            elsif(stato_conv = "10" and i_data(count)= '1') then 
                                --salvo stringa tradotta
                                uscita(i) := '1';
                                i := i+1;
                                uscita(i) := '0';
                                i := i+1;
                                stato_conv <= "11";
                            elsif(stato_conv = "01" and i_data(count)= '0') then
                                --salvo stringa tradotta
                                uscita(i) := '1';
                                i := i+1;
                                uscita(i) := '1';
                                i := i+1;
                                stato_conv <= "00";
                            elsif(stato_conv = "01" and i_data(count)= '1') then
                                --salvo stringa tradotta
                                uscita(i) := '0';
                                i := i+1;
                                uscita(i) := '0';
                                i := i+1;
                                stato_conv <= "10";
                            elsif(stato_conv = "11" and i_data(count)= '0') then 
                                --salvo stringa tradotta
                                uscita(i) := '1';
                                i := i+1;
                                uscita(i) := '0';
                                i := i+1;
                                stato_conv <= "01";
                            elsif(stato_conv = "11" and i_data(count)= '1') then 
                                --salvo stringa tradotta
                                uscita(i) := '0';
                                i := i+1;
                                uscita(i) := '1';
                                i := i+1;
                                stato_conv <= "11";
                            end if;
                            --decremento count cosi al prox ciclo di clock leggo il bit successivo(parto dal bit piu significativo verso quello meno significativo)
                            count := count - 1;
                            state <= SCRITTURA_BYTE;
                        else
                            --ora ho i due byte nel vettore 'uscita' che sono pronti per essere scritti in memoria
                            -- attivo la memoria
                            o_en <= '1';
                            -- attivo segnale di scrittura
                            o_we <= '1';

                            if not first then -- per scrivere il primo byte del vettore uscita
                                --primo indirizzo di memoria dei due byte di output
                                o_address <= std_logic_vector(unsigned(current_byte_address) + unsigned(offset_999)+z);
                                o_data <= uscita(0 to 7); --primi 8 bit del vettore 'uscita'
                                first <= true;
                                state <= SCRITTURA_BYTE;
                            else -- per scrivere il secondo byte del vettore uscita
                                --secondo indirizzo di memoria dei due byte di uscita(incremento di 1 l'indirizzo precedente)
                                o_address <= std_logic_vector(unsigned(current_byte_address) + unsigned(offset_999)+z+1);
                                o_data <= uscita(8 to 15); --8 bit restanti del vettore 'uscita'
                                first <= false;
                                i := 0; --azzero varibaile i per i cicli successivi
                                count :=7; --resetto count al suo valore iniziale per ripartire a leggere il byte da sx verso dx
                                z := z+1; --incremento questa variabile che mi aiuta ad avere il giusto offset per la scrittura in memoria
                                state <= LETTURA_BYTE;
                            end if;    
                        end if;

                    when FINE =>
                        if (i_start = '0') then
                            z :=0; --azzero la variabile che mi aiuta ad avere il giusto offset per la scrittura in memoria,per un eventuale uso successivo
                            stato_conv <= "00"; --"resetto" la FSM che gestisce il meccanismo di convoluzione,per un eventuale uso successivo
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
