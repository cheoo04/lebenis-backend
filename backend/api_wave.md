Publié à l'aide de Google Docs
Signaler un abus En savoir plus
Premiers pas avec l'API Wave Checkout

Premiers pas avec l'
API Wave Checkout

Dernière mise à jour : 27/12/2022

Ce document accompagne la documentation de référence de l'API Wave .

À quoi sert l'API Checkout ?
L'API Wave Checkout permet de gérer les transactions en ligne. Les entreprises disposant d'une boutique en ligne, que ce soit sur le web ou via une application mobile, peuvent intégrer cette API pour permettre à leurs clients de régler leurs achats grâce à l'application Wave sur leur téléphone.

Ce que l'API Checkout ne gère pas
Les fonctions suivantes ne sont pas gérées par l'API Checkout, mais seront prises en charge par différentes API Wave, dont certaines sont encore en développement :

Envoyer des paiements de votre entreprise à vos clients, employés ou fournisseurs ( API de paiement )
Être notifié des transactions effectuées sur votre portefeuille Wave Business, par exemple les paiements via l'application Wave et les paiements en personne avec lecture de QR code (abonnements aux événements Webhook).
Flux de l'API Checkout

Exemple : finaliser un achat sur un site web depuis un appareil mobile équipé de l’application Wave, ou via un ordinateur.
Imaginons qu'un client fasse ses courses sur un site web appelé FoodShop.

Le client ajoute les articles qu'il souhaite acheter à son panier, puis sélectionne « Payer ».
La page de paiement du site web FoodShop propose plusieurs modes de paiement, dont « Payer avec Wave ».
Le client appuie sur un bouton « Payer avec Wave » sur le site web de FoodShop
Le site web FoodShop envoie l'action au serveur FoodShop.
Le serveur FoodShop collecte les informations relatives à la « session de paiement » :
Montant et devise de l'achat ( champs montant et devise )
un identifiant permettant d'identifier l'achat dans la base de données FoodShop ( champ client_reference )
URL que l'application Wave doit charger lorsque le paiement a réussi ou échoué ( champs success_url et error_url )
Le serveur FoodShop envoie ces informations via une requête POST au point de terminaison /v1/checkout/sessions du serveur d'API Wave.
Le serveur FoodShop reçoit en retour un objet JSON de session de paiement contenant les détails qu'il a envoyés ainsi que des informations supplémentaires, notamment les suivantes :
URL permettant de lancer l'application Wave ( champ wave_launch_url )
un identifiant permettant de faire référence à cette session de paiement dans les requêtes ultérieures ( champ id )
Le serveur FoodShop stocke ces informations dans sa base de données et transmet l'URL de lancement Wave à son interface web.
Le site web FoodShop redirige vers l'URL de lancement de Wave :
Appareil mobile avec l'application Wave installée : la redirection ouvrira directement l'application Wave pour finaliser le paiement.
Appareil mobile sans l'application Wave installée : la redirection ouvrira une page web où le client sera invité à télécharger l'application Wave pour finaliser le paiement.
Appareil de bureau : La redirection ouvrira une page web affichant un code QR. En scannant ce code QR avec l’application Wave, le client pourra effectuer le paiement.
Une fois dans l'application Wave, sur le téléphone du client, un écran de confirmation affichera le nom de l'entreprise « FoodShop », le montant à payer et un bouton « Confirmer ».
Le client appuie sur le bouton « Confirmer » dans l’application Wave
L'application Wave demande au serveur Wave d'effectuer la transaction.
Le serveur Wave tente d'appeler le webhook sur le serveur FoodShop avec un événement checkout.session.completed (FoodShop a préalablement enregistré ce point de terminaison webhook auprès de Wave).
Le serveur Wave confirme à l'application Wave que le paiement a réussi.
L'application Wave ouvre l' URL de réussite fournie par FoodShop dans le navigateur Web du téléphone du client.
Le site web FoodShop détermine la transaction en cours effectuée par le client à partir d'une combinaison d'informations contenues dans l' URL de succès et dans l'état des cookies/sessions.
Le site web FoodShop consulte le serveur FoodShop pour vérifier si le paiement a réussi.
Si le serveur FoodShop a reçu un événement checkout.session.completed avec un identifiant correspondant et un statut de paiement « réussi » au moment où cela se produit, il peut utiliser ces informations.
Sinon, il peut envoyer une requête GET au point de terminaison /v1/checkout/session/:id du serveur Wave pour savoir si le paiement de la session de paiement a réussi , en utilisant l' identifiant reçu lors de la requête initiale.
Le site web de FoodShop affiche un message de confirmation au client.
Exemple de parcours client sur un site web de bureau
Étape 1 : Le client sélectionne les articles qu'il souhaite acheter sur le site web et appuie sur « Commencer la commande ».

Étape 2 : Le site Web redirige vers l’URL de lancement Wave renvoyée par l’API Wave, affichant un code QR pour finaliser le processus de paiement.

Étape 3 : Le client scanne le code QR avec l’application Wave et un écran de confirmation affichant le nom du magasin et le montant apparaît.

Étape 4 : Après confirmation, le client est redirigé vers l’« url_de_réussite » configurée dans la session de paiement, et la transaction apparaît dans l’historique de l’application Wave.

Mise en œuvre de l'API Wave Checkout
Voici la liste des modifications que vous devrez apporter à vos systèmes pour adopter l'API Wave Checkout.

☐ Créez une nouvelle option de paiement dans votre flux d'interface utilisateur de paiement
☐ Créez un système permettant de stocker les informations de session de paiement dans votre base de données.
Vous devrez conserver les valeurs d'identification des sessions de paiement associées à chaque client et/ou opération de paiement, ainsi que probablement la dernière valeur de statut reçue pour chacune.

☐ Créez un point de terminaison sur votre serveur que le serveur de Wave pourra appeler avec des événements webhook
☐ Créez des URL de succès et d'erreur vers lesquelles l'application Wave pourra rediriger après l'affichage d'une boîte de dialogue de demande de paiement.
Une fois que l'invite de paiement s'affiche dans l'application Wave et que le client a fait son choix, l'application Wave ouvre le navigateur Web mobile sur son téléphone et le redirige vers l' URL de succès (si le paiement a réussi) ou vers l' URL d'erreur (si le paiement a échoué ou si la transaction a expiré avant qu'un paiement réussi ne soit effectué).

Pour éviter toute fraude, lorsque votre site Web affiche l' URL de succès ou d'erreur, vous devez vérifier le statut de paiement de la session de paiement associée sur le serveur de Wave (soit via un événement webhook, soit en récupérant la session de paiement) afin d'être certain de son statut.

Recherche
Référence API
URL de base
Authentification
limitation de débit
Demandes
Réponses
Erreurs
Journal des modifications
2024-03-29
17 octobre 2022
10 mai 2022
29/03/2022
2022-03-23
Référence API
Les API Wave Business offrent un moyen de gérer votre compte Wave Business par programmation. Grâce à ces API REST, vous pouvez recevoir des paiements, envoyer de l'argent à vos clients, consulter le solde de votre portefeuille et effectuer un rapprochement bancaire automatisé.

Pour utiliser ces API, vous avez besoin d'un Wave Business Account.

API de balance et de rapprochement
API de paiement
API de paiement
API des marchands agrégés
Webhooks
URL de base
Tous les chemins d'accès aux points de terminaison référencés dans la documentation de l'API sont relatifs à une URL de base, https://api.wave.com .

Authentification
L'authentification à l'API s'effectue via des clés API. Ces clés sont liées à un seul portefeuille d'entreprise et ne peuvent interagir qu'avec celui-ci.

Si vous devez interagir avec plusieurs portefeuilles sur votre réseau, vous devrez obtenir une clé par portefeuille.

Les clés API permettent d'effectuer n'importe quelle requête API, y compris celles qui impliquent des transferts d'argent et l'accès à des informations sensibles. Il est donc impératif de les garder secrètes. Votre clé ne doit être ni partagée, ni stockée ailleurs que sur vos propres serveurs, ni utilisée dans le code côté client.

Chaque requête doit être envoyée via HTTPS et contenir un en-tête d'autorisation spécifiant le schéma de support avec la clé API :

Authorization: Bearer wave_sn_prod_YhUNb9d...i4bA6
Notez que la clé réelle est beaucoup plus longue, mais à des fins de documentation, la plupart des caractères ont été remplacés par des points de suspension.

Obtention de votre clé API
Vous pouvez gérer les clés API dans la section développeur du portail Wave Business . Vous pouvez créer, consulter et révoquer des clés, et définir les API spécifiques auxquelles chaque clé donne accès.

Portail développeur

Lorsque vous créez une nouvelle clé API, vous ne verrez la clé complète qu'une seule fois. Veillez à la copier sans omettre aucun caractère, car elle sera masquée par la suite pour des raisons de sécurité.

Créer une clé API

Wave ne connaît pas votre clé complète, mais si vous contactez le support API, nous pouvons l'identifier grâce aux 4 dernières lettres affichées sur le portail d'entreprise.

Seuls les administrateurs peuvent accéder à la section Développeur du portail d'entreprise. Si vous êtes administrateur et que vous ne la voyez toujours pas, contactez l'assistance API pour l'activer.
Codes d'erreur
Lors de la phase d'authentification, l'une des erreurs suivantes peut entraîner le retour prématuré de votre requête :

Statut Code Descriptions
401 missing-auth-header Votre requête doit inclure un en-tête d'authentification HTTP.
401 invalid-auth Votre en-tête d'authentification HTTP ne peut pas être traité.
401 api-key-not-provided Votre requête doit inclure une clé API.
401 no-matching-api-key La clé que vous avez fournie n'existe pas dans notre système.
401 api-key-revoked Votre clé API a été révoquée.
403 invalid-wallet Votre portefeuille ne peut pas être utilisé avec cette API.
403 disabled-wallet Votre portefeuille a été temporairement désactivé. Vous pouvez toujours utiliser ce point de terminaison pour consulter votre solde.
limitation de débit
Les API Wave sont soumises à une limitation de débit afin d'éviter les abus susceptibles de dégrader les performances pour tous les utilisateurs. Si vous envoyez de nombreuses requêtes en peu de temps, vous risquez de recevoir des réponses d'erreur 429.

Demandes
Voici un exemple de la façon dont vous pouvez construire une requête POST avec Authorizationdes Content-Typeen-têtes et des données JSON :

curl \
-X POST \
-H 'Authorization: Bearer wave_sn_prod_YhUNb9d...i4bA6' \
-H 'Content-Type: application/json' \
-d '{
"amount": "1000",
"currency": "XOF",
"error_url": "https://example.com/error",
"success_url": "https://example.com/success"
}' \
https://api.wave.com/v1/checkout/sessions
coquille
PHP
JavaScript
Java
Les requêtes API Wave utilisent l'authentification HTTP Bearer et, pour celles comportant un corps, le format JSON et l'encodage UTF-8. Toutes les requêtes doivent être envoyées via HTTPS.

Méthodes
Les requêtes de l'API Wave utilisent les méthodes HTTP GETou .POST

Cette GETméthode permet de récupérer des ressources. GETLes requêtes sont idempotentes et ne modifient aucune donnée sur le serveur.

Cette POSTméthode est utilisée pour créer de nouvelles ressources.

En-têtes
Pour l'authentification, l' Authorizationen-tête doit être inclus dans la requête. Sa valeur se compose du schéma d'authentification, Bearersuivi de la clé API :

Authorization: Bearer <API key>

Pour les requêtes incluant un corps, l' Content-Typeen-tête doit préciser que le corps est au format JSON :

Content-Type: application/json

Corps
Certaines requêtes de l'API Wave incluent des données. Ces données doivent être au format JSON et utiliser l'encodage UTF-8.

Réponses
Les réponses de l'API Wave utilisent les codes d'état HTTP pour indiquer si une requête a abouti. Les codes 2xx indiquent que la requête a été reçue, comprise et acceptée avec succès. Les codes 4xx signalent un problème côté client et les codes 5xx un problème côté serveur. Consultez la section Erreurs pour plus d'informations sur les réponses d'erreur.

En réponse à une requête API réussie, le corps du message contient des informations fournies par le serveur au format JSON (utilisant l'encodage UTF-8).

En cas d'échec d'une requête, le corps du message contient des informations sur l'erreur au format JSON (encodage UTF-8). Il comprend au minimum un code d'erreur court et un message plus long, lisible par l'utilisateur, expliquant la raison de l'échec.

Erreurs
Lorsqu'une requête API ne peut être menée à bien, la réponse fournit des informations sur l'échec dans le corps du message et dans le code d'état HTTP.

Détails de l'erreur
Voici à quoi pourrait ressembler le corps du message de réponse à une requête invalide :

{
"code": "request-validation-error",
"message": "Request invalid",
"details": [{
"loc": ["payments", 1, "mobile"],
"msg": "field required"
}]
}
En cas d'échec d'une requête, Wave fournit des détails sur l'erreur dans le corps du message. Ce message contient au minimum une description courte codeet une description plus détaillée, lisibles par l'utilisateur message. Pour les erreurs de validation, Wave peut également préciser detailsl'élément ayant échoué, notamment le champ concerné et le problème rencontré.

Codes d'état
La cause générale de l'échec est indiquée par le code d'état de la réponse HTTP. Les codes 4xx signalent un problème au niveau de la requête côté client, tandis que les codes 5xx indiquent un problème côté serveur. Les détails spécifiques du problème sont fournis dans le corps du message.

Vous trouverez ci-dessous une liste de certains codes d'état que nous renvoyons.

Code Titre Descriptions
400 Mauvaise demande Le serveur ne peut pas traiter la requête car elle est mal formée.
401 Non autorisé La clé API est invalide.
403 Interdit La clé API ne dispose pas des autorisations appropriées pour la requête.
404 Introuvable Vous avez demandé un objet ou une page introuvable.
422 Entité non traitable La requête est correctement formée, mais le serveur est incapable de traiter son contenu.
429 Trop de requêtes La limite de requêtes a été dépassée, c'est-à-dire que le serveur a reçu trop de requêtes dans un laps de temps donné.
500 Erreur interne du serveur Le serveur a rencontré une erreur. Veuillez réessayer plus tard.
503 service non disponible Le serveur est indisponible en raison d'une surcharge temporaire ou d'une maintenance planifiée. Veuillez réessayer plus tard.
Journal des modifications
2024-03-29
Supprime override_business_nameles détails de l'API de paiement

17 octobre 2022
Ajout aggregated_merchant_idde détails à l'API de paiement.

10 mai 2022
L'API de paiement valide désormais les décimales conformément aux règles décrites dans la section Montant .

29/03/2022
Ajoute override_business_namedes détails à l'API de paiement

2022-03-23
Première version des API Checkout et Balance.

Recherche
API de paiement
URL de base
Authentification
Idempotence
limitation de débit
API
Types
Erreurs
Journal des modifications
16/06/2023
24/11/2022
17 octobre 2022
2022-09-23
2022-09-21
2022-09-08
27/06/2022
API de paiement
L'API de paiement de Wave permet d'envoyer de l'argent de votre entreprise à un ou plusieurs bénéficiaires par programmation. Les bénéficiaires sont identifiés par leur numéro de téléphone mobile ; utiliser l'API est donc aussi simple que de l'indiquer à Wave :

"Envoyer amountà mobile number."

POINTS D'EXPÉRIENCE :

POST /v1/payout
GET /v1/payout/:id
GET /v1/payouts/search
POST /v1/payout-batch
GET /v1/payouts-batch/:id
POST /v1/payout/:id/reverse

URL de base
Tous les chemins d'accès aux points de terminaison référencés dans la documentation de l'API sont relatifs à une URL de base, https://api.wave.com .

Authentification
L'authentification à l'API s'effectue via des clés API. Ces clés sont liées à un seul portefeuille d'entreprise et ne peuvent interagir qu'avec celui-ci.

Si vous devez interagir avec plusieurs portefeuilles sur votre réseau, vous devrez obtenir une clé par portefeuille.

Les clés API permettent d'effectuer n'importe quelle requête API, y compris celles qui impliquent des transferts d'argent et l'accès à des informations sensibles. Il est donc impératif de les garder secrètes. Votre clé ne doit être ni partagée, ni stockée ailleurs que sur vos propres serveurs, ni utilisée dans le code côté client.

Chaque requête doit être envoyée via HTTPS et contenir un en-tête d'autorisation spécifiant le schéma de support avec la clé API :

Authorization: Bearer wave_sn_prod_YhUNb9d...i4bA6
Notez que la clé réelle est beaucoup plus longue, mais à des fins de documentation, la plupart des caractères ont été remplacés par des points de suspension.

Obtention de votre clé API
Vous pouvez gérer les clés API dans la section développeur du portail Wave Business . Vous pouvez créer, consulter et révoquer des clés, et définir les API spécifiques auxquelles chaque clé donne accès.

Portail développeur

Lorsque vous créez une nouvelle clé API, vous ne verrez la clé complète qu'une seule fois. Veillez à la copier sans omettre aucun caractère, car elle sera masquée par la suite pour des raisons de sécurité.

Créer une clé API

Wave ne connaît pas votre clé complète, mais si vous contactez le support API, nous pouvons l'identifier grâce aux 4 dernières lettres affichées sur le portail d'entreprise.

Seuls les administrateurs peuvent accéder à la section Développeur du portail d'entreprise. Si vous êtes administrateur et que vous ne la voyez toujours pas, contactez l'assistance API pour l'activer.
Codes d'erreur
Lors de la phase d'authentification, l'une des erreurs suivantes peut entraîner le retour prématuré de votre requête :

Statut Code Descriptions
401 missing-auth-header Votre requête doit inclure un en-tête d'authentification HTTP.
401 invalid-auth Votre en-tête d'authentification HTTP ne peut pas être traité.
401 api-key-not-provided Votre requête doit inclure une clé API.
401 no-matching-api-key La clé que vous avez fournie n'existe pas dans notre système.
401 api-key-revoked Votre clé API a été révoquée.
403 invalid-wallet Votre portefeuille ne peut pas être utilisé avec cette API.
403 disabled-wallet Votre portefeuille a été temporairement désactivé. Vous pouvez toujours utiliser ce point de terminaison pour consulter votre solde.
Idempotence
Toute requête modifiant des données doit fournir une clé d'idempotence afin de garantir des tentatives de reconnexion sécurisées et d'éviter les doubles envois de fonds accidentels. Cette clé permet d'identifier les requêtes considérées comme identiques .

Idempotency-Key: 65f735b4-b44b-429d-b0a8-550701e2393a

Générer des chaînes aléatoires
openssl rand -hex 8
coquille
PHP
JavaScript
Java
python
Si vous souhaitez réessayer une requête que vous avez déjà envoyée : utilisez la même clé d’idempotence .
Si vous souhaitez envoyer une nouvelle requête différente : utilisez une nouvelle chaîne aléatoire comme clé d’idempotence .
Les clés d'idempotence offrent la garantie simple suivante : si plusieurs requêtes utilisent la même clé d'idempotence, elles n'entraîneront jamais l'envoi d'argent plus d'une fois.
La clé d'idempotence est transmise dans l'en-tête HTTP d'une requête, sous la forme : `<clé_idempotence>` Idempotency-Key: <STRING_OF_YOUR_CHOICE>. Vous trouverez des exemples de requêtes complètes dans la section API .

La clé d'idempotence est générée par le client. Elle doit être unique et comporter jusqu'à 255 caractères. Nous recommandons l'utilisation d'UUID v4 ou d'autres chaînes aléatoires présentant une entropie suffisante pour éviter les collisions.

Nous vous suggérons d'attendre quelques secondes entre chaque nouvelle tentative. Veuillez consulter la section « Tentatives » pour obtenir des informations plus détaillées sur la mise en œuvre des nouvelles tentatives.

limitation de débit
Les API Wave sont soumises à une limitation de débit afin d'éviter les abus susceptibles de dégrader les performances pour tous les utilisateurs. Si vous envoyez de nombreuses requêtes en peu de temps, vous risquez de recevoir des réponses d'erreur 429.

API
Créer un paiement
Idempotent
POST /v1/payout

Effectuez un paiement unique, c'est-à-dire transférez de l'argent de votre portefeuille professionnel vers un destinataire spécifique, identifié par son numéro de téléphone. L'exécution est synchrone : Wave tentera d'exécuter la transaction immédiatement et renverra le résultat en réponse à cette requête.

curl -X POST \
 --url https://api.wave.com/v1/payout \
 -H 'Authorization: Bearer wave_sn_prod_YhUNb9d...i4bA6' \
 -H 'Content-Type: application/json' \
 -H 'idempotency-key: 65f735b4-b44b-429d-b0a8-550701e2393a' \
 -d '{ "currency": "XOF",
"receive_amount": "500",
"name": "Fatou Ndiaye",
"mobile": "+221555110219"
}'
coquille
PHP
JavaScript
Java
python
Paramètres
Clé Taper Description
client_reference Chaîne de caractères (facultatif, jusqu'à 255 caractères) Une chaîne de caractères unique que vous fournissez et qui peut être utilisée pour associer le paiement dans votre système.
currency Code de devise Le montant doit être indiqué dans la devise indiquée. Veuillez noter que votre portefeuille professionnel et celui du destinataire doivent se trouver dans le même pays.
mobile Numéro de téléphone Le numéro de téléphone portable du destinataire.
name Chaîne de caractères (facultatif), jusqu'à 255 caractères Le nom du destinataire peut être utilisé pour la vérification de l'utilisateur.
national_id Chaîne de caractères (facultatif, jusqu'à 255 caractères) Champ facultatif permettant d'enregistrer le numéro d'identification national du destinataire, pour une vérification ultérieure par l'utilisateur.
payment_reason Chaîne de caractères (facultatif), jusqu'à 40 caractères Un message facultatif indiquant le motif du paiement, qui apparaît aux clients sur le reçu de paiement.
receive_amount Montant Le montant à verser au bénéficiaire, net de frais.
aggregated_merchant_id Chaîne de caractères (obligatoire pour les agrégateurs) L'identifiant d'un compte marchand agrégé à utiliser pour ce paiement. Ce service est réservé à certaines entreprises et une erreur sera générée si vous le fournissez sans autorisation. Pour utiliser cette fonctionnalité, veuillez contacter votre représentant du support Wave.
Exemple de résultat positif

{
"id": "pt-185b5e4b8100c",
"currency": "XOF",
"receive_amount": "500",
"fee": "5",
"mobile": "+221555110219",
"name": "Fatou Ndiaye",
"status": "succeeded",
"timestamp": "2022-06-20T17:17:11Z"
}
En l'absence d'erreurs de validation ou de pré-vérification, l'envoi d'un paiement renvoie les mêmes champs que ceux que vous avez soumis, ainsi que les éléments suivants :

Clé Taper Description
id Chaîne Identifiant unique de l'objet de paiement. Jusqu'à 20 caractères.
fee Montant Les frais d'envoi du paiement.
payout_error Erreur de paiement (facultatif) Détails concernant le motif d'un échec de paiement. Ces informations sont renseignées uniquement lorsque le statut est « En attente » failed.
status État de paiement État du paiement : processing, failed, ou succeeded.
timestamp Horodatage Date et heure d'enregistrement de cette demande de paiement dans notre système. Veuillez noter que cela ne correspond pas à la date d'exécution du paiement, mais uniquement à la date de soumission.
Si la requête ne réussit pas à passer les règles de validation ou d'autres contrôles empêchant la création d'un objet Payout, une erreur de niveau supérieur simple est renvoyée avec les champs codeet message.

Exemple de résultat d'erreur

{
"code": "request-validation-error",
"message": "An 'Idempotency-Key' header is required for POST requests"
}
Notez que cela signifie que vous devez gérer les deux types d'erreurs :

1. Lorsque la réponse a un code d'état HTTP différent de 200 et que le JSON de la réponse contient la clé « code ».
2. Lorsqu'un objet Payout est renvoyé mais contient un objet d'erreur sous la clé « payout_error ».
   Consultez la section Erreurs pour obtenir la liste complète et l'explication de chaque code d'erreur possible.

Récupérez un paiement
GET /v1/payout/:id

Récupère un paiement unique par identifiant (identifiant commençant par pt-).

curl -X GET \
 --url https://api.wave.com/v1/payout/pt-185sewgm8100t \
 -H 'Authorization: Bearer wave_sn_prod_YhUNb9d...i4bA6'
coquille
PHP
JavaScript
Java
python
Exemple de réponse

{
"id": "pt-185sewgm8100t",
"currency": "XOF",
"receive_amount": "15000",
"fee": "150",
"mobile": "+221555110233",
"name": "Moustapha Mbaye",
"national_id": "1751197904376",
"client_reference": "FAH.4827.1734",
"payment_reason": "Salary November 2022",
"status": "succeeded",
"timestamp": "2022-06-21T09:56:29Z"
"aggregated_merchant_id": "am-7lks22ap113t4",
}
Attributs de retour
Clé Taper Description
id Chaîne Identifiant unique de l'objet de paiement. Jusqu'à 20 caractères.
currency Code de devise Le montant doit être indiqué dans la devise indiquée. Veuillez noter que votre portefeuille professionnel et celui du destinataire doivent se trouver dans le même pays.
fee Montant Les frais d'envoi du paiement.
mobile Numéro de téléphone Le numéro de téléphone portable du destinataire.
name Chaîne de caractères (facultatif), jusqu'à 255 caractères Le nom du destinataire peut être utilisé pour la vérification de l'utilisateur.
national_id Chaîne de caractères (facultatif), jusqu'à 255 caractères Champ facultatif permettant d'enregistrer le numéro d'identification national du destinataire, pour une vérification ultérieure par l'utilisateur.
payout_error Erreur de paiement (facultatif) Détails concernant le motif d'un échec de paiement. Ces informations sont renseignées uniquement lorsque le statut est « En attente » failed.
receive_amount Montant Le montant à verser au bénéficiaire, net de frais.
status État de paiement État du paiement : processing, failed, ou succeeded.
timestamp Horodatage Date et heure d'enregistrement de cette demande de paiement dans notre système. Veuillez noter que cela ne correspond pas à la date d'exécution du paiement, mais uniquement à la date de soumission.
client_reference Chaîne de caractères (facultatif), jusqu'à 255 caractères Une chaîne de caractères unique que vous fournissez et qui peut être utilisée pour associer le paiement dans votre système.
payment_reason Chaîne de caractères (facultatif), jusqu'à 40 caractères Un message facultatif indiquant le motif du paiement, qui apparaît aux clients sur le reçu de paiement.
aggregated_merchant_id Chaîne de caractères (facultatif) L'identifiant marchand agrégé utilisé pour ce paiement, le cas échéant.
Recherche de gains
GET /v1/payouts/search

Récupère la liste des paiements en fonction des paramètres de requête fournis. Ne prend actuellement en charge que la recherche par référence client ( client_reference).

curl -X GET \
 --url https://api.wave.com/v1/payouts/search?client_reference=FAH.4827.1734 \
 -H 'Authorization : Bearer wave_sn_prod_YhUNb9d...i4bA6'
coquille
PHP
JavaScript
Java
python
Exemple de réponse

{
"result": [
{
"id": "pt-185sewgm8100t",
"currency": "XOF",
"receive_amount": "15000",
"fee": "150",
"mobile": "+221555110233",
"name": "Moustapha Mbaye",
"national_id": "1751197904376",
"client_reference": "FAH.4827.1734",
"payment_reason": "Salary November 2022",
"status": "succeeded",
"timestamp": "2022-06-21T09:56:29Z"
"aggregated_merchant_id": "am-7lks22ap113t4",
}
]
}
Attributs de retour
Clé Taper Description
result Liste des paiements La liste des paiements correspondant aux critères de recherche.
Le tableau de résultats sera vide si aucun paiement ne correspond aux critères de recherche.
Créer un lot de paiement
Idempotent
POST /v1/payout-batch/

Soumet un lot de paiements, comprenant un ou plusieurs paiements à exécuter. Le traitement de ces transactions est asynchrone ; par conséquent, ce point de terminaison ne renverra pas immédiatement les paiements résultants.

Vous recevez alors un identifiant vous permettant de consulter le résultat du lot de paiements et de voir quelles transactions ont été effectuées avec succès. Nous vous recommandons d'interroger ce point de terminaison toutes les deux secondes environ, en fonction de la taille de votre lot.

curl -X POST \
 --url https://api.wave.com/v1/payout-batch \
 -H "authorization: Bearer wave_sn_prod_YhUNb9d...i4bA6" \
 -H 'content-type: application/json' \
 -H 'idempotency-key: 65f735b4-b44b-429d-b0a8-550701e2393a' \
 -d '{"payouts": [
{ "currency": "XOF",
"receive_amount": "1000",
"name": "Fatou Ndiaye",
"mobile": "+221555110219"
},
{ "currency": "XOF",
"receive_amount": "1200",
"name": "Moustapha Mbaye",
"mobile": "+221555110233",
"aggregated_merchant_id": "am-7lks22ap113t4",
},
{ "currency": "XOF",
"receive_amount": "16000",
"name": "Mame Diop",
"mobile": "+221555144081"
}
]}'
coquille
PHP
JavaScript
Java
python
Exemple de réponse

{
"id": "pb-185skxq8g1006"
}
Paramètres
Clé Taper Description
paiements Liste des demandes de paiement Liste des paiements à effectuer. Chaque élément doit respecter la même structure que celle utilisée pour une demande de paiement unique.
Attributs de retour
Clé Taper Description
identifiant Chaîne L'identifiant du lot de paiement que vous pouvez utiliser pour interroger le point de terminaison « get payout batch » .
Récupérer un lot de paiement
GET /v1/payout-batch/:id

Récupère un lot de paiements.

curl -X GET \
 --url https://api.wave.com/v1/payout-batch/pb-185skxq8g1006 \
 -H 'Authorization: Bearer wave_sn_prod_YhUNb9d...i4bA6'
coquille
PHP
JavaScript
Java
python
Exemple de réponse

{
"id": "pb-185skxq8g1006",
"status": "complete",
"payouts": [
{
"id": "pt-185skxq9g100w",
"currency": "XOF",
"receive_amount": "1000",
"fee": "10",
"mobile": "+221555110219",
"name": "Fatou Ndiaye",
"status": "succeeded",
"timestamp": "2022-06-21T10:07:30Z"
},
{
"id": "pt-185skxqa0100y",
"currency": "XOF",
"receive_amount": "1200",
"fee": "10",
"mobile": "+221555110233",
"name": "Moustapha Mbaye",
"status": "processing",
"aggregated_merchant_id": "am-7lks22ap113t4",
"timestamp": "2022-06-21T10:07:30Z"
},
{
"id": "pt-185sw98jg1016",
"currency": "XOF",
"receive_amount": "16000",
"fee": "160",
"mobile": "+221555144081",
"name": "Mame Diop",
"status": "failed",
"payout_error": {
"error_code": "recipient-limit-exceeded",
"error_message": "The recipient has reached their monthly limit."
},
"timestamp": "2022-06-21T10:25:46Z"
}
]
}
Attributs de retour
Clé Taper Description
identifiant Chaîne L'identifiant du lot de paiement.
payouts Liste des résultats de paiement . La liste des paiements, chaque élément ayant la même structure qu'un paiement unique récupéré.
status État du lot de paiement Statut du lot de paiement : processingou complete.
Il n'existe pas d'indicateur successde failedstatut pour les lots de paiements, car au sein d'un même lot, plusieurs paiements peuvent réussir ou échouer. Pour gérer les erreurs, chaque paiement payoutsdoit être examiné afin de vérifier la présence d'un payout_errorchamp approprié.

Annuler un paiement
Idempotent
POST /v1/payout/:id/reverse

Annule un paiement précédemment effectué, frais inclus. Actuellement, le délai d'annulation est de 3 jours (pour tenir compte d'un jour après le week-end), à compter de la date de création du paiement. Cette information se trouve dans le timestampchamp correspondant de l' objet Paiement .

L'idempotence de ce point de terminaison signifie que si vous tentez d'annuler un paiement déjà annulé, vous recevrez un code de retour de succès, mais aucune transaction supplémentaire ne sera créée. Vous ne pouvez donc jamais annuler un paiement deux fois par erreur.

curl -X POST \
 --url https://api.wave.com/v1/payout/pt-185sewgm8100t/reverse \
 -H 'Authorization: Bearer wave_sn_prod_YhUNb9d...i4bA6'
coquille
PHP
JavaScript
Java
python
Exemple de réponse

200 OK
Attributs de retour
Aucun

Si l'opération d'inversion réussit, ce point de terminaison renvoie un code HTTP 200, sans corps de requête.

Si l'opération d'inversion échoue, un code HTTP supérieur à 400 est renvoyé :

error_code explication
insufficient-funds Le solde du portefeuille du destinataire est insuffisant pour couvrir l'annulation.
payout-reversal-time-limit-exceeded Le délai pour annuler un paiement est expiré.
payout-reversal-account-terminated Le portefeuille du destinataire a été désactivé dans le système Wave.
not-found Aucun paiement n'a été trouvé sur le portefeuille lié à votre clé API.
Chaque paiement ne peut être annulé qu'une seule fois, mais comme le point de terminaison est idempotent, vous pouvez réessayer sans risque.

Types
Montant
Tous les montants sont représentés sous forme de chaîne de caractères. Le montant doit être un nombre rond, sans décimales. Les règles suivantes s'appliquent aux montants valides :

Pas de zéros non significatifs lorsque la valeur est supérieure ou égale à un.
Doit être positif pour les demandes.
Code de devise
Les codes à trois lettres majuscules de la norme ISO 4217XOF sont utilisés pour spécifier la devise. Remarque : le code du franc ouest-africain est Γ, et non Γ CFA.

Numéro de téléphone
Les numéros de téléphone sont conformes à la norme E.164 . Ils doivent inclure un indicatif de pays précédé d'un point +.

Horodatage
Date et heure ISO 8601 .

Le fuseau horaire est UTC.
La précision est de l'ordre de la seconde.
Le format est le suivantYYYY-MM-DDThh:mm:ssZ : . Exemple : 2022-06-20T17:17:11Z.
État de paiement
Un état de paiement est représenté par une chaîne de caractères qui correspond exactement à l'une des valeurs suivantes :

processing
La demande de paiement a été soumise, mais elle est toujours en cours de traitement.
succeeded
Le paiement a été effectué avec succès et l'argent est parvenu à l'utilisateur.
failed
Une erreur s'est produite lors du paiement. Veuillez consulter la section Erreurs pour obtenir des informations détaillées sur les différents types d'erreurs.
reversed
Le versement a été annulé.
État du lot de paiement
L'état d'un lot de paiement est représenté par une chaîne de caractères correspondant exactement à l'une des valeurs suivantes :

processing
La demande de paiement a été soumise et est en cours de traitement.
complete
Tous les paiements inclus dans le patch ont été traités. Certains paiements ont pu réussir, d'autres non ; il convient de vérifier chaque paiement au sein du lot.
Erreur de paiement
Exemple

{
"error_code": "insufficient-funds",
"error_message": "Insufficient funds in wallet."
}
L'erreur de paiement est un objet. Les erreurs peuvent être renvoyées par l'API à deux endroits : soit au niveau supérieur lorsqu'une validation ou une vérification préalable échoue, soit en tant que payout_errorchamp d'un paiement individuel si un problème est survenu lors de l'exécution.

Clé Taper Explication
error_code Chaîne Vous pouvez utiliser cette méthode dans votre système pour déterminer comment gérer l'erreur. Vous trouverez la liste de tous les codes d'erreur possibles dans la section « Erreurs » .
error_message Chaîne de caractères (facultatif)
Erreurs
Erreurs de l'API de paiement
Exemples d'erreurs renvoyées par l'API

Erreur de requête

{
"error": "request-validation-error",
"message": "Invalid phone number."
}
Erreur de validation

{
"code": "request-validation-error",
"message": "Request invalid",
"details": [
{
"loc": ["currency"],
"msg": "Unknown currency identifier: ABC. We require the currency to be a three-letter ISO 4217 code.",
"type": "value_error"
}
]
}
Erreur lors de la tentative d'exécution d'un paiement

{
"error_code": "insufficient-funds",
"error_message": "Insufficient funds in wallet."
}
Erreur sur un objet Payout, par exemple dans le cadre d'un lot

{
"id": "pt-185sw98jg1016",
"currency": "XOF",
"receive_amount": "16000",
"fee": "160",
"mobile": "+221555144081",
"name": "Mame Diop",
"status": "failed",
"payout_error": {
"error_code": "recipient-limit-exceeded",
"error_message": "The recipient has reached their monthly limit."
},
"timestamp": "2022-06-21T10:25:46Z"
}
Voici la liste des erreurs pouvant survenir lors de l'utilisation de cette API.

error_code explication
country-mismatch Le destinataire doit se trouver dans le même pays que votre entreprise.
currency-mismatch La devise que vous avez indiquée ne correspond pas à celle de votre portefeuille ni à celle du destinataire.
idempotency-mismatch Vous avez soumis une requête avec une clé d'idempotence que vous avez déjà utilisée dans une requête précédente, mais le contenu de la requête ne correspond pas.
insufficient-funds Votre compte bancaire professionnel ne dispose pas du solde nécessaire pour couvrir le montant total, frais inclus.
internal-server-error Une erreur technique est survenue dans le système Wave. Nous mettons tout en œuvre pour éviter ce genre de situation ; elle est donc réservée aux cas exceptionnels. Veuillez contacter votre représentant Wave si vous rencontrez ce problème. Vous pouvez toujours relancer la requête automatiquement avec la même clé d'idempotence. Nous vous recommandons d'attendre quelques secondes entre chaque tentative.
invalid-aggregated-merchant-id L'identifiant marchand agrégé fourni avec cette demande n'existe pas ou ne peut pas être utilisé à partir de ce compte.
missing-auth-header Il manque un jeton Bearer dans l' Authorizationen-tête de la requête. Consultez la section Authentification pour obtenir des instructions.
not-found Vous avez demandé un paiement ou un lot de paiements par un identifiant que nous ne parvenons pas à associer à une demande dans notre système. Veuillez vérifier que cet identifiant correspond bien à celui que vous avez reçu en réponse et que la demande provient du même portefeuille professionnel.
recipient-minor Le destinataire est mineur et ne peut recevoir de paiement de cette source.
recipient-account-blocked Le compte Wave auquel vous envoyez de l'argent est bloqué. Cela est généralement dû à la perte du téléphone ou à une fraude.
recipient-account-inactive Le compte Wave du destinataire de votre envoi d'argent est inactif. Il peut le réactiver en contactant l'assistance Wave.
recipient-limit-exceeded La personne à qui vous envoyez de l'argent a atteint son plafond mensuel. Elle peut souvent l'augmenter en vérifiant son identité auprès d'un agent Wave.
request-not-json Votre requête ne comporte pas de corps JSON ou ne contient pas l'en-tête Content-Type « application/json ».
request-parsing-error Le corps JSON de cette requête est invalide, généralement à cause de parenthèses, de virgules ou de guillemets mal placés. error_messageVous trouverez plus de détails ci-dessous.
request-validation-error Votre requête ne correspond pas au type d'objet requis. Il peut s'agir, par exemple, d'un champ manquant ou d'un type invalide pour un champ fourni, comme un numéro de téléphone invalide. Nous error_messagevous fournirons des informations supplémentaires.
service-unavailable Dans de rares et brèves situations, les services Wave sont indisponibles pour maintenance. Vous pouvez réessayer ultérieurement.
too-many-requests Vous avez envoyé plus de demandes que nous ne pouvons en traiter dans un délai aussi court. Pour éviter cela, vous pouvez effectuer vos paiements par lots .
aggregated-merchant-required Une identité marchande agrégée est requise pour traiter le paiement. Vous devez fournir un identifiant marchand agrégé.
Nous vous suggérons d'écrire un code capable de gérer les erreurs ci-dessus. Nous pourrions occasionnellement ajouter un nouveau type d'erreur.

La liste ci-dessus ne concerne que les erreurs connues et sous le contrôle de Wave. D'autres problèmes techniques peuvent survenir, comme des erreurs de connexion ou des délais d'attente en cas de problèmes réseau entre vos serveurs et ceux de Wave. Leur nombre est trop important pour être listé ici, mais dans tous les cas, les requêtes peuvent être relancées sans risque, à condition d' utiliser la même clé d'idempotence .

Codes d'état HTTP
La cause générale de l'échec est indiquée par le code d'état de la réponse HTTP. Les codes 4xx signalent un problème au niveau de la requête côté client, tandis que les codes 5xx indiquent un problème côté serveur. Les détails spécifiques du problème sont fournis dans le corps du message.

Vous trouverez ci-dessous une liste de certains codes d'état que nous renvoyons.

Code Titre Descriptions
400 Mauvaise demande Le serveur ne peut pas traiter la requête car elle est mal formée.
401 Non autorisé La clé API est invalide.
403 Interdit La clé API ne dispose pas des autorisations appropriées pour la requête.
404 Introuvable Vous avez demandé un objet ou une page introuvable.
405 Méthode non autorisée La combinaison de chemin d'URL et de méthode REST n'existe pas sur cette API.
408 Délai d'attente de la requête dépassé Le traitement de votre requête a pris trop de temps. Veuillez réessayer plus tard.
409 Conflit La requête n'a pas pu être traitée en raison d'un conflit avec l'état actuel de la ressource.
422 Entité non traitable La requête était bien formée, mais le serveur n'a pas pu la traiter.
429 Trop de requêtes La limite de requêtes a été dépassée, c'est-à-dire que le serveur a reçu trop de requêtes dans un laps de temps donné.
500 Erreur interne du serveur Le serveur a rencontré une erreur. Veuillez réessayer plus tard, mais l'erreur peut persister.
503 service non disponible Le serveur est indisponible en raison d'une surcharge temporaire ou d'une maintenance planifiée. Veuillez réessayer plus tard.
504 Délai d'attente de la passerelle Un délai d'attente a été dépassé sur le réseau lors du traitement de la requête. Veuillez réessayer plus tard.
État d'un paiement
Une fois le paiement enregistré dans notre système, il est créé avec le statut « En cours de traitement » processing . Le traitement du paiement commence immédiatement et une tentative d'envoi du montant sélectionné au destinataire final est effectuée. Le statut du paiement est ensuite mis à jour à « En cours de traitement » succeededou «failed Terminé ». Vous pouvez consulter le statut d'un paiement à tout moment via le point de terminaison GET /v1/payout , en fournissant l'identifiant renvoyé lors de sa création.

Le failedpaiement inclura également la raison de l'échec du transfert sous la forme d'une erreur de paiement (payout_error) , et vous pourrez utiliser cette information pour déterminer s'il convient de réessayer.

Si un paiement n'a pas pu être saisi correctement dans notre système, toute requête adressée au GET /v1/payoutpoint de terminaison avec l'identifiant concerné entraînera le not-foundrenvoi d'une erreur.

Dans des cas exceptionnels, Wave peut rencontrer une panne affectant ses API, entraînant une erreur 5XX, telle que 500 (Erreur interne du serveur) ou 503 (Service indisponible). Si vous recevez cette réponse du point de terminaison, un paiement peut tout de même être créé sur notre système, mais sans identifiant associé. Vous pouvez alors réessayer le paiement en toute sécurité en vous assurant d'utiliser POST /v1/payoutla même clé d'idempotence .

Si une requête POST /v1/payout est envoyée à l'API avec un corps identique à celui d'une autre requête, mais une clé d'idempotence différente, cela entraînera inévitablement une transaction dupliquée ! Assurez-vous que votre système est capable de gérer ce type de situation.
Nouvelle tentative de transaction
Voici les recommandations de Wave concernant la logique de nouvelle tentative. Veuillez lire attentivement la section relative aux erreurs et à l'idempotence .

Erreurs système
Certaines erreurs sont inattendues, ce qui signifie que la transaction se trouve dans un état inconnu . Cela peut se produire, par exemple, lors d'une panne ou en cas de problèmes de connexion Internet.

Il est important que vous marquiez vos transactions en interne comme étant en attente .
Vous devez ensuite réessayer ces transactions en utilisant la même clé d'idempotence . Il n'y a pas de limite de temps pour les nouvelles tentatives.
Utilisez des tentatives de nouvelle connexion qui commencent à intervalles de 1 seconde, puis utilisez un délai exponentiel .
Si vous disposez d'un identifiant de paiement ou d'un client_reference, vous pouvez également récupérer le paiement pour en vérifier l'état.
Voici les codes d'erreur dans lesquels ce problème peut se produire :
408Délai d'attente de la requête dépassé
500Erreur interne du serveur.
503Service indisponible. Le serveur est temporairement surchargé ou en cours de maintenance. Veuillez réessayer plus tard.
5xxVous devez réessayer en cas d'erreurs internes du serveur.
Si vous marquez les transactions comme ayant échoué au lieu de les laisser en attente , vos clients pourraient tenter de les effectuer à nouveau. Cela risque d'entraîner une transaction en double, ce qui est généralement considéré comme un problème majeur, car votre argent (ou celui de votre client) serait débité deux fois.

En cas de panne système de plus d'une minute, la meilleure solution consiste à laisser les transactions en attente et à les relancer automatiquement une fois la panne résolue.
erreurs de limitation de débit
Les erreurs de limitation de débit de type «429 Trop de requêtes » doivent toujours faire l'objet d'une nouvelle tentative. Il convient d'attendre quelques secondes avant de réessayer. Il est également recommandé de les marquer en interne comme étant en attente plutôt que comme ayant échoué.

Erreurs de validation et d'équilibrage
Toutes les autres erreurs sont définitives, votre système peut donc marquer la transaction comme ayant échoué .

Exemple 1 : si le destinataire a atteint la limite de son compte, il n’est pas judicieux de réessayer immédiatement.
Exemple 2 : si la requête était invalide parce qu’un champ était manquant, il est inutile de réessayer.
En résumé : en cas d’erreurs inattendues telles que des problèmes de connexion ou des services indisponibles, il est généralement conseillé de réessayer. Utilisez toujours la même clé d’idempotence lors de chaque nouvelle tentative de paiement ou de traitement par lots.

Journal des modifications
16/06/2023
recipient-minorCode d'erreur ajouté .
24/11/2022
Nouveau payment_reasondomaine.
17 octobre 2022
Ajout du aggregated_merchant_idchamp et invalid-aggregated-merchant-iddu code d'erreur associé.
2022-09-23
Code d'erreur ajouté recipient-account-blocked.
2022-09-21
Nous gérons désormais les problèmes de limitation de débit de manière plus transparente, en renvoyant le message HTTP 429« Trop de requêtes » au lieu de 500« Erreur interne du serveur ».
Le too-many-requestscode d'erreur a été ajouté.
2022-09-08
Code d'erreur ajouté recipient-account-inactive.
27/06/2022
version initiale
