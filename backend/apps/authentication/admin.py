# authentication/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User
from django.utils.translation import gettext_lazy as _

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        (_('Informations personnelles'), {'fields': ('first_name', 'last_name', 'phone')}),
        (_('Permissions'), {'fields': ('is_active', 'is_verified', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        (_('Type d\'Utilisateur'), {'fields': ('user_type',)}),
        (_('Dates importantes'), {'fields': ('last_login', 'created_at', 'updated_at')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'phone', 'first_name', 'last_name', 'user_type', 'password1', 'password2'),
        }),
    )
    list_display = ('email', 'full_name', 'user_type', 'phone', 'is_active', 'is_verified', 'is_staff')
    list_filter = ('user_type', 'is_staff', 'is_active', 'is_verified')
    search_fields = ('email', 'first_name', 'last_name', 'phone')
    ordering = ('email',)
    filter_horizontal = ('groups', 'user_permissions',)

    def full_name(self, obj):
        return f"{obj.first_name} {obj.last_name}"
    full_name.short_description = 'Nom complet'
