#!/bin/bash
# Register the Spring Boot service with Kong

KONG_ADMIN_URL="http://localhost:8002"

# Create a service
curl -i -X POST ${KONG_ADMIN_URL}/services/ \
  --data "name=springboot-service" \
  --data "url=http://localhost:8080/hello"

# Create a route
curl -i -X POST ${KONG_ADMIN_URL}/services/springboot-service/routes \
  --data "paths[]=/hello" \
  --data "strip_path=true"
