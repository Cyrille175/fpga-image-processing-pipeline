----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.11.2025 09:22:40
-- Design Name: 
-- Module Name: tb_memoire_cache_lena - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;

--Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_memoire_cache_lena is
end tb_memoire_cache_lena;

architecture Behavioral of tb_memoire_cache_lena is

  component memoire_cache is
    generic(
      LARGEUR_IMAGE : integer := 128;
      HAUTEUR_IMAGE : integer := 128
    );
    port(
      clk, rst   : in  std_logic;
      pixel_entree     : in  std_logic_vector(7 downto 0);
      pixel_valide     : in  std_logic;
      
      p00, p01, p02 : out std_logic_vector(7 downto 0);
      p10, p11, p12 : out std_logic_vector(7 downto 0);
      p20, p21, p22 : out std_logic_vector(7 downto 0);

      fenetre_valide  : out std_logic
    );
  end component;

  constant LARGEUR_IMAGE : integer := 128;
  constant HAUTEUR_IMAGE : integer := 128;
  
  signal clk : std_logic := '0';
  signal rst : std_logic := '1';
  signal pixel_entree : std_logic_vector(7 downto 0);
  signal pixel_valide : std_logic := '0';
  
  signal p00, p01, p02 : std_logic_vector(7 downto 0);
  signal p10, p11, p12 : std_logic_vector(7 downto 0);
  signal p20, p21, p22 : std_logic_vector(7 downto 0);
  
  signal fenetre_valide : std_logic;

begin

  -- Instanciation de la mémoire cache
  memoire: memoire_cache
    generic map(
      LARGEUR_IMAGE => LARGEUR_IMAGE,
      HAUTEUR_IMAGE => HAUTEUR_IMAGE
    )
    port map(
      clk => clk,
      rst => rst,
      pixel_entree => pixel_entree,
      pixel_valide => pixel_valide,
      p00 => p00,
      p01 => p01,
      p02 => p02,
      p10 => p10,
      p11 => p11,
      p12 => p12,
      p20 => p20,
      p21 => p21,
      p22 => p22,
      fenetre_valide => fenetre_valide
    );

  -- Génération de l'horloge (période 10 ns)
  clk <= not clk after 5 ns;

  -- Processus de reset
  process
  begin
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait;
  end process;

  -- Processus de lecture du fichier image
  p_read: process
    file vectors : text;
    variable Iline : line;
    variable I1_var : std_logic_vector(7 downto 0);
  begin
    pixel_valide <= '0';
    pixel_entree <= (others => '0');
    wait for 10 ns;
    -- Attente fin du reset
    wait until rst = '0';
    wait for 200 ns;
    
    -- Ouverture du fichier
    file_open(vectors, "Lena128x128g_8bits.dat", read_mode);
    
    -- Lecture et envoi des pixels
    while not endfile(vectors) loop
      wait until rising_edge(clk);
      
      -- Lecture d'un pixel
      readline(vectors, Iline);
      read(Iline, I1_var);
      pixel_entree <= I1_var;
      pixel_valide <= '1';
     
    end loop;
    
    -- Fin de la lecture
    wait until rising_edge(clk);
    pixel_valide <= '0';
    
    file_close(vectors);
    wait;
  end process;
  
  

  -- Processus d'écriture des résultats
  p_write: process
    file results : text;
    variable OLine : line;
    variable compteur : integer := 0;
  begin
    -- Attente fin du reset
    wait until rst = '0';
    wait for 20 ns;
    
    -- Ouverture du fichier de sortie
    file_open(results, "Lena128x128g_8bits_matrice.dat", write_mode);
    
    -- Attente de la première fenêtre valide
    wait until fenetre_valide = '1';
    
    -- Écriture des fenêtres 3x3
 
    while pixel_valide = '1' or fenetre_valide = '1' loop
      wait until rising_edge(clk);
      
      if fenetre_valide = '1' then
        -- Écriture de la fenêtre 3x3 complète
        write(OLine, string'("Fenetre ")); --j'ecris Fenetre au debut de chaque fenetre
        write(OLine, compteur);
        write(OLine, string'(":"));
        writeline(results, OLine);
        
        -- Ligne du haut
        write(OLine, p00, right, 4);
        write(OLine, string'(":"));
        write(OLine, p01, right, 4);
        write(OLine, string'(":"));
        write(OLine, p02, right, 4);
        writeline(results, OLine);
        
        -- Ligne du milieu
        write(OLine, p10, right, 4);
        write(OLine, string'(":"));
        write(OLine, p11, right, 4);
        write(OLine, string'(":"));
        write(OLine, p12, right, 4);
        writeline(results, OLine);
        
        -- Ligne du bas
        write(OLine, p20, right, 4);
        write(OLine, string'(":"));
        write(OLine, p21, right, 4);
        write(OLine, string'(":"));
        write(OLine, p22, right, 4);
        writeline(results, OLine);
        
        write(OLine, string'(""));
        writeline(results, OLine);
        
        compteur := compteur + 1;
      end if;
    end loop;
    
    file_close(results);
    wait;
  end process;
 
end Behavioral;
