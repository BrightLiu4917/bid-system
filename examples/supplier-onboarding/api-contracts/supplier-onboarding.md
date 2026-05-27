# API Contract: Supplier Onboarding

This file is an example contract, not a confirmed project API.

## Supplier Submit Application

```http
POST /api/supplier/onboarding/applications
```

Request fields are pending confirmation. Example only:

```json
{
  "organizationName": "Example Supplier",
  "contactName": "Example Contact",
  "contactPhone": "13800000000",
  "licenseFileId": "file_001"
}
```

Response wrapper must follow the target project.

## Supplier Current Application

```http
GET /api/supplier/onboarding/applications/current
```

Returns current onboarding status and review result visible to the supplier.

## Platform Review List

```http
GET /api/platform/supplier-onboarding/applications
```

Query parameters and pagination format must follow the target project.

## Platform Review Decision

```http
POST /api/platform/supplier-onboarding/applications/{id}/review
```

Example request only:

```json
{
  "decision": "APPROVED",
  "reason": "Materials verified"
}
```

## Pending Confirmation
- Response wrapper.
- Error code format.
- Auth strategy.
- Permission model.
- Pagination model.
- Sensitive material visibility.
