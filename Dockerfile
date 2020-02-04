FROM locustio/locust
USER root
RUN mkdir /mnt/locust && chown -R locust:locust /mnt/locust
ADD locustfile.py /mnt/locust/locustfile.py
RUN chmod a+x /mnt/locust/locustfile.py
RUN chown -R locust:locust /mnt/locust/locustfile.py
