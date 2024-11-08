----------------------------------------------------------------------------
-- Auteur(s)        : Florian TUTZO
--
-- Projet           : Capitalisation
--
-- Date de creation : 10/02/15
--
-- Description      : Package pour la generation de fichier log
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
use std.textio.all;

use work.stdio_h.all;
use work.strings_h.all;


package pkg_doc is

   ---------------------------------------------------------------------------
   -- Procedure creant le fichier de log des resultats
   ---------------------------------------------------------------------------
   procedure initLog;

   ---------------------------------------------------------------------------
   -- Procedure affichant un texte de type titre_1
   -- L'affichage se fait à l'ecran, dans le fichier de log et dans le document
   -- de test lors de sa generation
   ---------------------------------------------------------------------------
   procedure docTitle1(text : in string);

   ---------------------------------------------------------------------------
   -- Procedure affichant un texte de type titre_2
   -- L'affichage se fait à l'ecran, dans le fichier de log et dans le document
   -- de test lors de sa generation
   ---------------------------------------------------------------------------
   procedure docTitle2(text : in string);

   ---------------------------------------------------------------------------
   -- Procedure affichant un texte de type titre_3
   -- L'affichage se fait à l'ecran, dans le fichier de log et dans le document
   -- de test lors de sa generation
   ---------------------------------------------------------------------------
   procedure docTitle3(text : in string);

   ---------------------------------------------------------------------------
   -- Procedure affichant un texte standart
   -- L'affichage se fait à l'ecran, dans le fichier de log et dans le document
   -- de test lors de sa generation
   ---------------------------------------------------------------------------
   procedure docText(text : in string);

   ---------------------------------------------------------------------------
   -- Procedure affichant un texte de type titre_1
   -- L'affichage se fait à l'ecran et dans le fichier de log
   ---------------------------------------------------------------------------
   procedure logTitle1(text : in string);

   ---------------------------------------------------------------------------
   -- Procedure affichant un texte de type titre_2
   -- L'affichage se fait à l'ecran et dans le fichier de log
   ---------------------------------------------------------------------------
   procedure logTitle2(text : in string);

   ---------------------------------------------------------------------------
   -- Procedure affichant un texte de type titre_3
   -- L'affichage se fait à l'ecran et dans le fichier de log
   ---------------------------------------------------------------------------
   procedure logTitle3(text : in string);

   ---------------------------------------------------------------------------
   -- Procedure affichant un texte standart
   -- L'affichage se fait à l'ecran et dans le fichier de log
   ---------------------------------------------------------------------------
   procedure logText(text : in string);

   ---------------------------------------------------------------------------
   -- Procedure affichant un texte standart en gras
   -- L'affichage se fait à l'ecran et dans le fichier de log
   ---------------------------------------------------------------------------
   procedure logBoldText(text : in string);

   ---------------------------------------------------------------------------
   -- Procedure affichant un texte d'erreur en rouge
   -- L'affichage se fait à l'ecran et dans le fichier de log
   -- severityCase : error ou failure
   ---------------------------------------------------------------------------
   procedure logError(text           : in string;
                      severityCase   : in Severity_Level);

   ---------------------------------------------------------------------------
   -- Procedure affichant le titre du test en cours
   -- L'affichage se fait à l'ecran et dans le fichier de log
   -- numTest     : numero du test. Ce numero est incremente en fin de procedure
   ---------------------------------------------------------------------------
   procedure logInitTest(text     : in    string;
                         numTest  : inout integer);

   ---------------------------------------------------------------------------
   -- Procedure affichant le resultat d'un test intermediaire
   -- L'affichage se fait à l'ecran et dans le fichier de log
   -- testError   : resultat du test (0=OK, autre=KO). Remis a 0 en fin de procedure
   -- numTest     : numero du test. Ce numero est incremente en fin de procedure
   -- nbTestOk    : nombre de test OK. Si test OK alors nbTestOk=nbTestOk+1
   ---------------------------------------------------------------------------
   procedure logResultTest(testError: inout integer;
                           numTest  : inout integer;
                           nbTestOk : inout integer);

   ---------------------------------------------------------------------------
   -- Procedure affichant le resultat final des tests
   -- L'affichage se fait à l'ecran et dans le fichier de log
   -- nbTestOk    : nombre de test OK
   -- nbTest      : nombre de test total
   ---------------------------------------------------------------------------
   procedure logResultTestGlobal(nbTestOk : integer;
                                 nbTest   : integer);

end package pkg_doc;


package body pkg_doc is

   -- fichier de log
   shared variable log   : CFILE;

   ---------------------------------------------------------------------------
   -- Procedure initLog
   ---------------------------------------------------------------------------
   procedure initLog is
   begin
      log := fopen("result.mkp", "w");
   end procedure initLog;


   ---------------------------------------------------------------------------
   -- Procedure docTitle1
   ---------------------------------------------------------------------------
   procedure docTitle1(text : in string) is
   begin
      printf("---------------------------------------------------------------------------\n");
      printf("%s\n", text);
      printf("---------------------------------------------------------------------------\n");
      fprintf(log, "=%s=\n", text);
   end procedure docTitle1;


   ---------------------------------------------------------------------------
   -- Procedure docTitle2
   ---------------------------------------------------------------------------
   procedure docTitle2(text : in string) is
   begin
      printf("---------------------------------------------------------------------------\n");
      printf("%s\n", text);
      printf("---------------------------------------------------------------------------\n");
      fprintf(log, "==%s==\n", text);
   end procedure docTitle2;


   ---------------------------------------------------------------------------
   -- Procedure docTitle3
   ---------------------------------------------------------------------------
   procedure docTitle3(text : in string) is
   begin
      printf("---------------------------------------------------------------------------\n");
      printf("%s\n", text);
      printf("---------------------------------------------------------------------------\n");
      fprintf(log, "===%s===\n", text);
   end procedure docTitle3;


   ---------------------------------------------------------------------------
   -- Procedure DocText
   ---------------------------------------------------------------------------
   procedure docText (text : in string) is
   begin
      printf("---------------------------------------------------------------------------\n");
      printf("%s\n", text);
      printf("---------------------------------------------------------------------------\n");
      fprintf(log, "%s\n", text);
   end procedure DocText;


   ---------------------------------------------------------------------------
   -- Procedure logTitle1
   ---------------------------------------------------------------------------
   procedure logTitle1(text : in string) is
   begin
      printf("---------------------------------------------------------------------------\n");
      printf("%s\n", text);
      printf("---------------------------------------------------------------------------\n");
      fprintf(log, "=%s=\n", text);
   end procedure logTitle1;


   ---------------------------------------------------------------------------
   -- Procedure logTitle2
   ---------------------------------------------------------------------------
   procedure logTitle2(text : in string) is
   begin
      printf("---------------------------------------------------------------------------\n");
      printf("%s\n", text);
      printf("---------------------------------------------------------------------------\n");
      fprintf(log, "==%s==\n", text);
   end procedure logTitle2;


   ---------------------------------------------------------------------------
   -- Procedure logTitle3
   ---------------------------------------------------------------------------
   procedure logTitle3(text : in string) is
   begin
      printf("---------------------------------------------------------------------------\n");
      printf("%s\n", text);
      printf("---------------------------------------------------------------------------\n");
      fprintf(log, "===%s===\n", text);
   end procedure logTitle3;


   ---------------------------------------------------------------------------
   -- Procedure logText
   ---------------------------------------------------------------------------
   procedure logText(text : in string) is
   begin
      printf("---------------------------------------------------------------------------\n");
      printf("%s\n", text);
      printf("---------------------------------------------------------------------------\n");
      fprintf(log, "%s<br/>\n", text);
   end procedure logText;


   ---------------------------------------------------------------------------
   -- Procedure logBoldText
   ---------------------------------------------------------------------------
   procedure logBoldText(text : in string) is
   begin
      printf("---------------------------------------------------------------------------\n");
      printf("%s\n", text);
      printf("---------------------------------------------------------------------------\n");
      fprintf(log, "'''%s'''<br/>\n", text);
   end procedure logBoldText;


   ---------------------------------------------------------------------------
   -- Procedure logError
   ---------------------------------------------------------------------------
   procedure logError(text         : in string;
                      severityCase : in Severity_Level ) is
   begin
      fprintf(log, "<font color=""red"">'''Error''' : %s</font><br/>\n", text);
      printf("---------------------------------------------------------------------------\n");
      printf("%i ns => %s\n", pf(integer(now / 1 ns)), text);
      printf("---------------------------------------------------------------------------\n");
   end procedure logError;


   ---------------------------------------------------------------------------
   -- Procedure logInitTest
   ---------------------------------------------------------------------------
   procedure logInitTest(text     : in    string;
                         numTest  : inout integer) is
   begin
      printf("----------------------------------------------------------------\n");
      printf("TEST %s : %s\n", integer'image(numTest + 1), text);
      printf("----------------------------------------------------------------\n");
      fprintf(log, "'''----------------------------------------------------------------'''<br/>");
      fprintf(log, "'''TEST %s : %s'''<br/>", integer'image(numTest + 1), text);
      fprintf(log, "'''----------------------------------------------------------------'''<br/>");
   end procedure logInitTest;


   ---------------------------------------------------------------------------
   -- Procedure logResultTest
   ---------------------------------------------------------------------------
   procedure logResultTest (
      testError  : inout integer;
      numTest    : inout integer;
      nbTestOk   : inout integer) is
   begin
      if testError = 0 then
         printf("---------------------------------------------------------------------------\n");
         printf("TEST %s OK\n", integer'image(numTest+1));
         printf("---------------------------------------------------------------------------\n");
         fprintf(log, "<font color=""green"">'''Test %s OK'''</font><br/>\n\n", integer'image(numTest+1));
         nbTestOk := nbTestOk + 1;
      else
         printf("---------------------------------------------------------------------------\n");
         printf("TEST %s KO\n", integer'image(numTest+1));
         printf("---------------------------------------------------------------------------\n");
         fprintf(log, "<font color=""red"">'''Test %s KO'''</font><br/>\n\n", integer'image(numTest+1));
      end if;
      -- Remise a  0 du testError
      testError   := 0;
      -- Incrementation compteur de test
      numTest     := numTest + 1;
      -- new line
      fprintf(log, "");
   end procedure logResultTest;


   ---------------------------------------------------------------------------
   -- Procedure logResultTestGlobal
   ---------------------------------------------------------------------------
   procedure logResultTestGlobal (
      nbTestOk : in integer;
      nbTest   : in integer) is
   begin
      printf("---------------------------------------------------------------------------\n");
      printf("GLOBAL TEST : %s/%s OK\n", integer'image(nbTestOk), integer'image(nbTest));
      printf("---------------------------------------------------------------------------\n");
      if(nbTestOk = nbTest) then
         fprintf(log, "<br><font color=""green"">'''GLOBAL TEST : %s/%s OK '''</font>\n", integer'image(nbTestOk), integer'image(nbTest));
      else
         fprintf(log, "<br><font color=""red"">'''GLOBAL TEST : %s/%s KO '''</font>\n", integer'image(nbTestOk), integer'image(nbTest));
      end if;
      fclose(log);

      assert FALSE report "===============Fin du test===============\n" severity failure;
   end procedure;


end package body pkg_doc;
