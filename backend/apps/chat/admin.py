from django.contrib import admin
from .models import ChatRoom, ChatMessage


@admin.register(ChatRoom)
class ChatRoomAdmin(admin.ModelAdmin):
    list_display = [
        'id', 'room_type', 'driver', 'other_user', 'delivery',
        'driver_unread_count', 'other_user_unread_count',
        'last_message_at', 'is_active', 'is_archived'
    ]
    list_filter = ['room_type', 'is_active', 'is_archived', 'created_at']
    search_fields = [
        'driver__full_name', 'driver__phone_number',
        'other_user__full_name', 'other_user__phone_number',
        'delivery__tracking_number', 'firebase_path'
    ]
    readonly_fields = [
        'id', 'firebase_path', 'created_at', 'updated_at',
        'last_message_text', 'last_message_at', 'last_message_sender_id'
    ]
    
    fieldsets = (
        ('Informations de base', {
            'fields': ('id', 'room_type', 'driver', 'other_user', 'delivery')
        }),
        ('Firebase', {
            'fields': ('firebase_path',)
        }),
        ('Dernier message', {
            'fields': ('last_message_text', 'last_message_at', 'last_message_sender_id')
        }),
        ('Compteurs non lus', {
            'fields': ('driver_unread_count', 'other_user_unread_count')
        }),
        ('Statut', {
            'fields': ('is_active', 'is_archived')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )
    
    def has_add_permission(self, request):
        # Désactiver l'ajout manuel depuis l'admin
        return False


@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = [
        'id', 'chat_room', 'sender', 'message_type',
        'text_preview', 'is_read', 'is_synced_to_firebase', 'created_at'
    ]
    list_filter = ['message_type', 'is_read', 'is_synced_to_firebase', 'created_at']
    search_fields = ['text', 'sender__full_name', 'chat_room__firebase_path']
    readonly_fields = ['id', 'created_at', 'updated_at', 'read_at']
    
    fieldsets = (
        ('Informations de base', {
            'fields': ('id', 'chat_room', 'sender', 'message_type')
        }),
        ('Contenu', {
            'fields': ('text', 'image_url', 'latitude', 'longitude')
        }),
        ('Statut', {
            'fields': ('is_read', 'read_at', 'is_synced_to_firebase')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )
    
    def text_preview(self, obj):
        """Affiche un aperçu du texte"""
        if obj.message_type == 'text':
            return obj.text[:50] + '...' if len(obj.text) > 50 else obj.text
        elif obj.message_type == 'image':
            return '📷 Image'
        elif obj.message_type == 'location':
            return f'📍 Location ({obj.latitude}, {obj.longitude})'
        else:
            return '💬 Système'
    
    text_preview.short_description = 'Aperçu'
    
    def has_add_permission(self, request):
        # Désactiver l'ajout manuel depuis l'admin
        return False
