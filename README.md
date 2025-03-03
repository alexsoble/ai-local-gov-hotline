# Try it out!

Call 331-244-7720.

# Setup

## Local

You'll need the following installed locally:

1. `ruby`
2. `bundler`
3. `redis`: key-value datastore

Install dependencies:

```
make install
```

Run the app locally:

```
make local
```

This will start redis locally and spin up a local server at localhost:4567.

## Cloud

You'll need accounts for these services:

1. Twilio: telephony provider
2. Heroku: app cloud hosting

Provision your Heroku instance with a Redis server.

### Deploy

```
make deploy
```

# High-level architecture

```mermaid
flowchart TD
    User([User]) <--> |"Voice"| Twilio[Twilio Service]

    subgraph "Application Server"
        AppLogic[API & Business Logic]
    end

    Twilio <--> |"Webhooks/API"| AppLogic

    AppLogic <--> |"API Requests"| Claude[Claude AI API]

    AppLogic <--> |"Store/Retrieve"| Redis[(Redis Keystore)]

    classDef external fill:#f96,stroke:#333,stroke-width:2px
    classDef storage fill:#69b,stroke:#333,stroke-width:2px
    classDef app fill:#9d9,stroke:#333,stroke-width:2px

    class User,Twilio,Claude external
    class Redis storage
    class AppLogic app
```

# Tech stack choices

* Twilio: Excellent APIs, strong documentation.
* Claude: Low hallucination, strong reasoning, long context window.
	* Chose to pass in Raleigh Water Department FAQ data within the prompt context window not as RAG. This guarnatees data visibility, and has lower latency.
