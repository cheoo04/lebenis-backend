from rest_framework import serializers

class AssignZonesSerializer(serializers.Serializer):
    zone_ids = serializers.ListField(
        child=serializers.UUIDField(),
        allow_empty=False,
        help_text="Liste des IDs de zones à assigner au livreur."
    )
