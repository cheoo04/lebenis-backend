from locust import HttpUser, task, between

class LebenisUser(HttpUser):
    wait_time = between(1, 3)  # Attente aléatoire entre 1 et 3 secondes

    def on_start(self):
        self.token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY0NjM1NjE0LCJpYXQiOjE3NjQ2MzIwMTQsImp0aSI6IjgzYzE0MDJmNGE2MTQ2OGE4NDhmNWFhODE1Mzk0OTQ4IiwidXNlcl9pZCI6ImYxZjA1OTE5LWQ2MDktNGI2Ni05ZWFhLTlhMzZhZTJkODM1MiIsImVtYWlsIjoiY2hlb0BnbWFpbC5jb20iLCJ1c2VyX3R5cGUiOiJkcml2ZXIiLCJmdWxsX25hbWUiOiJjaGVvIFlBSCIsImlzX3ZlcmlmaWVkIjp0cnVlfQ.KdDnabK8fJm_w1n2kVKBUnhaA4Zy_rKpxk8GL5F-tYE"  # Mets ici un vrai token JWT

    @task
    def my_deliveries(self):
        headers = {"Authorization": f"Bearer {self.token}"}
        self.client.get("/api/v1/drivers/my-deliveries/", headers=headers)

    @task
    def health(self):
        self.client.get("/health/")

# Pour lancer 
# /var/data/python/bin/locust -f locustfile.py --host https://lebenis-backend.onrender.com