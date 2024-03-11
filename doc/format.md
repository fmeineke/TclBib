##Warum das *.ilf Format?
- Datenbasis ist ASCII Text
- Format soll gut maschinenlesbar und konvertierbar sein
- Format soll gut menschenlesbar sein und auch in einem einfachen Texteditor
  erweitert werden können
- es sollten auch eigene und neue Felder möglich sein
- ...

---------------------------------------------------------------------------
##Aufbau des *.ilf Format für TclBib:


- eine Referenz besteht aus mehreren Eintragszeilen der Form 
    :<Schlüsselwort>: <Inhalt> 
  siehe Liste unten
  
- nach jeder Referenz, auch der letzen, folgt eine Trennzeile:
    ****

- die Einträge :ABSTRACT: und :CONTENTS: dürfen eventuell auch Zeilentrenner
  enthalten; der <Inhalt> geht dann bis zu einem neuem Schlüsselwort. Sollte 
  jedoch z.B. im Abstract eine Zeile hier mit :<Schlüsselwort>: beginnen, gibts
  Fehler. Sicherer sind beliebig lange Zeilen.

- jede Zeile, die mit '#' beginnt, wird als Kommentarzeile (nicht) behandelt;

- jede ansonsten nicht erkannte Zeile wird ignoriert;
  
---------------------------------------------------------------------------
Bisherige Praxis:

- siehe Beispiele unten, z.B. werden die MESH Felder nicht aufgenommen;
- momentan sind nur Artikel, keine Bücher aufgenommen;


---------------------------------------------------------------------------
Felder des *.ilf Format:

Wichtige:
:AUTHOR:        Autorenliste, z.B. Alexander, W.S.; Roberts, A.W.
                Dieses Format ist wichtig !
                Nicht C.S Potten sondern Potten, C.S.
                Namenstrenner ist ein ';'.
                'von' etc. werden hintenangestellt:
                    Weizsäcker, R. von
:TITLE:         Titel (Orginal)
:JOURNAL:       Zeitschrift
                die Journal Felder sehen momentan aus wie aus der Medline 
                geholt; die Leerzeichen sind jedoch durch '-' ersetzt:
                aus <J Theor Biol> wird <J-Theor-Biol>

:OTITLE:        englischsprachiger Titel, falls abweichend von :TITLE:
:PDATE:         Publikations Datum, z.B. 1996 oder 4.1996 oder 23.4.1996
:PTYPE:         Publikations Typ, z.B. Article, Book. 
                Default ist Article
:ABSTRACT:      Zusammenfassung
:NUMBER:        Heftnummer
:VOLUME:        Zeitschriftenband
:PAGES:         Seitenbereich, z.B. 12-18 , 13
                tclbib konvertiert momentan Bereiche der Art 101-23 
                nach 101-123
:ISSN:          Zeitschriften Code
:MEDID:         Medline Kennummer
:PUBMEDID:      Public Medline Kennummer


Wichtige neue Felder, selbst eingetragen:
:CONTENT:       Nutzerdefiniertes Inhaltsfeld
:PLACE:         Ablage

Mehr für Bücher:
:BOOKTITLE:   
:CHAPTER:     
:EDITION:     
:EDITOR:      
:PUBLISHER:     Verlag, z.B. Springer
:PADDRESS:      Verlagsanschrift, z.B. Heidelberg 
:SERIES:   
:ISBN:    0  

Weniger wichtige, z.B. wie in Medline geliefert:
:NOTE:          Technische Bemerkungen
:CTYPE:         Inhaltlicher Typ, z.B. Report, Study"
:KEYWORDS:      Nutzerdefinierte Schluessel
:MESH:          Medline Schlagwörter
:OBJECTS:       Schlagwörter bzgl. Dingen
:PERSONS:       Schlagwörter bzgl. Personen
:AADDRESS:      Autoren Anschrift
:XREF:          ???
:REFNUM:        ???
:DBDATE:        Datum des Eintrags in die Datenbank
:LANGUAGE:      Sprache der Publikation"
:GRANTID:       ???
:ORGANIZATION: 
:PUBLISHEDAS: 
:SCHOOL:       
:INSTITUTION:

Interne, von tclbib selbst generierte:
:ID:            Systeminterne eindeutige Kennung, z.B. abc
:TEXID:         Kennung für Textverarbeitung, z.B. arnl-dpcm-96.

---------------------------------------------------------------------------

##Beispiel einer *.ilf Datei:


    # ILF Literature Database
    # Creator   : TclBib, version 27.6.1998
    # Generated : 01.03.1999, 18:53
    
    :ID:        aae
    :TEXID:     a-cses-95
    :AUTHOR:    Agarwal, P.
    :TITLE:     Cellular segregation and engulfment simulations using the cell programming language.
    :JOURNAL:   J-Theor-Biol
    :PDATE:     07.09.1995
    :NUMBER:    1
    :VOLUME:    176
    :PAGES:     79-89
    :PLACE:     -
    :KEYWORDS:  -
    :CONTENT:   -
    :ABSTRACT:  In developmental biology, modeling and simulation play an important
    role in understanding cellular interactions. In this paper a simple language,
    the Cell Programming Language (CPL), is suggested for writing programs that
    describe this behavior. Using these programs, it is possible to simulate and
    visualize intercellular behavior. CPL is used to model cellular segregation
    based upon the differential adhesion hypothesis. Results indicate that a high
    degree of segregation can be produced in a mixture of cells by allowing random
    motion. The engulfment of a tissue by a less adhesive tissue is also observed
    when the two tissues are placed in contact. Both these simulations utilize only
    local interactions and random motion of cells. Earlier simulations used
    long-range interactions to observe similar effects. The present simulations
    prove that random motion of cells can produce long-range effects.
    :AADDRESS:  Department of Computer Science, Courant Institute of Mathematical Sciences, New York University, New York 10012, USA.
    :DBDATE:    1996/02
    :ISSN:      0022-5193
    :MEDID:     96046879
    :PUBMEDID:  0007475109
    ****
    :ID:        aco
    :TEXID:     aoky-mshh-95
    :AUTHOR:    Araki, K.; Ogata, T.; Kobayashi, M.; Yatani, R.
    :TITLE:     A morphological study on the histogenesis of human colorectal hyperplastic polyps.
    :JOURNAL:   Gastroenterology
    :PDATE:     11.1995
    :NUMBER:    5
    :VOLUME:    109
    :PAGES:     1468-1474
    :PLACE:     -
    :KEYWORDS:  -
    :CONTENT:   -
    :ABSTRACT:  BACKGROUND & AIMS: Little is known about the histogenesis of human colorectal hyperplastic polyp, although this polyp is clinically very common. Therefore, the structural features of the polyp and their implications regarding histogenesis were studied. METHODS: A total of 261 foci were examined using scanning electronmicroscopic observation of the isolated crypt and surface structure, NaOH cell maceration and scanning electron microscopy, dissecting microscopy, and standard histological analysis. RESULTS: In surface view, each polyp crypt was discretely demarcated as in the normal crypt, suggesting that the crypt epithelium had not replaced the adjoining crypt. Notches at the base and various stages of branching, observed in 21.8% of the isolated crypts, were considered to reflect crypt fission. Several polyps with a single crypt mouth consisting of fissioned multiple crypts suggested polyp origin from a single crypt and growth by fission. Juxtaposition of small polyps and their fusion suggested polycentric origin. Almost all polyps showed increased stromal inflammatory cell infiltration and/or a lymphoid follicle at the base. CONCLUSIONS: Hyperplastic polyps originate by the apparent fusion of single abnormal crypts within a small region of mucosa. The polyps grow by fission of the crypt and fusion of the polycentrically originated polyps. Chronic inflammation has some relation to this process.
    :AADDRESS:  First Department of Surgery, Kochi Medical School, Japan.
    :DBDATE:    1996/01
    :ISSN:      0016-5085
    :MEDID:     96036334
    ****
