# Metrics API

The Metrics API provides information about a particular Buildkite agent.



## Get metrics

Returns an object with properties describing Buildkite.

`webhook_ips` is a list of IP addresses in CIDR notation that Buildkite uses to send outbound traffic such as webhooks and commit statuses. These are subject to change from time to time. We recommend checking for new addresses daily, and will try to advertise new addresses for at least 7 days before they are used.

Note: The IP addresses shown here are examples. You must query the API to get the current set of IP addresses.

```bash
curl -H "Authorization: Token XXXXXXXXXXXXXXXX" https://agent.buildkite.com/v3/metrics
```

```json
{
  "agents": {
    "idle": 1,
    "busy": 0,
    "total": 1,
    "queues": {
      "default": {
        "idle": 1,
        "busy": 0,
        "total": 1
      }
    }
  },
  "jobs": {
    "scheduled": 5,
    "running": 0,
    "waiting": 0,
    "total": 5,
    "queues": {
      "default}": {
        "scheduled": 5,
        "running": 0,
        "waiting": 0,
        "total": 5
      }
    }
  },
  "organization": {
    "slug": "plaindocs"
  }
}

```

Success response: `200 OK`