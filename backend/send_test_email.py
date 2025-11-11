#!/usr/bin/env python
"""
Script de test Cloudinary pour LeBeni's Backend
Teste l'upload d'images vers Cloudinary avec les credentials du projet
"""

import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.base')
django.setup()

import cloudinary
import cloudinary.uploader
from django.conf import settings


def test_cloudinary_config():
    """Teste la configuration Cloudinary"""
    print("=" * 80)
    print("TEST 1 : Configuration Cloudinary")
    print("=" * 80)
    
    try:
        cloud_name = settings.CLOUDINARY_STORAGE['CLOUD_NAME']
        api_key = settings.CLOUDINARY_STORAGE['API_KEY']
        api_secret = settings.CLOUDINARY_STORAGE['API_SECRET']
        
        print(f"✅ CLOUD_NAME: {cloud_name}")
        print(f"✅ API_KEY: {api_key[:10]}... (masqué)")
        print(f"✅ API_SECRET: {api_secret[:10]}... (masqué)")
        
        # Configuration
        cloudinary.config(
            cloud_name=cloud_name,
            api_key=api_key,
            api_secret=api_secret,
            secure=True
        )
        
        print("\n✅ Configuration Cloudinary réussie !\n")
        return True
    
    except Exception as e:
        print(f"\n❌ Erreur configuration: {e}\n")
        return False


def test_upload_from_url():
    """Teste l'upload depuis une URL internet"""
    print("=" * 80)
    print("TEST 2 : Upload depuis URL internet")
    print("=" * 80)
    
    # Image de test depuis Wikimedia
    test_image_url = "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Rotating_earth_%28large%29.gif/200px-Rotating_earth_%28large%29.gif"
    
    print(f"📥 Téléchargement depuis: {test_image_url}")
    print("🔄 Upload vers Cloudinary...")
    
    try:
        result = cloudinary.uploader.upload(
            test_image_url,
            folder="lebenis/profiles",
            public_id="test_upload_url",
            overwrite=True
        )
        
        secure_url = result.get('secure_url')
        public_id = result.get('public_id')
        format_type = result.get('format')
        width = result.get('width')
        height = result.get('height')
        
        print("\n✅ Upload réussi !")
        print(f"   📸 URL: {secure_url}")
        print(f"   🆔 Public ID: {public_id}")
        print(f"   📄 Format: {format_type}")
        print(f"   📐 Dimensions: {width}x{height}px")
        print(f"\n💡 Ouvre cette URL dans ton navigateur pour voir l'image:")
        print(f"   {secure_url}\n")
        
        return secure_url
    
    except Exception as e:
        print(f"\n❌ Erreur upload: {e}\n")
        return None


def test_upload_from_file(file_path=None):
    """Teste l'upload depuis un fichier local"""
    print("=" * 80)
    print("TEST 3 : Upload depuis fichier local")
    print("=" * 80)
    
    # Chemins possibles
    possible_paths = [
        file_path,
        "/home/cheoo/Images/test2.png",
        "/home/cheoo/Images/Captures d’écran/test.png",
        "test_image.jpg",
    ]
    
    # Chercher un fichier existant
    test_file = None
    for path in possible_paths:
        if path and os.path.exists(path):
            test_file = path
            break
    
    if not test_file:
        print("⚠️  Aucun fichier test trouvé. Spécifie un chemin:")
        print("    python test_cloudinary.py /chemin/vers/image.jpg")
        print("\n💡 Liste des fichiers dans le dossier courant:")
        try:
            files = [f for f in os.listdir('.') if f.endswith(('.jpg', '.jpeg', '.png', '.gif'))]
            if files:
                for f in files[:5]:
                    print(f"    - {f}")
            else:
                print("    Aucune image trouvée")
        except:
            pass
        return None
    
    print(f"📁 Fichier trouvé: {test_file}")
    print("🔄 Upload vers Cloudinary...")
    
    try:
        result = cloudinary.uploader.upload(
            test_file,
            folder="lebenis/profiles",
            public_id="test_upload_file",
            overwrite=True,
            transformation=[
                {'width': 512, 'height': 512, 'crop': 'fill'},
                {'quality': 'auto'},
            ]
        )
        
        secure_url = result.get('secure_url')
        
        print("\n✅ Upload réussi !")
        print(f"   📸 URL: {secure_url}")
        print(f"\n💡 Vérifie l'image uploadée:")
        print(f"   {secure_url}\n")
        
        return secure_url
    
    except Exception as e:
        print(f"\n❌ Erreur upload: {e}\n")
        return None


def test_delete_image(url):
    """Teste la suppression d'une image"""
    print("=" * 80)
    print("TEST 4 : Suppression d'image (optionnel)")
    print("=" * 80)
    
    if not url:
        print("⏭️  Aucune URL fournie, test ignoré\n")
        return
    
    print(f"🗑️  Tentative de suppression: {url}")
    
    try:
        # Extraire le public_id de l'URL
        parts = url.split('/')
        public_id_with_ext = '/'.join(parts[-2:])  # lebenis/profiles/test_upload.gif
        public_id = os.path.splitext(public_id_with_ext)[0]
        
        result = cloudinary.uploader.destroy(public_id)
        
        if result.get('result') == 'ok':
            print(f"✅ Image supprimée avec succès\n")
        else:
            print(f"⚠️  Résultat: {result.get('result')}\n")
    
    except Exception as e:
        print(f"❌ Erreur suppression: {e}\n")


def main():
    """Fonction principale"""
    print("\n" + "=" * 80)
    print("🧪 TEST CLOUDINARY - LEBENI'S BACKEND")
    print("=" * 80 + "\n")
    
    # Test 1 : Configuration
    if not test_cloudinary_config():
        print("❌ Arrêt des tests : configuration invalide")
        sys.exit(1)
    
    # Test 2 : Upload depuis URL
    url = test_upload_from_url()
    
    # Test 3 : Upload depuis fichier local
    file_path = sys.argv[1] if len(sys.argv) > 1 else None
    test_upload_from_file(file_path)
    
    # Test 4 : Suppression (optionnel)
    # test_delete_image(url)
    
    print("=" * 80)
    print("✅ TESTS TERMINÉS")
    print("=" * 80)
    print("\n💡 Si tous les tests ont réussi, ton CloudinaryService fonctionne !")
    print("   Le problème vient donc de l'envoi du fichier depuis Flutter.\n")


if __name__ == '__main__':
    main()
