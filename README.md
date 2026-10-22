# Colaborative IDE for Devs

A real-time collaborative code editor. Multiple developers join with a username, edit the same file together in a Monaco (VS Code) editor, and see who is online.

## Live Demo

**http://docker-aws-ALB-111196544.us-east-2.elb.amazonaws.com**

Hosted on AWS (us-east-2) behind an Application Load Balancer, running the backend as a Docker container.

Open the link in two browser tabs, join with different usernames, and type in one tab to see it appear in the other. You can also join directly with `?username=yourname` in the URL.

## Features

- Real-time collaborative editing with conflict-free merging (CRDTs via Yjs)
- Monaco editor with syntax highlighting (the editor that powers VS Code)
- Username-based join flow and online users sidebar (Yjs awareness)
- WebSocket sync over Socket.IO
- `/health` endpoint for load balancer health checks
- Dockerized backend that also serves the built frontend

## Tech Stack

| Layer | Technology |
| --- | --- |
| Frontend | React 19, Vite, Tailwind CSS 4, `@monaco-editor/react` |
| Collaboration | Yjs, `y-monaco`, `y-socket.io` |
| Backend | Node.js 20, Express 5, Socket.IO |
| Deployment | Docker (`node:20-alpine`), AWS Application Load Balancer |

## Project Structure

```
.
├── Backend/            # Express + Socket.IO + y-socket.io server
│   ├── server.js
│   └── public/         # Built frontend, served statically
├── Frontend/           # React + Vite app
│   └── src/app/App.jsx
├── dockerfile          # Builds the backend image
└── .dockerignore
```

## How It Works

1. A user enters a username on the join screen.
2. The frontend connects to the backend with `SocketIOProvider` and joins the shared `monaco` Yjs document.
3. `MonacoBinding` keeps the editor content in sync with the Yjs document, and the backend relays updates to all connected clients.
4. Yjs awareness tracks each user's presence for the sidebar.

## Getting Started

### Prerequisites

- Node.js 20+
- Docker (optional, for running the container)

### Run locally

Backend (port 3000):

```bash
cd Backend
npm install
npm start
```

Frontend (Vite dev server):

```bash
cd Frontend
npm install
npm run dev
```

The frontend connects to `http://localhost:3000` by default.

### Run with Docker

Build from the repository root:

```bash
docker build -t backend .
docker run -p 3000:3000 backend
```

Then open http://localhost:3000. The `.dockerignore` keeps local `node_modules` out of the image, so native modules are built for Linux inside the container.

### Build the frontend for the backend to serve

```bash
cd Frontend
npm run build
```

Copy the contents of `Frontend/dist` into `Backend/public`.

## API

| Route | Description |
| --- | --- |
| `GET /health` | Returns `{ "message": "ok", "success": true }` |
| `GET /` | Serves the built frontend from `Backend/public` |
| WebSocket | Socket.IO endpoint used by `y-socket.io` for document sync |

## Deployment on AWS

- Backend image is built from the root `dockerfile` and runs on port 3000.
- An Application Load Balancer in `us-east-2` forwards traffic to the container.
- The ALB health check should target `/health`.
- Socket.IO needs WebSocket support. If you run more than one container, enable sticky sessions on the target group.
