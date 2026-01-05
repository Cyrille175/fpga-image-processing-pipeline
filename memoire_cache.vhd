----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.10.2025 09:53:18
-- Design Name: 
-- Module Name: memoire_cache - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memoire_cache is
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
end memoire_cache;

architecture rtl of memoire_cache is

  component fifo_generator_1 
    port(
      clk : in std_logic;
      rst : in std_logic;
      din : in std_logic_vector(7 downto 0);
      wr_en : in std_logic;
      rd_en : in std_logic;
      prog_full_thresh : in std_logic_vector(9 downto 0);
      dout : out std_logic_vector(7 downto 0);
      full : out std_logic;
      empty : out std_logic;
      prog_full : out std_logic;
      wr_rst_busy : out std_logic;
      rd_rst_busy : out std_logic
    );
  end component;

  component ligne_retard
    port(
      clk   : in  std_logic;
      rst   : in  std_logic;
      en    : in  std_logic;
      din   : in  std_logic_vector(7 downto 0);
      dout1 : out std_logic_vector(7 downto 0);
      dout2 : out std_logic_vector(7 downto 0);
      dout3 : out std_logic_vector(7 downto 0)
    );
  end component;

  -- Machine à états pour le contrôle des FIFOs
  type etat_type is (INIT, LIGNE1, ATTENTE_FIFO1, LIGNE2, ATTENTE_FIFO2,VALIDATION_FENETRE);
  signal etat_present, etat_futur : etat_type;
  
  -- Compteur de pixels
  signal compteur_pixel : integer range 0 to LARGEUR_IMAGE*HAUTEUR_IMAGE;
  
  -- Signaux de contrôle
  constant prog_full_thresh_int : integer := LARGEUR_IMAGE - 5;
  signal prog_full_thresh : std_logic_vector(9 downto 0);
  
  signal wr_en_fifo1, wr_en_fifo2 : std_logic := '0';
  signal en_milieu, en_haut : std_logic := '0';
  
  -- Signaux de données
  signal ligne_actuelle, ligne_moins1, ligne_moins2 : std_logic_vector(7 downto 0);
  signal bas_gauche, bas_milieu, bas_droite : std_logic_vector(7 downto 0);
  signal milieu_gauche, milieu_milieu, milieu_droite : std_logic_vector(7 downto 0);
  signal haut_gauche, haut_milieu, haut_droite : std_logic_vector(7 downto 0);
  
  -- Signaux FIFO
  signal full1, empty1, full2, empty2 : std_logic;
  signal prog_full_fifo1, prog_full_fifo2 : std_logic;
  signal wr_rst_busy1, rd_rst_busy1, wr_rst_busy2, rd_rst_busy2 : std_logic;
  
  signal fenetre_valide_interne : std_logic := '0';

begin

  prog_full_thresh <= std_logic_vector(to_unsigned(prog_full_thresh_int, 10));
  ligne_actuelle <= pixel_entree;

  -- Ligne du bas (ligne actuelle)
  u_ligne_bas : ligne_retard
    port map(
      clk   => clk,
      rst   => rst,
      en    => pixel_valide,
      din   => ligne_actuelle,
      dout1 => bas_droite,
      dout2 => bas_milieu,
      dout3 => bas_gauche
    );
  
  -- FIFO 1 (stocke une ligne complète)
  u_fifo1 : fifo_generator_1
    port map(
      clk   => clk,
      rst  => rst,
      din   => bas_gauche,
      wr_en => wr_en_fifo1,
      rd_en => prog_full_fifo1,
      prog_full_thresh => prog_full_thresh,
      dout  => ligne_moins1,
      full  => full1,
      empty => empty1,
      prog_full => prog_full_fifo1,
      wr_rst_busy => wr_rst_busy1,
      rd_rst_busy => rd_rst_busy1
    );
  
  -- Ligne du milieu
  u_ligne_milieu : ligne_retard
    port map(
      clk   => clk,
      rst   => rst,
      en    => '1',--en_milieu,
      din   => ligne_moins1,
      dout1 => milieu_droite,
      dout2 => milieu_milieu,
      dout3 => milieu_gauche
    );

  -- FIFO 2 (stocke une deuxième ligne complète)
  u_fifo2 : fifo_generator_1
    port map(
      clk   => clk,
      rst  => rst,
      din   => milieu_gauche,
      wr_en => wr_en_fifo2,
      rd_en => prog_full_fifo2,
      prog_full_thresh => prog_full_thresh,
      dout  => ligne_moins2,
      full  => full2,
      empty => empty2,
      prog_full => prog_full_fifo2,
      wr_rst_busy => wr_rst_busy2,
      rd_rst_busy => rd_rst_busy2
    );

  -- Ligne du haut
  u_ligne_haut : ligne_retard
    port map(
      clk   => clk,
      rst   => rst,
      en    => en_haut,
      din   => ligne_moins2,
      dout1 => haut_droite,
      dout2 => haut_milieu,
      dout3 => haut_gauche
    );

  -- Affectation des sorties (fenêtre 3x3)
  p00 <= haut_gauche;    p01 <= haut_milieu;    p02 <= haut_droite;
  p10 <= milieu_gauche;  p11 <= milieu_milieu;  p12 <= milieu_droite;
  p20 <= bas_gauche;     p21 <= bas_milieu;     p22 <= bas_droite;

  fenetre_valide <= fenetre_valide_interne;
  

  -- Machine à états : Processus séquentiel
  process(clk, rst)
  begin
    if rst = '1' then
      etat_present <= INIT;
      compteur_pixel <= 0;
    elsif rising_edge(clk) then
      etat_present <= etat_futur;
      if pixel_valide = '1' then
        compteur_pixel <= compteur_pixel + 1;
      end if;
    end if;
  end process;

  process(etat_present, pixel_valide, compteur_pixel, prog_full_fifo1, prog_full_fifo2)
  begin

    case etat_present is

      when INIT =>
        -- Attente du premier pixel
        if pixel_valide = '1' then
          etat_futur <= LIGNE1;
        end if;
      
      when LIGNE1 =>
        -- Remplissage de la première ligne
        -- Attendre 3 cycles que le premier pixel atteigne bas_gauche
        if compteur_pixel > 2 then
          wr_en_fifo1 <= '1';
        end if;
        if compteur_pixel >= LARGEUR_IMAGE  then
          etat_futur <= ATTENTE_FIFO1;
          en_milieu <= '1';
        end if;
      
      when ATTENTE_FIFO1 =>
        -- Attente que FIFO1 soit prog_full
        wr_en_fifo1 <= '1';
        if prog_full_fifo1 = '1' then
          etat_futur <= LIGNE2;
        end if;
      
      when LIGNE2 =>
        -- Remplissage de la deuxième ligne
        if compteur_pixel >= LARGEUR_IMAGE + 3 then
        wr_en_fifo2 <= '1';
        end if;
        if compteur_pixel >= 2*LARGEUR_IMAGE - 4 then
          etat_futur <= ATTENTE_FIFO2;
          en_haut <= '1';
        end if;
      
      when ATTENTE_FIFO2 =>
        -- Attente que FIFO2 soit prog_full
        en_milieu <= '1';
        en_haut <= '1';
        if prog_full_fifo2 = '1' and compteur_pixel = 2*LARGEUR_IMAGE + 4 then
          etat_futur <= VALIDATION_FENETRE;
        end if;
      
      when VALIDATION_FENETRE =>
        wr_en_fifo1 <='1';
        wr_en_fifo2 <= '1';
          en_milieu   <= '1';
          en_haut     <= '1';
          fenetre_valide_interne <= pixel_valide;
      
      when others =>
        etat_futur <= INIT;
        
    end case;
  end process;

end rtl;