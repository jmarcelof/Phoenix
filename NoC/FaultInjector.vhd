library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.math_real.ALL;
use STD.textio.all;
use work.HammingPack16.all;
use work.NoCPackage.all;


entity FaultInjector is
generic(
    address: regflit;
    SEED_VAL_1: positive := 1;
    SEED_VAL_2: positive := 1
);
port(
    clock:          in std_logic;
    reset:          in std_logic;
    tx:             in regNport;
    data_in:        in arrayNport_regphit;
    data_out:       out arrayNport_regphit;
    credit:         in regNport
);
end FaultInjector;

architecture FaultInjector of FaultInjector is

    constant SA0: integer := 0; -- stuck-at 0
    constant SA1: integer := 1; -- stuck-at 1
    constant BF:  integer := 2; -- bitflit error
    constant OK:  integer := 3; -- OK (sem falha)

    type fault_bits is array (0 to 2) of regphit; -- 3 possiveis falhas (SA0, SA1, BT)
    type arrayFaultNports is array (0 to NPORT-1) of fault_bits;

    signal FaultNPorts: arrayFaultNports := (others=>(others=>(others=>'0')));

begin

    -- aqui eh escolhido os bits dos dados de saida
    -- baseados nos bits selecionados que ocorrerao a injecao de falha
    -- tipos de falha: stuck-at 0, stuck-at 1, bitflip
    data_fault: for i in 0 to NPORT-1 generate
    begin
        bit_fault: for j in 0 to TAM_PHIT-1 generate
        begin
            data_out(i)(j) <=   '0' when (FaultNPorts(i)(SA0)(j)='1') else -- stuck-at 0
                                '1' when (FaultNPorts(i)(SA1)(j)='1') else -- stuck-at 1
                                not data_in(i)(j) when (FaultNPorts(i)(BF)(j)='1') -- bitflip
                                else data_in(i)(j); -- normal
        end generate bit_fault;
    end generate data_fault;

    process
        file file_pointer: text;
        variable fstatus: file_open_status;
        variable line_num : line;
        variable tmp_word: string (1 to 50);
        variable tmp_line: line;
        variable line_counter: integer := 0;
        variable char_pointer: integer;
        variable char_pointer_tmp: integer;
        variable time_now: integer := 0;
        variable fault_rate: real;
        variable fault_port: integer;

        type real_array is array (0 to NPORT-1) of real;
        variable fault_rate_Nports: real_array := (others=>0.0);

        variable seed1: positive := SEED_VAL_1;
        variable seed2: positive := SEED_VAL_2;
        variable rand: real;
    begin
        file_open(fstatus, file_pointer,"fault_"&to_hstring(address)&".txt",READ_MODE);
        
        if(fstatus = OPEN_OK) then
            while not endfile(file_pointer) loop

                -- limpa a string tmp_word
                for i in 1 to tmp_word'length loop
                    tmp_word(i) := NUL;
                end loop;

                readline(file_pointer,line_num);
                line_counter := line_counter + 1;
                char_pointer := line_num'low;
                -- copia a string da linha lida ate encontrar espaco (ira copiar o tempo do inicio da falha)
                while (line_num(char_pointer) /= ' ' and char_pointer <= line_num'high) loop
                    tmp_word(char_pointer) := line_num(char_pointer);
                    char_pointer := char_pointer + 1;
                end loop;

                -- converte string lida (taxa de falhas) para real
                write(tmp_line,tmp_word);
                read(tmp_line,fault_rate);

                -- limpa a string tmp_word
                for i in 1 to tmp_word'length loop
                    tmp_word(i) := NUL;
                end loop;

                char_pointer := char_pointer + 1;
                char_pointer_tmp := 1;
                -- copia a string da linha lida ate encontrar espaco ou fim (ira copiar a porta de saida)
                while (line_num(char_pointer) /= ' ' and line_num(char_pointer) /= NUL and char_pointer < line_num'high) loop
                    tmp_word(char_pointer_tmp) := line_num(char_pointer);
                    char_pointer := char_pointer + 1;
                    char_pointer_tmp := char_pointer_tmp + 1;
                end loop;

                -- copiar o ultimo character
                tmp_word(char_pointer_tmp) := line_num(char_pointer);

                if (tmp_word(1 to 4) = "EAST") then
                    fault_port := EAST;
                elsif (tmp_word(1 to 4) = "WEST") then
                    fault_port := WEST;
                elsif (tmp_word(1 to 5) = "NORTH") then
                    fault_port := NORTH;
                elsif (tmp_word(1 to 5) = "SOUTH") then
                    fault_port := SOUTH;
                elsif (tmp_word(1 to 5) = "LOCAL") then
                    fault_port := LOCAL;
                else
                    assert false report "Erro de leitura da porta de saida: linha "&integer'image(line_counter)&" do arquivo fault_00"&to_hstring(address)&".txt" severity error;
                    wait;
                end if;

                -- limpa a string fault_type_string
                for i in 1 to tmp_word'length loop
                    tmp_word(i) := NUL;
                end loop;

                fault_rate_Nports(fault_port) := fault_rate;

                Deallocate(tmp_line);

            end loop; -- fim da leitura do arquivo

            wait until reset='0';
            wait until clock='1';
            wait for 1 ns;


            while true loop

                for i in 0 to NPORT-1 loop
                    if (tx(i)='1' and credit(i)='1') then
                        uniform(seed1, seed2, rand);
                        if (fault_rate_Nports(i) >= rand) then
                            FaultNPorts(i)(BF)(0) <= '1';
                            FaultNPorts(i)(BF)(1) <= '1';
                        else
                            FaultNPorts(i)(BF)(0) <= '0';
                            FaultNPorts(i)(BF)(1) <= '0';
                        end if;
                    else
                        FaultNPorts(i)(BF)(0) <= '0';
                        FaultNPorts(i)(BF)(1) <= '0';
                    end if;
                end loop;

                wait for CLOCK_PERIOD;
            end loop;
        else
            report "input fault file fault_" & to_hstring(address) & ".txt could not be open";
        end if;
        wait;
    end process;

end FaultInjector;
