FROM certbot/dns-route53

ENTRYPOINT [ "sleep", "3650d" ]
VOLUME /var/log/letsencrypt

COPY dns_route53.py src/certbot-dns-route53/certbot_dns_route53
