# 🖐️ Little Hands – Childcare & Support Platform

<div align="center">
  <img src="Frontend/flutter_app/assets/images/littlehandslogo.png" alt="Little Hands Logo" height="250" />
  <h3>Little Hands</h3>
  <p>
    A trusted childcare platform connecting parents with qualified caregivers, experts, and support services.
    <br />
    <a href="https://github.com/<your-repo>/wiki"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://drive.google.com/file/d/<your-demo-link>/view?usp=sharing">View Demo</a>
  </p>
</div>

---

**Little Hands** is a mobile and web-based application designed to support parents in caring for their children’s health, development, and well-being. Whether it's booking a babysitter, finding a shadow teacher, or scheduling an expert consultation, Little Hands offers one platform for all childcare needs—especially for children with special needs.

---

## 📱 Platforms & Technologies

<div align="center">

  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white" />
  <img src="https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Socket.IO-010101?style=for-the-badge&logo=socketdotio&logoColor=white" />
  <img src="https://img.shields.io/badge/Stripe-008CDD?style=for-the-badge&logo=stripe&logoColor=white" />
  <img src="https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white" />
  <img src="https://img.shields.io/badge/Postman-FF6C37?style=for-the-badge&logo=postman&logoColor=white" />
  <img src="https://img.shields.io/badge/Gemini%20API-4285F4?style=for-the-badge&logo=google&logoColor=white" />

</div>


---

## 🎯 Key Features

### 👨‍👩‍👧 Parent-Focused Services
- Book babysitters, shadow teachers, and developmental specialists
- View caregiver profiles with feedback and availability
- Flexible session types (one-time or recurring)
- Book a meeting before confirming sessions
- Submit complaints and detailed feedback
- Explore summarized expert articles and research

### 🧑‍⚕️ Caregiver Tools
- Register as a babysitter, expert, or special needs supporter
- Set up calendar preferences and work hours
- Accept, reject, or price session requests
- Get notified in real time via sockets and FCM
- Rate and review parents post-session

### 🧠 AI-Powered Matching System
- Suggests best caregivers based on:
  - Child’s needs and age group
  - Required skills
  - Proximity and city
  - Pricing compatibility
  - Past ratings

### 💳 Payment & Confirmation Flow
- Multiple payment options: Stripe or Cash
- Meeting-based sessions available before confirmation
- Auto-invoicing and confirmation via email and notifications

### 📊 Admin Dashboard
- Live tracking of bookings, feedback, and complaints
- Platform analytics and caregiver monitoring

---

## 🔐 Security & Privacy

- Password encryption and token-based authentication (JWT)
- Verified caregivers via ID Analyzer (including age checks)
- Role-based access (Parent, Babysitter, Expert, Admin)
- Encrypted session and payment data

---

## 🛠️ Setup & Installation

### 🔧 Backend (Node.js)


- git clone https://github.com/<your-repo>/Little-Hands.git
- cd Backend
- npm install
- cp .env.example .env
- npm start

#### Frontend (Flutter)
- cd Frontend/flutter_app
- flutter pub get
- flutter run

