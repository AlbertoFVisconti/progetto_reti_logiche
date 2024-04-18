----------------------------------------------------------------------------------

--Studente: Alberto Francesco Visconti
--Codice persona: 10763965
--Docente: Gianluca Palermo
--Anno accademico: 2023/2024


----------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------
-- interfaccia del componente

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic; 
        i_start : in std_logic;
        i_add : in std_logic_vector (15 downto 0); 
        i_k : in std_logic_vector(9 downto 0);
        
        o_done : out std_logic;
        
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_data : out std_logic_vector(7 downto 0);
        o_mem_we : out std_logic; 
        o_mem_en : out std_logic
) ;

end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component CHECK_C is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic; 
        enable : in std_logic;
        done : in std_logic;  
        input: in std_logic_vector( 7 downto 0);
        output : out std_logic_vector( 7 downto 0)
    );
end component CHECK_C;

component CHECK_W is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic; 
        enable : in std_logic;
        done : in std_logic;  
        input: in std_logic_vector( 7 downto 0);
        output : out std_logic_vector( 7 downto 0)
    );
end component CHECK_W;

component MULTIPLEXER is
    port(
        enable : in std_logic;
        sel : in std_logic;  
        input_0: in std_logic_vector( 7 downto 0);
        input_1: in std_logic_vector( 7 downto 0);
        output : out std_logic_vector( 7 downto 0)
    );
end component MULTIPLEXER;

component FFD_16 is
    port( 
     in1 : in UNSIGNED(15 downto 0);
     i_clk, i_rst : in std_logic;
     out1 : out UNSIGNED(15 downto 0)
     );
end component FFD_16;

component FFD_10 is
    port (     
         in1 : in UNSIGNED(9 downto 0);
         i_clk, i_rst : in std_logic;
         out1 : out UNSIGNED(9 downto 0)
     );
end component FFD_10;

component FSM is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic; 
        i_start : in std_logic;
        i_add : in std_logic_vector (15 downto 0); 
        i_k : in std_logic_vector(9 downto 0);
        
        --output di done
        o_done : out std_logic;
        s_done: out std_logic;

        
        --output logica di gestione della memoria     
        o_mem_addr : out std_logic_vector(15 downto 0);
        o_mem_we : out std_logic; 
        o_mem_en : out std_logic;
        
        --output logica di gestione del multiplexer
        o_en: out std_logic;
        o_en_mux: out std_logic;
        o_sel: out std_logic;
        
        --utilizzo di un ffd come elemento di memoria per evitare la creazione di latch
        o_curr_add: out UNSIGNED(15 downto 0); 
        i_curr_add: in UNSIGNED(15 downto 0); 
        o_curr_k: out UNSIGNED(9 downto 0);
        i_curr_k: in UNSIGNED(9 downto 0)
) ;
end component;
--signal del multiplexer 

signal en_mux: std_logic;
signal sel: std_logic;

--signal per la logica w e c 
signal en: std_logic;
signal new_w: std_logic_vector(7 downto 0); 
signal new_c: std_logic_vector(7 downto 0); 
signal done: std_logic; 

--signal della fsm per accedere ai ffd
signal o_curr_add:  UNSIGNED(15 downto 0);
signal i_curr_add:  UNSIGNED(15 downto 0); 
signal o_curr_k:  UNSIGNED(9 downto 0);
signal i_curr_k:  UNSIGNED(9 downto 0);
begin
    ff16: FFD_16 port map(
        i_clk  => i_clk,
        i_rst  => i_rst,
        in1=>o_curr_add,
        out1=>i_curr_add    
    );
    ff10: FFD_10 port map(
        i_clk  => i_clk,
        i_rst  => i_rst,
        in1=>o_curr_k,
        out1=>i_curr_k    
    );
    checkW : CHECK_W port map(
        i_clk  => i_clk,
        i_rst  => i_rst,
        enable => en,
        done => done,
        input => i_mem_data,
        output=> new_w
    );
    checkC : CHECK_C port map(
        i_clk  => i_clk,
        i_rst  => i_rst,
        enable => en,
        done => done,
        input => i_mem_data,
        output=> new_c
    );
    mux: MULTIPLEXER port map(
        enable => en_mux,
        sel => sel,  
        input_0=> new_w, 
        input_1=> new_c, 
        output=> o_mem_data
    );
    msf: FSM port map (
        i_clk  => i_clk,
        i_rst  => i_rst, 
        i_start => i_start,
        i_add =>i_add,
        i_k =>i_k,
        i_curr_add=>i_curr_add,
        i_curr_k=>i_curr_k,
        
        --output di done
        o_done =>o_done,
        --signal di done ( sono 2 ma sono lo stesso) 
        s_done =>done,
        
        --output logica di gestione della memoria     
        o_mem_addr =>o_mem_addr,
        o_mem_we =>o_mem_we,
        o_mem_en =>o_mem_en,
        
        --output logica di gestione del multiplexer
        o_en=>en, 
        o_en_mux=>en_mux,
        o_sel=>sel,
        
        --output memoria ffd 
        o_curr_add=>o_curr_add,
        o_curr_k=>o_curr_k
    ); 
    
end Behavioral;
-----------------------------------------------------------------------------------------------------
--FFD16



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity FFD_16 is
    port( 
     in1 : in UNSIGNED(15 downto 0);
     i_clk: in std_logic; 
     i_rst : in std_logic;
     out1 : out UNSIGNED(15 downto 0)
     );
end FFD_16;

architecture Behavioral of FFD_16 is

begin
 process(i_clk, i_rst)
 begin
     if i_rst = '1' then
            out1 <= (others=>'0');
     elsif rising_edge(i_clk) then
            out1 <= in1;
     end if;
 end process;


end Behavioral;
-----------------------------------------------------------------------------------------------------
--FFD10



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;


entity ffd_10 is
Port (     
     in1 : in UNSIGNED(9 downto 0);
     i_clk: in std_logic;
     i_rst : in std_logic;
     out1 : out UNSIGNED(9 downto 0)
 );
end ffd_10;

architecture Behavioral of ffd_10 is
begin
 process(i_clk, i_rst)
 begin
     if i_rst = '1' then
            out1 <= (others=>'0');
     elsif rising_edge(i_clk) then
            out1 <= in1;
     end if;
 end process;
end Behavioral;
-----------------------------------------------------------------------------------------------------
--CHECK-W


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CHECK_W is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic; 
        enable : in std_logic;
        done : in std_logic;  
        input: in std_logic_vector( 7 downto 0);
        output : out std_logic_vector( 7 downto 0)
    );
    end CHECK_W;

architecture Behavioral of CHECK_W is
    signal prev_value: std_logic_vector(7 downto 0);   
begin
    process(i_clk, i_rst)
    begin 
        if i_rst='1' then 
            prev_value<= (others => '0'); 
        elsif i_clk'event and i_clk= '1' then 
            if enable='1' then 
                if input="00000000" then 
                    output <=prev_value; 
                else 
                    output <= input; 
                    prev_value<=input;
                end if;
            elsif done='1'then
                prev_value<= (others => '0'); 
            end if; 
 
        end if; 
    end process; 
end Behavioral;
-----------------------------------------------------------------------------------------------------
--CHECK-C

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;


entity CHECK_C is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic; 
        enable : in std_logic;
        done : in std_logic;  
        input: in std_logic_vector( 7 downto 0);
        output : out std_logic_vector( 7 downto 0)
    );
end CHECK_C;

architecture Behavioral of CHECK_C is
    signal prev_credibility: UNSIGNED(7 downto 0); 
    signal first: std_logic; 
    constant one: UNSIGNED(7 downto 0):= "00000001";  
    constant thirtyone: UNSIGNED(7 downto 0):= "00011111";  
begin
    process(i_clk, i_rst)
    begin 
        if i_rst='1' then 
            prev_credibility<=thirtyone;
            first<='1';
            output<=(others=>'0');
        elsif i_clk'event and i_clk= '1' then 
            if enable='1' then 
                if input="00000000" then
                    if first ='1' then 
                        output<=(others=>'0');
                        prev_credibility<=thirtyone;                    
                    elsif prev_credibility="00000000" then
                        output<=std_logic_vector(prev_credibility); 
                        prev_credibility<=(others=>'0');                         
                    else 
                        output<=std_logic_vector(prev_credibility-one); 
                        prev_credibility<= prev_credibility - one;   
                    end if;                
                else 
                    output<=std_logic_vector( thirtyone); 
                    prev_credibility<= thirtyone;  
                    first<='0';
                end if;
            elsif done='1'then
                output<=(others=>'0');
                prev_credibility<=thirtyone;
                first<='1';
            end if; 
 
        end if; 
    end process; 
end Behavioral;

-----------------------------------------------------------------------------------------------------
--MULTIPLEXER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MULTIPLEXER is
    port(
        enable : in std_logic;
        sel : in std_logic;  
        input_0: in std_logic_vector( 7 downto 0);
        input_1: in std_logic_vector( 7 downto 0);
        output : out std_logic_vector( 7 downto 0)
    );
end MULTIPLEXER;

architecture Behavioral of MULTIPLEXER is

begin
    process(enable,sel,input_0,input_1) 
    begin 
    output<=(others=>'0');
    if enable='1' then 
            case sel is 
            when '0'=> output<=input_0;
            when others=> output<=input_1;
            end case;                
    end if;
     
end process; 
end Behavioral;

-----------------------------------------------------------------------------------------------------
--FSM


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity FSM is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic; 
        i_start : in std_logic;
        i_add : in std_logic_vector (15 downto 0); 
        i_k : in std_logic_vector(9 downto 0);
        
        --output di done
        o_done : out std_logic;
        s_done: out std_logic;
        
        --output logica di gestione della memoria     
        o_mem_addr : out std_logic_vector(15 downto 0);
        o_mem_we : out std_logic; 
        o_mem_en : out std_logic;
        
        --output logica di gestione del multiplexer
        o_en: out std_logic;
        o_en_mux: out std_logic;
        o_sel: out std_logic;
        
        --utilizzo di un ffd come elemento di memoria per evitare la creazione di latch
        o_curr_add: out UNSIGNED(15 downto 0); 
        i_curr_add: in UNSIGNED(15 downto 0); 
        o_curr_k: out UNSIGNED(9 downto 0);
        i_curr_k: in UNSIGNED(9 downto 0)
) ;end FSM;

architecture Behavioral of FSM is
    type state is (init, load, check_k, calculate, change_1, load_change_1, change_2, load_change_2, load_newW, done );
    signal curr_state: state;  
    constant one: UNSIGNED(7 downto 0):= "00000001";  
    constant one_k: UNSIGNED(9 downto 0):= "0000000001";  
    constant byte: UNSIGNED(15 downto 0):= "0000000000000001";  
    signal max_k: UNSIGNED(9 downto 0); 
begin
process(i_clk,i_rst) 
begin
    if i_rst='1' then 
        curr_state<= init; 
    elsif i_clk'event and i_clk = '1' then
        case curr_state is 
            when init =>
                if i_start ='1' then 
                    curr_state<= load; 
                end if; 
            when load =>
                curr_state<=check_k;
            when check_k =>
                if i_curr_k< max_k then 
                    curr_state<= calculate;
                else 
                    curr_state<=done;
                end if; 
            when calculate =>
                curr_state<= change_1;  
            when change_1 =>
                curr_state<= load_change_1;
            when load_change_1 =>
                curr_state<= change_2;  
            when change_2 =>
                curr_state<= load_change_2;
            when load_change_2 =>
                curr_state<= load_newW;
            when load_newW =>
                curr_state<= check_k; 
            when done =>
                if  i_start='0' then 
                    curr_state<=init; 
                end if;       
        end case; 
    
    end if; 
end process; 

process(curr_state) 
begin
    max_k<=UNSIGNED(i_k); 
    s_done<='0';
    o_en <= '0';
    o_en_mux <= '1';
    o_mem_en <= '0';
    o_mem_we <= '0';
    o_done <= '0';
    o_sel<='0';
    o_curr_add<=i_curr_add;
    o_curr_k<=i_curr_k;
    o_mem_addr<=std_logic_vector(i_curr_add);
    

    if curr_state = init then 
        s_done<='0';
        o_en <= '0';
        o_en_mux <= '0';
        o_mem_en <= '0';
        o_mem_we <= '0';
        o_done <= '0';    
        o_sel<='0';
        o_mem_addr<=(others=>'0'); 
        max_k<= (others=>'0');
        o_curr_k<=(others=>'0');
        o_curr_add<=(others=>'0');

     elsif curr_state= load then 
        o_mem_en <= '1';
        max_k<=UNSIGNED(i_k); 
        o_curr_add<=UNSIGNED(i_add); 
        o_mem_addr<= i_add; 
        o_en_mux <= '0';
        o_sel<='0';
     elsif curr_state= check_k then 
        o_mem_en <= '0';
        o_en_mux <= '0';
        o_sel<='0';
     elsif curr_state=calculate then 
        o_en<='1'; 
        o_en_mux <= '0';
        o_sel<='0';
     elsif curr_state= change_1 then 
        o_en<='0'; 
        o_en_mux<='1'; 
        o_sel<='0';
        o_mem_addr<= std_logic_vector(i_curr_add) ; 
        o_mem_en<='0';
        o_mem_we<='0';
     elsif curr_state= load_change_1 then 
        o_mem_en<='1';
        o_mem_we<='1';        
        o_sel<='0';
     elsif curr_state = change_2 then
        o_mem_addr<= std_logic_vector(i_curr_add+byte) ; 
        o_curr_add<= i_curr_add+ byte;
        o_sel<='1';
        o_mem_en<='0';
        o_mem_we<='0';
     elsif curr_state= load_change_2 then 
        o_mem_en<='1';
        o_mem_we<='1';
        o_sel<='1';
     elsif curr_state= load_newW then
        o_mem_en<='1';  
        o_mem_we<='0';
        o_sel<='1';
        o_mem_addr<= std_logic_vector(i_curr_add+byte) ; 
        o_curr_add<= i_curr_add+ byte;
        o_curr_k<=i_curr_k+ one_k;
     elsif curr_state= done then 
        s_done<='1';
        o_en_mux<='0'; 
        o_done<='1';
        o_sel<='1';
        o_mem_addr<=(others=>'0'); 
        o_curr_add<=(others=>'0'); 
        o_curr_k<=(others=>'0'); 
        max_k<=(others=>'0'); 
    end if; 
end process; 
end Behavioral;

