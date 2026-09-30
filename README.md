# 🏫 AI-Powered Campus Facility Issue Management System

An intelligent full-stack campus facility management platform for reporting, analyzing, assigning, tracking, and resolving facility-related issues using **Flutter, React, ASP.NET Core, PostgreSQL, and Agentic AI**.

> **SE3090 – Assignment 01**

---

## 📌 Project Overview

Universities and campuses frequently experience facility-related problems such as:

- Water leaks
- Electrical faults
- Air-conditioning problems
- Network and IT issues
- Broken furniture
- Lighting failures
- General maintenance problems

Traditional reporting methods can make it difficult to classify issues correctly, determine their urgency, assign an appropriate technician, and track the issue until completion.

The **AI-Powered Campus Facility Issue Management System** provides a centralized digital workflow for managing this process.

A reporter can submit an issue using the Flutter mobile application. The backend stores the issue and its supporting evidence, while an AI agent analyzes the report and determines its category, priority, required technical skill, and recommended action.

A second AI agent can then evaluate available technicians and recommend a suitable technician based on the issue requirements.

The AI does **not** directly make protected operational decisions. A manager reviews the recommendation through the React web dashboard and approves or rejects it before an assignment is finalized.

The assigned technician can then use the Flutter mobile application to view the job, start the work, upload completion evidence, and mark the issue as completed.

---

# 🎯 Main Objective

The main objective of this project is to create an intelligent facility issue management workflow that combines:

- Mobile issue reporting
- Web-based administration
- RESTful backend services
- PostgreSQL database management
- Secure authentication and authorization
- Image evidence management
- Agentic AI analysis
- AI-assisted technician recommendation
- Human approval
- Technician workflow management
- Issue lifecycle tracking

---

# 🏗️ System Architecture

The system consists of four main technical layers:

```text
┌───────────────────────────────────────────────┐
│             FLUTTER MOBILE APP                │
│                                               │
│  Reporter                    Technician       │
│  ────────                    ──────────       │
│  Report Issue                View Tasks       │
│  Upload BEFORE Photo         Start Work       │
│  Track Status                Complete Work    │
│  View Results                Upload AFTER     │
└──────────────────────┬────────────────────────┘
                       │
                       │ REST API / JWT
                       ▼
┌───────────────────────────────────────────────┐
│              ASP.NET CORE API                 │
│                                               │
│  Authentication & Authorization               │
│  Issue Management                             │
│  Technician Management                        │
│  Assignment Management                        │
│  File/Image Management                        │
│  Validation                                   │
│  Agent Orchestration                          │
└──────────────┬─────────────────┬──────────────┘
               │                 │
               │                 │
               ▼                 ▼
┌──────────────────────┐  ┌──────────────────────┐
│ POSTGRESQL DATABASE  │  │     AGENTIC AI       │
│                      │  │                      │
│ Users                │  │ Issue Analysis Agent │
│ Issues               │  │ Assignment Agent     │
│ Technicians          │  │                      │
│ Assignments          │  │ Gemini API / LLM     │
│ Images               │  └──────────────────────┘
│ Agent Runs           │
│ Status History       │
└──────────────────────┘
               ▲
               │
               │ REST API / JWT
               │
┌──────────────┴────────────────────────────────┐
│                REACT WEB APP                  │
│                                               │
│                 Manager                       │
│                                               │
│  Dashboard                                    │
│  Review Issues                                │
│  Run / Review AI Analysis                     │
│  Technician Recommendations                   │
│  Approve / Reject Assignments                 │
│  View Technicians                             │
│  Monitor Issue Lifecycle                      │
└───────────────────────────────────────────────┘
```

---

# 🔄 Complete System Workflow

The primary system workflow is:

```text
Reporter
   │
   ▼
Submit Facility Issue
   │
   ├── Title
   ├── Description
   ├── Location
   └── BEFORE Image
   │
   ▼
ASP.NET Core Backend
   │
   ├── Validate Request
   ├── Store Issue
   ├── Store Image
   └── Set Status = OPEN
   │
   ▼
Issue Analysis Agent
   │
   ├── Determine Category
   ├── Determine Priority
   ├── Determine Required Skill
   ├── Generate Summary
   └── Recommend Action
   │
   ▼
Backend Validation
   │
   ▼
Status = ANALYZED
   │
   ▼
Technician Assignment Agent
   │
   ├── Read Issue Requirements
   ├── Check Technicians
   ├── Check Skills
   ├── Check Availability
   └── Recommend Technician
   │
   ▼
Status = PENDING_APPROVAL
   │
   ▼
Manager Web Dashboard
   │
   ├── Review Issue
   ├── Review BEFORE Image
   ├── Review AI Analysis
   └── Review Technician Recommendation
   │
   ├──────── Reject
   │
   └──────── Approve
              │
              ▼
        Assignment Created
              │
              ▼
        Status = ASSIGNED
              │
              ▼
        Technician Mobile App
              │
              ▼
           Start Work
              │
              ▼
       Status = IN_PROGRESS
              │
              ▼
        Complete Repair
              │
              ├── Completion Note
              └── AFTER Image
              │
              ▼
        Status = COMPLETED
              │
              ▼
      Reporter / Manager
       Views Final Result
```

---

# 👥 User Roles

The application contains three main roles.

## 1. REPORTER

A reporter is a campus user who reports facility-related problems.

### Reporter Capabilities

- Login through the Flutter mobile application
- Submit a new facility issue
- Enter issue title
- Enter issue description
- Specify location
- Upload/capture a BEFORE image
- View own reported issues
- View issue details
- Track issue status
- View AI-classified information
- View completed issue information

---

## 2. TECHNICIAN

A technician is responsible for resolving assigned facility problems.

### Technician Capabilities

- Login through Flutter
- View assigned tasks
- View issue information
- View issue location
- View original BEFORE image
- Start assigned work
- Update task status
- Enter completion notes
- Capture/upload AFTER image
- Mark work as completed

---

## 3. MANAGER

The manager controls the administrative and approval workflow.

### Manager Capabilities

- Login through the React web application
- Access management dashboard
- View all reported issues
- Search and filter issues
- View detailed issue information
- View evidence images
- Run/review AI issue analysis
- Request technician recommendations
- Review AI recommendations
- Approve technician assignments
- Reject technician assignments
- View technicians
- View technician skills
- View technician availability
- Monitor issue lifecycle

---

# 🧩 Main Business Components

The project is divided into two major business components.

---

## Component 1 – Issue Reporting & AI Analysis Management

This component manages the process from issue reporting through intelligent issue analysis.

### Responsibilities

#### Flutter

- Report issue
- Add description
- Add location
- Capture/upload BEFORE image
- View own issues
- View issue status
- View issue details

#### React

- View issue list
- Search/filter issues
- View issue details
- View evidence
- View AI analysis
- Monitor issue status

#### ASP.NET Core

- Issue CRUD operations
- File upload handling
- Issue status management
- Input validation
- Issue Analysis Agent orchestration

#### PostgreSQL

Main entities include:

- Issue
- IssueImage
- IssueStatusHistory
- AgentRun

#### Agentic AI

**Issue Analysis Agent**

Responsible for understanding the reported facility problem.

---

## Component 2 – Technician Assignment & Resolution Management

This component manages technician recommendations, manager approval, and issue resolution.

### Responsibilities

#### React

- View technicians
- View analyzed issues
- Request AI technician recommendation
- Review recommendation
- Approve assignment
- Reject assignment
- Monitor assignment status

#### Flutter

- View assigned jobs
- View original problem details
- View BEFORE image
- Start work
- Add completion notes
- Upload AFTER image
- Complete job

#### ASP.NET Core

- Technician management
- Assignment management
- Recommendation workflow
- Approval/rejection
- Technician status updates
- Assignment Agent orchestration

#### PostgreSQL

Main entities include:

- Technician
- Assignment
- Issue
- IssueImage
- AgentRun

#### Agentic AI

**Technician Assignment Agent**

Responsible for recommending an appropriate technician for an analyzed issue.

---

# 📱 Flutter Mobile Application

The mobile application is developed using **Flutter**.

It supports two operational roles:

```text
REPORTER
TECHNICIAN
```

Managers use the React web application.

---

## Reporter Mobile Flow

```text
Login
  ↓
Reporter Home
  ↓
Report Issue
  ↓
Add Issue Information
  ↓
Capture / Select BEFORE Image
  ↓
Submit
  ↓
My Issues
  ↓
Issue Details
  ↓
Track Status
```

---

## Technician Mobile Flow

```text
Login
  ↓
Technician Home
  ↓
Assigned Tasks
  ↓
Task Details
  ↓
View BEFORE Image
  ↓
Start Work
  ↓
Complete Task
  ↓
Add Completion Note
  ↓
Capture / Select AFTER Image
  ↓
Submit Completion
```

---

## Flutter Main Packages

The mobile application uses packages such as:

```yaml
dio
flutter_secure_storage
image_picker
provider
intl
```

### Package Responsibilities

| Package                | Purpose                        |
| ---------------------- | ------------------------------ |
| Dio                    | REST API communication         |
| flutter_secure_storage | Secure JWT storage             |
| image_picker           | Camera/gallery image selection |
| provider               | State management               |
| intl                   | Date/time formatting           |

---

## Flutter Structure

```text
mobile/
├── assets/
│   ├── images/
│   └── icons/
│
├── lib/
│   ├── core/
│   │   ├── api/
│   │   │   ├── api_client.dart
│   │   │   └── api_endpoints.dart
│   │   │
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   │
│   │   ├── storage/
│   │   │   └── token_storage.dart
│   │   │
│   │   └── theme/
│   │       └── app_theme.dart
│   │
│   ├── models/
│   │   ├── user.dart
│   │   ├── issue.dart
│   │   └── assignment.dart
│   │
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── issue_service.dart
│   │   └── assignment_service.dart
│   │
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── issue_provider.dart
│   │   └── assignment_provider.dart
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   └── login_screen.dart
│   │   │
│   │   ├── reporter/
│   │   │   ├── reporter_home_screen.dart
│   │   │   ├── report_issue_screen.dart
│   │   │   ├── my_issues_screen.dart
│   │   │   └── issue_details_screen.dart
│   │   │
│   │   └── technician/
│   │       ├── technician_home_screen.dart
│   │       ├── task_details_screen.dart
│   │       └── complete_task_screen.dart
│   │
│   ├── widgets/
│   │   └── issue_card.dart
│   │
│   └── main.dart
│
└── test/
```

---

# 💻 React Web Management Application

The management dashboard is developed using:

- React
- Vite
- Tailwind CSS
- Axios
- React Router
- Lucide React

The web application is primarily designed for the:

```text
MANAGER
```

role.

---

## Web Features

### Authentication

- Manager login
- JWT authentication
- Manager-only access
- Persistent authenticated session
- Logout
- Protected routes

### Dashboard

The dashboard provides a high-level overview of facility operations, including issue statistics and workflow information.

### Issues Management

Managers can:

- View all issues
- Search issues
- Filter by status
- View category
- View priority
- View location
- View current status
- Open detailed issue information

### Issue Details

The detailed view can display:

- Issue title
- Description
- Location
- Category
- Priority
- Required skill
- AI summary
- Current status
- BEFORE evidence image
- AFTER evidence image
- AI actions
- Assignment recommendation

### AI Controls

Managers can initiate backend AI workflows through:

```text
Run AI Analysis
Recommend Technician
```

The React application itself does **not** directly communicate with the LLM.

All AI operations go through the ASP.NET Core backend.

### Technician Management

Managers can:

- View technicians
- Search technicians
- View skill
- View availability
- Use technician information during the assignment workflow

---

## React Structure

```text
web/
├── public/
│   └── assets/
│
├── src/
│   ├── api/
│   │   ├── apiClient.js
│   │   └── endpoints.js
│   │
│   ├── components/
│   │   ├── Layout.jsx
│   │   ├── Sidebar.jsx
│   │   ├── StatusBadge.jsx
│   │   └── LoadingSpinner.jsx
│   │
│   ├── pages/
│   │   ├── LoginPage.jsx
│   │   ├── DashboardPage.jsx
│   │   ├── IssuesPage.jsx
│   │   ├── IssueDetailsPage.jsx
│   │   └── TechniciansPage.jsx
│   │
│   ├── services/
│   │   ├── authService.js
│   │   ├── issueService.js
│   │   └── technicianService.js
│   │
│   ├── styles/
│   │   └── global.css
│   │
│   ├── App.jsx
│   └── main.jsx
│
├── package.json
├── vite.config.js
└── index.html
```

---

# ⚙️ ASP.NET Core Backend

The backend acts as the central control layer of the system.

It is responsible for:

- REST API endpoints
- Authentication
- JWT generation
- Role-based authorization
- Database access
- Business rules
- Issue management
- Technician management
- Assignment management
- File/image handling
- AI orchestration
- AI output validation
- Workflow state transitions
- Error handling

The frontend applications never access the database or AI provider directly.

```text
Flutter ──┐
          ├──► ASP.NET Core ──► PostgreSQL
React ────┘          │
                     └────────► Gemini / LLM
```

---

# 🔐 Authentication & Authorization

The system uses **JWT-based authentication**.

After successful login, the API returns a token and user information.

Example:

```json
{
  "token": "JWT_TOKEN",
  "user": {
    "id": 1,
    "name": "User Name",
    "email": "user@example.com",
    "role": "REPORTER"
  }
}
```

The JWT is included in protected requests:

```http
Authorization: Bearer JWT_TOKEN
```

---

# 🛡️ Role-Based Access Control

Protected operations are restricted according to user role.

| Operation                         | Reporter | Technician | Manager |
| --------------------------------- | :------: | :--------: | :-----: |
| Submit Issue                      |    ✅    |     ❌     |   ❌    |
| View Own Issues                   |    ✅    |     ❌     |   ❌    |
| View Assigned Tasks               |    ❌    |     ✅     |   ❌    |
| Start Work                        |    ❌    |     ✅     |   ❌    |
| Complete Work                     |    ❌    |     ✅     |   ❌    |
| View All Issues                   |    ❌    |     ❌     |   ✅    |
| Run AI Analysis                   |    ❌    |     ❌     |   ✅    |
| Request Technician Recommendation |    ❌    |     ❌     |   ✅    |
| Approve Assignment                |    ❌    |     ❌     |   ✅    |
| Reject Assignment                 |    ❌    |     ❌     |   ✅    |
| View Technician Management        |    ❌    |     ❌     |   ✅    |

---

# 🗄️ PostgreSQL Database

The system uses **PostgreSQL** as its relational database.

A hosted PostgreSQL environment such as **Supabase PostgreSQL** can be used for development and deployment.

---

## Main Database Entities

### Users

```text
id
name
email
passwordHash
role
```

### Issues

```text
id
reporterId
title
description
location
category
priority
requiredSkill
aiSummary
status
createdAt
```

### IssueImages

```text
id
issueId
imageUrl
imageType
uploadedAt
```

### Technicians

```text
id
userId
skill
isAvailable
```

### Assignments

```text
id
issueId
technicianId
status
aiReason
approvedBy
approvedAt
createdAt
```

### IssueStatusHistory

```text
id
issueId
oldStatus
newStatus
changedBy
changedAt
```

### AgentRuns

```text
id
issueId
agentType
status
outputJson
errorMessage
createdAt
completedAt
```

---

# 🔗 Main Database Relationships

```text
User
 │
 ├────< Issues
 │
 └──── Technician
           │
           │
Issue ─────┼──── Assignment
 │         │
 │         └──── Technician
 │
 ├────< IssueImages
 │
 ├────< IssueStatusHistory
 │
 └────< AgentRuns
```

---

# 📊 Issue Categories

The system supports the following categories:

```text
PLUMBING
ELECTRICAL
IT
HVAC
FURNITURE
GENERAL
```

These values should remain consistent between:

- Flutter
- React
- ASP.NET Core
- PostgreSQL
- AI structured outputs

---

# 🚨 Priority Levels

```text
LOW
MEDIUM
HIGH
```

The Issue Analysis Agent can recommend the priority based on the submitted issue.

---

# 🔄 Issue Status Lifecycle

The main issue lifecycle is:

```text
OPEN
  ↓
ANALYZED
  ↓
PENDING_APPROVAL
  ↓
ASSIGNED
  ↓
IN_PROGRESS
  ↓
COMPLETED
```

The system also supports:

```text
REJECTED
```

when a manager rejects an AI-generated assignment recommendation.

### Status Values

```text
OPEN
ANALYZED
PENDING_APPROVAL
ASSIGNED
IN_PROGRESS
COMPLETED
REJECTED
```

---

# 🖼️ Image Evidence

Images are used as evidence rather than as a mandatory AI computer-vision input.

Two image types are supported:

```text
BEFORE
AFTER
```

### BEFORE

Uploaded by the reporter when reporting the facility problem.

It helps:

- Managers understand the issue
- Technicians inspect the reported problem
- Maintain evidence of the original condition

### AFTER

Uploaded by the technician when completing the work.

It helps:

- Document the completed repair
- Allow managers/reporters to review the result
- Maintain evidence of issue resolution

The database stores the image URL/path rather than storing raw image binary data inside the Issue record.

---

# 🤖 Agentic AI

The project contains **two separate AI agent responsibilities**.

A cloud Large Language Model such as the **Gemini API** can provide the reasoning capability.

However:

```text
LLM ≠ Agent
```

The LLM provides language/reasoning capabilities.

The application-level agent provides:

- Goal
- Context
- Tool access
- Workflow
- Validation
- Structured output
- Error handling
- Backend integration

---

# 🧠 Agent 1 – Issue Analysis Agent

## Purpose

The Issue Analysis Agent understands the facility problem reported by the user.

Its responsibilities include:

- Analyze issue title
- Analyze description
- Consider location
- Determine category
- Determine priority
- Determine required technician skill
- Produce concise issue summary
- Recommend next action

---

## Agent 1 Controlled Tools

Possible backend-controlled tools include:

```text
get_issue_details(issueId)
get_issue_categories()
get_similar_issues(...)
```

The agent does not receive unrestricted database access.

---

## Agent 1 Structured Output

Example:

```json
{
  "issueId": 125,
  "category": "PLUMBING",
  "priority": "HIGH",
  "requiredSkill": "PLUMBING",
  "summary": "Water leakage from ceiling in Lab 03.",
  "recommendedAction": "Inspect the water line above Lab 03."
}
```

---

# 🛠️ Agent 2 – Technician Assignment Agent

## Purpose

The Technician Assignment Agent determines which technician is suitable for an analyzed issue.

It can consider:

- Required technical skill
- Technician skill
- Technician availability
- Current workload
- Issue requirements

---

## Agent 2 Controlled Tools

Possible controlled tools include:

```text
get_issue_requirements(issueId)
get_available_technicians()
get_technician_workload(technicianId)
```

---

## Agent 2 Structured Output

Example:

```json
{
  "issueId": 125,
  "technicianId": 2,
  "reason": "Required plumbing skill and technician is currently available."
}
```

---

# 🔗 Relationship Between the Two Agents

The two agents perform different responsibilities.

```text
ISSUE REPORTED
      │
      ▼
┌─────────────────────┐
│ Issue Analysis Agent│
└──────────┬──────────┘
           │
           │ What is the problem?
           ▼
     PLUMBING
     HIGH PRIORITY
     Needs PLUMBING skill
           │
           ▼
┌───────────────────────────┐
│ Technician Assignment     │
│ Agent                     │
└─────────────┬─────────────┘
              │
              │ Who can solve it?
              ▼
      Suitable Technician
              │
              ▼
       Manager Approval
              │
              ▼
          Assignment
```

Agent 1 understands the **problem**.

Agent 2 recommends the **person who can solve the problem**.

---

# 🔒 AI Safety and Backend Validation

AI output is treated as a **recommendation**, not unquestioned truth.

The backend validates AI output before it affects the workflow.

---

## Issue Analysis Validation

The backend verifies:

- Issue exists
- Category is allowed
- Priority is allowed
- Required skill is valid
- Required fields exist
- Output has valid structure

Example:

```text
AI Output
    ↓
ASP.NET Validation
    ↓
Valid?
 ┌──┴──┐
No    Yes
│      │
Fail   Save Result
       │
       ▼
   ANALYZED
```

---

## Technician Recommendation Validation

Before accepting a recommendation, the backend verifies:

- Technician exists
- Technician has the required skill
- Technician is available
- Issue is eligible for assignment
- Assignment does not conflict with current state

---

# 👤 Human-in-the-Loop Approval

A major design principle is that the AI cannot independently finalize a technician assignment.

The workflow is:

```text
AI Recommendation
       ↓
Backend Validation
       ↓
Pending Approval
       ↓
Manager Review
    ┌───────┐
    │       │
 Reject   Approve
    │       │
    ▼       ▼
REJECTED  ASSIGNED
```

This provides:

- Human oversight
- Better accountability
- Controlled AI usage
- Reduced risk of invalid automated decisions

---

# 📝 Agent Run History

Agent executions can be recorded in the `AgentRuns` table.

Example:

```text
Agent Type:
ISSUE_ANALYSIS

Status:
COMPLETED

Output:
{
  ...
}
```

Supported agent types:

```text
ISSUE_ANALYSIS
TECHNICIAN_ASSIGNMENT
```

Supported execution statuses:

```text
RUNNING
COMPLETED
FAILED
```

This allows the system to maintain an auditable history of AI workflow execution.

---

# 🌐 REST API

The ASP.NET Core backend exposes RESTful API endpoints for the Flutter and React applications.

---

## Authentication

### Login

```http
POST /api/auth/login
```

Used by:

```text
REPORTER
TECHNICIAN
MANAGER
```

---

# 📋 Issue API

### Submit Issue

```http
POST /api/issues
```

Role:

```text
REPORTER
```

Request type:

```text
multipart/form-data
```

Can include:

```text
title
description
location
beforeImage
```

---

### Reporter's Issues

```http
GET /api/issues/my
```

Role:

```text
REPORTER
```

---

### Get All Issues

```http
GET /api/issues
```

Role:

```text
MANAGER
```

---

### Get Issue

```http
GET /api/issues/{id}
```

Access depends on role and ownership/assignment rules.

---

### Analyze Issue

```http
POST /api/issues/{id}/analyze
```

Role:

```text
MANAGER
```

Triggers:

```text
Issue Analysis Agent
```

---

# 👨‍🔧 Technician API

### Get Technicians

```http
GET /api/technicians
```

Role:

```text
MANAGER
```

---

### Recommend Technician

```http
POST /api/issues/{id}/recommend-technician
```

Role:

```text
MANAGER
```

Triggers:

```text
Technician Assignment Agent
```

A recommendation should result in a pending approval workflow rather than an automatically finalized assignment.

---

# ✅ Assignment API

### Approve Assignment

```http
POST /api/assignments/{id}/approve
```

Role:

```text
MANAGER
```

---

### Reject Assignment

```http
POST /api/assignments/{id}/reject
```

Role:

```text
MANAGER
```

---

### Technician Tasks

```http
GET /api/technicians/my-tasks
```

Role:

```text
TECHNICIAN
```

---

### Start Assignment

```http
PATCH /api/assignments/{id}/start
```

Role:

```text
TECHNICIAN
```

Expected transition:

```text
ASSIGNED → IN_PROGRESS
```

---

### Complete Assignment

```http
PATCH /api/assignments/{id}/complete
```

Role:

```text
TECHNICIAN
```

Request type:

```text
multipart/form-data
```

Can contain:

```text
completionNote
afterImage
```

Expected transition:

```text
IN_PROGRESS → COMPLETED
```

---

# 📦 Example Issue DTO

```json
{
  "id": 125,
  "title": "Water Leakage",
  "description": "Water leaking from ceiling",
  "location": "Computer Lab 03",
  "category": "PLUMBING",
  "priority": "HIGH",
  "requiredSkill": "PLUMBING",
  "aiSummary": "Possible ceiling pipe leakage.",
  "status": "PENDING_APPROVAL",
  "beforeImageUrl": "/uploads/issues/125-before.jpg",
  "afterImageUrl": null,
  "createdAt": "2026-09-29T10:30:00Z"
}
```

---

# 📦 Technician Recommendation Example

A technician recommendation response may contain information such as:

```json
{
  "id": 10,
  "issueId": 125,
  "technicianId": 2,
  "technicianName": "Technician Name",
  "skill": "PLUMBING",
  "status": "PENDING_APPROVAL",
  "aiReason": "Required plumbing skill and technician is available."
}
```

The assignment ID can then be used by the manager to approve or reject the recommendation.

---

# ❌ Standard Error Response

A consistent API error response can use:

```json
{
  "success": false,
  "message": "Readable error message",
  "errors": []
}
```

---

# 🧰 Technology Stack

| Layer           | Technology                                 |
| --------------- | ------------------------------------------ |
| Mobile          | Flutter / Dart                             |
| Web             | React                                      |
| Web Build Tool  | Vite                                       |
| Web Styling     | Tailwind CSS                               |
| Web Routing     | React Router                               |
| Web HTTP Client | Axios                                      |
| Web Icons       | Lucide React                               |
| Backend         | ASP.NET Core / C#                          |
| API Style       | REST                                       |
| Authentication  | JWT                                        |
| Authorization   | Role-Based Access Control                  |
| Database        | PostgreSQL                                 |
| Hosted Database | Supabase PostgreSQL                        |
| Image Storage   | Supabase Storage / backend-managed storage |
| AI              | Gemini API / compatible LLM                |
| AI Architecture | Backend-controlled Agentic AI              |
| Version Control | Git / GitHub                               |

---

# 📂 Repository Structure

The project follows a monorepo structure.

```text
campus-facility-ai/
│
├── mobile/
│   └── Flutter application
│
├── web/
│   └── React + Vite management dashboard
│
├── backend/
│   └── ASP.NET Core API
│
├── docs/
│   └── Project documentation
│
├── .gitignore
└── README.md
```

---

# 🤖 Suggested Backend AI Structure

Agentic AI functionality belongs inside the backend.

```text
backend/
└── CampusFacility.Api/
    │
    ├── Controllers/
    │
    ├── Models/
    │
    ├── DTOs/
    │
    ├── Services/
    │
    ├── Data/
    │
    ├── Enums/
    │
    ├── Agents/
    │   ├── IssueAnalysisAgent.cs
    │   └── TechnicianAssignmentAgent.cs
    │
    ├── AgentTools/
    │
    ├── Program.cs
    └── appsettings.json
```

There is no requirement for a separate AI application.

```text
ASP.NET Core
     │
     ├── Business Logic
     ├── Agent Orchestration
     ├── Tool Execution
     ├── Validation
     └── Gemini API Communication
```

---

# 🔑 Environment Configuration

Sensitive values must **not** be committed to Git.

Examples include:

```text
PostgreSQL connection string
JWT secret
Gemini API key
Supabase credentials
Storage credentials
```

For local ASP.NET Core development, secrets should be stored using appropriate environment variables or .NET User Secrets.

Example conceptual configuration:

```text
ConnectionStrings__DefaultConnection=...
Jwt__Key=...
Gemini__ApiKey=...
```

Do not place production secrets directly inside source code.

---

# 🚀 Running the Web Application

Navigate to:

```bash
cd web
```

Install dependencies:

```bash
npm install
```

Start development server:

```bash
npm run dev
```

Production build:

```bash
npm run build
```

---

# 📱 Running the Flutter Application

Navigate to:

```bash
cd mobile
```

Install dependencies:

```bash
flutter pub get
```

Check the project:

```bash
flutter analyze
```

List devices:

```bash
flutter devices
```

Run:

```bash
flutter run
```

When testing with a physical mobile device, the Flutter application must use an API address reachable from the device.

Do not use the computer's `localhost` address from a physical phone.

Example:

```text
http://<COMPUTER_LAN_IP>:<PORT>/api
```

---

# ⚙️ Running the Backend

Navigate to the ASP.NET Core project:

```bash
cd backend/CampusFacility.Api
```

Restore dependencies:

```bash
dotnet restore
```

Build:

```bash
dotnet build
```

Run:

```bash
dotnet run
```

The actual API URL depends on the ASP.NET development configuration.

---

# 🔌 Frontend–Backend Integration

The React and Flutter applications communicate only through the backend API.

```text
React
  │
  └─────────────┐
                ▼
          ASP.NET Core
                │
                ├──── PostgreSQL
                │
                ├──── Image Storage
                │
                └──── Gemini API
                ▲
  ┌─────────────┘
  │
Flutter
```

The frontends must never contain:

- Database credentials
- Gemini API keys
- Supabase service credentials
- JWT signing secrets

---

# 🧪 Testing Strategy

Testing should cover each major layer.

---

## Flutter Testing

Test:

- Login
- Role routing
- Issue submission
- Image selection
- Reporter issue list
- Issue details
- Technician task list
- Start work
- Completion note
- AFTER image
- Completion workflow

---

## React Testing

Test:

- Manager login
- Protected routes
- Dashboard
- Issue loading
- Search
- Status filtering
- Issue details
- AI analysis action
- Technician recommendation
- Approval
- Rejection
- Technician list
- Error/loading/empty states
- Logout

---

## Backend Testing

Test:

- Authentication
- JWT validation
- Role authorization
- Issue CRUD
- File validation
- Technician queries
- Assignment state transitions
- Manager approval
- Technician ownership
- Invalid requests
- Unauthorized requests

---

## AI Testing

### Issue Analysis Agent

Test:

- Correct structured output
- Valid category
- Valid priority
- Required skill
- Missing data
- Invalid model output
- LLM/API failure

### Technician Assignment Agent

Test:

- Correct skill matching
- Available technician selection
- No suitable technician
- Invalid technician recommendation
- Unavailable technician
- Workload handling
- LLM/API failure

---

# 🛡️ Security Considerations

The system should implement:

- Password hashing
- JWT authentication
- Role-based authorization
- Backend input validation
- File type validation
- File size validation
- Protected manager endpoints
- Protected technician endpoints
- Reporter ownership validation
- Technician assignment ownership validation
- Secure API key management
- Database credential protection
- Controlled AI tool access

The backend remains the final authority for every protected operation.

---

# ⚠️ AI Design Principles

The project follows several important AI design principles.

### 1. AI Provides Recommendations

The AI assists the workflow instead of independently controlling protected operations.

### 2. Structured Output

Agent responses use predictable structured data rather than uncontrolled free-form responses.

### 3. Controlled Tools

Agents only receive access to explicitly defined backend tools.

### 4. Deterministic Validation

ASP.NET Core validates AI-generated results using normal application rules.

### 5. Human Approval

Technician recommendations require manager approval.

### 6. Error Handling

AI/API failures should not corrupt the normal application workflow.

### 7. Auditability

Agent executions can be stored in `AgentRuns`.

---

# 💡 Example End-to-End Scenario

A reporter notices water leaking from the ceiling of Computer Lab 03.

### Step 1 – Reporter

Using Flutter:

```text
Title:
Water Leakage

Description:
Water is leaking from the ceiling near the computers.

Location:
Computer Lab 03

BEFORE Image:
Uploaded
```

The issue is created:

```text
Status = OPEN
```

---

### Step 2 – AI Issue Analysis

The manager triggers the Issue Analysis Agent.

The agent may return:

```json
{
  "issueId": 125,
  "category": "PLUMBING",
  "priority": "HIGH",
  "requiredSkill": "PLUMBING",
  "summary": "Water leakage detected in Computer Lab 03.",
  "recommendedAction": "Inspect the ceiling water line."
}
```

The backend validates the result.

The issue becomes:

```text
ANALYZED
```

---

### Step 3 – Technician Recommendation

The manager requests a technician recommendation.

The Technician Assignment Agent evaluates suitable technicians.

Example:

```json
{
  "issueId": 125,
  "technicianId": 2,
  "reason": "Technician has the required plumbing skill and is available."
}
```

The backend validates the recommendation.

The issue becomes:

```text
PENDING_APPROVAL
```

---

### Step 4 – Manager Approval

The manager reviews:

- Issue details
- BEFORE image
- AI analysis
- Technician
- AI reason

The manager approves the recommendation.

The issue becomes:

```text
ASSIGNED
```

---

### Step 5 – Technician

The technician opens Flutter and sees the assigned job.

The technician selects:

```text
Start Work
```

The issue becomes:

```text
IN_PROGRESS
```

---

### Step 6 – Completion

After repairing the problem, the technician provides:

```text
Completion Note:
Repaired the damaged ceiling water pipe and checked for further leaks.

AFTER Image:
Uploaded
```

The issue becomes:

```text
COMPLETED
```

---

### Step 7 – Final Result

The reporter and manager can now see that the issue has been completed, together with the available before/after evidence and final status.

---

# 🔮 Possible Future Improvements

The architecture can later be extended with:

- Push notifications
- Email notifications
- Real-time updates
- Technician workload dashboards
- Maintenance analytics
- Recurring issue detection
- Building/floor mapping
- QR-based facility identification
- GPS-based issue location
- SLA tracking
- Predictive maintenance
- Image-based issue analysis
- Advanced AI recommendations

These are future enhancements and are not required for the core project workflow.

---

# 🚫 Out-of-Scope Complexity

The current solution intentionally avoids unnecessary AI complexity.

The core implementation does not require:

- Training a custom ML model
- Vector databases
- Embeddings
- RAG
- LangChain
- Local LLM hosting
- Computer vision
- Autonomous database modification

The focus is on a clear, demonstrable **Agentic AI workflow integrated into a real full-stack application**.

---

# 🌿 Git Workflow

Suggested branches:

```text
main
develop
feature/flutter
feature/react-web
feature/backend
feature/agents
```

Example development flow:

```text
feature/*
    ↓
develop
    ↓
Testing
    ↓
main
```

Never commit:

```text
.env
API keys
JWT secrets
Database passwords
Supabase service keys
Local secret configuration
```

---

# 👨‍💻 Component Ownership

Although the complete application is integrated into a single system, the academic implementation is organized around two major components.

## Student / Component 1

### Issue Reporting & AI Analysis Management

Responsible areas include:

- Issue reporting workflow
- Issue-related API functionality
- Issue-related database entities
- Relevant React interfaces
- Relevant Flutter interfaces
- Issue Analysis Agent
- Testing
- Documentation

---

## Student / Component 2

### Technician Assignment & Resolution Management

Responsible areas include:

- Technician workflow
- Assignment-related API functionality
- Technician/assignment database entities
- Relevant React interfaces
- Relevant Flutter interfaces
- Technician Assignment Agent
- Testing
- Documentation

---

# 🤝 Shared Infrastructure

The following elements are shared across the complete application:

- Authentication
- JWT
- Role management
- PostgreSQL configuration
- Common API infrastructure
- Common UI components
- File storage
- Error handling
- Security configuration

These shared elements support both major business components.

---

# 📌 Key Design Decisions

### Why Flutter?

Flutter provides a suitable cross-platform mobile interface for reporters and technicians, including camera/gallery integration.

### Why React?

React provides a responsive web-based administrative interface suitable for manager workflows.

### Why ASP.NET Core?

ASP.NET Core provides a structured backend for REST APIs, authentication, authorization, business rules, AI orchestration, and database integration.

### Why PostgreSQL?

The project contains strongly related entities such as users, issues, technicians, assignments, images, and status history, making a relational database suitable.

### Why Agentic AI?

Facility reports contain natural-language descriptions that require interpretation, while technician selection requires reasoning across issue requirements and available resources.

The agents assist these workflows while remaining under backend and human control.

---

# 🏁 Final System Summary

The **AI-Powered Campus Facility Issue Management System** demonstrates the integration of:

```text
Flutter Mobile Application
        +
React Web Dashboard
        +
ASP.NET Core REST API
        +
PostgreSQL Database
        +
Agentic AI
        +
Human Approval Workflow
```

The complete lifecycle is:

```text
REPORT
   ↓
ANALYZE
   ↓
RECOMMEND
   ↓
VALIDATE
   ↓
APPROVE
   ↓
ASSIGN
   ↓
REPAIR
   ↓
COMPLETE
```

The system combines traditional full-stack software engineering with controlled Agentic AI to create an intelligent, secure, traceable, and practical campus facility management workflow.

---

## Project

**SE3090 – Assignment 01**

**Project Title:**  
AI-Powered Campus Facility Issue Management System
