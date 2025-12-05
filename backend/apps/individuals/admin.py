from django.contrib import admin
from .models import Individual


@admin.register(Individual)
class IndividualAdmin(admin.ModelAdmin):
    list_display = ['id', 'full_name', 'email', 'phone', 'created_at']
    list_filter = ['created_at']
    search_fields = ['user__email', 'user__first_name', 'user__last_name', 'user__phone']
    readonly_fields = ['id', 'created_at', 'updated_at']
    
    fieldsets = (
        ('Utilisateur', {
            'fields': ('user',)
        }),
        ('Informations', {
            'fields': ('address',)
        }),
        ('Métadonnées', {
            'fields': ('id', 'created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
