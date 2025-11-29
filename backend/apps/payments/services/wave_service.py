import requests
from django.conf import settings

WAVE_API_URL = "https://api.wave.com/v1/checkout/sessions"
WAVE_API_KEY = getattr(settings, "WAVE_API_KEY", None)

class WaveAPIError(Exception):
    pass

def create_wave_payment_session(amount, currency, error_url, success_url):
    if not WAVE_API_KEY:
        raise WaveAPIError("WAVE_API_KEY is not configured in settings.")
    headers = {
        "Authorization": f"Bearer {WAVE_API_KEY}",
        "Content-Type": "application/json"
    }
    data = {
        "amount": str(amount),
        "currency": currency,
        "error_url": error_url,
        "success_url": success_url
    }
    response = requests.post(WAVE_API_URL, json=data, headers=headers, timeout=15)
    if response.status_code not in (200, 201):
        raise WaveAPIError(f"Wave API error: {response.status_code} {response.text}")
    return response.json()
