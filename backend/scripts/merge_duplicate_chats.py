#!/usr/bin/env python
"""
Script pour fusionner les conversations dupliquées entre les mêmes utilisateurs.
Garde la conversation la plus ancienne et déplace tous les messages des autres.

Usage:
    python manage.py shell < scripts/merge_duplicate_chats.py
    
Ou dans le shell Django:
    exec(open('scripts/merge_duplicate_chats.py').read())
"""

import os
import sys
import django

# Setup Django si pas déjà fait
if 'django' not in sys.modules or not hasattr(django, 'apps'):
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.production')
    django.setup()

from django.db.models import Count, Min
from apps.chat.models import ChatRoom, ChatMessage

def merge_duplicate_conversations():
    """Fusionne les conversations dupliquées entre les mêmes paires d'utilisateurs."""
    
    print("🔍 Recherche des conversations dupliquées...")
    
    # Trouver les paires (driver, other_user) avec plusieurs conversations
    duplicates = ChatRoom.objects.values('driver', 'other_user').annotate(
        count=Count('id'),
        oldest_id=Min('id')
    ).filter(count__gt=1)
    
    total_merged = 0
    total_messages_moved = 0
    
    for dup in duplicates:
        driver_id = dup['driver']
        other_user_id = dup['other_user']
        oldest_room_id = dup['oldest_id']
        
        # Récupérer toutes les conversations de cette paire
        rooms = ChatRoom.objects.filter(
            driver_id=driver_id,
            other_user_id=other_user_id
        ).order_by('created_at')
        
        # La première est la conversation principale (la plus ancienne)
        main_room = rooms.first()
        duplicate_rooms = rooms.exclude(id=main_room.id)
        
        print(f"\n📦 Paire: Driver {driver_id} <-> User {other_user_id}")
        print(f"   Conversation principale: {main_room.id}")
        print(f"   Conversations à fusionner: {duplicate_rooms.count()}")
        
        for dup_room in duplicate_rooms:
            # Déplacer les messages vers la conversation principale
            messages_count = ChatMessage.objects.filter(chat_room=dup_room).update(
                chat_room=main_room
            )
            total_messages_moved += messages_count
            print(f"   ✓ {messages_count} messages déplacés de {dup_room.id}")
            
            # Supprimer la conversation dupliquée
            dup_room.delete()
            total_merged += 1
    
    print(f"\n✅ Fusion terminée!")
    print(f"   Conversations fusionnées: {total_merged}")
    print(f"   Messages déplacés: {total_messages_moved}")
    
    return total_merged, total_messages_moved


if __name__ == '__main__':
    merge_duplicate_conversations()
else:
    # Exécuté depuis le shell Django
    merge_duplicate_conversations()
