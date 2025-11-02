# notifications/admin.py
from django.contrib import admin
from .models import Notification, DeviceToken


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'notification_type', 'title', 'is_read', 'sent_at')
    list_filter = ('notification_type', 'is_read', 'sent_at')
    search_fields = ('title', 'message', 'user__email')
    readonly_fields = ('sent_at', 'read_at')
    date_hierarchy = 'sent_at'


@admin.register(DeviceToken)
class DeviceTokenAdmin(admin.ModelAdmin):
    list_display = ('user', 'platform', 'device_name', 'is_active', 'created_at', 'last_used_at')
    list_filter = ('platform', 'is_active', 'created_at')
    search_fields = ('user__email', 'user__first_name', 'user__last_name', 'device_name', 'token')
    readonly_fields = ('created_at', 'last_used_at')
    date_hierarchy = 'created_at'
    
    actions = ['activate_tokens', 'deactivate_tokens']
    
    def activate_tokens(self, request, queryset):
        updated = queryset.update(is_active=True)
        self.message_user(request, f"{updated} token(s) activé(s)")
    activate_tokens.short_description = "Activer les tokens sélectionnés"
    
    def deactivate_tokens(self, request, queryset):
        updated = queryset.update(is_active=False)
        self.message_user(request, f"{updated} token(s) désactivé(s)")
    deactivate_tokens.short_description = "Désactiver les tokens sélectionnés"

