library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity screen_tb is
--  Port ( );
end screen_tb;

architecture Behavioral of screen_tb is

constant clk_period : time := 8ns;

component screen is 
    port (
        clk : in std_logic; 
        reset : in std_logic; 
        
        cs : out std_logic;
        mosi : out std_logic;
        nc : out std_logic;
        sck : out std_logic;
        dc : out std_logic;
        res : out std_logic;
        vccen : out std_logic;
        pmoden : out std_logic;
        led0 : out std_logic
    );
end component;
-- inputs
signal clk : std_logic := '0'; 
signal reset : std_logic := '0';
-- outpus
signal cs : std_logic;
signal mosi : std_logic;
signal nc : std_logic;
signal sck : std_logic;
signal dc : std_logic;
signal res : std_logic;
signal vccen : std_logic;
signal pmoden : std_logic;
signal led0 : STD_LOGIC;

begin

clk <= not clk after clk_period / 2;

uut : screen port map (
    clk => clk,
    reset => reset,
    cs => cs,
    mosi => mosi,
    nc => nc,
    sck => sck,
    dc => dc,
    res => res,
    vccen => vccen,
    pmoden => pmoden,
    led0 => led0
    );

tb_proc: process

begin
    
    wait for 1000 ms;
    assert (led0 = '1') report "led0 failed" severity error;
    
end process;
end Behavioral;
