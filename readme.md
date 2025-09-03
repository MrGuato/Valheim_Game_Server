# Valheim Docker Server - Automated & Secure

[![Made With Love](https://img.shields.io/badge/Made%20with%20%E2%9D%A4%EF%B8%8F-by%20Jonathan-red)](https://github.com/MrGuato)
[![Deploy Valheim](https://github.com/MrGuato/<YOUR-REPO-NAME>/actions/workflows/deploy.yml/badge.svg)](https://github.com/MrGuato/<YOUR-REPO-NAME>/actions/workflows/deploy.yml)
[![Uptime Status](https://img.shields.io/uptimerobot/status/m798619615-533a3f0c1a578cd8e72699f7)](https://stats.uptimerobot.com/tybY8h8NyK)
[![Docker Compose](https://img.shields.io/badge/Docker-Compose-blue?logo=docker)](https://docs.docker.com/compose/)
[![Security Engineer](https://img.shields.io/badge/Security-Engineer-black)](https://github.com/MrGuato)

---

## Project Overview
This repository hosts a Valheim dedicated server using Docker Compose, GitHub Actions, and DevSecOps best practices.

- Dockerized Deployment - clean, portable, repeatable  
- Automated CI/CD - deploys via GitHub Actions to my Ubuntu server  
- Security-first - `.env` is excluded from Git, firewall restricts access to trusted IPs only (via UniFi)  
- Automated Updates - Watchtower keeps the container fresh and patched  
- Backups & Cron Jobs - automatic world backups, configurable retention  

---

## Architecture

```mermaid
flowchart TD
    A[GitHub Repo] -->|push main| B[GitHub Actions]
    B -->|SSH Deploy| C[Ubuntu Server]
    C --> D[Docker Compose: Valheim]
    C --> E[Watchtower: Auto-Updates]
    D --> F[Friends' Clients]
    F -->|restricted by firewall| G[Firewall]
