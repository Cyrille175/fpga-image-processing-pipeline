----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.10.2025 09:53:18
-- Design Name: 
-- Module Name: ligne_retard - rtl
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ligne_retard is
  generic (
    N : integer := 8 
  );
  port (
    clk  : in  std_logic;                     
    rst  : in  std_logic;                     
    en   : in  std_logic;                    
    din  : in  std_logic_vector(N-1 downto 0);
    dout1 : out std_logic_vector(N-1 downto 0);
    dout2 : out std_logic_vector(N-1 downto 0);
    dout3 : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture rtl of ligne_retard is

  component generic_DFF is
    generic (N : integer := 8);
    port (
      clk : in  std_logic;
      rst : in  std_logic;
      en  : in  std_logic;
      d   : in  std_logic_vector(N-1 downto 0);
      q   : out std_logic_vector(N-1 downto 0)
    );
  end component;

  signal s1, s2, s3 : std_logic_vector(N-1 downto 0);

begin

  dff1: generic_DFF
    generic map (N => N)
    port map (
      clk => clk,
      rst => rst,
      en  => en,
      d   => din,
      q   => s1
    );

  dff2: generic_DFF
    generic map (N => N)
    port map (
      clk => clk,
      rst => rst,
      en  => en,
      d   => s1,
      q   => s2
    );

  dff3: generic_DFF
    generic map (N => N)
    port map (
      clk => clk,
      rst => rst,
      en  => en,
      d   => s2,
      q   => s3
    );

  dout1 <= s1;
  dout2 <= s2;
  dout3 <= s3;

end architecture;