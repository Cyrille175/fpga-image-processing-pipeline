----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2025 10:20:27
-- Design Name: 
-- Module Name: dupliq_lena - Behavioral
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
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_lena_dupliq is
end;

architecture arch_tb_lena of tb_lena_dupliq is

  component fifo_generator_1 is
    port (
      clk              : in  std_logic;
      rst              : in  std_logic;
      din              : in  std_logic_vector(7 downto 0);
      wr_en            : in  std_logic := '0';
      rd_en            : in  std_logic := '0';
      prog_full_thresh : in  std_logic_vector(9 downto 0);
      dout             : out std_logic_vector(7 downto 0);
      full             : out std_logic;
      empty            : out std_logic;
      prog_full        : out std_logic;
      wr_rst_busy      : out std_logic;
      rd_rst_busy      : out std_logic
    );
  end component;

  signal clk              : std_logic := '0';
  signal rst              : std_logic := '1';
  signal din              : std_logic_vector(7 downto 0) := (others => '0');
  signal dout             : std_logic_vector(7 downto 0);
  signal wr_en            : std_logic := '0';
  signal rd_en            : std_logic := '0';
  signal full             : std_logic;
  signal empty            : std_logic;
  signal prog_full        : std_logic;
  signal prog_full_thresh : std_logic_vector(9 downto 0) := (others => '0');
  signal wr_rst_busy      : std_logic;
  signal rd_rst_busy      : std_logic;
  signal I1               : std_logic_vector(7 downto 0) := (others => '0');
  signal O1               : std_logic_vector(7 downto 0) := (others => '0');
  signal DATA_AVAILABLE   : std_logic := '0';
  signal READ_DONE        : std_logic := '0';

begin

  clk <= not clk after 5 ns;
  
  rst_begin :process
  begin
  rst <= '1';
  wait for 50 ns;
  rst <= '0';
  wait;
  end process;
  
  O1  <= dout;

  fifo_inst : fifo_generator_1
    port map (
      clk              => clk,
      rst              => rst,
      din              => din,
      wr_en            => wr_en,
      rd_en            => rd_en,
      prog_full_thresh => prog_full_thresh,
      dout             => dout,
      full             => full,
      empty            => empty,
      prog_full        => prog_full,
      wr_rst_busy      => wr_rst_busy,
      rd_rst_busy      => rd_rst_busy
    );

  p_read : process
    file     vectors : text;
    variable Iline   : line;
    variable I1_var  : std_logic_vector(7 downto 0);
  begin
    wait until rst = '0';
    DATA_AVAILABLE <= '0';
    READ_DONE      <= '0';
    file_open(vectors, "Lena128x128g_8bits.dat", read_mode);
    wait for 20 ns;
    wait until (wr_rst_busy = '0' and rd_rst_busy = '0');
    DATA_AVAILABLE <= '1';
    while not endfile(vectors) loop
      readline(vectors, Iline);
      read(Iline, I1_var);
      I1  <= I1_var;
      wr_en <= '1';
      din <= I1_var;
      wait until rising_edge(clk);
      if full = '0' then
        wr_en <= '1';
      else
        wr_en <= '0';
        while full = '1' loop
          wait until rising_edge(clk);
        end loop;
        wr_en <= '1';
      end if;
    end loop;
    DATA_AVAILABLE <= '0';
    file_close(vectors);
    READ_DONE <= '1';
    wait;
  end process;

  p_write : process
    file     results : text;
    variable Oline   : line;
  begin
    wait until rst = '0';
    file_open(results, "Lena128x128g_8bits_r.dat", write_mode);
    while not (READ_DONE = '1' and empty = '1') loop
      if empty = '0' then
        rd_en <= '1';
      else
        rd_en <= '0';
      end if;
      wait until rising_edge(clk);
      if rd_en = '1' then
        rd_en <= '0';
        write(Oline, O1, right, 0);
        writeline(results, Oline);
      end if;
    end loop;
    file_close(results);
    wait;
  end process;

end arch_tb_lena;
