
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

----------------------------------------------------------------------------------
entity CMODA7Framework is
  port
  (
    CLK     : in std_logic;
    UART_RX : in std_logic;
    UART_TX : out std_logic);
end CMODA7Framework;

----------------------------------------------------------------------------------
architecture Structural of CMODA7Framework is

  component uart is
    port
    (
      CLK   : in std_logic;
      RESET : in std_logic;
      -- TX SIGNALS ---------------------------------
      DATA_IN   : in std_logic_vector(7 downto 0);
      TX_ENABLE : in std_logic;
      TX_IDLE   : out std_logic;
      TX_OUT    : out std_logic;
      -- RX SIGNALS ---------------------------------
      DATA_OUT   : out std_logic_vector(7 downto 0);
      DATA_VALID : out std_logic;
      RX_IN      : in std_logic);
  end component;

  component MainControler is
    port
    (
      CLK : in std_logic;
      -- UART CONTROL -----------------------------------
      UART_RESET : out std_logic;
      TX_ENABLE  : out std_logic;
      TX_IDLE    : in std_logic;
      DATA_VALID : in std_logic;
      DATA_IN    : in std_logic_vector(7 downto 0);
      -- REGISTER CONTROL -------------------------------
      DATA_OUT : out std_logic_vector(7 downto 0));
  end component;

  -- SIGNALS -------------------------------------------------------------------
  signal SAVE_IN  : std_logic;
  signal SAVE_OUT : std_logic;

  signal REG_IN  : std_logic_vector(7 downto 0);
  signal REG_OUT : std_logic_vector(7 downto 0);

  signal UART_DATA_TX : std_logic_vector(7 downto 0);
  signal UART_DATA_RX : std_logic_vector(7 downto 0);
  signal TX_ENABLE    : std_logic;
  signal TX_IDLE      : std_logic;
  signal DATA_VALID   : std_logic;
  signal UART_RESET   : std_logic;

begin
  UARTInstance : uart
  port map
  (
    clk   => CLK,
    reset => UART_RESET,
    -----------------------
    data_in   => UART_DATA_TX,
    tx_enable => TX_ENABLE,
    tx_idle   => TX_IDLE,
    tx_out    => UART_TX,
    -----------------------
    data_out   => UART_DATA_RX,
    data_valid => DATA_VALID,
    rx_in      => UART_RX
  );

  FSM : MainControler port
  map (
  CLK        => CLK,
  UART_RESET => UART_RESET,
  TX_ENABLE  => TX_ENABLE,
  TX_IDLE    => TX_IDLE,
  DATA_VALID => DATA_VALID,
  DATA_IN    => UART_DATA_RX,
  DATA_OUT   => UART_DATA_TX
  );
end Structural;