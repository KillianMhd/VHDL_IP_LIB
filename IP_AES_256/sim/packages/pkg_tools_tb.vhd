----------------------------------------------------------------------------
-- Auteur(s)        : Florian TUTZO
--
-- Projet           : Capitalisation
--
-- Date de creation : 10/02/15
--
-- Description      : Package pour la gestion des verifications automatiques
--
----------------------------------------------------------------------------
-- Historique    :
--
-- v1.0 14/01/15 Philippe LESPRIT / Florian TUTZO
-- Creation
--
----------------------------------------------------------------------------
-- Copyright (c) 2014 par ELSYS Design Group
-- Tous les droits sont reserves. Toute reproduction totale ou partielle est
-- interdite sans le consentement ecrit du proprietaire des droits d'auteur.
----------------------------------------------------------------------------

---------------------------------------------------------------------------
-- DECLARATION DES LIBRAIRIES                                            --
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.stdio_h.all;
use work.strings_h.all;
use work.pkg_doc.all;

---------------------------------------------------------------------------
-- DECLARATION DU PACKAGE                                                --
---------------------------------------------------------------------------
package PKG_TOOLS_TB is

   constant MAX_STR : integer :=  256;

   ---------------------------------------------------------------------------
   -- Procedure comparant deux std_logic et affichant le resultat de la
   -- comparaison
   -- outputName  : Description des donnees comparees
   -- output      : Sortie a comparer
   -- ref         : Reference de la comparaison
   -- display     : Choix de l'affichage du resultat s'il n'y a pas d'erreur
   --               0=pas d'affichage, 1=affichage
   --               En cas d'erreur le resultat est forcement affiche
   -- testError   : Cette valeur d'entree est incrementee s'il y a une erreur
   ---------------------------------------------------------------------------
   procedure compare_Output_To_Reference(
      outputName        : in    string;
      output            : in    std_logic;
      ref               : in    std_logic;
      display           : in    boolean;
      testError         : inout integer
   );

   ---------------------------------------------------------------------------
   -- Procedure comparant deux std_logic_vector et affichant le resultat de la
   -- comparaison
   -- outputName  : Description des donnees comparees
   -- output      : Sortie a comparer
   -- ref         : Reference de la comparaison
   -- display     : Choix de l'affichage du resultat s'il n'y a pas d'erreur
   --               0=pas d'affichage, 1=affichage
   --               En cas d'erreur le resultat est forcement affiche
   -- testError   : Cette valeur d'entree est incrementee s'il y a une erreur
   ---------------------------------------------------------------------------
   procedure compare_Output_To_Reference(
      outputName        : in    string;
      output            : in    std_logic_vector;
      ref               : in    std_logic_vector;
      display           : in    boolean;
      testError         : inout integer
   );

   ---------------------------------------------------------------------------
   -- Procedure comparant un std_logic_vector et un entier et affichant le
   -- resultat de la comparaison
   -- outputName  : Description des donnees comparees
   -- output      : Sortie a comparer
   -- ref         : Reference de la comparaison
   -- display     : Choix de l'affichage du resultat s'il n'y a pas d'erreur
   --               0=pas d'affichage, 1=affichage
   --               En cas d'erreur le resultat est forcement affiche
   -- testError   : Cette valeur d'entree est incrementee s'il y a une erreur
   ---------------------------------------------------------------------------
   procedure compare_Output_To_Reference(
      outputName        : in    string;
      output            : in    std_logic_vector;
      ref               : in    integer;
      display           : in    boolean;
      testError         : inout integer
   );

   ---------------------------------------------------------------------------
   -- Procedure comparant deux entier et affichant le resultat de la comparaison
   -- outputName  : Description des donnees comparees
   -- output      : Sortie a comparer
   -- ref         : Reference de la comparaison
   -- display     : Choix de l'affichage du resultat s'il n'y a pas d'erreur
   --               0=pas d'affichage, 1=affichage
   --               En cas d'erreur le resultat est forcement affiche
   -- testError   : Cette valeur d'entree est incrementee s'il y a une erreur
   ---------------------------------------------------------------------------
   procedure compare_Output_To_Reference(
      outputName        : in    string;
      output            : in    integer;
      ref               : in    integer;
      display           : in    boolean;
      testError         : inout integer
   );

---------------------------------------------------------------------------
-- END OF PACKAGE HEADER
---------------------------------------------------------------------------
end PKG_TOOLS_TB;

---------------------------------------------------------------------------
-- BEGIN OF PACKAGE BODY
---------------------------------------------------------------------------
package body PKG_TOOLS_TB is

   ---------------------------------------------------------------------------
   -- Procedure compare_Output_To_Reference
   ---------------------------------------------------------------------------
   procedure compare_Output_To_Reference(
      outputName        : in    string;
      output            : in    std_logic;
      ref               : in    std_logic;
      display           : in    boolean;
      testError         : inout integer
   ) is
      variable buff : string(1 to MAX_STR);
   begin
      if output = ref then
         if display then
            sprintf(buff, "Test signal '%s' : valeur lue '%s'",outputName, pf(output));
            logText(buff);
         end if;
      else
         sprintf(buff, "Error: Test signal '%s' : valeur lue '%s' au lieu de '%s'",outputName, pf(output), pf(ref));
         logError(buff, error);
         testError := testError + 1;
      end if;
   end procedure compare_Output_To_Reference;

   ---------------------------------------------------------------------------
   -- Procedure compare_Output_To_Reference
   ---------------------------------------------------------------------------
   procedure compare_Output_To_Reference(
      outputName        : in    string;
      output            : in    std_logic_vector;
      ref               : in    std_logic_vector;
      display           : in    boolean;
      testError         : inout integer
   ) is
      variable buff : string(1 to 256);
   begin
      if output = ref then
         if display then
            sprintf(buff, "Test signal '%s' : valeur lue 0x%x",outputName, pf(output));
            logText(buff);
         end if;
      else
         sprintf(buff, "Error: Test signal '%s' : valeur lue 0x%x au lieu de 0x%x",outputName, pf(output), pf(ref));
         logError(buff, error);
         testError := testError + 1;
      end if;
   end procedure compare_Output_To_Reference;


   ---------------------------------------------------------------------------
   -- Procedure compare_Output_To_Reference
   ---------------------------------------------------------------------------
   procedure compare_Output_To_Reference(
      outputName        : in    string;
      output            : in    std_logic_vector;
      ref               : in    integer;
      display           : in    boolean;
      testError         : inout integer
   ) is
      variable buff : string(1 to 256);
   begin
      if unsigned(output) = ref then
         if display then
            sprintf(buff, "Test signal '%s' : valeur lue 0x%x",outputName, pf(output));
            logText(buff);
         end if;
      else
         sprintf(buff, "Error: Test signal '%s' : valeur lue 0x%x au lieu de 0x%x",outputName, pf(output), pf(ref));
         logError(buff, error);
         testError := testError + 1;
      end if;
   end procedure compare_Output_To_Reference;


   ---------------------------------------------------------------------------
   -- Procedure compare_Output_To_Reference
   ---------------------------------------------------------------------------
   procedure compare_Output_To_Reference(
      outputName        : in    string;
      output            : in    integer;
      ref               : in    integer;
      display           : in    boolean;
      testError         : inout integer
   ) is
      variable buff : string(1 to 256);
   begin
      if output = ref then
         if display then
            sprintf(buff, "Test signal '%s' : valeur lue 0x%x",outputName, pf(output));
            logText(buff);
         end if;
      else
         sprintf(buff, "Error: Test signal '%s' : valeur lue 0x%x au lieu de 0x%x",outputName, pf(output), pf(ref));
         logError(buff, error);
         testError := testError + 1;
      end if;
   end procedure compare_Output_To_Reference;


end PKG_TOOLS_TB;

