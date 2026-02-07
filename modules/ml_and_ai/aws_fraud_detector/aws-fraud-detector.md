# Amazon Fraud Detector

Amazon Fraud Detector is a fully managed service that makes it easy to identify potentially fraudulent online activities, such as online payment fraud, identity fraud, and the creation of fake accounts. It uses machine learning (ML) and over 20 years of fraud detection expertise from Amazon to automatically identify suspicious events in near real-time.

## Core Concepts

*   **Managed Fraud Detection:** Amazon Fraud Detector handles the complex ML models and infrastructure needed to identify fraud.
*   **No ML Expertise Required:** Designed for users without deep machine learning expertise.
*   **Custom Models:** Allows you to build custom fraud detection models tailored to your specific business and fraud patterns, using your own historical data.
*   **Rules Engine:** Provides a flexible rules engine to define actions based on model scores and other event data.

## Key Components and Configuration

### 1. Event Types

*   **Purpose:** An Event Type defines the structure of the data that Amazon Fraud Detector will use to evaluate for fraud. It consists of the event name, entities, labels, and event variables.
*   **Event Name:** A unique name for the type of event you want to detect fraud for (e.g., `online_registration`, `new_account_creation`, `payment_transaction`).
*   **Entities:** Represents who is performing the event (e.g., `customer`, `user`).
*   **Labels:** Categorize historical events as fraudulent or legitimate (e.g., `fraud`, `legit`). These are crucial for training the ML model.
*   **Real-life Example:** For `online_registration` events, your entities might be `customer`. Your labels would be `fraud` or `legit`.

### 2. Event Variables

*   **Purpose:** The data points that describe the event being evaluated for fraud. These are the inputs to your fraud detection models and rules.
*   **Types:**
    *   **External Variables:** Standard variables provided by Amazon Fraud Detector (e.g., `ip_address`, `email_address`, `user_agent`).
    *   **Custom Variables:** Variables unique to your business (e.g., `account_age_in_days`, `num_previous_orders`, `billing_address`).
*   **Data Types:** Define the data type for each variable (e.g., `STRING`, `INTEGER`, `BOOLEAN`).
*   **Real-life Example:** For a payment transaction, you might define variables like `payment_amount`, `currency`, `card_type`, `billing_city`, `shipping_country`, and use the external `ip_address` variable.

### 3. Models

Amazon Fraud Detector can build custom machine learning models to identify fraud.

*   **Model Types:**
    *   **Online Fraud Insights (OFI):** For identifying various types of online fraud.
    *   **Account Takeover Insights (ATI):** Specialized for detecting account takeover attempts.
    *   **Transaction Fraud Insights (TFI):** Focused on payment transaction fraud.
    *   **Custom Model:** You can choose to train a generic custom model.
*   **Training Data:** You provide historical event data (including labels for `fraud` or `legit`) in an S3 bucket.
*   **Training and Evaluation:** Amazon Fraud Detector automatically prepares the data, trains multiple ML models, and evaluates their performance.
*   **Model Version:** Each trained model has a version number.
*   **Model Score:** When a model is used for real-time prediction, it returns a "model score" (e.g., 0-1000) indicating the likelihood of fraud.
*   **Real-life Example:** You have 6 months of historical `payment_transaction` data, with each transaction labeled as `fraud` or `legit`. You use this data to train a new version of a Transaction Fraud Insights model.

### 4. Detectors

A Detector is the core logic that defines how Amazon Fraud Detector evaluates an event for fraud. It combines one or more models and a set of rules.

*   **Detector Version:** Detectors are versioned, allowing you to iterate on your fraud detection logic.
*   **Rules:**
    *   **Purpose:** Define the actions to take based on the evaluation of variables and model scores. Rules are written using a simple expression language.
    *   **Example:** `($ip_address in $high_risk_ip_list) or ($payment_amount > 1000 and $model_score > 900)`.
    *   **Outcomes:** For each rule, you define an `outcome` (e.g., `Approve`, `Review`, `Reject`).
    *   **Rule Execution Mode:**
        *   **FIRST_MATCHED:** Executes actions for the first rule that matches.
        *   **ALL_MATCHED:** Executes actions for all rules that match.
*   **Real-life Example:** You create a `PaymentDetector`.
    *   **Rule 1:** "If `ip_address` is from a known blocked list OR `payment_amount` is greater than $5000" -> `Outcome: Reject`.
    *   **Rule 2:** "If `payment_transaction_model` score is > 800" -> `Outcome: Review`.
    *   **Rule 3:** "If no other rules match" -> `Outcome: Approve`.

### 5. Outcomes

*   **Purpose:** Represents the result of a fraud detection decision.
*   **Actions:** You define custom outcomes that correspond to actions your application can take (e.g., `APPROVE`, `REVIEW`, `REJECT`, `BLOCK_ACCOUNT`).
*   **Real-life Example:** When a transaction is evaluated, it returns an outcome of `REVIEW`. Your application then routes this transaction to a manual review queue for a fraud analyst.

## Integrating Fraud Detector

*   **API Call:** You integrate Amazon Fraud Detector into your application by making a `GetEventPrediction` API call in real-time.
*   **Input:** You pass the `eventId`, `eventTypeName`, `entities`, and `eventVariables` to the API call.
*   **Output:** The API call returns the fraud detection `outcome`, `modelScores`, and any `matchedRules`.
*   **Real-life Example:** Before processing an online payment, your backend application makes a `GetEventPrediction` call to Amazon Fraud Detector with all the relevant payment details. Based on the returned `outcome` (e.g., `REJECT`), the application can immediately block the transaction.

## Purpose and Real-life Use Cases

*   **Online Payment Fraud:** Identifying fraudulent credit card transactions, chargebacks, and account compromises.
*   **New Account Fraud:** Detecting the creation of fake accounts, bot registrations, or accounts created for spamming/phishing.
*   **Identity Fraud:** Verifying user identities to prevent account takeovers or synthetic identity fraud.
*   **Loyalty Program Abuse:** Identifying suspicious activity in loyalty programs.
*   **Click Fraud:** Detecting fraudulent clicks on online advertisements.
*   **Gaming:** Identifying bots, unauthorized access, or cheating behavior.

Amazon Fraud Detector allows businesses to quickly deploy sophisticated fraud detection capabilities, leveraging Amazon's extensive expertise in this domain, thereby reducing fraud losses and improving customer trust.
