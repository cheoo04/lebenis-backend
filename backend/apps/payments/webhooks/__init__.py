# apps/payments/webhooks/__init__.py

from .orange_webhook import orange_money_webhook
from .mtn_webhook import mtn_momo_webhook

__all__ = ['orange_money_webhook', 'mtn_momo_webhook']
