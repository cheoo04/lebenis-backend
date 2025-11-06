"""
URLs pour upload Cloudinary
"""
from django.urls import path
from .views import CloudinaryUploadView, CloudinaryDeleteView

app_name = 'core'

urlpatterns = [
    path('upload/', CloudinaryUploadView.as_view(), name='cloudinary-upload'),
    path('delete/', CloudinaryDeleteView.as_view(), name='cloudinary-delete'),
]
