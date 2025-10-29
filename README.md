# Bid4Good — Salesforce Order Management App

**Bid4Good** is a Salesforce learning and portfolio project that demonstrates how to design, develop, and test a complete business process in the Salesforce platform — from data model and Apex backend, through Lightning Web Components (LWC), to automation with Flow and Change Data Capture (CDC).

---

## Introduction

This is my first project in the Salesforce ecosystem. It was created as a final exam assignment for the JET BI Salesforce Developer course.

## Functionalities

The application allows users to explore and monitor **customer orders** directly in Salesforce UI, with real-time synchronization and automated business logic.

### 🔹 Key features

- **Dynamic Order Explorer (LWC)**
  - Displays all Accounts with related Orders.
  - Lets the user pick an Account and filter Orders by **Payment Due Date (month)**.
  - Automatically refreshes after any Account or Order change (via **Change Data Capture**).
  - Shows clickable links to records (`Account` and `Order__c`).

- **Change Data Capture (CDC) integration**
  - Subscribes to `/data/AccountChangeEvent` and `/data/Order__ChangeEvent`.
  - Refreshes picklists and data tables in real time — without page reload.

- **Custom field update on Account**
  - A trigger automatically updates the custom field **`Total_Orders_Number__c`**  
    each time an `Order__c` record is created, updated, or deleted.
  - Ensures the Account always reflects the **current number of related Orders**.
  - This value is then used in the UI and logic of the Order Explorer LWC.

- **Quick Action + Flow automation**
  - A **Quick Action** on `Order__c` launches a **Flow** that sends an **email notification**  
    with key order details (customer name, total amount, due date).
  - Demonstrates how declarative tools (Flow) can extend programmatic logic (Apex + LWC).

- **Apex Controller (`OrderCController`)**
  - Exposes cacheable methods for LWC (`@AuraEnabled(cacheable=true)`).
  - Handles permission checks and FLS security using `WITH SECURITY_ENFORCED`.
  - Returns structured picklist data and filtered lists of Orders.

- **Permission Model**
  - Users with `Order_Operators` Permission Set Group can access Order data.
  - Unit tests validate correct handling of insufficient permissions.

- **Comprehensive Test Coverage**
  - Includes `TestDataFactory` and `OrderCControllerTest`.
  - Covers both positive and negative scenarios.
  - Ensures compliance with Salesforce testing best practices.

---

## Technologies & Good Practices

| Area                  | Description                                                                                |
| --------------------- | ------------------------------------------------------------------------------------------ |
| **Frontend**          | Lightning Web Components (LWC) — reactive UI with comboboxes and datatable                 |
| **Backend**           | Apex classes with `@AuraEnabled` and structured exception handling                         |
| **Automation**        | Trigger + Flow (Quick Action → Send Email)                                                 |
| **Real-time updates** | Platform Events via **Change Data Capture (CDC)**                                          |
| **Security**          | Field Level Security (FLS) checks, `WITH SECURITY_ENFORCED`, Permission Set Groups         |
| **Testing**           | Factory pattern for data creation (`TestDataFactory`), `@TestSetup`, structured assertions |
| **Error handling**    | Centralized handling using `reduceErrors()` and `ShowToastEvent`                           |
| **Performance**       | `@AuraEnabled(cacheable=true)` + `refreshApex()` for selective reloading                   |
| **Code quality**      | Clean Code conventions, SonarQube static analysis, consistent naming                       |
| **Logs & debugging**  | `System.debug` and `getStackTraceString()` for detailed tracking                           |

---

## Bad Practices ;-)

- Left console.log() in JavaScript.
- Left system.debug() in Apex.
- Left TODO cooments.

If you have any other comments about bad practices, please contact me.

## Architecture Overview

```text
┌──────────────────────────┐
│   LWC: OrderExplorer     │
│  ──────────────────────  │
│  ↳ lightning-combobox    │
│  ↳ lightning-datatable   │
│  ↳ lightning-spinner     │
│  ↳ ShowToastEvent        │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│   Apex Controller        │
│  OrderCController.cls    │
│  - getAccountsWithOrders │
│  - getPaymentDueDate...  │
│  - getOrdersForAccount...│
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│   Salesforce Data Model  │
│  Account — Order__c      │
│  (Lookup, Payment Due)   │
│  + Trigger updates       │
│ Total_Orders_Number__c   │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│   Flow & Automation      │
│  Quick Action → Flow     │
│  Sends Order email alert │
└──────────────────────────┘

```

## Test Classes

### TestDataFactory.cls

- Creates sample Accounts, Orders, and Users.
- Handles permission setup (Standard User + `Order_Operators` group).
- Prevents mixed DML by separating setup vs. non-setup object inserts.

### OrderCControllerTest.cls

- Verifies controller logic, exception handling, and cacheable methods.
- Tests both “with permission” and “without permission” scenarios.
- Validates filtering Orders by Account and Payment Due Date.
- Uses `System.runAs()` for permission-based tests.

### AccountTriggerTest.cls

- Verifies automatic recalculation of `Total_Orders_Number__c` on Account.
- Ensures proper DML handling and prevents mixed-DML issues.
- Confirms trigger behavior on insert, update, and delete events.

---

## Deployment

1. **Clone repository**
   ```bash
    git clone https://github.com/TomaszWartak/Bid4Good.git
   ```
2. **Authorize your DevHub org**
   ```bash
    sf org login web -a DevHub
   ```
3. **Deploy to scratch org**
   ```bash
    sf project deploy start
   ```
4. **Open org**
   ```bash
    sf org open
   ```
5. **Assign Permission Set Group**
   ```bash
    sf org assign permsetgroup name=Order_Operators
   ```
6. **Run tests**
   ```bash
    sf apex test run --code-coverage --result-format human
   ```

## 📚 Author

**Tomasz Wartak**  
_Salesforce Junior Enthusiast 😉 | Trailblazer | Software Engineering Enthusiast_

🔗 [LinkedIn](https://www.linkedin.com/in/tomasz-wartak/) • [Trailblazer Profile](https://www.salesforce.com/trailblazer/tomasz-wartak)
