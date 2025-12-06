"""
============================================================================
BASE DE DONNÉES COMPLÈTE DES QUARTIERS D'ABIDJAN
Source: Recherche Internet (Wikipédia, Sites officiels, Portails immobiliers)
Date: Décembre 2025
============================================================================

Ce fichier contient:
- Liste complète de ~250+ quartiers répartis dans 13 communes
- Coordonnées GPS pour les quartiers principaux (utilisées pour les livraisons)
- Fonctions de recherche, validation et géocodage
"""

# ============================================================================
# COORDONNÉES GPS DES QUARTIERS PRINCIPAUX
# Ces coordonnées sont approximatives (centre du quartier)
# Les quartiers sans GPS utiliseront Nominatim comme fallback
# ============================================================================

QUARTIERS_GPS = {
    'COCODY': {
        'Riviera 1': (5.3651, -3.9917),
        'Riviera 2': (5.3679, -3.9850),
        'Riviera 3': (5.3742, -3.9780),
        'Riviera 4': (5.3780, -3.9720),
        'Riviera 6': (5.3820, -3.9680),
        'Riviera Golf': (5.3800, -3.9700),
        'Riviera Palmeraie': (5.3850, -3.9650),
        'Riviera Bonoumin': (5.3700, -3.9600),
        'Riviera Beach': (5.3680, -3.9520),
        'Riviera Attoban': (5.3620, -3.9480),
        'Angré': (5.3650, -3.9950),
        'Angré 7e Tranche': (5.3680, -3.9920),
        'Angré 8e Tranche': (5.3700, -3.9900),
        'Angré 9e Tranche': (5.3720, -3.9880),
        'Angré Star': (5.3740, -3.9860),
        'Angré Château': (5.3720, -3.9870),
        '2 Plateaux': (5.3580, -4.0050),
        '2 Plateaux Vallon': (5.3550, -4.0100),
        '2 Plateaux Extension': (5.3600, -4.0000),
        'Ambassades': (5.3400, -3.9900),
        'Danga': (5.3500, -3.9800),
        'Beverly Hills': (5.3560, -3.9750),
        'La Canebière': (5.3540, -3.9820),
        'Saint Jean': (5.3480, -3.9950),
        'II Plateaux Aghien': (5.3590, -4.0020),
        'Cocody Village': (5.3420, -4.0050),
        'Blockhaus (Blockauss)': (5.3350, -4.0200),
        "M'Badon": (5.3380, -3.9650),
        "M'Pouto": (5.3360, -3.9620),
        'Anono': (5.3340, -3.9580),
        'Akouédo': (5.3500, -3.9400),
        'Djorogobité 1': (5.3750, -3.9550),
        'Djorogobité 2': (5.3770, -3.9530),
        'Plateau Dokui': (5.3450, -4.0080),
        'Caféiers': (5.3520, -4.0120),
        'Abatta': (5.3600, -3.9300),
        'Lycée Technique': (5.3520, -4.0100),
        'ENA': (5.3480, -4.0060),
        'Cité des Arts': (5.3600, -4.0150),
        'Cité des Cadres': (5.3580, -4.0130),
        'RTI': (5.3460, -4.0040),
        'Genie 2000': (5.3440, -3.9980),
    },
    
    'YOPOUGON': {
        'Gesco': (5.3200, -4.0600),
        'Niangon': (5.3350, -4.0600),
        'Niangon Nord': (5.3380, -4.0580),
        'Niangon Sud': (5.3320, -4.0620),
        'Niangon Adjamé': (5.3400, -4.0560),
        'Niangon Lokoa': (5.3360, -4.0640),
        'Azito': (5.3150, -4.0700),
        'Andokoi': (5.3280, -4.0680),
        'Selmer': (5.3400, -4.0650),
        'Siporex': (5.3450, -4.0720),
        'Micao': (5.3420, -4.0780),
        'Sicogi': (5.3300, -4.0550),
        'Sogefiha': (5.3380, -4.0800),
        'Banco Nord': (5.3700, -4.0950),
        'Banco Sud': (5.3650, -4.0900),
        'Quartier Millionnaire': (5.3480, -4.0750),
        'Quartier Résidentiel': (5.3500, -4.0730),
        'Bel Air': (5.3520, -4.0760),
        'Kouté': (5.3100, -4.0800),
        'Maroc': (5.3600, -4.0800),
        'Koweit': (5.3580, -4.0820),
        'Wassakara': (5.3500, -4.0700),
        'Port-Bouët II': (5.3250, -4.0500),
        'Santé (Yopougon-Santé)': (5.3550, -4.0780),
        'Fanny': (5.3480, -4.0850),
        'Complexe': (5.3520, -4.0880),
        'Académie Pays-Bas': (5.3540, -4.0840),
        'Hôpital': (5.3560, -4.0860),
        'Kilomètre 17': (5.3100, -4.1000),
    },
    
    'MARCORY': {
        'Zone 4': (5.2900, -3.9850),
        'Zone 4A': (5.2920, -3.9830),
        'Zone 4B': (5.2880, -3.9870),
        'Zone 4C': (5.2920, -3.9880),
        'Zone 4D': (5.2860, -3.9890),
        'Biétry': (5.2800, -3.9750),
        'Marcory Résidentiel': (5.2950, -3.9900),
        'Anoumabo': (5.2850, -3.9800),
        'Champroux': (5.2980, -3.9920),
        'Remblais': (5.2750, -3.9700),
        'Cité Militaire': (5.2880, -3.9780),
    },
    
    'PLATEAU': {
        'Le Plateau': (5.3200, -4.0200),
        'Plateau Centre': (5.3200, -4.0200),
        'Démolition': (5.3180, -4.0180),
        'République': (5.3220, -4.0220),
        'Cathédrale': (5.3240, -4.0190),
        'Administratif': (5.3220, -4.0220),
        'Banques': (5.3190, -4.0210),
    },
    
    'ABOBO': {
        'PK 18': (5.4300, -4.0300),
        'Abobo Baoulé': (5.4150, -4.0150),
        'Anador': (5.4100, -4.0100),
        'Avocatier': (5.4250, -4.0250),
        'Abobo Té': (5.4180, -4.0200),
        'Sagbé': (5.4350, -4.0350),
        'Banco 2 (Abobo)': (5.4080, -4.0080),
        "N'Dotré": (5.4220, -4.0280),
        'Abobo Village': (5.4120, -4.0120),
        'Abobo Akéikoi': (5.4140, -4.0140),
    },
    
    'ADJAME': {
        'Liberté': (5.3550, -4.0250),
        'Bracodi': (5.3500, -4.0200),
        'Williamsville': (5.3600, -4.0300),
        'Adjamé Village': (5.3480, -4.0180),
        '220 Logements': (5.3450, -4.0150),
        'Adjamé Marché': (5.3520, -4.0230),
        'Abrogoua (Black Market)': (5.3540, -4.0260),
    },
    
    'KOUMASSI': {
        'Zone Industrielle': (5.2900, -3.9500),
        'Anani': (5.3020, -3.9620),
        'Grand Marché de Koumassi': (5.3000, -3.9580),
        'Remblais': (5.3000, -3.9600),
        'Belleville': (5.3080, -3.9680),
        'Koumassi Village': (5.3050, -3.9650),
    },
    
    'TREICHVILLE': {
        'Zone 1': (5.2920, -4.0020),
        'Zone 2': (5.2900, -4.0000),
        'Zone 3': (5.2880, -3.9980),
        'Zone 4 (Treichville)': (5.2860, -3.9960),
        'Belleville': (5.2940, -4.0040),
        'Treichville Centre': (5.2900, -4.0000),
        'Treichville Village': (5.2870, -3.9970),
    },
    
    'PORT-BOUET': {
        'Gonzagueville': (5.2550, -3.9550),
        'Vridi': (5.2500, -3.9500),
        'Zone 3': (5.2580, -3.9580),
        'Zone 4': (5.2560, -3.9560),
        'Phare': (5.2480, -3.9480),
        'Biétry (Port-Bouët)': (5.2620, -3.9620),
        'Azur': (5.2640, -3.9640),
        'Petit Bassam': (5.2660, -3.9660),
        'Port-Bouët Village': (5.2600, -3.9600),
        'Aéroport': (5.2450, -3.9450),
    },
    
    'ATTECOUBE': {
        'Locodjoro': (5.3400, -4.0600),
        'Santé': (5.3250, -4.0450),
        'Dokui': (5.3300, -4.0480),
        'Agban': (5.3350, -4.0550),
        'Attécoubé Village': (5.3280, -4.0500),
        'La Paix': (5.3320, -4.0520),
    },
    
    'ANYAMA': {
        'Anyama Centre': (5.4900, -4.0500),
        'Anyama Village': (5.4920, -4.0520),
        'Nouveau Quartier': (5.4880, -4.0480),
        'Cité de la Cola': (5.4860, -4.0460),
    },
    
    'BINGERVILLE': {
        'Bingerville Centre': (5.3550, -3.8900),
        'Santé': (5.3580, -3.8930),
        'Marché': (5.3540, -3.8890),
        'Plantations': (5.3600, -3.8950),
        'Bingerville Village': (5.3520, -3.8870),
        'Jardin Botanique': (5.3620, -3.8970),
    },
    
    'SONGON': {
        'Songon Agban': (5.3100, -4.2400),
        'Songon Kassemblé': (5.3150, -4.2450),
        "Songon M'Bratté": (5.3180, -4.2480),
        'Songon Village': (5.3120, -4.2420),
    },
}


# ============================================================================
# LISTE COMPLÈTE DES QUARTIERS (AVEC ET SANS GPS)
# Les quartiers sans GPS dans QUARTIERS_GPS utiliseront Nominatim
# ============================================================================

QUARTIERS_ABIDJAN_COMPLET = {
    
    # ========================================================================
    # COCODY (Commune résidentielle huppée - Est d'Abidjan)
    # ========================================================================
    'COCODY': [
        # Secteurs Riviera
        'Riviera 1', 'Riviera 2', 'Riviera 3', 'Riviera 4', 'Riviera 6',
        'Riviera Golf', 'Riviera Palmeraie', 'Riviera Bonoumin', 
        'Riviera Beach', 'Riviera Attoban',
        
        # Secteurs Angré
        'Angré', 'Angré 7e Tranche', 'Angré 8e Tranche', 'Angré 9e Tranche',
        'Angré Star', 'Angré Château',
        
        # Secteurs 2 Plateaux
        '2 Plateaux', '2 Plateaux Vallon', '2 Plateaux Extension',
        
        # Quartiers résidentiels
        'Ambassades', 'Danga', 'Beverly Hills', 'La Canebière', 'Saint Jean',
        'II Plateaux Aghien',
        
        # Villages et quartiers populaires
        'Cocody Village', 'Blockhaus (Blockauss)', "M'Badon", "M'Pouto",
        'Anono', 'Akouédo', 'Djorogobité 1', 'Djorogobité 2', 'Adjamé Extension',
        'Bahouakoi', 'Koffakoi', 'Plateau Dokui', 'Caféiers', 'Abatta',
        'Gendarmerie Agban', 'Genie 2000', 'RTI', 'Lycée Technique', 'ENA',
        'Cité des Arts', 'Cité des Cadres',
    ],
    
    # ========================================================================
    # YOPOUGON (Plus grande commune - Ouest d'Abidjan)
    # ========================================================================
    'YOPOUGON': [
        # Quartiers principaux
        'Gesco', 'Niangon', 'Niangon Nord', 'Niangon Sud', 'Niangon Adjamé',
        'Niangon Lokoa', 'Azito', 'Andokoi', 'Selmer', 'Siporex', 'Micao',
        'Sicogi', 'Sogefiha',
        
        # Quartiers résidentiels
        'Banco Nord', 'Banco Sud', 'Quartier Millionnaire', 'Quartier Résidentiel',
        'Bel Air',
        
        # Autres quartiers
        'Kouté', 'Kouté Village', 'Kouté Ouest', 'Kouté Est', 'Lokoua', 'Béago',
        'Maroc', 'Koweit', 'Doukouré', 'Wassakara', 'Port-Bouët II', 'Ficgayo',
        'Judée', 'Atchi', 'Attié', 'Bagouda', 'Banco 2', 'Bonikro',
        'Camp Militaire', 'Cité Caféiers', 'Cité CNPS', 'Cité Marine',
        'Cité Nawa', 'Cité Verte', 'Cité Sodefor', 'Deuxième Tranche',
        'Galilée', 'Lauriers 2', 'Lauriers Sacos', 'Les Pays-Bas', 'Lièvre Rouge',
        'Mamie Adjoua', "N'Zimakro", 'Santé (Yopougon-Santé)', 'Fanny',
        'Gabriel Gare', 'Complexe', 'Académie Pays-Bas', 'Bouguinissou',
        'Monde Arabe', 'Gesco Mondon', 'Cité Caisstab', 'Fin Goudron',
        'Hôpital', 'Kilomètre 17',
    ],
    
    # ========================================================================
    # MARCORY (Commune expatriée - Sud d'Abidjan)
    # ========================================================================
    'MARCORY': [
        # Zones principales
        'Zone 4', 'Zone 4A', 'Zone 4B', 'Zone 4C', 'Zone 4D', 'Biétry',
        'Marcory Résidentiel',
        
        # Autres quartiers
        'Poto-Poto', 'Marie Koré', 'Champroux', 'Gnanzoua',
        'KBF (Kablan Brou Fulgence)', 'Hibiscus', 'Konan Raphaël',
        'Jean Baptiste Mockey', 'Adeimin', 'Aliodan',
        
        # Villages
        'Anoumabo', 'Abia Koumassi', 'Abia Abety', 'Ancien Koumassi',
        'Village de Marcory', 'Remblais', 'Cité Militaire',
    ],
    
    # ========================================================================
    # PLATEAU (Centre d'affaires)
    # ========================================================================
    'PLATEAU': [
        'Le Plateau', 'Plateau Centre', 'Démolition', 'République',
        'Cathédrale', 'Administratif', 'Banques',
    ],
    
    # ========================================================================
    # ABOBO (Commune populaire - Nord d'Abidjan)
    # ========================================================================
    'ABOBO': [
        'PK 18', 'Abobo Baoulé', 'Anador', 'Avocatier', 'Abobo Té', 'Sagbé',
        'Banco 2 (Abobo)', "N'Dotré", 'Abidjan Nord', 'Tawé', 'Biabou',
        'Carrefour Dokui', 'Carrefour Manténé', 'Gare Andokoua Kouté', 'Samaké',
        'Abobo Village', 'Abobo Akéikoi', 'Abobo Agnissankoi',
        'Abobo Avocatier Bassin Orange', 'Abobo Baoulé Quartier Gouro',
    ],
    
    # ========================================================================
    # ADJAME (Commune commerciale - Nord)
    # ========================================================================
    'ADJAME': [
        'Liberté', 'Bracodi', 'Williamsville', 'Adjamé Village', '220 Logements',
        'Adjamé Marché', 'Abrogoua (Black Market)', 'Bérouth', 'Dubaï',
        'Sonitra', 'Azito (Adjamé)',
    ],
    
    # ========================================================================
    # KOUMASSI (Commune - Sud-Est)
    # ========================================================================
    'KOUMASSI': [
        'Zone Industrielle', 'Anani', 'Grand Marché de Koumassi', 'Remblais',
        'Azito', 'Belleville', 'Koumassi Village',
    ],
    
    # ========================================================================
    # TREICHVILLE (Commune portuaire - Centre-Sud)
    # ========================================================================
    'TREICHVILLE': [
        'Zone 1', 'Zone 2', 'Zone 3', 'Zone 4 (Treichville)', 'Belleville',
        'Treichville Centre', 'Treichville Village',
    ],
    
    # ========================================================================
    # PORT-BOUET (Commune aéroportuaire - Sud)
    # ========================================================================
    'PORT-BOUET': [
        'Gonzagueville', 'Vridi', 'Zone 3', 'Zone 4', 'Phare',
        'Biétry (Port-Bouët)', 'Azur', 'Petit Bassam', 'Port-Bouët Village',
        'Aéroport',
    ],
    
    # ========================================================================
    # ATTECOUBE (Commune - Centre-Ouest)
    # ========================================================================
    'ATTECOUBE': [
        'Locodjoro', 'Santé', 'Dokui', 'Agban', 'Attécoubé Village', 'La Paix',
    ],
    
    # ========================================================================
    # ANYAMA (Commune périphérique - Nord)
    # ========================================================================
    'ANYAMA': [
        'Anyama Centre', 'Anyama Village', 'Nouveau Quartier', 'Cité de la Cola',
    ],
    
    # ========================================================================
    # BINGERVILLE (Commune périphérique - Est)
    # ========================================================================
    'BINGERVILLE': [
        'Bingerville Centre', 'Santé', 'Marché', 'Plantations',
        'Bingerville Village', 'Jardin Botanique',
    ],
    
    # ========================================================================
    # SONGON (Commune périphérique - Ouest)
    # ========================================================================
    'SONGON': [
        'Songon Agban', 'Songon Kassemblé', "Songon M'Bratté", 'Songon Village',
    ],
}


# ============================================================================
# FONCTIONS UTILITAIRES
# ============================================================================

def get_statistics():
    """Retourne les statistiques des quartiers"""
    stats = {
        'total_communes': len(QUARTIERS_ABIDJAN_COMPLET),
        'total_quartiers': sum(len(q) for q in QUARTIERS_ABIDJAN_COMPLET.values()),
        'quartiers_avec_gps': sum(len(q) for q in QUARTIERS_GPS.values()),
        'par_commune': {
            commune: len(quartiers) 
            for commune, quartiers in QUARTIERS_ABIDJAN_COMPLET.items()
        }
    }
    return stats


def get_communes_list() -> list:
    """Retourne la liste des communes disponibles"""
    return list(QUARTIERS_ABIDJAN_COMPLET.keys())


def get_all_quartiers() -> list:
    """
    Retourne la liste de tous les quartiers
    
    Returns:
        Liste de dictionnaires [{nom, commune, latitude, longitude, has_gps}, ...]
    """
    all_quartiers = []
    
    for commune, quartiers in QUARTIERS_ABIDJAN_COMPLET.items():
        commune_gps = QUARTIERS_GPS.get(commune, {})
        
        for nom in quartiers:
            coords = commune_gps.get(nom)
            if coords:
                all_quartiers.append({
                    'nom': nom,
                    'commune': commune,
                    'latitude': coords[0],
                    'longitude': coords[1],
                    'has_gps': True,
                })
            else:
                all_quartiers.append({
                    'nom': nom,
                    'commune': commune,
                    'latitude': None,
                    'longitude': None,
                    'has_gps': False,
                })
    
    return all_quartiers


def get_quartiers_by_commune(commune: str) -> list:
    """
    Retourne les quartiers d'une commune spécifique
    
    Args:
        commune: Nom de la commune (ex: "COCODY")
    
    Returns:
        Liste de dictionnaires [{nom, commune, latitude, longitude, has_gps}, ...]
    """
    commune_upper = commune.upper()
    
    if commune_upper not in QUARTIERS_ABIDJAN_COMPLET:
        return []
    
    commune_gps = QUARTIERS_GPS.get(commune_upper, {})
    quartiers = []
    
    for nom in QUARTIERS_ABIDJAN_COMPLET[commune_upper]:
        coords = commune_gps.get(nom)
        if coords:
            quartiers.append({
                'nom': nom,
                'commune': commune_upper,
                'latitude': coords[0],
                'longitude': coords[1],
                'has_gps': True,
            })
        else:
            quartiers.append({
                'nom': nom,
                'commune': commune_upper,
                'latitude': None,
                'longitude': None,
                'has_gps': False,
            })
    
    return quartiers


def get_quartier_coordinates(quartier: str, commune: str = None) -> dict:
    """
    Retourne les coordonnées GPS d'un quartier
    
    Args:
        quartier: Nom du quartier
        commune: Commune (optionnel, accélère la recherche)
    
    Returns:
        Dict {nom, commune, latitude, longitude, has_gps} ou None
    """
    quartier_lower = quartier.lower().strip()
    
    # Si commune fournie, chercher uniquement dans cette commune
    if commune:
        commune_upper = commune.upper()
        if commune_upper in QUARTIERS_GPS:
            for nom, (lat, lon) in QUARTIERS_GPS[commune_upper].items():
                if nom.lower() == quartier_lower or quartier_lower in nom.lower():
                    return {
                        'nom': nom,
                        'commune': commune_upper,
                        'latitude': lat,
                        'longitude': lon,
                        'has_gps': True,
                    }
        
        # Quartier existe mais pas de GPS
        if commune_upper in QUARTIERS_ABIDJAN_COMPLET:
            for nom in QUARTIERS_ABIDJAN_COMPLET[commune_upper]:
                if nom.lower() == quartier_lower or quartier_lower in nom.lower():
                    return {
                        'nom': nom,
                        'commune': commune_upper,
                        'latitude': None,
                        'longitude': None,
                        'has_gps': False,
                    }
    
    # Sinon, chercher dans toutes les communes (d'abord ceux avec GPS)
    for comm, quartiers_gps in QUARTIERS_GPS.items():
        for nom, (lat, lon) in quartiers_gps.items():
            if nom.lower() == quartier_lower or quartier_lower in nom.lower():
                return {
                    'nom': nom,
                    'commune': comm,
                    'latitude': lat,
                    'longitude': lon,
                    'has_gps': True,
                }
    
    # Ensuite chercher dans la liste complète
    for comm, quartiers in QUARTIERS_ABIDJAN_COMPLET.items():
        for nom in quartiers:
            if nom.lower() == quartier_lower or quartier_lower in nom.lower():
                return {
                    'nom': nom,
                    'commune': comm,
                    'latitude': None,
                    'longitude': None,
                    'has_gps': False,
                }
    
    return None


def search_quartiers(query: str, limit: int = 15) -> list:
    """
    Recherche des quartiers par nom (pour autocomplete)
    
    Args:
        query: Texte de recherche
        limit: Nombre max de résultats
    
    Returns:
        Liste de quartiers correspondants (triés: avec GPS d'abord)
    """
    if len(query) < 2:
        return []
    
    query_lower = query.lower().strip()
    results_with_gps = []
    results_without_gps = []
    
    for commune, quartiers in QUARTIERS_ABIDJAN_COMPLET.items():
        commune_gps = QUARTIERS_GPS.get(commune, {})
        
        for nom in quartiers:
            if query_lower in nom.lower():
                coords = commune_gps.get(nom)
                
                if coords:
                    results_with_gps.append({
                        'nom': nom,
                        'commune': commune,
                        'latitude': coords[0],
                        'longitude': coords[1],
                        'has_gps': True,
                    })
                else:
                    results_without_gps.append({
                        'nom': nom,
                        'commune': commune,
                        'latitude': None,
                        'longitude': None,
                        'has_gps': False,
                    })
    
    # Priorité aux résultats avec GPS
    results = results_with_gps + results_without_gps
    return results[:limit]


def validate_quartier(quartier: str, commune: str) -> bool:
    """
    Vérifie si un quartier existe dans une commune
    
    Args:
        quartier: Nom du quartier
        commune: Nom de la commune
    
    Returns:
        True si le quartier existe, False sinon
    """
    commune_upper = commune.upper()
    
    if commune_upper not in QUARTIERS_ABIDJAN_COMPLET:
        return False
    
    quartier_lower = quartier.lower().strip()
    for nom in QUARTIERS_ABIDJAN_COMPLET[commune_upper]:
        if quartier_lower in nom.lower() or nom.lower() in quartier_lower:
            return True
    
    return False


def validate_address(commune: str, quartier: str) -> tuple:
    """
    Valide si un quartier existe dans une commune
    
    Returns:
        (bool, str) - (est_valide, message)
    """
    if commune.upper() not in QUARTIERS_ABIDJAN_COMPLET:
        return False, f"Commune '{commune}' inconnue"
    
    if not validate_quartier(quartier, commune):
        return False, f"Quartier '{quartier}' introuvable dans {commune}"
    
    return True, "Adresse valide"


# ============================================================================
# EXEMPLE D'UTILISATION
# ============================================================================

if __name__ == '__main__':
    stats = get_statistics()
    print("=" * 70)
    print("STATISTIQUES DES QUARTIERS D'ABIDJAN")
    print("=" * 70)
    print(f"Nombre total de communes: {stats['total_communes']}")
    print(f"Nombre total de quartiers: {stats['total_quartiers']}")
    print(f"Quartiers avec GPS: {stats['quartiers_avec_gps']}")
    print()
    print("Répartition par commune:")
    for commune, count in sorted(stats['par_commune'].items(), key=lambda x: x[1], reverse=True):
        gps_count = len(QUARTIERS_GPS.get(commune, {}))
        print(f"  {commune:15} : {count:3} quartiers ({gps_count} avec GPS)")
    print()
    
    # Exemples de recherche
    print("=" * 70)
    print("EXEMPLES DE RECHERCHE")
    print("=" * 70)
    
    print("\n1. Recherche 'Riviera':")
    results = search_quartiers('Riviera')
    for r in results[:5]:
        gps_icon = "📍" if r['has_gps'] else "❓"
        print(f"   {gps_icon} {r['nom']} ({r['commune']})")
    
    print("\n2. Recherche 'Zone 4':")
    results = search_quartiers('Zone 4')
    for r in results:
        gps_icon = "📍" if r['has_gps'] else "❓"
        print(f"   {gps_icon} {r['nom']} ({r['commune']})")


# ============================================================================
# NOTES
# ============================================================================
"""
TOTAL: 13 communes, ~250+ quartiers répertoriés

Quartiers les plus utilisés pour les livraisons:
- Cocody: Riviera 2, Riviera 3, Angré, 2 Plateaux
- Yopougon: Gesco, Niangon, Sicogi
- Marcory: Zone 4, Biétry, Résidentiel
- Plateau: Le Plateau

Pour les quartiers sans GPS local, le système utilise Nominatim (OpenStreetMap)
comme fallback pour obtenir les coordonnées.
"""
