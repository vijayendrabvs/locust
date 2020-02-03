from locust import HttpLocust, TaskSet, between

def testnative(l):
    l.client.get("/")

class UserBehavior(TaskSet):
    tasks = {testnative: 2}

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    wait_time = between(5.0, 9.0)
