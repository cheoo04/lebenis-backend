# Configuration SendGrid pour Render

## Étape 1 : Créer un compte SendGrid
1. Allez sur https://sendgrid.com/
2. Créez un compte gratuit (100 emails/jour)
3. Vérifiez votre email

## Étape 2 : Obtenir une clé API SendGrid
1. Connectez-vous à SendGrid
2. Allez dans **Settings** > **API Keys**
3. Cliquez sur **Create API Key**
4. Nom : `lebenis-backend`
5. Permission : **Full Access**
6. Copiez la clé (elle ne sera affichée qu'une seule fois)

## Étape 3 : Vérifier votre domaine d'envoi
1. Dans SendGrid, allez dans **Settings** > **Sender Authentication**
2. Cliquez sur **Verify a Single Sender**
3. Remplissez avec l'email : `yah.kouakou24@inphb.ci`
4. Vérifiez l'email reçu

## Étape 4 : Configurer les variables d'environnement sur Render

Dans votre service Render :
1. Allez dans **Dashboard** > **lebenis-backend** > **Environment**
2. Ajoutez ces variables :

```bash
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
EMAIL_HOST=smtp.sendgrid.net
EMAIL_PORT=587
EMAIL_HOST_USER=apikey
DEFAULT_FROM_EMAIL=yah.kouakou24@inphb.ci
SERVER_EMAIL=yah.kouakou24@inphb.ci
```

3. Cliquez sur **Save Changes**
4. Render va redéployer automatiquement

## Étape 5 : Tester l'envoi d'email

Après le déploiement, testez en créant une livraison dans l'admin Django.
Vous devriez voir dans les logs :
```
✅ Email de confirmation envoyé pour la livraison TRACK-XXXX
```

## Alternative : Gmail SMTP (moins fiable)

Si vous n'avez pas SendGrid, utilisez Gmail temporairement :

```bash
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=votre-email@gmail.com
EMAIL_HOST_PASSWORD=votre-mot-de-passe-application
DEFAULT_FROM_EMAIL=votre-email@gmail.com
```

**Note :** Pour Gmail, activez "Mots de passe d'application" dans les paramètres de sécurité Google.

## Dépannage

### Erreur "Connection timed out"
- Vérifiez que `EMAIL_PORT=587` (pas 465)
- Vérifiez que `EMAIL_USE_TLS=True`
- Vérifiez que Render autorise les connexions SMTP sortantes

### Erreur "Authentication failed"
- Vérifiez que `SENDGRID_API_KEY` est correctement configurée
- Vérifiez que `EMAIL_HOST_USER=apikey` (littéralement "apikey")
- Régénérez une nouvelle clé API si nécessaire

### Emails non reçus
- Vérifiez les spams
- Vérifiez que l'email expéditeur est vérifié dans SendGrid
- Vérifiez les logs Render pour voir les erreurs

## ⚠️ IMPORTANT : Render Free Tier et SMTP

**Depuis septembre 2025, Render bloque les ports SMTP (25, 465, 587) sur le plan gratuit.**

### Solution 1 : Utiliser l'API SendGrid (HTTP - non bloquée) ✅

Au lieu de SMTP, utilisez l'API HTTP SendGrid :

```bash
pip install sendgrid
```

Puis dans `settings/base.py` :
```python
# Remplacer le backend SMTP par l'API SendGrid
EMAIL_BACKEND = 'sendgrid_backend.SendgridBackend'
SENDGRID_API_KEY = os.getenv('SENDGRID_API_KEY', '')
```

### Solution 2 : Passer au plan payant Render ($7/mois)

Les ports SMTP sont disponibles sur tous les plans payants.

### Solution 3 : Mode console (développement/démo)

Si aucune clé API n'est configurée, les emails seront affichés dans les logs :
```python
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
```

## 📱 SMS non affecté

Les SMS (Twilio, Infobip, etc.) utilisent des APIs HTTP et ne sont **pas affectés** par cette restriction.
