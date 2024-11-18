#!/bin/bash
# Register the Spring Boot service with Kong Gateway (in case you prefer manual setup)

KONG_ADMIN_URL="http://192.168.1.11:7001"

# Register a new service
curl -i -X POST ${KONG_ADMIN_URL}/services/ \
  --data "name=springboot-service" \
  --data "url=http://192.168.1.11:8080/hello"

# Add a route to the service
curl -i -X POST ${KONG_ADMIN_URL}/services/springboot-service/routes \
  --data "paths[]=/" \
  --data "strip_path=false"
