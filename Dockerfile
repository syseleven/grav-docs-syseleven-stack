FROM registry.code.syseleven.de/syseleven/managed-services/docs/grav-docker:2022-05-30-150509

# We need the page to be at /var/www/html/metakube for easier ingress configuration
USER root
RUN mv /var/www/html /tmp/syseleven-stack && mkdir /var/www/html && mv /tmp/syseleven-stack /var/www/html/syseleven-stack && chown www-data:www-data /var/www/html
USER www-data

COPY --chown=www-data:www-data user/config syseleven-stack/user/config
COPY --chown=www-data:www-data user/pages syseleven-stack/user/pages
COPY --chown=www-data:www-data user/apache2/.htaccess .
