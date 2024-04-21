library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity screen is
  Port ( 
    clk : in std_logic := '0'; 
    reset : in std_logic := '0'; 
    
    cs : out std_logic := '0';
    mosi : out std_logic := '0';
    nc : out std_logic := '0';
    sck : out std_logic := '0';
    dc : out std_logic := '0';
    res : out std_logic := '0';
    vccen : out std_logic := '0';
    pmoden : out std_logic := '0';
    
    led0 : out STD_LOGIC := '0';
    led1 : out STD_LOGIC := '0'
    
    
  );
end screen;

architecture Behavioral of screen is

    type state_type is (START_POWER_ON, POWER_ON_WAIT, POWER_ON_WAIT2, READY, READY_WAIT_STATE, SENDING_DATA);
    signal state : state_type := START_POWER_ON; 
    
    constant INIT_DELAY : integer := 2500000; -- delay for init
    signal init_count : integer range 0 to INIT_DELAY := 0;
    
    constant SHORT_DELAY : integer := 375; -- delay for init
    signal short_count : integer range 0 to SHORT_DELAY := 0;
    
    signal short_count_count : integer range 0 to 1 := 0;
    
    constant ready_wait_DELAY : integer := 3125000; -- time to wait after ready
    signal ready_wait_count : integer range 0 to ready_wait_DELAY := 0;
    
    constant oled_clock_CYCLE : integer := 40; -- clock for oled
    signal oled_clock_COUNT : integer range 0 to oled_clock_CYCLE := 0;
    
    signal sck_helper : std_logic := '0';
    
    constant turn_on_cmd : std_logic_vector (0 to 7) := "01011111";
    signal turn_on_bit_index : integer range 0 to 8 := 0;
    

--    constant LCD_COMMAND_DELAY : integer := 2000; -- delay for command
--    signal command_count : integer range 0 to LCD_COMMAND_DELAY := 0;
    
begin
-- this is the power on seq
power_on_seq : process(clk, reset)
begin
        if reset = '1' then
            state <= START_POWER_ON;
            init_count <= 0;
            short_count <= 0;
            short_count_count <= 0;
            led0 <= '0';
            led1 <= '0';
        elsif rising_edge(clk) then
            case state is 
                when START_POWER_ON =>
                    dc <= '0';
                    res <= '1';
                    vccen <= '0';
                    pmoden <= '1';
                    state <= POWER_ON_WAIT;
                when POWER_ON_WAIT =>
                    if init_count < INIT_DELAY then 
                        init_count <= init_count + 1;
                    else 
                        res <= '0';
                        state <= POWER_ON_WAIT2;
                    end if;
                when POWER_ON_WAIT2 =>
                    if short_count < short_DELAY then 
                        short_count <= short_count + 1;
                    else 
                        if short_count_count < 1 then
                            short_count <= 0; 
                            short_count_count <= short_count_count + 1;
                            res <= '1';
                            state <= POWER_ON_WAIT2;
                            
                        else 
                            state <= READY;
                        end if;
                    end if;
                 when READY =>
                    led0 <= '1';
                    vccen <= '1';
                    cs <= '0';
                    state <= READY_WAIT_STATE;
                 when READY_WAIT_STATE =>
                    if ready_wait_COUNT < ready_wait_DELAY then 
                        ready_wait_COUNT <= ready_wait_COUNT + 1;
                    else 
                        state <= SENDING_DATA;
                    end if;
                 when SENDING_DATA =>
                    if oled_clock_COUNT < oled_clock_CYCLE then 
                        oled_clock_COUNT <= oled_clock_COUNT + 1;
                    else 
                        oled_clock_COUNT <= 0;
                        -- send the data
                        sck_helper <= not sck_helper;
                        sck <= sck_helper;
                        if sck_helper = '1' then
                            if turn_on_bit_index < 8 then
                                mosi <= turn_on_cmd(turn_on_bit_index); 
                                turn_on_bit_index <= turn_on_bit_index + 1;
                            else
                                cs <= '1';
                                led1 <= '1';
                            end if;
                        end if;
                    end if;
                 end case;  
        end if;
        end process;          
    
end Behavioral;

