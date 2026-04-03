----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.10.2025 09:53:18
-- Design Name: 
-- Module Name: generic_DFF - rtl
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

entity generic_DFF is
  generic (
    N : integer := 8  
  );
  port (
    clk : in  std_logic;                    
    rst : in  std_logic;                     
    en  : in  std_logic;                 
    d   : in  std_logic_vector(N-1 downto 0);
    q   : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture rtl of generic_DFF is
  signal qr : std_logic_vector(N-1 downto 0);
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then                     
        qr <= (others => '0');
      elsif en = '1' then                
        qr <= d;
      end if;
    end if;
  end process;

  q <= qr;
end architecture;
