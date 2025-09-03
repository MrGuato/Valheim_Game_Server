# Valheim Docker Server - Automated & Secure

[![Made With Love](https://img.shields.io/badge/Made%20with%20%E2%9D%A4%EF%B8%8F-by%20Jonathan-red)](https://github.com/MrGuato)
[![Deploy Status](https://github.com/MrGuato/Valheim_Game_Server/actions/workflows/deploy.yml/badge.svg)](https://github.com/MrGuato/Valheim_Game_Server/actions/workflows/deploy.yml)
[![Known Vulnerabilities](https://snyk.io/test/github/MrGuato/Valheim_Game_Server/badge.svg)](https://snyk.io/test/github/MrGuato/Valheim_Game_Server)
[![Dependabot](https://img.shields.io/badge/Dependabot-enabled-brightgreen?logo=dependabot)]()
[![Docker Compose](https://img.shields.io/badge/Docker–Compose-blue?logo=docker)]()
![GitHub Repo stars](https://img.shields.io/github/stars/MrGuato/Valheim_Game_Server?style=social)
[![Last Commit](https://img.shields.io/github/last-commit/MrGuato/Valheim_Game_Server)]()

---

## Project Overview
This repository provides the **infrastructure-as-code** needed to run a secure, automated Valheim dedicated server.  

It does not contain game files, world data, or secrets.  
Instead, it focuses on **deployment, automation, and security hardening** using Docker Compose, GitHub Actions, and DevSecOps principles.

- Dockerized Deployment — clean, portable, repeatable  
- Security-first — `.env` is excluded from Git, firewall restricts access to trusted IPs only  
- Automated Updates — Watchtower keeps the container fresh and patched  
- Backups & Cron Jobs — automatic world backups, configurable retention  

---

## Why I Created This
As a security engineer, I wanted to show how gaming projects can double as **practical DevSecOps case studies**.  

Hosting Valheim this way demonstrates:
- **Infrastructure as Code (IaC):** the server can be spun up or rebuilt consistently anywhere.  
- **Security Best Practices:** firewall rules, secret management, and least-privilege containers.  
- **Automation & CI/CD:** using GitHub Actions and Watchtower to keep services updated safely.  
- **Resilience & Backups:** world data is backed up and can be restored quickly.  

This repo is useful for anyone who wants to **learn secure container hosting** — whether for Valheim or for other self-hosted services.

---

## Architecture

```mermaid
flowchart TD
    A[GitHub Repo] -->|push main| B[GitHub Actions]
    B -->|Deploy| C[Ubuntu Server]
    C --> D[Docker Compose: Valheim]
    C --> E[Watchtower: Auto-Updates]
    D --> F[Friends' Clients]
    F -->|restricted by IP via firewall | G[Firewall]
```
Note: This repository contains infrastructure code only.
Sensitive configuration values (passwords, Steam tokens, backups) are never committed.
