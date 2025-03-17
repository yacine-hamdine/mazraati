# Farmer Marketplace App

A **mobile marketplace** where farmers can sell their products and clients can buy directly from farmers. The app is built with **Flutter** using the **BLoC pattern** for state management. The backend is powered by **Firebase** for authentication and database services, with **Express.js** hosted on **Vercel** as an alternative to Firebase Cloud Functions.

## Features

### 🌱 For Farmers
- Create and manage product listings
- Upload product images
- Set pricing and availability
- Track orders
- Receive payments

### 🛒 For Clients
- Browse products by category
- Search for specific products
- Add products to cart
- Place and track orders
- Secure payment integration

### 🔐 Authentication
- Firebase authentication (email/password, Google sign-in)
- Secure user profiles for farmers and buyers

### 🏪 Marketplace
- Browse and filter products
- View detailed product pages
- Direct messaging between farmers and buyers

### 📦 Order Management
- Cart functionality
- Order tracking system
- Order history

## Tech Stack

### Frontend
- **Flutter** (Dart)
- **BLoC Pattern** (State Management)
- **Dio** (API requests)
- **Firebase Authentication**

### Backend
- **Firebase Firestore** (Database)
- **Express.js** (Custom backend logic)
- **Vercel** (Hosting for backend API)

## Setup & Installation

### 1️⃣ Prerequisites
- Flutter SDK installed
- Firebase project set up
- Node.js installed
- Vercel CLI installed

### 2️⃣ Clone the Repository
```bash
git clone https://github.com/yourusername/farmer-marketplace.git
cd farmer-marketplace
```

### 3️⃣ Install Dependencies
#### For Flutter App:
```bash
flutter pub get
```
#### For Backend:
```bash
cd backend
npm install
```

### 4️⃣ Set Up Firebase
- Create a Firebase project
- Enable Firestore, Authentication, and Storage
- Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the project

### 5️⃣ Run the App
```bash
flutter run
```

### 6️⃣ Deploy Backend
```bash
cd backend
vercel
```

## Contributing
Pull requests are welcome! Please follow the standard **GitHub flow**.

## License
This project is open-source under the MIT License.
