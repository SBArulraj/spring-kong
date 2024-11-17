#!/bin/bash
# Register the Spring Boot service with Kong Gateway (in case you prefer manual setup)

KONG_ADMIN_URL="http://localhost:8002"

# Register a new service
curl -i -X POST ${KONG_ADMIN_URL}/services/ \
  --data "name=springboot-service" \
  --data "url=http://localhost:8080/hello"

# Add a route to the service
curl -i -X POST ${KONG_ADMIN_URL}/services/springboot-service/routes \
  --data "paths[]=/api" \
  --data "strip_path=true"
