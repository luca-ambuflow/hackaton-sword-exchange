-- =====================================================
-- Migration: 007_reference_data.sql
-- Description: Reference data tables (EPS organizations, Italian regions, disciplines)
-- Phase: All phases - Referenced by various features
-- =====================================================

-- =====================================================
-- TABLE: eps_organizations
-- Description: Predefined list of Italian EPS organizations
-- =====================================================
CREATE TABLE public.eps_organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  country TEXT DEFAULT 'IT',
  website TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  display_order INTEGER DEFAULT 0
);

-- Seed EPS organizations data
INSERT INTO public.eps_organizations (code, name, website, display_order) VALUES
  ('csen', 'CSEN - Centro Sportivo Educativo Nazionale', 'https://www.csen.it', 1),
  ('asi', 'ASI - Associazioni Sportive e Sociali Italiane', 'https://www.asinazionale.it', 2),
  ('aics', 'AICS - Associazione Italiana Cultura Sport', 'https://www.aics.it', 3),
  ('msp', 'MSP Italia - Movimento Sportivo Popolare', 'https://www.mspitalia.it', 4),
  ('uisp', 'UISP - Unione Italiana Sport Per tutti', 'https://www.uisp.it', 5),
  ('csi', 'CSI - Centro Sportivo Italiano', 'https://www.csi-net.it', 6),
  ('acsi', 'ACSI - Associazione Centri Sportivi Italiani', 'https://www.acsi.it', 7),
  ('libertas', 'Libertas - Associazione Nazionale Polisportive', 'https://www.libertasnazionale.it', 8),
  ('other', 'Altro / Other', NULL, 99);

-- No RLS needed (public reference data)
ALTER TABLE public.eps_organizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "EPS organizations are viewable by everyone"
  ON public.eps_organizations FOR SELECT
  USING (is_active = TRUE);

-- =====================================================
-- TABLE: italian_regions
-- Description: Italian regions and provinces for location filtering
-- =====================================================
CREATE TABLE public.italian_regions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  region_code TEXT NOT NULL,
  region_name TEXT NOT NULL,
  province_code TEXT,
  province_name TEXT,
  UNIQUE(region_code, province_code)
);

-- Seed Italian regions and provinces
INSERT INTO public.italian_regions (region_code, region_name, province_code, province_name) VALUES
  -- Abruzzo
  ('ABR', 'Abruzzo', 'AQ', 'L''Aquila'),
  ('ABR', 'Abruzzo', 'CH', 'Chieti'),
  ('ABR', 'Abruzzo', 'PE', 'Pescara'),
  ('ABR', 'Abruzzo', 'TE', 'Teramo'),
  
  -- Basilicata
  ('BAS', 'Basilicata', 'MT', 'Matera'),
  ('BAS', 'Basilicata', 'PZ', 'Potenza'),
  
  -- Calabria
  ('CAL', 'Calabria', 'CZ', 'Catanzaro'),
  ('CAL', 'Calabria', 'CS', 'Cosenza'),
  ('CAL', 'Calabria', 'KR', 'Crotone'),
  ('CAL', 'Calabria', 'RC', 'Reggio Calabria'),
  ('CAL', 'Calabria', 'VV', 'Vibo Valentia'),
  
  -- Campania
  ('CAM', 'Campania', 'AV', 'Avellino'),
  ('CAM', 'Campania', 'BN', 'Benevento'),
  ('CAM', 'Campania', 'CE', 'Caserta'),
  ('CAM', 'Campania', 'NA', 'Napoli'),
  ('CAM', 'Campania', 'SA', 'Salerno'),
  
  -- Emilia-Romagna
  ('EMR', 'Emilia-Romagna', 'BO', 'Bologna'),
  ('EMR', 'Emilia-Romagna', 'FC', 'Forlì-Cesena'),
  ('EMR', 'Emilia-Romagna', 'FE', 'Ferrara'),
  ('EMR', 'Emilia-Romagna', 'MO', 'Modena'),
  ('EMR', 'Emilia-Romagna', 'PC', 'Piacenza'),
  ('EMR', 'Emilia-Romagna', 'PR', 'Parma'),
  ('EMR', 'Emilia-Romagna', 'RA', 'Ravenna'),
  ('EMR', 'Emilia-Romagna', 'RE', 'Reggio Emilia'),
  ('EMR', 'Emilia-Romagna', 'RN', 'Rimini'),
  
  -- Friuli-Venezia Giulia
  ('FVG', 'Friuli-Venezia Giulia', 'GO', 'Gorizia'),
  ('FVG', 'Friuli-Venezia Giulia', 'PN', 'Pordenone'),
  ('FVG', 'Friuli-Venezia Giulia', 'TS', 'Trieste'),
  ('FVG', 'Friuli-Venezia Giulia', 'UD', 'Udine'),
  
  -- Lazio
  ('LAZ', 'Lazio', 'FR', 'Frosinone'),
  ('LAZ', 'Lazio', 'LT', 'Latina'),
  ('LAZ', 'Lazio', 'RI', 'Rieti'),
  ('LAZ', 'Lazio', 'RM', 'Roma'),
  ('LAZ', 'Lazio', 'VT', 'Viterbo'),
  
  -- Liguria
  ('LIG', 'Liguria', 'GE', 'Genova'),
  ('LIG', 'Liguria', 'IM', 'Imperia'),
  ('LIG', 'Liguria', 'SP', 'La Spezia'),
  ('LIG', 'Liguria', 'SV', 'Savona'),
  
  -- Lombardia
  ('LOM', 'Lombardia', 'BG', 'Bergamo'),
  ('LOM', 'Lombardia', 'BS', 'Brescia'),
  ('LOM', 'Lombardia', 'CO', 'Como'),
  ('LOM', 'Lombardia', 'CR', 'Cremona'),
  ('LOM', 'Lombardia', 'LC', 'Lecco'),
  ('LOM', 'Lombardia', 'LO', 'Lodi'),
  ('LOM', 'Lombardia', 'MN', 'Mantova'),
  ('LOM', 'Lombardia', 'MI', 'Milano'),
  ('LOM', 'Lombardia', 'MB', 'Monza e Brianza'),
  ('LOM', 'Lombardia', 'PV', 'Pavia'),
  ('LOM', 'Lombardia', 'SO', 'Sondrio'),
  ('LOM', 'Lombardia', 'VA', 'Varese'),
  
  -- Marche
  ('MAR', 'Marche', 'AN', 'Ancona'),
  ('MAR', 'Marche', 'AP', 'Ascoli Piceno'),
  ('MAR', 'Marche', 'FM', 'Fermo'),
  ('MAR', 'Marche', 'MC', 'Macerata'),
  ('MAR', 'Marche', 'PU', 'Pesaro e Urbino'),
  
  -- Molise
  ('MOL', 'Molise', 'CB', 'Campobasso'),
  ('MOL', 'Molise', 'IS', 'Isernia'),
  
  -- Piemonte
  ('PIE', 'Piemonte', 'AL', 'Alessandria'),
  ('PIE', 'Piemonte', 'AT', 'Asti'),
  ('PIE', 'Piemonte', 'BI', 'Biella'),
  ('PIE', 'Piemonte', 'CN', 'Cuneo'),
  ('PIE', 'Piemonte', 'NO', 'Novara'),
  ('PIE', 'Piemonte', 'TO', 'Torino'),
  ('PIE', 'Piemonte', 'VB', 'Verbano-Cusio-Ossola'),
  ('PIE', 'Piemonte', 'VC', 'Vercelli'),
  
  -- Puglia
  ('PUG', 'Puglia', 'BA', 'Bari'),
  ('PUG', 'Puglia', 'BT', 'Barletta-Andria-Trani'),
  ('PUG', 'Puglia', 'BR', 'Brindisi'),
  ('PUG', 'Puglia', 'FG', 'Foggia'),
  ('PUG', 'Puglia', 'LE', 'Lecce'),
  ('PUG', 'Puglia', 'TA', 'Taranto'),
  
  -- Sardegna
  ('SAR', 'Sardegna', 'CA', 'Cagliari'),
  ('SAR', 'Sardegna', 'CI', 'Carbonia-Iglesias'),
  ('SAR', 'Sardegna', 'VS', 'Medio Campidano'),
  ('SAR', 'Sardegna', 'NU', 'Nuoro'),
  ('SAR', 'Sardegna', 'OG', 'Ogliastra'),
  ('SAR', 'Sardegna', 'OT', 'Olbia-Tempio'),
  ('SAR', 'Sardegna', 'OR', 'Oristano'),
  ('SAR', 'Sardegna', 'SS', 'Sassari'),
  
  -- Sicilia
  ('SIC', 'Sicilia', 'AG', 'Agrigento'),
  ('SIC', 'Sicilia', 'CL', 'Caltanissetta'),
  ('SIC', 'Sicilia', 'CT', 'Catania'),
  ('SIC', 'Sicilia', 'EN', 'Enna'),
  ('SIC', 'Sicilia', 'ME', 'Messina'),
  ('SIC', 'Sicilia', 'PA', 'Palermo'),
  ('SIC', 'Sicilia', 'RG', 'Ragusa'),
  ('SIC', 'Sicilia', 'SR', 'Siracusa'),
  ('SIC', 'Sicilia', 'TP', 'Trapani'),
  
  -- Toscana
  ('TOS', 'Toscana', 'AR', 'Arezzo'),
  ('TOS', 'Toscana', 'FI', 'Firenze'),
  ('TOS', 'Toscana', 'GR', 'Grosseto'),
  ('TOS', 'Toscana', 'LI', 'Livorno'),
  ('TOS', 'Toscana', 'LU', 'Lucca'),
  ('TOS', 'Toscana', 'MS', 'Massa-Carrara'),
  ('TOS', 'Toscana', 'PI', 'Pisa'),
  ('TOS', 'Toscana', 'PT', 'Pistoia'),
  ('TOS', 'Toscana', 'PO', 'Prato'),
  ('TOS', 'Toscana', 'SI', 'Siena'),
  
  -- Trentino-Alto Adige
  ('TAA', 'Trentino-Alto Adige', 'BZ', 'Bolzano'),
  ('TAA', 'Trentino-Alto Adige', 'TN', 'Trento'),
  
  -- Umbria
  ('UMB', 'Umbria', 'PG', 'Perugia'),
  ('UMB', 'Umbria', 'TR', 'Terni'),
  
  -- Valle d''Aosta
  ('VDA', 'Valle d''Aosta', 'AO', 'Aosta'),
  
  -- Veneto
  ('VEN', 'Veneto', 'BL', 'Belluno'),
  ('VEN', 'Veneto', 'PD', 'Padova'),
  ('VEN', 'Veneto', 'RO', 'Rovigo'),
  ('VEN', 'Veneto', 'TV', 'Treviso'),
  ('VEN', 'Veneto', 'VE', 'Venezia'),
  ('VEN', 'Veneto', 'VR', 'Verona'),
  ('VEN', 'Veneto', 'VI', 'Vicenza');

-- No RLS needed (public reference data)
ALTER TABLE public.italian_regions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Italian regions are viewable by everyone"
  ON public.italian_regions FOR SELECT
  USING (true);

-- =====================================================
-- TABLE: disciplines
-- Description: Predefined disciplines/weapons for event filtering
-- =====================================================
CREATE TABLE public.disciplines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name_it TEXT NOT NULL,
  name_en TEXT,
  name_de TEXT,
  category TEXT, -- 'sword', 'dagger', 'polearm', 'grappling', 'mixed', 'other'
  is_active BOOLEAN DEFAULT TRUE,
  display_order INTEGER DEFAULT 0
);

-- Seed disciplines data
INSERT INTO public.disciplines (code, name_it, name_en, name_de, category, display_order) VALUES
  -- Swords
  ('spada_lunga', 'Spada Lunga', 'Longsword', 'Langschwert', 'sword', 1),
  ('spada_lato', 'Spada da Lato', 'Side Sword', 'Seitenschwert', 'sword', 2),
  ('spadone', 'Spadone', 'Greatsword / Montante', 'Großschwert', 'sword', 3),
  ('spada_boccoliere', 'Spada e Brocchiere', 'Sword & Buckler', 'Schwert & Buckler', 'sword', 4),
  ('rapier', 'Striscia / Rapier', 'Rapier', 'Rapier', 'sword', 5),
  ('sciabola', 'Sciabola', 'Saber', 'Säbel', 'sword', 6),
  ('spada_rotella', 'Spada e Rotella', 'Sword & Rotella', 'Schwert & Rotella', 'sword', 7),
  ('spada_targa', 'Spada e Targa', 'Sword & Targa', 'Schwert & Targa', 'sword', 8),
  ('messer', 'Messer', 'Messer', 'Messer', 'sword', 9),
  
  -- Daggers
  ('daga', 'Daga', 'Dagger', 'Dolch', 'dagger', 20),
  ('pugnale', 'Pugnale', 'Rondel Dagger', 'Panzerstecher', 'dagger', 21),
  
  -- Polearms
  ('lancia', 'Lancia', 'Spear', 'Speer', 'polearm', 30),
  ('alabarda', 'Alabarda', 'Halberd', 'Hellebarde', 'polearm', 31),
  ('asta', 'Armi in Asta', 'Polearms', 'Stangenwaffen', 'polearm', 32),
  
  -- Grappling
  ('lotta', 'Lotta / Abrazare', 'Wrestling / Grappling', 'Ringen', 'grappling', 40),
  ('daga_lotta', 'Daga e Lotta', 'Dagger Wrestling', 'Dolchringen', 'grappling', 41),
  
  -- Specialized
  ('armatura', 'Combattimento in Armatura', 'Armored Combat', 'Harnischfechten', 'specialized', 50),
  ('cavallo', 'Combattimento a Cavallo', 'Mounted Combat', 'Kampf zu Pferd', 'specialized', 51),
  
  -- Mixed
  ('mixed', 'Misto / Varie Armi', 'Mixed Weapons', 'Gemischte Waffen', 'mixed', 90),
  ('other', 'Altro', 'Other', 'Andere', 'other', 99);

-- No RLS needed (public reference data)
ALTER TABLE public.disciplines ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Disciplines are viewable by everyone"
  ON public.disciplines FOR SELECT
  USING (is_active = TRUE);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX idx_eps_organizations_code ON public.eps_organizations(code);
CREATE INDEX idx_eps_organizations_active ON public.eps_organizations(is_active);
CREATE INDEX idx_italian_regions_region ON public.italian_regions(region_code);
CREATE INDEX idx_italian_regions_province ON public.italian_regions(province_code);
CREATE INDEX idx_disciplines_code ON public.disciplines(code);
CREATE INDEX idx_disciplines_category ON public.disciplines(category);
CREATE INDEX idx_disciplines_active ON public.disciplines(is_active);

-- =====================================================
-- COMMENTS (Documentation)
-- =====================================================

COMMENT ON TABLE public.eps_organizations IS 'Reference data: Italian EPS (Enti di Promozione Sportiva) organizations';
COMMENT ON TABLE public.italian_regions IS 'Reference data: Italian regions and provinces for location filtering';
COMMENT ON TABLE public.disciplines IS 'Reference data: Historical fencing disciplines/weapons for categorization';

COMMENT ON COLUMN public.disciplines.category IS 'Discipline category: sword, dagger, polearm, grappling, specialized, mixed, other';
COMMENT ON COLUMN public.disciplines.display_order IS 'Display order in dropdowns/filters (lower = first)';
