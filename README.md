# terraform-provider-gcp-lb

This project handles the creation of a module to create Load Balancer in GCP. The goal is to create different kinds of Load Balancers from a single module:

- Global HTTP(S)
- Regional HTTP(S)
- Internal HTTP(S)
- Regional TCP

## Inputs table

| Variable   | Type   | Details                                                  | Nullable |
|------------|--------|----------------------------------------------------------|----------|
| name       | string | Name to be used by resources in the Load Balancer        | false    |
| mode       | string | Load Balancer mode. Can be REGIONAL or GLOBAL            | false    |
| scheme     | string | Scheme of the Load Balancer                              | false    |
| protocol   | string | Protocol to be used by the Load Balancer                 | false    |
| frontends  | map    | Defines the structure of frontends (multiple can be set) | false    |
| backends   | map    | Defines the structure of backends (multiple can be set)  | false    |
| url_maps   | list   | Defines the url-paths to be used by the Load Balancer    | false    |
| region     | string | Region which regional resources will be deployed         | true     |
| network    | string | Network which regional resources will be deployed        | true     |
| subnetwork | string | Subnetwork which regional resources will be deployed     | true     |

## Outputs table

| Variable           | Type | Details                                                |
|--------------------|------|--------------------------------------------------------|
| global_addresses   | map  | Map with all the global addresses created to be used   |
| regional_addresses | map  | Map with all the regional addresses created to be used |

## Frontends, Backends and Mapping rules

This module supports creating multiple frontends, backends and their mappings all within the same context.

### Frontend

- Purpose: Creating different frontends with different hosts which will use the same backend and also having both SSL and non-SSL entry points. Example: It's possible to have a HTTP example.com, HTTPS example.com and HTTPS second-example.com all pointing to the same Load Balancer;

- Variable: It is defined through a single variable named "frontends" which its type is map. Each key present in the root represents one frontend. The content should be:

| Field              | Type         | Description                                                                       | Nullable |
|--------------------|--------------|-----------------------------------------------------------------------------------|----------|
| ip_version         | string       | The IP Version that will be used by this frontend address. Can be IPV4 or IPV6    | false    |
| protocol           | string       | Protocol to be used by the frontend rule. Can be HTTP, HTTPS or TCP               | false    |
| region             | string       | Region where the frontend resources will be created                               | true     |
| network_tier       | string       | The networking tier used for configuring this address. Can be PREMIUM or STANDARD | true     |
| ssl.certificate_id | string       | If a certificate already exists, its ID should be passed here                          | true     |
| ssl.domains        | list(string) | List of domains to be added to the certificate. Google managed                    | true     |
| ssl.private_key    | string       | String with private key content (BEGIN PRIVATE KEY)                               | true     |
| ssl.certificate    | string       | String with certificate content (BEGIN CERTIFICATE)                               | true     |

- Rules (can't be added to variables validation): 
  - When Load Balancer mode is REGIONAL, frontends ip_version must be IPV4
  - When Load Balancer mode is REGIONAL, frontends must specify a region
  - When Load Balancer schema is INTERNAL_SELF_MANAGED, frontends network_tier must be PREMIUM
  - When frontend protocol is HTTPS, at least one of the following should be set: ssl.certificate_id, ssl.domains or ssl.private_key/ssl.certificate

### Backend

- Purpose: For cases when different backend services/buckets follow different path rules.

- Variable: It is defined through a single variable named "backends" which its type is map. Each key present in the root represents one backend. The content should be:

| Field                                  | Type   | Description                                                                                                                       | Nullable                   |
|----------------------------------------|--------|-----------------------------------------------------------------------------------------------------------------------------------|----------------------------|
| default_backend                        | bool   | Marks the backend to be the default route                                                                                         | false                      |
| type                                   | string | Type of backend. Can be SERVICE or BUCKET                                                                                         | false                      |
| config.protocol                        | string | Protocol used by the backend. Can be TCP, HTTP, HTTP/2 or HTTPS                                                                   | false                      |
| config.target                          | string | Target resource ID. Example: "https://www.googleapis.com/compute/v1/projects/<project-id>/zones/<mig-zone>/instanceGroups/<mig>"  | false                      |
| config.port_name                       | string | Port name that is configured on the target                                                                                        | false                      |
| config.balancing_mode                  | string | Defines how the Load Balancer distributes requests among backend. Can be UTILIZATION, RATE or CONNECTION                          | false                      |
| config.bucket_name                     | string | Bucket name where the backend will point                                                                                          | true (when TYPE is BUCKET) |
| config.timeout_sec                     | number | How many seconds to wait for the backend before considering it a failed request                                                   | true                       |
| config.connection_draining_timeout_sec | number | Time for which instance will be drained (not accept new connections, but still work to finish started)                            | true                       |
| config.enable_cdn                      | bool   | If true, enable Cloud CDN for this BackendService                                                                                 | true                       |
| config.custom_request_headers          | list   | Headers that the HTTP/S load balancer should add to proxied requests                                                              | true                       |
| config.custom_response_headers         | list   | Headers that the HTTP/S load balancer should add to proxied responses                                                             | true                       |
| config.session_affinity                | string | Type of session affinity to use                                                                                                   | true                       |
| config.affinity_cookie_ttl_sec         | number | Lifetime of cookies in seconds if session_affinity is GENERATED_COOKIE                                                            | true                       |
| config.security_policy                 | string | The security policy associated with this backend service                                                                          | true                       |
| config.capacity_scaler                 | number | A multiplier applied to the group's maximum servicing capacity                                                                    | true                       |
| config.max_connections                 | number | The max number of simultaneous connections for the group                                                                          | true                       |
| config.max_connections_per_instance    | number | The max number of simultaneous connections that a single backend instance can handle                                              | true                       |
| config.max_connections_per_endpoint    | number | The max number of simultaneous connections that a single backend network endpoint can handle                                      | true                       |
| config.max_rate                        | number | The max requests per second (RPS) of the group                                                                                    | true                       |
| config.max_rate_per_instance           | number | The max requests per second (RPS) that a single backend instance can handle                                                       | true                       |
| config.max_rate_per_endpoint           | number | The max requests per second (RPS) that a single backend network endpoint can handle                                               | true                       |
| config.max_utilization                 | number | Used when balancingMode is UTILIZATION. This ratio defines the CPU utilization target for the group                               | true                       |
| health_check.port                      | number | The port number for the health check request                                                                                      | true                       |
| health_check.check_interval_sec        | number | How often (in seconds) to send a health check                                                                                     | true                       |
| health_check.timeout_sec               | number | How long (in seconds) to wait before claiming failure                                                                             | true                       |
| health_check.healthy_threshold         | number | A so-far unhealthy instance will be marked healthy after this many consecutive successes                                          | true                       |
| health_check.unhealthy_threshold       | number | A so-far healthy instance will be marked unhealthy after this many consecutive failures                                           | true                       |

- Rules (can't be added to variables validation): 
  - When Load Balancer mode is REGIONAL, backends balancing_mode must be CONNECTION
  - When Load Balancer mode is REGIONAL, backend service must be in the same region as the backend

### Url maps

- Purpose: Map the corresponding hosts and paths to the right backend.

- Variable: It is defined through a single variable named "url-maps" which its type is list. Each index present represents on set of rules. The content should be:

| Variable     | Type         | Details                                                                        | Nullable |
|--------------|--------------|--------------------------------------------------------------------------------|----------|
| hosts        | list(string) | List of hosts which when matched will follow the rules                         | false    |
| rules.path   | list(string) | List of paths that will lead to the same backend                               | false    |
| rules.target | string       | Name of the backend to send traffic. Should match one of the backends variable | false    |

- Rules (can't be added to variables validation): 
  - The target for each rule should match one of the backends variable map