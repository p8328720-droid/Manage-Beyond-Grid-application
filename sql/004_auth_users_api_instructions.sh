#!/bin/bash
# Replace SERVICE_ROLE_KEY with your Supabase project's service_role key.
# Use these commands to create auth users programmatically. Do not share the key.

SERVICE_ROLE_KEY="REPLACE_WITH_SERVICE_ROLE_KEY"
PROJECT_URL="https://jebiwzrskyxnrxicuse.supabase.co"

# Create admin user
curl -s -X POST "${PROJECT_URL}/auth/v1/admin/users" \
  -H "apikey: ${SERVICE_ROLE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@mbg.io","password":"Admin123!","email_confirm":true}' | jq .

# Create teknisi user
curl -s -X POST "${PROJECT_URL}/auth/v1/admin/users" \
  -H "apikey: ${SERVICE_ROLE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"email":"teknisi@mbg.io","password":"Teknisi123!","email_confirm":true}' | jq .

# After running, fetch auth user ids with:
# curl -s -X GET "${PROJECT_URL}/auth/v1/admin/users" -H "apikey: ${SERVICE_ROLE_KEY}" -H "Authorization: Bearer ${SERVICE_ROLE_KEY}" | jq '.data[] | {id,email}'
