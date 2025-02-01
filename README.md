# 👔 Men's Fashion E-Commerce App

[![Flutter](https://img.shields.io/badge/Flutter-3.13.8-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

A modern Flutter-based e-commerce application specializing in men's fashion, featuring product browsing, cart management, user authentication, and profile customization.


## ✨ Features

- **User Authentication**: Secure sign-up/login with email/password
- **Product Catalog**: Browse clothing items with filters and search
- **Shopping Cart**: Manage items with quantity/size selection
- **User Profile**: Customizable profile with image upload
- **Order Management**: Track purchase history
- **Responsive Design**: Optimized for mobile and tablet

## 📸 Screenshots

| Home Screen | Product View | Cart | Profile Screen |
|-------------|--------------|------|----------------|
| ![Home](https://ibb.co/G4k5jgcM) | ![Product](https://ibb.co/k6m8xW1p) | ![Cart](https://ibb.co/XxqJ7c5y) | ![Profile](https://ibb.co/fGXWHwfh) |

## 🚀 Getting Started

### Prerequisites
- Flutter 3.13.8+
- Dart 3.1.0+
- Node.js (for JSON Server)

### Installation


1. Clone repository:
```bash
git clone https://github.com/emad60/men-fashion-app.git
```
2. Install dependencies:
```bash
    flutter pub get
```
3. Start JSON Server (in separate terminal):
```bash
    cd api && json-server --watch db.json --port 3000
```
4. Run the app:
```bash
    flutter run
```



🛠 Tech Stack

- Frontend: Flutter

- State Management: Provider

- Backend: JSON Server

- Authentication: Local Storage

- Image Handling: Image Picker

- Navigation: Flutter Navigator 2.0



🔗 API Reference

```bash
GET    /products       List all products
POST   /users          Create new user
PATCH  /users/{id}     Update user profile
DELETE /users/{id}     Delete account
```


🤝 Contributing


- Fork the Project

- Create your Feature Branch (git checkout -b feature/AmazingFeature)

- Commit your Changes (git commit -m 'Add some AmazingFeature')

- Push to the Branch (git push origin feature/AmazingFeature)

- Open a Pull Request


📄 License

Distributed under the MIT License. See LICENSE for more information.


📧 Contact

Emad Al-Ghail - emadalghail60@gmail.com


Project Link: https://github.com/emad60/men-fashion-app