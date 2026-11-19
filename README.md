# Deploy and Host Opik on Railway

Opik is Comet's open-source platform (Apache-2.0) for debugging, evaluating and monitoring LLM applications, RAG systems and agents. It records traces and spans from your code, scores them with LLM-as-a-judge and heuristic metrics, runs experiments on datasets, and offers a prompt playground, prompt library and production dashboards.

## About Hosting Opik

Opik's self-hosted stack has eight services. This template runs all of them on Railway, wired together over the private network. The web UI (nginx) is the only public service, and it sits behind a login whose password is generated at deploy time. The Java backend runs the MySQL and ClickHouse schema migrations on every start, then serves the API. A Python backend runs evaluation metrics and the optimizer worker. ClickHouse stores traces and spans, with ZooKeeper coordinating it. MySQL holds projects, datasets and prompts, Redis queues jobs, and MinIO keeps attachments. Every stateful service has its own volume. The first deploy takes about 5–10 minutes.

## Common Use Cases

* Trace LLM calls, RAG pipelines and agents (OpenAI, Anthropic, LangChain, LlamaIndex, CrewAI and more) and inspect each step
* Evaluate prompts and models against datasets with built-in and custom metrics, and compare experiments
* Monitor production LLM traffic with online evaluation rules, feedback scores and cost/latency dashboards

## Dependencies for Opik Hosting

* MySQL 8.4 and Redis 7.4 (official images, pinned by digest)
* ClickHouse 26.3, ZooKeeper 3.9 and MinIO, built from this repository's folders

### Deployment Dependencies

* Opik source and releases: https://github.com/comet-ml/opik/releases
* Opik self-hosting guide: https://www.comet.com/docs/opik/self-host/overview
* Template repository: https://github.com/aalfath/opik-railway-template

### Implementation Details

| Service | What it does | Storage |
|---|---|---|
| `Opik` (public) | Web UI and reverse proxy for `/api`, behind a login | none |
| `Opik Backend` | REST API, migrations, background jobs | none |
| `Opik Python Backend` | Python metrics and the optimizer worker (process executor) | none |
| `ClickHouse` | Traces, spans, feedback scores | volume |
| `ZooKeeper` | Coordination for ClickHouse's replicated tables | volume |
| `MySQL` | Projects, datasets, prompts, settings | volume |
| `Redis` | Job queues, rate limits, caches | volume |
| `MinIO` | Attachments (images, files) | volume |

**After deploy:** open the `Opik` service's URL and sign in as `opik` with the password in that service's `OPIK_AUTH_PASSWORD` variable. To log traces from the Python SDK, point it at your deployment and send the same password as the API key:

```python
import opik
opik.configure(url="https://YOUR-DOMAIN/api", api_key="OPIK_AUTH_PASSWORD value", workspace="default", use_local=False)
```

or set `OPIK_URL_OVERRIDE=https://YOUR-DOMAIN/api` and `OPIK_API_KEY=` that password in your app's environment. To use the playground or LLM-as-a-judge metrics, add your model provider key under Configuration → AI Providers in the UI.

**Updates:** every service builds from the public repository `aalfath/opik-railway-template`, which pins each image by version and digest. When a new Opik release is tested there, Railway shows an "update available" notice on your project. Read `CHANGELOG.md` first: the backend migrates the databases on start.

**Left out on purpose:** the guardrails backend (a GPU model server, optional), the OpenTelemetry collector and Jaeger (optional tracing of Opik itself), and the Docker-in-Docker code sandbox (needs privileged containers; Python metrics run in the process executor instead).

## Why Deploy Opik on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Opik on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
