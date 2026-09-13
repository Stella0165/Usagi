# Lumi by Team Usagi

### Problem Statement
Stress & Workload Manager

### Video Presentation Link


### Presentation slides
[https://canva.link/c50m5jabcklmn35](https://canva.link/c50m5jabcklmn35)

# 1 Project Overview
## 1.1 Problem Statement

University students often need to manage assignments, classes, part-time work, social commitments, errands, and their physical and mental wellbeing at the same time.

The main problem is not only having many tasks, but also not having a clear view of how much total workload they are carrying. This may cause students to accept too many commitments, delay lower-priority tasks, and reduce their recovery time.

Lumi is designed to help students understand their workload earlier and manage it more sustainably.

---

## 1.2 Target Users and Stakeholders

Primary target user: Full-time university students managing multiple academic and non-academic commitments, especially those balancing coursework with part-time work, social activities, and personal responsibilities.

Stakeholder: University Students
Need/Interest: Understand and manage total workload more sustainably.

Stakeholder: Universities / student support
Need/Interest: Encourage earlier workload awareness and sustainable study habits.

Stakeholder: Lecturers / tutors
Need/Interest: Students manage academic responsibilities more effectively.

Stakeholder: Development team
Need/Interest: Build a practical, accessible and usable solution.

---


## 1.3 Similar Solution & Gap
Example: Todoist

Task-management apps are useful for organising tasks and deadlines, but Lumi is positioned around a different question: not only "What do I need to do?" but also "How much can I realistically carry?" Lumi combines workload visibility, wellbeing check-ins, rebalancing, and recovery support in one student-focused flow.

---

## 1.4 Our Solution

Lumi is a personal workload and capacity manager for university students.

It allows users to manage commitments, view their workload, check their stress or wellbeing, rebalance flexible commitments, and use AI support when needed.

Instead of only asking:

> "What do I need to do?"

Lumi also focuses on:

> "How much can I realistically handle?"

---

## 1.5 Core Features

- User registration and login
- Add, edit and delete commitments
- Commitment categories
- Priority and deadline management
- Capacity and workload viewing
- Stress / health check-in
- Rebalance flexible commitments
- AI chat support

---

# 2. Ideation & Process

## 2.1 Ideas Considered

| Idea | Decision | Reason |
|---|---|---|
| Personal Capacity Dashboard | Keep | Helps users understand their total workload. |
| Smart Load Balancer | Keep | Helps users take action when overloaded. |
| Quick Stress Check-in | Keep | Connects workload with how the user is feeling. |
| Recovery Nudges | Drop | It only supports recovery rather than productivity. |
| AI Workload Insight | Future | Provides additional support based on workload. |
| Generic AI Chatbot | Keep | Useful for user interactions. |
| Calendar Integration | Future | Useful, but not necessary for the MVP. |
| Wearable / Sleep Integration | Future | Too complex for the current development period. |
| Social Leaderboard | Drop | May create additional pressure for users. |

---

## 2.2 Ideation Boards

The mindmap shows the main problem, user needs, workload categories, possible features, expected impact, and final concept.

![Ideation Mindmap](https://drive.google.com/file/d/1GKTMqyod8HAnlJGxaP_HQ9nCeKoC98pm/view?usp=sharing)

---

## 2.2.1 Problem Tree

The problem tree shows the causes of student overload, the main problem, and its possible effects.

![Problem Tree](https://drive.google.com/file/d/1JtpX_-aXtK5XsjTq8ESJzuXuMipMpvXY/view?usp=sharing)

---

## 2.2.2 User Flow

The user flow shows how a user moves through Lumi from login and commitment entry to workload checking, rebalancing, and recovery support.

![User Flow](https://drive.google.com/file/d/1CStMPi6HFUe9iANfQRSNzt5sX-ojn_-7/view?usp=sharing)

---

## 2.2.3 Idea Evolution

The concept was refined from a simple stress tracker into a personal capacity manager. The key refinement was moving from passive tracking to an action-oriented flow that helps the user understand, rebalance, and recover.

**Stress Tracker → Stress + Tasks → Capacity Manager → Rebalance + Recover**

The main improvement was changing the application from only tracking stress into helping users take action when their workload becomes too high.

![Idea Evolution](https://drive.google.com/file/d/1wfAbRBSjO_D2b6vHMXSWripa6JpXW-k3/view?usp=sharing)

---

## 2.3 Mentor Consultation

| Date | Mentor | Feedback | Changes Made |
|---|---|---|---|
| 11/9/2026 | Zack Khong | Add more commitment categories. | Added categories such as Academic, Health, Personal, and Financial. |
| 11/9/2026 | Zack Khong | Add an AI helper to automatically create commitments. | Not implemented due to limited development time. |

Not all mentor suggestions were implemented because the prototype development period was limited.

---

# 3. Design & Prototype

## 3.1 UI Prototype

[https://usagi.appwrite.network/](https://usagi.appwrite.network/)

---

## 3.2 Main Commitments Page

Users can view their commitments for different weeks.

They can also access their capacity, health check-in, and account options. Users can select an existing commitment to edit it.

![Main Commitments Page](https://drive.google.com/file/d/1yO_n7tgL2CTI0KasgbPjSDTPO_2uTEwL/view?usp=sharing)

---

## 3.3 Edit Commitment Page

Users can edit the information of an existing commitment or delete it.

![Edit Commitment Page](https://drive.google.com/file/d/1FNzxmlSmsVKcAG9Gk-iEoQxkrjOIio5L/view?usp=sharing)

---

## 3.4 Rebalance Page

When users have a high workload, they can move flexible commitments to the following week.

![Rebalance Page](https://drive.google.com/file/d/1cS_oJNVOc0SJuHnOkVIm9zkbffmbDL0S/view?usp=sharing)

---

## 3.5 AI Chat Page

Users can access the AI chat when they want additional support or someone to talk to.

![AI Chat Page](https://drive.google.com/file/d/11s7jDWRWP_WeTw0JmXGWihU6V-_mcdkP/view?usp=sharing)

---

# 4 What Makes Lumi Different

The Stress & Workload Manager combines task management, stress tracking and recovery support in one application. Instead of only helping users complete tasks, the application also considers whether the user’s overall workload is becoming unhealthy through AI analysis.

Lumi is designed as a personal capacity manager rather than simply another task manager or stress tracker. Its main twist is that it does not stop at showing tasks or recording stress. It combines workload visibility, wellbeing check-ins, rebalancing, and recovery in one continuous flow so students can act before a high-load period becomes unmanageable.

| Feature | Difference |
|---|---|
| Capacity View | Shows workload as limited capacity instead of only showing deadlines. |
| Load Balancer | Helps users move flexible commitments when overloaded. |
| Workload + Wellbeing | Combines planned workload with stress or wellbeing check-ins. |
| Recovery Support | Encourages users to consider recovery time as part of planning. |

### Expected Impact

**Before Lumi:**  
Students may be able to see individual tasks but may not understand their overall workload.

**After Lumi:**  
Students can identify overloaded periods earlier and make adjustments to their commitments.

---

# Technical Architecture & Feasibility

## Frontend

**Flutter**

Flutter was chosen because it supports web, Android, and desktop using one codebase.

It also provides reusable UI components suitable for dashboards, task management, and workload visualisation.

**Constraint:**  
Some Flutter plugins may behave differently across platforms.

---

## Backend

**Appwrite**

Appwrite provides backend services such as authentication, database access, and user management without requiring a separate backend server.

**Constraint:**  
The free plan has resource and usage limits.

---

## Database

**Appwrite Database**

The database stores commitments, user information, and wellbeing-related information online.

This allows users to access their information across different devices.

**Constraint:**  
An internet connection is required.

---

## Authentication

**Appwrite Auth**

Appwrite Auth provides user registration, login, and session management.

It also helps ensure each user's data is connected to their own account.

**Constraint:**  
Authentication depends on internet access and Appwrite availability.

---

## AI API

**Gemini API**

Gemini is used to support AI-related features such as recovery suggestions and AI chat.

**Constraint:**  
The free API tier has usage limits.

---

## Version Control

**GitHub**

GitHub is used for source control, version history, and project backup.

---

## Hosting

**Appwrite Sites**

Appwrite Sites is used to host the Flutter web application.

Using Appwrite for both hosting and backend helps simplify the setup.

---

## System Architecture

![System Architecture Diagram](IMAGE_LINK_HERE)

---

# Build Scope

The minimum project scope includes:

- User registration and login
- Add commitments
- Edit commitments
- Delete commitments
- Commitment categories

Additional features implemented include:

- Capacity viewing
- Stress / health check-in
- Rebalancing
- AI chat

Some implemented features may be slightly different from the original idea because the project was adjusted during development based on time and feasibility.

The main objective remains the same: helping students understand and manage their workload.

---

# Video Presentation

**Unlisted YouTube Video:**  
[YOUR_YOUTUBE_LINK_HERE]

The video presents:

- The problem
- Lumi's solution
- The main prototype features
- What makes Lumi different
- The technology used
- Expected user impact

---

# Presentation Slides

[https://canva.link/c50m5jabcklmn35](https://canva.link/c50m5jabcklmn35)

---

# Project Links

**Public GitHub Repository:**  
[https://github.com/Stella0165/Usagi.git](https://github.com/Stella0165/Usagi.git)

**Prototype:**  
[https://usagi.appwrite.network/](https://usagi.appwrite.network/)

**Unlisted YouTube Video:**  
[YOUR_YOUTUBE_LINK_HERE]

**Presentation Slides:**  
[https://canva.link/c50m5jabcklmn35](https://canva.link/c50m5jabcklmn35)

---

# Team

**Team Name:** Usagi

| Member | Role |
|---|---|
| Stella Wong Kai Ning | Tech Stack / Programming |
| Tan Xiao Jie | Decoumentation |