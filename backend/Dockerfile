FROM python:3.11-slim

WORKDIR /app

# Installer dépendances système
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copier requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code
COPY . .

# Variables d'environnement
ENV PYTHONUNBUFFERED=1

# Port
EXPOSE 8000

# Commande de démarrage
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
