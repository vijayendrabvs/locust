FROM locustio/locust
USER root
RUN mkdir /mnt/locust && chown -R locust /mnt/locust
USER locust
ADD locustfile.py /mnt/locust/locustfile.py
