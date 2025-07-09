# MongoDB Backend Setup for My Pocket Wallet

This document provides instructions for setting up a MongoDB backend API to support real-time data for the Flutter wallet app.

## Prerequisites

- Node.js (v16 or higher)
- MongoDB Atlas account or local MongoDB installation
- npm or yarn package manager

## Quick Setup

### 1. Initialize Node.js Project

```bash
mkdir wallet-api
cd wallet-api
npm init -y
```

### 2. Install Dependencies

```bash
npm install express mongoose bcryptjs jsonwebtoken cors dotenv helmet morgan express-rate-limit
npm install -D nodemon
```

### 3. Environment Variables

Create a `.env` file in the root directory:

```env
PORT=3000
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/wallet_db
JWT_SECRET=your_super_secret_jwt_key_here
NODE_ENV=development
```

### 4. Server Structure

```
wallet-api/
├── package.json
├── .env
├── server.js
├── models/
│   ├── User.js
│   ├── Wallet.js
│   └── Transaction.js
├── routes/
│   ├── auth.js
│   ├── user.js
│   ├── wallet.js
│   ├── transactions.js
│   └── utility.js
├── middleware/
│   ├── auth.js
│   └── validation.js
└── utils/
    └── database.js
```

## Sample Server Implementation

### server.js

```javascript
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();

// Security middleware
app.use(helmet());
app.use(cors());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Logging
app.use(morgan('combined'));

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Database connection
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/user', require('./routes/user'));
app.use('/api/wallet', require('./routes/wallet'));
app.use('/api/transactions', require('./routes/transactions'));
app.use('/api/utility', require('./routes/utility'));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

## MongoDB Schema Models

### User Model (models/User.js)

```javascript
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  phoneNumber: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  pin: { type: String, required: true },
  profilePicture: String,
  isVerified: { type: Boolean, default: false },
  isPinSet: { type: Boolean, default: true },
  isBiometricEnabled: { type: Boolean, default: false },
}, {
  timestamps: true
});

userSchema.pre('save', async function(next) {
  if (!this.isModified('pin')) return next();
  this.pin = await bcrypt.hash(this.pin, 12);
  next();
});

userSchema.methods.comparePin = async function(candidatePin) {
  return await bcrypt.compare(candidatePin, this.pin);
};

module.exports = mongoose.model('User', userSchema);
```

### Wallet Model (models/Wallet.js)

```javascript
const mongoose = require('mongoose');

const walletSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  balance: { type: Number, default: 0, min: 0 },
  currency: { type: String, default: 'USD' },
  isActive: { type: Boolean, default: true },
}, {
  timestamps: true
});

module.exports = mongoose.model('Wallet', walletSchema);
```

### Transaction Model (models/Transaction.js)

```javascript
const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { 
    type: String, 
    enum: ['send', 'receive', 'payBill', 'withdraw', 'topUp', 'refund'],
    required: true 
  },
  status: { 
    type: String, 
    enum: ['pending', 'completed', 'failed', 'cancelled'],
    default: 'pending' 
  },
  amount: { type: Number, required: true, min: 0 },
  currency: { type: String, default: 'USD' },
  description: String,
  recipientPhone: String,
  recipientName: String,
  billType: String,
  accountNumber: String,
  reference: { type: String, unique: true },
  metadata: mongoose.Schema.Types.Mixed,
}, {
  timestamps: true
});

// Generate unique reference
transactionSchema.pre('save', function(next) {
  if (!this.reference) {
    this.reference = 'TXN' + Date.now() + Math.random().toString(36).substr(2, 5).toUpperCase();
  }
  next();
});

module.exports = mongoose.model('Transaction', transactionSchema);
```

## API Endpoints

### Authentication Endpoints

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login with phone and PIN
- `POST /api/auth/logout` - Logout user

### User Endpoints

- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update user profile

### Wallet Endpoints

- `GET /api/wallet/balance` - Get wallet balance
- `POST /api/wallet/top-up` - Top up wallet

### Transaction Endpoints

- `GET /api/transactions` - Get user transactions
- `POST /api/transactions/send` - Send money
- `POST /api/transactions/pay-bill` - Pay bill
- `POST /api/transactions/withdraw` - Withdraw money

### Utility Endpoints

- `GET /api/utility/bill-providers` - Get bill providers
- `POST /api/utility/validate-account` - Validate account

## Real-time Features

### WebSocket Integration

```javascript
const socketIo = require('socket.io');
const io = socketIo(server);

io.on('connection', (socket) => {
  socket.on('join-wallet', (userId) => {
    socket.join(`wallet-${userId}`);
  });
  
  // Emit real-time balance updates
  socket.on('balance-update', (data) => {
    io.to(`wallet-${data.userId}`).emit('balance-changed', data);
  });
  
  // Emit transaction updates
  socket.on('transaction-update', (data) => {
    io.to(`wallet-${data.userId}`).emit('transaction-status', data);
  });
});
```

## Deployment Options

### 1. MongoDB Atlas (Recommended)

1. Create MongoDB Atlas account
2. Create a new cluster
3. Get connection string
4. Update `.env` file

### 2. Local MongoDB

```bash
# Install MongoDB locally
brew install mongodb/brew/mongodb-community # macOS
# or download from mongodb.com

# Start MongoDB
mongod --dbpath /data/db
```

### 3. Deploy API

#### Heroku
```bash
heroku create wallet-api
heroku config:set MONGODB_URI=your_mongodb_uri
heroku config:set JWT_SECRET=your_jwt_secret
git push heroku main
```

#### Vercel
```bash
npm install -g vercel
vercel
```

#### Railway
```bash
npm install -g @railway/cli
railway deploy
```

## Flutter Integration

Update the `ApiService` base URL in your Flutter app:

```dart
// For local development
static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator

// For production
static const String baseUrl = 'https://your-api-domain.com/api';
```

## Security Best Practices

1. **Environment Variables**: Never commit sensitive data
2. **Rate Limiting**: Implement request rate limiting
3. **Input Validation**: Validate all inputs
4. **Authentication**: Use JWT tokens with proper expiration
5. **HTTPS**: Always use HTTPS in production
6. **Password Hashing**: Use bcrypt for PIN hashing
7. **CORS**: Configure CORS properly

## Testing

```bash
# Install testing dependencies
npm install -D jest supertest

# Run tests
npm test
```

## Monitoring

Consider integrating:
- **Sentry** for error tracking
- **New Relic** for performance monitoring
- **LogRocket** for user session recording

## Database Backup

Set up automated backups for production:
- MongoDB Atlas: Built-in automated backups
- Self-hosted: Use mongodump/mongorestore

## Performance Optimization

1. **Database Indexing**: Create proper indexes
2. **Caching**: Use Redis for session management
3. **Connection Pooling**: Configure MongoDB connection pools
4. **Query Optimization**: Optimize database queries

This setup provides a robust, scalable backend for your Flutter wallet app with real-time data synchronization capabilities.
