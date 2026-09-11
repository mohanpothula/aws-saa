# Changelog

## 1.0 - 11 September 2026

- Published ten local Docker labs for AWS Solutions Architect – Associate, each as `labs/lab-NN-<topic>/` holding `lab.md`, `lab.pdf` and the lab's source.
- Converted the original Student Guides to Markdown and PDF; the editable `.docx` originals are kept in `courseware/`.
- Added an AWS-service mapping, a verification table and AWS / tool documentation references to every lab.
- Enforced LF line endings for scripts and configs so LocalStack init scripts run when the repository is cloned on Windows.

### Fixes found while running every lab end to end

- **Lab 1 and Lab 2:** LocalStack reports healthy before its init script finishes, so exercises run immediately after `docker compose up -d` could see no users, buckets or keys. Step 1 now waits for the init script's success message.
- **Lab 2 — `docker-compose.yml`:** the `alb` proxy was not attached to `private-net`, so it could not resolve `app` and NGINX exited on start-up; Step 2 (`curl http://localhost:8080`) always failed. The ALB now joins `default` and `private-net`. The deliberate App ↔ DB separation that Steps 5–6 teach is unchanged.
- **Lab 2 — Step 6:** the original command ran `apk add busybox-extras` inside the app container before `nc`. On an internal network there is no internet access, so the install always failed and `nc` never ran. The step now uses the `nc` already built into the image, and explains why the install could never work.
- **Lab 2 — Step 6:** `docker compose up -d --force-recreate` recreated every service, including LocalStack, which keeps its data in memory. Its bucket vanished until the init script re-ran, so Step 7 could fail with `NoSuchBucket`. The step now recreates only `app` and `alb`.
- **Lab 4 — Steps 3–4:** `stop primary; sleep 3; curl` checked too early. Failover takes about 8–10 seconds (three failed health checks, two seconds apart), so the request hung and no `SECONDARY` appeared. Step 3 now waits for the standby and times the failover; Step 4 has learners tune `inter`/`fall` and measure the shorter RTO.
- **Lab 10 — `nginx.conf`:** with the app stopped, NGINX kept connecting to the stopped container's old address, so Step 6's request hung for up to a minute (19 seconds in testing) before a 502 or 504. `proxy_connect_timeout 2s` now makes it fail fast with a 504 in about two seconds, as an ALB would.
