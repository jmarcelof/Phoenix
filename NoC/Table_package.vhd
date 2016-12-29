library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.NoCPackage.all;

package TablePackage is

constant NREG : integer := 6;
constant MEMORY_SIZE : integer := NREG;
constant NBITS : integer := 4;
constant CELL_SIZE : integer := 2*NPORT+4*NBITS;

subtype cell is std_logic_vector(CELL_SIZE-1 downto 0);
subtype regAddr is std_logic_vector(2*NBITS-1 downto 0);
type memory is array (0 to MEMORY_SIZE-1) of cell;
type tables is array (0 to NROT-1) of memory;
subtype ports is std_logic_vector(NPORT-1 downto 0);

function input_ports(region : cell) return ports;
function output_ports(region : cell) return ports;
function upper_right_x(region : cell) return natural;
function upper_right_y(region : cell) return natural;
function lower_left_x(region : cell) return natural;
function lower_left_y(region : cell) return natural;
function formatted_region(
    input_ports : ports;
    VertInf : regAddr;
    VertSup : regAddr;
    output_ports : ports
) return cell;

constant TAB: tables :=(
-- Router 0.0
(("10000000000010000010000100"),
( "10000000100000100010000001"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 0.1
(("11100000100000100000100001"),
("11001000000100100010000100"),
("10101000000000000000001000"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 0.2
(("10101000000000000000101000"),
("11001000000110100010000100"),
("11100000100000100001000001"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 0.3
(("11100000100110010001100001"),
("11001000001000010010000100"),
("11100001100110100010000001"),
("10101000000000100001001000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 0.4
(("11000000101000010010000001"),
("10000001100000100010001001"),
("10001000000000010001101000"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 1.0
(("10101000000000000000000010"),
("10010000000010001010000100"),
("10010001000000100010000001"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 1.1
(("10111000000000001000001000"),
("11001000000000000000100010"),
("11110001000000100000100001"),
("11001000000100100010000100"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 1.2
(("11110001000100010001000001"),
("10111000000000000000001000"),
("11001000000000000010000010"),
("11110001100100100010000001"),
("11001000100110100010000100"),
("10111000100000100000101000")
),
 -- Router 1.3
(("11110001000110010001100001"),
("11011000101000010010000100"),
("11110001100110100010000001"),
("11101000000000000010000010"),
("10111000100000100001001000"),
("00000000000000000000000000")
),
 -- Router 1.4
(("10001000001000000010000010"),
("10000001100000100010001001"),
("10001000000000010001101000"),
("11010001000000100010000001"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 2.0
(("10101000000000001000000010"),
("10010001100000100010000001"),
("10010000000010010010000100"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 2.1
(("10111000000000010000001000"),
("11110001100000100000100001"),
("11001000000000001000100010"),
("11001000000100100010000100"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 2.2
(("10111001000000010000101000"),
("10111000000000001000001000"),
("11001000000000001001000010"),
("11110001100000100010000001"),
("11001000000110100010000100"),
("00000000000000000000000000")
),
 -- Router 2.3
(("10111000000000001000001000"),
("11001000001000010010000100"),
("11110001100110100010000001"),
("11001000000000001001100010"),
("10111001000000100001001000"),
("00000000000000000000000000")
),
 -- Router 2.4
(("10010001000000010001101000"),
("10010001100000100010001000"),
("11000000000000001010000010"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 3.0
(("10101000000000010000000010"),
("10010010000000100010000001"),
("10010000000010011010000100"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 3.1
(("11110010000000100000100001"),
("10111000000000011000001000"),
("11001000000000010000100010"),
("11001000000100100010000100"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 3.2
(("11011001100110011010000100"),
("11110010000100100010000001"),
("10111001100000100000101000"),
("11101000000000010010000010"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 3.3
(("11011001101000011010000100"),
("11110010000110100010000001"),
("10101000000110010010000010"),
("10101000000000100001001000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 3.4
(("10000001100000011001101000"),
("10000010000000100010000001"),
("10000000000000010010001000"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 4.0
(("10010000000010100010000100"),
("10100000000000011000000010"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 4.1
(("10110000000000100000001000"),
("11000000000000011000100010"),
("11000000000100100010000100"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 4.2
(("11010010000110100010000100"),
("10110010000000100000101000"),
("11100000000000011010000010"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 4.3
(("11010001101000100010000100"),
("10100000000110011010000010"),
("10100000000000100001001000"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
),
 -- Router 4.4
(("11000001101000011010000010"),
("10010000000000010010001000"),
("10010001100000100001101000"),
("00000000000000000000000000"),
("00000000000000000000000000"),
("00000000000000000000000000")
)
);
end TablePackage;

package body TablePackage is

function input_ports(region : cell) return ports is
    variable result : std_logic_vector(NPORT-1 downto 0);
begin
    result := region(CELL_SIZE-1 downto CELL_SIZE-5);
    return result;
end input_ports;

function output_ports(region : cell) return ports is
begin
    return region(NPORT-1 downto 0);
end output_ports;

function upper_right_x(region : cell) return natural is
begin
    return TO_INTEGER(unsigned(region(CELL_SIZE-6-2*NBITS downto CELL_SIZE-5-3*NBITS)));
end upper_right_x;

function upper_right_y(region : cell) return natural is
begin
    return TO_INTEGER(unsigned(region(CELL_SIZE-6-3*NBITS downto 5)));
end upper_right_y;

function lower_left_x(region : cell) return natural is
begin
    return TO_INTEGER(unsigned(region(CELL_SIZE-6 downto CELL_SIZE-5-NBITS)));
end lower_left_x;

function lower_left_y(region : cell) return natural is
begin
    return TO_INTEGER(unsigned(region(CELL_SIZE-6-NBITS downto CELL_SIZE-5-2*NBITS)));
end lower_left_y;

function formatted_region(
    input_ports : ports;
    VertInf : regAddr;
    VertSup : regAddr;
    output_ports : ports
) return cell is
    variable region : cell;
begin
     region(CELL_SIZE-1 downto CELL_SIZE-5) := input_ports;
     region(CELL_SIZE-6 downto CELL_SIZE-5-2*NBITS) := VertInf;
     region(CELL_SIZE-6-2*NBITS downto NPORT) := VertSup;
     region(NPORT-1 downto 0) := output_ports;
     return region;
end formatted_region;

end TablePackage;
