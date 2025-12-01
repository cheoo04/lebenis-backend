from locust import HttpUser, task, between

class LebenisUser(HttpUser):
    wait_time = between(1, 3)  # Attente aléatoire entre 1 et 3 secondes

    def on_start(self):
        self.token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY0NjI1NDkwLCJpYXQiOjE3NjQ2MjE4OTAsImp0aSI6ImRjOTRlNDk4MmNjNzQwMWNiNGRlZmE5ZmQ1MWEwNjVjIiwidXNlcl9pZCI6ImYxZjA1OTE5LWQ2MDktNGI2Ni05ZWFhLTlhMzZhZTJkODM1MiIsImVtYWlsIjoiY2hlb0BnbWFpbC5jb20iLCJ1c2VyX3R5cGUiOiJkcml2ZXIiLCJmdWxsX25hbWUiOiJjaGVvIFlBSCIsImlzX3ZlcmlmaWVkIjp0cnVlfQ.-TLUA-xRlMmttwVTVoWxS4BFipDonK9QcPtLVMLJMsw"  # Mets ici un vrai token JWT

    @task
    def my_deliveries(self):
        headers = {"Authorization": f"Bearer {self.token}"}
        self.client.get("/api/v1/drivers/my-deliveries/", headers=headers)

    @task
    def health(self):
        self.client.get("/health/")